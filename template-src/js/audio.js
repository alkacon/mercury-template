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

import {Howl, Howler} from 'howler';

// the global objects that must be passed to this module
var jQ;
var DEBUG;

"use strict";

function formatTime(seconds) {

    var hours   = Math.floor(seconds / 3600);
    var minutes = Math.floor((seconds % 3600) / 60)
    var secs    = Math.floor(seconds % 60)

    if ((minutes < 10) && (hours > 0)) { minutes = "0" + minutes }
    if (secs < 10) { secs = "0" + secs }

    var result = minutes + ':' + secs;
    if (hours > 0) {
        result = hours + ':' + result;
    }

    return result;
}

function initAudio($audioData, aP) {

    aP = aP || false;

    $audioData.each(function(){

        var $audioElement = jQ(this);
        var data = $audioElement.data('audio') || {};

        var src = data.src;
        var autoplay = aP || (!Mercury.isEditMode() && data.autoplay);

        if (DEBUG) console.info("Audio: Howler init src=[" + src + "] autoplay=" + autoplay);

        var sound = new Howl({
            src: [src],
            autoplay: autoplay,
            preload: autoplay ? true : "metadata",
            html5: true
        });

        sound.$audiopos = $audioElement.find('.audio-pos');
        sound.$audiolength = $audioElement.find('.audio-length');

        sound.$progressBarWrapper = $audioElement.find('.audio-progress');
        sound.$progressBar = sound.$progressBarWrapper.find('.progress-bar');

        sound.$playPauseButton = $audioElement.find('.audio-play');
        sound.$playPauseButton.on('click', function(){
            if (sound.playing()) {
                sound.pause();
            } else {
                sound.play();
            }
        });

        sound.$stopButton = $audioElement.find('.audio-stop');
        sound.$stopButton.on('click', function(){
            sound.stop();
        });

        sound.$skipButton = $audioElement.find('.audio-skip');
        sound.$skipButton.on('click', function(){
            var seek = (sound.seek() || 0) + 15;
            if (DEBUG) console.info("Audio: Skip btn click seek=" + seek + " duration=" + sound.duration());
            if (seek < sound.duration()) {
                sound.seek(seek);
            } else {
                sound.stop();
            }
        });

        sound.$progressBarWrapper.on('click', function(event){
            var $bar = sound.$progressBarWrapper;
            var per = Math.round((event.pageX - $bar.offset().left) / $bar.innerWidth() * 1000.0) / 1000.0;
            if (DEBUG) console.info("Audio: Progessbar click per=" + per + " width=" + $bar.innerWidth() + " pageX=" + event.pageX + " offset=" + $bar.offset().left);
            sound.seek(sound.duration() * per);
        });

        sound.on('seek', function() {
            if (DEBUG) console.info("Audio: seek event for [" + src + "]");
            updateProgress(sound);
        });

        sound.on('play', function() {
            if (DEBUG) console.info("Audio: play event for [" + src + "]");
            sound.$playPauseButton.removeClass("fa-play").addClass("fa-pause");
            updateProgress(sound);
        });

        sound.on('pause', function() {
            if (DEBUG) console.info("Audio: pause event for [" + src + "]");
            sound.$playPauseButton.removeClass("fa-pause").addClass("fa-play");
            updateProgress(sound);
        });

        sound.on('load', function() {
            if (DEBUG) console.info("Audio: load event for [" + src + "]");
            sound.$audiolength.text('' + formatTime(sound.duration()));
            updateProgress(sound);
        });

        sound.on('stop', function() {
            if (DEBUG) console.info("Audio: stop event for [" + src + "]");
            sound.$playPauseButton.removeClass("fa-pause").addClass("fa-play");
            updateProgress(sound);
        });

        sound.on('end', function() {
            if (DEBUG) console.info("Audio: end event for [" + src + "]");
            sound.$playPauseButton.removeClass("fa-pause").addClass("fa-play");
            updateProgress(sound);
        });
    });
}

function updateProgress(sound) {

    var seek = sound.seek() || 0;
    sound.$audiopos.text('' + formatTime(Math.round(seek)));

    var percents = ((seek / sound.duration()) * 100.0) || 0;
    if (percents > 99.5) {
        // even a width of 99.9 will still leave a very visible space at the end of the bar
        percents = 100.0;
    }
    sound.$progressBar.width('' + percents + '%').attr('aria-valuenow', percents);

    // if the sound is still playing, continue updating the progress bar
    if (sound.playing()) {
        window.setTimeout(function() { updateProgress(sound) }, 25);
    }
}



/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("Audio.init()");

    Howler.unload();
}

export function initAudioElement($element, autoplay) {

    if (DEBUG) console.info("Audio.initAudio() autoplay=" + autoplay);

    var $audioData = $element.find('[data-audio]');
    if ($audioData.length > 0) {
        initAudio($audioData, autoplay);
    }
}