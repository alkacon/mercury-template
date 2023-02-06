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

import mapgl from 'maplibre-gl';
import tinycolor from 'tinycolor2';

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

function getPuempel(color) {

  var strokeColor = tinycolor(color).darken(20);
  return '<svg xmlns="http://www.w3.org/2000/svg" width="19" height="34" viewBox="-15 -34 19 34">' +
      '<path fill="#fff" d="M-9-28h7v7h-7z"/>' +
      '<path fill="' + color +
      '" stroke="' + strokeColor +
      '" d="M-5.5-33.4c-4.9 0-8.9 3.6-9 8.4 0 6.6 7.2 8.3 9 25 1.8-16.7 8.9-18.4 8.9-25 0-4.6-4-8.4-8.9-8.4zm0 6.4c1.4 0 2.6 1 2.7 2.5 0 1.5-1.2 2.7-2.7 2.7A2.7 2.7 0 0 1-8-24.5c0-1.4 1.2-2.4 2.5-2.5z"/>' +
      '</svg>';
}

function getCenterPointGraphic() {
    const color1 = Mercury.getThemeJSON("map-center", "#000000");
    const color2 = tinycolor(color1).darken(20);
    return '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20">' +
        '<circle cx="8" cy="8" r="6" stroke="' + color2 + '" stroke-width="1" fill="' + color1 + '" />' +
        '</svg>';
}

function getClusterGraphic() {
    const color = Mercury.getThemeJSON("map-cluster", "#999999");
    const strokeColor = tinycolor(color).darken(20);
    return {
        'circle-color': color,
        'circle-radius': 20,
        'circle-stroke-width': 2,
        'circle-stroke-color': strokeColor.toString()
    }
}

function getClusterGraphicTextColor() {
    const color = Mercury.getThemeJSON("map-cluster", "#999999");
    const perceivedColor = tinycolor(color);
    return perceivedColor.isLight() ? tinycolor(color).darken(70) : tinycolor(color).lighten(70);
}

function getFeatureGraphic(mapId) {
    const color = Mercury.getThemeJSON("map-color[0]", "#ffffff");
    const svg = window.btoa(getPuempel(color));
    const image = new Image(19, 34);
    image.src = `data:image/svg+xml;base64,${svg}`;
    image.id = "featureGraphic" + mapId;
    image.style.display = "none";
    document.querySelector("body").appendChild(image);
    return document.getElementById(image.id);
}

