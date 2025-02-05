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

// Max Zoom to use
const m_maxZoom = 18;
const m_clusterMaxZoom = 15;
const m_clusterRadius = 23;
const m_clusterCircleRadius = 24;
const m_fitBoundsOptions = {
    padding: {top: 100, bottom: 100, left: 100, right: 100},
    maxZoom: 12,
    maxDuration: 2000,
    curve: 2,
    speed: 2
}

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
    let color = Mercury.getThemeJSON("map-cluster", "#999999");
    const strokeColor = tinycolor(color).darken(20);
    return {
        'circle-color': color,
        'circle-radius': m_clusterCircleRadius,
        'circle-stroke-width': 2,
        'circle-stroke-color': strokeColor.toString()
    }
}

function getClusterGraphicTextColor() {
    let color = Mercury.getThemeJSON("map-cluster", "#999999");
    const perceivedColor = tinycolor(color);
    return perceivedColor.isLight() ? tinycolor(color).darken(70) : tinycolor(color).lighten(70);
}

function getFeaturesGraphic(imageId, color) {
    color = color === undefined ? Mercury.getThemeJSON("map-color[0]", "#ffffff") : color;
    const svg = window.btoa(getPuempel(color));
    const image = new Image(19, 34);
    image.src = `data:image/svg+xml;base64,${svg}`;
    image.id = "featuresGraphic" + imageId;
    image.style.display = "none";
    document.querySelector("body").appendChild(image);
    return document.getElementById(image.id);
}

function getOthersGraphic(imageId, color) {
    color = color === undefined ? Mercury.getThemeJSON("map-color[0]", "#ffffff") : color;
    const svg = window.btoa(getPuempel(color));
    const image = new Image(19, 34);
    image.src = `data:image/svg+xml;base64,${svg}`;
    image.id = "othersGraphic" + imageId;
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
            maxZoom: m_maxZoom,
            attributionControl: false
        });
        const attributionControl = new mapgl.AttributionControl({compact:true});
        m_maps[mapData.id].addControl(attributionControl);
        attributionControl._container.style.display = "none";
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
            attributionControl._toggleAttribution();
            attributionControl._container.style.display = "block";
        });
    }

    m_maps[mapData.id].marker=[];
    var groups = {};
    var groupsFound = 0;

    if (typeof mapData.markers !== "undefined") {
        for (var p=0; p < mapData.markers.length; p++) {
            var marker=mapData.markers[p];
            var group = marker.group;
            if (group != "hidden") {
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
                var markerObject = new mapgl.Marker({
                    anchor: "bottom",
                    element: el
                });
    
                markerObject.setLngLat([parseFloat(marker.lng), parseFloat(marker.lat)]);
                if (marker.info.length > 0){
                    markerObject.setPopup(new mapgl.Popup({ offset: [0, -25], maxWidth: '400px' }).setHTML(marker.info));
                }
                markerObject.addTo(m_maps[mapData.id]);
                markerObject.group=group;
                m_maps[mapData.id].marker.push(markerObject);
            }
        }
    }
}

