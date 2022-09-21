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

"use strict";

var m_parallaxElements;

// function to be called whenever the window is scrolled or resized
function update(){
    var scrollTop = Mercury.windowScrollTop();

    m_parallaxElements.forEach(function(element){

        var backgroundImage = getComputedStyle(element)["background-image"];
        if (backgroundImage == 'none') {
            return;
        }

        var offset = 0;
        var elementTop = Mercury.position.offset(element).top;
        var elementHeight = element.getBoundingClientRect().height;
        var elementBottom = elementTop + elementHeight;
        var elementScrollTop = elementTop - scrollTop;
        var elementScrollBottom = elementBottom - scrollTop;
        var windowHeight = window.innerHeight;

        // Check if element is to small for parallax effect
        if (elementHeight <= 1) {
            return;
        }

        // Check if element is visible, if not just return
        if (elementScrollBottom < 0 || elementScrollTop > windowHeight) {
            return;
        }

        if (Mercury.debug() == 2) console.info("Parallax elementTop: " + elementTop + " elementBottom: " + elementBottom);
        if (Mercury.debug() == 2) console.info("Parallax elementScrollTop: " + elementScrollTop + " elementScrollBottom: " + elementScrollBottom);

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

            if (Mercury.debug() == 2) console.info(
                "Parallax elementHeight: " +  elementHeight +
                " windowHeight: " + windowHeight +
                " offset: " + offset +
                " elementScrollTop: " + elementScrollTop);

        }

        element.style.backgroundPosition = ("50% " + offset + "px");
    });
}

/****** Exported functions ******/

export function initParallax() {

    m_parallaxElements = document.querySelectorAll('.effect-parallax-bg');
    if (Mercury.debug()) {
        console.info("Parallax.init()");
        console.info("Parallax.init() .effect-parallax-bg elements found: " + m_parallaxElements.length);
    }

    if (m_parallaxElements.length > 0) {
        window.addEventListener('scroll', update);
        window.addEventListener('resize', update);
        update();
    }
}
