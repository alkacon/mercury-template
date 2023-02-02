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

"use strict";

const ICON_CACHE = new Map ();
const EL_CACHE = new Map();

let ICON_FOLDER = null;

function replaceIcons(svgData, faElements, iconName) {
    if (Mercury.debug()) console.info("Icons.replaceIcons: Replacing fa-".concat(iconName).concat(faElements.length > 1 ?  " ".concat(faElements.length).concat(" times.") : ""));
    for (const faElement of faElements) {
        faElement.classList.add("ico", "ico-svg", "ico-replaced", "ico-fa-".concat(iconName));
        faElement.classList.remove("fa", "fab", "fas", "fa-".concat(iconName));
        faElement.innerHTML = svgData;
    }
}

function loadIcons(faElements) {
    for (const faEl of faElements) {
        if (!faEl.classList.contains("ico")) {
            if ("none" != window.getComputedStyle(faEl, '::before').content) {
                // this icon is part of the reduced awesome font, no need to load SVG
                faEl.classList.add("ico");
            } else {
                const faClIter = faEl.classList.values();
                for (const faClass of faClIter) {
                    if (faClass.startsWith("fa-")) {
                        const iconName = faClass.substring(3);
                        if (ICON_CACHE.has(iconName)) {
                            replaceIcons(ICON_CACHE.get(iconName), [faEl], iconName)
                        } else if (EL_CACHE.has(iconName)) {
                            EL_CACHE.get(iconName).push(faEl);
                        } else {
                            EL_CACHE.set(iconName, [faEl]);
                        }
                    }
                }
            }
        }
    }
    for (const [iconName, faEls] of EL_CACHE) {
        EL_CACHE.delete(iconName);
        let iconPath = ICON_FOLDER.concat(iconName).concat(".svg");
        fetch(iconPath, { cache: "force-cache" })
            .then(response => {
                if (response.ok) return response.text();
                throw Error();
            })
            .then(text => {
                ICON_CACHE.set(iconName, text)
                replaceIcons(text, faEls, iconName);
            })
            .catch(error => {
                console.log("Icons.loadIcons: Unable to load icon fa fa-".concat(iconName))
                for (const faEl of faEls) {
                    faEl.classList.add('ico-load-error');
                }
            })
        break;
    }
}

function mutateIcons(mutations) {
    const faElements = [];
    for (const { addedNodes } of mutations) {
        for (const node of addedNodes) {
            if (!node.tagName) continue;
            if ((node.classList.contains('fa') || node.classList.contains('fab') || node.classList.contains('fas')) && !node.classList.contains('ico')) {
                faElements.push(node);
            } else if (node.firstElementChild) {
                faElements.push(...node.getElementsByClassName('fa'));
                faElements.push(...node.getElementsByClassName('fab'));
                faElements.push(...node.getElementsByClassName('fas'));
            }
        }
    }
    if (faElements.length > 0) {
        if (Mercury.debug()) console.info("Icons.mutateIcons: ".concat(faElements.length).concat(" .fa/.fab/.fas elements found after mutation!"));
    }
    loadIcons(faElements);
}

/****** Exported functions ******/

export function init(iconPath, fullIcons) {

    ICON_FOLDER = window.atob(iconPath).slice(0, -6);
    if (Mercury.debug()) console.info("Icons.init() source: ".concat(ICON_FOLDER));

    const faElements = document.querySelectorAll(".fa:not(.ico)");

    if ((faElements.length > 80) && (fullIcons != null)) {
        // using 80 because of calendar lists
        if (Mercury.debug()) console.info("Icons.init: Using font - ".concat(faElements.length).concat(" .fa:not(.ico) elements found after page load!"));
        Mercury.loadCss(window.atob(fullIcons));

    } else {

        if (faElements.length > 0) {
            if (Mercury.debug()) console.info("Icons.init: ".concat(faElements.length).concat(" .fa:not(.ico) elements found after page load!"));
            loadIcons(faElements);
        }

        new MutationObserver((mutations) => {
            mutateIcons(mutations);
        }).observe(document, {
            childList: true,
            subtree: true,
            attributes: true
        });
    }
}

