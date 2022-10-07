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

import EmblaCarousel from 'embla-carousel';
import EmblaClassNames from 'embla-carousel-class-names';

"use strict";

//                      2     4   6   8   10
const massTable = [1,20,14,11,7,6,4,4,2,2,1];
const getMass = (speed) => {
    if ((speed > 9) || (speed < 1)) return 1;
    return massTable[speed];
}

const scrollTo = (engine, index, autoplay, direction, speed) => {
    if (autoplay) autoplay.stop();
    let sp = (engine.options.speed > 90) ? engine.options.speed : speed || 8;
    engine.scrollBody.useSpeed(sp).useMass(getMass(sp));
    engine.scrollTo.index(index, direction || 0);
}

const scrollNext = (engine, autoplay, speed) => {
    const next = engine.index.clone().add(1);
    scrollTo(engine, next.get(), autoplay, -1, speed);
}

const scrollPrev = (engine, autoplay, speed) => {
    const prev = engine.index.clone().add(-1);
    scrollTo(engine, prev.get(), autoplay, 1, speed);
}

const setupPrevNextBtns = (prevBtn, nextBtn, embla, autoplay) => {
    prevBtn.addEventListener('click', () => { scrollPrev(embla.internalEngine(), autoplay) }, false);
    nextBtn.addEventListener('click', () => { scrollNext(embla.internalEngine(), autoplay) }, false);
};

const setupDotBtns = (dotsArray, embla, autoplay) => {
    dotsArray.forEach((dotBtn, i) => {
        dotBtn.addEventListener('click', () => { scrollTo(embla.internalEngine(), i, autoplay) }, false);
    });
};

const generateDotBtns = (dots, embla) => {
    const template = dots.innerHTML;
    let dotHtml = "";
    const slideTotal = embla.slideNodes().length;
    for (let slideIndex=0; slideIndex<slideTotal; slideIndex++) {
        dotHtml += template.replace('*slideIndex*', slideIndex + 1).replace('*slideTotal*', slideTotal);
    };
    dots.innerHTML = dotHtml;
    return [].slice.call(dots.querySelectorAll(".dot-btn"));
};

const selectDotBtn = (dotsArray, embla) => () => {
    const previous = embla.previousScrollSnap();
    const selected = embla.selectedScrollSnap();
    dotsArray[previous].classList.remove('active');
    dotsArray[previous].setAttribute('tabindex', '-1');
    dotsArray[previous].setAttribute('aria-selected', false);
    dotsArray[selected].classList.add('active');
    dotsArray[selected].setAttribute('tabindex', '0');
    dotsArray[selected].setAttribute('aria-selected', true);
};

// In order to use my custom mass functions I had to modfy the autoplay plugin from the distribution
function AutoplayMod(userOptions) {

    const defaultOptions = {
        active: true,
        breakpoints: {},
        delay: 4000,
        speed: 4,
        stopOnInteraction: false,
        stopOnMouseEnter: false
    }

    const optionsHandler = EmblaCarousel.optionsHandler();

    let options;
    let carousel;
    let interaction;
    let timer = 0;

    function init(embla) {
        if (Mercury.debug()) console.info("Slider.init() AutoplayMod.init()");
        carousel = embla;
        options = optionsHandler.atMedia(self.options);
        interaction = options.stopOnInteraction ? destroy : stop;
        const { eventStore } = carousel.internalEngine();
        const root = carousel.rootNode();

        carousel.on('pointerDown', interaction);
        if (!options.stopOnInteraction) carousel.on('pointerUp', reset);

        if (options.stopOnMouseEnter) {
            eventStore.add(root, 'mouseenter', stop);
            eventStore.add(root, 'mouseleave', reset);
        }

        eventStore.add(document, 'visibilitychange', () => {
            if (document.visibilityState === 'hidden') return stop();
            reset()
        })
        eventStore.add(window, 'pagehide', (event) => {
            if (event.persisted) stop();
        })

        play();
    }

    function stop() {
        if (!timer) return;
        window.clearTimeout(timer);
    }

    function play() {
        stop();
        timer = window.setTimeout(next, options.delay);
    }

    function destroy() {
        carousel.off('pointerDown', interaction);
        if (!options.stopOnInteraction) carousel.off('pointerUp', reset);
        stop();
        timer = 0;
    }

    function reset() {
        if (!timer) return;
        stop();
        play();
    }

    function next() {
        scrollNext(carousel.internalEngine(), null, options.speed);
        play();
    }

    const self = {
        name: 'autoplayMod',
        options: optionsHandler.merge(defaultOptions, userOptions),
        init,
        destroy,
        play,
        stop,
        reset
    }

    return self;
}

// see https://www.embla-carousel.com/examples/inspiration/#scale
// see https://codesandbox.io/s/embla-carousel-scale-vanilla-gc3b0

