/*
 * This program is part of the OpenCms Mercury Template.
 *
 * Copyright (c) Alkacon Software GmbH & Co. KG (http://www.alkacon.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// the global objects that must be passed to this module
var jQ;
var DEBUG;
var VERBOSE;

"use strict";

var m_fixedHeader = null;
var m_$anchor = null;
var m_menuTimeout = null;
var m_subMenuTimeout = null;
var m_firstInit = true;
var $topControl = null;

var m_isWrapMenu = false;
var m_$navToggleLabel = null;

function setKeyboardClass(active) {
    if (active) {
        jQ(document.documentElement).addClass('keyboard-nav');
    } else {
        jQ(document.documentElement).removeClass('keyboard-nav');
    }
}

function insertMegaMenu(path, $megaMenuParent) {

    // check if the mega menu structure has submenus, if so change HTML to match "no submenu" case
    var $subMenuLink = $megaMenuParent.find("a.nav-label");
    if ($subMenuLink.length > 0) {
        // this is required because otherwise the HTML/CSS for the mega menu does not work
        var $subMenuTrigger = $megaMenuParent.find("a[aria-label]");
        $subMenuLink.attr("aria-controls", $subMenuTrigger.attr("aria-controls"));
        $subMenuTrigger.remove();
    }

    jQ.ajax({
        method : "GET",
        url : path + "?__disableDirectEdit=true&megamenu=true",
        cache : true,
        dataType : "text"
    }).done(function(content) {

        var $menuListEntry = $megaMenuParent.find("ul");
        var idAttr = $menuListEntry.attr("id");
        var $dropdown = jQuery("<div></div>").addClass("nav-menu").addClass("nav-mega-menu").attr("id", idAttr);
        var $row = jQuery(content).find(".row").first();
        $dropdown.append($row);

        $menuListEntry.remove();
        $megaMenuParent.append($dropdown);
    });
}

function initMegaMenu() {

    if (DEBUG) console.info("Navigation.initMegaMenu()");

    if (Mercury.gridInfo().isMobileNav()) {
        // .mega-only marks mega menus that are a) not displayed in mobile and b) have no submenu
        var $megaMenus = jQ(".mega-only[data-megamenu]");
        if (DEBUG) console.info("Navigation.initMegaMenu() .mega-only[data-megamenu] elements found: " + $megaMenus.length);
        $megaMenus.each(function() {
            // these mega menus must be removed
            var $megaMenuItem = jQ(this);
            $megaMenuItem.removeAttr("aria-expanded");
            $megaMenuItem.removeAttr("data-megamenu");
            $megaMenuItem.children("a").removeAttr("aria-controls");
            $megaMenuItem.children("ul").remove();
        });
    }

    var megaSelector = Mercury.gridInfo().isDesktopNav() ? "[data-megamenu]" : ".mega-mobile[data-megamenu]";
    var $megaMenus = jQ(megaSelector);
    if (DEBUG) console.info("Navigation.initMegaMenu() " + megaSelector + " elements found: " + $megaMenus.length);

    $megaMenus.each(function() {
        var $megaMenuItem = jQ(this);
        insertMegaMenu($megaMenuItem.data("megamenu"), $megaMenuItem);
        // attach event listener the the mega menu nav item
        $megaMenuItem.on('mouseenter touchstart focus', function(e) {
            // calculate top position from main menu item
            var posTop = $megaMenuItem.position().top + $megaMenuItem.outerHeight();
            // calculate left position from the .nav-main-container
            var $megaMenu = $megaMenuItem.find('.nav-mega-menu');
            var $menuContainer = $megaMenuItem.closest('.nav-main-container');
            var posLeft = -1 * ($menuContainer.offset().left - ((Mercury.windowWidth() - $megaMenu.outerWidth()) / 2));
            if (DEBUG) console.info("MegaMenu: Setting position top=" + posTop + " left=" + posLeft);
            // set the position
            $megaMenu.css('top', posTop + 'px');
            $megaMenu.css('left', posLeft + 'px');
        });
    });

    jQ(document).on('click', '.nav-main-container .nav-mega-menu', function(e) {
        e.stopPropagation();
    });
}

var lastInitMenuStatus = 0;

function initMenu() {
    var initMenuStatus = Mercury.gridInfo().isMobileNav() ? 1 : 2;
    if (initMenuStatus != lastInitMenuStatus) {
        lastInitMenuStatus = initMenuStatus;
        // Close all menus
        var $allMenus = jQ('.nav-main-items [aria-expanded]');
        if (DEBUG) console.info("Navigation.initMenu() .nav-main-items [aria-expanded] elements found: " + $allMenus.length);
        if ($allMenus.length > 0 ) {
            $allMenus.attr("aria-expanded", "false");
        }
        if (Mercury.gridInfo().isMobileNav()) {
            // Activate current menu position
            var $activeMenus = jQ('.nav-main-items [aria-expanded].active');
            if (DEBUG) console.info("Navigation.initMenu() .nav-main-items [aria-expanded].active elements found: " + $activeMenus.length);
            if ($activeMenus.length > 0 ) {
                $activeMenus.attr("aria-expanded", "true");
            }
        }
    }
}

function resetMenu($menuToggle) {
    jQ(".nav-main-items [aria-expanded]").each(function(i) {
        if (!$menuToggle || !jQ.contains(this, $menuToggle[0])) {
            var $this = jQ(this);
            $this.removeClass("open-left");
            $this.removeClass("open-right");
            $this.attr("aria-expanded", "false");
            $this.find(".nav-menu").first().css("right", "");
        }
    });
}

function toggleMenu($submenu, $menuToggle, targetmenuId, event) {

    // check which kind of event was triggered
    var eventMouseenter = event.type == "mouseenter";
    var eventMouseleave = event.type == "mouseleave";
    var eventKeydown = (event.type == "keydown" && ((event.which == 13) || (event.which == 32))); // limit keydown to enter and space
    var eventTouchstart = event.type == "touchstart";
    var eventClick = event.type == "click";

    var expanded = $submenu.attr("aria-expanded") == "true";
    var stopEventPropagation = false;

    if (eventMouseenter && m_menuTimeout) {
        clearTimeout(m_menuTimeout);
    }
    if ((eventMouseenter || eventMouseleave) && m_subMenuTimeout) {
        clearTimeout(m_subMenuTimeout);
    }

    if (Mercury.gridInfo().isDesktopNav()) {
        if (VERBOSE) console.info("Navigation.toggleMenu, isDesktopNav=true eventMouseenter=" + eventMouseenter + " eventMouseleave=" + eventMouseleave);
        // desktop navigation
        var $targetmenu = jQ("#" + targetmenuId).first();
        if (!expanded && (eventMouseenter || eventKeydown || eventTouchstart)) {
            stopEventPropagation = true;
            resetMenu($menuToggle);
            $submenu.attr("aria-expanded", "true");
            if ($submenu.parent().hasClass("nav-main-items")) {
                // this is a toplevel menu entry
                if ($targetmenu.offset().left + $targetmenu.outerWidth() > Mercury.windowWidth()) {
                    // this menu must open left
                    $submenu.addClass("open-left");
                } else {
                    $submenu.removeClass("open-left");
                }
            } else {
                // this is a sublevel menu entry
                var openRight = $targetmenu.closest('.open-right').length > 0;
                var openLeft = $targetmenu.closest('.open-left').length > 0;
                if (openRight || (openLeft && ($submenu.offset().left - $targetmenu.outerWidth() <= 0))) {
                    // we have opened left too far, open to the right again
                    $submenu.addClass("open-right");
                } else if (openLeft || ($targetmenu.offset().left + $targetmenu.outerWidth() > Mercury.windowWidth())) {
                    // this menu must open left, the right corner is outside window
                    $submenu.addClass("open-left");
                    var $parent = $submenu.parent();
                    if ($parent.outerWidth() > Math.floor(parseFloat($parent.css("min-width")))) {
                        // parent is wider than min-width from CSS, adjust right position
                        $targetmenu.css("right", $parent.outerWidth());
                    }
                }
            }
        } else if (expanded && (eventMouseleave || eventKeydown || eventTouchstart)) {
            if (eventMouseleave) {
                // only close open menu if this is NOT a top level menu (top level menu has separate timeout)
                if (!$submenu.parent().hasClass("nav-main-items")) {
                    // stopEventPropagation must remain false, otherwise top level menus would not close
                    m_subMenuTimeout = setTimeout(function() {
                        $submenu.attr("aria-expanded", "false");
                    }, 375);
                }
            } else {
                stopEventPropagation = true;
                $submenu.attr("aria-expanded", "false");
            }
        }
    } else if (eventTouchstart || eventClick) {
        // mobile navigation
        stopEventPropagation = true;
        resetMenu($menuToggle);
        $submenu.attr("aria-expanded", !expanded);
    }

    if (stopEventPropagation) {
        event.preventDefault();
        event.stopPropagation();
    }
}

// Elements in head navigation
function initHeadNavigation() {

    // If the mouse leaves a toplevel menu, set a timeout to close the menu
    jQ('.nav-main-items > li[aria-expanded]').on('mouseleave', function(e) {
        if (m_subMenuTimeout) {
            clearTimeout(m_subMenuTimeout);
        }
        if (Mercury.gridInfo().isDesktopNav()) {
            m_menuTimeout = setTimeout(resetMenu, 750);
        }
    });

    // If the mouse enters a toplevel menu, close all other menus
    jQ('.nav-main-items > li > a').on('mouseenter', function(e) {
        // This will be triggered only for toplevel menu items
        if (Mercury.gridInfo().isDesktopNav()) {
            if (m_menuTimeout) {
                clearTimeout(m_menuTimeout);
            }
            if (m_subMenuTimeout) {
                clearTimeout(m_subMenuTimeout);
            }
            resetMenu();
        }
    });

    // Select all menu elements
    var $menuToggles = jQ('.nav-main-items [aria-controls]');
    if (DEBUG) console.info("Navigation.initHeadNavigation() .nav-main-items [aria-controls] elements found: " + $menuToggles.length);

    if ($menuToggles.length > 0 ) {
        $menuToggles.each(function() {

            // initialize menus with values from data attributes
            var $menuToggle = jQ(this);
            var targetmenuId = $menuToggle.attr("aria-controls");
            if (typeof targetmenuId !== 'undefined') {
                var $submenu = $menuToggle.parent();
                $menuToggle.on('keydown touchstart click', function(e) {
                    // open menus if trigger is clicked
                    toggleMenu($submenu, $menuToggle, targetmenuId, e);
                });
                $submenu.on('mouseenter mouseleave', function(e) {
                    // also open menus if mouse enters (hovers) above it and closes if mouse leaves
                    toggleMenu($submenu, $menuToggle, targetmenuId, e);
                });
            }
        });
    }

    // Activate current menu elements in case of mobile navigation
    initMenu();
    jQ(window).on('resize', debInitMenu);

    m_$navToggleLabel = jQ('#nav-toggle-label');
    m_isWrapMenu = false || jQ('header.wh').length;

    // Responsive navbar toggle button
    jQ('.nav-toggle').click(function() {
        jQ('.nav-toggle').toggleClass('active');
        jQ(document.documentElement).toggleClass('active-nav');
        updateNavTogglePosition();
    });

    // Add handler for top scroller
    var $topControlBtn = jQ('#topcontrol, .topcontrol, .topcontrol-nohide');
    // multiple selectors allow to add topcontrol in template as well
    if ($topControlBtn) {
            // just the function, no hiding of the button on mobile
            $topControlBtn.on('click', function(e) {
            scrollToAnchor(jQ('body'));
        });
    }
    $topControl = jQ('#topcontrol, .topcontrol');
    if ($topControl) {
        // hide the button on mobile
        jQ(window).on('scroll resize', function(e) {
            var isVisible = $topControl.hasClass('show');
            if (jQ(window).scrollTop() > 300) {
                if (!isVisible) {
                    $topControl.addClass('show');
                }
            } else if (isVisible) {
                $topControl.removeClass('show');
            }
        });
    }

    // Hover Selector used for language switch
    jQ('.hoverSelector').on('mouseenter mouseleave', function(e) {
        jQ('.hoverSelectorBlock', this).toggleClass('expanded');
        e.stopPropagation();
    });

    // Add handler for elements that should not keep the focus
    jQ('[data-toggle], .blur-focus').on('mouseleave', function(e) {
        jQ(this).blur();
    });

    // If user presses tab, add marker class to document body to enable focus highlighting
    jQ(document.documentElement).on('keydown', function(e) {
        if (e.which == 9) {
            setKeyboardClass(true);
        }
    });

    // If the mouse is moved, remove focus highlight marker class
    jQ(document.documentElement).on('mousemove', function(e) {
        setKeyboardClass(false);
    });

    // Fixed top navbar header
    var $header = jQ('.area-header');
    if ($header.length > 0) {
        var $fixedHeader = $header.first().find('.sticky');
        if ($fixedHeader.length > 0) {
            var fixCssSetting = $fixedHeader.hasClass('csssetting');
            if (!fixCssSetting || (Mercury.gridInfo().getNavFixHeader() != "false")) {
                if (DEBUG) console.info("Navigation.initHeadNavigation() Fixed header element found!");
                m_fixedHeader = {};
                m_fixedHeader.$header = $header;
                m_fixedHeader.$parent = $fixedHeader.first();
                m_fixedHeader.$element = $fixedHeader.find('.head').first();
                m_fixedHeader.$element.addClass('notfixed');
                m_fixedHeader.$header.addClass('header-notfixed');
                m_fixedHeader.isFixed = false;

                var fixAlways = $fixedHeader.hasClass('always');
                var fixUpscroll = $fixedHeader.hasClass('upscroll');
                var cssSetting = Mercury.gridInfo().getNavFixHeader() == "upscroll";
                m_fixedHeader.useUpscroll = (cssSetting && !fixAlways) || fixUpscroll;

                m_fixedHeader.getHeight = function () {
                    return this.height > 0 ? this.height : this.$element.height();
                }
                jQ(window).on('scroll', debUpdateFixedScroll).on('resize', debUpdateFixedResize);
                updateFixed(true);
            } else {
                if (DEBUG) console.info("Navigation.initHeadNavigation() Fixed header element found, but disabled by CSS!");
            }
        } else {
            if (DEBUG) console.info("Navigation.initHeadNavigation() Fixed header element NOT found!");
        }
    };

    if ((m_fixedHeader == null) && m_isWrapMenu) {
        // no fixed header, make sure to update the wrap menu "hamburger" position after resize and scroll
        jQ(window).on('scroll', debUpdateNavTogglePosition).on('resize', debUpdateNavTogglePosition);
        updateNavTogglePosition();
    }
}

var m_lastScrollTop = 0;
var m_checkScrollTop = 999999999999; // Stupid IE 10 does not know Number.MAX_SAFE_INTEGER

function mobileNavActive() {
    return jQ(document.documentElement).hasClass('active-nav');
}

function updateNavTogglePosition() {
    if (m_isWrapMenu) {
        // this is only needed in the "wrap menu" theme
        var navToggleTop = 0;
        var navToggleHeight = m_$navToggleLabel.outerHeight(false);
        var navToggleBorder = parseInt(m_$navToggleLabel.find(".nav-toggle").first().css("border-top-width"));
        if (mobileNavActive()) {
            // warp menu navigation is active
            var $logo = jQ('header.wh .nav-main-mobile-logo');
            var hLogoHeight = $logo.length ? $logo.outerHeight(true) : 0;
            navToggleTop = Math.round((hLogoHeight / 2.0) - (navToggleHeight / 2.0) + (Mercury.isEditMode() ? 52 : 0));
            if (VERBOSE) console.info("Nav toggle [active] top=" + navToggleTop + " .nav-main-mobile-logo.height=" + hLogoHeight);
        } else {
            // wrap menu navigation is hidden
            var $hLogoCol = jQ('header.wh .head .h-logo-col');
            var hLogoColHeight = $hLogoCol.length ? $hLogoCol.outerHeight(true) : 0;
            if ((m_fixedHeader != null) && m_fixedHeader.isFixed) {
                // header is fixed
                m_fixedHeader.$header.addClass('icon-fixed');
                var $hMeta = jQ('header.wh .head > .h-meta:visible');
                var hMetaHeight = $hMeta.length ? $hMeta.outerHeight(true) : 0;
                navToggleTop = Math.round((hLogoColHeight / 2.0) - (navToggleHeight / 2.0) + hMetaHeight + (Mercury.isEditMode() ? 52 : 0));
                if (VERBOSE) console.info("Nav toggle [fixed] top=" + navToggleTop + " .h-logo-col.height=" + hLogoColHeight + " .h-meta.height=" + hMetaHeight);
            } else if ($hLogoCol.bottomVisible()) {


                // header is not fixed and logo column is visible

                m_fixedHeader.$header.removeClass('icon-fixed');
                var $hLogo = jQ('header.wh .head .h-logo');
                var hLogoHeight = $hLogo.outerHeight(true);

                var hLogoTop = $hLogo.offset().top - m_fixedHeader.$header.offset().top;
                if (m_fixedHeader.$header.hasClass('mp-m')) {
                    navToggleTop = Math.round((hLogoHeight / 2.0) - (navToggleHeight / 2.0) + hLogoTop);
                } else if (m_fixedHeader.$header.hasClass('mp-t')) {
                    navToggleTop = hLogoTop - navToggleBorder;
                } else {
                    // position must be bottom
                    navToggleTop = hLogoHeight - navToggleHeight + navToggleBorder + hLogoTop;
                }
                if (VERBOSE) console.info("Nav toggle [notfixed] top=" + navToggleTop + " .h-logo.height=" + hLogoHeight + " .h-logo.top=" + hLogoTop);


            } else {
                // header is not fixed but the logo column is no longer visible
                m_fixedHeader.$header.addClass('icon-fixed');
                navToggleTop = -1;
            }
        }
        if (navToggleTop > -1) {
            m_$navToggleLabel.css('top', navToggleTop);
        } else {
            m_$navToggleLabel.css('top', '');
        }
        if (! m_$navToggleLabel.hasClass('ready')) {
             setTimeout(function() { m_$navToggleLabel.addClass('ready') }, 1000);
        }
    }
}

function updateFixed(resize) {

    if (VERBOSE) console.info("Fixed header update, resize=" + resize);
    // Update position of fixed header.
    // This is more complicated then it appears since the fixed header height
    // can be different from the attached header height, e.g. if a class '.hidden-fixed' is used.
    // In order to correctly calculate anchor link positions we must make sure to use the correct
    // header height depending on the page scroll state.
    if (Mercury.gridInfo().showFixedHeader()) {
        if (VERBOSE) console.info("Fixed header update, showFixedHeader=true");
        // assuming this event handler is only called if m_fixedHeader != null
        // only do this if desktop head nav is shown
        if (resize) {
            m_fixedHeader.bottom = m_fixedHeader.$parent.offset().top + m_fixedHeader.$parent.height();
        }
        var scrollUp = true;
        if (m_fixedHeader.useUpscroll) {
            scrollUp = resize || m_lastScrollTop > Mercury.windowScrollTop();
            m_lastScrollTop = Mercury.windowScrollTop();
            if (! scrollUp) {
                m_checkScrollTop = m_lastScrollTop - 50;
            }
        }
        var fixHeader = scrollUp && (m_fixedHeader.bottom < (Mercury.windowScrollTop() + Mercury.toolbarHeight()));
        if (VERBOSE) console.info("Fixed header update, fixHeader=" + fixHeader + " m_fixedHeader.isFixed=" + m_fixedHeader.isFixed);
        if (fixHeader && !m_fixedHeader.isFixed) {
            // if mobile nav is active, don't fix the header, otherwise there would be an ugly css effect on the mobile nav
            if (!mobileNavActive()) {
                // header should be fixed, but is not
                if (VERBOSE) console.info("Fixed header update, fixing header at m_lastScrollTop=" + m_lastScrollTop  +  " m_checkScrollTop=" + m_checkScrollTop);
                if (m_lastScrollTop < m_checkScrollTop) {
                    m_fixedHeader.isFixed = true;
                    m_fixedHeader.$parent.height(m_fixedHeader.$element.height());
                    m_fixedHeader.$element.removeClass('notfixed').removeClass('scrolled').addClass('isfixed');
                    m_fixedHeader.$header.removeClass('header-notfixed').addClass('header-isfixed');
                    m_fixedHeader.height = m_fixedHeader.$element.height();
                    m_checkScrollTop = 999999999999;
                }
            }
        } else if (!fixHeader && m_fixedHeader.isFixed) {
            // header should not be fixed, but is
            m_fixedHeader.isFixed = false;
            m_fixedHeader.$element.removeClass('isfixed').addClass('notfixed');
            m_fixedHeader.$header.removeClass('header-isfixed').addClass('header-notfixed');
            m_fixedHeader.$parent.height("auto");
        }
        if (!m_fixedHeader.isFixed) {
            // add class to identify a header that has been scrolled but is not fixed yet
            if (Mercury.windowScrollTop() > 0) {
                m_fixedHeader.$element.addClass('scrolled');
            } else {
                m_fixedHeader.$element.removeClass('scrolled');
            }
        }
        if (resize) {
            // resize may lead to changes in the header height, make sure we don't use outdated values
            m_fixedHeader.height = m_fixedHeader.isFixed ? m_fixedHeader.$element.height() : -1;
            if (VERBOSE) console.info("Header is " + (m_fixedHeader.isFixed ? "" : "NOT ") + "fixed, fixed height: " + m_fixedHeader.getHeight());
        }
    } else {
        // smaller screens: make sure the head height is set to "auto"
        if (VERBOSE) console.info("Fixed header update, showFixedHeader=false");
        if (m_fixedHeader.isFixed) {
            m_fixedHeader.isFixed = false;
            m_fixedHeader.$element.removeClass('isfixed').addClass('notfixed');
            m_fixedHeader.$header.removeClass('header-isfixed').addClass('header-notfixed');
            m_fixedHeader.$parent.height("auto");
        }
    }
    updateNavTogglePosition();
}

function fixedHeaderActive() {

    return (m_fixedHeader != null) && Mercury.gridInfo().showFixedHeader();
}

// add click handler and adjust position on initial page load
function initSmoothScrolling() {

    // attach click handler to anchor links on the page
    jQ('a[href*="#"]:not([href="#"]):not([data-toggle]):not([data-slide])').click(function() {
        if (location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//, '') && location.hostname == this.hostname) {
            var $target = jQ(this.hash);
            if ($target.length) {
                jQ(this).blur();
                scrollToAnchor($target);
                return false;
            }
        }
    });

    // for initial page load, make sure we adjust scroll position for fixed header and OpenCms toolbar
    if (location.hash.length) {
        if (DEBUG) console.info("Navigation.initSmoothScrolling() Initial anchor (location.hash): " + location.hash);
        scrollToAnchor(jQ(location.hash));
    }
}

// Clickme-Showme effect sections
function initClickmeShowme() {

    var $clickSections = jQ('.clickme-showme');
    if (DEBUG) console.info("Navigation.initClickmeShowme() .clickme-showme elements found: " + $clickSections.length);
    $clickSections.each(function() {

        var $element = jQ(this);
        var $clickme = $element.find('> .clickme');
        var $showme  = $element.find('> .showme');

        if (DEBUG) console.info("Navigation.initClickmeShowme() initializing " + $clickme.getFullPath());

        $clickme.click(function() {
            $clickme.slideUp();
            $showme.slideDown();
        });

        $showme.click(function() {
            $showme.slideUp();
            $clickme.slideDown();
        });
    });
}

// apply "external" class to all a href links
function initExternalLinks() {

    var $aHrefs = jQ('.piece text a');
    if (DEBUG) console.info("Navigation.initExternalLinks() a elements found in '.piece text': " + $aHrefs.length);
    if (DEBUG) console.info("Navigation.initExternalLinks() location.hostname is: " + location.hostname);
    try {
        if (! Mercury.isEditMode()) {
            $aHrefs.each(function() {

                var $element = jQ(this);
                var hostname = $element.prop("hostname");
                if (hostname && hostname !== location.hostname) {
                    $element.addClass("external");
                }
            });
        } else {
            if (DEBUG) console.info("Navigation.initExternalLinks() skipped external a element extension because of edit mode");
        }
    } catch (err) {
        // required otherwise IE may prodice an error and stop execution
        console.info("initExternalLinks() Error " + err);
    }
}

// functions that require the Mercury object
var debUpdateFixedResize;
var debUpdateFixedScroll;
var debUpdateNavTogglePosition;
var debInitMenu;
var debScrollToAnchor;

function initDependencies() {

    debUpdateFixedResize = Mercury.debounce(function() {
        updateFixed(true)
    }, 25, true);

    debUpdateFixedScroll = Mercury.debounce(function() {
        updateFixed(false)
    }, 5);

    debUpdateNavTogglePosition = Mercury.debounce(function() {
        updateNavTogglePosition();
    }, 5);

    debInitMenu = Mercury.debounce(function() {
        initMenu();
    }, 100);

    debScrollToAnchor = Mercury.debounce(function($anchor, offset) {
        if ($anchor.length) {
            offset = offset || 0;
            var targetTop = $anchor.offset().top + offset;
            if (DEBUG) console.info("Navigation.debScrollToAnchor(#" + $anchor.attr('id') + ") position:" + targetTop);
            if (fixedHeaderActive() && (targetTop > m_fixedHeader.bottom)) {
                if (m_fixedHeader.height < 0) {
                    // fixed header height is unknown, i.e. page was not scrolled down so far
                    // jump to header bottom to activate the fixed header first
                    if (targetTop > m_fixedHeader.bottom) {
                        jQ('html, body').scrollTop(m_fixedHeader.bottom - Mercury.toolbarHeight() + 1);
                        updateFixed(true);
                    }
                }
                targetTop = targetTop - m_fixedHeader.getHeight();
                if (DEBUG) console.info("Navigation.debScrollToAnchor(#" + $anchor.attr('id') + ") adjusting position to:" + targetTop);
            }
            var page = $("html, body");
            // see: https://stackoverflow.com/questions/18445590/jquery-animate-stop-scrolling-when-user-scrolls-manually
            page.on("scroll mousedown wheel DOMMouseScroll mousewheel keyup touchmove", function(){
                page.stop();
            });
            page.animate({ scrollTop: Math.ceil(targetTop - Mercury.toolbarHeight()) }, 1000, function(){
                page.off("scroll mousedown wheel DOMMouseScroll mousewheel keyup touchmove");
            });
            if (Mercury.gridInfo().isMobileNav()) {
                // close the mobile navigation
                jQ('.nav-toggle').removeClass('active');
                jQ(document.documentElement).removeClass('active-nav');
            }
        }
    }, 500, true);
}

/****** Exported functions ******/

// Smooth scrolling to anchor links
export function scrollToAnchor($anchor, offset) {
    if ($anchor.length) {
        debScrollToAnchor($anchor, offset);
    }
}

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = true || debug;
    VERBOSE = true || DEBUG && (Mercury.getParameter("jsverbose") != null);

    if (DEBUG) console.info("Navigation.init()");

    if (m_firstInit) {
        initDependencies();
        initMegaMenu();
        initHeadNavigation();
    }
    m_firstInit = false;

    initSmoothScrolling();
    initClickmeShowme();
    initExternalLinks();
}
