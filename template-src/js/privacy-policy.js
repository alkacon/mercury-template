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

var jsCookiesAttributes = { path: '/' };

var OPTIONS_CONFIRMED = "privacy-options-confirmed";
var OPTIONS_CONFIRMED_DAYS = 1; // number of days the confirmation will be valid

var COOKIES_TECHNICAL = "|technical";
var COOKIES_STATISTICS = "|statistics";
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
        var $btnAccept = $banner.find(".btn-accept");
        if (DEBUG) console.info("PrivacyPolicy: Cookie expiration days=" + m_policy.CookieExpirationDays);
        $btnAccept.on('click', function(e) {
            setPrivacyCookies(true, true, true);
            $banner.slideUp();
            $bannerElement.slideUp();
            resetTemplateScript();
        });
        $banner.find(".btn-decline").on('click', function(e) {
            setPrivacyCookies(true, false, false);
            $banner.slideUp();
            $bannerElement.slideUp();
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
                if (DEBUG) console.info("PrivacyPolicy: Banner NOT confirmed, cookies accepted=" + cookiesAcceptedTechnical());
                loadPolicy(m_bannerData, displayBanner);
            } else if (hasExternalElements()) {
                loadPolicy(m_bannerData);
            } else {
                if (DEBUG) console.info("PrivacyPolicy: Banner confirmed, cookies accepted=" + cookiesAcceptedTechnical());
            }
        }
    }
}

function initPrivacyToggle() {

    var $privacyToggle = jQ("#privacy-policy-toggle");
    if (DEBUG) console.info("PrivacyPolicy: Privacy policy toggle buttons found=" + $privacyToggle.length);

    if ($privacyToggle.length > 0) {
        $privacyToggle.prop('checked', cookiesAcceptedExternal());

        $privacyToggle.change(function() {
            setPrivacyCookies(true, this.checked, this.checked);
            resetTemplateScript();
        });
    }
}

function setPrivacyCookies(allowTechnical, allowStatistics, allowExternal) {
    var cookieDays = OPTIONS_CONFIRMED_DAYS;
    if (typeof m_policy.CookieExpirationDays !== 'undefined') {
        cookieDays = m_policy.CookieExpirationDays;
    }
    var cookieString = (new Date()).toLocaleDateString("en-US");
    if (allowTechnical) cookieString = cookieString + COOKIES_TECHNICAL;
    if (allowStatistics) cookieString = cookieString + COOKIES_STATISTICS;
    if (allowExternal) cookieString = cookieString + COOKIES_EXTERNAL;
    if (DEBUG) console.info("PrivacyPolicy: cookieString=" + cookieString + " cookieDays=" + cookieDays);
    setCookie(OPTIONS_CONFIRMED, cookieString, { expires: Number(cookieDays) });
}

function cookiesAcceptedByDefault() {
    // default behavior if no banner configuration has been found
    return !m_bannerConfigured && DEFAULT_IF_NOT_CONFIGURED;
}

function hasExternalElements() {
    return jQ("[data-cookies]").length > 0;
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

export function cookiesAcceptedStatistics() {
    return checkCookie(COOKIES_STATISTICS)
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
                '<div class=\"cookie-switch pp-toggle animated\">' +
                    '<input type=\"checkbox\" id=\"' + toggleId + '\" class=\"toggle-check\">' +
                    '<label for=\"' + toggleId + '\" class=\"toggle-label\">' +
                        '<span class=\"toggle-box\">' +
                            '<span class=\"toggle-inner\" data-checked=\"' + m_policy.AcceptButtonText + '\" data-unchecked=\"' + m_policy.DeclineButtonText + '\"></span>' +
                            '<span class=\"toggle-slider\"></span>' +
                        '</span>' +
                    '</label>' +
                    '<div class=\"cookie-toggle-text\">Externer Inhalt</div>' +
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

        var $cookieToggle = jQ(".toggle-check", $element);
        $cookieToggle.prop('checked', false);
        $cookieToggle.change(function() {
            setPrivacyCookies(true, true, true);
            window.setTimeout(function() {
                $element.empty();
                resetTemplateScript();
            }, 600);
        });

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
