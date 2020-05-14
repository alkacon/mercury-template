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

function addGoogleAnalytics(analyticsId) {

    if (DEBUG) console.info("addGoogleAnalytics() initializing Google analytics using id: " + analyticsId);

    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
    ga('create', analyticsId, 'auto');
    ga('set', 'anonymizeIp', true);
    ga('send', 'pageview');
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
    if (DEBUG) console.info("addPiwikAnalytics() initializing Piwik using url: " + piwikData.url + " and id: " + piwikData.id);

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
}

/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("Analytics.init()");

    if (PrivacyPolicy.cookiesAccepted()) {

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
                console.info("Google analytic ID is: " + googleAnalyticsId);
                if (! Mercury.isOnlineProject()) console.info("Google analytics NOT initialized because not in the ONLINE project!");
            } else {
                console.info("Google analytic ID (property 'google.analytics') not set in OpenCms VFS!");
            }
        }
        if (Mercury.isOnlineProject() && (googleAnalyticsId != null)) {
            // only enable google analytics in the online project when ID is set
            addGoogleAnalytics(googleAnalyticsId);
        }

        // initialize Piwik
        jQ('#template-info').each(function(){

            var $element = jQ(this);
            var piwikData = null;
            if (typeof $element.data("piwik") != 'undefined') {
                piwikData = $element.data("piwik");
            }
            if (piwikData != null) {
                if (DEBUG) console.info("Piwik data found:");
                if (DEBUG) jQ.each(piwikData, function( key, value ) { console.info( "- " + key + ": " + value ); });
                if (typeof piwikData.id != 'undefined') {
                    if (Mercury.isOnlineProject()) {
                        // only enable Piwik in the online project when ID and URL is set
                        addPiwik(piwikData);
                    } else {
                        if (DEBUG) console.info("Piwik NOT initialized because not in the ONLINE project!");
                    }
                } else {
                    if (DEBUG) console.info("Piwik ID (property 'piwik.id') not set in OpenCms VFS!");
                }
            } else {
                if (DEBUG) console.info("Piwik URL (property 'piwik.url') not set in OpenCms VFS!");
            }
        });

    } else {
        if (DEBUG) console.info("Cookies not accepted be the user - Analytics are disabled!");
    }
}