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

import jsCookies from 'js-cookie';

// the global objects that must be passed to this module
var jQ;
var DEBUG;

"use strict";

var DEFAULT_IF_NOT_CONFIGURED = true; // default if policy banner is not configured in the template

var OPTIONS_CONFIRMED = "privacy-options-confirmed";
var OPTIONS_CONFIRMED_DAYS = 1; // number of days the confirmation will be valid

var COOKIES_TECHNICAL = "|technical";
var COOKIES_STATISTICAL = "|statistical";
var COOKIES_EXTERNAL = "|external";

var m_bannerData = {};
m_bannerData.initialized = false;
m_bannerData.togglesInitialized = false;

var m_policy = {};
m_policy.loaded = false;


function initBannerData() {
    if (! m_bannerData.initialized) {
        var $privacyBanner = jQ("#privacy-policy-banner");
        var bannerDataFound = ($privacyBanner.length > 0);

        if (DEBUG) console.info("PrivacyPolicy: Initializing banner data=" + bannerDataFound);
        if (bannerDataFound) {

            m_bannerData = $privacyBanner.data("banner");
            m_bannerData.initialized = true;
            if (typeof m_bannerData !== 'undefined') {
                m_bannerData.$bannerElement = $privacyBanner;
            }
        }
    }
}

function loadPolicy(callback) {

    if (! m_policy.loaded) {
        var policyUrl = "/system/modules/alkacon.mercury.template/elements/privacy-policy.jsp";

        var params =
            "policy=" + encodeURIComponent(m_bannerData.policy) + "&" +
            "page=" + encodeURIComponent(m_bannerData.page) + "&" +
            "__locale=" + Mercury.getLocale();

        var policyLink = policyUrl + '?' + params;

        if (DEBUG) console.info("PrivacyPolicy: Loading policy data from " + policyLink);

        jQ.get(policyLink, function(ajaxResult) {

            m_policy = ajaxResult;
            m_policy.loaded = true;

            if (callback) {
                callback();
            }

        }, "json");
    }
}

function displayBanner() {

    var $banner = jQ(m_policy.banner).find(".banner");
    if ($banner.length > 0) {

        var $bannerElement = m_bannerData.$bannerElement;
        var onTop = m_bannerData.onTop;

        // add click handlers to buttons on banner
        $banner.find(".btn-accept").on('click', function(e) {
            $banner.find("#use-statistical").prop('checked', true);
            $banner.find("#use-external").prop('checked', true);
            setPrivacyCookies(true, true, true);
            window.setTimeout(function() {
                $banner.slideUp();
                $bannerElement.slideUp();
                resetTemplateScript();
            }, 500);
        });
        $banner.find(".btn-save").on('click', function(e) {
            var useStatistical = $banner.find("#use-statistical").prop('checked');
            var useExternal = $banner.find("#use-external").prop('checked');
            setPrivacyCookies(true, useExternal, useStatistical);
            $banner.slideUp();
            $bannerElement.slideUp();
            if (useExternal) {
                enableExternalElements();
            } else {
                disableExternalElements();
                activatePrivacyToggle();
                initPrivacyToggle();
            }
        });

        // append the banner HTML - still hidden by CSS
        $banner.appendTo($bannerElement);

        // now reveal the banner
        $banner.slideDown(800, function() {
            if (onTop && Mercury.isEditMode()) {
                $banner.css({top: Mercury.toolbarHeight()});
            }
            $bannerElement.height($banner.outerHeight());
        });
        $banner.addClass("fixed " + (onTop ? "top" : "bottom" ));
    } else {
        if (DEBUG) console.warn("PrivacyPolicy: No banner was loaded!");
    }
}

function initPrivacyBanner(onTop) {
    onTop = onTop || false;

    if (typeof m_bannerData !== 'undefined') {
        m_bannerData.onTop = onTop;

        if (! cookiesAcceptedTechnical()) {
            if (DEBUG) console.info("PrivacyPolicy: Banner NOT confirmed - Displaying banner");
            loadPolicy(displayBanner);
        } else if (hasExternalElements() && ! cookiesAcceptedExternal()) {
            if (DEBUG) console.info("PrivacyPolicy: Banner confirmed, external cookies required but not confirmed - Loading policy, cookie data=" + getCookie(OPTIONS_CONFIRMED));
            loadPolicy();
        } else {
            if (DEBUG) console.info("PrivacyPolicy: Banner confirmed, cookie data=" + getCookie(OPTIONS_CONFIRMED));
        }
    }
}

