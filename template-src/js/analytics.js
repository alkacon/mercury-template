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

// Required by Piwik, needs to be in the global JavaScript context, not in the module context
// Will always be inserted even if no Piwik is used, but this should not hurt
window._paq = window._paq || [];

"use strict";

// the global objects that must be passed to this module
var jQ;
var DEBUG;

var m_googleInitialized = false;
var m_piwikInitialized = false;
var m_matomoInitialized = false;

function addGoogleAnalytics(analyticsId) {

    if (DEBUG) console.info("Analytics.addGoogleAnalytics() initializing Google analytics using id: " + analyticsId);

    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
    ga('create', analyticsId, 'auto');
    ga('set', 'anonymizeIp', true);
    ga('send', 'pageview');
    m_googleInitialized = true;
}

function addPiwik(piwikData) {

    if (piwikData.url.indexOf("http://") == 0) {
        piwikData.url = piwikData.url.substring(7, piwikData.url.length);
    } else if (piwikData.url.indexOf("https://") == 0) {
        piwikData.url = piwikData.url.substring(8, piwikData.url.length);
    }
    if (piwikData.url.endsWith("/")) {
        piwikData.url = piwikData.url.substring(0, piwikData.url.length - 1);
    }
    if (DEBUG) console.info("Analytics.addPiwik() initializing Piwik using url: " + piwikData.url + " and id: " + piwikData.id);

    // see: https://developer.piwik.org/guides/tracking-javascript-guide
    if (piwikData.setDocumentTitle == "true"){
        _paq.push(["setDocumentTitle", document.domain + "/" + document.title]);
    }
    if (typeof piwikData.setCookieDomain != 'undefined'){
        _paq.push(["setCookieDomain", piwikData.setCookieDomain]);
    }
    if (typeof piwikData.setDomains != 'undefined'){
        _paq.push(["setDomains", piwikData.setDomains]);
    }
    _paq.push(['trackPageView']);
    _paq.push(['enableLinkTracking']);
    (function() {
        var u="//" + piwikData.url + "/";
        _paq.push(['setTrackerUrl', u+'piwik.php']);
        _paq.push(['setSiteId', '' + piwikData.id]);
        var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
        g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
    })();
    m_piwikInitialized = true;
}

function addMatomo(matomoData, userAllowedStatisticalCookies) {

    if (matomoData.url.indexOf("http://") == 0) {
        matomoData.url = matomoData.url.substring(7, matomoData.url.length);
    } else if (matomoData.url.indexOf("https://") == 0) {
        matomoData.url = matomoData.url.substring(8, matomoData.url.length);
    }
    if (matomoData.url.endsWith("/")) {
        matomoData.url = matomoData.url.substring(0, matomoData.url.length - 1);
    }
    if (DEBUG) console.info("Analytics.addMatomo() Initializing Matomo using url: " + matomoData.url + " and id: " + matomoData.id + " - Cookie Consent: " + userAllowedStatisticalCookies + " - JS Tracking: " + matomoData.jst+ " - DNT: " + matomoData.dnt);

    // see: https://developer.matomo.org/guides/tracking-javascript-guide
    if (matomoData.setDocumentTitle == "true"){
        _paq.push(["setDocumentTitle", document.domain + "/" + document.title]);
    }
    if (typeof matomoData.setCookieDomain != 'undefined'){
        _paq.push(["setCookieDomain", matomoData.setCookieDomain]);
    }
    if (typeof matomoData.setDomains != 'undefined'){
        _paq.push(["setDomains", matomoData.setDomains]);
    }
    // see: https://developer.matomo.org/guides/tracking-consent
    _paq.push(['requireCookieConsent']);
    if (userAllowedStatisticalCookies) {
        _paq.push(['setCookieConsentGiven']);
    } else {
        // this is may not be required, but make sure Matomo knows we want this
        _paq.push(['forgetCookieConsentGiven']);
    }
    _paq.push(['trackPageView']);
    _paq.push(['enableLinkTracking']);
    (function() {
        var u="//" + matomoData.url + "/";
        _paq.push(['setTrackerUrl', u+'matomo.php']);
        _paq.push(['setSiteId', '' + matomoData.id]);
        var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
        g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
    })();
    m_matomoInitialized = true;
    $(".matomo-goal").each(function(index, element) {
        var goal = location.pathname;
        if (DEBUG) console.info('Initializing Matomo goal: ' + goal);
        _paq.push(['setDocumentTitle', document.title + ' [' + goal + ']']);
        _paq.push(['trackPageView']);
    })
}