function showSingleMap(mapData) {

    if (mapData.css) {
        Mercury.loadCss(mapData.css);
    }

    if (!m_maps[mapData.id]) {

        var $typeParent = jQ("#" + mapData.id).closest("*[class*='type-map']");
        $typeParent.addClass("visible");

        m_maps[mapData.id] = new mapgl.Map({
            container: mapData.id,
            style: m_style,
            center: [parseFloat(mapData.centerLng), parseFloat(mapData.centerLat)],
            zoom: mapData.zoom,
            interactive: false,
            maxZoom: 18
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

        m_maps[mapData.id].on('load', function () {
            this.addControl(new mapgl.NavigationControl());
        });
    }

    m_maps[mapData.id].marker=[];
    var groups = {};
    var groupsFound = 0;

    if (typeof mapData.markers !== "undefined") {
        for (var p=0; p < mapData.markers.length; p++) {
            var marker=mapData.markers[p];
            var group = marker.group;
            if (group === "centerpoint") {
                if (DEBUG) console.info("OSM new center point added.");
                groups[group] = getCenterPointGraphic();
            } else if (typeof groups[group] === "undefined" ) {
                var color = Mercury.getThemeJSON("map-color[" + groupsFound++ + "]", "#ffffff");
                if (DEBUG) console.info("OSM new marker group added: " + group + " with color: " + color);
                groups[group] = getPuempel(color);
            }
            // create a HTML element for each feature
            var el = document.createElement('div');
            el.innerHTML = groups[group];
            var markerObject = new mapgl.Marker(el, {
                anchor: "bottom"
            });

            markerObject.setLngLat([parseFloat(marker.lng), parseFloat(marker.lat)]);
            if (marker.info.length > 0 && group !== "centerpoint"){
                markerObject.setPopup(new mapgl.Popup({ offset: [0, -25], maxWidth: '400px' }).setHTML(marker.info));
            }
            markerObject.addTo(m_maps[mapData.id]);
            markerObject.group=group;
            m_maps[mapData.id].marker.push(markerObject);
        }
    }
}

function showMaps(jQ, apiKey){

    for (var i=0; i < m_mapData.length; i++) {
        if(!m_mapData[i].showPlaceholder) {
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
        jQ.getJSON(Mercury.addContext("/system/modules/alkacon.mercury.template/osmviewer/style.json"),function (data){
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

export function showGeoJson(mapId, geoJson) {

    if (DEBUG) console.info("OSM update markers for map with id: " + mapId);
    const map = m_maps[mapId];
    if (!map) { // no cookie consent yet
        return;
    }
    if (!map.hasImage("featureGraphic")) {
        const featureGraphic = getFeatureGraphic(mapId);
        featureGraphic.addEventListener("load", function() {
            map.addImage("featureGraphic", featureGraphic);
        });
    }
    map.addSource('features', {
        type: 'geojson',
        data: geoJson,
        cluster: true,
        clusterMaxZoom: 12,
        clusterRadius: 25
    });
    const infos = new Map();
    const getKey = function(coordinates) {
        let c0 = ("" + coordinates[0].toFixed(5));
        let c1 = ("" + coordinates[1].toFixed(5));
        return [c0, c1].join(",");
     }
    const getBoundsAndInfos = function(features, centerPoint, getInfo) {
        const boundsNorthEast = {lat: null, lng: null};
        const boundSouthWest = {lat: null, lng: null};
        const checkBounds = function(coordinates) {
            let lat = coordinates[1];
            let lng = coordinates[0];
            if (boundsNorthEast.lat === null || boundsNorthEast.lat < lat) {
                boundsNorthEast.lat = lat;
            }
            if (boundsNorthEast.lng === null || boundsNorthEast.lng < lng) {
                boundsNorthEast.lng = lng;
            }
            if (boundSouthWest.lat === null || boundSouthWest.lat > lat) {
                boundSouthWest.lat = lat;
            }
            if (boundSouthWest.lng === null || boundSouthWest.lng > lng) {
                boundSouthWest.lng = lng;
            }
        }
        if (centerPoint) {
            checkBounds(centerPoint);
        }
        for (let i = 0; i < features.length; i++) {
            const feature = features[i];
            const coordinates = feature.geometry.coordinates;
            const key = getKey(coordinates);
            if (getInfo === true) {
                const info = feature.properties.info;
                if (!infos.has(key)) {
                    infos.set(key, info);
                } else {
                    infos.set(key, info + infos.get(key));
                }
            }
            checkBounds(coordinates);
        }
        return [[boundsNorthEast.lng,boundsNorthEast.lat],[boundSouthWest.lng,boundSouthWest.lat]];
    }
    let centerPoint;
    for (let md of m_mapData) {
        if (md.id === mapId && md.markers && md.markers.length > 0) {
            centerPoint = md;
        }
    }
    let bounds = getBoundsAndInfos(geoJson.features || [], (centerPoint ? [centerPoint.centerLng, centerPoint.centerLat] : null), true);
    let fitted = false;
    map.on("data", function(event) {
        if (!fitted && geoJson.features && geoJson.features.length > 0) {
            map.fitBounds(bounds, {
                padding: {top: 100, bottom: 100, left: 100, right: 100}
            });
            fitted = true;
        }
    });
    map.addLayer({
        id: "clusters",
        type: "circle",
        source: "features",
        filter: ["has", "point_count"],
        paint: getClusterGraphic()
    });
    map.addLayer({
        id: "cluster-count",
        type: "symbol",
        source: "features",
        filter: ["has", "point_count"],
        layout: {
            "text-field": "{point_count_abbreviated}",
            "text-size": 14
        },
        paint: {
            "text-color": getClusterGraphicTextColor().toString(),
        }
    });
    map.addLayer({
        id: "unclustered-point",
        type: "symbol",
        source: "features",
        filter: ["!", ["has", "point_count"]],
        layout: {
            "icon-image": "featureGraphic",
            "icon-anchor": "bottom"
        }
    });
    map.on("click", "clusters", function (e) {
        const features = map.queryRenderedFeatures(e.point, {
            layers: ["clusters"]
        });
        const clusterId = features[0].properties.cluster_id;
        const pointCount = features[0].properties.point_count;
        map.getSource("features").getClusterLeaves(clusterId, pointCount, 0, function(error, clusterFeatures) {
            const bounds = getBoundsAndInfos(clusterFeatures);
            map.fitBounds(bounds, {
                padding: {top: 100, bottom: 100, left: 100, right: 100},
                maxZoom: 16
            });
        });

    });
    map.on("click", "unclustered-point", function (e) {
        const coordinates = e.features[0].geometry.coordinates.slice();
        const info = e.features[0].properties.info;
        const key = getKey(coordinates);
        while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
            coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
        }
        new mapgl.Popup({ offset: [0, -25], maxWidth: '400px' })
            .setLngLat(coordinates)
            .setHTML(infos.get(key) ? infos.get(key) : info)
            .addTo(map);
    });
    map.on("mouseenter", "clusters", function () {
        map.getCanvas().style.cursor = "pointer";
    });
    map.on("mouseleave", "clusters", function () {
        map.getCanvas().style.cursor = "";
    });
    map.on("mouseenter", "unclustered-point", function () {
        map.getCanvas().style.cursor = "pointer";
    });
    map.on("mouseleave", "unclustered-point", function () {
        map.getCanvas().style.cursor = "";
    });
}

function showMap(event){

    // called by click on hidden map element in edit mode
    if (DEBUG) console.info("OSM show map with id: "+ event.currentTarget.id);
    var mapToShow = event.currentTarget;
    for(var i=0; i<m_mapData.length; i++){
        if(m_mapData[i].id == mapToShow.id) {
            m_mapData[i].showPlaceholder = false;
            var mapData = m_mapData[i];
            setStyle(jQ, m_apiKey, function() {
                showSingleMap(mapData);
            });
        }
    }
}

function redrawMap(mapId, event) {

    // called if map is in a tab or accordion after being revealed
    var $parentElement;
    if (event.type == "shown.bs.tab") {
        var target = jQ(event.target).attr("data-bs-target");
        $parentElement = jQ(target);
    } else {
        // this should be an accordion
        $parentElement = jQ(event.target);
    }
    var $map = $parentElement.find('#' + mapId);
    if ($map.length > 0) {
        if (DEBUG) console.info("OSM redrawing map with id: " + mapId);
        if (typeof m_maps[mapId] !== "undefined") {
            m_maps[mapId].resize();
        }
    }
}

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    m_apiKey = Mercury.getInfo("osmApiKey");

    if (DEBUG) {
        console.info("OsmMap.init()");
        if (m_apiKey != null) {
            console.info("OsmMap.init() API key is: " + m_apiKey);
        } else {
            console.info("OsmMap.init() API key not set - OSM maps not activated");
        }
    }

    var $mapElements = jQ('.map-osm .mapwindow');
    if (DEBUG) console.info("OsmMap.init() .map-osm elements found: " + $mapElements.length);

    if ($mapElements.length > 0) {

        if (m_apiKey != null || Mercury.hasInfo("osmStyleUrl")) {

            if (PrivacyPolicy.cookiesAcceptedExternal()) {

                // initialize map sections with values from data attributes
                $mapElements.each(function() {
                    var $mapElement = jQ(this);
                    if (typeof $mapElement.data("map") !== "undefined") {
                        var mapData = $mapElement.data("map");
                        if(typeof mapData === "string") {
                            mapData = JSON.parse(mapData);
                        }
                        mapData.id = $mapElement.attr("id");
                        mapData.showPlaceholder = Mercury.initPlaceholder($mapElement, showMap);
                        if (DEBUG) console.info("OSM map found with id: " + mapData.id);
                        m_mapData.push(mapData);
                        if (! mapData.showPlaceholder) {
                            $mapElement.removeClass('placeholder');
                        }
                        // add redraw handler for maps hidden in accordions and tabs
                        Mercury.initTabAccordion($mapElement[0], function(event) { redrawMap(mapData.id, event) });
                    }
                });

                setStyle(jQ, m_apiKey, function() {
                    showMaps(jQ, m_apiKey);
                });

            } else {

                if (DEBUG) console.info("External cookies not accepted by the user - OSM / Open street maps are disabled!");
            }

        }
    }
}
