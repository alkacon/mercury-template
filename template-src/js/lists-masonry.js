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

import Masonry from 'masonry-layout';

"use strict";

function createMasonryList(listId, listSelector) {

    if (Mercury.debug()) console.info("MasonryList.createMasonryList(" + listId + ")");
    return new Masonry('#' + listId + listSelector, {
        itemSelector: '.tile-col',
        percentPosition: true
    });
}

/****** Exported functions ******/

export function init() {

    if (Mercury.debug()) console.info("MasonryList.init()");

    const listElements = document.querySelectorAll('.masonry-list .list-dynamic');
    if (Mercury.debug()) console.info("MasonryList.init() .masonry-list .list-dynamic elements found: " + listElements.length);
    for (const listElement of listElements) {
        listElement.addEventListener("list:loaded", function(e) {
            const listId = e.target.getAttribute('id');
            createMasonryList(listId, " .list-entries");
        });
    }

    const imageseriesElements = document.querySelectorAll('.masonry-list .series');
    if (Mercury.debug()) console.info("MasonryList.init() .masonry-list .series elements found: " + imageseriesElements.length);
    for (const listElement of imageseriesElements) {
        listElement.addEventListener("imageseries:loaded", function(e) {
            const listId = e.target.getAttribute('id');
            createMasonryList(listId, " .images");
        });
    }
}