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


import SlickSlider from "slick-carousel";

// the global objects that must be passed to this module
var jQ;
var DEBUG;

"use strict";

function initSlickSliders($sliders) {

    $sliders.each(function(){
        var $slider = jQ(this);
        var $sliderElement = $slider.find('.slide-definitions.list-of-slides');
        var data = $sliderElement.data('typeslick') || {};
        if (Mercury.device().mobile()) {
            data.arrows = false;
            data.fade = false;
        }
        $sliderElement.slick(data);
    });
}

/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("SliderSlick.init()");

    var $slickSliders = jQuery('.type-slick-slider');
    if (DEBUG) console.info(".type-slick-slider elements found: " + $slickSliders.length);
    if ($slickSliders.length > 0) {
        initSlickSliders($slickSliders);
    }
}
