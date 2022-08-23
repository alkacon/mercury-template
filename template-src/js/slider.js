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

import EmblaCarousel from 'embla-carousel';
import EmblaAutoplay from 'embla-carousel-autoplay';
import EmblaClassNames from 'embla-carousel-class-names';

// the global objects that must be passed to this module
var jQ;
var DEBUG;

"use strict";

function initSlickSliders($sliders) {

    $sliders.each(function(){
        var $slider = jQ(this);
        var data = $slider.data('typeslick') || {};
        if (Mercury.device().mobile()) {
            data.arrows = false;
            data.fade = false;
        }
        $slider.slick(data);
    });
}

// this is taken straight from the embla examples
// see https://www.embla-carousel.com/examples/navigation/#arrows--dots
// see https://codesandbox.io/s/embla-carousel-arrows-dots-vanilla-twh0h
const setupPrevNextBtns = (prevBtn, nextBtn, embla) => {
    prevBtn.addEventListener('click', embla.scrollPrev, false);
    nextBtn.addEventListener('click', embla.scrollNext, false);
};

const generateDotBtns = (dots, embla) => {
    const template = '<li type="button" role="presentation"><button type="button" class="dot-btn" role="tab" aria-selected="false" tabindex="-1">*index*</button></li>';
    let dotHtml = "";
    [].forEach.call(embla.scrollSnapList(), (slide, i) => {
        dotHtml += template.replace('*index*', i+1);
    });
    dots.innerHTML = dotHtml;
    return [].slice.call(dots.querySelectorAll(".dot-btn"));
};

const setupDotBtns = (dotsArray, embla) => {
    dotsArray.forEach((dotNode, i) => {
        dotNode.addEventListener("click", () => embla.scrollTo(i), false);
    });
};

const selectDotBtn = (dotsArray, embla) => () => {
    const previous = embla.previousScrollSnap();
    const selected = embla.selectedScrollSnap();
    dotsArray[previous].classList.remove("active");
    dotsArray[previous].setAttribute('tabindex', '-1');
    dotsArray[previous].setAttribute('aria-selected', false);
    dotsArray[selected].classList.add("active");
    dotsArray[selected].setAttribute('tabindex', '0');
    dotsArray[selected].setAttribute('aria-selected', true);
};

const checkAutoplay = (embla, slider, autoplay) => () => {
    autoplay.stop();
    slider.classList.remove('all-in-view');
    embla.scrollTo(0, true);
    const slides = embla.slidesNotInView().length;
    if (DEBUG) console.info("Slider.checkAutoplay() Slides not in view: " + slides) ;
    if (slides > 0) {
        embla.reInit({active: true});
        autoplay.play();
    } else {
        slider.classList.add('all-in-view');
        embla.reInit({active: false});
    }
}

function initEmblaSliders(sliders) {

    [].forEach.call(sliders, (slider, i) => {
        const optionNode = slider.getElementsByClassName('slide-definitions')[0];

        const options = JSON.parse(optionNode.dataset.slider);
        options.loop = true;
        options.align = 'start';
        options.inViewThreshold = 0.75;

        let plugins = [EmblaClassNames({ selected: 'slide-active' })];
        const autoplay = options.autoplay ? EmblaAutoplay({ delay: options.delay, stopOnMouseEnter: options.pause, stopOnInteraction: false }) : null;
        if (autoplay !=  null) {
            plugins.push(autoplay);
        }

        optionNode.classList.add('slider-initialized');
        const embla = EmblaCarousel(slider, options, plugins);

        if (options.arrows) {
            const prevBtn = slider.querySelector(".prev-btn");
            const nextBtn = slider.querySelector(".next-btn");
            setupPrevNextBtns(prevBtn, nextBtn, embla);
        }

        if (options.dots) {
            const dots = document.querySelector(".slider-dots");
            const dotsArray = generateDotBtns(dots, embla);
            const setSelectedDotBtn = selectDotBtn(dotsArray, embla);
            setupDotBtns(dotsArray, embla);
            embla.on("select", setSelectedDotBtn);
            embla.on("init", setSelectedDotBtn);
        }

        if (options.type == 'logo') {
            const setAutoPlay = checkAutoplay(embla, slider, autoplay);
            embla.on("init", setAutoPlay);
            embla.on("resize", setAutoPlay);
        }

        slider.addEventListener('keydown', (event) => {
            switch (event.key) {
                case "ArrowLeft":
                    embla.scrollPrev();
                    break;
                case "ArrowRight":
                    embla.scrollNext();
                    break;
            }
        });
    });
}

/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("Slider.init()");

    var $sliders = jQuery('.type-slider.type-slick-slider .slide-definitions.list-of-slides');
    if (DEBUG) console.info("Slider.init() .type-slick-slider .slide-definitions.list-of-slides elements found: " + $sliders.length);
    if ($sliders.length > 0) {
        initSlickSliders($sliders);
    }

    let sliders = document.querySelectorAll('.type-slider.type-embla-slider .slider-box');
    if (DEBUG) console.info("Slider.init() .type-embla-slider .slider-box elements found: " + sliders.length);
    if (sliders.length > 0) {
        initEmblaSliders(sliders);
    }
}
