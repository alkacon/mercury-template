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

import jQuery from 'jquery';

// import 'bootstrap/js/dist/alert';
// import 'bootstrap/js/dist/button';
// import 'bootstrap/js/dist/carousel';
import 'bootstrap/js/dist/collapse';
import 'bootstrap/js/dist/dropdown';
import 'bootstrap/js/dist/modal';
// import 'bootstrap/js/dist/offcanvas';
// import 'bootstrap/js/dist/popover';
// import 'bootstrap/js/dist/scrollspy';
import 'bootstrap/js/dist/tab';
// import 'bootstrap/js/dist/toast';
import 'bootstrap/js/dist/tooltip';

import jsDevice from 'current-device';
import fitVids from 'fitvids';
Object.assign(lazySizes.cfg, { init: false }); // otherwise device based configuration will not work
import lazySizes from 'lazysizes';

import * as AnalyticElements from './analytics.js';
import * as CommentElements from './comments.js';
import * as DynamicListElemements from './lists.js';
import * as DynamicListFilterElemements from './lists-filter.js';
import * as Icons from './icons.js';
import * as NavigationElements from './navigation.js';
import * as PrivacyPolicy from './privacy-policy.js';

import './jquery-extensions.js';
import './unobfuscate.js';

import { _OpenCmsReinitEditButtons, _OpenCmsInit } from './opencms-callbacks.js';

