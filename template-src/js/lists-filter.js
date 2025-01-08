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
 * Text search filter
 */
class TextSearch {

    /**
     * Creates a new text search filter.
     * @param element the HTML element
     * @param parent the parent filter
     */
    constructor(element, parent) {
        this.element = element;
        this.parent = parent;
    }

    /**
     * Returns the URL parameters for the current filter selection with count information.
     * @return the URL parameters for the current filter selection with count information
     */
    getCountFilterParams() {

        return "&s=" + encodeURIComponent(this.parent.id);
    }

    /**
     * Returns the URL parameters for the current filter selection.
     * @return the URL parameters for the current filter selection
     */
    getFilterParams() {

        const query = this.element.value;
        if (query) {
            return "&" + this.element.getAttribute("name") + "=" + encodeURIComponent(query);
        }
        return "";
    }

    /**
     * Returns the reset buttons for the current filter selection.
     * @return the reset buttons for the current filter selection
     */
    getResetButtons() {

        const query = this.element.value;
        if (query) {
            const buttonTitle = this.parent.data.resetbuttontitle;
            return [DynamicList.generateInputFieldResetButton(this.parent.id, buttonTitle)];
        }
        return [];
    }
}

/**
 * Archive filter
 */
class ArchiveFilter {

    /**
     * Creates a new archive filter.
     * @param element the HTML element
     * @param parent the parent filter
     */
    constructor(element, parent) {

        this.element = element;
        this.parent = parent;
    }

    /**
     * Returns the URL parameters for the current filter selection with count information.
     * @return the URL parameters for the current filter selection with count information
     */
    getCountFilterParams() {

        return "&a=" + encodeURIComponent(this.parent.id);
    }

    /**
     * Returns the URL parameters for the current filter selection.
     * @param countInfo whether to request count information
     * @param triggerId the id of the element that triggered the filter selection
     * @return the URL parameters for the current filter selection
     */
    getFilterParams(countInfo = false, triggerId) {

        const triggerElement = this.element.querySelector("#" + triggerId);
        if (triggerId && triggerElement && triggerElement.classList.contains("active")) {
            return "";
        }
        const elements = triggerId ? (triggerElement ? [triggerElement] : []) : this.element.querySelectorAll(".active");
        const parentId = this.parent.id;
        const paramkey = this.parent.data.archiveparamkey;
        let params = "";
        elements.forEach((element) => {
            const value = element.dataset.value;
            if (value) {
                params += "&";
                if (countInfo) {
                    params += "facet_" + encodeURIComponent(parentId + "_a");
                } else {
                    params += paramkey;
                }
                params += "=" + encodeURIComponent(value);
            }
        });
        return params;
    }

    /**
     * Returns the reset buttons for the current filter selection.
     * @return the reset buttons for the current filter selection
     */
    getResetButtons() {

        const self = this;
        const resetButtons = [];
        this.element.querySelectorAll(".active").forEach((element) => {
            const buttonTitle = self.parent.data.resetbuttontitle;
            resetButtons.push(DynamicList.generateResetButton(element, buttonTitle));
        });
        return resetButtons;
    }

