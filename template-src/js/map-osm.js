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

// Module implemented using the "revealing module pattern", see
// https://addyosmani.com/resources/essentialjsdesignpatterns/book/#revealingmodulepatternjavascript
// https://www.christianheilmann.com/2007/08/22/again-with-the-module-pattern-reveal-something-to-the-world/

import mapboxgl from 'mapbox-gl';

"use strict";

// the global objects that must be passed to this module
var jQ;
var DEBUG;

var m_style="";

// all initialized OpenStreetMaps
var m_maps = {};

// all map data sets found on the page, as array for easy iteration
var m_mapData = [];

// API key for accessing the map data
var m_apiKey;

// map styling
var m_mapStyle = [];

function shadeColor(color, percent) {

    var f=parseInt(color.slice(1),16),t=percent<0?0:255,p=percent<0?percent*-1:percent,R=f>>16,G=f>>8&0x00FF,B=f&0x0000FF;
    return "#"+(0x1000000+(Math.round((t-R)*p)+R)*0x10000+(Math.round((t-G)*p)+G)*0x100+(Math.round((t-B)*p)+B)).toString(16).slice(1);
}

function getPuempel(color) {

  var strokeColor=shadeColor(color,-0.4);
  return '<svg xmlns="http://www.w3.org/2000/svg" width="19" height="34" viewBox="-15 -34 19 34">' +
      '<path fill="#fff" d="M-9-28h7v7h-7z"/>' +
      '<path fill="' + color +
      '" stroke="' + strokeColor +
      '" d="M-5.5-33.4c-4.9 0-8.9 3.6-9 8.4 0 6.6 7.2 8.3 9 25 1.8-16.7 8.9-18.4 8.9-25 0-4.6-4-8.4-8.9-8.4zm0 6.4c1.4 0 2.6 1 2.7 2.5 0 1.5-1.2 2.7-2.7 2.7A2.7 2.7 0 0 1-8-24.5c0-1.4 1.2-2.4 2.5-2.5z"/>' +
      '</svg>'
}

function showSingleMap(mapData){
    m_maps[mapData.id] = new mapboxgl.Map({
        container: mapData.id,
        style: m_style,
        center: [parseFloat(mapData.centerLng), parseFloat(mapData.centerLat)],
        zoom: mapData.zoom,
        interactive: false
    });

    m_maps[mapData.id].on('mousedown', function (e) {
        this.scrollZoom.enable();
        this.dragPan.enable();
        this.touchZoomRotate.enable();
    });

    m_maps[mapData.id].on('click', function (e) {
        this.scrollZoom.enable();
        this.dragPan.enable();
        this.touchZoomRotate.enable();
    });

    m_maps[mapData.id].marker=[];
    var groups = {};
    var groupsFound = 0;

    if (typeof mapData.markers != "undefined") {
        for (var p=0; p < mapData.markers.length; p++) {
            var marker=mapData.markers[p];
            var group = decodeURIComponent(marker.group);
            if (typeof groups[group] === "undefined" ) {
                var color = Mercury.getThemeJSON("map-color[" + groupsFound++ + "]", "#ffffff");
                if (DEBUG) console.info("OSM new marker group added: " + group + " with color: " + color);
                groups[group] = getPuempel(color);
            }
            // create a HTML element for each feature
            var el = document.createElement('div');
            el.innerHTML = groups[group];
            var markerObject = new mapboxgl.Marker(el, {
                anchor: "bottom"
            });

            markerObject.setLngLat([parseFloat(marker.lng), parseFloat(marker.lat)]);
            if (decodeURIComponent(marker.info).length >0){
              markerObject.setPopup(new mapboxgl.Popup({ offset: [0, -25] }).setHTML(decodeURIComponent(marker.info)));
            }
            markerObject.addTo(m_maps[mapData.id]);
            markerObject.group=group;
            m_maps[mapData.id].marker.push(markerObject);
        }
    }

    m_maps[mapData.id].on('load', function () {
        this.addControl(new mapboxgl.NavigationControl());
    });
}

function showMaps(jQ, apiKey){

    for (var i=0; i < m_mapData.length; i++) {
        if(!m_mapData[i].hidden) {
            showSingleMap(m_mapData[i]);
        }
    }
}

