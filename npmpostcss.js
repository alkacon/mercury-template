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

'use strict';

var path = require('path');
var packageConfig = require('./package.json');

// target path of the generated CSS in OpenCms
var deployTargetVfsDir = packageConfig.config.deployTargetVfsDir ? packageConfig.config.deployTargetVfsDir : "/system/modules/alkacon.mercury.theme/css/";

// the folder where the static template resources are located
var mercuryBaseVfsDir =  packageConfig.config.mercuryBaseVfsDir ? packageConfig.config.mercuryBaseVfsDir : "/system/modules/alkacon.mercury.theme/";

// function to calculate the relative file path for the generated CSS to the static template folder in the OpenCms VFS
// it's is required to use relative paths here to make sure static export works as expected
exports.resourcePath = function(target) {
    var resPath = path.normalize(path.relative(deployTargetVfsDir, mercuryBaseVfsDir) + '/'
            + target)
    if (path.sep == '\\') {
        resPath = resPath.replace(/\\/g, '/');
    }
    console.log('Rewriting path:' + target + ' to:' + resPath);
    return resPath;
}

console.log('#');
console.log('# Mercury deploy target : ' + deployTargetVfsDir);
console.log('# Mercury base directory: ' + mercuryBaseVfsDir);
console.log('#');
