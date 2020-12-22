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

function initWaveForms($waveForms, afterPreview) {

    var aP = afterPreview || false;

    $waveForms.each(function(){

        var $waveForm = jQ(this);
        var data = $waveForm.data('waveform') || {};

        var id = data.id;
        var src = data.src;
        var useMediaElement = data.mediael;
        var loadTxt = data.loadtxt;
        var autoplay = aP || data.autoplay;

        if (DEBUG) console.info("WaveForm init - id:" + id);

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

        var $timer = $waveForm.find('.wave-time');
        var $progressBar = $waveForm.find('.wave-progress');
        var $progressBarPct = $progressBar.find('.progress-bar');
        var durationStr = '';

        if (useMediaElement) {
            var audioElement = $waveForm.find('audio').get(0);
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
            if (DEBUG) console.info('WaveForm ' + (useMediaElement ? 'waveform-ready' : 'ready') + '- id:' + id);
            $progressBar.hide();
            if (!useMediaElement && autoplay) {
                wavesurfer.play();
            }
        });

        wavesurfer.on('audioprocess', function () {
            $timer.text('' + formatTime(wavesurfer.getCurrentTime()) + ' / ' + formatTime(wavesurfer.getDuration()));
        });

        wavesurfer.on('interaction', function (param) {
             if (DEBUG) console.info("WaveForm interaction - param:" + param);
        });

        wavesurfer.on('seek', function (progress) {
             if (DEBUG) console.info("WaveForm seek - progress: " + progress);
        });

        var playButton = $waveForm.find('.btn-wave-play');
        playButton.on('click', wavesurfer.playPause.bind(wavesurfer));
    });
}

/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = true || debug;

    if (DEBUG) console.info("WaveForm.init()");

    var $waveForms = jQ('[data-waveform]');
    if (DEBUG) console.info("WaveForm [data-waveform] elements found: " + $waveForms.length);
    if ($waveForms.length > 0) {
        initWaveForms($waveForms, false);
    }
}


export function playWaveForm($element) {

    var $waveForm = $element.find('[data-waveform]');
    if ($waveForm.length > 0) {
        initWaveForms($waveForm, true);
    }
}