function showSingleMapClustered(mapData, filterByGroup) {

    if (mapData.css) {
        Mercury.loadCss(mapData.css);
    }
    let map = m_maps[mapData.id];
    if (!map) {
        var $typeParent = jQ("#" + mapData.id).closest("*[class*='type-map']");
        $typeParent.addClass("visible");
        map = new mapgl.Map({
            container: mapData.id,
            style: m_style,
            maxZoom: m_maxZoom,
            attributionControl: false
        });
        const attributionControl = new mapgl.AttributionControl({compact:true});
        map.addControl(attributionControl);
        attributionControl._container.style.display = "none";
        map.on('mousedown', function (e) {
            this.scrollZoom.enable();
            this.dragPan.enable();
            this.touchZoomRotate.enable();
        });
        map.on('click', function (e) {
            this.scrollZoom.enable();
            this.dragPan.enable();
            this.touchZoomRotate.enable();
        });
        map.on("load", function () {
            this.addControl(new mapgl.NavigationControl());
            attributionControl._toggleAttribution();
            attributionControl._container.style.display = "block";
        });
        m_maps[mapData.id] = map;
    }
    map.marker=[];
    map.geojson={"type": "FeatureCollection", "features": []};
    var groups = {};
    var groupsFound = 0;
    const infos = new Map();
    if (typeof mapData.markers !== "undefined") {
        for (var p = 0; p < mapData.markers.length; p++) {
            var marker=mapData.markers[p];
            if (filterByGroup === undefined || filterByGroup == "showall" || decodeURIComponent(filterByGroup) == marker.group) {
                let feature = {
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [parseFloat(marker.lng), parseFloat(marker.lat)] },
                    "properties": {
                        "info": marker.info,
                        "group": marker.group
                    }
                };
                map.geojson.features.push(feature);
                var group = marker.group;
                if (group === "centerpoint") {
                    if (DEBUG) {
                        console.info("OSM new center point added.");
                    }
                    var el = document.createElement('div');
                    el.innerHTML = getCenterPointGraphic();
                    var markerObject = new mapgl.Marker(el, {
                        anchor: "bottom"
                    });
                    markerObject.setLngLat([parseFloat(marker.lng), parseFloat(marker.lat)]);
                    markerObject.addTo(map);
                    markerObject.group=group;
                    map.marker.push(markerObject);
                } else if (typeof groups[group] === "undefined" ) {
                    var color = Mercury.getThemeJSON("map-color[" + groupsFound++ + "]", "#ffffff");
                    if (DEBUG) console.info("OSM new marker group added: " + group + " with color: " + color);
                    groups[group] = getFeaturesGraphic(mapData.id + group, color);
                }
            }
        }
        map.groups = groups;
        let fitted = false;
        let bounds = getBoundsAndInfos(map.geojson.features || [], null, true, infos);
        if (map.loaded()) {
            map.getSource("localFeatures").setData(map.geojson);
            if (!fitted && map.geojson.features && map.geojson.features.length > 0) {
                map.fitBounds(bounds, m_fitBoundsOptions);
                fitted = true;
            }
        } else {
            map.on("styleimagemissing", function(event) {
                const key = event.id.substring("featuresGraphic".length);
                if (!map.hasImage(event.id) && groups[key]) {
                    map.addImage(event.id, groups[key]);
                }
            });
            map.on("load", function() {
                if (!map.getSource("localFeatures")) {
                    map.addSource("localFeatures", {
                        type: 'geojson',
                        data: map.geojson,
                        cluster: true,
                        clusterMaxZoom: m_clusterMaxZoom,
                        clusterRadius: m_clusterRadius
                    });
                }

                if (!map.getLayer("clusters")) {
                    map.addLayer({
                        id: "clusters",
                        type: "circle",
                        source: "localFeatures",
                        filter: ["has", "point_count"],
                        paint: getClusterGraphic()
                    });
                    map.on("mouseenter", "clusters", function () {
                        map.getCanvas().style.cursor = "pointer";
                    });
                    map.on("mouseleave", "clusters", function () {
                        map.getCanvas().style.cursor = "";
                    });
                    map.on("click", "clusters", async (e) => {
                        const features = map.queryRenderedFeatures(e.point, {
                            layers: ["clusters"]
                        });
                        const clusterId = features[0].properties.cluster_id;
                        const zoom = await map.getSource("localFeatures").getClusterExpansionZoom(clusterId);
                        map.easeTo({
                            center: features[0].geometry.coordinates,
                            zoom
                        });
                    });
                }

                for (let group in groups) {
                    if (!map.getLayer("unclustered-point-" + group)) {
                        map.addLayer({
                            id: "unclustered-point-" + group,
                            type: "symbol",
                            source: "localFeatures",
                            filter: ["==", "group", group],
                            layout: {
                                "icon-allow-overlap": true,
                                "icon-image": "featuresGraphic" + group,
                                "icon-anchor": "bottom"
                            }
                        }, "clusters");
                        map.on("click", "unclustered-point-" + group, function (e) {
                            const coordinates = e.features[0].geometry.coordinates.slice();
                            const info = e.features[0].properties.info;
                            const key = getKey(coordinates);
                            while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
                                coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
                            }
                            mapData.popup = new mapgl.Popup({ offset: [0, -25], maxWidth: '400px' });
                            mapData.popup.setLngLat(coordinates)
                                .setHTML(infos.get(key) ? infos.get(key) : info)
                                .addTo(map);
                        });
                        map.on("mouseenter", "unclustered-point-" + group, function () {
                            map.getCanvas().style.cursor = "pointer";
                        });
                        map.on("mouseleave", "unclustered-point-" + group, function () {
                            map.getCanvas().style.cursor = "";
                        });
                    }
                }

                if (!map.getLayer("cluster-count")) {
                    map.addLayer({
                        id: "cluster-count",
                        type: "symbol",
                        source: "localFeatures",
                        filter: ["has", "point_count"],
                        layout: {
                            "icon-allow-overlap": false,
                            "text-field": "{point_count_abbreviated}",
                            "text-size": 14
                        },
                        paint: {
                            "text-color": getClusterGraphicTextColor().toString(),
                        }
                    });
                }

                if (!fitted && map.geojson.features && map.geojson.features.length > 0) {
                    map.fitBounds(bounds, m_fitBoundsOptions);
                    fitted = true;
                }
            });
        }
    }
}