function setStyle(jQ, apiKey, showMapFunction){

    if(m_style != ""){
        showMapFunction();
        return;
    }
    if (Mercury.hasInfo("osmStyleUrl")) {
        m_style = Mercury.getInfo("osmStyleUrl")
        showMapFunction();
    } else {
        jQ.getJSON("/system/modules/alkacon.mercury.template/osmviewer/style.json",function (data){
            data["sprite"]=window.location.protocol+"//"+window.location.host+Mercury.getInfo("osmSpriteUrl");
            var styleStr = JSON.stringify(data);
            m_style = JSON.parse(styleStr.replace(new RegExp("maptiler-api-key", 'g'),apiKey).replace(new RegExp('#b31b34','g'),Mercury.getThemeJSON("main-theme", [])));
            showMapFunction();
        });
    }
}

/****** Exported functions ******/

export function showMarkers(mapId, group){

    if (DEBUG) console.info("OSM showMapMarkers() called with id: " + mapId);
    var map = m_maps[mapId];
    if (map) {
        var markers = map.marker;
        var g = decodeURIComponent(group);

        for (var i = 0; i < markers.length; i++) {
            if (markers[i].group == g || g == 'showall') {
                markers[i].addTo(map);
            } else {
                markers[i].remove();
            }
        }
    }
}

function showMap(event){
    // called by click on hidden map element in edit mode

    if (DEBUG) console.info("OSM show map with id: "+ event.currentTarget.id);
    var mapToShow = event.currentTarget;
    for(var i=0; i<m_mapData.length; i++){
        if(m_mapData[i].id == mapToShow.id) {
            m_mapData[i].hidden = false;
            var mapData = m_mapData[i];
            setStyle(jQ, m_apiKey, function() {
                showSingleMap(mapData);
            });
        }
    }
}

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    m_apiKey = Mercury.getInfo("osmApiKey");

    if (DEBUG) {
        console.info("OSM.init()");
        if (m_apiKey != null) {
            console.info("OSM API key is: " + m_apiKey);
        } else {
            console.info("OSM API key not set - OSM maps not activated");
        }
    }

    var $mapElements = jQ('.map-osm .mapwindow');
    if (DEBUG) console.info("OSM .map-osm elements found: " + $mapElements.length);

    if ($mapElements.length > 0) {

        if (m_apiKey != null || Mercury.hasInfo("osmStyleUrl")) {

            // initialize map style from JSON stored in CSS
            m_mapStyle = Mercury.getThemeJSON("map-style", []);

            // initialize map sections with values from data attributes
            $mapElements.each(function() {
                var $mapElement = jQ(this);
                if (typeof $mapElement.data("map") != "undefined") {
                    var mapData = $mapElement.data("map");
                    if (mapData.hasOwnProperty("ratio")) {
                        var ratio = mapData.ratio;
                        var width = $mapElement.outerWidth();
                        var splits = ratio.split("-");
                        var wRatio = Number(splits[0]);
                        var hRatio = Number(splits[1]);
                        var factor = hRatio / wRatio;
                        var height = Math.round(width * factor);
                        if (DEBUG) console.info("mapData ratio:" + ratio + " wR=" + wRatio + " hR=" + hRatio + " width=" + width + " height=" + height);
                        $mapElement.outerHeight(height);
                    }
                    if(typeof mapData == "string") {
                        mapData = JSON.parse(mapData);
                    }
                    mapData.id = $mapElement.attr("id");
                    mapData.hidden = Mercury.isElementHidden($mapElement, showMap);
                    if (DEBUG) console.info("OSM map found with id: " + mapData.id);
                    m_mapData.push(mapData);
                    $mapElement.removeClass('placeholder');
                }
            });

            setStyle(jQ, m_apiKey, function() {
                showMaps(jQ, m_apiKey);
            });

        } else {

            // activate the hide message (no API key found)
            $mapElements.each(function() {
                var $mapElement = jQ(this);
                if (typeof $mapElement.data("map") != "undefined") {
                    Mercury.hideElement($mapElement);
                }
            });
        }
    }
}
