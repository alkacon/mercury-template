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

// this is taken straight from the jQuery docs:
// http://api.jquery.com/jQuery.getScript/
jQuery.loadScript = function( url, options, DEBUG ) {

    if (DEBUG) console.info("Loading script from url: " + url);

    // Allow user to set any option except for dataType, cache, and url
    options = jQuery.extend( options || {}, {
        dataType: "script",
        cache: true,
        url: url
    });

    // Use jQuery.ajax() since it is more flexible than jQuery.getScript
    // Return the jqXHR object so we can chain callbacks
    return jQuery.ajax( options );
};


jQuery.fn.visible = function( partial ) {

    var $element = jQuery(this);
    var _top = $element.offset().top;
    var _bottom = _top + $element.height();
    var compareTop = partial === true ? _bottom : _top;
    var compareBottom = partial === true ? _top : _bottom;

    return ((compareTop >= Mercury.windowScrollTop()) &&
            (compareBottom - 100 <= (Mercury.windowScrollTop() + Mercury.windowHeight())));
};


// Checks is the bottom of an element is visible
jQuery.fn.bottomVisible = function() {

    var $element = jQuery(this);
    var elementBottom = $element.offset().top + $element.height();
    return elementBottom >= Mercury.windowScrollTop();
};

// Get the path to an element, good for debugging messages.
// see http://stackoverflow.com/questions/5442767/returning-the-full-path-to-an-element
jQuery.fn.getFullPath = function(){

    return $(this).parentsUntil('body')
        .addBack()
        .map(function() {
            var index = $(this).index();
            return this.nodeName + '[' + index + ']';
        }).get().join('>');
};


// Acessing object path by String value
// see: http://stackoverflow.com/questions/6491463/accessing-nested-javascript-objects-with-string-key
Object.byString = function(o, s) {
    s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
    s = s.replace(/^\./, '');           // strip a leading dot
    var a = s.split('.');
    for (var i = 0, n = a.length; i < n; ++i) {
        var k = a[i];
        if (k in o) {
            o = o[k];
        } else {
            return;
        }
    }
    return o;
}