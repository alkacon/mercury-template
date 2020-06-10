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
var COOKIES_ACCEPTED = "privacy-cookies-accepted";

var COOKIES_DECLINED_CLASS = "cookies-declined"; // css class added to elements for cookies have been declined
var OPTIONS_CONFIRMED_DAYS = 1; // number of days the confirmation will be valid

var COOKIES_DECLINED_MESSAGE = "This element is disabled because cookies have not been accepted!";

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

    if (typeof m_policy.DisabledMessage !== 'undefined') {
        COOKIES_DECLINED_MESSAGE=m_policy.DisabledMessage;
        setDisabledText(m_policy.DisabledMessage);
    }

    var $banner = jQ(m_bannerHtml).find(".banner");
    if ($banner.length > 0) {

        var $bannerElement = m_bannerData.$bannerElement;
        var onTop = m_bannerData.onTop;

        // add click handlers to buttons on banner
        var $btnAccept = $banner.find(".btn-accept");
        var cookieDays = $btnAccept.data("days");
        if (DEBUG) console.info("PrivacyPolicy: Cookie expiration days on banner=" + cookieDays);
        $btnAccept.on('click', function(e) {
            setPrivacyCookies(true, cookieDays);
            $banner.slideUp();
            $bannerElement.slideUp();
            resetTemplateScript();
        });
        $banner.find(".btn-decline").on('click', function(e) {
            setPrivacyCookies(false);
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

    var $disabledElements = jQ(".cookie-notice, ." + COOKIES_DECLINED_CLASS);
    if ($disabledElements.length > 0) {
        jQ(".presized.large-cookie-notice").each(function() {
            // fix presized elements height
            var $presized = jQ(this);
            $presized.removeClass("large-cookie-notice");
        });
        // some elements on this page are disabled, re-init Mercury to enable them
        Mercury.init();
        $disabledElements.removeClass(COOKIES_DECLINED_CLASS);
        $disabledElements.removeClass("cookie-notice");
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

            if (! optionsConfirmed()) {
                if (DEBUG) console.info("PrivacyPolicy: Banner NOT confirmed, cookies accepted=" + cookiesAccepted());
                loadPolicy(m_bannerData, displayBanner);
            } else if (hasExternalElements()) {
                loadPolicy(m_bannerData);
            } else {
                if (DEBUG) console.info("PrivacyPolicy: Banner confirmed, cookies accepted=" + cookiesAccepted());
            }
        }
    }
}

function initPrivacyToggle() {

    var $privacyToggle = jQ("#privacy-policy-toggle");
    if (DEBUG) console.info("PrivacyPolicy: Privacy policy toggle buttons found=" + $privacyToggle.length);

    if ($privacyToggle.length > 0) {
        $privacyToggle.prop('checked', cookiesAccepted());

        $privacyToggle.change(function() {
            var cookieDays = $privacyToggle.data("days");
            if (DEBUG) console.info("PrivacyPolicy: Cookie expiration days on toggle=" + cookieDays);
            setPrivacyCookies(this.checked, cookieDays);
            resetTemplateScript();
        });
    }
}

function setPrivacyCookies(accepted, days) {
    var cookieDays = OPTIONS_CONFIRMED_DAYS;
    if (accepted && (typeof days !== 'undefined')) {
        cookieDays = days;
    }
    setCookie(OPTIONS_CONFIRMED, (new Date()).toLocaleDateString("en-US"), { expires: cookieDays });
    if (accepted) {
        setCookie(COOKIES_ACCEPTED, (new Date()).toLocaleDateString("en-US"), { expires: cookieDays });
    } else {
        removeCookie(COOKIES_ACCEPTED);
    }
}

function optionsConfirmed() {
    return hasCookie(OPTIONS_CONFIRMED);
}

function cookiesAcceptedByDefault() {
    // default behavior if no banner configuration has been found
    return !m_bannerConfigured && DEFAULT_IF_NOT_CONFIGURED;
}

function setDisabledText(disabledMessage) {
    var $disabledElements = jQ("." + COOKIES_DECLINED_CLASS);
    $disabledElements.attr("data-message", disabledMessage);
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

export function cookiesAccepted() {
    return cookiesAcceptedByDefault() || Mercury.isEditMode() || (optionsConfirmed() && hasCookie(COOKIES_ACCEPTED));
}

export function markDisabled($element) {
    // $element.attr("data-message", COOKIES_DECLINED_MESSAGE);
    // $element.addClass(COOKIES_DECLINED_CLASS);
    addCookieToggle($element);
}

export function addCookieToggle($element) {

    if (DEBUG) console.info("PrivacyPolicy.addCookieToggle()");

    var cookieData = $element.data("cookies");
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

        $element.addClass("cookie-notice");
        $element.empty().html(cookieHtml);

        var $presizedParent = $element.parent(".presized");
        if ($presizedParent.length > 0) {
            var parentHeight = $presizedParent.innerHeight();
            var toggleHeight = $element.find(".cookie-content").innerHeight();
            if (DEBUG) console.info("PrivacyPolicy: parent(.presized).height=" + parentHeight + " .cookie-content.height=" + toggleHeight);
            if (parentHeight < toggleHeight) {
                $element.parent(".presized").addClass("large-cookie-notice");
            }
        }

        var $cookieToggle = jQ(".toggle-check", $element);
        $cookieToggle.prop('checked', false);
        $cookieToggle.change(function() {
            setPrivacyCookies(true);
            window.setTimeout(function() {
                $element.empty();
                resetTemplateScript();
            }, 600);
        });

    }
}

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("PrivacyPolicy.init()");

    initPrivacyBanner();
    initPrivacyToggle();
}
