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

var KEYBOARD_PERMANENT = "keyboard-permenent";

var m_fixedHeader = null;
var m_$anchor = null;
var m_menuTimeout = null;
var m_subMenuTimeout = null;
var m_firstInit = true;
var m_isBurgerHeader = false;
var m_keyboardNavActive = false;
var m_keyboardNavPermanent = false;

var $topControl = null;

let m_nmc = null;
let m_isActive = false;

function removeKeyboardClass(event) {
    setKeyboardClass(false);
}

function setKeyboardClass(active) {
    if (active || m_keyboardNavPermanent) {
        if (! m_keyboardNavActive) {
            m_keyboardNavActive = true;
            jQ(document.documentElement).addClass('keyboard-nav');
            jQ(document.documentElement).on('mousemove', removeKeyboardClass);
        }
    } else {
        if (m_keyboardNavActive) {
            m_keyboardNavActive = false;
            jQ(document.documentElement).removeClass('keyboard-nav');
            jQ(document.documentElement).off('mousemove', removeKeyboardClass);
        }
    }
}

function setKeyboardNavPermanent(active) {
    m_keyboardNavPermanent = active;
    if (m_keyboardNavPermanent) {
        setKeyboardClass(true);
        jQ('#keyboard-toggle').attr("aria-checked", "true");
        PrivacyPolicy.setCookie(KEYBOARD_PERMANENT, "true");
    } else {
        jQ('#keyboard-toggle').attr("aria-checked", "false");
        PrivacyPolicy.removeCookie(KEYBOARD_PERMANENT);
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
        // .mega-only marks mega menus that a) are not displayed in mobile and b) have no submenu
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
            var posLeft = -1 * ($menuContainer.offset().left - ((window.innerWidth - $megaMenu.outerWidth()) / 2));
            if (DEBUG) console.info("MegaMenu: Setting position top=" + posTop + " left=" + posLeft);
            // set the position
            $megaMenu.css('top', posTop + 'px');
            $megaMenu.css('left', posLeft + 'px');
        });
        let headerEl = $megaMenuItem.closest('.header-group.sticky .head')[0];
        if (headerEl != null) {
            headerEl.addEventListener('header:notfixed', (e) => {
                $megaMenuItem.removeClass("ed");
            });
            headerEl.addEventListener('header:isfixed', (e) => {
                $megaMenuItem.removeClass("ed");
            });
        }
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
        var $allMenus = jQ('.nav-main-items li.expand');
        if (DEBUG) console.info("Navigation.initMenu() .nav-main-items li.expand elements found: " + $allMenus.length);
        if ($allMenus.length > 0 ) {
            $allMenus.children("[aria-expanded]").attr('aria-expanded', false);
            $allMenus.removeClass("ed");
        }
        if (Mercury.gridInfo().isMobileNav()) {
            // Activate current menu position
            var $activeMenus = jQ('.nav-main-items li.expand.active');
            if (DEBUG) console.info("Navigation.initMenu() .nav-main-items li.expand.active elements found: " + $activeMenus.length);
            if ($activeMenus.length > 0 ) {
                $activeMenus.children("[aria-expanded]").attr('aria-expanded', true);
                $activeMenus.addClass("ed");
            }
        }
    }
}

function resetMenu($menuToggle) {
    jQ(".nav-main-items li.expand").each(function() {
        if (!$menuToggle || !jQ.contains(this, $menuToggle[0])) {
            var $this = jQ(this);
            $this.removeClass("ed");
            $this.removeClass("open-left");
            $this.removeClass("open-right");
            $this.children("[aria-expanded]").attr('aria-expanded', false);
            $this.find(".nav-menu").first().css("right", "");
        }
    });
}

