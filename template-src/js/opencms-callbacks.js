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
 * Callbacks to update the OpenCms edit points when the screen element change.
 */

export function _OpenCmsReinitEditButtons(DEBUG) {

    if (DEBUG) console.info('OpenCmsReinitEditButtons() called!');
    if (typeof opencms != 'undefined' && typeof opencms.reinitializeEditButtons === 'function') {
        opencms.reinitializeEditButtons();
    } else if (DEBUG) {
        console.info('OpenCmsReinitEditButtons(): Edit button re-init function not available!');
    }
}


export function _OpenCmsInit(jQuery, DEBUG) {

    // accordion
    jQuery('.accordion').on('shown.bs.collapse', function() {

        if (DEBUG) console.info('Event handler .accordion(shown.bs.collapse) triggered!');
        _OpenCmsReinitEditButtons(DEBUG);
    })

    jQuery('.accordion').on('hidden.bs.collapse', function() {

        if (DEBUG) console.info('Event handler .accordion(hidden.bs.collapse) triggered!');
        _OpenCmsReinitEditButtons(DEBUG);
    })

    // tabs
    jQuery('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {

        if (DEBUG) console.info('Event handler a[data-toggle=tab](shown.bs.tab) triggered!');
        _OpenCmsReinitEditButtons(DEBUG);
    })

    jQuery('a[data-toggle="tab"]').on('hidden.bs.tab', function(e) {

        if (DEBUG) console.info('Event handler a[data-toggle=tab](hidden.bs.tab) triggered!');
        _OpenCmsReinitEditButtons(DEBUG);
    })
}
