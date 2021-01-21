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

function replaceAll(template, key, value) {

    return template.split("$(" + key + ")").join(value);
}

function getContrastBg(hexcolor){

        try {
            hexcolor = hexcolor.substr(1);
            if (hexcolor.length < 6) {
                hexcolor = hexcolor + hexcolor;
            }
            var r = parseInt(hexcolor.substr(0,2),16);
            var g = parseInt(hexcolor.substr(2,2),16);
            var b = parseInt(hexcolor.substr(4,2),16);
            var yiq = ((r*299)+(g*587)+(b*114))/1000;
            if (DEBUG) console.info("getContrastBg(#" + hexcolor + ") result: " + yiq);
            return (yiq >= 220) ? 'box box-grey' : 'box box-white';
        } catch (e) {
            return 'p-20';
        }
}

/****** Exported functions ******/

export function initCssSampler(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("CssSampler.initCssSampler()");

    var $sampleElements = jQ(".template-info.sample");
    if (DEBUG) console.info("CssSampler.initCssSampler() .template-info.sample elements found: " + $sampleElements.length);

    for (var i = 0; i < $sampleElements.length; i++) {
        var $element = jQ($sampleElements[i]);
        var template = $element.html();
        $element.empty();

        if (DEBUG) console.info("CssSampler.initCssSampler() Creating CSS sample for id: " + $element.attr('id'));
        var data = Mercury.getCssJsonData($element.attr('id'));

        for (var j = data.length-1; j>=0; j--) {

            var obj = data[j];
            if (obj.name) {
                var html = template;
                html = replaceAll(html, "name", obj.name);
                html = replaceAll(html, "value", obj.value);
                html = replaceAll(html, "background", getContrastBg(obj.value));
                $element.append(jQ(html));
            }
        }
    }
}