function resetTemplateScript(forceInit) {

    var $externalElements = jQ(".external-cookie-notice");
    if ($externalElements.length > 0) {
        // some elements on this page are disabled, re-init Mercury to enable them
        $externalElements.parent(".presized.enlarged").removeClass("enlarged");
        $externalElements.removeClass("external-cookie-notice");
        Mercury.init();
    } else if (forceInit) {
        location.reload();
    }
    activatePrivacyToggle();
}

function activatePrivacyToggle() {
    var $privacyToggle = jQ(".type-privacy-policy .pp-toggle .toggle-check.optional");
    $privacyToggle.each(function() {
        var $toggleCheckbox = jQ(this);
        $toggleCheckbox.prop('disabled', false);
    });
}

function initPrivacyToggle() {

    var $privacyToggle = jQ(".type-privacy-policy .pp-toggle");
    if (DEBUG) console.info("PrivacyPolicy: Privacy policy toggle buttons found=" + $privacyToggle.length);

    $privacyToggle.each(function() {
        var $toggle = jQ(this);
        var isExternalToogle = $toggle.hasClass("pp-toggle-external");
        var isStatisticalToogle = $toggle.hasClass("pp-toggle-statistical");
        var $toggleCheckbox = jQ(".toggle-check", $toggle);
        if (isExternalToogle) {
            $toggleCheckbox.prop('checked', cookiesAcceptedExternal());
            if (! m_bannerData.togglesInitialized) {
                // must attach change event listener only on initial load
                $toggleCheckbox.change(function() {
                    var checked = jQ(this).prop('checked');
                    if (DEBUG) console.info("PrivacyPolicy: External cookie toggle changed to value=" + checked);
                    if (checked) {
                        enableExternalElements();
                    } else {
                        disableExternalElements();
                    }
                });
            }
        }
        if (isStatisticalToogle) {
            $toggleCheckbox.prop('checked', cookiesAcceptedStatistical());
            if (! m_bannerData.togglesInitialized) {
                $toggleCheckbox.change(function() {
                    var checked = jQ(this).prop('checked');
                    if (DEBUG) console.info("PrivacyPolicy: Statistical cookie toggle changed to value=" + checked);
                    setPrivacyCookiesStatistical(checked);
                    resetTemplateScript();
                });
            }
        }
        if (!cookiesAcceptedTechnical()) {
            $toggleCheckbox.prop('disabled', true);
        }
    });

    m_bannerData.togglesInitialized = true;
}

function setPrivacyCookies(allowTechnical, allowExternal, allowStatistical) {
    var cookieDays = OPTIONS_CONFIRMED_DAYS;
    if (allowStatistical) {
        if (typeof m_policy.daysA !== 'undefined') {
            cookieDays = m_policy.daysA;
        }
    } else {
        if (typeof m_policy.daysS !== 'undefined') {
            cookieDays = m_policy.daysS;
        }
    }
    m_bannerData.cookiesTechnical = allowTechnical;
    m_bannerData.cookiesExternal = allowExternal;
    m_bannerData.cookiesStatistical = allowStatistical;
    var cookieString = (new Date()).toLocaleDateString("en-US");
    if (allowTechnical) cookieString = cookieString + COOKIES_TECHNICAL;
    if (allowStatistical) cookieString = cookieString + COOKIES_STATISTICAL;
    if (allowExternal) cookieString = cookieString + COOKIES_EXTERNAL;
    if (DEBUG) console.info("PrivacyPolicy: Setting cookie options=" + cookieString + " cookieDays=" + cookieDays);
    setCookie(OPTIONS_CONFIRMED, cookieString, { expires: Number(cookieDays) });
}

function setPrivacyCookiesExternal(allow) {
    setPrivacyCookies(true, allow, cookiesAcceptedStatistical());
}

function setPrivacyCookiesStatistical(allow) {
    setPrivacyCookies(true, cookiesAcceptedExternal(), allow);
}

function cookiesAcceptedByDefault() {
    // default behavior if no banner configuration has been found
    return !m_bannerData.initialized && DEFAULT_IF_NOT_CONFIGURED;
}

function hasExternalElements() {
    return jQ("[data-external-cookies]").length > 0;
}

function disableExternalElements() {
    if (! m_policy.loaded) {
        loadPolicy(disableExternalElements);
    } else {
        if (DEBUG) console.info("PrivacyPolicy: Disabling external elements");
        setPrivacyCookiesExternal(false);
        jQ("[data-external-cookies]").each(function() {
            var $element = jQ(this);
            showExternalCookieNotice($element);
        });
    }
}

function enableExternalElements() {
    if (DEBUG) console.info("PrivacyPolicy: Enabling external elements");
    setPrivacyCookiesExternal(true);
    var $elements = jQ("[data-external-cookies]");
    window.setTimeout(function() {
        $elements.empty();
        resetTemplateScript();
    }, 600);
}

