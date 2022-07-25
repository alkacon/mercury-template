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

"use strict";

var DISQUS_DATA = {};
var HYVORTALK_DATA = {};
var m_firstInit = true;

function toggleComments(commentData) {

    var open = commentData.$fa.hasClass("open");
    if (DEBUG) console.info("Comments.toggleComments() " + (open ? "Close " : "Open ") + commentData.type);
    if (open) {
        commentData.$view.slideUp();
    } else {
        if (!commentData.loaded) {
            commentData.loadComments();
        }
        commentData.$view.slideDown();
    }
    commentData.$fa.toggleClass("open");
}

/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("Comments.init()");

    var $commentElements = jQ('.type-comments');
    if (DEBUG) console.info("Comments.init() .type-comments [data-comments] elements found: " + $commentElements.length);

    $commentElements.each(function() {
        var $commentElement = jQ(this);
        var $view = $commentElement.find("[data-comments]");
        if (typeof $view.data("comments") != 'undefined') {

            var commentData = $view.data("comments");

            commentData.$element = $commentElement;
            commentData.$view = $view;
            commentData.$toggle = commentData.$element.find(".btn-toggle");
            commentData.$fa = commentData.$toggle.find(".fa");

            commentData.loaded = false;
            commentData.site = decodeURIComponent(commentData.site);
            commentData.url = decodeURIComponent(commentData.url);

            var commentId = commentData.$view.attr('id');
            if (commentId == "disqus_thread") {
                if (DEBUG) console.info("Comments.init() found DISQUS data for page id: " + commentData.id);
                commentData.valid = true;
                commentData.type = "DISQUS";

                if (commentData.site.endsWith(".disqus.com")) {
                    commentData.site = commentData.site + "#";
                    commentData.site = commentData.site.replace(".disqus.com#", "");
                }

                // this need to be visible in global JS context for DISQUS
                window.disqus_config = function() {
                    this.page.url = commentData.url;
                    this.page.identifier = commentData.id;
                    this.language = commentData.locale;
                };

                DISQUS_DATA = commentData;
                DISQUS_DATA.loadComments = function () {
                    if (DEBUG) console.info("Comments DISQUS .loadComments()");
                    if (PrivacyPolicy.cookiesAcceptedExternal()) {
                        if (! DISQUS_DATA.loaded) {
                            DISQUS_DATA.loaded = true;
                            var d = document, s = d.createElement('script');
                            s.src = '//' + DISQUS_DATA.site + '.disqus.com/embed.js';
                            s.setAttribute('data-timestamp', + new Date());
                            (d.head || d.body).appendChild(s);
                        } else {
                            DISQUS.reset({
                                reload: true,
                                config: window.disqus_config
                            });
                        }
                    }
                };

            } else if (commentId == "hyvor-talk-view") {
                if (DEBUG) console.info("Comments.init() found HYVOR TALK data for page id: " + commentData.id);
                commentData.valid = true;
                commentData.type = "HYVOR TALK";

                // this need to be visible in global JS context for HYVOR TALK
                window.HYVOR_TALK_WEBSITE = commentData.site;
                window.HYVOR_TALK_CONFIG = {
                    url: commentData.url,
                    id: commentData.id,
                    language: commentData.locale,
                    palette: {
                        accent: Mercury.getThemeJSON("main-theme", [])
                    }
                };

                HYVORTALK_DATA = commentData;
                HYVORTALK_DATA.loadComments = function () {
                    if (DEBUG) console.info("Comments HYVOR TALK .loadComments()");
                    if (PrivacyPolicy.cookiesAcceptedExternal()) {
                        if (! HYVORTALK_DATA.loaded) {
                            HYVORTALK_DATA.loaded = true;
                            var d = document, s = d.createElement('script');
                            s.src = '//talk.hyvor.com/web-api/embed';
                            (d.head || d.body).appendChild(s);
                        } else {
                            window.hyvor_talk.reload();
                        }
                    }
                };
            }
            if (commentData.valid) {
                if (DEBUG) console.info("Comments.init() " + commentData.type + " data=" + commentData.url + " id=" + commentData.id + " site=" + commentData.site);
                if ((commentData.$toggle.length > 0) && m_firstInit) {
                    commentData.$toggle.on('click', function(event) {
                        toggleComments(commentData);
                    });
                } else {
                    commentData.loadComments();
                }
            } else {
                if (DEBUG) console.warn("Comments.init() UNKNOWN data for id: " + commentId);
            }
        }
    });

    m_firstInit = false;
}
