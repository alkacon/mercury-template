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
 * Abstract class for filter boxes.
 */
class A_ListFilterBox {

    constructor($element) {
        // unfold categories if on desktop and responsive setting is used
        if ($element) {
            if (Mercury.debug()) {
                console.info("Lists.init() collapse elements found for filter id " + this.id + ": " + $collapses.length);
            }
            if (($element.hasClass("op-lg") && Mercury.gridInfo().isMinLg())
                || ($element.hasClass("op-md") && Mercury.gridInfo().isMinMd())
                || ($element.hasClass("op-sm") && Mercury.gridInfo().isMinSm())) {
                $element.collapse("show");
            }
        }
        // attach key listeners for keyboard support
        $element.find("li > a").on("keydown", function(e) {
            if (e.type == "keydown" && (e.which == 13 || e.which == 32)) {
                jQ(this).click();
                e.preventDefault();
            }
        });
    }
}


/**
 * Text search filter
 */
class TextSearch {

    /**
     * Creates a new text search filter.
     */
    constructor($element, parent) {
        this.$element = $element;
        this.parent = parent;
    }

    /**
     * Returns the URL parameters for the current filter selection with count information.
     */
    getCountFilterParams() {

        return "&s=" + encodeURIComponent(this.parent.id);
    }

    /**
     * Returns the URL parameters for the current filter selection.
     */
    getFilterParams() {
    
        const query = this.$element.val();
        if (query) {
            return "&" + this.$element.attr("name") + "=" + encodeURIComponent(query);
        }
        return "";
    }