const calculateDiffToTarget = (embla) => {
    const engine = embla.internalEngine();
    const scrollProgress = embla.scrollProgress();

    return embla.scrollSnapList().map((scrollSnap, index) => {
        if (!embla.slidesInView().includes(index)) return 0;
        let diffToTarget = scrollSnap - scrollProgress;

        if (engine.options.loop) {
            engine.slideLooper.loopPoints.forEach((loopItem) => {
                const target = loopItem.target().get();
                if (index === loopItem.index && target !== 0) {
                    const sign = Math.sign(target);
                    if (sign === -1) diffToTarget = scrollSnap - (1 + scrollProgress);
                    if (sign === 1) diffToTarget = scrollSnap + (1 - scrollProgress);
                }
            });
        }
        return diffToTarget;
    });
};

const checkNumber = (number) => {
    let result = Math.min(Math.max(number, 0), 1);
    if ((result - 0.001) < 0) {
        result = 0
    } else if ((result + 0.001) > 1) {
        result = 1;
    };
    return result;
}

const scaleTransition = (diffToTarget, index, layers, transitionParam) => {
    const transform = checkNumber(1 - Math.abs(diffToTarget * transitionParam));
    layers[index].style.transform = `scale(${transform})`;
}

const parallaxTransition = (diffToTarget, index, layers, transitionParam) => {
    const PARALLAX_FACTOR = 0.75;
    const transform = checkNumber(diffToTarget * (-1 / transitionParam)) * 100;
    layers[index].style.transform = `translateX(${transform}%)`;
}

const slideTransition = (embla, transition, transitionParam) => {
    const slides = embla.slideNodes();
    const layers = slides.map((s) => s.querySelector(".slide-container"));
    const applyTransition = () => {
        const scaleTransforms = calculateDiffToTarget(embla);
        scaleTransforms.forEach((diffToTarget, index) => {
            transition(diffToTarget, index, layers, transitionParam);
        });
    };
    return applyTransition;
};

// for "logo" slider:
// check if all slides are in view, and if so stop autoplay and center the slides
const checkAutoplay = (embla, sliderBox, autoplay) => () => {
    if (autoplay) autoplay.stop();
    sliderBox.classList.remove('all-in-view');
    embla.scrollTo(0, true);
    const slides = embla.slidesNotInView().length;
    if (Mercury.debug()) console.info("Slider.checkAutoplay() Slides not in view: " + slides) ;
    if (slides > 0) {
        embla.reInit({active: true});
        if (autoplay) autoplay.play();
    } else {
        sliderBox.classList.add('all-in-view');
        embla.reInit({active: false});
    }
}

function initEmblaSliders(sliders) {

    sliders.forEach((slider) => {

        const sliderBox = slider.querySelector('.slider-box');
        const options = JSON.parse(sliderBox.dataset.slider);

        options.loop = true;
        options.align = 'start';
        options.speed = options.speed || 4;
        options.inViewThreshold = (options.type == 'logo' ? 0.75 : 0);

        let plugins = [EmblaClassNames({
            selected: 'slide-active',
            dragging: 'is-dragging', draggable: ''
        })];
        const autoplay = options.autoplay ? AutoplayMod({
            delay: options.delay,
            stopOnMouseEnter: options.pause,
            speed: options.speed
        }) : null;
        if (autoplay !=  null) {
            plugins.push(autoplay);
        }

        const embla = EmblaCarousel({root: sliderBox, container: sliderBox.querySelector('.slide-definitions')}, options, plugins);
        sliderBox.classList.add('slider-initialized');

        if (options.arrows) {
            const prevBtn = slider.querySelector(".prev-btn");
            const nextBtn = slider.querySelector(".next-btn");
            setupPrevNextBtns(prevBtn, nextBtn, embla, autoplay);
        }

        if (options.dots) {
            const dots = slider.querySelector(".slider-dots");
            const dotsArray = generateDotBtns(dots, embla);
            const setSelectedDotBtn = selectDotBtn(dotsArray, embla);
            setupDotBtns(dotsArray, embla, autoplay);
            embla
                .on("init", setSelectedDotBtn)
                .on("select", setSelectedDotBtn);
        }

        if (options.transition == 'scale' || options.transition == 'parallax') {
            const transitionParam = options.param || (options.transition == 'scale' ? 2.0 : 0.75);
            const applyTransition = slideTransition(embla, options.transition == 'scale' ? scaleTransition : parallaxTransition, transitionParam);
            embla
                .on("init", applyTransition)
                .on("scroll", applyTransition);
        } else if (options.transition == 'fade') {
            embla
                .on("init", function() { sliderBox.classList.add('slider-initialized') })
                .on("reInit", function() { sliderBox.classList.add('slider-initialized') })
                .on("resize", function() {
                    sliderBox.classList.remove('slider-initialized');
                    embla.reInit();
                });
        }

        if (options.type == 'logo') {
            const setAutoPlay = checkAutoplay(embla, sliderBox, autoplay);
            embla
                .on("init", setAutoPlay)
                .on("resize", setAutoPlay);
        }

        sliderBox.addEventListener('keydown', (event) => {
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

export function init() {

    if (Mercury.debug()) console.info("Slider.init()");

    let sliders = document.querySelectorAll('.use-embla-slider');
    if (Mercury.debug()) console.info("Slider.init() .use-embla-slider elements found: " + sliders.length);
    if (sliders.length > 0) {
        initEmblaSliders(sliders);
    }
}
