(self.webpackChunkmercury_template=self.webpackChunkmercury_template||[]).push([[108],{6927:function(n,e,t){n.exports=function(n){"use strict";function e(n){return n&&"object"==typeof n&&"default"in n?n:{default:n}}var t=e(n),r={active:!0,breakpoints:{},selected:"is-selected",draggable:"is-draggable",dragging:"is-dragging"};function o(n,e){var t=n.classList;e&&t.contains(e)&&t.remove(e)}function i(n,e){var t=n.classList;e&&!t.contains(e)&&t.add(e)}function u(n){var e,c,a,s,l=t.default.optionsHandler(),d=l.merge(r,u.globalOptions),f=["select","pointerUp"],p=["pointerDown","pointerUp"];function g(n){"pointerDown"===n?i(a,e.dragging):o(a,e.dragging)}function v(){var n=c.slidesInView(!0);c.slidesNotInView(!0).forEach((function(n){return o(s[n],e.selected)})),n.forEach((function(n){return i(s[n],e.selected)}))}var m={name:"classNames",options:l.merge(d,n),init:function(n){c=n,e=l.atMedia(m.options),a=c.rootNode(),s=c.slideNodes(),c.internalEngine().options.draggable&&i(a,e.draggable),e.dragging&&p.forEach((function(n){return c.on(n,g)})),e.selected&&(f.forEach((function(n){return c.on(n,v)})),v())},destroy:function(){o(a,e.draggable),p.forEach((function(n){return c.off(n,g)})),f.forEach((function(n){return c.off(n,v)})),s.forEach((function(n){return o(n,e.selected)}))}};return m}return u.globalOptions=void 0,u}(t(6883))},6883:function(n){n.exports=function(){"use strict";function n(n){return"number"==typeof n}function e(n){return"[object Object]"===Object.prototype.toString.call(n)}function t(n){return e(n)||function(n){return Array.isArray(n)}(n)}function r(n){return Math.abs(n)}function o(n){return n?n/r(n):0}function i(n,e){return r(n-e)}function u(n){return s(n).map(Number)}function c(n){return n[a(n)]}function a(n){return Math.max(0,n.length-1)}function s(n){return Object.keys(n)}function l(n,t){return[n,t].reduce((function(n,t){return s(t).forEach((function(r){var o=n[r],i=t[r],u=e(o)&&e(i);n[r]=u?l(o,i):i})),n}),{})}function d(n,e){var r=s(n),o=s(e);return r.length===o.length&&r.every((function(r){var o=n[r],i=e[r];return"function"==typeof o?"".concat(o)==="".concat(i):t(o)&&t(i)?d(o,i):o===i}))}function f(e,t){var r={start:function(){return 0},center:function(n){return o(n)/2},end:o};function o(n){return t-n}return{measure:function(o){return n(e)?t*Number(e):r[e](o)}}}function p(n,e){var t=r(n-e);function o(e){return e<n}function i(n){return n>e}function u(n){return o(n)||i(n)}return{length:t,max:e,min:n,constrain:function(t){return u(t)?o(t)?n:e:t},reachedAny:u,reachedMax:i,reachedMin:o,removeOffset:function(n){return t?n-t*Math.ceil((n-e)/t):n}}}function g(n,e,t){var o=p(0,n),i=o.min,u=o.constrain,c=n+1,a=s(e);function s(n){return t?r((c+n)%c):u(n)}function l(){return a}function d(n){return a=s(n),f}var f={add:function(n){return d(l()+n)},clone:function(){return g(n,l(),t)},get:l,set:d,min:i,max:n};return f}function v(){var n=[],e={add:function(t,r,o,i){return void 0===i&&(i=!1),t.addEventListener(r,o,i),n.push((function(){return t.removeEventListener(r,o,i)})),e},removeAll:function(){return n=n.filter((function(n){return n()})),e}};return e}function m(e){var t=e;function r(n){return t/=n,i}function o(e){return n(e)?e:e.get()}var i={add:function(n){return t+=o(n),i},divide:r,get:function(){return t},multiply:function(n){return t*=n,i},normalize:function(){return 0!==t&&r(t),i},set:function(n){return t=o(n),i},subtract:function(n){return t-=o(n),i}};return i}function h(n,e,t,u,c,a,s,l,d,f,p,g,h,x,y,S){var b=n.cross,w=["INPUT","SELECT","TEXTAREA"],E=m(0),A=v(),M=v(),k=h.measure(20),L={mouse:300,touch:400},O={mouse:500,touch:600},I=y?5:16,T=0,N=0,P=!1,B=!1,D=!1,z=!1;function V(n){if(!(z="mousedown"===n.type)||0===n.button){var e,r=i(u.get(),a.get())>=2,o=z||!r,s=(e=n.target.nodeName||"",!(w.indexOf(e)>-1)),l=r||z&&s;P=!0,c.pointerDown(n),E.set(u),u.set(a),d.useBaseMass().useSpeed(80),function(){var n=z?document:t;M.add(n,"touchmove",q).add(n,"touchend",C).add(n,"mousemove",q).add(n,"mouseup",C)}(),T=c.readPoint(n),N=c.readPoint(n,b),g.emit("pointerDown"),o&&(D=!1),l&&n.preventDefault()}}function q(n){if(!B&&!z){if(!n.cancelable)return C(n);var t=c.readPoint(n),r=c.readPoint(n,b),o=i(t,T),a=i(r,N);if(!(B=o>a)&&!D)return C(n)}var l=c.pointerMove(n);!D&&l&&(D=!0),s.start(),u.add(e.apply(l)),n.preventDefault()}function C(n){var t=f.byDistance(0,!1).index!==p.get(),a=c.pointerUp(n)*(y?O:L)[z?"mouse":"touch"],s=function(n,e){var t=p.clone().add(-1*o(n)),i=t.get()===p.min||t.get()===p.max,u=f.byDistance(n,!y).distance;return y||r(n)<k?u:!x&&i?.4*u:S&&e?.5*u:f.byIndex(t.get(),0).distance}(e.apply(a),t),v=function(n,e){if(0===n||0===e)return 0;if(r(n)<=r(e))return 0;var t=i(r(n),r(e));return r(t/n)}(a,s),m=i(u.get(),E.get())>=.5,h=t&&v>.75,b=r(a)<k,w=h?10:I,A=h?1+2.5*v:1;m&&!z&&(D=!0),B=!1,P=!1,M.removeAll(),d.useSpeed(b?9:w).useMass(A),l.distance(s,!y),z=!1,g.emit("pointerUp")}function H(n){D&&n.preventDefault()}return{addActivationEvents:function(){var n=t;A.add(n,"touchmove",(function(){})).add(n,"touchend",(function(){})).add(n,"touchstart",V).add(n,"mousedown",V).add(n,"touchcancel",C).add(n,"contextmenu",C).add(n,"click",H)},clickAllowed:function(){return!D},pointerDown:function(){return P},removeAllEvents:function(){A.removeAll(),M.removeAll()}}}function x(n,e,t){var r,i,u=(r=2,i=Math.pow(10,r),function(n){return Math.round(n*i)/i}),c=m(0),a=m(0),s=m(0),l=0,d=e,f=t;function p(n){return d=n,v}function g(n){return f=n,v}var v={direction:function(){return l},seek:function(e){s.set(e).subtract(n);var t,r,i,u=(r=0)+(s.get()-(t=0))/(100-t)*(d-r);return l=o(s.get()),s.normalize().multiply(u).subtract(c),(i=s).divide(f),a.add(i),v},settle:function(e){var t=e.get()-n.get(),r=!u(t);return r&&n.set(e),r},update:function(){c.add(a),n.add(c),a.multiply(0)},useBaseMass:function(){return g(t)},useBaseSpeed:function(){return p(e)},useMass:g,useSpeed:p};return v}function y(n,e,t,o,i){var u=i.measure(10),c=i.measure(50),a=!1;return{constrain:function(i){if(!a&&n.reachedAny(t.get())&&n.reachedAny(e.get())){var s=n.reachedMin(e.get())?"min":"max",l=r(n[s]-e.get()),d=t.get()-e.get(),f=Math.min(l/c,.85);t.subtract(d*f),!i&&r(d)<u&&(t.set(n.constrain(t.get())),o.useSpeed(10).useMass(3))}},toggleActive:function(n){a=!n}}}function S(n,e,t,r){var o=p(-e+n,t[0]),i=t.map(o.constrain);return{snapsContained:function(){if(e<=n)return[o.max];if("keepSnaps"===r)return i;var t=function(){var n=i[0],e=c(i);return p(i.lastIndexOf(n),i.indexOf(e)+1)}(),u=t.min,a=t.max;return i.slice(u,a)}()}}function b(n,e,t,r){var o=p(e.min+.1,e.max+.1),i=o.reachedMin,u=o.reachedMax;return{loop:function(e){if(function(n){return 1===n?u(t.get()):-1===n&&i(t.get())}(e)){var o=n*(-1*e);r.forEach((function(n){return n.add(o)}))}}}}function w(n){var e=n.max,t=n.length;return{get:function(n){return(n-e)/-t}}}function E(n,e,t,i,u){var c=i.reachedAny,a=i.removeOffset,s=i.constrain;function l(n){return n.concat().sort((function(n,e){return r(n)-r(e)}))[0]}function d(e,r){var i=[e,e+t,e-t];return n?l(r?i.filter((function(n){return o(n)===r})):i):i[0]}return{byDistance:function(t,o){var i=u.get()+t,l=function(t){var o=n?a(t):s(t);return{index:e.map((function(n){return n-o})).map((function(n){return d(n,0)})).map((function(n,e){return{diff:n,index:e}})).sort((function(n,e){return r(n.diff)-r(e.diff)}))[0].index,distance:o}}(i),f=l.index,p=l.distance,g=!n&&c(i);return!o||g?{index:f,distance:t}:{index:f,distance:t+d(e[f]-p,0)}},byIndex:function(n,t){return{index:n,distance:d(e[n]-u.get(),t)}},shortcut:d}}function A(n,e,t){var r="x"===n.scroll?function(n){return"translate3d(".concat(n,"px,0px,0px)")}:function(n){return"translate3d(0px,".concat(n,"px,0px)")},o=t.style,i=!1;return{clear:function(){i||(o.transform="",t.getAttribute("style")||t.removeAttribute("style"))},to:function(n){i||(o.transform=r(e.apply(n.get())))},toggleActive:function(n){i=!n}}}function M(n,e,t,r,o,i,c,a,s){var l,d=u(o),f=u(o).reverse(),p=(l=i[0]-1,h(v(f,l),"end")).concat(function(){var n=t-i[0]-1;return h(v(d,n),"start")}());function g(n,e){return n.reduce((function(n,e){return n-o[e]}),e)}function v(n,e){return n.reduce((function(n,t){return g(n,e)>0?n.concat([t]):n}),[])}function h(t,o){var i="start"===o,u=i?-r:r,l=c.findSlideBounds([u]);return t.map((function(t){var o=i?0:-r,u=i?r:0,c=l.filter((function(n){return n.index===t}))[0][i?"end":"start"],d=m(-1),f=m(-1),p=A(n,e,s[t]);return{index:t,location:f,translate:p,target:function(){return d.set(a.get()>c?o:u)}}}))}return{canLoop:function(){return p.every((function(n){var e=n.index;return g(d.filter((function(n){return n!==e})),t)<=.1}))},clear:function(){p.forEach((function(n){return n.translate.clear()}))},loop:function(){p.forEach((function(n){var e=n.target,t=n.translate,r=n.location,o=e();o.get()!==r.get()&&(0===o.get()?t.clear():t.to(o),r.set(o))}))},loopPoints:p}}function k(n,e,t,r,o,i,u){var c=o.removeOffset,a=o.constrain,s=i?[0,e,-e]:[0],l=d(s,u);function d(e,o){var i=e||s,u=function(n){var e=n||0;return t.map((function(n){return p(.5,n-.5).constrain(n*e)}))}(o);return i.reduce((function(e,o){var i=r.map((function(e,r){return{start:e-t[r]+u[r]+o,end:e+n-u[r]+o,index:r}}));return e.concat(i)}),[])}return{check:function(n,e){var t=i?c(n):a(n);return(e||l).reduce((function(n,e){var r=e.index,o=e.start,i=e.end;return-1===n.indexOf(r)&&o<t&&i>t?n.concat([r]):n}),[])},findSlideBounds:d}}function L(e,t,r){var o=n(r);return{groupSlides:function(n){return o?function(n,e){return u(n).filter((function(n){return n%e==0})).map((function(t){return n.slice(t,t+e)}))}(n,r):function(n){return u(n).reduce((function(n,r){var o=t.slice(c(n),r+1).reduce((function(n,e){return n+e}),0);return!r||o>e?n.concat(r):n}),[]).map((function(e,t,r){return n.slice(e,r[t+1])}))}(n)}}}function O(n,e,t,o,i){var s=o.align,l=o.axis,d=o.direction,O=o.startIndex,I=o.inViewThreshold,T=o.loop,N=o.speed,P=o.dragFree,B=o.slidesToScroll,D=o.skipSnaps,z=o.containScroll,V=e.getBoundingClientRect(),q=t.map((function(n){return n.getBoundingClientRect()})),C=function(n){var e="rtl"===n?-1:1;return{apply:function(n){return n*e}}}(d),H=function(n,e){var t="y"===n?"y":"x";return{scroll:t,cross:"y"===n?"x":"y",startEdge:"y"===t?"top":"rtl"===e?"right":"left",endEdge:"y"===t?"bottom":"rtl"===e?"left":"right",measureSize:function(n){var e=n.width,r=n.height;return"x"===t?e:r}}}(l,d),R=H.measureSize(V),U=function(n){return{measure:function(e){return n*(e/100)}}}(R),j=f(s,R),F=!T&&""!==z,J=function(n,e,t,o,i){var u=n.measureSize,s=n.startEdge,l=n.endEdge,d=function(){if(!i)return 0;var n=t[0];return r(e[s]-n[s])}(),f=function(){if(!i)return 0;var n=window.getComputedStyle(c(o));return parseFloat(n.getPropertyValue("margin-".concat(l)))}(),p=t.map(u),g=t.map((function(n,e,t){var r=!e,o=e===a(t);return r?p[e]+d:o?p[e]+f:t[e+1][s]-n[s]})).map(r);return{slideSizes:p,slideSizesWithGaps:g}}(H,V,q,t,T||""!==z),X=J.slideSizes,G=J.slideSizesWithGaps,W=L(R,G,B),$=function(n,e,t,o,i,u,s){var l,d=n.startEdge,f=n.endEdge,p=u.groupSlides,g=p(o).map((function(n){return c(n)[f]-n[0][d]})).map(r).map(e.measure),v=o.map((function(n){return t[d]-n[d]})).map((function(n){return-r(n)})),m=(l=c(v)-c(i),p(v).map((function(n){return n[0]})).map((function(n,e,t){var r=!e,o=e===a(t);return s&&r?0:s&&o?l:n+g[e]})));return{snaps:v,snapsAligned:m}}(H,j,V,q,G,W,F),_=$.snaps,Y=$.snapsAligned,K=-c(_)+c(G),Q=S(R,K,Y,z).snapsContained,Z=F?Q:Y,nn=function(n,e,t){var r,o;return{limit:(r=e[0],o=c(e),p(t?r-n:o,r))}}(K,Z,T).limit,en=g(a(Z),O,T),tn=en.clone(),rn=u(t),on=function(n){var e=0;function t(n,t){return function(){n===!!e&&t()}}function r(){e=window.requestAnimationFrame(n)}return{proceed:t(!0,r),start:t(!1,r),stop:t(!0,(function(){window.cancelAnimationFrame(e),e=0}))}}((function(){T||gn.scrollBounds.constrain(gn.dragHandler.pointerDown()),gn.scrollBody.seek(an).update();var n=gn.scrollBody.settle(an);n&&!gn.dragHandler.pointerDown()&&(gn.animation.stop(),i.emit("settle")),n||i.emit("scroll"),T&&(gn.scrollLooper.loop(gn.scrollBody.direction()),gn.slideLooper.loop()),gn.translate.to(cn),gn.animation.proceed()})),un=Z[en.get()],cn=m(un),an=m(un),sn=x(cn,N,1),ln=E(T,Z,K,nn,an),dn=function(n,e,t,r,o,i){function u(r){var u=r.distance,c=r.index!==e.get();u&&(n.start(),o.add(u)),c&&(t.set(e.get()),e.set(r.index),i.emit("select"))}return{distance:function(n,e){u(r.byDistance(n,e))},index:function(n,t){var o=e.clone().set(n);u(r.byIndex(o.get(),t))}}}(on,en,tn,ln,an,i),fn=k(R,K,X,_,nn,T,I),pn=h(H,C,n,an,function(n){var e,t;function o(n){return"undefined"!=typeof TouchEvent&&n instanceof TouchEvent}function i(n){return n.timeStamp}function u(e,t){var r=t||n.scroll,i="client".concat("x"===r?"X":"Y");return(o(e)?e.touches[0]:e)[i]}return{isTouchEvent:o,pointerDown:function(n){return e=n,t=n,u(n)},pointerMove:function(n){var r=u(n)-u(t),o=i(n)-i(e)>170;return t=n,o&&(e=n),r},pointerUp:function(n){if(!e||!t)return 0;var o=u(t)-u(e),c=i(n)-i(e),a=i(n)-i(t)>170,s=o/c;return c&&!a&&r(s)>.1?s:0},readPoint:u}}(H),cn,on,dn,sn,ln,en,i,U,T,P,D),gn={containerRect:V,slideRects:q,animation:on,axis:H,direction:C,dragHandler:pn,eventStore:v(),percentOfView:U,index:en,indexPrevious:tn,limit:nn,location:cn,options:o,scrollBody:sn,scrollBounds:y(nn,cn,an,sn,U),scrollLooper:b(K,nn,cn,[cn,an]),scrollProgress:w(nn),scrollSnaps:Z,scrollTarget:ln,scrollTo:dn,slideLooper:M(H,C,R,K,G,Z,fn,cn,t),slidesToScroll:W,slidesInView:fn,slideIndexes:rn,target:an,translate:A(H,C,e)};return gn}var I={align:"center",axis:"x",containScroll:"",direction:"ltr",slidesToScroll:1,breakpoints:{},dragFree:!1,draggable:!0,inViewThreshold:0,loop:!1,skipSnaps:!1,speed:10,startIndex:0,active:!0};function T(){function n(n,e){return l(n,e||{})}return{merge:n,areEqual:function(n,e){return JSON.stringify(s(n.breakpoints||{}))===JSON.stringify(s(e.breakpoints||{}))&&d(n,e)},atMedia:function(e){var t=e.breakpoints||{},r=s(t).filter((function(n){return window.matchMedia(n).matches})).map((function(n){return t[n]})).reduce((function(e,t){return n(e,t)}),{});return n(e,r)}}}function N(n,e,t){var r,o,i,u,c,a=v(),s=T(),l=function(){var n=T(),e=n.atMedia,t=n.areEqual,r=[],o=[];function i(n){var r=e(n.options);return function(){return!t(r,e(n.options))}}var u={init:function(n,t){return o=n.map(i),(r=n.filter((function(n){return e(n.options).active}))).forEach((function(n){return n.init(t)})),n.reduce((function(n,e){var t;return Object.assign(n,((t={})[e.name]=e,t))}),{})},destroy:function(){r=r.filter((function(n){return n.destroy()}))},haveChanged:function(){return o.some((function(n){return n()}))}};return u}(),d=function(){var n={};function e(e){return n[e]||[]}var t={emit:function(n){return e(n).forEach((function(e){return e(n)})),t},off:function(r,o){return n[r]=e(r).filter((function(n){return n!==o})),t},on:function(r,o){return n[r]=e(r).concat([o]),t}};return t}(),f=d.on,p=d.off,g=w,m=!1,h=s.merge(I,N.globalOptions),x=s.merge(h),y=[],S=0;function b(e,t){if(!m){var a,f;if(a="container"in n&&n.container,f="slides"in n&&n.slides,i="root"in n?n.root:n,u=a||i.children[0],c=f||[].slice.call(u.children),h=s.merge(h,e),x=s.atMedia(h),r=O(i,u,c,x,d),S=r.axis.measureSize(i.getBoundingClientRect()),!x.active)return E();if(r.translate.to(r.location),y=t||y,o=l.init(y,L),x.loop){if(!r.slideLooper.canLoop())return E(),b({loop:!1},t);r.slideLooper.loop()}x.draggable&&u.offsetParent&&c.length&&r.dragHandler.addActivationEvents()}}function w(n,e){var t=k();E(),b(s.merge({startIndex:t},n),e),d.emit("reInit")}function E(){r.dragHandler.removeAllEvents(),r.animation.stop(),r.eventStore.removeAll(),r.translate.clear(),r.slideLooper.clear(),l.destroy()}function A(n){var e=r[n?"target":"location"].get(),t=x.loop?"removeOffset":"constrain";return r.slidesInView.check(r.limit[t](e))}function M(n,e,t){x.active&&!m&&(r.scrollBody.useBaseMass().useSpeed(e?100:x.speed),r.scrollTo.index(n,t||0))}function k(){return r.index.get()}var L={canScrollNext:function(){return r.index.clone().add(1).get()!==k()},canScrollPrev:function(){return r.index.clone().add(-1).get()!==k()},clickAllowed:function(){return r.dragHandler.clickAllowed()},containerNode:function(){return u},internalEngine:function(){return r},destroy:function(){m||(m=!0,a.removeAll(),E(),d.emit("destroy"))},off:p,on:f,plugins:function(){return o},previousScrollSnap:function(){return r.indexPrevious.get()},reInit:g,rootNode:function(){return i},scrollNext:function(n){M(r.index.clone().add(1).get(),!0===n,-1)},scrollPrev:function(n){M(r.index.clone().add(-1).get(),!0===n,1)},scrollProgress:function(){return r.scrollProgress.get(r.location.get())},scrollSnapList:function(){return r.scrollSnaps.map(r.scrollProgress.get)},scrollTo:M,selectedScrollSnap:k,slideNodes:function(){return c},slidesInView:A,slidesNotInView:function(n){var e=A(n);return r.slideIndexes.filter((function(n){return-1===e.indexOf(n)}))}};return b(e,t),a.add(window,"resize",(function(){var n=s.atMedia(h),e=!s.areEqual(n,x),t=r.axis.measureSize(i.getBoundingClientRect()),o=S!==t,u=l.haveChanged();(o||e||u)&&w(),d.emit("resize")})),setTimeout((function(){return d.emit("init")}),0),L}return N.globalOptions=void 0,N.optionsHandler=T,N}()},2608:function(n,e,t){"use strict";t.r(e),t.d(e,{init:function(){return h}});var r,o=t(6883),i=t.n(o),u=t(6927),c=t.n(u);const a=[1,20,14,11,8,6,4,4,2,2,1],s=(n,e,t,r,o)=>{t&&t.stop();let i=n.options.speed>90?n.options.speed:o||8;n.scrollBody.useSpeed(i).useMass((n=>n>9||n<1?1:a[n])(i)),n.scrollTo.index(e,r||0)},l=(n,e,t)=>{const r=n.index.clone().add(1);s(n,r.get(),e,-1,t)},d=(n,e,t,r)=>{n.addEventListener("click",(()=>{((n,e,t)=>{const r=n.index.clone().add(-1);s(n,r.get(),e,1,t)})(t.internalEngine(),r)}),!1),e.addEventListener("click",(()=>{l(t.internalEngine(),r)}),!1)};const f=n=>{let e=Math.min(Math.max(n,0),1);return e-.001<0?e=0:e+.001>1&&(e=1),e},p=(n,e,t,r)=>{const o=f(1-Math.abs(n*r));t[e].style.transform=`scale(${o})`},g=(n,e,t,r)=>{const o=100*f(n*(-1/r));t[e].style.transform=`translateX(${o}%)`},v=(n,e,t)=>{const r=n.slideNodes().map((n=>n.querySelector(".slide-container")));return()=>{const o=(n=>{const e=n.internalEngine(),t=n.scrollProgress();return n.scrollSnapList().map(((r,o)=>{if(!n.slidesInView().includes(o))return 0;let i=r-t;return e.options.loop&&e.slideLooper.loopPoints.forEach((n=>{const e=n.target().get();if(o===n.index&&0!==e){const n=Math.sign(e);-1===n&&(i=r-(1+t)),1===n&&(i=r+(1-t))}})),i}))})(n);o.forEach(((n,o)=>{e(n,o,r,t)}))}};function m(n){[].forEach.call(n,((n,e)=>{const t=n.querySelector(".slider-box"),o=JSON.parse(t.dataset.slider);o.loop=!0,o.align="start",o.speed=o.speed||4,o.inViewThreshold="logo"==o.type?.75:0;let u=[c()({selected:"slide-active",draggable:"",dragging:""})];const a=o.autoplay?function(n){const e=i().optionsHandler();let t,o,u,c=0;function a(){c&&window.clearTimeout(c)}function s(){a(),c=window.setTimeout(p,t.delay)}function d(){o.off("pointerDown",u),t.stopOnInteraction||o.off("pointerUp",f),a(),c=0}function f(){c&&(a(),s())}function p(){l(o.internalEngine(),null,t.speed),s()}const g={name:"autoplayMod",options:e.merge({active:!0,breakpoints:{},delay:4e3,speed:4,stopOnInteraction:!1,stopOnMouseEnter:!1},n),init:function(n){r&&console.info("Slider.init() AutoplayMod.init()"),o=n,t=e.atMedia(g.options),u=t.stopOnInteraction?d:a;const{eventStore:i}=o.internalEngine(),c=o.rootNode();o.on("pointerDown",u),t.stopOnInteraction||o.on("pointerUp",f),t.stopOnMouseEnter&&(i.add(c,"mouseenter",a),i.add(c,"mouseleave",f)),i.add(document,"visibilitychange",(()=>{if("hidden"===document.visibilityState)return a();f()})),i.add(window,"pagehide",(n=>{n.persisted&&a()})),s()},destroy:d,play:s,stop:a,reset:f};return g}({delay:o.delay,stopOnMouseEnter:o.pause,speed:o.speed}):null;null!=a&&u.push(a),t.classList.add("slider-initialized");const f=i()({root:t,container:t.querySelector(".slide-definitions")},o,u);if(o.arrows){const e=n.querySelector(".prev-btn"),t=n.querySelector(".next-btn");d(e,t,f,a)}if(o.dots){const e=((n,e)=>{const t=n.innerHTML;let r="";const o=e.slideNodes().length;for(let n=0;n<o;n++)r+=t.replace("*slideIndex*",n+1).replace("*slideTotal*",o);return n.innerHTML=r,[].slice.call(n.querySelectorAll(".dot-btn"))})(n.querySelector(".slider-dots"),f),t=((n,e)=>()=>{const t=e.previousScrollSnap(),r=e.selectedScrollSnap();n[t].classList.remove("active"),n[t].setAttribute("tabindex","-1"),n[t].setAttribute("aria-selected",!1),n[r].classList.add("active"),n[r].setAttribute("tabindex","0"),n[r].setAttribute("aria-selected",!0)})(e,f);((n,e,t)=>{n.forEach(((n,r)=>{n.addEventListener("click",(()=>{s(e.internalEngine(),r,t)}),!1)}))})(e,f,a),f.on("init",t),f.on("select",t)}if("scale"==o.transition||"parallax"==o.transition){const n=o.param||("scale"==o.transition?2:.75),e=v(f,"scale"==o.transition?p:g,n);f.on("init",e),f.on("scroll",e)}if("logo"==o.type){const n=((n,e,t)=>()=>{t&&t.stop(),e.classList.remove("all-in-view"),n.scrollTo(0,!0);const o=n.slidesNotInView().length;r&&console.info("Slider.checkAutoplay() Slides not in view: "+o),o>0?(n.reInit({active:!0}),t&&t.play()):(e.classList.add("all-in-view"),n.reInit({active:!1}))})(f,t,a);f.on("init",n),f.on("resize",n)}t.addEventListener("keydown",(n=>{switch(n.key){case"ArrowLeft":f.scrollPrev();break;case"ArrowRight":f.scrollNext()}}))}))}function h(n,e){(r=e)&&console.info("Slider.init()");let t=document.querySelectorAll(".use-embla-slider");r&&console.info("Slider.init() .use-embla-slider elements found: "+t.length),t.length>0&&m(t)}}}]);
//# sourceMappingURL=mercury-slider.js.map