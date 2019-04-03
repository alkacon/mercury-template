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
import PhotoSwipe   from 'photoswipe';
import PhotoSwipeUi from 'photoswipe/dist/photoswipe-ui-default';

// the global objects that must be passed to this module
var jQ;
var DEBUG;

"use strict";

// all auto loading image galleries as array for easy iteration
var m_autoLoadSeries = [];

// all image galleries that have been initialized as object
var m_galleries = {};

function appendPhotoSwipeToBody() {

jQ('body').append(
'<div class="pswp" tabindex="-1" role="dialog" aria-hidden="true">' +
    '<div class="pswp__bg"></div>' +
    '<div class="pswp__scroll-wrap">' +
        '<div class="pswp__container">' +
            '<div class="pswp__item"></div>' +
            '<div class="pswp__item"></div>' +
            '<div class="pswp__item"></div>' +
        '</div>' +
        '<div class="pswp__ui pswp__ui--hidden">' +
            '<div class="pswp__top-bar">' +
                '<div class="pswp__counter"></div>' +
                '<button class="pswp__button pswp__button--close" title="Close (Esc)"></button>' +
                '<button class="pswp__button pswp__button--fs" title="Toggle fullscreen"></button>' +
                '<button class="pswp__button pswp__button--zoom" title="Zoom in/out"></button>' +
                '<div class="pswp__preloader">' +
                    '<div class="pswp__preloader__icn">' +
                        '<div class="pswp__preloader__cut">' +
                            '<div class="pswp__preloader__donut"></div>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>' +
            '<div class="pswp__share-modal pswp__share-modal--hidden pswp__single-tap">' +
                '<div class="pswp__share-tooltip"></div>' +
            '</div>' +
            '<button class="pswp__button pswp__button--arrow--left" title="Previous (arrow left)"></button>' +
            '<button class="pswp__button pswp__button--arrow--right" title="Next (arrow right)"></button>' +
            '<div class="pswp__caption">' +
                '<div class="pswp__caption__center"></div>' +
            '</div>' +
        '</div>' +
    '</div>' +
'</div>'
);}


function openPhotoSwipe(index, id) {

    var pswpElement = document.querySelectorAll('.pswp')[0];
    var options = {
        barsSize : {top:0, bottom:0},
        history : false,
        focus : true,
        showHideOpacity : true,
        getThumbBoundsFn : false,
        showAnimationDuration : 0,
        index : index,
        closeEl : true,
        counterEl : true
    };

    var images = m_galleries[id].images;
    var photoSwipe = new PhotoSwipe(pswpElement, PhotoSwipeUi, images, options);
    // images could use .msrc pohotoswipe attribute but currently don't
    // would have to calculate small image for series and large for fullscreen
    // see http://photoswipe.com/documentation/getting-started.html#creating-slide-objects-array
    // for possible resonsive image support see
    // see http://photoswipe.com/documentation/responsive-images.html
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
                imageHtml = imageHtml.split("%(" + property + ")").join(decodeURIComponent(image[property]));
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
                imageData.w = size[0].split(':')[1];
                imageData.h = size[1].split(':')[1];
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

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("ImageSeries.init()");

    var $imageSeriesElements = jQ('.type-imageseries');
    var $imageZoomElements = jQ('[data-imagezoom]');

    if (DEBUG) console.info(".type-imageseries elements found: " + $imageSeriesElements.length);
    if (DEBUG) console.info("[data-imagezoom] elements found: " + $imageZoomElements.length);

    if ($imageSeriesElements.length > 0 || $imageZoomElements.length > 0) {
        // We have found image for a series, append the PhotoSwipe markup
        appendPhotoSwipeToBody();
        if ($imageSeriesElements.length > 0) {
            initImageSeries($imageSeriesElements);
        }
        if ($imageZoomElements.length > 0) {
            initZoomers($imageZoomElements);
        }
    }
}