function toggleMenu($submenu, $menuToggle, targetmenuId, event) {

    // check which kind of event was triggered
    var eventMouseenter = event.type == "mouseenter";
    var eventMouseleave = event.type == "mouseleave";
    var eventKeydown = (event.type == "keydown" && ((event.which == 13) || (event.which == 32))); // limit keydown to enter and space
    var eventTouch = event.type == (Mercury.gridInfo().isDesktopNav() ? "touchstart" : "touchend");
    var eventClick = event.type == "click";

    var expanded = $submenu.hasClass("ed");
    var stopEventPropagation = false;

    if (eventMouseenter && m_menuTimeout) {
        clearTimeout(m_menuTimeout);
    }
    if ((eventMouseenter || eventMouseleave) && m_subMenuTimeout) {
        clearTimeout(m_subMenuTimeout);
    }

    if (Mercury.gridInfo().isDesktopNav()) {
        if (eventClick && m_keyboardNavActive) {
            // screen reades like NVDA will send click instead of keydown
            eventKeydown = true;
            eventClick = false;
        }
        if (VERBOSE) console.info("Navigation.toggleMenu, isDesktopNav=true eventMouseenter=" + eventMouseenter + " eventMouseleave=" + eventMouseleave, $submenu ,$menuToggle);
        // desktop navigation
        var $targetmenu = jQ("#" + targetmenuId).first();
        if (!expanded && (eventMouseenter || eventKeydown || eventTouch)) {
            stopEventPropagation = true;
            resetMenu($menuToggle);
            $submenu.addClass("ed");
            $submenu.children("[aria-expanded]").attr('aria-expanded', true);
            if ($submenu.parent().hasClass("nav-main-items")) {
                // this is a toplevel menu entry
                if ($targetmenu.offset().left + $targetmenu.outerWidth() > window.innerWidth) {
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
                } else if (openLeft || ($targetmenu.offset().left + $targetmenu.outerWidth() > window.innerWidth)) {
                    // this menu must open left, the right corner is outside window
                    $submenu.addClass("open-left");
                    var $parent = $submenu.parent();
                    if ($parent.outerWidth() > Math.floor(parseFloat($parent.css("min-width")))) {
                        // parent is wider than min-width from CSS, adjust right position
                        $targetmenu.css("right", $parent.outerWidth());
                    }
                }
            }
        } else if (expanded && (eventMouseleave || eventKeydown || eventTouch)) {
            if (eventMouseleave) {
                // only close open menu if this is NOT a top level menu (top level menu has separate timeout)
                if (!$submenu.parent().hasClass("nav-main-items")) {
                    // stopEventPropagation must remain false, otherwise top level menus would not close
                    m_subMenuTimeout = setTimeout(function() {
                        $submenu.removeClass("ed");
                        $submenu.children("[aria-expanded]").attr('aria-expanded', false);
                    }, 375);
                }
            } else {
                stopEventPropagation = true;
                $submenu.removeClass("ed");
                $submenu.children("[aria-expanded]").attr('aria-expanded', false);
            }
        }
    } else if (eventTouch || eventClick) {
        // mobile navigation
        stopEventPropagation = true;
        resetMenu($menuToggle);
        $submenu.children("[aria-expanded]").attr('aria-expanded', !expanded);
        if (expanded) {
            $submenu.removeClass("ed");
        } else {
            $submenu.addClass("ed");
        }
    }

    if (stopEventPropagation) {
        event.preventDefault();
        event.stopPropagation();
    }
}

function toggleHeadNavigation() {
    var toggle = jQ('.nav-toggle-btn');
    toggle.toggleClass('active-nav');
    m_isActive = toggle.hasClass('active-nav');
    toggle.attr('aria-expanded', m_isActive);
    jQ(document.documentElement).toggleClass('active-nav');
    let $focusOn;
    if (m_isActive) {
        $focusOn = jQ('#nav-toggle-label-close > .nav-toggle-btn.active-nav');
        if ($focusOn.length < 1) $focusOn = jQ('html.keyboard-nav #nav-toggle-label-close.nav-toggle-btn.active-nav');
    } else {
        $focusOn = jQ('#nav-toggle-label-open > .nav-toggle-btn');
        if ($focusOn.length < 1) $focusOn = jQ('html.keyboard-nav #nav-toggle-label-open.nav-toggle-btn');
    }
    $focusOn.focus();
}

