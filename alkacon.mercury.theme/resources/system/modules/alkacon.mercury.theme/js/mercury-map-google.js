(window.webpackJsonp=window.webpackJsonp||[]).push([[3],{28:function(module,__webpack_exports__,__webpack_require__){"use strict";var jQ,DEBUG;__webpack_require__.r(__webpack_exports__),__webpack_require__.d(__webpack_exports__,"showMarkers",function(){return showMarkers}),__webpack_require__.d(__webpack_exports__,"initGoogleMaps",function(){return initGoogleMaps}),__webpack_require__.d(__webpack_exports__,"init",function(){return init});var m_maps={},m_mapData=[],m_mapStyle=[],m_apiKey,m_googleGeocoder=null;function showInfo(o,e){DEBUG&&console.info("GoogleMap showInfo() called with map id: "+o+" info id: "+e);for(var a=m_maps[o],n=a.infoWindows,t=0;t<n.length;t++)t!=e?n[t].close():("true"==n[t].geocode&&(DEBUG&&console.info("showInfo() geocode lookup for "+o),getGeocode(n[t]),n[t].geocode="false"),n[t].open(a,n[t].marker))}function hideAllInfo(o){DEBUG&&console.info("GoogleMap hideAllInfo() called with map id: "+o);for(var e=m_maps[o].infoWindows,a=0;a<e.length;a++)e[a].close()}function setInfo(o,e,a){DEBUG&&console.info("GoogleMap setInfo() geocode lookup returned status "+e);var n="";e==google.maps.GeocoderStatus.OK?o[0]&&(n=formatGeocode(o[0])):console.warn("GoogleMap GeoCoder returned error status '"+e+"' for coordinates "+a.marker.position);var t=a.getContent();t=t.replace("<div class='geoAdr'></div>",n),a.setContent(t)}function formatGeocode(o){for(var e="",a="",n="",t="",r=!1,p=0;p<o.address_components.length;p++){var i=String(o.address_components[p].types);""==e&&-1!=i.indexOf("route")&&(e=o.address_components[p].long_name,r=!0),-1!=i.indexOf("street_number")&&(a=o.address_components[p].long_name,r=!0),-1!=i.indexOf("postal_code")&&(n=o.address_components[p].long_name,r=!0),""==t&&-1!=i.indexOf("locality")&&(t=o.address_components[p].long_name,r=!0)}return 1==r?e+" "+a+"<br/>"+n+" "+t:o.formatted_address}function getGeocode(o){null==m_googleGeocoder&&(m_googleGeocoder=new google.maps.Geocoder),m_googleGeocoder.geocode({latLng:o.marker.position},function(e,a){setInfo(e,a,o)})}function loadGoogleApi(){var o=Mercury.getInfo("locale"),e="";null!=m_apiKey&&(e="&key="+m_apiKey);var a="";Mercury.isOnlineProject()||(a="&libraries=places"),DEBUG&&console.info("GoogleMap API key: "+(""==e?"(undefined)":e)),jQ.loadScript("https://maps.google.com/maps/api/js?callback=GoogleMap.initGoogleMaps&language="+o+a+e,{},DEBUG)}function shadeColor(o,e){var a=parseInt(o.slice(1),16),n=e<0?0:255,t=e<0?-1*e:e,r=a>>16,p=a>>8&255,i=255&a;return"#"+(16777216+65536*(Math.round((n-r)*t)+r)+256*(Math.round((n-p)*t)+p)+(Math.round((n-i)*t)+i)).toString(16).slice(1)}function getPuempel(o){return{path:"M0-37.06c-5.53 0-10 4.15-10 9.26 0 7.4 8 9.26 10 27.8 2-18.54 10-20.4 10-27.8 0-5.1-4.47-9.26-10-9.26zm.08 7a2.9 2.9 0 0 1 2.9 2.9 2.9 2.9 0 0 1-2.9 2.9 2.9 2.9 0 0 1-2.9-2.9 2.9 2.9 0 0 1 2.9-2.9z",scale:1,fillOpacity:1,fillColor:o,strokeColor:shadeColor(o,-.4),strokeWeight:1}}function showMarkers(o,e){DEBUG&&console.info("GoogleMap showMapMarkers() called with map id: "+o);var a=m_maps[o];if(a){var n=a.markers,t=decodeURIComponent(e);hideAllInfo(o);for(var r=0;r<n.length;r++)n[r].group==t||"showall"==t?n[r].setVisible(!0):n[r].setVisible(!1)}}function showSingleMap(mapData){var mapId=mapData.id;DEBUG&&console.info("GoogleMap initializing map: "+mapId);var mapOptions={zoom:parseInt(mapData.zoom),styles:m_mapStyle,scrollwheel:!1,mapTypeId:eval("google.maps.MapTypeId."+mapData.type),streetViewControl:!1,mapTypeControlOptions:{style:google.maps.MapTypeControlStyle.DROPDOWN_MENU,mapTypeIds:new Array(google.maps.MapTypeId.ROADMAP,google.maps.MapTypeId.SATELLITE,google.maps.MapTypeId.HYBRID,google.maps.MapTypeId.TERRAIN)},center:new google.maps.LatLng(mapData.centerLat,mapData.centerLng)},map=new google.maps.Map(document.getElementById(mapId),mapOptions);google.maps.event.addListener(map,"click",function(o){this.setOptions({scrollwheel:!0})});var markers=[],infoWindows=[],groups={},groupsFound=0;if(void 0!==mapData.markers)for(var p=0;p<mapData.markers.length;p++){var point=mapData.markers[p],group=decodeURIComponent(point.group);if(void 0===groups[group]){var color=Mercury.getThemeJSON("map-color["+groupsFound+++"]","#ffffff");DEBUG&&console.info("GoogleMap new marker group added: "+group+" with color: "+color),groups[group]=getPuempel(color)}var marker=new google.maps.Marker({position:new google.maps.LatLng(point.lat,point.lng),map:map,title:decodeURIComponent(point.title),group:group,icon:groups[group],info:decodeURIComponent(point.info),index:p,mapId:mapId,geocode:point.geocode});markers.push(marker);var infoWindow=new google.maps.InfoWindow({content:marker.info,marker:marker,geocode:point.geocode,index:p});infoWindows.push(infoWindow),DEBUG&&console.info("GoogleMap attaching Event lister: "+p+" to map id "+mapId),marker.addListener("click",function(){showInfo(this.mapId,this.index)})}var map={id:mapId,map:map,markers:markers,infoWindows:infoWindows};m_maps[mapId]=map}function initGoogleMaps(){DEBUG&&console.info("GoogleMap initGoogleMaps() called with data for "+m_mapData.length+" maps!");for(var o=0;o<m_mapData.length;o++)m_mapData[o].hidden||showSingleMap(m_mapData[o])}function showMap(o){DEBUG&&console.log("GoogleMap show map with id: "+o.currentTarget.id);for(var e=o.currentTarget,a=0;a<m_mapData.length;a++)m_mapData[a].id==e.id&&(m_mapData[a].hidden=!1,showSingleMap(m_mapData[a]))}function init(o,e){jQ=o,DEBUG=e,m_apiKey=Mercury.getInfo("googleApiKey"),DEBUG&&(console.info("GoogleMap.init()"),null!=m_apiKey?console.info("GoogleMap API key is: "+Mercury.getInfo("googleApiKey")):console.info("GoogleMap API key not set - Google maps not activated"));var a=jQ(".map-google .mapwindow");DEBUG&&console.info("GoogleMap .map-google elements found: "+a.length),a.length>0&&(null!=m_apiKey?PrivacyPolicy.cookiesAccepted()?(m_mapStyle=Mercury.getThemeJSON("map-style",[]),a.each(function(){var o=jQ(this);if(void 0!==o.data("map")){var e=o.data("map");if(e.hasOwnProperty("ratio")){var a=e.ratio,n=o.outerWidth(),t=a.split("-"),r=Number(t[0]),p=Number(t[1]),i=p/r,l=Math.round(n*i);DEBUG&&console.info("mapData ratio:"+a+" wR="+r+" hR="+p+" width="+n+" height="+l),o.outerHeight(l)}e.id=o.attr("id"),e.hidden=Mercury.isElementHidden(o,showMap),DEBUG&&console.info("GoogleMap found with id: "+e.id),m_mapData.push(e),o.removeClass("placeholder")}}),loadGoogleApi()):(DEBUG&&console.info("GoogleMap cookies not accepted by the user - Google maps are disabled!"),a.each(function(){var o=jQ(this);o.removeClass("placeholder"),PrivacyPolicy.markDisabled(o)})):a.each(function(){var o=jQ(this);void 0!==o.data("map")&&Mercury.hideElement(o)}))}}}]);
//# sourceMappingURL=mercury-map-google.js.map