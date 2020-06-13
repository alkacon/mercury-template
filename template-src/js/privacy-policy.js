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

var m_bannerConfigured = false;
var m_policy = {};
var m_bannerHtml = "";
var m_bannerData;



function loadPolicy(policyData, callback) {

    var ajaxUrl = "/system/modules/alkacon.mercury.template/elements/privacy-policy.jsp";

    var params =
        "policy=" + encodeURIComponent(policyData.policy) + "&" +
        "page=" + encodeURIComponent(policyData.page) + "&" +
        "__locale=" + Mercury.getLocale();

    var ajaxLink = ajaxUrl + '?' + params;

    if (DEBUG) console.info("PrivacyPolicy: Loading policy data from " + ajaxLink);

    jQ.get(ajaxLink, function(ajaxResult) {

        m_policy = ajaxResult.content[0];
        m_bannerHtml = ajaxResult.html;

        if (callback || false) {
            callback();
        }

    }, "json");
}

function displayBanner() {

    var $banner = jQ(m_bannerHtml).find(".banner");
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

function resetTemplateScript(forceInit) {

    var $externalElements = jQ(".external-cookie-notice");
    if ($externalElements.length > 0) {
        $externalElements.find(".presized.enlarged").each(function() {
            // fix presized elements height
            var $presized = jQ(this);
            $presized.removeClass("enlarged");
        });
        // some elements on this page are disabled, re-init Mercury to enable them
        Mercury.init();
        $externalElements.removeClass("external-cookie-notice");
    } else if (forceInit) {
        location.reload();
    }
    var $privacyToggle = jQ(".type-privacy-policy .pp-toggle .toggle-check.optional");
    $privacyToggle.each(function() {
        var $toggleCheckbox = jQ(this);
        $toggleCheckbox.prop('disabled', false);
    });
}

function initPrivacyBanner(onTop) {
    onTop = onTop || false;

    var $privacyBanner = jQ("#privacy-policy-banner");
    m_bannerConfigured = ($privacyBanner.length > 0);

    if (DEBUG) console.info("PrivacyPolicy: Banner div found=" + m_bannerConfigured);
    if (m_bannerConfigured) {

        m_bannerData = $privacyBanner.data("banner");
        if (typeof m_bannerData !== 'undefined') {
            m_bannerData.$bannerElement = $privacyBanner;
            m_bannerData.onTop = onTop;

            if (! cookiesAcceptedTechnical()) {
                if (DEBUG) console.info("PrivacyPolicy: Banner NOT confirmed - Displaying banner");
                loadPolicy(m_bannerData, displayBanner);
            } else if (hasExternalElements() && ! cookiesAcceptedExternal()) {
                if (DEBUG) console.info("PrivacyPolicy: Banner confirmed, external cookies required but not confirmed - Loading policy, cookies accepted=" + getCookie(OPTIONS_CONFIRMED));
                loadPolicy(m_bannerData);
            } else {
                if (DEBUG) console.info("PrivacyPolicy: Banner confirmed, cookies accepted=" + getCookie(OPTIONS_CONFIRMED));
            }
        }
    }
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
            $toggleCheckbox.change(function() {
                if (DEBUG) console.info("PrivacyPolicy: External cookie toggle changed to value=" + $toggleCheckbox.prop('checked'));
                if (jQ(this).prop('checked')) {
                    enableExternalElements();
                } else {
                    disableExternalElements();
                }
            });
        }
        if (isStatisticalToogle) {
            $toggleCheckbox.prop('checked', cookiesAcceptedStatistical());
            $toggleCheckbox.change(function() {
                if (DEBUG) console.info("PrivacyPolicy: Statistical cookie toggle changed to value=" + $toggleCheckbox.prop('checked'));
                setPrivacyCookiesStatistical(true);
                resetTemplateScript();
            });
        }
        if (!cookiesAcceptedTechnical()) {
            $toggleCheckbox.prop('disabled', true);
        }
    });
}

function setPrivacyCookies(allowTechnical, allowExternal, allowStatistical) {
    var cookieDays = OPTIONS_CONFIRMED_DAYS;
    if (typeof m_policy.CookieExpirationDays !== 'undefined') {
        cookieDays = m_policy.CookieExpirationDays;
    }
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
    return !m_bannerConfigured && DEFAULT_IF_NOT_CONFIGURED;
}

function hasExternalElements() {
    return jQ("[data-external-cookies]").length > 0;
}

function disableExternalElements() {
    if (DEBUG) console.info("PrivacyPolicy: Disabling external elements");
    if (typeof m_policy.CookieExpirationDays === 'undefined') {
        loadPolicy(m_bannerData, disableExternalElements);
    } else {
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
    return checkCookie(COOKIES_TECHNICAL)
}

export function cookiesAcceptedStatistical() {
    return checkCookie(COOKIES_STATISTICAL)
}

export function cookiesAcceptedExternal() {
    return checkCookie(COOKIES_EXTERNAL)
}

export function showExternalCookieNotice($element) {

    if (DEBUG) console.info("PrivacyPolicy.showExternalCookieNotice()");

    var cookieData = $element.data("external-cookies");
    if (typeof cookieData !== 'undefined') {
        // read cookie data
        var group = cookieData.group;
        var heading = cookieData.heading;
        var message = cookieData.message;
        var footer = cookieData.footer;
        var toggleId = "toggle-" + Math.floor(Math.random() * 1000000);

        var cookieHtml =
            '<div class=\"cookie-content\">' +
                '<div class=\"cookie-header\">' + heading + '</div>' +
                '<div class=\"cookie-message\">' + message + '</div>' +
                '<div class=\"cookie-switch pp-toggle pp-toggle-external animated\">' +
                    '<input id=\"' + toggleId + '\" type=\"checkbox\" class=\"toggle-check\">' +
                    '<label for=\"' + toggleId + '\" class=\"toggle-label\">' +
                        '<span class=\"toggle-box\">' +
                            '<span class=\"toggle-inner\" data-checked=\"' + m_policy.AcceptButtonText + '\" data-unchecked=\"' + m_policy.DeclineButtonText + '\"></span>' +
                            '<span class=\"toggle-slider\"></span>' +
                        '</span>' +
                    '</label>' +
                    '<div class=\"toggle-text\">Externer Inhalt</div>' +
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
                $element.parent(".presized").addClass("enlarge");
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

    initPrivacyBanner();
    initPrivacyToggle();
}