/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("Analytics.init()");

    var userAllowedStatisticalCookies = PrivacyPolicy.cookiesAcceptedStatistical();

    if (userAllowedStatisticalCookies) {

        if (! m_googleInitialized) {
            // initialize Google Analytics (only if it has not been initialized already for this page)
            var googleAnalyticsId = null;
            if (Mercury.hasInfo("googleAnalyticsId")) {
                googleAnalyticsId = Mercury.getInfo("googleAnalyticsId");
                if (! googleAnalyticsId.toUpperCase().indexOf("UA-") == 0) {
                    googleAnalyticsId = "UA-" + googleAnalyticsId;
                }
            }
            if (DEBUG) {
                if (googleAnalyticsId != null) {
                    // Goggle analytics ID is read in pageinfo tag and stored in JavaScript via main script init()
                    console.info("Analytics.init() Google analytic ID is: " + googleAnalyticsId);
                    if (! Mercury.isOnlineProject()) console.info("Analytics.init() Google analytics NOT initialized because not in the ONLINE project!");
                } else {
                    console.info("Analytics.init() Google analytic ID (property 'google.analytics') not set!");
                }
            }
            if (Mercury.isOnlineProject() && (googleAnalyticsId != null)) {
                // only enable google analytics in the online project when ID is set
                addGoogleAnalytics(googleAnalyticsId);
            }
        }

        if (! m_piwikInitialized) {
            // initialize Piwik / Matomo Analytics (only if it has not been initialized already for this page)
            jQ('#template-info').each(function(){

                var $element = jQ(this);
                var piwikData = null;
                if (typeof $element.data("piwik") != 'undefined') {
                    piwikData = $element.data("piwik");
                }
                if (piwikData != null) {
                    if (DEBUG) console.info("Analytics.init() Piwik data found:");
                    if (DEBUG) jQ.each(piwikData, function( key, value ) { console.info( "- " + key + ": " + value ); });
                    if (typeof piwikData.id != 'undefined') {
                        if (Mercury.isOnlineProject()) {
                            // only enable Piwik in the online project when ID and URL is set
                            addPiwik(piwikData);
                        } else {
                            if (DEBUG) console.info("Analytics.init() Piwik NOT initialized because not in the ONLINE project!");
                        }
                    } else {
                        if (DEBUG) console.info("Analytics.init() Piwik ID (property 'piwik.id') not set!");
                    }
                } else {
                    if (DEBUG) console.info("Analytics.init() Piwik URL (property 'piwik.url') not set!");
                }
            });
        }

    } else {
        if (DEBUG) console.info("Analytics.init() Statistical cookies not accepted - Google / Piwik analytics disabled!");
    }

    if (! m_matomoInitialized) {
        // initialize Matomo Analytics (only if it has not been initialized already for this page)
        jQ('#template-info').each(function(){

            var $element = jQ(this);
            var matomoData = null;
            if (typeof $element.data("matomo") !== 'undefined') {
                matomoData = $element.data("matomo");
            }
            if (matomoData != null) {
                if (DEBUG) console.info("Analytics.init() Matomo data found:");
                if (DEBUG) jQ.each(matomoData, function( key, value ) { console.info( "- " + key + ": " + value ); });
                if (userAllowedStatisticalCookies || matomoData.jst) {
                    if ((typeof matomoData.id !== 'undefined') && (typeof matomoData.url !== 'undefined')) {
                        if (Mercury.isOnlineProject()) {
                            // only enable Matomo in the online project when ID and URL is set
                                addMatomo(matomoData, userAllowedStatisticalCookies);
                        } else {
                            if (DEBUG) console.info("Analytics.init() Matomo NOT initialized because not in the ONLINE project!");
                        }
                    } else {
                        if (DEBUG && (typeof matomoData.id === 'undefined')) console.info("Analytics.init() Matomo ID (property 'matomo.id') not set!");
                        if (DEBUG && (typeof matomoData.url === 'undefined')) console.info("Analytics.init() Matomo URL (property 'matomo.url') not set!");
                    }
                } else {
                    if (DEBUG) console.info("Analytics.init() Statistical cookies not accepted AND tracking by JavaScript not enabled - Matomo analytics disabled!");
                }
            } else {
                if (DEBUG) console.info("Analytics.init() Matomo properties 'matomo.url' and 'matomo.id' not set!");
            }
        });
    }
}