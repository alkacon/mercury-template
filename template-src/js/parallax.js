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

var m_$parallaxElements;

// function to be called whenever the window is scrolled or resized
function update(){
    var scrollTop = Mercury.windowScrollTop();

    m_$parallaxElements.each(function(){
        var $element = jQ(this);

        var backgroundImage = $element.css("background-image");
        if (backgroundImage == 'none') {
            return;
        }

        var offset = 0;
        var elementTop = $element.offset().top;
        var elementHeight = $element.outerHeight(true);
        var elementBottom = elementTop + elementHeight;
        var elementScrollTop = elementTop - scrollTop;
        var elementScrollBottom = elementBottom - scrollTop;
        var windowHeight = Mercury.windowHeight();

        var effectType = $element.data("parallax").effect;

        // Check if element is to small for parallax effect
        if (elementHeight <= 1) {
            return;
        }

        // Check if element is visible, if not just return
        if (elementScrollBottom < 0 || elementScrollTop > windowHeight) {
            return;
        }

        if (DEBUG) console.info("elementTop: " + elementTop + " elementBottom: " + elementBottom);
        if (DEBUG) console.info("elementScrollTop: " + elementScrollTop + " elementScrollBottom: " + elementScrollBottom);

        if (effectType == 1) {
            // This effect assumes there is a full size background image.
            // The background is slightly shifted up while the bottom of the
            // element is not in view. Once the bottom is in view,
            // or the screen top is reached, the shift effect stops.
            var elementBottomOffset = 0;

            if (elementHeight <= windowHeight) {
                elementBottomOffset = elementScrollBottom - windowHeight;
            } else {
                elementBottomOffset = elementScrollTop;
            }

            if (elementBottomOffset > 0) {
                // The bottom is not in view
                offset = Math.round(Math.abs(elementBottomOffset) * 0.5);

                if (DEBUG) console.info(
                    "elementHeight: " +  elementHeight +
                    " windowHeight: " + windowHeight +
                    " offset: " + offset +
                    " elementScrollTop: " + elementScrollTop);

            }
        } else if (effectType == 2) {
            // Initially developed for the blog visual.
            // This effect assumes there is a full size background image
            // near the screen top (directly under the main navigation).
            // The image should have standard 'photo' 4:3 or 3:2 format.
            // Initially only the upper part of the image is seen (about 400px).
            // When scolling, the image starts shiftig up faster then the scroll
            // and reveals the lower part originally hidden.

            if (elementScrollTop < 0) {
                 offset = Math.round(elementScrollTop * 2);
            }
        } else if (effectType == 3) {
            // Also developed for the blog visual.
            // This effect assumes there is a full size background image
            // near the screen top (directly under the main navigation).
            // The image should have standard 'photo' 4:3 or 3:2 format.
            // When scolling, the image starts shiftig very slow
            // and reveals some of the lower part originally hidden.

            offset = Math.round(elementScrollTop * 0.33);
        }
        $element.css('background-position', "50% " + offset + "px");
    });
}

function initParallaxInt() {

    // initialize parallax sections with values from data attributes
    m_$parallaxElements.each(function(){

        var $element = jQ(this);
        var effectType = 1;

        // the following data attribute can to be attached to the div
        // <div class="effect-parallax-bg" data-prallax='{"effect":1}' >
        if (typeof $element.data("parallax") != 'undefined') {
            if (typeof $element.data("parallax").effect != 'undefined') {
                effectType = $element.data("parallax").effect;
            }
        }
        $element.data("parallax", { effect: effectType } );
    });
}

/****** Exported functions ******/

export function initParallax(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    m_$parallaxElements = jQuery('.effect-parallax-bg');
    if (DEBUG) {
        console.info("Parallax.init()");
        console.info("Parallax.init() .effect-parallax-bg elements found: " + m_$parallaxElements.length);
    }

    if (m_$parallaxElements.length > 0) {
        initParallaxInt();
        jQ(window).on('scroll', update).resize(update);
        update();
    }
}