/****** Exported functions ******/

//see https://github.com/js-cookie/js-cookie/wiki/Design-Patterns-To-Use-With-JavaScript-Cookie
export function getCookie(name) {
    return jsCookies.get(name);
}

export function hasCookie(name) {
    return (getCookie(name) !== undefined);
}

export function removeCookie(name, jsCookiesAttributes) {
    return jsCookies.remove(name, jsCookiesAttributes);
}

export function setCookie(name, value, jsCookiesAttributes) {
    return jsCookies.set(name, value, jsCookiesAttributes);
}

function checkCookie(cookieType) {
    if (cookiesAcceptedByDefault() || Mercury.isEditMode()) {
        return true;
    }
    var cookieValue = "" + getCookie(OPTIONS_CONFIRMED);
    var result = cookieValue.includes(cookieType);
    if (DEBUG) console.info("PrivacyPolicy: Checking " + cookieValue + " for " + cookieType + " result=" + result);
    return result;
}

export function cookiesAcceptedTechnical() {
    if (typeof m_bannerData.cookiesTechnical === 'undefined') {
        m_bannerData.cookiesTechnical = checkCookie(COOKIES_TECHNICAL);
    }
    return m_bannerData.cookiesTechnical;
}

export function cookiesAcceptedExternal() {
    if (typeof m_bannerData.cookiesExternal === 'undefined') {
        m_bannerData.cookiesExternal = checkCookie(COOKIES_EXTERNAL);
    }
    return m_bannerData.cookiesExternal;
}

export function cookiesAcceptedStatistical() {
    if (typeof m_bannerData.cookiesStatistical === 'undefined') {
        m_bannerData.cookiesStatistical = checkCookie(COOKIES_STATISTICAL);
    }
    return m_bannerData.cookiesStatistical;
}

export function showExternalCookieNotice($element) {

    if (DEBUG) console.info("PrivacyPolicy.showExternalCookieNotice()");

    var cookieData = $element.data("external-cookies");
    if (typeof cookieData !== 'undefined') {
        // read cookie data
        var heading = (typeof cookieData.heading !== 'undefined') ? cookieData.heading : m_policy.nHead;
        var message = (typeof cookieData.message !== 'undefined') ? cookieData.message : m_policy.nMsg;
        var footer = (typeof cookieData.footer !== 'undefined') ? cookieData.footer : m_policy.nFoot;
        var toggleId = "toggle-" + Math.floor(Math.random() * 1000000);

        var cookieHtml =
            '<div class=\"cookie-content\">' +
                '<div class=\"cookie-header\">' + heading + '</div>' +
                '<div class=\"cookie-message\">' + message + '</div>' +
                '<div class=\"cookie-switch pp-toggle pp-toggle-external animated\">' +
                    '<input id=\"' + toggleId + '\" type=\"checkbox\" class=\"toggle-check\">' +
                    '<label for=\"' + toggleId + '\" class=\"toggle-label\">' +
                        '<span class=\"toggle-box\">' +
                            '<span class=\"toggle-inner\" data-checked=\"' + m_policy.togOn + '\" data-unchecked=\"' + m_policy.togOff + '\"></span>' +
                            '<span class=\"toggle-slider\"></span>' +
                        '</span>' +
                    '</label>' +
                    '<div class=\"toggle-text\">' + m_policy.togLEx + '</div>' +
                '</div>' +
                '<div class=\"cookie-footer\">' + footer + '</div>' +
            '</div>';

        $element.addClass("external-cookie-notice");
        $element.empty().html(cookieHtml);

        var $presizedParent = $element.parent(".presized");
        if ($presizedParent.length > 0) {
            var parentHeight = $presizedParent.innerHeight();
            var toggleHeight = $element.find(".cookie-content").innerHeight();
            if (DEBUG) console.info("PrivacyPolicy: parent(.presized).height=" + parentHeight + " .cookie-content.height=" + toggleHeight);
            if (parentHeight < toggleHeight) {
                $element.parent(".presized").addClass("enlarged");
            }
        }

        var $toggleCheckbox = jQ(".toggle-check", $element);
        // only allow element activation in case technical cookies have already been accepted
        $toggleCheckbox.prop('checked', false);
        $toggleCheckbox.change(function() {
            enableExternalElements();
        });
        if (!cookiesAcceptedTechnical()) {
            $toggleCheckbox.prop('disabled', true);
        }

    } else {
        if (DEBUG) console.info("PrivacyPolicy.showExternalCookieNotice(): No Cookie data found on " + $element.getFullPath());
    }
}

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("PrivacyPolicy.init()");

    initBannerData();
    initPrivacyBanner();
    initPrivacyToggle();
}