// Module implemented using the "revealing module pattern", see
// https://addyosmani.com/resources/essentialjsdesignpatterns/book/#revealingmodulepatternjavascript
// https://www.christianheilmann.com/2007/08/22/again-with-the-module-pattern-reveal-something-to-the-world/
const Mercury = function (jQ) {

    "use strict";

    let VERBOSE = false || (getParameter("jsverbose") != null);
    let DEBUG = VERBOSE || (getParameter("jsdebug") != null) || PrivacyPolicy.hasCookie("jsdebug");

    // container for information passed from CSS to JavaScript
    let m_info = {};

    // the grid size when the page was loaded
    let m_gridInfo = {};

    // the color theme passed from CSS to JavaScript
    let m_theme = null;

    // element update callback functions
    const m_updateCallbacks = [];

    // additional CSS files loaded
    const m_addCss = [];

    function toolbarHeight() {
        return isEditMode() ? 52 : 0;
    }

    function windowScrollTop() {
        return document.documentElement.scrollTop;
    }

    const position = {
        offset: function(el) {
            const box = el.getBoundingClientRect();
            const docElem = document.documentElement;
            return {
                top: box.top + window.scrollY - docElem.clientTop,
                left: box.left + window.scrollX - docElem.clientLeft
            };
        }
    }

    function device() {
        // returns information about the current device
        // this is provided by the current-device plugin
        return jsDevice;
    }


    function debounce(func, wait, immediate) {
        // debounce function to optimize JavaScript events
        // see https://davidwalsh.name/javascript-debounce-function
        let timeout;
        return function () {
            let context = this, args = arguments;
            let later = function () {
                timeout = null;
                if (!immediate) func.apply(context, args);
            };
            let callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = window.setTimeout(later, wait);
            if (callNow) func.apply(context, args);
        };
    }


    function addInfo(info) {
        m_info = { ...m_info, ...info };
        if (DEBUG) console.info("Mercury info extended to:");
        if (DEBUG) for (const [key, value] of Object.entries(m_info)) { console.info("- " + key + ": " + value) };
    }


    function hasInfo(key) {
        return key in m_info;
    }


    function getInfo(key) {
        if ((key in m_info) && (m_info[key] != "none")) {
            return m_info[key];
        }
        return null;
    }


    function debug() {
        // returns the DEBUG level as integer
        // returns 0 if debug mode if off, 1 if normal debug mode is on, and 2 if verbose debug mode is on
        if (VERBOSE) return 2;
        if (DEBUG) return 1;
        return 0;
    }


    function loadCss(addCss) {
        if (! m_addCss.includes(addCss)) {
            if (DEBUG) console.info("Mercury.loadCss(): " + addCss);
            const head = document.getElementsByTagName("HEAD")[0];
            const link = document.createElement("link");
            link.href = addCss;
            link.rel = "stylesheet";
            head.appendChild(link);
            m_addCss.push(addCss);
        }
    }


    function getLocale() {
        const locale = getInfo("locale");
        return (typeof locale !== "undefined") ? locale : "en";
    }


    function addContext(path) {
        let contextPath = getInfo("context");
        contextPath = ((contextPath != null) && (typeof contextPath !== "undefined")) ? contextPath : "/";
        if (DEBUG) console.info("Mercury.addContext: path=" + path + " contextPath=" + contextPath);
        path = path.startsWith("/") ? path.substr(1) : path;
        return contextPath + path;
    }


    function isNotEmpty(string) {
        // checks if the argument variable is of type string and has a length > 0
        let result = false;
        if ((typeof string === "string") && (string.trim().length > 0)) {
            result = true;
        }
        return result;
    }


    function removeQuotes(string) {
        // passing variables from SCSS to JavaScript
        // see https://css-tricks.com/making-sass-talk-to-javascript-with-json/
        if (typeof string === "string" || string instanceof String) {
            string = string.replace(/^['"]+|\\|(;\s?})+|['"]$/g, '');
        }
        return string;
    }


    function parseJson(data) {
        // parses JSON with error handling
        let result = {};
        if (isNotEmpty(data) && (data != "none")) {
            try {
                result = JSON.parse(data);
            } catch (err) {
                console.warn("Error parsing JSON data '" + data + "'", err);
            }
        }
        return result;
    }


    function getParameter(key) {
        key = key.replace(/[*+?^$.\[\]{}()|\\\/]/g, "\\$&"); // escape RegEx meta chars
        const match = location.search.match(new RegExp("[?&]" + key + "=([^&]+)(&|$)"));
        return match && decodeURIComponent(match[1].replace(/\+/g, " "));
    }


    function getCssJsonData(elementId) {
        // reads JSON data from the CSS and returns it as an JS object
        const data = getCssDataFromId(elementId);
        if (DEBUG) console.info("Mercury data found in CSS: [" + data + "]");
        return parseJson(data);
    }


    function getCssDataFromElement(element, after) {
        // read data from ::before or ::after elements in the CSS
        const selector = after ? '::after' : '::before';
        let data = null;
        if (element) {
            if (window.getComputedStyle && window.getComputedStyle(element, selector)) {
                data = window.getComputedStyle(element, selector);
                data = data.content;
            }
        }
        return data != null ? removeQuotes(data) : data;
    }


    function getCssDataFromId(elementId, after) {
        const element = document.getElementById(elementId);
        const data = getCssDataFromElement(element, after);
        return data;
    }


    function initInfo() {
        // the CSS template stores JSON encoded information for the JavaScript
        // in the HTML elements with the ID #template-info
        // initialize info sections with values from data attributes
        const element = document.querySelector("#template-info");
        if (element.dataset["info"] != null) {
            const $info = JSON.parse(element.dataset["info"]);
            addInfo($info);
        }
        m_theme = getCssJsonData(element.getAttribute("id"));
        if (DEBUG) console.info("Mercury theme JSON: " + getThemeJSON("main-theme", []));
        initGridInfo();
    }


    function getThemeJSON(key, defaultValue) {
        // the CSS template theme stores several values in the CSS by JSON
        // these values are returned by this function
        // this way it is possible to pass information from the CSS to the JavaScript
        // currently the CSS theme provides the following information:
        // * color information (main theme colors, background colors, map marker colors...)
        // * information about the grid size (responsive breakpoints, points where the mobile nav appears)
        // * header information (stick header enabled or disabled) - note that the JS can overwrite this
        // * ...other stuff
        let result = defaultValue; // default return color when all else fails
        if (m_theme) {
            try {
                const col = Object.byString(m_theme, key);
                if (typeof col !== "undefined") {
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
        // this means the "offline" project is selected AND the edit buttons are enabled in ADE
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

        let gridInfo = getCssDataFromId('template-grid-info', true);
        gridInfo = gridInfo.replace(new RegExp('px', 'g'), '');
        if (DEBUG) console.info("Mercury grid info: [" + gridInfo + "]");
        if (isNotEmpty(gridInfo)) {
            m_gridInfo = { ...m_gridInfo, ...JSON.parse(gridInfo) };
        }
        if (DEBUG) console.info("Mercury screen xs max:" + m_gridInfo.xsMax + " xxl min:" + m_gridInfo.xxlMin + " desktop head nav min:" + m_gridInfo.navDeskMin);
        if (DEBUG) console.info("Mercury fixed header nav setting: " + m_gridInfo.navFixHeader);

        m_gridInfo.currentSize = function () {
            if (window.innerWidth <= this.xsMax) {
                return "xs";
            }
            if (window.innerWidth <= this.smMax) {
                return "sm";
            }
            if (window.innerWidth <= this.mdMax) {
                return "md";
            }
            if (window.innerWidth <= this.lgMax) {
                return "lg";
            }
            if (window.innerWidth <= this.xlMax) {
                return "xl";
            }
            if (window.innerWidth >= this.xxlMin) {
                return "xxl";
            }
            return "unknown";
        }

        m_gridInfo.navType = function () {
            if (window.innerWidth <= this.navMobMax) {
                return "mobile";
            }
            if (window.innerWidth >= this.navDeskMin) {
                return "desktop";
            }
            return "unknown";
        }

        m_gridInfo.isMaxXs = function () { return window.innerWidth <= this.xsMax };
        m_gridInfo.isMaxSm = function () { return window.innerWidth <= this.smMax };
        m_gridInfo.isMaxMd = function () { return window.innerWidth <= this.mdMax };
        m_gridInfo.isMaxLg = function () { return window.innerWidth <= this.lgMax };

        m_gridInfo.isMinSm = function () { return window.innerWidth >= this.smMin };
        m_gridInfo.isMinMd = function () { return window.innerWidth >= this.mdMin };
        m_gridInfo.isMinLg = function () { return window.innerWidth >= this.lgMin };
        m_gridInfo.isMinXl = function () { return window.innerWidth >= this.xlMin };

        m_gridInfo.forceMobileNav = function () { return (this.navDeskMin < 5) };
        m_gridInfo.getNavFixHeader = function () { return (this.navFixHeader) };
        m_gridInfo.isDesktopNav = function () { return (!m_gridInfo.forceMobileNav()) && (window.innerWidth >= this.navDeskMin) };
        m_gridInfo.isMobileNav = function () { return (m_gridInfo.forceMobileNav()) || (window.innerWidth < this.navDeskMin) };
        m_gridInfo.navPos = function () { return this.navMobPos };
    }


    function calcRatio(ratio) {
        // calculates the ratio of an image based on its pixel size
        // used by some plugins (e.g. RevSlider)
        // the argument "ratio" has to have the format of the "image.size" property in OpenCms
        let result = {};
        result.valid = false;
        if (ratio != '') {
            ratio = ratio.toString();
            let i = ratio.indexOf('-');
            if (i > 0) {
                ratio = ratio.replace(',', '.');
                let wd = parseFloat(ratio.substring(0, i));
                let hd = parseFloat(ratio.substring(i + 1));
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

        const form = document.createElement("form");
        form.setAttribute("method", method);
        form.setAttribute("action", path);

        for (let key in params) {
            if (params.hasOwnProperty(key)) {
                const hiddenField = document.createElement("input");
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


    function initFitVids() {
        // set video widths using the fidVids plugin
        fitVids({
            players: ['iframe[src*="slideshare.net"]', 'iframe[src*="medien-tube.de"]', 'iframe[src*="domradio.de"]'],
            ignore: ['.type-media .content iframe'] // ignore all media elements
        });
    }


    function initTabAccordion(element, callback) {
        // add handler for elements hidden in accordions and tabs
        let accoEl = element.closest('.accordion .collapse, .collapse-parent .collapse');
        if (accoEl != null) {
            accoEl.addEventListener('shown.bs.collapse', callback);
        }
        // add handler for elements hidden in tabs
        let tabEl = element.closest('.tabs-parent');
        if (tabEl != null) {
            tabEl.querySelectorAll('button[data-bs-toggle="tab"]').forEach(function(tab) {
                tab.addEventListener('shown.bs.tab', callback);
            });
        }
        // add handler for elements hidden in the sticky header
        let headerEl = element.closest('.header-group.sticky .head');
        if (headerEl != null) {
            headerEl.addEventListener('header:notfixed', callback);
        }
    }

    function update(parent) {
        // called by Ajax methods to update dynamic template elements
        // used for example after new elements have been loaded in dynamic lists
        if (DEBUG) console.info("Mercury.update() parent=" + parent);

        initFitVids();
        // in case a dynamic list contains audio elements, make sure the required audio script is available
        loadAudioScript(function () { initMedia(parent) });
        initOnclickActivation(parent);
        initTooltips(parent);

        // run registered update callbacks
        for (let i = 0; i < m_updateCallbacks.length; i++) {
            try {
                if (DEBUG) console.info("Mercury.update() running callback: " + m_updateCallbacks[i].name);
                m_updateCallbacks[i](jQ, DEBUG, parent);
            } catch (err) {
                console.warn("Mercury.update() error in callback", err);
            }
        }

        // reset the OpenCms edit buttons
        debounce(_OpenCmsReinitEditButtons, 500);
    }


    function addUpdateCallback(callback) {
        if (typeof callback === "function") {
            if (DEBUG) console.info("Mercury.addUpdateCallback() added function: " + callback.name);
            m_updateCallbacks.push(callback);
        } else {
            console.warn("Mercury.addUpdateCallback() added object is not a function", callback);
        }
    }


    function loadAudioScript(callback) {
        // load audio script if required
        const audioScriptRequired = requiresModule(".type-media.audio, [data-audio]");
        if (audioScriptRequired && ((typeof window.AudioData === "undefined") || (typeof window.AudioData.initAudioElement !== "function"))) {
            window.AudioData = false;
            if (DEBUG) console.info("Mercury.loadAudioScript() - Loading audio script...");
            try {
                import(
                    /* webpackChunkName: "mercury-audio" */
                    "./audio.js").then(function (AudioData) {
                        if (DEBUG) console.info("Mercury.loadAudioScript() - Audio script was loaded!");
                        AudioData.init(jQ, DEBUG);
                        window.AudioData = AudioData;
                        if (typeof callback === "function") {
                            callback();
                        }
                    });
            } catch (err) {
                console.warn("Mercury.loadAudioScript() error", err);
            }
        } else {
            if (DEBUG) console.info("Mercury.loadAudioScript() - Audio script " + (audioScriptRequired ? "alreay loaded." : "not required."));
            if (typeof callback === "function") {
                callback();
            }
        }
    }


    function initLazyImageLoading() {
        // initialize lazy loading of images using the lazySizes plugin
        const lazySizesCfg = { init: true };
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
        const selector = parent + ' [data-bs-toggle="tooltip"]';
        const $tooltips = jQ(selector);
        if (DEBUG) console.info("Mercury.initTooltips() " + selector + " elements found: " + $tooltips.length);
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


    function initPlaceholder($element, callback) {
        if (isEditMode() && (typeof $element.data("placeholder") !== "undefined")) {
            // add the hide element class
            $element.addClass("placeholder");
            if (!$element.hasClass("error")) {
                // .placeholder.error class should NOT call the callback
                jQ($element).on("click", function (event) {
                    // remove handler and remove class when clicked
                    jQ(event.currentTarget).off("click")
                    jQ(event.currentTarget).removeClass("placeholder");
                    callback(event);
                }
                );
            }
            return true;
        }
        return false;
    }


    function revalOnClickTemplate($element, template, isMedia, autoplay) {
        if (DEBUG) console.info("revalOnClickTemplate(): isMedia=" + isMedia + " autoplay=" + autoplay);
        $element.removeClass("reveal-registered");
        $element.off("click");
        $element.off("keydown");
        let $p = $element.parent();
        $p.removeClass("concealed enlarged");
        $p.addClass("revealed");
        if (template == "audio") {
            autoplay = (typeof autoplay === "undefined") ? true : autoplay;
            if (window.AudioData) {
                window.AudioData.initAudioElement($element, autoplay);
            }
        } else {
            let $piece = $element.parents(".effect-piece").first();
            $piece.removeClass("effect-raise effect-shadow effect-rotate effect-box");
            let $mediaBox = $element.parents(".media-box.removable");
            if ($mediaBox.length > 0) {
                $mediaBox.removeClass().css("padding-bottom", "").addClass("media-box-removed");
                $mediaBox.find(".content").removeClass().addClass("content-removed")
            }
            $element.remove();
            let color = getThemeJSON("main-theme");
            if (typeof color !== "undefined") {
                template = template.replace("XXcolor-main-themeXX", color.substring(1));
            }
            $p.append(decodeURIComponent(template));
            initFitVids();
        }
    }


    function registerRevealFunttion($element, template, isMedia, autoplay) {
        // adds a placeholder that has to be clicked in edit mode in order to reveal the template
        // mostly used for JavaScripts that contact external servers which may not be wanted in edit mode
        const revealFunction = function () {
            // first we create a finction that revelas the template when clicked
            revalOnClickTemplate($element, template, isMedia, autoplay);
        };
        if (!initPlaceholder($element, revealFunction)) {
            // check if a placeholder is required in edit mode, otherwise directly show the element
            revealFunction();
        }
    }


    function checkOnClickTemplateCookies(event) {
        const data = event.data;
        const cookieData = data.$element.data("modal-external-cookies");
        if (!cookieData || PrivacyPolicy.cookiesAcceptedExternal()) {
            revalOnClickTemplate(data.$element, data.template, data.isMedia);
        } else {
            PrivacyPolicy.createExternalElementModal(cookieData.header, cookieData.message, cookieData.footer,
                function () {
                    revalOnClickTemplate(data.$element, cata.template, cata.isMedia);
                });
        }
    }


    function initOnclickTemplates(selector, isMedia) {
        let $onclickTemplates = jQ(selector);
        if (DEBUG) console.info("Mercury.initOnclickTemplates(): " + selector + " elements found: " + $onclickTemplates.length);
        $onclickTemplates.each(function () {

            let $element = jQ(this);
            let data = $element.data("preview");
            if (data && data.template) {
                let template = data.template;
                let color = getThemeJSON("main-theme");
                data.isMedia = isMedia;
                data.$element = $element;
                if (typeof color !== "undefined") {
                    template = template.replace("XXcolor-main-themeXX", color.substring(1));
                }
                if ($element.width() < 300) {
                    $element.addClass("narrow");
                }
                // for autoplay check if element is rendered in our template - like e.g. the audio player - or from an external server
                let noAutoPlay = (template == "audio") && (!PrivacyPolicy.cookiesAcceptedExternal() || isEditMode());
                if ($element.hasClass("ensure-external-cookies") && !noAutoPlay) {
                    // this element requires external coodies to be accepted before it is shown
                    // if cookies are not accepted the external cookie notice will be rendered from initExternalElements() in privacy-policy.js
                    if (PrivacyPolicy.cookiesAcceptedExternal()) {
                        // only render this if external cookies are allowed
                        registerRevealFunttion($element, template, isMedia, !isEditMode());
                    }
                } else if ($element.hasClass("placeholder-in-editor") && !noAutoPlay) {
                    // this element has a placeholder so it should NOT be shown direclty in edit mode, only online or in preview mode
                    registerRevealFunttion($element, template, isMedia, !isEditMode());
                } else {
                    // this element has a preview template that has to be clicked before the external content is shown
                    if (!$element.hasClass("reveal-registered")) {
                        // only attach event listerners once, important for dynamic lists
                        $element.addClass("reveal-registered");
                        $element.on("click", data, checkOnClickTemplateCookies);
                        $element.on("keydown", data, function (e) {
                            if (e.which == 13) { checkOnClickTemplateCookies(e); }
                        });
                    }
                }
            }
        });
    }


    function initMedia(parent) {
        // initialize Media element click handlers
        parent = parent || '';
        initOnclickTemplates(parent + ' .type-media .preview.inline', true);
    }


    function initOnclickActivation(parent) {
        // add click handlers to generic onclick activation elements
        parent = parent || '';
        initOnclickTemplates(parent + ' .onclick-activation', false);
    }

    function initFunctions() {
        // calls all init() functions that have registered using mercury.ready(...)
        // this is required for external scripts that need to use the jQuery instance from Mercury
        // these scripts should not register their own "$(document).ready(...)" event
        // the reason being that Mercury loads jQuery as an asset, and therefore jQuery may not available before Mercury is ready anyway
        const directInit = function(initFunction) {
            if (DEBUG) console.info("Mercury init function added after main init()!");
            initFunction(jQ, DEBUG);
        }
        // replace mercury.ready() and mercury.load() so that functions that are added AFTER Merury.initFunctions() has completed are called directly
        // this solves problems with async loaded scripts that may register an init handler after Mercury has already finished initializing
        window.mercury.ready = directInit;
        window.mercury.load = directInit;
        const _functions = window.mercury.getInitFunctions();
        if (DEBUG) console.info("Mercury init functions found: " + _functions.length);
        for (let i = 0; i < _functions.length; i++) {
            try {
                const initFunction = _functions[i];
                if (VERBOSE) console.info("Mercury executing init function:\n" + initFunction.toString());
                initFunction(jQ, DEBUG, VERBOSE);
            } catch (err) {
                console.warn("Mercury.initFunctions() error", err);
            }
        }
    }


    function addInit(initFunction) {
        // add a function to the template script init process
        if (DEBUG) console.info("Mercury added init function: " + initFunction.name);
        window.mercury(initFunction);
    }


    function initScripts() {
        // register additional JavaScripts to the template init process {#see initFunctions()}
        const $initScripts = jQ('.mercury-initscript');
        if (DEBUG) console.info("Mercury.initScripts() .mercury-initscript elements found: " + $initScripts.length);
        $initScripts.each(function () {

            const $element = jQ(this);
            if (typeof $element.data("script") !== "undefined") {
                const script = $element.data("script");
                if (DEBUG) console.info("initscript found:" + script);
                addInit(window[script]);
            }
        });
    }


    function requiresModule(selector) {
        // checks if a specific module is required by checking for special selectors
        return (jQ(selector).length > 0);
    }


    let m_cssTimer = 0;
    function waitForCss() {
        const element = document.getElementById("template-info");
        if (window.getComputedStyle(element).visibility == "hidden") {
            initAfterCss();
        } else {
            m_cssTimer += 50;
            setTimeout(function () { waitForCss() }, 50);
        }
    }


    function initAfterCss() {

        if (DEBUG) console.info("Mercury.initAfterCss() - CSS wait time: " + m_cssTimer + "ms");
        if (DEBUG) console.info("Mercury device info: " + device().type);

        // initialize
        try {
            initInfo();
        } catch (err) {
            console.warn("Mercury.initInfo() error", err);
        }

        try {
            PrivacyPolicy.init(jQ, DEBUG);
            window.PrivacyPolicy = PrivacyPolicy;
        } catch (err) {
            console.warn("PrivacyPolicy.init() error", err);
        }

        try {
            update();
        } catch (err) {
            console.warn("Mercury.update() error", err);
        }

        if (getInfo("iconConfig") != null) {
            try {
                Icons.init(getInfo("iconConfig"), getInfo("fullIcons"));
            } catch (err) {
                console.warn("Icons.init() error", err);
            }
        }

        try {
            NavigationElements.init(jQ, DEBUG, VERBOSE);
        } catch (err) {
            console.warn("Navigation.init() error", err);
        }

        try {
            DynamicListElemements.init(jQ, DEBUG, VERBOSE);
            window.DynamicList = DynamicListElemements;
        } catch (err) {
            console.warn("List.init() error", err);
        }
        
        try {
            DynamicListFilterElemements.init(jQ);
        } catch (err) {
            console.warn("ListFilter.init() error", err);
        }

        try {
            CommentElements.init(jQ, DEBUG);
        } catch (err) {
            console.warn("Comments.init() error", err);
        }

        try {
            AnalyticElements.init();
        } catch (err) {
            console.warn("Analytics.init() error", err);
        }

        // now initialize optional modules

        if (requiresModule(".use-embla-slider")) {
            try {
                import(
                    /* webpackChunkName: "mercury-slider" */
                    "./slider.js").then(function (SliderSlick) {
                        SliderSlick.init();
                    });
            } catch (err) {
                console.warn("Slider.init() error", err);
            }
        }

        if (requiresModule(".masonry-list")) {
            try {
                import(
                    /* webpackChunkName: "mercury-masonry-list" */
                    "./lists-masonry.js").then(function (MasonryList) {
                        MasonryList.init(jQ, DEBUG);
                    });
            } catch (err) {
                console.warn("MasonryList.init() error", err);
            }
        }

        if (requiresModule(".map-osm")) {
            try {
                import(
                    /* webpackChunkName: "mercury-map-osm" */
                    "./map-osm.js").then(function (OsmMap) {
                        OsmMap.init(jQ, DEBUG);
                        window.OsmMap = OsmMap;
                        window.dispatchEvent(new CustomEvent("load-module-map-osm", {
                            detail: OsmMap
                        }));
                    });
            } catch (err) {
                console.warn("OsmMap.init() error", err);
            }
        }

        if (requiresModule(".map-google")) {
            try {
                import(
                    /* webpackChunkName: "mercury-map-google" */
                    "./map-google.js").then(function (GoogleMap) {
                        window.GoogleMap = GoogleMap;
                        let response = GoogleMap.init(jQ, DEBUG);
                        if (response) {
                            response.then(function (event) {
                                window.dispatchEvent(new CustomEvent("load-module-map-google", {
                                    detail: GoogleMap
                                }));
                            });
                        } else { // Google map was loaded already
                            window.dispatchEvent(new CustomEvent("load-module-map-google", {
                                detail: GoogleMap
                            }));
                        }
                    });
            } catch (err) {
                console.warn("GoogleMap.init() error", err);
            }
        }

        if (requiresModule(".type-imageseries, [data-imagezoom]")) {
            try {
                import(
                    /* webpackChunkName: "mercury-imageseries" */
                    "./imageseries.js").then(function (ImageSeries) {
                        ImageSeries.init(jQ, DEBUG);
                        window.ImageSeries = ImageSeries;
                    });
            } catch (err) {
                console.warn("ImageSeries.init() error", err);
            }
        }

        if (requiresModule(".datepicker")) {
            try {
                import(
                    /* webpackChunkName: "mercury-datepicker" */
                    "./datepicker.js").then(function (DatePicker) {
                        DatePicker.init();
                    });
            } catch (err) {
                console.warn("DatePicker.init() error", err);
            }
        }

        if (requiresModule(".type-shariff")) {
            try {
                import(
                    /* webpackChunkName: "mercury-shariff" */
                    "shariff/dist/shariff.min.js").then(function (Shariff) {
                        if (DEBUG) console.info("Shariff module loaded!");
                    });
            } catch (err) {
                console.warn("Shariff.init() error", err);
            }
        }

        if (requiresModule(".effect-parallax-bg, .effect-parallax-bg-div > img")) {
            try {
                import(
                    /* webpackChunkName: "mercury-tools" */
                    "./parallax.js").then(function (TemplateTools) {
                        TemplateTools.initParallax();
                    });
            } catch (err) {
                console.warn("Parallax.init() error", err);
            }
        }

        if (requiresModule(".template-info.sample")) {
            try {
                import(
                    /* webpackChunkName: "mercury-tools" */
                    "./csssampler.js").then(function (TemplateTools) {
                        TemplateTools.initCssSampler(jQ, DEBUG);
                    });
            } catch (err) {
                console.warn("CssSampler.init() error", err);
            }
        }

        if (requiresModule(".formdata-manage")) {
            try {
                import(
                    /* webpackChunkName: "mercury-formdata-manage" */
                    "./formdata-manage.js").then(function (FormdataManage) {
                        FormdataManage.init();
                    });
            } catch (err) {
                console.warn("FormdataManage.init() error", err);
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

        // fire "mercury.ready" event for scripts that do not need jQuery
        window.setTimeout(function() {
            window.dispatchEvent(new CustomEvent("mercury.ready"));
        }, 500);

        // add event listeners for Bootstrap elements
        _OpenCmsInit(DEBUG);
    }

    function init() {

        if (getParameter("jsdebugperm") != null) {
            PrivacyPolicy.setCookie("jsdebug", "true");
            DEBUG = true;
        }

        // main init function - called from jQuery(document).ready() - see below in this script
        if (DEBUG) console.info("Mercury.init() - Modularized version [24-09]");
        window.Mercury = Mercury;

        try {
            initLazyImageLoading();
        } catch (err) {
            console.warn("Mercury.initLazyImageLoading() error", err);
        }

        waitForCss();
    }


    // public available functions
    return {
        init: init,
        addContext: addContext,
        addUpdateCallback: addUpdateCallback,
        calcRatio: calcRatio,
        debounce: debounce,
        debug: debug,
        device: device,
        getCssJsonData: getCssJsonData,
        getInfo: getInfo,
        getLocale: getLocale,
        getParameter: getParameter,
        getThemeJSON: getThemeJSON,
        gridInfo: gridInfo,
        hasInfo: hasInfo,
        initElements: update,
        initPlaceholder: initPlaceholder,
        initTabAccordion: initTabAccordion,
        isEditMode: isEditMode,
        isOnlineProject: isOnlineProject,
        loadCss: loadCss,
        position: position,
        post: post,
        scrollToAnchor: scrollToAnchor,
        toolbarHeight: toolbarHeight,
        update: update,
        windowScrollTop: windowScrollTop
    }

}(jQuery);


//webpack: setting the public path for the exported modules that are dynamically loaded
//see https://webpack.js.org/guides/public-path/
__webpack_public_path__ = function () {
    return __scriptPath.replace("/mercury.js", "/");
}();


jQuery(function() {
    Mercury.init();
});
