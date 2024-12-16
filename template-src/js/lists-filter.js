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

// the global objects that must be passed to this module
/** @type {jQuery} jQuery object */
let jQ;

/**
 * Returns the URL parameters for the current filter selection.
 */
function getFilterParams() {

    let params = "";
    const filter = this;
    // text search
    const query = filter.$textsearch.val();
    if (query !== undefined && query != "") {
        params += "&" + filter.$textsearch.attr("name") + "=" + encodeURIComponent(query);
    }
    filter.$element.find(".active").each( function() {
        params += DynamicList.calculateStateParameter(filter, this.id, false);
    });
    // Folder is a bit tricky, here currenpage is on
    // each item, with a parent folder of the clicked on
    // but only the clicked one should be set
    // so we only take the parameter with the longest path
    // into account
    let pageP = "";
    filter.$element.find("li.currentpage").each( function() {
        const p = DynamicList.calculateStateParameter(filter, this.id, false);
        if (p.length > pageP.length) {
            pageP = p;
        }
    });
    params += pageP;
    return params;
}

/**
 * Returns the URL parameters for the current filter selection with count information.
 */
function getCountFilterParams() {

    const filter = this;
    let params = "";
    const query = filter.$textsearch.val();
    if (query !== undefined && query != "") {
        params +=
            "&" +
            filter.$textsearch.attr("name") +
            "=" +
            encodeURIComponent(query);
    }
    filter.$element.find(".active").each(function() {
        params += DynamicList.calculateStateParameter(filter, this.id, false, true);
    });
    let pageP = "";
    filter.$element.find("li.currentpage").each(function() {
        const p = DynamicList.calculateStateParameter(filter, this.id, false, true);
        if (p.length > pageP.length) {
            pageP = p;
        }
    });
    params += pageP;
    // Tell which filters are shown in the current filter element
    if (filter.search == "true") {
        params += "&s=" + encodeURIComponent(filter.id);
    }
    if (filter.categories == "true") {
        params += "&c=" + encodeURIComponent(filter.id);
    }
    if (filter.archive == "true") {
        params += "&a=" + encodeURIComponent(filter.id);
    }
    if (filter.folders == "true") {
        params += "&f=" + encodeURIComponent(filter.id);
    }
    return params;
}

/**
 * Returns the reset buttons for the current filter selection.
 */
function getResetButtons() {

    const filter = this;
    const resetButtons = [];
    const query = filter.$textsearch.val();
    if (query !== undefined && query != "") {
        resetButtons.push(DynamicList.generateInputFieldResetButton(filter.id, filter.resetbuttontitle));
    }
    filter.$element.find(".active").each(function() {
        resetButtons.push(DynamicList.generateResetButton(this, filter.resetbuttontitle));
    });
    let pageP = "";
    let checkedElement;
    filter.$element.find("li.currentpage").each(function() {
        let p = DynamicList.calculateStateParameter(filter, this.id, false, true);
        if (p.length > pageP.length) {
            pageP = p;
            checkedElement = this;
        }
    });
    if (checkedElement !== undefined) {
        resetButtons.push(DynamicList.generateResetButton(checkedElement, filter.resetbuttontitle));
    }
    return resetButtons;
}

/**
 * Updates the filter counts for the current filter selection.
 */
