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

import RevSliderMin     from "script-loader!../plugins/revolution-slider/js/revslider.min.js";

// the global objects that must be passed to this module
var jQ;
var DEBUG;

"use strict";

// global slider variables
var m_revSliderVars;

function initRevSliderVars() {

    if (typeof m_revSliderVars === "undefined") {
        m_revSliderVars = {};

        var responsiveLevels = {};
        responsiveLevels.xl = 1200;
        responsiveLevels.lg = 1014;
        responsiveLevels.md = 764;
        responsiveLevels.sm = 552;
        responsiveLevels.xs = 450;
        m_revSliderVars.responsiveLevels = responsiveLevels;

        var gridwidth = {};
        gridwidth.xl = responsiveLevels.xl;
        gridwidth.lg = responsiveLevels.lg + (responsiveLevels.xl - responsiveLevels.lg) * 0.25;
        gridwidth.md = responsiveLevels.md + (responsiveLevels.lg - responsiveLevels.md) * 0.5;
        gridwidth.sm = responsiveLevels.sm + (responsiveLevels.md - responsiveLevels.sm) * 0.75;
        gridwidth.xs = responsiveLevels.xs;
        m_revSliderVars.gridwidth = gridwidth;
    }
}

/**
 * Calculates the grid height values for the different screen sizes
 *
 * @param slHeightXL the desired slider ratio or height value
 * @param slHeightXS the desired slider ratio or height value for small screen sizes
 * @returns an object with attributes "obj.xl", "obj.lg", "obj.md", "obj.sm", "obj.xs"
 */
function calcGridHeights(slHeightXL, slHeightXS) {
    var slRatioXL = Mercury.calcRatio(slHeightXL);
    var slRatioXS = Mercury.calcRatio(slHeightXS);
    if (DEBUG) console.log("Revslider grid: slHeightXL=" + slHeightXL + " slHeightXS=" + slHeightXS);
    var result = {};
    if (slRatioXL.valid) {
        // ratio is given, calculate heights
        var factor = 0;
        if (slHeightXS == "") {
            // no value for small screens available, use XL ratio
            result.xs = m_revSliderVars.gridwidth.xs / (slRatioXL.ratio);
        } else {
            if (slRatioXS.valid) {
                // ratio for small screens is given, calculate factor for sizes between, and small height
                var diff = slRatioXL.ratio - slRatioXS.ratio;
                factor = diff / 4;
                result.xs = m_revSliderVars.gridwidth.xs / (slRatioXS.ratio);
            } else {
                // height is given
                result.xs = slHeightXS;
            }
        }
        result.xl = m_revSliderVars.gridwidth.xl / slRatioXL.ratio;
        result.lg = m_revSliderVars.gridwidth.lg / (slRatioXL.ratio - factor);
        result.md = m_revSliderVars.gridwidth.md / (slRatioXL.ratio - (factor * 2));
        result.sm = m_revSliderVars.gridwidth.sm / (slRatioXL.ratio - (factor * 3));
    } else {
        // absolute height is given, apply to all screen sizes
        result.xl = slHeightXL;
        result.lg = slHeightXL;
        result.md = slHeightXL;
        result.sm = slHeightXL;
        if (slHeightXS == "") {
            // no value for small screens available, use common height
            result.xs = slHeightXL;
        } else {
            if (slRatioXS.valid) {
                // ratio for small screens is given
                result.xs = m_revSliderVars.gridwidth.xs / (slRatioXS.ratio);
            } else {
                // height is given
                result.xs = slHeightXS;
            }
        }
    }
    return result;
}

/**
 * Complex sliders
 */
