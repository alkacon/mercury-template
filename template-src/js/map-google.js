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

import tinycolor from 'tinycolor2';
import { MarkerClusterer } from "@googlemaps/markerclusterer";

// the global objects that must be passed to this module
var jQ;
var DEBUG;

"use strict";

// all initialized Google maps
var m_maps = {};

// all map data sets found on the page, as array for easy iteration
var m_mapData = [];

// all map data sets found on the page, as map for fast access
var m_mapDataMap = {};

// map styling
var m_mapStyle = [];

// map icons from SVGs
var m_svgIcons = [];

// API key for accessing the map data
var m_apiKey;

// the Google geocode object, used for resolving coordinates to address names
var m_googleGeocoder = null;

// check if the API has already been loaded
var m_googleApiLoaded = false;


function prepareExternalSVGs(markerConfig = [], svgIcons = []) {
    try {
        const filteredIconObjs = markerConfig.filter(mC => mC && mC.name && !svgIcons.some(icon => icon.name === mC.name));

        filteredIconObjs.forEach(mC => {
            let svgRaw = mC.icon || '';
            let viewBoxMatch = svgRaw.match(/viewBox="([^"]+)"/);
            let viewBox = viewBoxMatch ? viewBoxMatch[1] : '0 0 24 24';

            const cleaned = svgRaw
                .replace(/<svg[^>]*>/, '')
                .replace('</svg>', '')
                .replace(/stroke="[^"]*"/g, '')
                .replace(/fill="[^"]*"/g, '')
                .replace(/<([a-z]+)([^>]*)>/g, '<$1 fill="currentColor"$2>');

            svgIcons.push({
                name: mC.name,
                group: mC.group,
                box: mC.box,
                svg: cleaned,
                viewBox: viewBox
            });

        });
    } catch (error) {
        console.error("Error preparing external SVGs:", error);
    }
}

function getPuempel(color, name = null) {

    color = String(color);
    var strokeColor = String(tinycolor(color).darken(20));
    if (name != null) {
        const extSvg = m_svgIcons.find(icon => icon.name === name);
        let svgIcon = null;
        if (extSvg && extSvg.box) {
            const ol = false;
            const iconColor = tinycolor.mostReadable(color, ['#ffffff', '#000000']).toHexString();
            svgIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="34" viewBox="0 0 28 34" style="color:' + iconColor + ';">' +
                '<rect x="1" y="1" width="26" height="26" rx="5" ry="5" fill="' + color + (ol ? '" stroke="' + strokeColor + '" stroke-width="1"/>' : '"/>') +
                '<polygon points="10,27 14,34 18,27" fill="' + color + (ol ? '" stroke="' + strokeColor + '" stroke-width="1"/>' : '"/>') +
                (ol ? '<line x1="10.5" y1="26.8" x2="17.5" y2="26.8"' + '" stroke="' + color + '" stroke-width="1.4"/>' : '') +
                '<svg x="3" y="3" width="22" height="22" viewBox="' + extSvg.viewBox + '" preserveAspectRatio="xMidYMid meet">' +
                    extSvg.svg +
                '</svg>' +
            '</svg>';
        } else if (extSvg) {
            svgIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="' + extSvg.viewBox + '" preserveAspectRatio="xMidYMid meet" style="color:' + color + ';">' +
                extSvg.svg +
            '</svg>';
        }
        if (svgIcon != null) {
            return {
                url: "data:image/svg+xml;charset=UTF-8," + encodeURIComponent(svgIcon),
                scaledSize: new google.maps.Size(28, 34),
                anchor: new google.maps.Point(14, 34)
            }
        }
    }
    return {
        path: 'M0-37.06c-5.53 0-10 4.15-10 9.26 0 7.4 8 9.26 10 27.8 2-18.54 10-20.4 10-27.8 0-5.1-4.47-9.26-10-9.26zm.08 7a2.9 2.9 0 0 1 2.9 2.9 2.9 2.9 0 0 1-2.9 2.9 2.9 2.9 0 0 1-2.9-2.9 2.9 2.9 0 0 1 2.9-2.9z',
        scale: 1,
        fillOpacity: 1,
        fillColor: color,
        strokeColor: strokeColor,
        strokeWeight: 1
    };
}