function updateFilterCounts(elementFacets) {

    const filter = this;
    const archiveFilter = elementFacets["a"];
    const categoryFilter = elementFacets["c"];
    const folderFilter = elementFacets["f"];
    if (archiveFilter != null) {
        const $el = filter.$element.find(".archive");
        $el.find("li[data-value]").each(function(_, li) {
            const val = li.getAttribute("data-value");
            let count = archiveFilter[val];
            if (count == null) {
                count = "0";
            }
            const countSpan = li.querySelector(".li-count");
            const isDisabled = li.classList.contains("disabled");
            if (countSpan != undefined && countSpan.textContent !== count) { // change the count
                countSpan.textContent = count;
            }
            if (isDisabled && count !== "0" || !isDisabled && count === "0") { // enabled / disable
                if (count === "0") {
                    li.setAttribute("data-onclick", li.getAttribute("onclick"));
                    li.removeAttribute("onclick");
                    li.setAttribute("tabindex", "-1");
                    li.classList.remove("enabled");
                    li.classList.add("disabled");
                } else {
                    li.setAttribute("onclick", li.getAttribute("data-onclick"));
                    li.removeAttribute("data-onclick");
                    li.setAttribute("tabindex", "0");
                    li.classList.remove("disabled");
                    li.classList.add("enabled");
                }
            }
        });
    }
    if (categoryFilter != null) {
        const $catEl = filter.$element.find(".categories");
        $catEl.find("li[data-value]").each(function(_, li) {
            const val = li.getAttribute("data-value");
            let count = categoryFilter[val];
            if (count == null) {
                count = "0";
            };
            const countSpan = li.querySelector(".li-count");
            const isDisabled = li.classList.contains("disabled");
            if (countSpan != undefined && countSpan.textContent !== count) { // change the count
                countSpan.textContent = count;
            }
            if (isDisabled && count !== "0" || !isDisabled && count === "0") { // enabled / disable
                const a = li.querySelector("a");
                if (count == "0") {
                    a.setAttribute("tabindex", "-1");
                    li.classList.remove("enabled");
                    li.classList.add("disabled");
                } else {
                    a.setAttribute("tabindex", "0");
                    li.classList.remove("disabled");
                    li.classList.add("enabled");
                }
            }
        });
    }
    if (folderFilter != null) {
        const $catEl = filter.$element.find(".folders");
        $catEl.find("li[data-value]").each(function(_, li) {
            const val = li.getAttribute("data-value");
            const count = folderFilter[val];
            const shouldDisable = (null == count || count == "0");
            const isDisabled = li.classList.contains("disabled");
            if (isDisabled != shouldDisable) {
                const a = li.querySelector("a");
                if (shouldDisable) {
                    a.setAttribute("tabindex", "-1");
                    li.classList.remove("enabled");
                    li.classList.add("disabled");
                } else {
                    a.setAttribute("tabindex", "0");
                    li.classList.remove("disabled");
                    li.classList.add("enabled");
                }
            }
        });
    }
}

/**
 * Initialize the list filters.
 */
export function init(jQuery) {

    jQ = jQuery;
    const $listArchiveFilters = jQ(".type-list-filter");
    if (Mercury.debug()) {
        console.info("Lists.init() .type-list-filter elements found: " + $listArchiveFilters.length);
    }
    if ($listArchiveFilters.length > 0) {
        $listArchiveFilters.each(function() {
            let filter = DynamicList.registerFilter(this, getFilterParams, getCountFilterParams, getResetButtons, updateFilterCounts);
            if (filter !== undefined) {
                const $archiveFilter = jQ(this);
                filter.$textsearch = $archiveFilter.find("#textsearch_" + filter.id);
                filter.$directlink = $archiveFilter.find(".directlink");
                // unfold categories if on desktop and responsive setting is used
                const $collapses = $archiveFilter.find("#cats_" + filter.id + ", #folder_" + filter.id  + ", #arch_" + filter.id);
                if ($collapses.length > 0) {
                    if (Mercury.debug()) {
                        console.info("Lists.init() collapse elements found for filter id " + filter.id + ": " + $collapses.length);
                    }
                    $collapses.each(function() {
                        const $collapse = jQ(this);
                        if (($collapse.hasClass("op-lg") && Mercury.gridInfo().isMinLg())
                            || ($collapse.hasClass("op-md") && Mercury.gridInfo().isMinMd())
                            || ($collapse.hasClass("op-sm") && Mercury.gridInfo().isMinSm())) {
                            $collapse.collapse("show");
                        }
                    });
                }
                // attach key listeners for keyboard support
                $archiveFilter.find("li > a").on("keydown", function(e) {
                    if (e.type == "keydown" && (e.which == 13 || e.which == 32)) {
                        jQ(this).click();
                        e.preventDefault();
                    }
                });
                if (Mercury.debug()) {
                    console.info("Lists.init() .type-list-filter data found - id=" + filter.id + ", elementId=" + filter.elementId);
                }
            } else {
                if (Mercury.debug()) {
                    console.info("Lists.init() .type-list-filter found without data, ignoring!");
                }
            }
        });
    }
}
