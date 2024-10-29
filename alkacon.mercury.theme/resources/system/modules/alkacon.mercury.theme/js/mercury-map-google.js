"use strict";(self.webpackChunkmercury_template=self.webpackChunkmercury_template||[]).push([[461],{111:function(e,t,o){o.d(t,{w1:function(){return b}});var r=o(17),s=o.n(r);const n=[Int8Array,Uint8Array,Uint8ClampedArray,Int16Array,Uint16Array,Int32Array,Uint32Array,Float32Array,Float64Array];class i{static from(e){if(!(e instanceof ArrayBuffer))throw new Error("Data must be an instance of ArrayBuffer.");const[t,o]=new Uint8Array(e,0,2);if(219!==t)throw new Error("Data does not appear to be in a KDBush format.");const r=o>>4;if(1!==r)throw new Error(`Got v${r} data when expected v1.`);const s=n[15&o];if(!s)throw new Error("Unrecognized array type.");const[a]=new Uint16Array(e,2,1),[l]=new Uint32Array(e,4,1);return new i(l,a,s,e)}constructor(e,t=64,o=Float64Array,r){if(isNaN(e)||e<0)throw new Error(`Unpexpected numItems value: ${e}.`);this.numItems=+e,this.nodeSize=Math.min(Math.max(+t,2),65535),this.ArrayType=o,this.IndexArrayType=e<65536?Uint16Array:Uint32Array;const s=n.indexOf(this.ArrayType),i=2*e*this.ArrayType.BYTES_PER_ELEMENT,a=e*this.IndexArrayType.BYTES_PER_ELEMENT,l=(8-a%8)%8;if(s<0)throw new Error(`Unexpected typed array class: ${o}.`);r&&r instanceof ArrayBuffer?(this.data=r,this.ids=new this.IndexArrayType(this.data,8,e),this.coords=new this.ArrayType(this.data,8+a+l,2*e),this._pos=2*e,this._finished=!0):(this.data=new ArrayBuffer(8+i+a+l),this.ids=new this.IndexArrayType(this.data,8,e),this.coords=new this.ArrayType(this.data,8+a+l,2*e),this._pos=0,this._finished=!1,new Uint8Array(this.data,0,2).set([219,16+s]),new Uint16Array(this.data,2,1)[0]=t,new Uint32Array(this.data,4,1)[0]=e)}add(e,t){const o=this._pos>>1;return this.ids[o]=o,this.coords[this._pos++]=e,this.coords[this._pos++]=t,o}finish(){const e=this._pos>>1;if(e!==this.numItems)throw new Error(`Added ${e} items when expected ${this.numItems}.`);return a(this.ids,this.coords,this.nodeSize,0,this.numItems-1,0),this._finished=!0,this}range(e,t,o,r){if(!this._finished)throw new Error("Data not yet indexed - call index.finish().");const{ids:s,coords:n,nodeSize:i}=this,a=[0,s.length-1,0],l=[];for(;a.length;){const p=a.pop()||0,c=a.pop()||0,h=a.pop()||0;if(c-h<=i){for(let i=h;i<=c;i++){const a=n[2*i],p=n[2*i+1];a>=e&&a<=o&&p>=t&&p<=r&&l.push(s[i])}continue}const m=h+c>>1,u=n[2*m],d=n[2*m+1];u>=e&&u<=o&&d>=t&&d<=r&&l.push(s[m]),(0===p?e<=u:t<=d)&&(a.push(h),a.push(m-1),a.push(1-p)),(0===p?o>=u:r>=d)&&(a.push(m+1),a.push(c),a.push(1-p))}return l}within(e,t,o){if(!this._finished)throw new Error("Data not yet indexed - call index.finish().");const{ids:r,coords:s,nodeSize:n}=this,i=[0,r.length-1,0],a=[],l=o*o;for(;i.length;){const p=i.pop()||0,c=i.pop()||0,m=i.pop()||0;if(c-m<=n){for(let o=m;o<=c;o++)h(s[2*o],s[2*o+1],e,t)<=l&&a.push(r[o]);continue}const u=m+c>>1,d=s[2*u],g=s[2*u+1];h(d,g,e,t)<=l&&a.push(r[u]),(0===p?e-o<=d:t-o<=g)&&(i.push(m),i.push(u-1),i.push(1-p)),(0===p?e+o>=d:t+o>=g)&&(i.push(u+1),i.push(c),i.push(1-p))}return a}}function a(e,t,o,r,s,n){if(s-r<=o)return;const i=r+s>>1;l(e,t,i,r,s,n),a(e,t,o,r,i-1,1-n),a(e,t,o,i+1,s,1-n)}function l(e,t,o,r,s,n){for(;s>r;){if(s-r>600){const i=s-r+1,a=o-r+1,p=Math.log(i),c=.5*Math.exp(2*p/3),h=.5*Math.sqrt(p*c*(i-c)/i)*(a-i/2<0?-1:1);l(e,t,o,Math.max(r,Math.floor(o-a*c/i+h)),Math.min(s,Math.floor(o+(i-a)*c/i+h)),n)}const i=t[2*o+n];let a=r,c=s;for(p(e,t,r,o),t[2*s+n]>i&&p(e,t,r,s);a<c;){for(p(e,t,a,c),a++,c--;t[2*a+n]<i;)a++;for(;t[2*c+n]>i;)c--}t[2*r+n]===i?p(e,t,r,c):(c++,p(e,t,c,s)),c<=o&&(r=c+1),o<=c&&(s=c-1)}}function p(e,t,o,r){c(e,o,r),c(t,2*o,2*r),c(t,2*o+1,2*r+1)}function c(e,t,o){const r=e[t];e[t]=e[o],e[o]=r}function h(e,t,o,r){const s=e-o,n=t-r;return s*s+n*n}const m={minZoom:0,maxZoom:16,minPoints:2,radius:40,extent:512,nodeSize:64,log:!1,generateId:!1,reduce:null,map:e=>e},u=Math.fround||(d=new Float32Array(1),e=>(d[0]=+e,d[0]));var d;class g{constructor(e){this.options=Object.assign(Object.create(m),e),this.trees=new Array(this.options.maxZoom+1),this.stride=this.options.reduce?7:6,this.clusterProps=[]}load(e){const{log:t,minZoom:o,maxZoom:r}=this.options;t&&console.time("total time");const s=`prepare ${e.length} points`;t&&console.time(s),this.points=e;const n=[];for(let t=0;t<e.length;t++){const o=e[t];if(!o.geometry)continue;const[r,s]=o.geometry.coordinates,i=u(w(r)),a=u(y(s));n.push(i,a,1/0,t,-1,1),this.options.reduce&&n.push(0)}let i=this.trees[r+1]=this._createTree(n);t&&console.timeEnd(s);for(let e=r;e>=o;e--){const o=+Date.now();i=this.trees[e]=this._createTree(this._cluster(i,e)),t&&console.log("z%d: %d clusters in %dms",e,i.numItems,+Date.now()-o)}return t&&console.timeEnd("total time"),this}getClusters(e,t){let o=((e[0]+180)%360+360)%360-180;const r=Math.max(-90,Math.min(90,e[1]));let s=180===e[2]?180:((e[2]+180)%360+360)%360-180;const n=Math.max(-90,Math.min(90,e[3]));if(e[2]-e[0]>=360)o=-180,s=180;else if(o>s){const e=this.getClusters([o,r,180,n],t),i=this.getClusters([-180,r,s,n],t);return e.concat(i)}const i=this.trees[this._limitZoom(t)],a=i.range(w(o),y(n),w(s),y(r)),l=i.data,p=[];for(const e of a){const t=this.stride*e;p.push(l[t+5]>1?f(l,t,this.clusterProps):this.points[l[t+3]])}return p}getChildren(e){const t=this._getOriginId(e),o=this._getOriginZoom(e),r="No cluster with the specified id.",s=this.trees[o];if(!s)throw new Error(r);const n=s.data;if(t*this.stride>=n.length)throw new Error(r);const i=this.options.radius/(this.options.extent*Math.pow(2,o-1)),a=n[t*this.stride],l=n[t*this.stride+1],p=s.within(a,l,i),c=[];for(const t of p){const o=t*this.stride;n[o+4]===e&&c.push(n[o+5]>1?f(n,o,this.clusterProps):this.points[n[o+3]])}if(0===c.length)throw new Error(r);return c}getLeaves(e,t,o){t=t||10,o=o||0;const r=[];return this._appendLeaves(r,e,t,o,0),r}getTile(e,t,o){const r=this.trees[this._limitZoom(e)],s=Math.pow(2,e),{extent:n,radius:i}=this.options,a=i/n,l=(o-a)/s,p=(o+1+a)/s,c={features:[]};return this._addTileFeatures(r.range((t-a)/s,l,(t+1+a)/s,p),r.data,t,o,s,c),0===t&&this._addTileFeatures(r.range(1-a/s,l,1,p),r.data,s,o,s,c),t===s-1&&this._addTileFeatures(r.range(0,l,a/s,p),r.data,-1,o,s,c),c.features.length?c:null}getClusterExpansionZoom(e){let t=this._getOriginZoom(e)-1;for(;t<=this.options.maxZoom;){const o=this.getChildren(e);if(t++,1!==o.length)break;e=o[0].properties.cluster_id}return t}_appendLeaves(e,t,o,r,s){const n=this.getChildren(t);for(const t of n){const n=t.properties;if(n&&n.cluster?s+n.point_count<=r?s+=n.point_count:s=this._appendLeaves(e,n.cluster_id,o,r,s):s<r?s++:e.push(t),e.length===o)break}return s}_createTree(e){const t=new i(e.length/this.stride|0,this.options.nodeSize,Float32Array);for(let o=0;o<e.length;o+=this.stride)t.add(e[o],e[o+1]);return t.finish(),t.data=e,t}_addTileFeatures(e,t,o,r,s,n){for(const i of e){const e=i*this.stride,a=t[e+5]>1;let l,p,c;if(a)l=_(t,e,this.clusterProps),p=t[e],c=t[e+1];else{const o=this.points[t[e+3]];l=o.properties;const[r,s]=o.geometry.coordinates;p=w(r),c=y(s)}const h={type:1,geometry:[[Math.round(this.options.extent*(p*s-o)),Math.round(this.options.extent*(c*s-r))]],tags:l};let m;m=a||this.options.generateId?t[e+3]:this.points[t[e+3]].id,void 0!==m&&(h.id=m),n.features.push(h)}}_limitZoom(e){return Math.max(this.options.minZoom,Math.min(Math.floor(+e),this.options.maxZoom+1))}_cluster(e,t){const{radius:o,extent:r,reduce:s,minPoints:n}=this.options,i=o/(r*Math.pow(2,t)),a=e.data,l=[],p=this.stride;for(let o=0;o<a.length;o+=p){if(a[o+2]<=t)continue;a[o+2]=t;const r=a[o],c=a[o+1],h=e.within(a[o],a[o+1],i),m=a[o+5];let u=m;for(const e of h){const o=e*p;a[o+2]>t&&(u+=a[o+5])}if(u>m&&u>=n){let e,n=r*m,i=c*m,d=-1;const g=(o/p<<5)+(t+1)+this.points.length;for(const r of h){const l=r*p;if(a[l+2]<=t)continue;a[l+2]=t;const c=a[l+5];n+=a[l]*c,i+=a[l+1]*c,a[l+4]=g,s&&(e||(e=this._map(a,o,!0),d=this.clusterProps.length,this.clusterProps.push(e)),s(e,this._map(a,l)))}a[o+4]=g,l.push(n/u,i/u,1/0,g,-1,u),s&&l.push(d)}else{for(let e=0;e<p;e++)l.push(a[o+e]);if(u>1)for(const e of h){const o=e*p;if(!(a[o+2]<=t)){a[o+2]=t;for(let e=0;e<p;e++)l.push(a[o+e])}}}}return l}_getOriginId(e){return e-this.points.length>>5}_getOriginZoom(e){return(e-this.points.length)%32}_map(e,t,o){if(e[t+5]>1){const r=this.clusterProps[e[t+6]];return o?Object.assign({},r):r}const r=this.points[e[t+3]].properties,s=this.options.map(r);return o&&s===r?Object.assign({},s):s}}function f(e,t,o){return{type:"Feature",id:e[t+3],properties:_(e,t,o),geometry:{type:"Point",coordinates:[(r=e[t],360*(r-.5)),k(e[t+1])]}};var r}function _(e,t,o){const r=e[t+5],s=r>=1e4?`${Math.round(r/1e3)}k`:r>=1e3?Math.round(r/100)/10+"k":r,n=e[t+6],i=-1===n?{}:Object.assign({},o[n]);return Object.assign(i,{cluster:!0,cluster_id:e[t+3],point_count:r,point_count_abbreviated:s})}function w(e){return e/360+.5}function y(e){const t=Math.sin(e*Math.PI/180),o=.5-.25*Math.log((1+t)/(1-t))/Math.PI;return o<0?0:o>1?1:o}function k(e){const t=(180-360*e)*Math.PI/180;return 360*Math.atan(Math.exp(t))/Math.PI-90}
/*! *****************************************************************************
Copyright (c) Microsoft Corporation.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
***************************************************************************** */
function M(e,t){var o={};for(var r in e)Object.prototype.hasOwnProperty.call(e,r)&&t.indexOf(r)<0&&(o[r]=e[r]);if(null!=e&&"function"==typeof Object.getOwnPropertySymbols){var s=0;for(r=Object.getOwnPropertySymbols(e);s<r.length;s++)t.indexOf(r[s])<0&&Object.prototype.propertyIsEnumerable.call(e,r[s])&&(o[r[s]]=e[r[s]])}return o}class E{static isAdvancedMarkerAvailable(e){return google.maps.marker&&!0===e.getMapCapabilities().isAdvancedMarkersAvailable}static isAdvancedMarker(e){return google.maps.marker&&e instanceof google.maps.marker.AdvancedMarkerElement}static setMap(e,t){this.isAdvancedMarker(e)?e.map=t:e.setMap(t)}static getPosition(e){if(this.isAdvancedMarker(e)){if(e.position){if(e.position instanceof google.maps.LatLng)return e.position;if(e.position.lat&&e.position.lng)return new google.maps.LatLng(e.position.lat,e.position.lng)}return new google.maps.LatLng(null)}return e.getPosition()}static getVisible(e){return!!this.isAdvancedMarker(e)||e.getVisible()}}class v{constructor({markers:e,position:t}){this.markers=e,t&&(t instanceof google.maps.LatLng?this._position=t:this._position=new google.maps.LatLng(t))}get bounds(){if(0===this.markers.length&&!this._position)return;const e=new google.maps.LatLngBounds(this._position,this._position);for(const t of this.markers)e.extend(E.getPosition(t));return e}get position(){return this._position||this.bounds.getCenter()}get count(){return this.markers.filter((e=>E.getVisible(e))).length}push(e){this.markers.push(e)}delete(){this.marker&&(E.setMap(this.marker,null),this.marker=void 0),this.markers.length=0}}class x{constructor({maxZoom:e=16}){this.maxZoom=e}noop({markers:e}){return A(e)}}const A=e=>e.map((e=>new v({position:E.getPosition(e),markers:[e]})));class I extends x{constructor(e){var{maxZoom:t,radius:o=60}=e,r=M(e,["maxZoom","radius"]);super({maxZoom:t}),this.state={zoom:-1},this.superCluster=new g(Object.assign({maxZoom:this.maxZoom,radius:o},r))}calculate(e){let t=!1;const o={zoom:e.map.getZoom()};if(!s()(e.markers,this.markers)){t=!0,this.markers=[...e.markers];const o=this.markers.map((e=>{const t=E.getPosition(e);return{type:"Feature",geometry:{type:"Point",coordinates:[t.lng(),t.lat()]},properties:{marker:e}}}));this.superCluster.load(o)}return t||(this.state.zoom<=this.maxZoom||o.zoom<=this.maxZoom)&&(t=!s()(this.state,o)),this.state=o,t&&(this.clusters=this.cluster(e)),{clusters:this.clusters,changed:t}}cluster({map:e}){return this.superCluster.getClusters([-180,-90,180,90],Math.round(e.getZoom())).map((e=>this.transformCluster(e)))}transformCluster({geometry:{coordinates:[e,t]},properties:o}){if(o.cluster)return new v({markers:this.superCluster.getLeaves(o.cluster_id,1/0).map((e=>e.properties.marker)),position:{lat:t,lng:e}});const r=o.marker;return new v({markers:[r],position:E.getPosition(r)})}}class G{constructor(e,t){this.markers={sum:e.length};const o=t.map((e=>e.count)),r=o.reduce(((e,t)=>e+t),0);this.clusters={count:t.length,markers:{mean:r/t.length,sum:r,min:Math.min(...o),max:Math.max(...o)}}}}class D{render({count:e,position:t},o,r){const s=`<svg fill="${e>Math.max(10,o.clusters.markers.mean)?"#ff0000":"#0000ff"}" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240" width="50" height="50">\n<circle cx="120" cy="120" opacity=".6" r="70" />\n<circle cx="120" cy="120" opacity=".3" r="90" />\n<circle cx="120" cy="120" opacity=".2" r="110" />\n<text x="50%" y="50%" style="fill:#fff" text-anchor="middle" font-size="50" dominant-baseline="middle" font-family="roboto,arial,sans-serif">${e}</text>\n</svg>`,n=`Cluster of ${e} markers`,i=Number(google.maps.Marker.MAX_ZINDEX)+e;if(E.isAdvancedMarkerAvailable(r)){const e=(new DOMParser).parseFromString(s,"image/svg+xml").documentElement;e.setAttribute("transform","translate(0 25)");const o={map:r,position:t,zIndex:i,title:n,content:e};return new google.maps.marker.AdvancedMarkerElement(o)}const a={position:t,zIndex:i,title:n,icon:{url:`data:image/svg+xml;base64,${btoa(s)}`,anchor:new google.maps.Point(25,25)}};return new google.maps.Marker(a)}}class O{constructor(){!function(e,t){for(let o in t.prototype)e.prototype[o]=t.prototype[o]}(O,google.maps.OverlayView)}}var C;!function(e){e.CLUSTERING_BEGIN="clusteringbegin",e.CLUSTERING_END="clusteringend",e.CLUSTER_CLICK="click"}(C||(C={}));const P=(e,t,o)=>{o.fitBounds(t.bounds)};class b extends O{constructor({map:e,markers:t=[],algorithmOptions:o={},algorithm:r=new I(o),renderer:s=new D,onClusterClick:n=P}){super(),this.markers=[...t],this.clusters=[],this.algorithm=r,this.renderer=s,this.onClusterClick=n,e&&this.setMap(e)}addMarker(e,t){this.markers.includes(e)||(this.markers.push(e),t||this.render())}addMarkers(e,t){e.forEach((e=>{this.addMarker(e,!0)})),t||this.render()}removeMarker(e,t){const o=this.markers.indexOf(e);return-1!==o&&(E.setMap(e,null),this.markers.splice(o,1),t||this.render(),!0)}removeMarkers(e,t){let o=!1;return e.forEach((e=>{o=this.removeMarker(e,!0)||o})),o&&!t&&this.render(),o}clearMarkers(e){this.markers.length=0,e||this.render()}render(){const e=this.getMap();if(e instanceof google.maps.Map&&e.getProjection()){google.maps.event.trigger(this,C.CLUSTERING_BEGIN,this);const{clusters:t,changed:o}=this.algorithm.calculate({markers:this.markers,map:e,mapCanvasProjection:this.getProjection()});if(o||null==o){const e=new Set;for(const o of t)1==o.markers.length&&e.add(o.markers[0]);const o=[];for(const t of this.clusters)null!=t.marker&&(1==t.markers.length?e.has(t.marker)||E.setMap(t.marker,null):o.push(t.marker));this.clusters=t,this.renderClusters(),requestAnimationFrame((()=>o.forEach((e=>E.setMap(e,null)))))}google.maps.event.trigger(this,C.CLUSTERING_END,this)}}onAdd(){this.idleListener=this.getMap().addListener("idle",this.render.bind(this)),this.render()}onRemove(){google.maps.event.removeListener(this.idleListener),this.reset()}reset(){this.markers.forEach((e=>E.setMap(e,null))),this.clusters.forEach((e=>e.delete())),this.clusters=[]}renderClusters(){const e=new G(this.markers,this.clusters),t=this.getMap();this.clusters.forEach((o=>{1===o.markers.length?o.marker=o.markers[0]:(o.marker=this.renderer.render(o,e,t),o.markers.forEach((e=>E.setMap(e,null))),this.onClusterClick&&o.marker.addListener("click",(e=>{google.maps.event.trigger(this,C.CLUSTER_CLICK,o),this.onClusterClick(e,o,t)}))),E.setMap(o.marker,t)}))}}},17:function(e){e.exports=function e(t,o){if(t===o)return!0;if(t&&o&&"object"==typeof t&&"object"==typeof o){if(t.constructor!==o.constructor)return!1;var r,s,n;if(Array.isArray(t)){if((r=t.length)!=o.length)return!1;for(s=r;0!=s--;)if(!e(t[s],o[s]))return!1;return!0}if(t.constructor===RegExp)return t.source===o.source&&t.flags===o.flags;if(t.valueOf!==Object.prototype.valueOf)return t.valueOf()===o.valueOf();if(t.toString!==Object.prototype.toString)return t.toString()===o.toString();if((r=(n=Object.keys(t)).length)!==Object.keys(o).length)return!1;for(s=r;0!=s--;)if(!Object.prototype.hasOwnProperty.call(o,n[s]))return!1;for(s=r;0!=s--;){var i=n[s];if(!e(t[i],o[i]))return!1}return!0}return t!=t&&o!=o}},9:function(__unused_webpack_module,__webpack_exports__,__webpack_require__){__webpack_require__.r(__webpack_exports__),__webpack_require__.d(__webpack_exports__,{init:function(){return init},initGoogleMaps:function(){return initGoogleMaps},showGeoJson:function(){return showGeoJson},showMarkers:function(){return showMarkers}});var tinycolor2__WEBPACK_IMPORTED_MODULE_0__=__webpack_require__(140),_googlemaps_markerclusterer__WEBPACK_IMPORTED_MODULE_1__=__webpack_require__(111),jQ,DEBUG,m_maps={},m_mapData=[],m_mapStyle=[],m_apiKey,m_googleGeocoder=null,m_googleApiLoaded=!1;function getPuempel(e){return{path:"M0-37.06c-5.53 0-10 4.15-10 9.26 0 7.4 8 9.26 10 27.8 2-18.54 10-20.4 10-27.8 0-5.1-4.47-9.26-10-9.26zm.08 7a2.9 2.9 0 0 1 2.9 2.9 2.9 2.9 0 0 1-2.9 2.9 2.9 2.9 0 0 1-2.9-2.9 2.9 2.9 0 0 1 2.9-2.9z",scale:1,fillOpacity:1,fillColor:e,strokeColor:""+(0,tinycolor2__WEBPACK_IMPORTED_MODULE_0__.A)(e).darken(20),strokeWeight:1}}function getFeatureGraphic(){return getPuempel(Mercury.getThemeJSON("map-color[0]","#ffffff"))}function getCenterPointGraphic(){const e=Mercury.getThemeJSON("map-center","#000000"),t=(0,tinycolor2__WEBPACK_IMPORTED_MODULE_0__.A)(e).darken(20);return{path:"M2,8a6,6 0 1,0 12,0a6,6 0 1,0 -12,0",scale:1,fillColor:e.toString(),fillOpacity:1,strokeWeight:1,strokeColor:t.toString(),strokeOpacity:1}}function getClusterGraphic(){return{render:function({count:e,position:t},o){const r=Mercury.getThemeJSON("map-cluster","#999999"),s=(0,tinycolor2__WEBPACK_IMPORTED_MODULE_0__.A)(r),n=(0,tinycolor2__WEBPACK_IMPORTED_MODULE_0__.A)(r).darken(20),i=s.isLight()?(0,tinycolor2__WEBPACK_IMPORTED_MODULE_0__.A)(r).darken(70):(0,tinycolor2__WEBPACK_IMPORTED_MODULE_0__.A)(r).lighten(70),a=window.btoa(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 50 50"><circle cx="25" cy="25" r="20" stroke="${n}" stroke-width="2" fill="${r}"/></svg>`);return new google.maps.Marker({position:t,icon:{url:`data:image/svg+xml;base64,${a}`,scaledSize:new google.maps.Size(60,60)},label:{text:String(e),color:i.toString(),fontSize:"14px",fontWeight:"normal"},zIndex:Number(google.maps.Marker.MAX_ZINDEX)+e})}}}function showInfo(e,t){DEBUG&&console.info("GoogleMap showInfo() called with map id: "+e+" info id: "+t);for(var o=m_maps[e],r=o.infoWindows,s=0;s<r.length;s++)s!=t?r[s].close():("true"==r[s].geocode&&(DEBUG&&console.info("showInfo() geocode lookup for "+e),getGeocode(r[s]),r[s].geocode="false"),r[s].open(o,r[s].marker))}function hideAllInfo(e){DEBUG&&console.info("GoogleMap hideAllInfo() called with map id: "+e);for(var t=m_maps[e].infoWindows,o=0;o<t.length;o++)t[o].close()}function setInfo(e,t,o){DEBUG&&console.info("GoogleMap setInfo() geocode lookup returned status "+t);var r="";t==google.maps.GeocoderStatus.OK?e[0]&&(r=formatGeocode(e[0])):console.warn("GoogleMap GeoCoder returned error status '"+t+"' for coordinates "+o.marker.position);var s=o.getContent();s=s.replace("\x3c!-- replace-with-geoadr --\x3e",r),o.setContent(s)}function formatGeocode(e){for(var t="",o="",r="",s="",n=!1,i=0;i<e.address_components.length;i++){var a=String(e.address_components[i].types);""==t&&-1!=a.indexOf("route")&&(t=e.address_components[i].long_name,n=!0),-1!=a.indexOf("street_number")&&(o=e.address_components[i].long_name,n=!0),-1!=a.indexOf("postal_code")&&(r=e.address_components[i].long_name,n=!0),""==s&&-1!=a.indexOf("locality")&&(s=e.address_components[i].long_name,n=!0)}return 1==n?t+" "+o+"<br/>"+r+" "+s:e.formatted_address}function getGeocode(e){null==m_googleGeocoder&&(m_googleGeocoder=new google.maps.Geocoder),m_googleGeocoder.geocode({latLng:e.marker.position},(function(t,o){setInfo(t,o,e)}))}function loadGoogleApi(){if(!m_googleApiLoaded){var e=Mercury.getInfo("locale"),t="";null!=m_apiKey&&(t="&key="+m_apiKey);var o="";Mercury.isOnlineProject()||(o="&libraries=places"),DEBUG&&console.info("GoogleMap API key: "+(""==t?"(undefined)":t));let r=jQ.loadScript("https://maps.google.com/maps/api/js?callback=GoogleMap.initGoogleMaps&language="+e+o+t,{},DEBUG);return m_googleApiLoaded=!0,r}initGoogleMaps()}function showMarkers(e,t){DEBUG&&console.info("GoogleMap showMapMarkers() called with map id: "+e);var o=m_maps[e];let r;for(let t of m_mapData)t.id===e&&(r=t);if(o)if(r.markerCluster)hideAllInfo(e),showSingleMap(r,t);else{var s=o.markers,n=decodeURIComponent(t);hideAllInfo(e);for(var i=0;i<s.length;i++)s[i].group==n||"showall"==n?s[i].setVisible(!0):s[i].setVisible(!1)}}function showSingleMap(mapData,filterByGroup){var mapId=mapData.id;DEBUG&&console.info("GoogleMap initializing map: "+mapId);var mapOptions={zoom:parseInt(mapData.zoom),styles:m_mapStyle,scrollwheel:!1,mapTypeId:eval("google.maps.MapTypeId."+mapData.type),streetViewControl:!1,mapTypeControlOptions:{style:google.maps.MapTypeControlStyle.DROPDOWN_MENU,mapTypeIds:new Array(google.maps.MapTypeId.ROADMAP,google.maps.MapTypeId.SATELLITE,google.maps.MapTypeId.HYBRID,google.maps.MapTypeId.TERRAIN)},center:new google.maps.LatLng(mapData.centerLat,mapData.centerLng),maxZoom:18},$typeParent=jQ("#"+mapData.id).closest("*[class*='type-map']");$typeParent.addClass("visible");var map=new google.maps.Map(document.getElementById(mapId),mapOptions);google.maps.event.addListener(map,"click",(function(e){this.setOptions({scrollwheel:!0})}));var markers=[],infoWindows=[],groups={},groupsFound=0;if(void 0!==mapData.markers){let e=0;for(var p=0;p<mapData.markers.length;p++){var point=mapData.markers[p],group=point.group;if("centerpoint"===group)DEBUG&&console.info("GoogleMap new center point added."),groups[group]=getCenterPointGraphic();else if(void 0===groups[group]){var color=Mercury.getThemeJSON("map-color["+groupsFound+++"]","#ffffff");DEBUG&&console.info("GoogleMap new marker group added: "+group+" with color: "+color),groups[group]=getPuempel(color)}if(!mapData.markerCluster||void 0===filterByGroup||"showall"==filterByGroup||decodeURIComponent(filterByGroup)==group){var marker=new google.maps.Marker({position:new google.maps.LatLng(point.lat,point.lng),map:map,title:point.title,group:group,icon:groups[group],info:point.info,index:e,mapId:mapId,geocode:point.geocode});markers.push(marker);var infoWindow=new google.maps.InfoWindow({content:marker.info,marker:marker,geocode:point.geocode,index:e});infoWindows.push(infoWindow),DEBUG&&console.info("GoogleMap attaching Event lister: "+p+" to map id "+mapId),marker.addListener("click",(function(){showInfo(this.mapId,this.index)})),e++}}}mapData.markerCluster&&new _googlemaps_markerclusterer__WEBPACK_IMPORTED_MODULE_1__.w1({markers:markers,map:map,renderer:getClusterGraphic()});var map={id:mapId,map:map,markers:markers,infoWindows:infoWindows};m_maps[mapId]=map}function showGeoJson(e,t,o){let r;DEBUG&&console.info("Google update markers for map with id: "+e);try{r=m_maps[e].map}catch(e){}if(!r)return;const s=t.features||[],n=[],i={lat:null,lng:null},a={lat:null,lng:null};let l,p=function(e){let t=e[1],o=e[0];(null===i.lat||i.lat<t)&&(i.lat=t),(null===i.lng||i.lng<o)&&(i.lng=o),(null===a.lat||a.lat>t)&&(a.lat=t),(null===a.lng||a.lng>o)&&(a.lng=o)};for(let t of m_mapData)t.id===e&&t.markers&&t.markers.length>0&&(l=t);l&&p([r.getCenter().lng(),r.getCenter().lat()]);for(let t=0;t<s.length;t++){const i=s[t],a=i.geometry.coordinates,l=i.properties.coords;p(a);const c=new google.maps.Marker({position:new google.maps.LatLng(a[1],a[0]),map:r,icon:getFeatureGraphic(),zIndex:t});n.push(c);const h=new google.maps.InfoWindow({marker:c,zIndex:t});c.addListener("click",(function(t){m_maps[e].infoWindow&&m_maps[e].infoWindow.close();fetch(o+"&coordinates="+l).then((e=>e.text())).then((e=>{h.setContent(e),h.open(r,c)})),m_maps[e].infoWindow=h}))}if(new _googlemaps_markerclusterer__WEBPACK_IMPORTED_MODULE_1__.w1({markers:n,map:r,renderer:getClusterGraphic()}),i.lat){const e=new google.maps.LatLngBounds;e.extend(i),e.extend(a),r.fitBounds(e)}}function initGoogleMaps(){DEBUG&&console.info("GoogleMap initGoogleMaps() called with data for "+m_mapData.length+" maps!");for(var e=0;e<m_mapData.length;e++)m_mapData[e].showPlaceholder||showSingleMap(m_mapData[e])}function showMap(e){DEBUG&&console.log("GoogleMap show map with id: "+e.currentTarget.id);for(var t=e.currentTarget,o=0;o<m_mapData.length;o++)m_mapData[o].id==t.id&&(m_mapData[o].showPlaceholder=!1,showSingleMap(m_mapData[o]));window.dispatchEvent(new CustomEvent("map-placeholder-click",{detail:GoogleMap}))}function init(e,t){jQ=e,DEBUG=t,m_apiKey=Mercury.getInfo("googleApiKey"),DEBUG&&(console.info("GoogleMap.init()"),null!=m_apiKey?console.info("GoogleMap API key is: "+Mercury.getInfo("googleApiKey")):console.info("GoogleMap API key not set - Google maps not activated"));var o=jQ(".map-google .mapwindow");if(DEBUG&&console.info("GoogleMap.init() .map-google elements found: "+o.length),o.length>0&&null!=m_apiKey){if(PrivacyPolicy.cookiesAcceptedExternal())return m_mapStyle=Mercury.getThemeJSON("map-style",[]),o.each((function(){var e=jQ(this);if(void 0!==e.data("map")){var t=e.data("map");"string"==typeof t&&(t=JSON.parse(t)),t.id=e.attr("id"),t.showPlaceholder=Mercury.initPlaceholder(e,showMap),DEBUG&&console.info("GoogleMap found with id: "+t.id),m_mapData.push(t),t.showPlaceholder||e.removeClass("placeholder")}})),loadGoogleApi();DEBUG&&console.info("External cookies not accepted by the user - Google maps are disabled!")}}}}]);
//# sourceMappingURL=mercury-map-google.js.map?ver=0d5ec3d5038735f107af