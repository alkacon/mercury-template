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

// Polyfills to support IE 11
import 'promise-polyfill/src/polyfill';
import 'mdn-polyfills/Object.assign';

import jQuery                       from 'jquery';
import bootstrap                    from 'bootstrap';
import jsDevice                     from 'current-device';
import fitVids                      from 'fitvids';
Object.assign(lazySizes.cfg,        { init:false }); // otherwise device based configuration will not work
import lazySizes                    from 'lazysizes';

import * as DynamicListElemements   from './lists.js';
import * as NavigationElements      from './navigation.js';
import * as DisqusElements          from './disqus.js';
import * as AnalyticElements        from './analytics.js';
import * as PrivacyPolicy           from './privacy-policy.js';

import jQueryExtensions             from './jquery-extensions.js';
import unobfuscateString            from './unobfuscate.js';

import { _OpenCmsReinitEditButtons, _OpenCmsInit } from './opencms-callbacks.js';

var DEBUG = false || (getParameter("jsdebug") != null);

// Module implemented using the "revealing module pattern", see
// https://addyosmani.com/resources/essentialjsdesignpatterns/book/#revealingmodulepatternjavascript
// https://www.christianheilmann.com/2007/08/22/again-with-the-module-pattern-reveal-something-to-the-world/
var Mercury = function(jQ) {

    "use strict";

    // class to mark element that should be hidden
    var HIDE_ELEMENT_CLASS="element-hide";

    // container for information passed from CSS to JavaScript
    var m_info = {};

    // the color theme passed from CSS to JavaScript
    var m_theme = null;

    // the grid size when the page was loaded
    var m_gridInfo = {};

    // the current window
    var m_$window = jQ(window);

    // height of current window
    var m_windowHeight = m_$window.height();

    // width of current window
    var m_windowWidth = m_$window.width();

    // attach event listener to window resize event (debounced)
    m_$window.resize(debounce(function() {
        m_windowHeight = m_$window.height();
        m_windowWidth = m_$window.width();

        if (DEBUG) console.info("Mercury current grid size: " + m_gridInfo.currentSize());
    }, 100));


    function windowHeight() {
        return m_windowHeight;
    }


    function windowWidth() {
        return m_windowWidth;
    }


    function toolbarHeight() {
        return isEditMode() ? 52 : 0;
    }


    function windowScrollTop() {
        return m_$window.scrollTop();
    }


    function device() {
        // returns information about the current device
        // this is provided by the current-device plugin
        return jsDevice;
    }


    function debounce(func, wait, immediate) {
        // debounce function to optimize JavaScript events
        // see https://davidwalsh.name/javascript-debounce-function
        var timeout;
        return function() {
            var context = this, args = arguments;
            var later = function() {
                timeout = null;
                if (!immediate) func.apply(context, args);
            };
            var callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = window.setTimeout(later, wait);
            if (callNow) func.apply(context, args);
        };
    }


    function addInfo(info) {

        jQ.extend(m_info, info);

        if (DEBUG) console.info("Mercury info extended to:");
        if (DEBUG) jQ.each(m_info, function( key, value ) { console.info( "- " + key + ": " + value ); });
    }


    function hasInfo(key) {

        return key in m_info;
    }

    function hideElement($element){
        if (typeof $element.data("hidemessage") != "undefined"){
            $element.addClass(HIDE_ELEMENT_CLASS);
        }
    }

    function isElementHidden($element, callback){

        if (typeof $element.data("hidemessage") != "undefined") {
            // add the hide element class
            $element.addClass(HIDE_ELEMENT_CLASS);
            // show the element by clicking on the element
            jQ($element).on("click",function(event) {
            // remove handler and remove class
            jQ(event.currentTarget).off("click")
                jQ(event.currentTarget).removeClass(HIDE_ELEMENT_CLASS);
                callback(event);
            });
            return true;
        }
        return false;
    }


    function getInfo(key) {

        if ((key in m_info) && (m_info[key] != "none")) {
            return m_info[key];
        }
        return null;
    }


    function getLocale() {

        var locale = getInfo("locale");
        return (typeof locale !== "undefined") ? locale : "en";
    }


    function isNotEmpty(string) {
        // checks if the argument variable is of type string and has a length > 0
        var result = false;
        if ((typeof string === "string") && (string.trim().length > 0)) {
           result = true;
        }
        return result;
    }


    function removeQuotes(string) {
        // passing variables from SCSS to JavaScript
        // see https://css-tricks.com/making-sass-talk-to-javascript-with-json/
        if (typeof string === 'string' || string instanceof String) {
            string = string.replace(/^['"]+|\\|(;\s?})+|['"]$/g, '');
        }
        return string;
    }


    function parseJson(data) {
        // parses JSON with error handling
        var result = {};
        if (isNotEmpty(data) && (data != "none")) {
            try {
                result = JSON.parse(data);
            } catch (err) {
                console.warn("Error parsing JSON data '" + data + "'", err);
            }
        }
        return result;
    }


    function getCssJsonData(elementId) {
        // reads JSON data from the CSS and returns it as an JS object
        var data = getCssDataFromId(elementId);
        if (DEBUG) console.info("Mercury data found in ::before: [" + data + "]");
        return parseJson(data);
    }


    function getCssDataFromElement(element, after) {
        // read data from ::before or ::after elements in the CSS
        var selector = after ? '::after' : '::before';
        var data = null;
        if (element) {
            if (window.getComputedStyle && window.getComputedStyle(element, selector) ) {
                data = window.getComputedStyle(element, selector);
                data = data.content;
            }
        }
        return data != null ? removeQuotes(data) : data;
    }


    function getCssDataFromId(elementId, after) {
        var element = document.getElementById(elementId);
        return getCssDataFromElement(element, after);
    }


    function getCssDataFromJQuery($element, after) {
        var element = $element.get(0);
        return getCssDataFromElement(element, after);
    }


    function initInfo() {
        // the CSS template stores JSON encoded information for the JavaScript
        // in the HTML elements with the ID #template-info
        // initialize info sections with values from data attributes
        jQ('#template-info').each(function() {
            var $element = jQ(this);
            if (typeof $element.data("info") != 'undefined') {
                var $info = $element.data("info");
                addInfo($info);
            }
            m_theme = getCssJsonData($element.attr('id'));
            if (DEBUG) console.info("Mercury theme JSON: " + getThemeJSON("main-theme", []));
        });

        initGridInfo();
    }


    function getThemeJSON(key, defaultValue) {
        // the CSS template themes store several values in the CSS by JSON
        // these values are returned by this function
        // this way it is possible to pass information from the CSS to the JavaScript
        // currently the CSS theme provides the following information:
        // * color information (main theme colors, background colors, map marker colors...)
        // * information about the grid size (responsive breakpoints, points where the mobile nav appears)
        // * header information (stick header enabled or disabled) - note that the JS can overwrite this
        // * ...other stuff
        var result = defaultValue; // default return color when all else fails
        if (m_theme) {
            try {
                var col = Object.byString(m_theme, key);
                if (typeof col != "undefined") {
                    result = col;
                }
            } catch (e) {
                // result will be default
            }
        }

        return result;
    }


    function isOnlineProject() {
        // returns if the current OpenCms project is the online project
        // this information about is directly rendered into the template by OpenCms when the page is created
        // it is stored in the #template-info HTML element
        return ("online" == m_info["project"]);
    }


    function isEditMode() {
        // returns "true" if OpenCms runs in edit mode
        // this means "offline" project AND edit buttons are enables in ADE
        // this information about is directly rendered into the template by OpenCms when the page is created
        // it is stored in the #template-info HTML element
        return ("true" == m_info["editMode"]);
    }


    function gridInfo() {
        // function wrapper for the gridInfo variable
        return m_gridInfo;
    }


    function initGridInfo() {
        // update grid size from CSS
        m_gridInfo.grid = getCssDataFromId('template-grid-info');
        if (DEBUG) console.info("Mercury grid size: " + m_gridInfo.grid);

        var gridInfo = getCssDataFromId('template-grid-info', true);
        gridInfo = gridInfo.replace(new RegExp('px', 'g'), '');
        if (DEBUG) console.info("Mercury grid info: [" + gridInfo + "]");
        if (isNotEmpty(gridInfo)) {
            jQ.extend(m_gridInfo, JSON.parse(gridInfo));
        }
        if (DEBUG) console.info("Mercury screen xs max:" + m_gridInfo.xsMax + " xl min:" + m_gridInfo.xlMin  + " desktop head nav min:" + m_gridInfo.navDeskMin);
        if (DEBUG) console.info("Mercury fixed header nav setting: " + m_gridInfo.navFixHeader);

        m_gridInfo.currentSize = function() {
            if (m_windowWidth <= this.xsMax) {
                return "xs";
            }
            if (m_windowWidth <= this.smMax) {
                return "sm";
            }
            if (m_windowWidth <= this.mdMax) {
                return "md";
            }
            if (m_windowWidth <= this.lgMax) {
                return "lg";
            }
            if (m_windowWidth >= this.xlMin) {
                return "xl";
            }
            return "unknown";
        }

        m_gridInfo.navType = function() {
            if (m_windowWidth <= this.navMobMax) {
                return "mobile";
            }
            if (m_windowWidth >= this.navDeskMin) {
                return "desktop";
            }
            return "unknown";
        }

        m_gridInfo.isMaxXs = function() { return m_windowWidth <= this.xsMax };
        m_gridInfo.isMaxSm = function() { return m_windowWidth <= this.smMax };
        m_gridInfo.isMaxMd = function() { return m_windowWidth <= this.mdMax };
        m_gridInfo.isMaxLg = function() { return m_windowWidth <= this.lgMax };

        m_gridInfo.isMinSm = function() { return m_windowWidth >= this.smMin };
        m_gridInfo.isMinMd = function() { return m_windowWidth >= this.mdMin };
        m_gridInfo.isMinLg = function() { return m_windowWidth >= this.lgMin };
        m_gridInfo.isMinXl = function() { return m_windowWidth >= this.xlMin };

        m_gridInfo.isDesktopNav = function() { return m_windowWidth >= this.navDeskMin };
        m_gridInfo.isMobileNav = function() { return m_windowWidth < this.navDeskMin };
        m_gridInfo.navPos = function() { return this.navMobPos };
        m_gridInfo.getNavFixHeader = function() { return (this.navFixHeader) };
    }


    function calcRatio(ratio) {
        // calculates the ratio of an image based on its pixel size
        // used by some plugins (e.g. RevSlider)
        // the argument "ratio" has to have the format of the "image.size" property in OpenCms
        var result = {};
        result.valid = false;
        if (ratio != '') {
            ratio = ratio.toString();
            var i = ratio.indexOf('-');
            if (i > 0) {
                ratio = ratio.replace(',', '.');
                var wd = parseFloat(ratio.substring(0, i));
                var hd = parseFloat(ratio.substring(i + 1));
                result.wd = wd;
                result.hd = hd;
                result.ratio = wd / hd;
                result.valid = true;
            }
        }
        return result;
    }


    function post(path, params, method) {
        method = method || "post"; // Set method to post by default if not specified.

        var form = document.createElement("form");
        form.setAttribute("method", method);
        form.setAttribute("action", path);

        for(var key in params) {
            if(params.hasOwnProperty(key)) {
                var hiddenField = document.createElement("input");
                hiddenField.setAttribute("type", "hidden");
                hiddenField.setAttribute("name", key);
                hiddenField.setAttribute("value", params[key]);

                form.appendChild(hiddenField);
             }
        }

        document.body.appendChild(form);
        form.submit();
    }


    function scrollToAnchor($anchor, offset) {
        NavigationElements.scrollToAnchor($anchor, offset);
    }


    function initJavaScriptMarker() {
        // adds a CSS class "hasscript" to the document body so CSS can react if JS is available or not
        // when initially loaded, the page has the class "noscript" attached
        jQ(document.documentElement).removeClass("noscript");
        jQ(document.documentElement).addClass("hasscript");
    }


    function initFitVids() {
        // set vidio withs using the fidVids plugin
        fitVids({ players: "iframe[src*='slideshare.net']"});
    }


    // Affix elements, restricted to a parent container
    var m_affixElements = [];

    // Update Affix elements
    function updateAffix() {
        var verbose = false;
        if (DEBUG && verbose) console.info("Affix: update, m_affixElements=" + m_affixElements.length);
        for (var i=0; i<m_affixElements.length; i++) {
            var toolbarHeight = toolbarHeight();
            var affix = m_affixElements[i];
            var $element = affix.$element;
            var $parent =  affix.$parent;
            var topOffset = affix.top;
            var topOffsetFixed = affix.topFixed;
            var pHeight = $parent.outerHeight(true);
            var eHeight = $element.outerHeight(true);
            var docHeight = jQ(document).height();
            var scrollTop = m_$window.scrollTop();
            var top = $parent.offset().top - toolbarHeight + topOffset - topOffsetFixed;
            var bottom = top + (pHeight - eHeight) - topOffset;

            if (DEBUG && verbose) console.info("Affix: docHeight=" + docHeight + " pHeight=" +  pHeight + " eHeight=" +  eHeight + " top=" + top + " bottom=" + bottom + " scrollTop=" + scrollTop);

            var isFixedTop = scrollTop > top;
            var isFixedBottom = isFixedTop && (scrollTop >= bottom);

            if (DEBUG && verbose) console.info("Affix isFixed=" + (isFixedTop || isFixedBottom) + " isFixedTop=" + isFixedTop + " isFixedBottom=" + isFixedBottom);
            if (isFixedBottom) {
                $element.removeClass("affix affix-top").addClass("affix-bottom");
                $element.css("top", pHeight - eHeight);
            } else if (isFixedTop) {
                $element.removeClass("affix-top affix-bottom").addClass("affix");
                $element.css("top", toolbarHeight + topOffsetFixed);
            } else {
                $element.removeClass("affix-bottom affix").addClass("affix-top");
                $element.css("top", topOffset);
            }
        }
    }

    // Init Affix elements
    function initAffixes() {
        var verbose = false;
        var $affixes = jQ('.affix-parent .affix-box');
        if (DEBUG) console.info(".affix-parent .affix-box elements found: " + $affixes.length);
        $affixes.each(function() {
            var $element = jQ(this);
            var $parent = $element.parents(".affix-parent").first();
            var affix = {};
            affix.$element = $element;
            affix.$parent = $parent;
            var topCss = $element.css("top");
            if (typeof topCss !== "undefined") { topCss = topCss.match(/-?\d+/) } else { topCss = "0" };
            var options = getCssDataFromJQuery($element);
            var data = parseJson(options);
            if (typeof data.topFixed === "undefined" ) { data.topFixed = 0 };
            if (DEBUG && verbose) console.info("Affix: css JSON data is=" + options + " topFixed=" + data.topFixed);
            affix.top = parseInt(topCss, 10);
            affix.topFixed = data.topFixed;
            m_affixElements.push(affix);
            if (DEBUG && verbose) console.info("Affix: added top=" + affix.top + " topFixed=" + affix.topFixed);
        });
        if (m_affixElements.length > 0) {
            m_$window.on('scroll resize', function() { updateAffix() }); // can not use debouce, will be to "jaggy"
            updateAffix(true);
        }
    }


    function initElements(parent) {
        // call back for Ajax methods to initialize dynamic template elements
        initFitVids();
        initMedia();
        initTooltips(parent);

        // reset the OpenCms edit buttons
        debounce(_OpenCmsReinitEditButtons, 500);
    }



    function initLazyImageLoading() {
        // initialize lazy loading of images using the lazySizes plugin
        var lazySizesCfg = { init:true };
        if (device().desktop()) {
            lazySizesCfg.expFactor = 2.0; // load elements "not so near" for desktop
            lazySizesCfg.loadMode = 3; // load elements "not so near" for desktop
        } else {
            lazySizesCfg.loadMode = 1; // only load visible elements for mobile
        }
        // see https://github.com/aFarkas/lazysizes/issues/410
        Object.assign(lazySizes.cfg, lazySizesCfg);
        lazySizes.init();
    }


    function initTooltips(parent) {
        // initialize bootstrap tooltips
        parent = parent || '';
        var selector = parent + ' [data-toggle="tooltip"]';
        var $tooltips = jQ(selector);
        if (DEBUG) console.info(selector + " tooltips found: " +  $tooltips.length);
            if ($tooltips.length > 0) {
            $tooltips.tooltip({
                container: 'body',
                placement: 'top',
                delay: { 'show': 100, 'hide': 100 }
            });
            if (!device().desktop()) {
                // automatically close the tooltip
                $tooltips.on('shown.bs.tooltip', function (event) {
                    setTimeout(function () {
                        $(event.target).tooltip('hide');
                    }, 2500);
                });
            }
        }
    }


    function initMedia(parent) {
        // initialize Media element click handlers
        parent = parent || '';
        var selector = parent + ' .type-media .preview';
        var $mediaElements = jQ(selector);
        if (DEBUG) console.info(selector + " elements found: " + $mediaElements.length);
        $mediaElements.each(function() {

            var $element = jQ(this);
            var data = $element.data("preview");
            if (data && data.template) {
                $element.on("click", data, function(event) {
                    var $m = jQ(this);
                    var $p = $m.parent();
                    $p.parent().removeClass("effect-raise effect-shadow effect-rotate effect-box");
                    $p.parent().addClass("play");
                    $m.remove();
                    $p.append(decodeURIComponent(data.template));
                });
                /* This may not be needed
                $element.on("lazyloaded", data, function(event) {
                    // after image is loaded, make sure video is fit into available space
                    var $m = jQ(this);
                    var $centered = $m.find(".centered").first();
                    var $preview = $m.closest(".preview").first();
                    if ($preview.height() < $centered.height()) {
                        var percentage = $preview.height() / $centered.height() * 101.0;
                        $centered.css("width", percentage + "%");
                    }
                });
                */
            }
        });
    }

    function checkVersion() {
        // writes version information about the template to the console
        var sassVersion = getCssDataFromId('template-sass-version');

        if (DEBUG) console.info("Mercury asset versions: " +
                     "SASS " + sassVersion +
                     " - JavaScript " + WEBPACK_SCRIPT_VERSION);
    }


    function addInit(initFunction) {
        // Add a function to the template script init process
        if (DEBUG) console.info("Mercury added init function: " + initFunction.name);
        window.mercury(initFunction);
    }


    function initScripts() {
        // register additional JavaScripts to the template init process
        // the idea is that additional JavaScrips are started from here rather then registering their own "window.onload" event
        // this way it can be ensured that the required page functions are already initialized when the additional JS is executed
        var $initScripts = jQ('.mercury-initscript');
        if (DEBUG) console.info(".mercury-initscript elements found: " + $initScripts.length);
        $initScripts.each(function() {

            var $element = jQ(this);
            if (typeof $element.data("script") != 'undefined') {
                var script = $element.data("script");
                if (DEBUG) console.info("initscript found:" + script);
                addInit(window[script]);
            }
        });
    }


    function initFunctions() {
        // calls all init() functions that have registered
        var _functions = window.mercury.getInitFunctions();
        for (var i=0; i < _functions.length; i++) {
            try {
                var initFunction = _functions[i];
                if (DEBUG) console.info("Mercury executing init function: " + initFunction.name);
                initFunction(jQ, DEBUG);
            } catch (err) {
                console.warn("Mercury.initFunctions() error", err);
            }
        }
    }

    function requiresModule(selector) {
        // checks if a specific module is required by checking for special selectors
        return (jQ(selector).length > 0);
    }


    var m_cssTimer = 0;
    function waitForCss() {
        var element = document.getElementById("template-info");
        if (window.getComputedStyle(element).visibility == "hidden") {
            initAfterCss();
        } else {
            m_cssTimer += 50;
            setTimeout(function() { waitForCss() }, 50);
        }
    }


    function init() {
        // Template script main init function!
        // This is called directly by jQuery(document).ready from a script embedded on the page generated by OpenCms
        if (DEBUG) console.info("Mercury.init() - Modularized version");
        window.Mercury = Mercury;

        try {
            initJavaScriptMarker(); // set JavaScript marker class to <html>
        } catch (err) {
            console.warn("Mercury.initJavaScriptMarker() error", err);
        }
        try {
            initLazyImageLoading();
        } catch (err) {
            console.warn("Mercury.initLazyImageLoading() error", err);
        }
        try {
            initElements();
        } catch (err) {
            console.warn("Mercury.initElements() error", err);
        }

        waitForCss();
    }


    function initAfterCss() {

        if (DEBUG) console.info("Mercury.initAfterCss() - CSS wait time: " + m_cssTimer + "ms");
        checkVersion(); // output a JS console information about the template version
        if (DEBUG) console.info("Mercury device info: " + device().type);

        // initialize
        try {
            initInfo();
        } catch (err) {
            console.warn("Mercury.initInfo() error", err);
        }
        try {
            initAffixes();
        } catch (err) {
            console.warn("Mercury.initAffixes() error", err);
        }

        // initialize default modules
        try {
            PrivacyPolicy.init(jQ, DEBUG);
            window.PrivacyPolicy = PrivacyPolicy;
        } catch (err) {
            console.warn("PrivacyPolicy.init() error", err);
        }
        try {
            NavigationElements.init(jQ, DEBUG);
        } catch (err) {
            console.warn("Navigation.init() error", err);
        }
        try {
            DynamicListElemements.init(jQ, DEBUG);
            window.DynamicList = DynamicListElemements;
        } catch (err) {
            console.warn("List.init() error", err);
        }
        try {
            DisqusElements.init(jQ, DEBUG);
        } catch (err) {
            console.warn("Disqus.init() error", err);
        }
        try {
            AnalyticElements.init(jQ, DEBUG);
        } catch (err) {
            console.warn("Analytics.init() error", err);
        }

        // now initialize optional modules

        if (requiresModule(".type-slick-slider")) {
            try {
                import(
                    /* webpackChunkName: "mercury-slider-slick" */
                    "./slider-slick.js").then( function ( SliderSlick ) {
                    SliderSlick.init(jQ, DEBUG);
                });
            } catch (err) {
                console.warn("Mercury SliderSlick.init() error", err);
            }
        }

        if (requiresModule(".map-osm")) {
            try {
                 import(
                    /* webpackChunkName: "mercury-map-osm" */
                    "./map-osm.js").then( function ( OsmMap ) {
                       OsmMap.init(jQ, DEBUG);
                       window.OsmMap = OsmMap;
                 });
            } catch (err) {
                 console.warn("OsmMap.init() error", err);
            }
         }

         if (requiresModule(".map-google")) {
              try {
                  import(
                      /* webpackChunkName: "mercury-map-google" */
                      "./map-google.js").then( function ( GoogleMap ) {
                      GoogleMap.init(jQ, DEBUG);
                      window.GoogleMap = GoogleMap;
                  });
               } catch (err) {
                  console.warn("GoogleMap.init() error", err);
               }
         }

        if (requiresModule(".masonry-list")) {
            try {
                import(
                    /* webpackChunkName: "mercury-masonry-list" */
                    "./lists-masonry.js").then( function (MasonryList) {
                    MasonryList.init(jQ, DEBUG);
                });
            } catch (err) {
                console.warn("MasonryList.init() error", err);
            }
        }

        if (requiresModule(".type-imageseries, [data-imagezoom]")) {
            try {
                import(
                    /* webpackChunkName: "mercury-imageseries" */
                    "./imageseries.js").then( function (ImageSeries) {
                    ImageSeries.init(jQ, DEBUG);
                });
            } catch (err) {
                console.warn("Mercury ImageSeries.init() error", err);
            }
        }

        if (requiresModule(".type-shariff")) {
            try {
                import(
                    /* webpackChunkName: "mercury-shariff" */
                    "script-loader!shariff/dist/shariff.min.js").then( function(Shariff) {
                    if (DEBUG) console.info("Shariff module loaded!");
                });
            } catch (err) {
                console.warn("Shariff.init() error", err);
            }
        }

        // support for revolution slider is disabled by default
        if (false) {
            if (requiresModule(".type-complex-slider")) {
                try {
                    import(
                        /* webpackChunkName: "mercury-slider-rev" */
                        "./slider-rev.js").then( function (SliderRev) {
                        SliderRev.init(jQ, DEBUG);
                    });
                } catch (err) {
                    console.warn("SliderRev.init() error", err);
                }
            }
        }

        if (requiresModule(".effect-parallax-bg")) {
            try {
                import(
                    /* webpackChunkName: "mercury-tools" */
                    "./parallax.js").then( function(TemplateTools) {
                    TemplateTools.initParallax(jQ, DEBUG);
                });
            } catch (err) {
                console.warn("Parallax.init() error", err);
            }
        }

        if (requiresModule(".template-info.sample")) {
            try {
                import(
                    /* webpackChunkName: "mercury-tools" */
                    "./csssampler.js").then( function(TemplateTools) {
                    TemplateTools.initCssSampler(jQ, DEBUG);
                });
            } catch (err) {
                console.warn("CssSampler.init() error", err);
            }
        }

        try {
            // this must come directly before initFunctions()
            initScripts();
        } catch (err) {
            console.warn("Mercury.initScripts() error", err);
        }
        try {
            // this must come last
            initFunctions();
        } catch (err) {
            console.warn("Mercury.initFunctions() error", err);
        }

        // add event listeners for Bootstrap elements
        _OpenCmsInit(jQ, DEBUG)
    }


    // public available functions
    return {
        init: init,
        calcRatio: calcRatio,
        debounce: debounce,
        device: device,
        getCssJsonData: getCssJsonData,
        getInfo: getInfo,
        getLocale: getLocale,
        getThemeJSON: getThemeJSON,
        gridInfo: gridInfo,
        hasInfo: hasInfo,
        hideElement: hideElement,
        initElements: initElements,
        isEditMode: isEditMode,
        isElementHidden: isElementHidden,
        isOnlineProject: isOnlineProject,
        post: post,
        scrollToAnchor: scrollToAnchor,
        toolbarHeight: toolbarHeight,
        windowHeight: windowHeight,
        windowWidth: windowWidth,
        windowScrollTop: windowScrollTop
    }

}(jQuery);


//webpack: setting the public path for the exported modules that are dynamically loaded
//see https://webpack.js.org/guides/public-path/
__webpack_public_path__ = function() {
    return __scriptPath.replace("/mercury.js", "/");
}();

function getParameter(key) {
    key = key.replace(/[*+?^$.\[\]{}()|\\\/]/g, "\\$&"); // escape RegEx meta chars
    var match = location.search.match(new RegExp("[?&]"+key+"=([^&]+)(&|$)"));
    return match && decodeURIComponent(match[1].replace(/\+/g, " "));
}

jQuery(document).ready(function() {
    Mercury.init();
});
