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

var DISQUS_DATA = {};

function loadComments() {
    if (PrivacyPolicy.cookiesAcceptedExternal()) {
        if (! DISQUS_DATA.loaded) {
            DISQUS_DATA.loaded = true;
            var d = document, s = d.createElement('script');
            s.src = '//' + DISQUS_DATA.site + '.disqus.com/embed.js';
            s.setAttribute('data-timestamp', + new Date());
            (d.head || d.body).appendChild(s);
        } else {
            DISQUS.reset({ reload: true, config: window.disqus_config });
        }
    }
}

function toggleComments() {

    if (DISQUS_DATA.open) {
        $("#comments_toggle").toggleClass("open");
        $("#disqus_thread").slideUp();
    } else {
        $("#comments_toggle").toggleClass("open");
        if (!DISQUS_DATA.loaded) {
            $("#disqus_thread").show();
            loadComments();
        } else {
            $("#disqus_thread").slideDown();
        }
    }
    DISQUS_DATA.open = !DISQUS_DATA.open;
}

/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("Comments.init()");

    var $commentElements = jQ('.type-comments [data-comments]');
    if (DEBUG) console.info("Comments.init() .type-comments [data-comments] elements found: " + $commentElements.length);

    if (PrivacyPolicy.cookiesAcceptedExternal()) {

        $commentElements.each(function() {
            var $commentElement = jQ(this);
            if (typeof $commentElement.data("comments") != 'undefined') {

                var commentData = $commentElement.data("comments");
                commentData.$element = $commentElement;
                commentData.loaded = false;
                commentData.open = false;
                commentData.site = decodeURIComponent(commentData.site);
                commentData.url = decodeURIComponent(commentData.url);

                var commentId = $commentElement.attr('id');
                if (commentId == "disqus_thread") {
                    if (DEBUG) console.info("Comments.init() found DISQUS data for page id: " + commentData.id);
                    if (commentData.site.endsWith(".disqus.com")) {
                        commentData.site = commentData.site + "#";
                        commentData.site = commentData.site.replace(".disqus.com#", "");
                    }
                    window.disqus_pageUrl = commentData.url;
                    window.disqus_pageId = commentData.id;
                    commentData.type = "DISQUS";
                    commentData.valid = true;
                    DISQUS_DATA = commentData;
                } else if (commentId == "hyvor-talk-view") {
                    if (DEBUG) console.info("Comments.init() found HYVOR TALK data for page id: " + commentData.id);
                }
                if (commentData.valid) {
                    var clickToLoad = commentData.load && !commentData.open;
                    if (DEBUG) console.info("Comments.init() " + commentData.type + " clickToLoad='" + clickToLoad + "' url=" + commentData.url + " site=" + commentData.site);
                    if (clickToLoad) {
                        jQ('.btn-comments').on('click', function(event) {
                            toggleComments();
                        });
                    } else {
                        loadComments();
                    }
                } else {
                    if (DEBUG) console.warn("Comments.init() UNKNOWN data for id: " + commentId);
                }
            }
        });

    } else {

        if (DEBUG) console.info("Comments.init() External cookies not accepted be the user - External comments are disabled!");
        jQ('.btn-comments').on('click', function(event) {
            toggleComments()
        });
    }
}
