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


import WaveSurfer from 'wavesurfer.js';
import {Howl, Howler} from 'howler';
import tinycolor from 'tinycolor2';

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

function playAudio($audioData, afterPreview) {
    if (false) {
        initWaveSurfer($audioData, afterPreview);
    } else {
        initHowler($audioData, afterPreview);
    }
}

function initWaveSurfer($audioData, afterPreview) {

    var aP = afterPreview || false;

    $audioData.each(function(){

        var $audioElement = jQ(this);
        var data = $audioElement.data('audio') || {};

        var id = data.id;
        var src = data.src;
        var useMediaElement = data.mediael;
        var loadTxt = data.loadtxt;
        var autoplay = aP || data.autoplay;

        if (DEBUG) console.info("Audio: WaveSurfer init src=[" + src + "] - id=" + id);

        var ctx = document.createElement('canvas').getContext('2d');

        var themeCol = tinycolor(Mercury.getThemeJSON("main-theme", []));
        var themeGrad = ctx.createLinearGradient(0, 70, 0, 100);
        themeGrad.addColorStop(0.5, themeCol);
        themeGrad.addColorStop(0.5, themeCol.setAlpha(.5));

        var prevGrad = ctx.createLinearGradient(0, 70, 0, 100);
        prevGrad.addColorStop(0.5, '#666');
        prevGrad.addColorStop(0.5, '#ccc');

        var wavesurfer = WaveSurfer.create({
            container: document.querySelector('#' + id),
            waveColor: prevGrad,
            progressColor: themeGrad,
            barWidth: 2,
            cursorWidth: 0,
            height: 80,
            backend: useMediaElement ? 'MediaElement' : 'WebAudio',
            mediaControls: true,
            autoplay: autoplay
        });

        var $timer = $audioElement.find('.wave-time');
        var $progressBar = $audioElement.find('.wave-progress');
        var $progressBarPct = $progressBar.find('.progress-bar');
        var durationStr = '';

        if (useMediaElement) {
            var audioElement = $audioElement.find('audio').get(0);
            wavesurfer.load(audioElement);
        } else {
            wavesurfer.load(src);
        }

        wavesurfer.on('error', function(e) {
            console.warn(e);
        });

        wavesurfer.on('loading', function (percents) {
            var txt = loadTxt.replace('%percent', '' + percents + '%')
            $progressBarPct.width('' + percents + '%').attr('aria-valuenow', percents).text(txt);
        });

        wavesurfer.on(useMediaElement ? 'waveform-ready' : 'ready', function () {
            if (DEBUG) console.info('Audio ' + (useMediaElement ? 'waveform-ready' : 'ready') + '- id:' + id);
            $progressBar.hide();
            if (!useMediaElement && autoplay) {
                wavesurfer.play();
            }
        });

        wavesurfer.on('audioprocess', function () {
            $timer.text('' + formatTime(wavesurfer.getCurrentTime()) + ' / ' + formatTime(wavesurfer.getDuration()));
        });

        wavesurfer.on('interaction', function (param) {
             if (DEBUG) console.info("Audio interaction - param:" + param);
        });

        wavesurfer.on('seek', function (progress) {
             if (DEBUG) console.info("Audio seek - progress: " + progress);
        });

        var playButton = $audioElement.find('.btn-audio-play');
        playButton.on('click', wavesurfer.playPause.bind(wavesurfer));
    });
}

function initHowler($audioData, afterPreview) {

    var aP = afterPreview || false;

    $audioData.each(function(){

        var $audioElement = jQ(this);
        var data = $audioElement.data('audio') || {};

        var id = data.id;
        var src = data.src;
        var autoplay = aP || data.autoplay;

        if (DEBUG) console.info("Audio: Howler init src=[" + src + "] - id=" + id);

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
    DEBUG = true || debug;

    if (DEBUG) console.info("Audio.init()");

    var $audioData = jQ('[data-audio]');
    if (DEBUG) console.info("Audio [data-audio] elements found: " + $audioData.length);
    if ($audioData.length > 0) {
        playAudio($audioData, false);
    }
}

export function initAudio($element) {

    var $audioData = $element.find('[data-audio]');
    if ($audioData.length > 0) {
        playAudio($audioData, true);
    }
}