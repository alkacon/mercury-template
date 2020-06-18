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

// Module implemented using the "revealing module pattern", see
// https://addyosmani.com/resources/essentialjsdesignpatterns/book/#revealingmodulepatternjavascript
// https://www.christianheilmann.com/2007/08/22/again-with-the-module-pattern-reveal-something-to-the-world/

// this need to be visible in global JS context for DISQUS
window.disqus_config = function() {
    this.page.url = window.disqus_pageUrl;
    this.page.identifier = window.disqus_pageId;
};

// the global objects that must be passed to this module
var jQ;
var DEBUG;

"use strict";

var disqus_loaded = false;
var disqus_open = false;
var disqus_site = null;

// check if the API has already been loaded
var m_disqusApiLoaded = false;

function loadComments() {
    if (PrivacyPolicy.cookiesAcceptedExternal()) {
        if (! m_disqusApiLoaded) {
            var d = document, s = d.createElement('script');
            s.src = '//' + disqus_site + '.disqus.com/embed.js';
            s.setAttribute('data-timestamp', + new Date());
            (d.head || d.body).appendChild(s);
            m_disqusApiLoaded = true;
        } else {
            DISQUS.reset({ reload: true, config: window.disqus_config });
        }
    }
}

function toggleComments() {

    if (disqus_open) {
        $("#disqus_toggle").toggleClass("open");
        $("#disqus_thread").slideUp();
    } else {
        $("#disqus_toggle").toggleClass("open");
        if (!disqus_loaded) {
            $("#disqus_thread").show();
            disqus_loaded = true;
            loadComments();
        } else {
            $("#disqus_thread").slideDown();
        }
    }
    disqus_open = !disqus_open;
}

/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("Disqus.init()");

    var $disqusElements = jQ('#disqus_thread');
    if (DEBUG) console.info("#disqus_thread elements found: " + $disqusElements.length);

    if (PrivacyPolicy.cookiesAcceptedExternal()) {

        $disqusElements.each(function() {
            var $disqusElement = jQ(this);
            if (typeof $disqusElement.data("disqus") != 'undefined') {
                var dicqusData = $disqusElement.data("disqus");

                disqus_site = decodeURIComponent(dicqusData.site);
                if (disqus_site.endsWith(".disqus.com")) {
                    disqus_site = disqus_site + "#";
                    disqus_site = disqus_site.replace(".disqus.com#", "");
                }
                window.disqus_pageUrl = decodeURIComponent(dicqusData.url);
                window.disqus_pageId = dicqusData.id;
                var clickToLoad = (dicqusData.load == "true");

                if (DEBUG) console.info("Disqus: clickToLoad='" + clickToLoad + "' url=" + window.disqus_pageUrl + " site=" + disqus_site);

                if (! clickToLoad) {
                    loadComments();
                } else {
                    jQ('.btn-disqus').on('click', function(event) {
                        toggleComments()
                    });
                }
            }
        });

    } else {

        if (DEBUG) console.info("External cookies not accepted be the user - DISQUS is disabled!");
        jQ('.btn-disqus').on('click', function(event) {
            toggleComments()
        });
    }
}