function showMaps(jQ, apiKey){

    for (var i=0; i < m_mapData.length; i++) {
        if(!m_mapData[i].showPlaceholder) {
            if (m_mapData[i].markerCluster) {
                showSingleMapClustered(m_mapData[i]);
            } else {
                showSingleMap(m_mapData[i]);
            }
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

function getBoundsAndInfos(features, centerPoint, getInfo, infos) {
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
    return [[boundSouthWest.lng,boundSouthWest.lat],[boundsNorthEast.lng,boundsNorthEast.lat]];
}

function buildMapLayer(map, source, ajaxUrlMarkersInfo, cluster) {

    const clusterLayer = source + "clusters";
    const clusterCountLayer = source + "cluster-count";
    const unclusteredPointLayer = source + "unclustered-point";
    const graphic = source + "Graphic";
    if (cluster) {
        map.addLayer({
            id: clusterLayer,
            type: "circle",
            source: source,
            filter: ["has", "point_count"],
            paint: getClusterGraphic()
        });
        map.addLayer({
            id: clusterCountLayer,
            type: "symbol",
            source: source,
            filter: ["has", "point_count"],
            layout: {
                "icon-allow-overlap": false,
                "text-field": "{point_count_abbreviated}",
                "text-size": 14
            },
            paint: {
                "text-color": getClusterGraphicTextColor().toString(),
            }
        });
    }
    map.addLayer({
        id: unclusteredPointLayer,
        type: "symbol",
        source: source,
        filter: ["!", ["has", "point_count"]],
        layout: {
            "icon-allow-overlap": true,
            "icon-image": graphic,
            "icon-anchor": "bottom"
        }
    });
    if (cluster) {
        map.on("click", clusterLayer, async (e) => {
            const features = map.queryRenderedFeatures(e.point, {
                layers: [clusterLayer]
            });
            const clusterId = features[0].properties.cluster_id;
            const zoom = await map.getSource(source).getClusterExpansionZoom(clusterId);
            map.easeTo({
                center: features[0].geometry.coordinates,
                zoom
            });
        });
    }
    map.on("click", unclusteredPointLayer, function (e) {
        const coordinates = e.features[0].geometry.coordinates;
        const infoCoordinates = e.features[0].properties.coords;
        const ajaxUrl = ajaxUrlMarkersInfo + "&coordinates=" + infoCoordinates;
        const popup = new mapgl.Popup({ offset: [0, -25], maxWidth: '400px' })
            .setLngLat(coordinates)
            .setHTML("<div></div>")
            .addTo(map);
        fetch(ajaxUrl)
            .then(response => response.text())
            .then(data => {
                popup.setHTML(data);
            });
    });
    if (cluster) {
        map.on("mouseenter", clusterLayer, function () {
            map.getCanvas().style.cursor = "pointer";
        });
        map.on("mouseleave", clusterLayer, function () {
            map.getCanvas().style.cursor = "";
        });
    }
    map.on("mouseenter", unclusteredPointLayer, function () {
        map.getCanvas().style.cursor = "pointer";
    });
    map.on("mouseleave", unclusteredPointLayer, function () {
        map.getCanvas().style.cursor = "";
    });
}

function getKey(coordinates) {
    let c0 = ("" + coordinates[0].toFixed(5));
    let c1 = ("" + coordinates[1].toFixed(5));
    return [c0, c1].join(",");
 }

/****** Exported functions ******/

export function showMarkers(mapId, group){

    if (DEBUG) console.info("OSM showMapMarkers() called with id: " + mapId);
    var map = m_maps[mapId];
    let mapData;
    for (let md of m_mapData) {
        if (md.id === mapId) {
            mapData = md;
        }
    }
    if (map) {
        if (!mapData.markerCluster) {
            var markers = map.marker;
            var g = decodeURIComponent(group);
            for (var i = 0; i < markers.length; i++) {
                if (markers[i].group == g || g == 'showall') {
                    markers[i].addTo(map);
                } else {
                    markers[i].remove();
                }
            }
        } else {
            if (mapData.popup) {
                mapData.popup.remove();
                mapData.popup = null;
            }
            showSingleMapClustered(mapData, group);
        }
    }
}

export function showGeoJson(mapId, geoJson, ajaxUrlMarkersInfo, count, geoJsonOthers) {

    count = count || 0;
    if (DEBUG && (count == 0)) console.info("OsmMap.showGeoJson() update markers for map id: " + mapId);
    const map = m_maps[mapId];
    if (!map || !map.isStyleLoaded()) {
        if (DEBUG) console.info("OsmMap.showGeoJson() waiting (" + count + ") for map id: " + mapId);
        if (count <= 10) {
            setTimeout(function() {
                showGeoJson(mapId, geoJson, ajaxUrlMarkersInfo, ++count, geoJsonOthers);
            }, 200);
        }
        return;
    }
    if (DEBUG && (count > 0)) console.info("OsmMap.showGeoJson() styles loaded, proceeding with map id: " + mapId);
    if (!map.hasImage("featuresGraphic")) {
        const centerPointColor = Mercury.getThemeJSON("map-center", "#000000");
        const featuresGraphic = getFeaturesGraphic(mapId, geoJsonOthers ? centerPointColor : undefined);
        featuresGraphic.addEventListener("load", function() {
            map.addImage("featuresGraphic", featuresGraphic);
        });
    }
    if (geoJsonOthers && !map.hasImage("othersGraphic")) {
        const othersGraphic = getOthersGraphic(mapId);
        othersGraphic.addEventListener("load", function() {
            map.addImage("othersGraphic", othersGraphic);
        });
    }
    map.addSource("features", {
        type: "geojson",
        data: geoJson,
        cluster: (geoJsonOthers ? false : true),
        clusterMaxZoom: m_clusterMaxZoom,
        clusterRadius: m_clusterRadius
    });
    if (geoJsonOthers) {
        map.addSource("others", {
            type: "geojson",
            data: geoJsonOthers,
            cluster: true,
            clusterMaxZoom: m_clusterMaxZoom,
            clusterRadius: m_clusterRadius
        });
    }
    let centerPoint;
    for (let md of m_mapData) {
        if (md.id === mapId && md.markers && md.markers.length > 0) {
            centerPoint = md;
        }
    }
    let bounds = getBoundsAndInfos(geoJson.features || [], (centerPoint ? [centerPoint.centerLng, centerPoint.centerLat] : null), false);
    let fitted = false;
    map.on("data", function() {
        if (!fitted && geoJson.features && geoJson.features.length > 0) {
            map.fitBounds(bounds, m_fitBoundsOptions);
            fitted = true;
        }
    });
    if (geoJsonOthers) {
        buildMapLayer(map, "others", ajaxUrlMarkersInfo, true);
    }
    buildMapLayer(map, "features", ajaxUrlMarkersInfo, false);
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
                mapData.markerCluster ? showSingleMapClustered(mapData) : showSingleMap(mapData);
            });
        }
    }
    window.dispatchEvent(new CustomEvent("map-placeholder-click", {
        detail: OsmMap
    }));
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
                        if (DEBUG) console.info("OsmMap.init() map found with id: " + mapData.id);
                        m_mapData.push(mapData);
                        if (!mapData.showPlaceholder) {
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
