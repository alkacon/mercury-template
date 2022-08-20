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

import PhotoSwipe from 'photoswipe';

// the global objects that must be passed to this module
var jQ;
var DEBUG;

"use strict";

// all auto loading image galleries as array for easy iteration
var m_autoLoadSeries = [];

// all image galleries that have been initialized as object
var m_galleries = {};

function openPhotoSwipe(index, id) {

    var options = {
        bgOpacity: 0.9,
        index : index,
        showHideAnimationType: 'none'
    };

    options.dataSource = m_galleries[id].images;
    var photoSwipe = new PhotoSwipe(options);

    photoSwipe.on('uiRegister', function() {
        photoSwipe.ui.registerElement({
            name: 'caption',
            order: 9,
            isButton: false,
            appendTo: 'root',
            onInit: (el, pswp) => {
                photoSwipe.on('change', () => {
                    const currSlideData = photoSwipe.currSlide.data;
                    el.innerHTML = '<div class="caption-wrapper">' + currSlideData.title + '</div>';
                });
            }
        });
    });

    photoSwipe.init();
}

function handleAutoLoaders() {
    if (m_autoLoadSeries != null) {
        for (var i=0; i<m_autoLoadSeries.length; i++) {
            var imageSeries = m_autoLoadSeries[i];
            // NOTE: jQuery.visible() is defined in jquery-extensions.js
            if (!imageSeries.loaded && (imageSeries.page > 0) && imageSeries.element.find(".more").visible()) {
                render(imageSeries, imageSeries.page + 1);
            }
        }
    }
}


function render(imageSeries, page) {

    // disable the image series 'more' button
    var $moreButton = imageSeries.element.find(".more");
    $moreButton.off("click");
    $moreButton.finish().hide();

    var images = imageSeries.images;
    var count = parseInt(imageSeries.count);
    var start = page * count;
    var end = start + count <= images.length ? start + count : images.length;

    if (DEBUG) console.info("Rengering images for series:" + imageSeries.id + ", start=" + start + ", end=" + end);

    var $appendElement = imageSeries.element.find(".images");
    var $spinnerElement =  imageSeries.element.find('.spinner');

    // show load indicator
    $spinnerElement.fadeIn(100);

    for (var i=start; i<end; i++) {
        var image = images[i];
        // render the base markup for this element
        var imageHtml = imageSeries.template.replace("%(index)", image.index);
        for (var property in image) {
            if (image.hasOwnProperty(property)) {
                var decodedProperty = null;
                if (property != "title") {
                    // title property has already been decoded
                    decodedProperty = decodeURIComponent(image[property]);
                } else {
                    decodedProperty = image[property];
                }
                imageHtml = imageHtml.split("%(" + property + ")").join(decodedProperty);
            }
        }
        // create DOM object from String
        var $imageElement = jQ('<div/>').html(imageHtml).contents();
        // add click handler
        $imageElement.click(image, function(event) {
            event.preventDefault();
            openPhotoSwipe(event.data.index, event.data.id);
        });
        // append the image html to the image series
        $appendElement.append($imageElement);
    }

    // hide load indicator
    $spinnerElement.finish().fadeOut(1000);
    // set the image series page
    imageSeries.page = page;

    if (end < images.length) {
        // not all images have been rendered
        if (page == 0 || imageSeries.autoload != "true") {
            // add click handlerto button if no autoload
            $moreButton.click(function() {
                render(imageSeries, page + 1);
            });
        }
        $moreButton.finish().fadeIn(250);
        // call autoload once to ensure visible buttons are directly rendered without scrolling
        handleAutoLoaders();
    } else {
        // the series images are all rendered
        imageSeries.loaded = true;
        $moreButton.finish().fadeOut(1000);
    }
}

function collect(imageSeries) {

    imageSeries.template = decodeURIComponent(imageSeries.template);
    var images = [];
    var imageSrc = [];
    var $imageSeriesItems = imageSeries.element.find("li[data-image]");
    $imageSeriesItems.each(function(index) {

        var imageData = jQ(this).data("image");
        if (! imageSrc.indexOf(imageData.tilesrc) >= 0) {
            // only add images that are not already in the list
            // this way users can manually add images from folders without duplication, e.g. for another order
            imageData.id = imageSeries.id;
            imageData.index = index;
            imageData.title = decodeURIComponent(imageData.caption);
            imageData.page = 0;

            // calculate image width and height by parsing the property string
            if (imageData.size.indexOf(',') >= 0 && imageData.size.indexOf(':') >= 0) {
                var size = imageData.size.split(',');
                imageData.width  = size[0].split(':')[1];
                imageData.height = size[1].split(':')[1];
            }
            imageSrc.push(imageData.tilesrc);
            images.push(imageData);
        }
    });

    if (DEBUG) console.info("Image image series collected " + images.length + " images:" + imageSeries + ", path=" + imageSeries.path + ", template=" + imageSeries.template);
    imageSeries.images = images;
    render(imageSeries, 0);
}