    /**
     * Returns the reset buttons for the current filter selection.
     */
    getResetButtons() {

        const query = this.$element.val();
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
class ArchiveFilter extends A_ListFilterBox {

    /**
     * Creates a new archive filter.
     */
    constructor($element, parent) {
        super($element);
        this.$element = $element;
        this.parent = parent;
    }

    /**
     * Returns the URL parameters for the current filter selection with count information.
     */
    getCountFilterParams() {

        return "&a=" + encodeURIComponent(this.parent.id);
    }

    /**
     * Returns the URL parameters for the current filter selection.
     */
    getFilterParams(countInfo = false) {

        let self = this;
        let params = "";
        this.$element.find(".active").each(function() {
            params += DynamicList.calculateStateParameter(self.parent.data, this.id, false, countInfo);
        });
        return params;
    }

    /**
     * Returns the reset buttons for the current filter selection.
     */
    getResetButtons() {

        const self = this;
        const resetButtons = [];
        this.$element.find(".active").each(function() {
            const buttonTitle = self.parent.data.resetbuttontitle;
            resetButtons.push(DynamicList.generateResetButton(this, buttonTitle));
        });
        return resetButtons;
    }

    /**
     * Updates the filter counts for the current filter selection.
     */
    updateFilterCounts(elementFacets) {

        this.$element.find("li[data-value]").each(function(_, li) {
            const val = li.getAttribute("data-value");
            let count = elementFacets[val];
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

class CategoryFilter extends A_ListFilterBox {

    /**
     * Creates a new category filter.
     */
    constructor($element, parent) {
        super($element);
        this.$element = $element;
        this.parent = parent;
    }

    /**
     * Returns the URL parameters for the current filter selection with count information.
     */
    getCountFilterParams() {

        return "&c=" + encodeURIComponent(this.parent.id);
    }

    /**
     * Returns the URL parameters for the current filter selection.
     */
    getFilterParams(countInfo = false) {

        let self = this;
        let params = "";
        this.$element.find(".active").each(function() {
            params += DynamicList.calculateStateParameter(self.parent.data, this.id, false, countInfo);
        });
        return params;
    }

    /**
     * Returns the reset buttons for the current filter selection.
     */
    getResetButtons() {

        const self = this;
        const resetButtons = [];
        this.$element.find(".active").each(function() {
            const buttonTitle = self.parent.data.resetbuttontitle;
            resetButtons.push(DynamicList.generateResetButton(this, buttonTitle));
        });
        return resetButtons;
    }

    /**
     * Updates the filter counts for the current filter selection.
     */
    updateFilterCounts(elementFacets) {

        this.$element.find("li[data-value]").each(function(_, li) {
            const val = li.getAttribute("data-value");
            let count = elementFacets[val];
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
class FolderFilter extends A_ListFilterBox {

    /**
     * Creates a new folder filter.
     */
    constructor($element, parent) {
        super($element);
        this.$element = $element;
        this.parent = parent;
    }

    /**
     * Returns the URL parameters for the current filter selection with count information.
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
     */
    getFilterParams(countInfo = false) {

        const self = this;
        let params = "";
        this.$element.find("li.currentpage").each(function() {
            const p = DynamicList.calculateStateParameter(self.parent.data, this.id, false, countInfo);
            if (p.length > params.length) {
                params = p;
            }
        });
        return params;
    }

    /**
     * Returns the reset buttons for the current filter selection.
     */
    getResetButtons() {

        const self = this;
        let params = "";
        let checkedElement;
        const resetButtons = [];
        this.$element.find("li.currentpage").each(function() {
            let p = DynamicList.calculateStateParameter(self.parent.data, this.id, false, true);
            if (p.length > params.length) {
                params = p;
                checkedElement = this;
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
     */
    updateFilterCounts(elementFacets) {

        this.$element.find("li[data-value]").each(function(_, li) {
            const val = li.getAttribute("data-value");
            const count = elementFacets[val];
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
     * @param jQ the jQuery object
     * @param element the HTML element
     */
    constructor(jQ, element) {
        this.$element = jQ(element);
        this.id = this.$element.attr("id");
        this.data = this.$element.data("filter");
        if (this.data.search == "true") {
            this.textSearch = new TextSearch(this.$element.find("#textsearch_" + this.id), this);
        }
        if (this.data.categories == "true") {
            this.categoryFilter = new CategoryFilter(this.$element.find("#cats_" + this.id), this);
        }
        if (this.data.archive == "true") {
            this.archiveFilter = new ArchiveFilter(this.$element.find("#arch_" + this.id), this);
        }
        if (this.data.folders == "true") {
            this.folderFilter = new FolderFilter(this.$element.find("#folder_" + this.id), this);
        }
        this.$directlink = this.$element.find(".directlink"); //TODO
    }

    /**
     * Returns the URL parameters for the current filter selection.
     */
    getFilterParams(countInfo = false) {
    
        let params = "";
        if (this.textSearch) {
            params += this.textSearch.getFilterParams();
        }
        if (this.categoryFilter) {
            params += this.categoryFilter.getFilterParams(countInfo);
        }
        if (this.archiveFilter) {
            params += this.archiveFilter.getFilterParams(countInfo);
        }
        if (this.folderFilter) {
            params += this.folderFilter.getFilterParams(countInfo);
        }
        return params;
    }

    /**
     * Returns the URL parameters for the current filter selection with count information.
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
     * Updates the filter counts for the current filter selection.
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
 * Initialize the list filters.
 */
export function init(jQuery) {

    jQ = jQuery;
    const $listFilters = jQ(".type-list-filter");
    if (Mercury.debug()) {
        console.info("Lists.init() .type-list-filter elements found: " + $listFilters.length);
    }
    if ($listFilters.length > 0) {
        $listFilters.each(function() {
            let listFilter = new ListFilter(jQ, this);
            let filter = DynamicList.registerFilter(this, listFilter);
            if (filter !== undefined && Mercury.debug()) {
                console.info("Lists.init() .type-list-filter data found - id=" + filter.id + ", elementId=" + filter.elementId);
            } else if (Mercury.debug()) {
                console.info("Lists.init() .type-list-filter found without data, ignoring!");
            }
        });
    }
}