function initComplexRevSliders($sliders) {

    initRevSliderVars();
    $sliders.each(function(){

        var $slider = jQ(this);
        var sliderId = $slider.data("sid");

        var extPath = $slider.data("ext");
        if(DEBUG){
            console.log("Revslider ExtPath: " + extPath);
        }

        // determine scroll bar width because RS does not consider this when using responsive levels
        var w1 = window.innerWidth;
        var w2 = jQ('body').innerWidth();
        var scrollWidth = w1 - w2;

        // calculate grid heights for the slider depending on the entered ratio / height
        var slHeightXL = $slider.data("height");
        var slHeightXS = $slider.data("heightsm");
        var slGridHeights = calcGridHeights(slHeightXL, slHeightXS);
        if(DEBUG){
            console.log("Revslider calculated heights:"
                + "\nXL: " + slGridHeights.xl
                + "\nLG: "+ slGridHeights.lg
                + "\nMD: "+ slGridHeights.md
                + "\nSM: "+ slGridHeights.sm
                + "\nXS: "+ slGridHeights.xs);
        }

        if (!$slider.data("init")) {
            var slConfig = {
                delay: $slider.data("delay"),
                disableProgressBar: $slider.data("noprogressbar"),
                sliderType: 'standard',
                sliderLayout: 'auto',
                autoHeight: 'on',
                spinner: 'spinner0',
                lazyType: "smart",
                stopAtSlide: -1,
                stopAfterLoops: -1,
                gridwidth : [
                    m_revSliderVars.gridwidth.xl,
                    m_revSliderVars.gridwidth.lg,
                    m_revSliderVars.gridwidth.md,
                    m_revSliderVars.gridwidth.sm,
                    m_revSliderVars.gridwidth.xs
                ],
                gridheight : [
                    slGridHeights.xl,
                    slGridHeights.lg,
                    slGridHeights.md,
                    slGridHeights.sm,
                    slGridHeights.xs
                ],
                navigation : {
                      keyboardNavigation:"off",
                      onHoverStop: $slider.data("onhoverstop"),
                      touch:{
                             touchenabled:"on",
                             swipe_treshold : 75,
                             swipe_min_touches : 1,
                             drag_block_vertical:true,
                             swipe_direction:"horizontal"
                      },
                      arrows: {
                         style:"hesperiden",
                         enable: $slider.data("arrows"),
                         rtl:false,
                         hide_onmobile:false,
                         hide_onleave:true,
                         hide_delay:200,
                         hide_delay_mobile:1200,
                         hide_under:0,
                         hide_over:9999,
                         tmp:'',
                         left : {
                                container:"slider",
                                h_align:"left",
                                v_align:"center",
                                h_offset:20,
                                v_offset:0,
                         },
                         right : {
                                container:"slider",
                                h_align:"right",
                                v_align:"center",
                                h_offset:20,
                                v_offset:0
                         }
                      },
                      bullets: {
                         enable: $slider.data("navbutton"),
                         style: 'hesperiden',
                         tmp:'<span class="tp-bullet-title"></span>',
                         hide_onmobile:false,
                         hide_onleave:true,
                         hide_delay:200,
                         hide_delay_mobile:1200,
                         hide_under:0,
                         hide_over:9999,
                         direction:"horizontal",
                         h_align:"center",
                         v_align:$slider.data("navtype"),
                         h_offset:20,
                         v_offset:20,
                         space: 5
                     }
                },

                extensions: extPath
            };

            if ($slider.data("responsive")) {
                slConfig.responsiveLevels = [
                    m_revSliderVars.responsiveLevels.xl - scrollWidth,
                    m_revSliderVars.responsiveLevels.lg - scrollWidth,
                    m_revSliderVars.responsiveLevels.md - scrollWidth,
                    m_revSliderVars.responsiveLevels.sm - scrollWidth,
                    m_revSliderVars.responsiveLevels.xs - scrollWidth
                ];

                slConfig.visibilityLevels = [
                    m_revSliderVars.gridwidth.xl,
                    m_revSliderVars.gridwidth.lg,
                    m_revSliderVars.gridwidth.md,
                    m_revSliderVars.gridwidth.sm,
                    m_revSliderVars.gridwidth.xs
                ];
            }

            jQ('#rev-slider-' + sliderId).show().revolution(
                slConfig
            );

        }
        $slider.data("init", "true");

    });
}

/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("SliderRev.init()");
    if (DEBUG) console.info("Revoulution slider JavaScript available: " + jQ.isFunction(jQ.fn.revolution));

    // RevSliderInit(jQ);

    if (jQ.isFunction(jQ.fn.revolution)) {
        var $complexSliders = jQuery('.type-complex-slider');
        if (DEBUG) console.info(".type-complex-slider elements found: " + $complexSliders.length);
        if ($complexSliders.length > 0) {
            initComplexRevSliders($complexSliders);
        }
    }
}