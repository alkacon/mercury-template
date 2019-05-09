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

// the global objects that must be passed to this module
var jQ;
var DEBUG;

"use strict";

// all initialized Google maps
var m_maps = {};

// all map data sets found on the page, as array for easy iteration
var m_mapData = [];

// map styling
var m_mapStyle = [];

// API key for accessing the map data
var m_apiKey;

// the Google geocode object, used for resolving coordinates to address names
var m_googleGeocoder = null;

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
    infoContent = infoContent.replace("<div class='geoAdr'></div>", addressFound);
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

    var locale = Mercury.getInfo("locale");
    var mapKey = ""
    if (m_apiKey != null) {
        mapKey = "&key=" + m_apiKey;
    }
    var addLibs = "";
    if (! Mercury.isOnlineProject()) {
        // need to load places API for OpenCms map editor
        addLibs = "&libraries=places"
    }
    if (DEBUG) console.info("GoogleMap API key: " + (mapKey == '' ? '(undefined)' : mapKey));
    jQ.loadScript("https://maps.google.com/maps/api/js?callback=GoogleMap.initGoogleMaps&language=" + locale + addLibs + mapKey, {}, DEBUG);
}


// See: https://stackoverflow.com/questions/5560248/programmatically-lighten-or-darken-a-hex-color-or-rgb-and-blend-colors
function shadeColor(color, percent) {

    var f=parseInt(color.slice(1),16),t=percent<0?0:255,p=percent<0?percent*-1:percent,R=f>>16,G=f>>8&0x00FF,B=f&0x0000FF;
    return "#"+(0x1000000+(Math.round((t-R)*p)+R)*0x10000+(Math.round((t-G)*p)+G)*0x100+(Math.round((t-B)*p)+B)).toString(16).slice(1);
}


function getPuempel(color) {

    var shade = shadeColor(color, -0.4);
    return {
        path: 'M0-37.06c-5.53 0-10 4.15-10 9.26 0 7.4 8 9.26 10 27.8 2-18.54 10-20.4 10-27.8 0-5.1-4.47-9.26-10-9.26zm.08 7a2.9 2.9 0 0 1 2.9 2.9 2.9 2.9 0 0 1-2.9 2.9 2.9 2.9 0 0 1-2.9-2.9 2.9 2.9 0 0 1 2.9-2.9z',
        scale: 1,
        fillOpacity: 1,
        fillColor: color,
        strokeColor: shade,
        strokeWeight: 1
    };
}

/****** Exported functions ******/

export function showMarkers(mapId, group) {

    if (DEBUG) console.info("GoogleMap showMapMarkers() called with map id: " + mapId);
    var map = m_maps[mapId];
    if (map) {
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
    }
}

function showSingleMap(mapData){

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
        center: new google.maps.LatLng(mapData.centerLat, mapData.centerLng)
    }

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

    if (typeof mapData.markers != "undefined") {
        for (var p=0; p < mapData.markers.length; p++) {

            var point = mapData.markers[p];
            var group = decodeURIComponent(point.group);
            if (typeof groups[group] === "undefined" ) {
                // Array? Object?
                // see http://stackoverflow.com/questions/9526860/why-does-a-string-index-in-a-javascript-array-not-increase-the-length-size
                var color = Mercury.getThemeJSON("map-color[" + groupsFound++ + "]", "#ffffff");
                if (DEBUG) console.info("GoogleMap new marker group added: " + group + " with color: " + color);
                groups[group] = getPuempel(color);
            }

            // get marker data from calling object
            var marker = new google.maps.Marker({
                position: new google.maps.LatLng(point.lat, point.lng),
                map: map,
                title: decodeURIComponent(point.title),
                group: group,
                icon: groups[group],
                info: decodeURIComponent(point.info),
                index: p,
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
                index: p
            });

            // add marker to marker map
            infoWindows.push(infoWindow);

            if (DEBUG) console.info("GoogleMap attaching Event lister: " + p + " to map id " + mapId);

            // attach event listener that shows info window to marker
            // see http://you.arenot.me/2010/06/29/google-maps-api-v3-0-multiple-markers-multiple-infowindows/
            marker.addListener('click', function() {
                showInfo(this.mapId, this.index);
            });
        }
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

export function initGoogleMaps() {

    if (DEBUG) console.info("GoogleMap initGoogleMaps() called with data for " + m_mapData.length + " maps!" );
       for (var i=0; i < m_mapData.length; i++) {
         if(!m_mapData[i].hidden){
             showSingleMap(m_mapData[i]);
          }
       }
}

function showMap(event){

    // called by click on hidden map element in edit mode
    if (DEBUG) {console.log("GoogleMap show map with id: "+event.currentTarget.id);}
    var mapToShow= event.currentTarget;

    for(var i=0; i<m_mapData.length;i++){
        if(m_mapData[i].id == mapToShow.id){
            m_mapData[i].hidden=false;
            showSingleMap(m_mapData[i]);
        }
    }
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
    if (DEBUG) console.info("GoogleMap .map-google elements found: " + $mapElements.length);

    if ($mapElements.length > 0) {

        if (m_apiKey != null) {

            if (PrivacyPolicy.cookiesAccepted()) {

                // initialize map style from JSON stored in CSS
                m_mapStyle = Mercury.getThemeJSON("map-style", []);

                // initialize map sections with values from data attributes
                $mapElements.each(function(){
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
                        mapData.id = $mapElement.attr("id");
                        mapData.hidden=Mercury.isElementHidden($mapElement, showMap);
                        if (DEBUG) console.info("GoogleMap found with id: " + mapData.id);
                        m_mapData.push(mapData);
                        $mapElement.removeClass('placeholder');
                    }
                });

                // load the Google map API
                loadGoogleApi();

            } else {
                if (DEBUG) console.info("GoogleMap cookies not accepted by the user - Google maps are disabled!");

                $mapElements.each(function() {
                    var $mapElement =  jQ(this);
                    $mapElement.removeClass('placeholder');
                    PrivacyPolicy.markDisabled($mapElement);
                });
            }

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