function initImageSeries($elements) {

    // initialize image series with values from data attributes
    $elements.each(function(){
        var $element = jQ(this);
        var $imageSeries = $element.find('.series');

        if (typeof $imageSeries.data("imageseries") != 'undefined') {
            var imageSeries = $imageSeries.data("imageseries");
            imageSeries.id = $imageSeries.attr("id");
            imageSeries.element = $imageSeries;
            m_galleries[imageSeries.id] = imageSeries;
            if (imageSeries.autoload == "true") {
                m_autoLoadSeries.push(imageSeries);
            }
            if (DEBUG) console.info("Image image series data found:" + imageSeries + ", path=" + imageSeries.path + ", count=" + imageSeries.count + ", autoload=" + imageSeries.autoload);
            collect(imageSeries);
        }
    });

    if (m_autoLoadSeries.length > 0) {
        // only enable scroll listener if we have at least one autoloading image series
        jQ(window).on('scroll', handleAutoLoaders).resize(handleAutoLoaders);
    }
}

function initZoomers($elements) {

    var images = [];
    var imageSrc = [];
    var indexCount = -1;
    $elements.each(function(){

        var $this = jQ(this);
        var addClick = false;

        var imageData = $this.data("imagezoom");
        if (typeof imageData.src !== 'undefined') {
            if (DEBUG) console.info("Image zoom element found with direct path=" + imageData.src);
            addClick = ($this.closest('a').length == 0);
        } else if ($this.is("a")) {
            imageData.src = $this.attr("href");
            addClick = true;
        } else if ($this.is("img")) {
            imageData.src = $this.attr("src");
            addClick = ($this.closest('a').length == 0);
        }
        var existingIndex = imageSrc.indexOf(imageData.src);
        indexCount = existingIndex < 0 ? indexCount + 1 : indexCount;
        var targetIndex = existingIndex < 0 ? indexCount : existingIndex;
        if (imageData.src) {
            imageData.index = targetIndex;
            imageData.id = "imagezoom";
            if (typeof imageData.caption !== 'undefined') {
                imageData.title = decodeURIComponent(imageData.caption);
            }
            if (existingIndex < 0) {
                images.push(imageData);
            }
            imageSrc.push(imageData.src);
            if (addClick) {
                $this.click(function(e) {
                    e.preventDefault();
                    openPhotoSwipe(targetIndex, "imagezoom");
                });
                $this.keyup(function(e) {
                    if (e.keyCode === 13) {
                        e.preventDefault();
                        openPhotoSwipe(targetIndex, "imagezoom");
                    }
                });
            }

            if (DEBUG) console.info("Image zoom element added path=" + imageData.src + ", index=" + imageData.index);
        }
    });

    var imageSeries = {};
    imageSeries.id = "imagezoom";
    imageSeries.images = images;
    m_galleries[imageSeries.id]= imageSeries;
}

/****** Exported functions ******/

export function reInit(jQ, DEBUG, parent) {
    var $imageZoomElements = jQ(parent + ' [data-imagezoom]');
    if ($imageZoomElements.length > 0) {
        if (DEBUG) console.info("ImageSeries.reInit() parent=" + parent + " [data-imagezoom] elements=" + $imageZoomElements.length);
        initZoomers($imageZoomElements);
    }
}


export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("ImageSeries.init()");

    var $imageSeriesElements = jQ('.type-imageseries');
    var $imageZoomElements = jQ('[data-imagezoom]');

    if (DEBUG) console.info("ImageSeries.init() .type-imageseries elements found: " + $imageSeriesElements.length);
    if (DEBUG) console.info("ImageSeries.init() [data-imagezoom] elements found: " + $imageZoomElements.length);

    if ($imageSeriesElements.length > 0 || $imageZoomElements.length > 0) {
        // We have found image for a series, append the PhotoSwipe markup
        if ($imageSeriesElements.length > 0) {
            initImageSeries($imageSeriesElements);
        }
        if ($imageZoomElements.length > 0) {
            initZoomers($imageZoomElements);
        }
        Mercury.addUpdateCallback(reInit);
    }
}

