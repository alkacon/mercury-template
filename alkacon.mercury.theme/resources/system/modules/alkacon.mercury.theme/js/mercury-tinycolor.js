"use strict";(self.webpackChunkmercury_template=self.webpackChunkmercury_template||[]).push([[530],{140:function(t,r,e){function n(t){return n="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(t){return typeof t}:function(t){return t&&"function"==typeof Symbol&&t.constructor===Symbol&&t!==Symbol.prototype?"symbol":typeof t},n(t)}e.d(r,{A:function(){return o}});var a=/^\s+/,i=/\s+$/;function o(t,r){if(r=r||{},(t=t||"")instanceof o)return t;if(!(this instanceof o))return new o(t,r);var e=function(t){var r={r:0,g:0,b:0},e=1,o=null,h=null,s=null,f=!1,u=!1;"string"==typeof t&&(t=function(t){t=t.replace(a,"").replace(i,"").toLowerCase();var r,e=!1;if(x[t])t=x[t],e=!0;else if("transparent"==t)return{r:0,g:0,b:0,a:0,format:"name"};if(r=z.rgb.exec(t))return{r:r[1],g:r[2],b:r[3]};if(r=z.rgba.exec(t))return{r:r[1],g:r[2],b:r[3],a:r[4]};if(r=z.hsl.exec(t))return{h:r[1],s:r[2],l:r[3]};if(r=z.hsla.exec(t))return{h:r[1],s:r[2],l:r[3],a:r[4]};if(r=z.hsv.exec(t))return{h:r[1],s:r[2],v:r[3]};if(r=z.hsva.exec(t))return{h:r[1],s:r[2],v:r[3],a:r[4]};if(r=z.hex8.exec(t))return{r:R(r[1]),g:R(r[2]),b:R(r[3]),a:N(r[4]),format:e?"name":"hex8"};if(r=z.hex6.exec(t))return{r:R(r[1]),g:R(r[2]),b:R(r[3]),format:e?"name":"hex"};if(r=z.hex4.exec(t))return{r:R(r[1]+""+r[1]),g:R(r[2]+""+r[2]),b:R(r[3]+""+r[3]),a:N(r[4]+""+r[4]),format:e?"name":"hex8"};if(r=z.hex3.exec(t))return{r:R(r[1]+""+r[1]),g:R(r[2]+""+r[2]),b:R(r[3]+""+r[3]),format:e?"name":"hex"};return!1}(t));"object"==n(t)&&(T(t.r)&&T(t.g)&&T(t.b)?(l=t.r,c=t.g,d=t.b,r={r:255*S(l,255),g:255*S(c,255),b:255*S(d,255)},f=!0,u="%"===String(t.r).substr(-1)?"prgb":"rgb"):T(t.h)&&T(t.s)&&T(t.v)?(o=C(t.s),h=C(t.v),r=function(t,r,e){t=6*S(t,360),r=S(r,100),e=S(e,100);var n=Math.floor(t),a=t-n,i=e*(1-r),o=e*(1-a*r),h=e*(1-(1-a)*r),s=n%6,f=[e,o,i,i,h,e][s],u=[h,e,e,o,i,i][s],l=[i,i,h,e,e,o][s];return{r:255*f,g:255*u,b:255*l}}(t.h,o,h),f=!0,u="hsv"):T(t.h)&&T(t.s)&&T(t.l)&&(o=C(t.s),s=C(t.l),r=function(t,r,e){var n,a,i;function o(t,r,e){return e<0&&(e+=1),e>1&&(e-=1),e<1/6?t+6*(r-t)*e:e<.5?r:e<2/3?t+(r-t)*(2/3-e)*6:t}if(t=S(t,360),r=S(r,100),e=S(e,100),0===r)n=a=i=e;else{var h=e<.5?e*(1+r):e+r-e*r,s=2*e-h;n=o(s,h,t+1/3),a=o(s,h,t),i=o(s,h,t-1/3)}return{r:255*n,g:255*a,b:255*i}}(t.h,o,s),f=!0,u="hsl"),t.hasOwnProperty("a")&&(e=t.a));var l,c,d;return e=w(e),{ok:f,format:t.format||u,r:Math.min(255,Math.max(r.r,0)),g:Math.min(255,Math.max(r.g,0)),b:Math.min(255,Math.max(r.b,0)),a:e}}(t);this._originalInput=t,this._r=e.r,this._g=e.g,this._b=e.b,this._a=e.a,this._roundA=Math.round(100*this._a)/100,this._format=r.format||e.format,this._gradientType=r.gradientType,this._r<1&&(this._r=Math.round(this._r)),this._g<1&&(this._g=Math.round(this._g)),this._b<1&&(this._b=Math.round(this._b)),this._ok=e.ok}function h(t,r,e){t=S(t,255),r=S(r,255),e=S(e,255);var n,a,i=Math.max(t,r,e),o=Math.min(t,r,e),h=(i+o)/2;if(i==o)n=a=0;else{var s=i-o;switch(a=h>.5?s/(2-i-o):s/(i+o),i){case t:n=(r-e)/s+(r<e?6:0);break;case r:n=(e-t)/s+2;break;case e:n=(t-r)/s+4}n/=6}return{h:n,s:a,l:h}}function s(t,r,e){t=S(t,255),r=S(r,255),e=S(e,255);var n,a,i=Math.max(t,r,e),o=Math.min(t,r,e),h=i,s=i-o;if(a=0===i?0:s/i,i==o)n=0;else{switch(i){case t:n=(r-e)/s+(r<e?6:0);break;case r:n=(e-t)/s+2;break;case e:n=(t-r)/s+4}n/=6}return{h:n,s:a,v:h}}function f(t,r,e,n){var a=[F(Math.round(t).toString(16)),F(Math.round(r).toString(16)),F(Math.round(e).toString(16))];return n&&a[0].charAt(0)==a[0].charAt(1)&&a[1].charAt(0)==a[1].charAt(1)&&a[2].charAt(0)==a[2].charAt(1)?a[0].charAt(0)+a[1].charAt(0)+a[2].charAt(0):a.join("")}function u(t,r,e,n){return[F(q(n)),F(Math.round(t).toString(16)),F(Math.round(r).toString(16)),F(Math.round(e).toString(16))].join("")}function l(t,r){r=0===r?0:r||10;var e=o(t).toHsl();return e.s-=r/100,e.s=H(e.s),o(e)}function c(t,r){r=0===r?0:r||10;var e=o(t).toHsl();return e.s+=r/100,e.s=H(e.s),o(e)}function d(t){return o(t).desaturate(100)}function g(t,r){r=0===r?0:r||10;var e=o(t).toHsl();return e.l+=r/100,e.l=H(e.l),o(e)}function b(t,r){r=0===r?0:r||10;var e=o(t).toRgb();return e.r=Math.max(0,Math.min(255,e.r-Math.round(-r/100*255))),e.g=Math.max(0,Math.min(255,e.g-Math.round(-r/100*255))),e.b=Math.max(0,Math.min(255,e.b-Math.round(-r/100*255))),o(e)}function m(t,r){r=0===r?0:r||10;var e=o(t).toHsl();return e.l-=r/100,e.l=H(e.l),o(e)}function p(t,r){var e=o(t).toHsl(),n=(e.h+r)%360;return e.h=n<0?360+n:n,o(e)}function _(t){var r=o(t).toHsl();return r.h=(r.h+180)%360,o(r)}function v(t,r){if(isNaN(r)||r<=0)throw new Error("Argument to polyad must be a positive number");for(var e=o(t).toHsl(),n=[o(t)],a=360/r,i=1;i<r;i++)n.push(o({h:(e.h+i*a)%360,s:e.s,l:e.l}));return n}function y(t){var r=o(t).toHsl(),e=r.h;return[o(t),o({h:(e+72)%360,s:r.s,l:r.l}),o({h:(e+216)%360,s:r.s,l:r.l})]}function M(t,r,e){r=r||6,e=e||30;var n=o(t).toHsl(),a=360/e,i=[o(t)];for(n.h=(n.h-(a*r>>1)+720)%360;--r;)n.h=(n.h+a)%360,i.push(o(n));return i}function A(t,r){r=r||6;for(var e=o(t).toHsv(),n=e.h,a=e.s,i=e.v,h=[],s=1/r;r--;)h.push(o({h:n,s:a,v:i})),i=(i+s)%1;return h}o.prototype={isDark:function(){return this.getBrightness()<128},isLight:function(){return!this.isDark()},isValid:function(){return this._ok},getOriginalInput:function(){return this._originalInput},getFormat:function(){return this._format},getAlpha:function(){return this._a},getBrightness:function(){var t=this.toRgb();return(299*t.r+587*t.g+114*t.b)/1e3},getLuminance:function(){var t,r,e,n=this.toRgb();return t=n.r/255,r=n.g/255,e=n.b/255,.2126*(t<=.03928?t/12.92:Math.pow((t+.055)/1.055,2.4))+.7152*(r<=.03928?r/12.92:Math.pow((r+.055)/1.055,2.4))+.0722*(e<=.03928?e/12.92:Math.pow((e+.055)/1.055,2.4))},setAlpha:function(t){return this._a=w(t),this._roundA=Math.round(100*this._a)/100,this},toHsv:function(){var t=s(this._r,this._g,this._b);return{h:360*t.h,s:t.s,v:t.v,a:this._a}},toHsvString:function(){var t=s(this._r,this._g,this._b),r=Math.round(360*t.h),e=Math.round(100*t.s),n=Math.round(100*t.v);return 1==this._a?"hsv("+r+", "+e+"%, "+n+"%)":"hsva("+r+", "+e+"%, "+n+"%, "+this._roundA+")"},toHsl:function(){var t=h(this._r,this._g,this._b);return{h:360*t.h,s:t.s,l:t.l,a:this._a}},toHslString:function(){var t=h(this._r,this._g,this._b),r=Math.round(360*t.h),e=Math.round(100*t.s),n=Math.round(100*t.l);return 1==this._a?"hsl("+r+", "+e+"%, "+n+"%)":"hsla("+r+", "+e+"%, "+n+"%, "+this._roundA+")"},toHex:function(t){return f(this._r,this._g,this._b,t)},toHexString:function(t){return"#"+this.toHex(t)},toHex8:function(t){return function(t,r,e,n,a){var i=[F(Math.round(t).toString(16)),F(Math.round(r).toString(16)),F(Math.round(e).toString(16)),F(q(n))];if(a&&i[0].charAt(0)==i[0].charAt(1)&&i[1].charAt(0)==i[1].charAt(1)&&i[2].charAt(0)==i[2].charAt(1)&&i[3].charAt(0)==i[3].charAt(1))return i[0].charAt(0)+i[1].charAt(0)+i[2].charAt(0)+i[3].charAt(0);return i.join("")}(this._r,this._g,this._b,this._a,t)},toHex8String:function(t){return"#"+this.toHex8(t)},toRgb:function(){return{r:Math.round(this._r),g:Math.round(this._g),b:Math.round(this._b),a:this._a}},toRgbString:function(){return 1==this._a?"rgb("+Math.round(this._r)+", "+Math.round(this._g)+", "+Math.round(this._b)+")":"rgba("+Math.round(this._r)+", "+Math.round(this._g)+", "+Math.round(this._b)+", "+this._roundA+")"},toPercentageRgb:function(){return{r:Math.round(100*S(this._r,255))+"%",g:Math.round(100*S(this._g,255))+"%",b:Math.round(100*S(this._b,255))+"%",a:this._a}},toPercentageRgbString:function(){return 1==this._a?"rgb("+Math.round(100*S(this._r,255))+"%, "+Math.round(100*S(this._g,255))+"%, "+Math.round(100*S(this._b,255))+"%)":"rgba("+Math.round(100*S(this._r,255))+"%, "+Math.round(100*S(this._g,255))+"%, "+Math.round(100*S(this._b,255))+"%, "+this._roundA+")"},toName:function(){return 0===this._a?"transparent":!(this._a<1)&&(k[f(this._r,this._g,this._b,!0)]||!1)},toFilter:function(t){var r="#"+u(this._r,this._g,this._b,this._a),e=r,n=this._gradientType?"GradientType = 1, ":"";if(t){var a=o(t);e="#"+u(a._r,a._g,a._b,a._a)}return"progid:DXImageTransform.Microsoft.gradient("+n+"startColorstr="+r+",endColorstr="+e+")"},toString:function(t){var r=!!t;t=t||this._format;var e=!1,n=this._a<1&&this._a>=0;return r||!n||"hex"!==t&&"hex6"!==t&&"hex3"!==t&&"hex4"!==t&&"hex8"!==t&&"name"!==t?("rgb"===t&&(e=this.toRgbString()),"prgb"===t&&(e=this.toPercentageRgbString()),"hex"!==t&&"hex6"!==t||(e=this.toHexString()),"hex3"===t&&(e=this.toHexString(!0)),"hex4"===t&&(e=this.toHex8String(!0)),"hex8"===t&&(e=this.toHex8String()),"name"===t&&(e=this.toName()),"hsl"===t&&(e=this.toHslString()),"hsv"===t&&(e=this.toHsvString()),e||this.toHexString()):"name"===t&&0===this._a?this.toName():this.toRgbString()},clone:function(){return o(this.toString())},_applyModification:function(t,r){var e=t.apply(null,[this].concat([].slice.call(r)));return this._r=e._r,this._g=e._g,this._b=e._b,this.setAlpha(e._a),this},lighten:function(){return this._applyModification(g,arguments)},brighten:function(){return this._applyModification(b,arguments)},darken:function(){return this._applyModification(m,arguments)},desaturate:function(){return this._applyModification(l,arguments)},saturate:function(){return this._applyModification(c,arguments)},greyscale:function(){return this._applyModification(d,arguments)},spin:function(){return this._applyModification(p,arguments)},_applyCombination:function(t,r){return t.apply(null,[this].concat([].slice.call(r)))},analogous:function(){return this._applyCombination(M,arguments)},complement:function(){return this._applyCombination(_,arguments)},monochromatic:function(){return this._applyCombination(A,arguments)},splitcomplement:function(){return this._applyCombination(y,arguments)},triad:function(){return this._applyCombination(v,[3])},tetrad:function(){return this._applyCombination(v,[4])}},o.fromRatio=function(t,r){if("object"==n(t)){var e={};for(var a in t)t.hasOwnProperty(a)&&(e[a]="a"===a?t[a]:C(t[a]));t=e}return o(t,r)},o.equals=function(t,r){return!(!t||!r)&&o(t).toRgbString()==o(r).toRgbString()},o.random=function(){return o.fromRatio({r:Math.random(),g:Math.random(),b:Math.random()})},o.mix=function(t,r,e){e=0===e?0:e||50;var n=o(t).toRgb(),a=o(r).toRgb(),i=e/100;return o({r:(a.r-n.r)*i+n.r,g:(a.g-n.g)*i+n.g,b:(a.b-n.b)*i+n.b,a:(a.a-n.a)*i+n.a})},o.readability=function(t,r){var e=o(t),n=o(r);return(Math.max(e.getLuminance(),n.getLuminance())+.05)/(Math.min(e.getLuminance(),n.getLuminance())+.05)},o.isReadable=function(t,r,e){var n,a,i=o.readability(t,r);switch(a=!1,(n=function(t){var r,e;r=((t=t||{level:"AA",size:"small"}).level||"AA").toUpperCase(),e=(t.size||"small").toLowerCase(),"AA"!==r&&"AAA"!==r&&(r="AA");"small"!==e&&"large"!==e&&(e="small");return{level:r,size:e}}(e)).level+n.size){case"AAsmall":case"AAAlarge":a=i>=4.5;break;case"AAlarge":a=i>=3;break;case"AAAsmall":a=i>=7}return a},o.mostReadable=function(t,r,e){var n,a,i,h,s=null,f=0;a=(e=e||{}).includeFallbackColors,i=e.level,h=e.size;for(var u=0;u<r.length;u++)(n=o.readability(t,r[u]))>f&&(f=n,s=o(r[u]));return o.isReadable(t,s,{level:i,size:h})||!a?s:(e.includeFallbackColors=!1,o.mostReadable(t,["#fff","#000"],e))};var x=o.names={aliceblue:"f0f8ff",antiquewhite:"faebd7",aqua:"0ff",aquamarine:"7fffd4",azure:"f0ffff",beige:"f5f5dc",bisque:"ffe4c4",black:"000",blanchedalmond:"ffebcd",blue:"00f",blueviolet:"8a2be2",brown:"a52a2a",burlywood:"deb887",burntsienna:"ea7e5d",cadetblue:"5f9ea0",chartreuse:"7fff00",chocolate:"d2691e",coral:"ff7f50",cornflowerblue:"6495ed",cornsilk:"fff8dc",crimson:"dc143c",cyan:"0ff",darkblue:"00008b",darkcyan:"008b8b",darkgoldenrod:"b8860b",darkgray:"a9a9a9",darkgreen:"006400",darkgrey:"a9a9a9",darkkhaki:"bdb76b",darkmagenta:"8b008b",darkolivegreen:"556b2f",darkorange:"ff8c00",darkorchid:"9932cc",darkred:"8b0000",darksalmon:"e9967a",darkseagreen:"8fbc8f",darkslateblue:"483d8b",darkslategray:"2f4f4f",darkslategrey:"2f4f4f",darkturquoise:"00ced1",darkviolet:"9400d3",deeppink:"ff1493",deepskyblue:"00bfff",dimgray:"696969",dimgrey:"696969",dodgerblue:"1e90ff",firebrick:"b22222",floralwhite:"fffaf0",forestgreen:"228b22",fuchsia:"f0f",gainsboro:"dcdcdc",ghostwhite:"f8f8ff",gold:"ffd700",goldenrod:"daa520",gray:"808080",green:"008000",greenyellow:"adff2f",grey:"808080",honeydew:"f0fff0",hotpink:"ff69b4",indianred:"cd5c5c",indigo:"4b0082",ivory:"fffff0",khaki:"f0e68c",lavender:"e6e6fa",lavenderblush:"fff0f5",lawngreen:"7cfc00",lemonchiffon:"fffacd",lightblue:"add8e6",lightcoral:"f08080",lightcyan:"e0ffff",lightgoldenrodyellow:"fafad2",lightgray:"d3d3d3",lightgreen:"90ee90",lightgrey:"d3d3d3",lightpink:"ffb6c1",lightsalmon:"ffa07a",lightseagreen:"20b2aa",lightskyblue:"87cefa",lightslategray:"789",lightslategrey:"789",lightsteelblue:"b0c4de",lightyellow:"ffffe0",lime:"0f0",limegreen:"32cd32",linen:"faf0e6",magenta:"f0f",maroon:"800000",mediumaquamarine:"66cdaa",mediumblue:"0000cd",mediumorchid:"ba55d3",mediumpurple:"9370db",mediumseagreen:"3cb371",mediumslateblue:"7b68ee",mediumspringgreen:"00fa9a",mediumturquoise:"48d1cc",mediumvioletred:"c71585",midnightblue:"191970",mintcream:"f5fffa",mistyrose:"ffe4e1",moccasin:"ffe4b5",navajowhite:"ffdead",navy:"000080",oldlace:"fdf5e6",olive:"808000",olivedrab:"6b8e23",orange:"ffa500",orangered:"ff4500",orchid:"da70d6",palegoldenrod:"eee8aa",palegreen:"98fb98",paleturquoise:"afeeee",palevioletred:"db7093",papayawhip:"ffefd5",peachpuff:"ffdab9",peru:"cd853f",pink:"ffc0cb",plum:"dda0dd",powderblue:"b0e0e6",purple:"800080",rebeccapurple:"663399",red:"f00",rosybrown:"bc8f8f",royalblue:"4169e1",saddlebrown:"8b4513",salmon:"fa8072",sandybrown:"f4a460",seagreen:"2e8b57",seashell:"fff5ee",sienna:"a0522d",silver:"c0c0c0",skyblue:"87ceeb",slateblue:"6a5acd",slategray:"708090",slategrey:"708090",snow:"fffafa",springgreen:"00ff7f",steelblue:"4682b4",tan:"d2b48c",teal:"008080",thistle:"d8bfd8",tomato:"ff6347",turquoise:"40e0d0",violet:"ee82ee",wheat:"f5deb3",white:"fff",whitesmoke:"f5f5f5",yellow:"ff0",yellowgreen:"9acd32"},k=o.hexNames=function(t){var r={};for(var e in t)t.hasOwnProperty(e)&&(r[t[e]]=e);return r}(x);function w(t){return t=parseFloat(t),(isNaN(t)||t<0||t>1)&&(t=1),t}function S(t,r){(function(t){return"string"==typeof t&&-1!=t.indexOf(".")&&1===parseFloat(t)})(t)&&(t="100%");var e=function(t){return"string"==typeof t&&-1!=t.indexOf("%")}(t);return t=Math.min(r,Math.max(0,parseFloat(t))),e&&(t=parseInt(t*r,10)/100),Math.abs(t-r)<1e-6?1:t%r/parseFloat(r)}function H(t){return Math.min(1,Math.max(0,t))}function R(t){return parseInt(t,16)}function F(t){return 1==t.length?"0"+t:""+t}function C(t){return t<=1&&(t=100*t+"%"),t}function q(t){return Math.round(255*parseFloat(t)).toString(16)}function N(t){return R(t)/255}var E,I,L,z=(I="[\\s|\\(]+("+(E="(?:[-\\+]?\\d*\\.\\d+%?)|(?:[-\\+]?\\d+%?)")+")[,|\\s]+("+E+")[,|\\s]+("+E+")\\s*\\)?",L="[\\s|\\(]+("+E+")[,|\\s]+("+E+")[,|\\s]+("+E+")[,|\\s]+("+E+")\\s*\\)?",{CSS_UNIT:new RegExp(E),rgb:new RegExp("rgb"+I),rgba:new RegExp("rgba"+L),hsl:new RegExp("hsl"+I),hsla:new RegExp("hsla"+L),hsv:new RegExp("hsv"+I),hsva:new RegExp("hsva"+L),hex3:/^#?([0-9a-fA-F]{1})([0-9a-fA-F]{1})([0-9a-fA-F]{1})$/,hex6:/^#?([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$/,hex4:/^#?([0-9a-fA-F]{1})([0-9a-fA-F]{1})([0-9a-fA-F]{1})([0-9a-fA-F]{1})$/,hex8:/^#?([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$/});function T(t){return!!z.CSS_UNIT.exec(t)}}}]);
//# sourceMappingURL=mercury-tinycolor.js.map?ver=25b3c8d1cfcf7a943aff