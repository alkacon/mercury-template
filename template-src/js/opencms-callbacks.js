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

export function _OpenCmsReinitEditButtons() {

    if (Mercury.debug()) console.info('OpenCmsReinitEditButtons() called!');
    if (typeof opencms != 'undefined' && typeof opencms.reinitializeEditButtons === 'function') {
        opencms.reinitializeEditButtons();
    } else if (Mercury.debug()) {
        console.info('OpenCmsReinitEditButtons(): Edit button re-init function not available!');
    }
}


export function _OpenCmsInit() {

    // accordion
    document.querySelectorAll('.accordion .collapse, .collapse-parent .collapse').forEach(function(el) {
        el.addEventListener('shown.bs.collapse', event => {
            if (Mercury.debug()) console.info('Event handler accordion(shown.bs.collapse) triggered!');
            _OpenCmsReinitEditButtons();
        });
        el.addEventListener('hidden.bs.collapse', event => {
            if (Mercury.debug()) console.info('Event handler accordion(hidden.bs.collapse) triggered!');
            _OpenCmsReinitEditButtons();
        });
    });

    // tabs
    document.querySelectorAll('button[data-bs-toggle="tab"]').forEach(function(el) {
        el.addEventListener('shown.bs.tab', event => {
            if (Mercury.debug()) console.info('Event handler tab(shown.bs.tab) triggered!');
            _OpenCmsReinitEditButtons();
        });
        el.addEventListener('hidden.bs.tab', event => {
            if (Mercury.debug()) console.info('Event handler tab(hidden.bs.tab) triggered!');
            _OpenCmsReinitEditButtons();
        });
    });
}
