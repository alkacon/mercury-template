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

import flatpickr from "flatpickr";
import { German } from "flatpickr/dist/l10n/de.js"

"use strict";

/****** Exported functions ******/

export function init() {

    let locale = Mercury.getLocale();
    let isGerman = false;
    if (locale != "en") {
        locale = locale.substr(0, 2).toLowerCase();
        if (locale == "de") {
            flatpickr.localize( German );
            isGerman = true;
        }
    }

    if (Mercury.debug()) console.info("DatePicker.init()");

    const datepickers = document.querySelectorAll(".datepicker");
    if (Mercury.debug()) console.info("DatePicker.init() .datepicker elements found: " + datepickers.length);

    datepickers.forEach(function(datepicker) {
        const config = datepicker.dataset["datepicker"] ? datepicker.dataset["datepicker"] : "{}";
        if (Mercury.debug()) console.info("DatePicker config: " + config);
        const jsonConfig = JSON.parse(config);
        if(jsonConfig.dateFormat == null) {
            if(jsonConfig.enableTime == true) {
                const noCalendar = jsonConfig.noCalendar == true;
                if (isGerman) {
                    jsonConfig.dateFormat = noCalendar ? "H:i" : "d.m.Y H:i"
                } else {
                    jsonConfig.dateFormat = noCalendar ? "H:i" : "Y-m-d H:i"
                }
            } else {
                if (isGerman) {
                    jsonConfig.dateFormat = "d.m.Y"
                } else {
                    jsonConfig.dateFormat = "Y-m-d"
                }

            }
        }
        flatpickr(datepicker, jsonConfig);
    });
}