function getCenterPointGraphic() {

    const color1 = Mercury.getThemeJSON("map-center", "#000000");
    const color2 = tinycolor(color1).darken(20);
    return {
        path: "M2,8a6,6 0 1,0 12,0a6,6 0 1,0 -12,0",
        scale: 1,
        fillColor: color1.toString(),
        fillOpacity: 1,
        strokeWeight: 1,
        strokeColor: color2.toString(),
        strokeOpacity: 1
    }
}

function getClusterGraphic(color, markerTitle) {

    color = color ? color : Mercury.getThemeJSON("map-cluster", "#999999");
    return {
        render: function({count, position}, stats) {
            const perceivedColor = tinycolor(color);
            const strokeColor = tinycolor(color).darken(20);
            const textColor = perceivedColor.isLight() ? tinycolor(color).darken(70) : tinycolor(color).lighten(70);
            const svg = window.btoa(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 50 50"><circle cx="25" cy="25" r="20" stroke="${strokeColor}" stroke-width="2" fill="${color}"/></svg>`);
            return new google.maps.Marker({
                title: markerTitle,
                position,
                icon: {
                    url: `data:image/svg+xml;base64,${svg}`,
                    scaledSize: new google.maps.Size(60, 60)
                },
                label: {
                    text: String(count),
                    color: textColor.toString(),
                    fontSize: "14px",
                    fontWeight: "normal"
                },
                zIndex: Number(google.maps.Marker.MAX_ZINDEX) + count,
            });
        }
    }
}

function showInfo(mapId, infoId) {

    if (DEBUG) console.info("GoogleMap showInfo() called with map id: " + mapId + " info id: " + infoId);
    var map = m_maps[mapId];
    var infoWindows = map.infoWindows;
    for (var i = 0; i < infoWindows.length; i++) {
        if (i != infoId) {
            infoWindows[i].close();
        } else {
            if (infoWindows[i].geocode == "true") {
                if (DEBUG) console.info("showInfo() geocode lookup for " + mapId);
                getGeocode(infoWindows[i]);
                infoWindows[i].geocode = "false";
            }
            infoWindows[i].open(
                map,
                infoWindows[i].marker
            );
        }
    }
}

function hideAllInfo(mapId) {

    if (DEBUG) console.info("GoogleMap hideAllInfo() called with map id: " + mapId);
    var map = m_maps[mapId];
    var infoWindows = map.infoWindows;
    for (var i = 0; i < infoWindows.length; i++) {
        infoWindows[i].close();
    }
}

function setInfo(results, status, infoWindow) {

    if (DEBUG) console.info("GoogleMap setInfo() geocode lookup returned status " + status);
    var addressFound = "";
    if (status == google.maps.GeocoderStatus.OK) {
        if (results[0]) {
            addressFound = formatGeocode(results[0]);
        }
    } else {
        console.warn("GoogleMap GeoCoder returned error status '" + status + "' for coordinates " + infoWindow.marker.position);
    }
    // replace content in info window
    var infoContent = infoWindow.getContent();
    infoContent = infoContent.replace("<!-- replace-with-geoadr -->", addressFound);
    infoWindow.setContent(infoContent);
}

function formatGeocode(result) {

    // returns the address from a geocode result in nicely formatted way
    var street = "";
    var strNum = "";
    var zip = "";
    var city = "";
    var foundAdr = false;

    for (var i = 0; i < result.address_components.length; i++) {
        var t = String(result.address_components[i].types);
        if (street == "" && t.indexOf("route") != -1) {
            street = result.address_components[i].long_name;
            foundAdr = true;
        }
        if (t.indexOf("street_number") != -1) {
            strNum = result.address_components[i].long_name;
            foundAdr = true;
        }
        if (t.indexOf("postal_code") != -1) {
            zip = result.address_components[i].long_name;
            foundAdr = true;
        }
        if (city == "" && t.indexOf("locality") != -1) {
            city = result.address_components[i].long_name;
            foundAdr = true;
        }
    }
    if (foundAdr == true) {
        return street + " " + strNum + "<br/>" + zip + " " + city;
    } else {
        return result.formatted_address;
    }
}

function getGeocode(infoWindow) {

    if (m_googleGeocoder == null) {
        // initialize global geocoder object if required
        m_googleGeocoder = new google.maps.Geocoder();
    }

    m_googleGeocoder.geocode({'latLng': infoWindow.marker.position}, function(results, status) {
        setInfo(results, status, infoWindow);
    });
}

function loadGoogleApi() {

    if (!m_googleApiLoaded) {
        var locale = Mercury.getInfo("locale");
        var mapKey = ""
        if (m_apiKey != null) {
            mapKey = "&key=" + m_apiKey;
        }
        var addLibs = "";
        if (!Mercury.isOnlineProject()) {
            // need to load places API for OpenCms map editor
            addLibs = "&libraries=places"
        }
        if (DEBUG) console.info("GoogleMap API key: " + (mapKey == '' ? '(undefined)' : mapKey));
        let response = jQ.loadScript("https://maps.google.com/maps/api/js?callback=GoogleMap.initGoogleMaps&loading=async&language=" + locale + addLibs + mapKey, {}, DEBUG);
        m_googleApiLoaded = true;
        return response;
    } else {
        initGoogleMaps();
    }
}

/****** Exported functions ******/

export function showMarkers(mapId, group) {

    if (DEBUG) console.info("GoogleMap showMapMarkers() called with map id: " + mapId);
    const map = m_maps[mapId];
    const mapData = m_mapData.find(md => md.id === mapId);
    if (map) {
        if (!mapData.markerCluster) {
            var markers = map.markers;
            var g = decodeURIComponent(group);
            hideAllInfo(mapId);
            for (var i = 0; i < markers.length; i++) {
                if (markers[i].group == g || g == 'showall') {
                    markers[i].setVisible(true);
                } else {
                    markers[i].setVisible(false);
                }
            }
        } else {
            hideAllInfo(mapId);
            showSingleMap(mapData, group);
        }
    }
}

function showSingleMap(mapData, filterByGroup){

    var mapId = mapData.id;

    if (DEBUG) console.info("GoogleMap initializing map: " + mapId);
    var mapOptions = {
        zoom: parseInt(mapData.zoom),
        styles: m_mapStyle,
        scrollwheel: false,
        mapTypeId: eval("google.maps.MapTypeId." + mapData.type),
        streetViewControl: false,
        mapTypeControlOptions: {
            style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
            mapTypeIds: new Array(
                google.maps.MapTypeId.ROADMAP,
                google.maps.MapTypeId.SATELLITE,
                google.maps.MapTypeId.HYBRID,
                google.maps.MapTypeId.TERRAIN
            )
        },
        center: new google.maps.LatLng(mapData.centerLat, mapData.centerLng),
        maxZoom: 18
    }

    var $typeParent = jQ("#" + mapData.id).closest("*[class*='type-map']");
    $typeParent.addClass("visible");

    // create the map
    var map = new google.maps.Map(document.getElementById(mapId), mapOptions);

    // enable mouse wheel scrolling after click
    google.maps.event.addListener(map, 'click', function(event){
        this.setOptions({scrollwheel:true});
    });

    // map markers and info windows
    var markers = [];
    var infoWindows = [];
    var groups = {};
    var groupsFound = 0;

    if (typeof mapData.markers !== "undefined") {
        let idx = 0;
        for (var p=0; p < mapData.markers.length; p++) {
            var point = mapData.markers[p];
            var group = point.group;
            if (group === "centerpoint") {
                if (DEBUG) console.info("GoogleMap new center point added.");
                groups[group] = getCenterPointGraphic();
            } else if (typeof groups[group] === "undefined" ) {
                let color = Mercury.getThemeJSON("map-color[" + groupsFound++ + "]", "#ffffff");
                let svgName = null;
                let customColor = color;
                if (Array.isArray(mapData.markerConfig)) {
                    const mC = mapData.markerConfig.find(icon => icon.group === group);
                    if (mC) {
                        svgName = mC.name ? mC.name : null;
                        customColor = mC.color ? mC.color : color;
                    }
                }
                if (DEBUG) console.info("GoogleMap new marker group added: " + group + " with color: " + customColor + (svgName == null ? "" : " icon: " + svgName));
                groups[group] = getPuempel(customColor, svgName);
            }
            if (!mapData.markerCluster || filterByGroup === undefined || filterByGroup == "showall" || decodeURIComponent(filterByGroup) == group) {
                // get marker data from calling object
                var marker = new google.maps.Marker({
                    position: new google.maps.LatLng(point.lat, point.lng),
                    map: map,
                    title: point.title,
                    group: group,
                    icon: groups[group],
                    info: point.info,
                    index: idx,
                    mapId: mapId,
                    geocode: point.geocode
                });

                // add marker to marker map
                markers.push(marker);

                // initialize info window
                var infoWindow = new google.maps.InfoWindow({
                    content: marker.info,
                    marker: marker,
                    geocode: point.geocode,
                    index: idx
                });

                // add marker to marker map
                infoWindows.push(infoWindow);

                if (DEBUG) console.info("GoogleMap attaching Event lister: " + p + " to map id " + mapId);

                // attach event listener that shows info window to marker
                // see http://you.arenot.me/2010/06/29/google-maps-api-v3-0-multiple-markers-multiple-infowindows/
                marker.addListener('click', function() {
                    showInfo(this.mapId, this.index);
                });
                idx++;
            }
        }
    }
    if (mapData.markerCluster) {
        new MarkerClusterer({markers: markers, map: map, renderer: getClusterGraphic(undefined, mapData.markerTitle)});
    }
    // store map in global array, required e.g. to select marker groups etc.
    var map = {
        'id': mapId,
        'map': map,
        'markers': markers,
        'infoWindows': infoWindows
    };
    m_maps[mapId] = map;
}

/**
 * Loads and displays a GeoJSON file.
 */
export function showGeoJson(mapId, geoJson, ajaxUrlMarkersInfo, count, geoJsonOthers) {

    count = count || 0; // needed for other map providers only
    if (DEBUG) console.info("Google update markers for map with id: " + mapId);
    let map;
    try {
        map = m_maps[mapId].map;
    } catch (e) {
        // map data may already be loaded but not the map
    }
    if (!map) { // no cookie consent yet
        return;
    }
    const mapData = m_mapDataMap[m_maps[mapId].id];
    const boundsNorthEast = {lat: null, lng: null};
    const boundSouthWest = {lat: null, lng: null};
    let checkBounds = function(coordinates) {
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
    let centerPoint;
    for (let md of m_mapData) {
        if (md.id === mapId && md.markers && md.markers.length > 0) {
            centerPoint = md;
        }
    }
    if (centerPoint) {
        checkBounds([map.getCenter().lng(), map.getCenter().lat()]); // bounding box includes the center point
    }
    let buildLayer = function(layerJson, others) {
        const features = layerJson.features || [];
        const markers = [];
        const featuresColor = others || !geoJsonOthers ? undefined : Mercury.getThemeJSON("map-center", "#000000");
        for (let i = 0; i < features.length; i++) {
            const feature = features[i];
            const coordinates = feature.geometry.coordinates;
            const infoCoordinates = feature.properties.coords;
            if (!others) {
                checkBounds(coordinates);
            }
            let color = featuresColor ? featuresColor : Mercury.getThemeJSON("map-color[0]", "#ffffff");
            let svgName = null;
            let customColor = color;
            if (Array.isArray(mapData.markerConfig)) {
                const mC = mapData.markerConfig.find(icon => icon.group === group);
                if (mC) {
                    svgName = mC.name ? mC.name : null;
                    customColor = mC.color ? mC.color : color;
                }
            }
            const marker = new google.maps.Marker({
                title: mapData.markerTitle,
                position: new google.maps.LatLng(coordinates[1], coordinates[0]),
                map: map,
                icon: getPuempel(customColor, svgName),
                zIndex: i
            });
            markers.push(marker);
            const infoWindow = new google.maps.InfoWindow({
                marker: marker,
                zIndex: i
            });
            marker.addListener("click", function() {
                if (m_maps[mapId].infoWindow) {
                    m_maps[mapId].infoWindow.close();
                }
                const ajaxUrl = ajaxUrlMarkersInfo + "&coordinates=" + infoCoordinates;
                fetch(ajaxUrl)
                    .then(response => response.text())
                    .then(data => {
                        infoWindow.setContent(data);
                        infoWindow.open(map, marker);
                    });
                m_maps[mapId].infoWindow = infoWindow;
            });
        }
        new MarkerClusterer({markers: markers, map: map, renderer: getClusterGraphic(featuresColor, mapData.markerTitle)});
    }
    if (geoJsonOthers) {
        buildLayer(geoJsonOthers, true);
    }
    buildLayer(geoJson);
    if (boundsNorthEast.lat) { // catch no center point and no features
        const bounds = new google.maps.LatLngBounds();
        bounds.extend(boundsNorthEast);
        bounds.extend(boundSouthWest);
        map.fitBounds(bounds);
    }
}

export function initGoogleMaps() {

    if (DEBUG) console.info("GoogleMap initGoogleMaps() called with data for " + m_mapData.length + " maps!" );
       for (var i=0; i < m_mapData.length; i++) {
         if(!m_mapData[i].showPlaceholder){
             showSingleMap(m_mapData[i]);
          }
       }
}

function showMap(event){

    // called by click on hidden map element in edit mode
    if (DEBUG) {console.log("GoogleMap show map with id: " + event.currentTarget.id);}
    var mapToShow= event.currentTarget;
    for(var i=0; i<m_mapData.length;i++){
        if(m_mapData[i].id == mapToShow.id){
            m_mapData[i].showPlaceholder=false;
            showSingleMap(m_mapData[i]);
        }
    }
    window.dispatchEvent(new CustomEvent("map-placeholder-click", {
        detail: GoogleMap
    }));
}

/****** Exported functions ******/

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    m_apiKey = Mercury.getInfo("googleApiKey");

    if (DEBUG) {
        console.info("GoogleMap.init()");
        if (m_apiKey != null) {
            // Goggle map key is read in mercury:pageinfo tag and read to JavaScript via Mercury.init()
            console.info("GoogleMap API key is: " + Mercury.getInfo("googleApiKey"));
        } else {
            console.info("GoogleMap API key not set - Google maps not activated");
        }
    }

    var $mapElements = jQ('.map-google .mapwindow');
    if (DEBUG) console.info("GoogleMap.init() .map-google elements found: " + $mapElements.length);

    if ($mapElements.length > 0) {

        if (m_apiKey != null) {

            if (PrivacyPolicy.cookiesAcceptedExternal()) {

                // initialize map style from JSON stored in CSS
                m_mapStyle = Mercury.getThemeJSON("map-style", []);

                // initialize map sections with values from data attributes
                $mapElements.each(function(){
                    var $mapElement = jQ(this);

                    if (typeof $mapElement.data("map") !== "undefined") {
                        var mapData = $mapElement.data("map");
                        if(typeof mapData === "string") {
                            mapData = JSON.parse(mapData);
                        }
                        mapData.id = $mapElement.attr("id");
                        mapData.showPlaceholder = Mercury.initPlaceholder($mapElement, showMap);
                        prepareExternalSVGs(mapData.markerConfig, m_svgIcons);
                        if (DEBUG) console.info("GoogleMap found with id: " + mapData.id);
                        m_mapData.push(mapData);
                        m_mapDataMap[mapData.id] = mapData;
                        if (! mapData.showPlaceholder) {
                            $mapElement.removeClass('placeholder');
                        }
                    }
                });

                // load the Google map API
                return loadGoogleApi();

            } else {
                if (DEBUG) console.info("External cookies not accepted by the user - Google maps are disabled!");
            }

        }
    }
}