// Elements in head navigation
function initHeadNavigation() {

    // If the mouse leaves a toplevel menu, set a timeout to close the menu
    jQ('.nav-main-items > li.expand').on('mouseleave', function(e) {
        if (m_subMenuTimeout) {
            clearTimeout(m_subMenuTimeout);
        }
        if (Mercury.gridInfo().isDesktopNav()) {
            m_menuTimeout = setTimeout(resetMenu, 750);
        }
    });

    // If the mouse enters a toplevel menu, close all other menus
    jQ('.nav-main-items > li > a:last-of-type:not([aria-controls])').on('mouseenter', function(e) {
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

            // initialize menus with values from aria attributes
            var $menuToggle = jQ(this);
            var targetmenuId = $menuToggle.attr("aria-controls");
            if (typeof targetmenuId !== 'undefined') {
                var $submenu = $menuToggle.parent();
                if (!$menuToggle.hasClass("click-direct")) {
                    $menuToggle.on('keydown touchstart click', function(e) {
                        // open menus if trigger is clicked
                        toggleMenu($submenu, $menuToggle, targetmenuId, e);
                    });
                }
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

    m_isBurgerHeader = false || jQ('header.bh').length;

    // Responsive navbar toggle button
    jQ('.nav-toggle-btn').on('click', toggleHeadNavigation);
    jQ('.head-overlay').click(function() {
        jQ('.nav-toggle-btn').removeClass('active-nav');
        jQ(document.documentElement).removeClass('active-nav');
    });

    // Add handler for top scroller
    var $topControlBtn = jQ('#topcontrol, .topcontrol, .topcontrol-nohide');
    // multiple selectors allow to add topcontrol in template as well
    if ($topControlBtn) {
        // just the function, no hiding of the button on mobile
        $topControlBtn.on('click', function(e) {
            scrollToAnchor(jQ('body'));
        });
        addEnterIsClick($topControlBtn);
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
    jQ('[data-bs-toggle], .blur-focus').on('mouseleave', function(e) {
        jQ(this).blur();
    });

    // If user presses tab, add marker class to document body to enable focus highlighting
    const $nmc = jQ('.nav-main-container');
    if ($nmc.length > 0) m_nmc = $nmc.get(0);
    jQ(document.documentElement).on('keydown', function(e) {
        if (e.which == 9) {
            setKeyboardClass(true);
            if (m_isActive && m_isBurgerHeader && (m_nmc != null)) {
                // Close the burger header if the focus is outside
                setTimeout(() => {
                    const hasFocus = m_nmc.contains(document.activeElement);
                    if (VERBOSE) console.info("Navigation.keydown() focus in navigation: " + hasFocus);
                    if (! hasFocus) toggleHeadNavigation();
                }, 100);
            }
        }
    });

    jQ('#skip-to-content').on('keydown', function(e) {
        if ((e.which == 13) || (e.which == 32)) {
            setKeyboardNavPermanent(!m_keyboardNavPermanent);
        }
    });

    if (PrivacyPolicy.hasCookie(KEYBOARD_PERMANENT)) {
        setKeyboardNavPermanent(true);
    }

    // Fixed / sticky header
    var $header = jQ('.area-header');
    if ($header.length > 0) {
        var $fixedHeader = $header.first().find('.sticky');
        if ($fixedHeader.length > 0) {
            var fixCssSetting = $fixedHeader.hasClass('csssetting');
            if (!fixCssSetting || (Mercury.gridInfo().getNavFixHeader() != "false")) {
                if (DEBUG) console.info("Fixed header element found!");
                m_fixedHeader = {};
                m_fixedHeader.$header = $header;
                m_fixedHeader.$parent = $fixedHeader.first();
                m_fixedHeader.$element = $fixedHeader.find('.head').first();

                if (m_isBurgerHeader) {
                    m_fixedHeader.$toggleOpen = jQ('#nav-toggle-label-open');
                    m_fixedHeader.$toggleParent = m_fixedHeader.$toggleOpen.parent();
                    m_fixedHeader.$toggleClose = jQ('#nav-toggle-label-close');
                }

                resetFixedHeader();

                var fixAlways = $fixedHeader.hasClass('always');
                var fixUpscroll = $fixedHeader.hasClass('upscroll');
                var cssSetting = Mercury.gridInfo().getNavFixHeader() == "upscroll";
                m_fixedHeader.useUpscroll = (cssSetting && !fixAlways) || fixUpscroll;

                m_fixedHeader.getHeight = function () {
                    return this.height > 0 ? this.height : this.$element.height();
                }
                window.addEventListener("scroll", debUpdateFixedScroll, { passive: true });
                window.addEventListener("resize", debUpdateFixedResize, { passive: true });
                updateFixed(true);
            } else {
                if (DEBUG) console.info("Fixed header element found, but disabled by CSS!");
            }
        } else {
            if (DEBUG) console.info("Fixed header element NOT found!");
        }
    };
}

var m_lastScrollTop = 0;
var m_checkScrollTop = 999999999999; // Stupid IE 10 does not know Number.MAX_SAFE_INTEGER

function mobileNavActive() {
    return jQ(document.documentElement).hasClass('active-nav');
}

function resetFixedHeader() {
    // rest fixed header in intial state, i.e. header is on top page is not scrolled
    if (m_fixedHeader != null) {
        m_fixedHeader.isFixed = false;
        m_fixedHeader.isScrolled = false;
        m_fixedHeader.useUpScrollActive = false;
        m_fixedHeader.$element.removeClass('isfixed').addClass('notfixed');
        m_fixedHeader.$header.removeClass('header-isfixed').addClass('header-notfixed');
        m_fixedHeader.$parent.height("auto");
    }
}

function updateNavTogglePosition(resize) {
    if (m_isBurgerHeader) {
        var scrollTop = Mercury.windowScrollTop();
        var fixTogglePos = -1;
        if (scrollTop <= 0) {
            // page is on top, not scrolled - the full header is visible
            m_fixedHeader.$header.removeClass("fixtoggle");
            m_fixedHeader.toggleOpenTop = m_fixedHeader.$toggleOpen.offset().top;
            m_fixedHeader.toggleOpenFix = parseInt(Mercury.gridInfo().bhTogTop) + Mercury.toolbarHeight();
        } else if (
            !m_fixedHeader.useUpScrollActive && (m_fixedHeader.isScrolled || (!m_fixedHeader.isFixed && !m_fixedHeader.isScrolled))) {
            // if upscrolling header is active never show a fixed icon
            // otherwise page has been scrolled down but header is not fixed yet OR no fixed header at all
            var fixPos = m_fixedHeader.toggleOpenTop > m_fixedHeader.toggleOpenFix ? m_fixedHeader.toggleOpenTop - m_fixedHeader.toggleOpenFix : 0;
            if (scrollTop >= fixPos) {
                fixTogglePos = fixPos > 0 ? m_fixedHeader.toggleOpenFix : m_fixedHeader.toggleOpenTop;
            }
        }
        if (fixTogglePos >= 0) {
            m_fixedHeader.$header.addClass("fixtoggle");
            m_fixedHeader.$toggleOpen.css("top", fixTogglePos).css("left", m_fixedHeader.$toggleParent.offset().left);
        } else {
            m_fixedHeader.$header.removeClass("fixtoggle");
            m_fixedHeader.$toggleOpen.css("top", "").css("left", "");
        }
    }
}

function updateFixed(resize) {

    if (VERBOSE) console.info("Fixed header ----------" + (resize ? ' resize=true' : ''));
    // Update position of fixed header.
    // The fixed header height is likely to be different from the attached header height because of different CSS selectors.
    if (showFixedHeader()) {
        if (VERBOSE) console.info("Fixed header show: true");
        // assuming this event handler is only called if m_fixedHeader != null
        // only do this if desktop head nav is shown
        if (resize) {
            m_fixedHeader.bottom = m_fixedHeader.$parent.offset().top + m_fixedHeader.$parent.height();
        }
        var scrollUp = true;
        if (m_fixedHeader.useUpscroll) {
            // useUpscroll reflects the user selection, useUpScrollActive also takes the screen size into account
            // for smaller screens the fixed header may not be active regardless of the user selection
            m_fixedHeader.useUpScrollActive = true;
            scrollUp = resize || m_lastScrollTop >= Mercury.windowScrollTop();
            m_lastScrollTop = Mercury.windowScrollTop();
            if (! scrollUp) {
                m_checkScrollTop = m_lastScrollTop - 50;
            }
        }
        var fixHeader = scrollUp && (m_fixedHeader.bottom < (Mercury.windowScrollTop() + Mercury.toolbarHeight()));
        if (VERBOSE) console.info("Fixed header fixHeader=" + fixHeader + " m_fixedHeader.isFixed=" + m_fixedHeader.isFixed);
        if (fixHeader && !m_fixedHeader.isFixed) {
            // if mobile nav is active, don't fix the header, otherwise there would be an ugly css effect on the mobile nav
            if (!mobileNavActive()) {
                // header should be fixed, but is not
                if (VERBOSE) console.info("Fixed header fixing at m_lastScrollTop=" + m_lastScrollTop  +  " m_checkScrollTop=" + m_checkScrollTop + " m_fixedHeader.bottom=" + m_fixedHeader.bottom);
                if (m_lastScrollTop < m_checkScrollTop) {
                    m_fixedHeader.isFixed = true;
                    m_fixedHeader.isScrolled = false;
                    m_fixedHeader.$parent.height(m_fixedHeader.$element.height());
                    m_fixedHeader.$element.removeClass('notfixed').removeClass('scrolled').addClass('isfixed');
                    m_fixedHeader.$header.removeClass('header-notfixed').addClass('header-isfixed');
                    m_fixedHeader.height = m_fixedHeader.$element.height();
                    m_checkScrollTop = 999999999999;
                    m_fixedHeader.$element[0].dispatchEvent(new CustomEvent("header:isfixed", { bubbles: true, cancelable: true }));
                }
            }
        } else if (!fixHeader && m_fixedHeader.isFixed) {
            // header should not be fixed, but is
            resetFixedHeader();
            m_fixedHeader.$element[0].dispatchEvent(new CustomEvent("header:notfixed", { bubbles: true, cancelable: true }));
        }
        if (!m_fixedHeader.isFixed) {
            // add class to identify a header that has been scrolled but is not fixed yet
            if (Mercury.windowScrollTop() > 0) {
                m_fixedHeader.$element.addClass('scrolled');
                m_fixedHeader.isScrolled = true;
            } else {
                m_fixedHeader.$element.removeClass('scrolled');
                m_fixedHeader.isScrolled = false;
            }
        }
        if (resize) {
            // resize may lead to changes in the header height, make sure we don't use outdated values
            m_fixedHeader.height = m_fixedHeader.isFixed ? m_fixedHeader.$element.height() : -1;
            if (VERBOSE) console.info("Fixed header is " + (m_fixedHeader.isFixed ? "" : "NOT ") + "fixed, fixed height: " + m_fixedHeader.getHeight());
        }
    } else {
        // smaller screens: make sure the head height is set to "auto"
        if (VERBOSE) console.info("Fixed header show: FALSE");
        if (m_fixedHeader.isFixed) {
            resetFixedHeader();
        }
    }
    updateNavTogglePosition(resize);
}

function showFixedHeader() {

    if (m_isBurgerHeader) {
        // burger header
        return m_fixedHeader.$header.hasClass("fix-xs") ||
            (m_fixedHeader.$header.hasClass("fix-sm") && Mercury.gridInfo().isMinSm()) ||
            (m_fixedHeader.$header.hasClass("fix-md") && Mercury.gridInfo().isMinMd()) ||
            (m_fixedHeader.$header.hasClass("fix-lg") && Mercury.gridInfo().isMinLg());
    } else {
        // other headers
        return Mercury.gridInfo().isDesktopNav() || (Mercury.gridInfo().forceMobileNav() && Mercury.gridInfo().getNavFixHeader() != "false");
    }
}

function fixedHeaderActive() {

    return (m_fixedHeader != null) && showFixedHeader();
}

// add click handler and adjust position on initial page load
function initSmoothScrolling() {

    // attach click handler to anchor links on the page
    jQ('a[href*="#"]:not([href="#"]):not([data-bs-toggle]):not([data-slide])').click(function() {
        if (location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//, '') && location.hostname == this.hostname) {
            var $target = jQ(this.hash);
            if ($target.length) {
                jQ(this).blur();
                scrollToAnchor($target);
                focusOnElement($target);
                window.history.pushState(null, null, this.hash);
                return false;
            }
        }
    });

    // for initial page load, make sure we adjust scroll position for fixed header and OpenCms toolbar
    if (location.hash.length) {
        if (DEBUG) console.info("Navigation.initSmoothScrolling() Initial anchor (location.hash): " + location.hash);
        scrollToAnchor(jQ(location.hash));
        focusOnElement(jQ(location.hash));
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

// auto-scroll to an opened accordion tab
function initAccordionScroll() {
    jQ('article.accordion').on('shown.bs.collapse', function() {
        var $tab = $(this).closest('article.accordion').find('.acco-header');
        if (! $tab.visible()) {
            doScrollToAnchor($tab, -5);
        }
    })
    jQ('.collapse-target').on('shown.bs.collapse', function() {
        var $tar = $(this);
        setTimeout(function () {
            // must wait for animation to finish before calculating the anchor position
            var $tab = $tar.find('.collapse-container');
            if (! $tab.visible()) {
                var $tac = $tar.prev('.collapse-trigger').find('.text-overlay').first();
                doScrollToAnchor($tac, -5);
            }
        }, 330);
    })
}

// auto-scroll to and open a regular tab
function openTabFromHash($tab) {
    var parentId = "#b_" + $tab.attr('id');
    var $parent = jQ(parentId);
    $parent.tab('show');
    doScrollToAnchor($parent, -5);
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

function addEnterIsClick($element) {
    if (DEBUG) console.info("Navigation.addEnterIsClick()", $element);
    $element.keyup(function(event) {
        if (event.keyCode === 13) {
            $element.trigger('click');
            return false;
        }
    });
}

// fix 'skip links'
// see https://axesslab.com/skip-links/
// see https://github.com/selfthinker/dokuwiki_template_writr/blob/master/js/skip-link-focus-fix.js
// even though the problem is apparently fixed in regular browser use, it is stell needed because of our initSmoothScrolling() function
function focusOnElement($element) {
    if (DEBUG) console.info("Navigation.focusOnElement()", $element);
    if (!$element.length) {
        return;
    }
    if (!($element.is(':input:enabled, a[href], area[href], object, [tabindex]') && !$element.is(':hidden'))) {
        // add tabindex to make focusable and remove again
        $element.attr('tabindex', -1).on('blur focusout', function () {
            $(this).removeAttr('tabindex');
        });
    }
    $element.focus();
}

function doScrollToAnchor($anchor, offset) {
    if (DEBUG) console.info("Navigation.debScrollToAnchor() called!");
    if ($anchor.length) {
        if ($anchor.collapse && (! $anchor.hasClass('show'))) {
            // this anchor is a bootstrap collapse, show it
            if ($anchor.hasClass('tab-pane')) {
                // this anchor is a bootstrap tab, show it
                if (DEBUG) console.info("Navigation.debScrollToAnchor(#" + $anchor.attr('id') + ") is a tab!");
                openTabFromHash($anchor);
                return;
            } else if ($anchor.hasClass('acco-body') || $anchor.hasClass('collapse-target')) {
                if (DEBUG) console.info("Navigation.debScrollToAnchor(#" + $anchor.attr('id') + ") is a collapse!");
                $anchor.collapse("show");
                return;
            }
        }
        offset = offset || 0;
        var targetTop = $anchor.offset().top + offset;
        targetTop = targetTop < 0 ? 0 : targetTop;
        if (DEBUG) console.info("Navigation.debScrollToAnchor(#" + $anchor.attr('id') + ") position:" + targetTop, $anchor);
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
        page.on("scroll mousedown wheel DOMMouseScroll mousewheel keyup touchmove", function () {
            page.stop();
        });
        page.animate({ scrollTop: Math.ceil(targetTop - Mercury.toolbarHeight()) }, 750, function () {
            page.off("scroll mousedown wheel DOMMouseScroll mousewheel keyup touchmove");
        });
        if (Mercury.gridInfo().isMobileNav()) {
            // close the mobile navigation
            jQ('.nav-toggle-btn').removeClass('active-nav');
            jQ(document.documentElement).removeClass('active-nav');
        }
    }
}

// functions that require the Mercury object
var debUpdateFixedResize;
var debUpdateFixedScroll;
var debInitMenu;
var debScrollToAnchor;

function initDependencies() {

    // add id to first 'main' element'
    jQ('#mercury-page main').first().attr('id', 'main-content');

    debUpdateFixedResize = Mercury.debounce(function() {
        updateFixed(true)
    }, 10, true);

    debUpdateFixedScroll = Mercury.debounce(function() {
        updateFixed(false)
    }, 10);

    debInitMenu = Mercury.debounce(function() {
        initMenu();
    }, 100);

    debScrollToAnchor = Mercury.debounce(doScrollToAnchor, 500, true);
}

/****** Exported functions ******/

// Smooth scrolling to anchor links
export function scrollToAnchor($anchor, offset) {
    if ($anchor.length) {
        debScrollToAnchor($anchor, offset);
    }
}

export function init(jQuery, debug, verbose) {

    jQ = jQuery;
    DEBUG = debug;
    VERBOSE = verbose;

    if (DEBUG) console.info("Navigation.init()");

    if (m_firstInit) {
        initDependencies();
        initMegaMenu();
        initHeadNavigation();
    }
    m_firstInit = false;

    initSmoothScrolling();
    initAccordionScroll();
    initClickmeShowme();
    initExternalLinks();
}
