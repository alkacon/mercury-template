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

/**
 * Script to reveal / unobfuscate an Email that was obfuscated using the <mercury:obfuscate> tag.
 */
function unobfuscateString(scramble, mailto) {

    "use strict";

    var del = scramble.lastIndexOf('/') + 1;
    scramble = scramble.substr(del, scramble.length - del - 1);
    var result = '';
    var codes = scramble.split(';');
    for (var j = 0; j < codes.length; j++) {
        if (codes[j].length > 1) {
            var ch = String.fromCharCode(parseInt(codes[j], 16));
            result = result + ch;
        }
    }
    result = result.replace(/\[SCRAMBLE\]/g, '.').replace(/\{SCRAMBLE\}/g, '@').split('').reverse().join('');
    if (mailto) {
        window.location.href = "mailto:" + result;
    } else {
        return result;
    }
}

window.unobfuscateString = unobfuscateString;