    /**
     * Updates the filter counts for the current filter selection.
     * @param elementFacets element facets map with date as key and count as value
     */
    updateFilterCounts(elementFacets) {

        this.element.querySelectorAll("li[data-value]").forEach((li) => {
            const value = li.dataset.value;
            let count = elementFacets[value];
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
}

/**
 * Category filter
 */
class CategoryFilter {

    /**
     * Creates a new category filter.
     * @param element the HTML element
     * @param parent the parent filter
     */
    constructor(element, parent) {

        this.element = element;
        this.parent = parent;
    }

    /**
     * Returns the URL parameters for the current filter selection with count information.
     * @return the URL parameters for the current filter selection with count information
     */
    getCountFilterParams() {

        return "&c=" + encodeURIComponent(this.parent.id);
    }

    /**
     * Returns the URL parameters for the current filter selection.
     * @param countInfo whether to request count information
     * @param triggerId the id of the element that triggered the filter selection
     * @return the URL parameters for the current filter selection
     */
    getFilterParams(countInfo = false, triggerId) {

        const triggerElement = this.element.querySelector("#" + triggerId);
        if (triggerId && triggerElement && triggerElement.classList.contains("active")) {
            return "";
        }
        const elements = triggerId ? (triggerElement ? [triggerElement] : []) : this.element.querySelectorAll(".active");
        const parentId = this.parent.id;
        const paramkey = this.parent.data.catparamkey;
        let params = "";
        elements.forEach((element) => {
            const value = element.dataset.value;
            if (value) {
                params += "&";
                if (countInfo) {
                    params += "facet_" + encodeURIComponent(parentId + "_c");
                } else {
                    params += paramkey;
                }
                params += "=" + encodeURIComponent(value);
            }
        });
        return params;
    }

    /**
     * Returns the reset buttons for the current filter selection.
     * @return the reset buttons for the current filter selection
     */
    getResetButtons() {

        const self = this;
        const resetButtons = [];
        this.element.querySelectorAll(".active").forEach((element) => {
            const buttonTitle = self.parent.data.resetbuttontitle;
            if (!element.classList.contains("levelAll")) {
                resetButtons.push(DynamicList.generateResetButton(element, buttonTitle));
            }
        });
        return resetButtons;
    }

    /**
     * Updates the filter counts for the current filter selection.
     * @param elementFacets element facets map with date as key and count as value
     */
    updateFilterCounts(elementFacets) {

        this.element.querySelectorAll("li[data-value]").forEach((li) => {
            const value = li.dataset.value;
            let count = elementFacets[value];
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
}

/**
 * Folder filter
 */
class FolderFilter {

    /**
     * Creates a new folder filter.
     * @param element the HTML element
     * @param parent the parent filter
     */
    constructor(element, parent) {

        this.element = element;
        this.parent = parent;
    }

    /**
     * Returns the URL parameters for the current filter selection with count information.
     * @return the URL parameters for the current filter selection with count information
     */
    getCountFilterParams() {

        return "&f=" + encodeURIComponent(this.parent.id);
    }

    /**
     * Returns the URL parameters for the current filter selection.
     * The folder filter is a bit tricky, here currenpage is on
     * each item, with a parent folder of the clicked on
     * but only the clicked one should be set
     * so we only take the parameter with the longest path
     * into account
     * @param countInfo whether to request count information
     */
    getFilterParams(countInfo = false, triggerId) {

        const triggerElement = this.element.querySelector("#" + triggerId);
        if (triggerId && triggerElement && triggerElement.classList.contains("active")) {
            return "";
        }
        const elements = triggerId ? (triggerElement ? [triggerElement] : []) : this.element.querySelectorAll("li.currentpage");
        const parentId = this.parent.id;
        const paramkey = this.parent.data.folderparamkey;
        let params = "";
        elements.forEach((element) => {
            let p = "";
            const value = element.dataset.value;
            if (value) {
                p += "&";
                if (countInfo) {
                    p += "facet_" + encodeURIComponent(parentId + "_f");
                } else {
                    p += paramkey;
                }
                p += "=" + encodeURIComponent(value);
            }
            if (p.length > params.length) {
                params = p;
            }
        });
        return params;
    }

    /**
     * Returns the reset buttons for the current filter selection.
     * @return the reset buttons for the current filter selection
     */
    getResetButtons() {

        const self = this;
        let params = "";
        let checkedElement;
        const resetButtons = [];
        this.element.querySelectorAll("li.currentpage").forEach((element) => {
            let p = self.getFilterParams(false, element.id);
            if (p.length > params.length) {
                params = p;
                checkedElement = element;
            }
        });
        if (checkedElement !== undefined) {
            const buttonTitle = self.parent.data.resetbuttontitle;
            resetButtons.push(DynamicList.generateResetButton(checkedElement, buttonTitle));
        }
        return resetButtons;
    }

    /**
     * Updates the filter counts for the current filter selection.
     * @param elementFacets element facets map with date as key and count as value
     */
    updateFilterCounts(elementFacets) {

        this.element.querySelectorAll("li[data-value]").forEach((li) => {
            const value = li.dataset.value;
            const count = elementFacets[value];
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
 * Standard Mercury list filters.
 * <li>Text search filter
 * <li>Category filter
 * <li>Archive filter
 * <li>Folder filter
 */
class ListFilter {

    /**
     * Creates a new list filter.
     * @param element the HTML element
     */
    constructor(element) {
        this.element = element;
        this._data = null;
        if (this.data.search == "true") {
            this.textSearch = new TextSearch(this.element.querySelector("#textsearch_" + this.id), this);
        }
        if (this.data.categories == "true") {
            this.categoryFilter = new CategoryFilter(this.element.querySelector("#cats_" + this.id), this);
        }
        if (this.data.archive == "true") {
            this.archiveFilter = new ArchiveFilter(this.element.querySelector("#arch_" + this.id), this);
        }
        if (this.data.folders == "true") {
            this.folderFilter = new FolderFilter(this.element.querySelector("#folder_" + this.id), this);
        }
        this.directlink = this.element.querySelector(".directlink");
    }

    /**
     * Laziliy initializes and returns the dataset value as JSON.
     * @return the dataset value as JSON
     */
    get data() {

        if (!this._data) {
            const filterData = this.element.dataset.filter;
            this._data = JSON.parse(filterData);
        }
        return this._data;
    }

    /**
     * Returns the element id of this filter.
     * @return the element id of this filter
     */
    get elementId() {

        return this.element.dataset.id;
    }

    /**
     * Returns whether this filter can have reset buttons.
     * @return whether this filter can have reset buttons
     */
    get hasResetButtons() {

        return this.element.querySelector("#resetbuttons_" + this.id) !== null;
    }

    /**
     * Returns the id of this filter.
     * @return the id of this filter
     */
    get id() {

        return this.element.getAttribute("id");
    }

    /**
     * Returns the URL parameters for the current filter selection.
     * @param countInfo whether to request count information
     * @param triggerId the id of the element that triggered the filter selection
     * @return the URL parameters for the current filter selection
     */
    getFilterParams(countInfo = false, triggerId) {
    
        let params = "";
        if (this.textSearch) {
            params += this.textSearch.getFilterParams();
        }
        if (this.categoryFilter) {
            params += this.categoryFilter.getFilterParams(countInfo, triggerId);
        }
        if (this.archiveFilter) {
            params += this.archiveFilter.getFilterParams(countInfo, triggerId);
        }
        if (this.folderFilter) {
            params += this.folderFilter.getFilterParams(countInfo, triggerId);
        }
        return params;
    }

    /**
     * Returns the URL parameters for the current filter selection with count information.
     * @return the URL parameters for the current filter selection with count information
     */
    getCountFilterParams() {
    
        let params = this.getFilterParams(true);
        // Tell which filters are shown in the current filter element
        if (this.textSearch) {
            params += this.textSearch.getCountFilterParams();
        }
        if (this.categoryFilter) {
            params += this.categoryFilter.getCountFilterParams();
        }
        if (this.archiveFilter) {
            params += this.archiveFilter.getCountFilterParams();
        }
        if (this.folderFilter) {
            params += this.folderFilter.getCountFilterParams();
        }
        return params;
    }

    /**
     * Returns the reset buttons for the current filter selection.
     * @return the reset buttons for the current filter selection
     */
    getResetButtons() {
    
        let resetButtons = [];
        if (this.textSearch) {
            resetButtons = resetButtons.concat(this.textSearch.getResetButtons());
        }
        if (this.categoryFilter) {
            resetButtons = resetButtons.concat(this.categoryFilter.getResetButtons());
        }
        if (this.archiveFilter) {
            resetButtons = resetButtons.concat(this.archiveFilter.getResetButtons());
        }
        if (this.folderFilter) {
            resetButtons = resetButtons.concat(this.folderFilter.getResetButtons());
        }
        return resetButtons;
    }

    /**
     * Updates the direct link with the actual search state parameters.
     * @param searchStateParameters the actual search state parameters
     */
    updateDirectLink(searchStateParameters) {

        const element = this.element.querySelector(".directlink");
        if (!element) {
            return;
        }
        const link = element.querySelector("a");
        if (!link) {
            return;
        }
        var url = link.getAttribute("href");
        if (url && url.indexOf("?") >= 0) {
            url = url.substring(0, url.indexOf("?"));
        }
        link.setAttribute("href", url + "?" + searchStateParameters);
    }

    /**
     * Updates the filter counts for the current filter selection.
     * @param elementFacets element facets map with date as key and count as value
     */
    updateFilterCounts(elementFacets) {

        if (this.categoryFilter && elementFacets["c"]) {
            this.categoryFilter.updateFilterCounts(elementFacets["c"]);
        }
        if (this.archiveFilter && elementFacets["a"]) {
            this.archiveFilter.updateFilterCounts(elementFacets["a"]);
        }
        if (this.folderFilter && elementFacets["f"]) {
            this.folderFilter.updateFilterCounts(elementFacets["f"]);
        }
    }
}

/**
 * Initializes the list filters.
 */
export function init() {

    const listFilters = document.querySelectorAll(".type-list-filter");
    if (Mercury.debug()) {
        console.info("Lists.init() .type-list-filter elements found: " + listFilters.length);
    }
    listFilters.forEach((element) => {
        const listFilter = new ListFilter(element);
        const register = DynamicList.registerFilter(listFilter);
        if (register !== undefined && Mercury.debug()) {
            console.info("Lists.init() .type-list-filter data found - id=" + listFilter.id + ", elementId=" + listFilter.elementId);
        } else if (Mercury.debug()) {
            console.info("Lists.init() .type-list-filter found without data, ignoring!");
        }
    });
}
