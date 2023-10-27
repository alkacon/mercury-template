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

import { _OpenCmsReinitEditButtons } from './opencms-callbacks.js';

/**
 * Definitions of the types locally used.
 *
 * NOTE: Definition may be incomplete since the HTML attribute "data-list" contains a JSON object
 * that the list object extends from. It might provide some keys not documented/typed here.
 *
 * @typedef {Object} List Wrapper for a single list.
 * @property {JQuery<HTMLElement>} $element the HTML element of the list.
 * @property {string} id the lists unique id on the page.
 * @property {string} elementId the id of the list element's content.
 * @property {boolean} loadAll flag, indicating if all items are loaded directly.
 * @property {?number[]} pageSizes the page sizes as array. Only provided in load all case.
 * @property {JQuery<HTMLElement>} $editbox HTML element representing the edit box for empty lists.
 * @property {JQuery<HTMLElement>} $entries HTML element representing the list entries shown.
 * @property {JQuery<HTMLElement>} $spinner HTML element representing the spinner shown when loading
 * @property {JQuery<HTMLElement>} $pagination HTML element where pagination is put.
 * @property {?Map<number, JQuery>} pageEntries the entries per page. Only filled in loadAll mode.
 * @property {?JQuery<HTMLElement>} $noresults HTML element where information about the empty list is placed.
 * @property {boolean} locked flag, indicating if the list is locked for reloading.
 * @property {boolean} autoload flag, indicating if the list should automatically load more items on scroll.
 * @property {boolean} notclicked flag, indicating if the "load more" button was already clicked.
 * @property {string} option pagination option, either "append" or "paginate".
 * @property {JQuery<HTMLElement>} $facets the facet elements of the list.
 * @property {string} initparams the initial search state parameters to apply on first load of the list.
 * @property {PageData} pageData the pagination state.
 * @property {PaginationCallback} paginationCallback the pagination callback function.
 *
 * @typedef {Object.<string, List>} ListMap Object holding only lists as property values.
 *
 * @typedef {Object.<string, List[]>} ListArrayMap Object holding only list arrays as property values.
 *
 * @typedef {Object.<string, HTMLElement[]>} ResetButtonsPerList Object holding list resource ids as properties and the reset buttons map as value.
 *
 * @typedef {Object} ListFilter Wrapper for a list's filter.
 * @property {JQuery<HTMLElement>} $element the HTML element of the filter.
 * @property {string} id the id attribute of the filter HTML element.
 * @property {string} elementId the id of the list element the filter belongs to.
 * @property {?JQuery<HTMLElement>} $textsearch  the search form of the filter (for full text search).
 * @property {boolean} hasResetButtons flag, indicating if the filter has reset buttons shown.
 * @property {string} resetbuttontitle the (locale specific) title attribute for reset buttons.
 * @property {string} initparams the initial search state parameters to apply on first load of the list.
 *
 * @typedef {Object.<string, ListFilter>} ListFilterMap Object holding only list filters as property values.
 *
 * @typedef {Object.<string, ListFilter[]>} ListFilterArrayMap Object holding only list filters as property values.
 *
 * @typedef {Object} PageData Holds the list's pagination data.
 * @property {boolean} reloaded flag, indicating if ????
 * @property {number} currentPage the currently shown page.
 * @property {number} pages the total number of pages.
 * @property {number} found the total number of results.
 * @property {number} start the first result to show on the page.
 * @property {number} end the last result to show on the page.
 *
 * @typedef {Object} InitWaitCallBackHandler Handler to keep track of initialization and trigger an callback when initialization finishes.
 * @property {() => void} wait start waiting for an initialization action
 * @property {() => void} ready stop waiting for an initialization action.
 *
 * @callback PaginationCallback
 * @param {PageData} pageData the current state of the list pagination.
 *
 /

// the global objects that must be passed to this module
/** @type {jQuery} jQuery object */
var jQ;
/** @type {boolean} flag, indicating if in debug mode. */
var DEBUG;

/** @type {ListMap} all initialized lists by unique instance id  */
var m_lists = {};

/** @type {ListFilterMap} all initialized list archive filters by unique instance id  */
var m_archiveFilters = {};

/** @type {ListArrayMap} groups of lists by element id (potentially more then one on a page) */
var m_listGroups = {};

/** @type {ListFilterArrayMap} groups of archive filters lists by list element id (potentially more then one on a page) */
var m_archiveFilterGroups = {};

/** @type {List[]} all auto loading lists as array for easy iteration  */
var m_autoLoadLists = [];

/** @type {boolean} flag indicating whether to scroll to the list head on filter or on page change. */
var m_flagScrollToAnchor = true;

/** @type {ResetButtonsPerList} reset buttons to display per list. */
var m_listResetButtons = {};

/**
 * Calculates the search state parameters.
 * @param {*} filter
 * @param {string} elId id of the element the search state parameters should be calculated for.
 * @param {boolean} resetActive flag, indicating if other active filters should be reset.
 * @param {boolean} countVersion flag, indicating if the state has to be calculated for the count calculation.
 * @returns {string} the search state parameters corresponding to the filter action.
 */
function calculateStateParameter(filter, elId, resetActive, countVersion = false) {
    var $el = $( '#' + elId);
    var value = $el.data("value")
    var paramkey =
            elId.indexOf('cat_') == 0
                ? (resetActive && $el.hasClass("active")
                    ? ''
                    : (countVersion
                        ? 'facet_' + encodeURIComponent(filter.id + '_c')
                        : filter.catparamkey))
            : elId.indexOf('folder_') == 0
                ? (resetActive && $el.hasClass("currentpage")
                    ? ''
                    :  (countVersion
                        ?'facet_' + encodeURIComponent(filter.id + '_f')
                        : filter.folderparamkey))
            : (resetActive && $el.hasClass("active")
                    ? ''
                    : (countVersion
                        ? 'facet_' + encodeURIComponent(filter.id + '_a')
                        : filter.archiveparamkey));
    var stateParameter =
        typeof paramkey !== 'undefined' && paramkey != '' && typeof value !== 'undefined' && value != ''
            ? '&' + paramkey + '=' + encodeURIComponent(value)
            : '';
    return stateParameter;
}

/**
 * Splits the request parameters in a key-value map.
 * @param {string} paramstring
 * @returns {Map<string,string>} parameters as key-value map.
 */
function splitRequestParameters(paramstring) {
    var params={};
    paramstring.replace(/[?&]*([^=&]+)=([^&]*)/gi, function(str,key,value) {
        params[key] = decodeURIComponent(value);
    });
    return params;
}


/**
 * Generates the search state parameters for the provided filter.
 *
 * @param {ListFilter} filter the filter element to get the additional parameters for.
 * @returns {string} the additional search state parameters generated by the filter.
 */
// retrieves the set filters from other category filters and combines the filter parameters
function getAdditionalFilterParams(filter) {
    var filterGroup = m_archiveFilterGroups[filter.elementId];
    var params = "";
    if (typeof filterGroup !== 'undefined') {
        for (var i=0; i<filterGroup.length; i++) {
            var fi = filterGroup[i];
            if (fi.combinable && fi.id != filter.id) {
                var query = fi.$textsearch.val();
                if(typeof query !== 'undefined' && query != '') {
                    params += '&' + fi.$textsearch.attr('name') + '=' + encodeURIComponent(query);
                }
                fi.$element.find(".active").each( function() {
                    var p = calculateStateParameter(fi, this.id, false);
                    params += p;
                });
                // Folder is a bit tricky, here currenpage is on
                // each item, with a parent folder of the clicked on
                // but only the clicked one should be set
                // so we only take the parameter with the longest path
                // into account
                var pageP = "";
                fi.$element.find("li.currentpage").each( function() {
                    var p = calculateStateParameter(fi, this.id, false);
                    if(p.length > pageP.length) pageP = p;
                });
                params += pageP;
            }
        }
    }
    return params;
}

/**
 * Applies a list filter.
 *
 * @param {string} id the id of the list to apply the filter for.
 * @param {string} triggerId the id of the element that triggered the filter action (TODO: correct?)
 * @param {string} filterId the id of the list filter element.
 * @param {string} searchStateParameters the search state parameters corresponding to the filter action.
 * @param {boolean} removeOthers flag, indicating if other filters should be cleared.
 * @returns {void}
 */
function listFilter(id, triggerId, filterId, searchStateParameters, removeOthers) {

    if (DEBUG) console.info("Lists.listFilter() called elementId=" + id);

    // reset filters of not sorting
    var filterGroup = m_archiveFilterGroups[id];
    var filter = m_archiveFilters[filterId]
    var removeAllFilters = !(filter && filter.combine);
    if ((triggerId != "SORT") && (typeof filterGroup !== "undefined")) {
        // We have more than one filter element, so we can combine them and have to adjust counts
        // I.e., if in one filter element we click a category
        // the facet counts in the other filter elements decrease
        var adjustCounts = filterGroup.length > 1;
        // potentially the same filter may be on the same page
        // here we make sure to reset them all
        var triggeredWasActive = triggerId != null && jQ("#" + triggerId).hasClass("active");
        // check if reset buttons need to be shown.
        var hasResetButtons = m_listResetButtons[id] != undefined;
        for (var i=0; i<filterGroup.length; i++) {
            var fi = filterGroup[i];
            // remove all active / highlighted filters
            // unless filters should be combined
            // TODO: Is there any uncombinable filter at all presently?
            var currentFolder = "";
            // if triggerId is null, we have a changed query string and this means always to reset all filters.
            if (removeOthers && (removeAllFilters || !fi.combinable || fi.id == filterId || triggerId == null)) {
                var $elactive = fi.$element.find(".active");
                $elactive.removeClass("active");
                // clear folder filter
                var $current = fi.$element.find("li.currentpage").each(function() {
                    var $c = $(this);
                    $c.children().trigger("blur");
                    $c.removeClass("currentpage");
                    $c.parentsUntil("ul.list-group").removeClass("currentpage");
                    var folderPath = this.getAttribute('data-value');
                    if(folderPath && folderPath.length > currentFolder.length) currentFolder = folderPath;
                });
                // clear text input if wanted
                if (triggerId != fi.$textsearch.id) {
                    fi.$textsearch.val('');
                }
            }
            if (triggerId != null) {
                var $current = fi.$element.find("#" + triggerId).first();
                if (DEBUG) console.info("Lists.listFilter() Current has class active? : " + $current.hasClass("active") + " - " + $current.attr("class"));
                // activate clicked folder filter, if it wasn't the highlighted before
                if (triggerId.indexOf("folder_") == 0) {
                    var folderElem = document.getElementById(triggerId);
                    var elemValue = folderElem.getAttribute('data-value');
                    if(currentFolder !== elemValue) {
                        $current.addClass("currentpage");
                        $current.parentsUntil("ul.list-group").addClass("currentpage");
                    }
                } else if (triggeredWasActive){
                    $current.removeClass("active");
                } else {
                    $current.addClass("active");
                }
            } else if (fi.id == filterId && (typeof searchStateParameters === 'string' || searchStateParameters instanceof String) && searchStateParameters.length > 0) {
                // highlight possibly already checked category restrictions
                var catparamkey = fi.catparamkey;
                if(typeof catparamkey !== 'undefined') {
                    var params = splitRequestParameters(searchStateParameters);
                    var initValue = params[catparamkey];
                        if (typeof initValue !== 'undefined' && initValue != '') {
                            fi.$element.find("li").each(function () {
                            var $this = $(this);
                            var itemValue = $this.data("value");
                            if (itemValue === initValue) {
                                $this.addClass("active");
                            }
                        });
                    }
                }
            }
        }
    }

    var listGroup = m_listGroups[id];
    if (typeof listGroup !== "undefined") {
        // required list is an element on this page
        for (var i=0; i<listGroup.length; i++) {
            updateInnerList(listGroup[i].id, searchStateParameters, true);
        }
        if (adjustCounts || hasResetButtons) {
          updateFilterCountsAndResetButtons(listGroup[0].id, filterGroup);
        }
        updateDirectLink(filter, searchStateParameters);
    } else {
        var archive = m_archiveFilters[filterId];
        // list is not on this page, check filter target attribute
        var target = archive.target;
        if (typeof target !== "undefined" && target !== window.location.pathname && target + "index.html" !== window.location.pathname) {
            if (DEBUG) console.info("Lists.listFilter() No list group found on page, trying redirect to " + target);
            var params = splitRequestParameters("reloaded=true&" + searchStateParameters);

            Mercury.post(target, params);
        } else {
            console.error("Lists.listFilter() Unable to load list!\nNo dynamic list found on the page and property 'mercury.list' not set.");
        }
    }
}

/**
 * Updates the direct link for a changed search state.
 *
 * @param {Object} filter the filter
 * @param {string} searchStateParameters the search state paramters
 */
function updateDirectLink(filter, searchStateParameters) {
    if (!filter.$directlink) {
        return;
    }
    var link = filter.$directlink.find("a");
    if (!link) {
        return;
    }
    var url = link.attr("href");
    if (url && url.indexOf("?") >= 0) {
        url = url.substring(0, url.indexOf("?"));
    }
    link.attr("href", url + "?" + searchStateParameters);
}

/**
 * Updates the list (results) for a changed search state.
 * Search is performed on the server and results are returned according to the state parameters.
 *
 * @param {string} id the lists id.
 * @param {string} searchStateParameters the search state parameters.
 * @param {boolean} reloadEntries flag, indicating if the shown list entries should be reloaded (in contrast to appending new ones only).
 * @param {boolean} isInitialLoad flag, indicating if this is the first load for the list after the page was originally loaded.
 * @param {InitWaitCallBackHandler} waitHandler optionally to keep an initialization action waiting till the list is updated.
 * @returns {void}
 */
function updateInnerList(id, searchStateParameters, reloadEntries, isInitialLoad = false, waitHandler = undefined) {

    if(waitHandler) waitHandler.wait();
    searchStateParameters = searchStateParameters || "";
    reloadEntries = reloadEntries || false;

    var list = m_lists[id];

    if (DEBUG) console.info("Lists.updateInnerList() called instanceId=" + list.id + " elementId=" + list.elementId + " parameters=" + searchStateParameters);

    if ((list.ajax == null)) {
        if (DEBUG) console.warn("Lists.updateInnerList() called instanceId=" + list.id + " elementId=" + list.elementId + " parameters=" + searchStateParameters + " does not support updates since no AJAX link is provided.");
    } else {
        if (!list.locked) {
            list.locked = true;

            var ajaxOptions = "&";
            if (reloadEntries) {
                // hide the "no results found" message during search
                list.$editbox.hide();
                list.$pagination.show();
            } else {
                // fade out the load more button
                list.$element.find('.btn-append').addClass("fadeOut");
                // we don't need to calculate facets again if we do not reload all entries
                ajaxOptions = "&hideOptions=true&";
            }
            if (list.initialLoad) {
                list.$element.addClass("initial-load");
            }

            // calculate the spinner position in context to the visible list part
            var scrollTop = Mercury.windowScrollTop();
            var windowHeight = window.innerHeight;
            var elementTop = list.$element.offset().top;
            var offsetTop = scrollTop > elementTop ? (elementTop - scrollTop) * -1 : 0;
            var elementHeight = list.$element.outerHeight(true);
            var visibleHeight = Math.min(scrollTop + windowHeight, elementTop + elementHeight) - Math.max(scrollTop, elementTop);
            var spinnerPos = ((0.5 * visibleHeight) + offsetTop) / elementHeight * 100.0;

            if (false && DEBUG) console.info("Lists.updateInnerList() Spinner animation" +
                " scrollTop=" + scrollTop +
                " windowHeight=" + windowHeight +
                " elementTop=" + elementTop +
                " offsetTop=" + offsetTop +
                " elementHeight=" + elementHeight +
                " visibleHeight=" + visibleHeight +
                " spinnerPos=" + spinnerPos + "%"
            )

            // show the spinner
            if (visibleHeight > 0) {
                list.$spinner.css("top", spinnerPos + "%").fadeIn(250);
            }

            // get requested page
            var page = 1;
            var pageParamPos = searchStateParameters.indexOf("page=");
            if (pageParamPos >= 0) {
                var helper = searchStateParameters.substring(pageParamPos + 5);
                var pageFromParam = parseInt(helper);
                if (!isNaN(pageFromParam) && pageFromParam > 1) {
                    page = pageFromParam;
                }
                if(list.loadAll) {
                    const params = new URLSearchParams(searchStateParameters);
                    params.delete('page');
                    searchStateParameters = params.toString();
                }
            }
            if (DEBUG) console.info("Lists.updateInnerList() showing page " + page);

            const shouldLoadMultiplePages = isInitialLoad && !list.reloadEntries && page > 1 && list.option === 'append' && !list.loadAll;
            if (shouldLoadMultiplePages) {
                const params = new URLSearchParams(searchStateParameters);
                loadMultiplePages(list, ajaxOptions, params, 1, page, waitHandler);
            } else {
                if(waitHandler) waitHandler.wait();
                jQ.get(buildAjaxLink(list, ajaxOptions, searchStateParameters), function(ajaxListHtml) {
                    generateListHtml(list, reloadEntries, ajaxListHtml, page, true, waitHandler);
                }, "html");
            }
        }
        if(waitHandler) waitHandler.ready();
    }
}

/**
 * Loads all pages from the current to the last one.
 * This function should only be used for a list with append as option that does not load all entries at once
 * but initially should load more than the first page.
 *
 * @param {List} list the list to generate the link for.
 * @param {string} ajaxOptions the ajax options to pass with the link as parameters.
 * @param {URLSearchParams} searchStateParameters the search state parameters to pass with the link.
 * @param {number} currentPage the page to load next
 * @param {number} lastPage the last page to load
 * @param {InitWaitCallBackHandler} waitHandler optional init wait handler.
 * @returns {string} the AJAX link.
 */
function loadMultiplePages(list, ajaxOptions, searchStateParameters, currentPage, lastPage, waitHandler) {
    if(currentPage <= lastPage) {
        searchStateParameters.set('page', currentPage);
        if(waitHandler) waitHandler.wait();
        jQ.get(buildAjaxLink(list, ajaxOptions, searchStateParameters.toString()), function(ajaxListHtml) {
            generateListHtml(list, false, ajaxListHtml, currentPage, true, waitHandler);
            if(list.pageData && list.pageData.pages && list.pageData.pages > currentPage && currentPage < lastPage) {
                loadMultiplePages(list, ajaxOptions, searchStateParameters, currentPage+1, lastPage);
            }
        }, "html");
    }
}
/**
 * Generates the AJAX link to call to retrieve the list entries and pagination for the
 * provided state.
 *
 * @param {List} list the list to generate the link for.
 * @param {string} ajaxOptions the ajax options to pass with the link as parameters.
 * @param {string} searchStateParameters the search state parameters to pass with the link.
 * @returns {string} the AJAX link.
 */
function buildAjaxLink(list, ajaxOptions, searchStateParameters) {

    if (DEBUG) console.info("Lists.buildAjaxLink() called - searchStateParameters='" + searchStateParameters + "' ajaxOptions='" + ajaxOptions + "'");

    var params = "contentpath=" + list.path
        + "&instanceId="
        + list.id
        + "&elementId="
        + list.elementId
        + "&sitepath="
        + list.sitepath
        + "&subsite="
        + list.subsite
        + "&__locale="
        + list.locale
        + "&loc="
        + list.locale
        + "&option="
        + list.option;

    if (list.$facets.length != 0) {
        // The first option is only used by the old lists. NG lists use the settings.
        params = params + "&facets=" + list.$facets.data("facets");
        params = params + list.$facets.data("settings");
    }
    return list.ajax + (list.ajax.indexOf('?') >= 0 ? '&' : '?') + params + ajaxOptions + searchStateParameters;
}

/**
 * Makes the list's HTML (results and pagination) visible on the client.
 * Call it after new results are returned from the server.
 *
 * @param {List} list the list to render the HTML for.
 * @param {boolean} reloadEntries flag, indicating if the current results should be reloaded/replaced.
 * @param {string} listHtml the list HTML as received from the server.
 * @param {number} page the number of the result page to show.
 * @param {boolean} isInitialLoad flag, indicating if the generation happens during the initial page load.
 * @param {InitWaitCallBackHandler} waitHandler optional init wait handler.
 * @returns {void}
*/
function generateListHtml(list, reloadEntries, listHtml, page, isInitialLoad = false, waitHandler = undefined) {
    if (DEBUG) console.info("Lists.generateListHtml() called");

    var $result = jQ(listHtml);
    // collect information about the search result
    var resultData = $result.find('#resultdata').first().data('result');
    list.pageData = resultData;
    list.pageData.itemsPerPage = parseInt(list.itemsPerPage, 10);
    if (DEBUG) console.info("Lists.generateListHtml() Search result - list=" + list.id + ", reloaded=" + list.pageData.reloaded + ", start=" + list.pageData.start + ", end=" + list.pageData.end + ", entries=" + list.pageData.found + ", pages=" + list.pageData.pages + ", currentPage=" + list.pageData.currentPage + ", page to show=" + page);

    var $newEntries;
    var $groups = $result.find("div[listgroup]");
    var hasGroups = $groups.length > 0;
    if (hasGroups) {
        // the search results should be grouped
        if (DEBUG) console.info("Lists.generateListHtml() Search result - list=" + list.id + " contains " + $groups.length + " groups");
        hasGroups = combineGroups($groups, false);
        $newEntries = $result.find(".list-entry:parent");
    } else {
        // no grouping of search results required
        $newEntries = $result.find(".list-entry:not(:empty)");
        // :not(:empty) added to remove 'invalid' decoys
    }

    if (list.loadAll) {
        list.pageEntries = paginateEntries(list, $newEntries);
        list.pageData.pages = list.pageEntries.size;
    }
    // clear the pagination element
    list.$pagination.empty();

    // initial list load:
    // entries are already there, if there are no groups in the result we can skip the reload
    // but never skip if all items are displayed
    var skipInitialLoad = list.initialLoad && !hasGroups && !list.loadAll && page == 1;
    list.initialLoad = false;
    if (DEBUG && skipInitialLoad) console.info("Lists.generateListHtml() Skipping initial reload for list=" + list.id);

    if (reloadEntries && !skipInitialLoad) {
        // set min-height of list to avoid screen flicker
        list.$entries.css("min-height", list.$entries.height() + 'px');
        // remove the old entries when list is reloaded
        list.$entries.empty();
    }

    // add the new elements to the list and set pagination element with new content.
    if (list.loadAll) {
        if (list.pageEntries.size == 0) {
            list.$entries.hide();
                if (list.$noresults != null) {
                var $noResultsElements = $result.find(".list-no-entries");
                if ($noResultsElements.length > 0) {
                    list.$noresults.empty();
                    $noResultsElements.appendTo(list.$noresults)
                }
                list.$noresults.show();
            }
        } else {
            if ((page < 1) || (page > list.pageData.pages)) {
                page = 1;
            }
            if (list.$noresults != null) list.$noresults.hide();
            if ((page > 1) && (list.option === 'append')) {
                list.$entries.empty();
                for (var i=1; i<page; i++) {
                    list.pageEntries.get(i).appendTo(list.$entries);
                }
            }
            list.pageEntries.get(page).appendTo(list.$entries);
            if (list.pageEntries.size > 1) {
                var paginationString = generatePagination(list, page);
                if (!paginationString.empty) {
                    jQ(paginationString).appendTo(list.$pagination);
                }
            } else {
                updatePageData(list, page);
            }
        }
    } else {
        if (!skipInitialLoad) {
            $newEntries.appendTo(list.$entries);
        }
        // set pagination element with new content
        $result.find('.list-append-position').appendTo(list.$pagination);
    }

    if (reloadEntries) {
        var $facetOptions = list.$facets;

        // reset the list option box
        $facetOptions.find(".list-options").remove();
        $result.find(".list-options").appendTo($facetOptions);

        // check if we have found any results
        if ($newEntries.length == 0) {
            // show the "no results found" message
            list.$editbox.show();
            // no results means we don't need any pagination element
            list.$pagination.hide();
        }
        // reset the min-height of the list now that the elements are visible
        list.$entries.animate({'min-height': "0px"}, 500);
    }

    setTimeout(function() {
        // trigger "list:loaded" event with a short delay, so that other lists have a change to initialize as well
        jQ('#' + list.id)[0].dispatchEvent(new CustomEvent("list:loaded", { bubbles: true, cancelable: true }));
    }, 100);

    // fade out the spinner
    list.$spinner.fadeOut(250);
    list.$element.removeClass("initial-load");
    list.locked = false;

    if ((list.appendOption === "clickfirst") && list.notclicked && !reloadEntries) {
        // this is a auto loading list that is activated on first click
        m_autoLoadLists.push(list);
        list.notclicked = false;
        if (m_autoLoadLists.length == 1) {
            // enable scroll listener because we now have one autoloading gallery
            jQ(window).bind('scroll', handleAutoLoaders);
        }
        handleAutoLoaders();
    } else if (reloadEntries && list.autoload) {
        // check if we can render more of this automatic loading list
        handleAutoLoaders();
    }

    // there may be media elements in the list
    Mercury.update('#' + list.id);

    if (resultData.reloaded == "true" && reloadEntries && !isInitialLoad) {
        if (! list.$element.visible()) {
            if (DEBUG) console.info("Lists.generateListHtml() Scrolling to anchor");
            if (m_flagScrollToAnchor) {
                Mercury.scrollToAnchor(list.$element, -20);
            }
        }
    }

    updateURLPageMarker(list,page);
    // We have to wait till Animations finished.
    if(waitHandler) setTimeout(waitHandler.ready, 750);
}

/**
 * Replaces the current URL by setting an url parameter keeping the current page of the list in edit mode.
 * Otherwise replacing the parameters value in the history state to allow to directly set the page again when using history back.
 *
 * @param {List} list the list to update the page data for.
 * @param {number} page the new current page.
 */
function updateURLPageMarker(list, page) {
    if (DEBUG) console.info("Lists.updateURLPageMarker() called");
    const paramName = 'p_' + list.elementId;
    if(Mercury.isEditMode()) {
        const currentUrl = new URL(window.location.href);
        const currentParams = currentUrl.searchParams;
        if(page > 1) {
            currentParams.set(paramName, page);
        } else if (currentParams.has(paramName)) {
            currentParams.delete(paramName);
        }
        // We could either use pushState or replaceState.
        // It depends if each page switch should be kept in the history
        window.history.replaceState(window.history.state, null, currentUrl.toString());
    } else {
        const state = window.history.state ? window.history.state : {};
        if(page > 1) {
            state[paramName] = page.toString();
        } else if (state[paramName]) {
            delete state[paramName];
        }
        window.history.replaceState(state, null, window.location.href);
    }
}

/**
 * @param {List} list the list to update the page data for.
 * @param {number} page the new current page.
 */
function updatePageData(list, page) {
    var pageData = list.pageData;
    var previousEnd = 0;
    for(var i = 1; i < page; i++) {
        previousEnd = previousEnd + getPageSize(i, list.pageSizes);
    }
    if (list.option !== 'append') {
        pageData.start = previousEnd + 1;
    } else {
        pageData.start = 1;
    }
    pageData.currentPage = page;
    pageData.end = previousEnd + getPageSize(page, list.pageSizes);
    if (pageData.end > pageData.found) {
        pageData.end = pageData.found;
    }

    updateURLPageMarker(list,page);
    if (null != list.paginationCallback) {
        list.paginationCallback(pageData);
    }
}

/**
 * Generates the pagination on the client side.
 * This is only used when all items are prefetched.
 * @param {Object} list the list (object) to generate the pagination for.
 * @param {number} page the current page
 * @returns {string | null} the HTML to render for the pagination, or null if no pagination should be rendered.
 */
function generatePagination(list, page) {

    updatePageData(list, page);
    var pagination = list.paginationInfo;
    var messages = pagination.messages;
    var listId = list.id;
    var result = [];
    var lastPage = list.pageEntries.size;
    if (lastPage > 1) {
        if (list.option === 'paginate') {
            // show the pagination
            var pagesToShow = 5;
            var firstShownPage;
            var lastShownPage;
            var isShowAll = lastPage <= pagesToShow;
            if (isShowAll) {
                firstShownPage = 1;
                lastShownPage = pagesToShow;
            } else {
                firstShownPage = page - 2 <= 1 ? 1 :  page - 2;
                lastPage = list.pageEntries.size;
                lastShownPage = firstShownPage + pagesToShow - 1;
            }
            if (lastShownPage > lastPage) {
                var diffPages = lastShownPage - lastPage;
                firstShownPage = firstShownPage - diffPages <= 1 ? 1 : firstShownPage - diffPages;
                lastShownPage = lastPage;
            }
            result.push('<ul class="pagination">');
            // previous page and first page
            result.push(generatePaginationItem("previous", page <= 1, false, page <= 1 ? 1 : page -1, messages.tpp, null, "ico fa fa-angle-left", listId)); // mercury:icon
            if (firstShownPage > 1) {
                var liClassesFirstPage = "first";
                if (firstShownPage > 2) {
                    liClassesFirstPage += " gap";
                }
                result.push(generatePaginationItem(liClassesFirstPage, page <= 1, false, 1, messages.tfp, "{{p}}", null, listId));
            }
            for (var p = firstShownPage; p <= lastShownPage; p++) {
                result.push(generatePaginationItem(p == lastShownPage ? "lastpage" : "page", false, page == p, p, messages.tp, messages.lp, "number", listId));
            }
            result.push(generatePaginationItem("next", page >= lastPage, false, page < lastPage ? page + 1 : lastPage, messages.tnp, null, "ico fa fa-angle-right", listId)); // mercury:icon
        } else if (list.option === 'append' && page < lastPage) {
            // show the button to append more results.
            result.push('<div class="list-append-position" data-dynamic="false">');
            result.push('<button class="btn btn-append" onclick="DynamicList.appendPage(\'');
            result.push(listId);
            result.push('\',');
            result.push(page + 1);
            result.push(')"><span>');
            result.push(messages.la);
            result.push("</span></button></div>");
        }
    }
    return result.empty ? null : result.join('');
}

/**
 * Renders a single pagination entry.
 * @param {string} liClasses classes for the li element additionally to active or disabled.
 * @param {boolean} isDisabled flag, indicating if the entry is disabled.
 * @param {boolean} isActive flag, indicating if the entry is active.
 * @param {string} liClasses the classes to put on the li item (except active and disabled).
 * @param {number} page the page to go to when the entry is clicked.
 * @param {string} title the (hover) title of the entry, can contain macro "{{p}}" that will be resolved to the page number of the page to go to on click.
 * @param {string} label the label of the entry, can contain macro "{{p}}" that will be resolved to the page number of the page to go to on click.
 * @param {string} spanClasses the classes to put on the &lt;span&gt; contained in the list entry.
 * @param {string} listId the id of the list the pagination entry is generated for.
 * @returns {string} the HTML to render for the pagination item.
 */
function generatePaginationItem(liClasses, isDisabled, isActive, page, title, label, spanClasses, listId) {
    /** @type {string[]} the HTML to return. The array is joined at the end. This performs better than plain string concatination.*/
    var result = []
    var resolvedTitle = title.replace(/\{\{p\}\}/g,page);
    result.push('<li');
    var classes = "";
    if (isDisabled) classes +=" disabled";
    if (isActive) classes +=" active";
    if (!(liClasses == null)) classes = " " + liClasses + classes;
    if (classes.length > 0) {
        result.push(' class="');
        result.push(classes.substring(1));
        result.push('"');
    }
    result.push('><a href="javascript:void(0)"');
    if(isDisabled) {
        result.push(' tabindex="-1"');
    }
    result.push('onclick="DynamicList.switchPage(\'');
    result.push(listId);
    result.push('\',');
    result.push(page);
    result.push(')" title="');
    result.push(resolvedTitle);
    result.push('">');
    var noLabel = (label == null);
    if (noLabel) {
        result.push('<span class="visually-hidden">');
        result.push(resolvedTitle);
        result.push('</span>');
    }
    result.push('<span class="');
    result.push(spanClasses);
    result.push('"');
    if(noLabel) {
        result.push(' aria-hidden="true"');
    }
    result.push('>');
    if(!noLabel) {
        result.push(label.replace(/\{\{p\}\}/g, page));
    }
    result.push('</span></a></li>');
    return result.join('');
}

/**
 * To support grouping of list elements do the following:
 *
 * 1. For grouping, you need a markup structure like this:
 *    <div>
 *          Some repeating content here that should appear only one, like a date etc.
 *          <div class="${the_group_id}">
 *              Content here will will be grouped.
 *          </div>
 *    <div>
 *
 *    Consider the following example:
 *    <div class="list-entry">
 *          <div listgroup="xy-1">
 *              Content from group 1.
 *          </div>
 *    <div>
 *    <div>
 *          <div listgroup="xy-2">
 *              Content from group 2.
 *          </div>
 *    <div>
 *
 *    This will be grouped like this:
 *     <div class="list-entry">
 *          <div>
 *              Content from group 1.
 *          </div>
 *          <div>
 *              Content from group 2.
 *          </div>
 *    <div>
 *
 * 2. In the formatter of the list element, mark the div to be extracted
 *    like this: <div class="list-group" listgroup="${some_group_id}">.
 *    The group ID must be created in the formatter.
 *    It must be the same for each element that belongs to the same group.
 *
 * 3. In the formatter XML settings, include the following configuration:
 *      <Setting>
 *        <PropertyName><![CDATA[requiredListWrapper]]></PropertyName>
 *        <Widget><![CDATA[hidden]]></Widget>
 *        <Default><![CDATA[list-with-groups]]></Default>
 *        <Visibility><![CDATA[parent]]></Visibility>
 *      </Setting>
 *
 * @param {JQuery} $groups The groups to manipulate (combine) the HTML for.
 * @param {boolean} isStatic flag, indicating if the rendered list is a static or dynamic list.
 *
 */
function combineGroups($groups, isStatic) {
    isStatic = isStatic || false;
    if (DEBUG) console.info("Lists.combineGroups() Combining list with " + $groups.length + " groups for a " + (isStatic ? "static" : "dynamic") + " list" );
    var lastGroupId, $lastGroup;
    var hasGroups = false;
    $groups.each(function(index) {
        var $this = $(this);
        var thisGroupId = $this.attr("listgroup");
        $this.removeAttr("listgroup");
        var $thisListEntry = $this.parents(".list-entry");
        if (Mercury.isEditMode()) {
            // reshuffle edit points
            var $editpointstart = $thisListEntry.find(".oc-editable");
            var $editpointend = $thisListEntry.find(".oc-editable-end");
            $this.prepend($editpointstart);
            $this.append($editpointend);
        }
        if (thisGroupId != lastGroupId) {
            // start of a new group
            $lastGroup = $this.parent();
            lastGroupId = thisGroupId;
        } else {
            // append to current group
            hasGroups = true;
            $this.appendTo($lastGroup);
            if (isStatic) {
                // must handle HTML differently for static lists
                $thisListEntry.remove();
            } else {
                $thisListEntry.empty();
            }
        }
    });
    return hasGroups;
}

/**
 * Splits the list of entries into several pages.
 * This is only used if all entries are loaded directly and pagination is done by the client.
 *
 * @param {List} list the list to split the entries for. It contains the pagination information.
 * @param {JQuery} $entries all list entries (this might be the groups of entries already where each group is counted as one entry).
 * @returns {Map<number, JQuery>} the map from page number to entries of the page.
 */
function paginateEntries(list, $entries) {
    var pageEntries = new Map();
    var pageSizes = list.pageSizes;
    var numEntries = $entries.length;
    var currentPage = 1;
    var pageStart = 0;
    while (pageStart < numEntries) {
        var pageSize = getPageSize(currentPage, pageSizes);
        pageEntries.set(currentPage, $entries.slice(pageStart, pageSize + pageStart)); //does it work when the end index is gt the entries length?
        pageStart = pageStart + pageSize;
        currentPage++;
    }
    return pageEntries;
}

/**
 * Returns the size of the provided page.
 *
 * @param {number} page the page to get the size for.
 * @param {number[]} pageSizes the page sizes array.
 */
function getPageSize(page, pageSizes) {
    if (page > pageSizes.length) {
        return pageSizes[pageSizes.length - 1];
    } else {
        return pageSizes[page-1];
    }
}

/**
 * Handles loading of a additional entries for lists that automatically load more entries on scroll.
 * NOTE: works currently only for lists where not all entries are loaded upfront.
 */
function handleAutoLoaders() {
    if (m_autoLoadLists != null) {
        for (var i=0; i<m_autoLoadLists.length; i++) {

            var list = m_autoLoadLists[i];
            var appendPosition = list.$element.find(".list-append-position");

            if (appendPosition.length
                && !list.locked
                && appendPosition.data("dynamic")
                // NOTE: jQuery.visible() is defined in jquery-extensions.js
                && appendPosition.visible()) {

                updateInnerList(list.id, list.$element.find('.btn-append').attr('data-load'), false);
            }
        }
    }
}

/**
 * Updates the counts on list filters.
 * Search is performed on the server and results are returned according to the state parameters.
 *
 * @param {sting} id id of the list to update.
 * @param {ListFilter[]} filterGroup the list filters to update.
 * @returns {void}
 */
function updateFilterCountsAndResetButtons(id, filterGroup) {
  if (DEBUG)
    console.info(
      "Lists.updateFilterCountsAndResetButtons() called with filterGroup, filter, searchStateParameters:"
    );
  var list = m_lists[id];
  /** @type {HTMLElement[]} */
  const resetButtons = [];
  const updateCounts = list.ajaxCount != undefined;
  const updateResets = m_listResetButtons[list.elementId] != undefined;
  if (!updateCounts) {
    if (DEBUG)
      console.warn(
        "Lists.updateFilterCountsAndResetButtons() does not support updates since no AJAX link for count updates is provided."
      );
  }
  if (!updateResets) {
    if (DEBUG)
      console.warn(
        "Lists.updateFilterCountsAndResetButtons() does not need to update reset buttons."
      );
  }
  if (updateCounts || updateResets) {
    var params = "&reloaded";
    for (var i = 0; i < filterGroup.length; i++) {
      var fi = filterGroup[i];
      if (fi.combinable) {
        var query = fi.$textsearch.val();
        if (typeof query !== "undefined" && query != "") {
          if (updateCounts)
            params +=
              "&" +
              fi.$textsearch.attr("name") +
              "=" +
              encodeURIComponent(query);
          if (updateResets)
            resetButtons.push(generateInputFieldResetButton(fi.id, fi.resetbuttontitle));
        }
        fi.$element.find(".active").each(function () {
          if (updateCounts) {
            var p = calculateStateParameter(fi, this.id, false, true);
            params += p;
          }
          if (updateResets) {
            resetButtons.push(generateResetButton(this, fi.resetbuttontitle));
          }
        });
        var pageP = "";
        var checkedElement = undefined;
        fi.$element.find("li.currentpage").each(function () {
          var p = calculateStateParameter(fi, this.id, false, true);
          if (p.length > pageP.length) {
            pageP = p;
            checkedElement = this;
          }
        });
        if (updateCounts) {
          params += pageP;
        }
        if (updateResets && checkedElement != undefined) {
          resetButtons.push(generateResetButton(checkedElement, fi.resetbuttontitle));
        }

        if(updateCounts) {
          // Tell which filters are shown in the current filter element
          if (fi.search == "true") params += "&s=" + encodeURIComponent(fi.id);
          if (fi.categories == "true")
            params += "&c=" + encodeURIComponent(fi.id);
          if (fi.archive == "true") params += "&a=" + encodeURIComponent(fi.id);
          if (fi.folders == "true") params += "&f=" + encodeURIComponent(fi.id);
        }
      }
    }
    if(updateCounts) {
      jQ.get(
        buildAjaxCountLink(list, params),
        function (ajaxCountJson) {
          replaceFilterCounts(filterGroup, ajaxCountJson);
        },
        "json"
      );
    }
    if(updateResets) {
      updateResetButtons(list.elementId, resetButtons);
    }
  }
}

/**
 * @param {HTMLElement} filterField
 * @param {string} titleAttr
 * @returns {HTMLElement} the reset button
 */
function generateResetButton(filterField, titleAttr) {
  /** @type {HTMLElement} */
  const result = document.createElement("button");
  const id = filterField.id;
  const type = id.startsWith('folder_')
    ? 'folders'
    : (id.startsWith('y_')
        ? 'archive'
        : (id.startsWith('cat_') ? 'categories' : undefined))
  result.classList.add("resetbutton");
  if(type != undefined) result.classList.add(type);
  result.id = "reset_" + id;
  const label = filterField.getAttribute('data-label');
  let onclick = filterField.getAttribute('onclick');
  if(!onclick) onclick = filterField.getAttribute('data-onclick');
  if(!onclick) onclick = filterField.firstChild.getAttribute('onclick');
  result.setAttribute('onclick', onclick);
  if(titleAttr) result.setAttribute('title', titleAttr);
  result.textContent = label ? label : id;
  return result;
}

/**
 * @param {string} archiveId
 * @param {string} titleAttr
 * @returns {HTMLElement} the reset button
 */
function generateInputFieldResetButton(archiveId, titleAttr) {
  /** @type {HTMLElement} */
  const result = document.createElement("button");
  result.classList.add("resetbutton");
  result.classList.add("textsearch");
  result.id = "reset_textsearch_" + archiveId;
  const form = document.getElementById('queryform_' + archiveId)
  const submitAction = form.getAttribute('onsubmit');
  const inputField = document.getElementById('textsearch_' + archiveId);
  const labelPlain = inputField.getAttribute('data-label');
  const label = labelPlain ? labelPlain.replace('%(query)', inputField.value) : inputField.value;
  let onclick = "document.getElementById('textsearch_" + archiveId + "').value = ''; " + submitAction;
  result.setAttribute('onclick', onclick);
  if(titleAttr) result.setAttribute('title', titleAttr);
  result.textContent = label;
  return result;
}



/**
 *
 * @param {string} id
 * @param {ResetButtonsMap} resetButtons
 */
function updateResetButtons(id, resetButtons) {
  m_listResetButtons[id] = resetButtons;
  const filters = m_archiveFilterGroups[id];
  filters.forEach((filter) => {
    /** @type {HTMLElement} */
    const buttons = document.getElementById('resetbuttons_' + filter.id);
    if(buttons != undefined) {
      buttons.textContent = '';
      resetButtons.forEach((button) => buttons.appendChild(button.cloneNode(true)));
    }
  });
}

/**
 * Generates the AJAX link to call to retrieve the item counts for filters for the
 * provided state.
 *
 * @param {List} list the list to generate the link for.
 * @param {string} searchStateParameters the search state parameters to pass with the link.
 * @returns {string} the AJAX link.
 */
function buildAjaxCountLink(list, searchStateParameters) {

    if (DEBUG) console.info("Lists.buildAjaxCountLink() called - searchStateParameters='" + searchStateParameters + "'");

    var params = "contentpath=" + list.path
        + "&sitepath="
        + list.sitepath
        + "&subsite="
        + list.subsite
        + "&__locale="
        + list.locale;

    if (list.$facets.length != 0) {
        // The first option is only used by the old lists. NG lists use the settings.
        //params = params + "&facets=" + list.$facets.data("facets");
        //params = params + list.$facets.data("settings");
    }
    return list.ajaxCount + (list.ajaxCount.indexOf('?') >= 0 ? '&' : '?') + params + searchStateParameters;
}

/**
 * Updates the counts on list filters.
 * Callback after the counts are returned from the server.
 *
 * @param {ListFilter[]} filterGroup the list filters to update.
 * @param {Object} ajaxCountJson the new counts of the filters.
 * @returns {void}
 */
function replaceFilterCounts(filterGroup, ajaxCountJson) {
    if(DEBUG) console.info("Lists.replaceFilterCounts() called with ajaxCountJson", ajaxCountJson);
    filterGroup.forEach((filter) => {
        var elementFacets = ajaxCountJson[filter.id];
        var archiveFilter = elementFacets['a'];
        var categoryFilter = elementFacets['c'];
        var folderFilter = elementFacets['f'];
        if(null != archiveFilter) {
            var $el = filter.$element.find('.archive');
            $el.find('li[data-value]').each(function(_, li) {
                var val = li.getAttribute('data-value');
                var count = archiveFilter[val];
                if(null == count) count = '0';
                var countSpan = li.querySelector('.li-count');
                var isDisabled = li.classList.contains('disabled');
                if(countSpan != undefined && countSpan.textContent !== count) { // change the count
                    countSpan.textContent = count;
                }
                if (isDisabled && count !== '0' || !isDisabled && count === '0') { // enabled / disable
                    if(count === '0') {
                        li.setAttribute('data-onclick', li.getAttribute('onclick'));
                        li.removeAttribute('onclick');
                        li.setAttribute('tabindex', '-1');
                        li.classList.remove('enabled');
                        li.classList.add('disabled');
                    } else  {
                        li.setAttribute('onclick', li.getAttribute('data-onclick'));
                        li.removeAttribute('data-onclick');
                        li.setAttribute('tabindex', '0');
                        li.classList.remove('disabled');
                        li.classList.add('enabled');
                    }
                }
            });
        }
        if(null != categoryFilter) {
            var $catEl = filter.$element.find('.categories');
            $catEl.find('li[data-value]').each(function(_, li) {
                var val = li.getAttribute('data-value');
                var count = categoryFilter[val];
                if(null == count) count = '0';
                var countSpan = li.querySelector('.li-count');
                var isDisabled = li.classList.contains('disabled');
                if(countSpan != undefined && countSpan.textContent !== count) { // change the count
                    countSpan.textContent = count;
                }
                if (isDisabled && count !== '0' || !isDisabled && count === '0') { // enabled / disable
                    var a = li.querySelector('a');
                    if(count == '0') {
                        a.setAttribute('tabindex', '-1');
                        li.classList.remove('enabled');
                        li.classList.add('disabled');
                    } else {
                        a.setAttribute('tabindex', '0');
                        li.classList.remove('disabled');
                        li.classList.add('enabled');
                    }
                }
            });
        }
        if(null != folderFilter) {
            var $catEl = filter.$element.find('.folders');
            $catEl.find('li[data-value]').each(function(_, li) {
                var val = li.getAttribute('data-value');
                var count = folderFilter[val];
                var shouldDisable = (null == count || count == '0');
                var isDisabled = li.classList.contains('disabled');
                if (isDisabled != shouldDisable) {
                    var a = li.querySelector('a');
                    if(shouldDisable) {
                        a.setAttribute('tabindex', '-1');
                        li.classList.remove('enabled');
                        li.classList.add('disabled');
                    } else {
                        a.setAttribute('tabindex', '0');
                        li.classList.remove('disabled');
                        li.classList.add('enabled');
                    }
                }
            });
        }
    })
}

/**
 * The callback for scroll events that tracks the current scroll position.
 * @type {() => void}
 */
const scrollListener = () => {
    const scrollPos = window.scrollY;
    if(DEBUG) console.log("Lists.scrollListener: scrolled to " + scrollPos);
    if(Mercury.isEditMode()) {
        const currentUrl = new URL(window.location.href);
        currentUrl.searchParams.set('_sp', scrollPos);
        window.history.replaceState(window.history.state, null, currentUrl.toString());
    } else {
        const state = window.history.state ? window.history.state : {};
        if(DEBUG) console.log('Lists.scrollListener: pulled state', state);
        state.sp = scrollPos;
        if(DEBUG) console.log('Lists.scrollListener: pushed state', state);
        window.history.replaceState(state, null, window.history.url)
    }
};

/**
 * Initializes scroll position tracking.
 * The function should be called if all dynamic page loading has finished.
 * It directly scrolls to the latest tracked scroll position (if any) and starts
 * tracking positions again.
 */
function initScrollPositionTracking() {
    /**
     * @type {Object}
     */
    if(DEBUG) console.info('Lists.initScrollPositionTracking() called');
    let spInt = undefined;
    if(Mercury.isEditMode()) {
        const url = new URL(window.location.href);
        if (url.searchParams.has('_sp')) {
            const sp = url.searchParams.get('_sp');
            spInt = parseInt(sp);
        }
    } else {
        const state = window.history.state;
        if(DEBUG) console.log('Lists.initScrollPositionTracking: pulled state', state);
        if (state && state.sp) {
            const sp = state.sp;
            spInt = parseInt(sp);
        }
    }
    if (spInt && !isNaN(spInt) && spInt > 0) {
        window.scrollTo(0, spInt);
    }
    window.addEventListener("scroll", scrollListener);
}

/**
 * Returns an init wait callback handler that will trigger the
 * provided callback when initialization is finished.
 * @param {() => void} callback the callback to trigger when initialization is finished.
 * @returns {InitWaitCallBackHandler} the callback handler that will trigger the provided callback after initialization.
 */
function getInitWaitCallBackHandler(callback) {
    let counter = 0;
    return {
        wait: () => {
            counter++;
            if(DEBUG) console.info('Lists init wait callback handler: increase counter to:' + counter);
        },
        ready: () => {
            counter--;
            if(DEBUG) console.info('Lists init wait callback handler: decrease counter to:' + counter);
            if(counter <= 0) {
                if(DEBUG) console.info('Lists init wait callback handler: calling init wait callback.');
                callback();
            }
        }
    }
}

/**
 * Handler for dom changes.
 * We need to find out when the content editor is closed and
 * a reload trigger is placed in the page.
 * If this is the case, we have to prevent scroll tracking to
 * keep the former scroll position until the page is reloaded.
 *
 * @param {[MutationRecord]} m the list of dom mutations.
 */
function onDomChange(m) {
    if(m.find((mr) => mr.target.classList && mr.target.classList.contains('oct-reload'))) {
        window.removeEventListener("scroll", scrollListener);
    }
}

/****** Exported functions ******/

/**
 * Applies a facet filter to a list.
 *
 * @param {string} id the id of the list the filter belongs to.
 * @param {string} triggerId the id of the HTML element that triggered the filter action.
 * @param {string} searchStateParameters the search state parameters representing the filter action.
 */
export function facetFilter(id, triggerId, searchStateParameters) {
    listFilter(id, triggerId, null, searchStateParameters, true);
}

/**
 * Applies an archive filter option to the list.
 *
 * @param {string} idthe id of the list the filter belongs to.
 * @param {string} triggerId the id of the HTML element that triggered the filter action.
 */
export function archiveFilter(id, triggerId) {
    var filter = m_archiveFilters[id];
    // if filters of other filter elements should be combined with that one - get the other filters that are set
    var additionalFilters = filter.combine ? getAdditionalFilterParams(filter) : "";
    // calculate the filter query part for the just selected item
    var additionalStateParameter = calculateStateParameter(filter, triggerId, true);
    listFilter(filter.elementId, triggerId, id, filter.searchstatebase + additionalFilters + additionalStateParameter, true);
}


/**
 * Applies an query filter to the list.
 *
 * @param {string} id the id of the list the filter belongs to.
 * @param {string} triggerId the id of the HTML element that triggered the filter action.
 */
export function archiveSearch(id, searchStateParameters) {
    var filter = m_archiveFilters[id];
    // we do never combine the text search when we change the search word. This should reset all other filters always.
    //var additionalFilters = filter.combine ? getAdditionalFilterParams(filter) : "";
    var additionalFilters= "&reloaded";
    listFilter(filter.elementId, null, filter.id, searchStateParameters + encodeURIComponent(filter.$textsearch.val()) + additionalFilters, true);
}

/**
 * Switches to the given page. The method can only be used when all results are preloaded directly.
 *
 * @param {string} id the id of the list where the page should be appended to.
 * @param {number} page the number of the page to append.
 */
export function switchPage(id, page) {
    var list = m_lists[id];
    list.$entries.empty();
    list.pageEntries.get(page).appendTo(list.$entries);
    list.$pagination.empty();
    list.pageData.start = 1 + (page - 1) * list.itemsPerPage;
    var paginationString = generatePagination(list, page);
    if (!paginationString.empty) {
        jQ(paginationString).appendTo(list.$pagination);
    }

    // there may be media elements in the list
    Mercury.update('#' + list.id);
    if (! list.$element.visible()) {
        if (DEBUG) console.info("Lists.switchPage() - scrolling to anchor");
        if (m_flagScrollToAnchor) {
            Mercury.scrollToAnchor(list.$element, -20);
        }
    }
}

/**
 * Appends a further page of items to the currently shown items.
 * The method can only be used if all items are already preloaded.
 *
 * @param {string} id the id of the list where the page should be appended to.
 * @param {number} page the number of the page to append.
 */
export function appendPage(id, page) {
    var list = m_lists[id];
    list.pageEntries.get(page).appendTo(list.$entries);
    list.$pagination.empty();
    var paginationString = generatePagination(list, page);
    if (!paginationString.empty) {
        jQ(paginationString).appendTo(list.$pagination);
    }
    // there may be media elements in the list
    Mercury.update('#' + list.id);
}

/**
 * Update the list in the case where not all items are already loaded.
 * This will update the list according to the provided search state parameters.
 * A call to the server is made to fetch the entries according to the parameters.
 * This method is e.g., called when the page is switched for a list where the entries
 * are not preloaded completely.
 *
 * @param {string} id the id of the list for which the update should take place.
 * @param {string} searchStateParameters the search state parameters to use for the update.
 * @param {boolean} reloadEntries a flag, indicating if the currently shown results should be reloaded/replaced (or if new results should only be appended).
 */
export function update(id, searchStateParameters, reloadEntries) {
    updateInnerList(id, searchStateParameters, reloadEntries == "true");
}

/**
 * This method can be used to allow pagination for the lists that retrieve their results not via the default AJAX call.
 *
 * @param {string} id the id of the list for which the update should take place.
 * @param {string} searchStateParameters the search state parameters to use for the update.
 * @param {boolean} reloadEntries a flag, indicating if the currently shown results should be reloaded/replaced (or if new results should only be appended).
 * @param {ListCallback} [paginationCallback] a callback triggered when a page is loaded or appended.
 */
export function injectResults(id, resultHtml, paginationCallback, pageToShow) {

    if (DEBUG) console.info("Lists.injectResults() id=" + id + ", pageToShow=" + pageToShow);
    pageToShow = pageToShow || 1;
    var list = m_lists[id];
    list.paginationCallback = paginationCallback;
    generateListHtml(list, true, resultHtml, pageToShow);
}

/**
 * Initialize the list script.
 * @param {jQuery} jQuery jQuery object.
 * @param {boolean} debug a flag, determining iff in debug mode.
 */
export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    const waitHandler = getInitWaitCallBackHandler(initScrollPositionTracking);
    waitHandler.wait();

    if(Mercury.isEditMode()) {
        if(DEBUG) console.info("Lists.init() - observing DOM, since we are in edit mode.");
        const observeDOM = (function(){
            const MutationObserver = window.MutationObserver || window.WebKitMutationObserver;

            return function( obj, callback ){
            if( !obj || obj.nodeType !== 1 ) return;

            if( MutationObserver ){
                // define a new observer
                const mutationObserver = new MutationObserver(callback)

                // have the observer observe for changes in children
                mutationObserver.observe( obj, { childList:true, subtree:true })
                return mutationObserver
            }

            // browser support fallback
            else if( window.addEventListener ){
                obj.addEventListener('DOMNodeInserted', callback, false)
                obj.addEventListener('DOMNodeRemoved', callback, false)
            }
            }
        })();
        observeDOM(document.body, onDomChange);
    }
    if (DEBUG) console.info("Lists.init()");

    var $listElements = jQ('.list-dynamic');
    if (DEBUG) console.info("Lists.init() .list-dynamic elements found: " + $listElements.length);

    const urlParams = (new URL(window.location.href)).searchParams;
    if ($listElements.length > 0 ) {
        $listElements.each(function() {

            // initialize lists with values from data attributes
            var $list = jQ(this);

            if (typeof $list.data("list") !== 'undefined') {
                // read list data
                /** @type {List} a single list. */
                var list = $list.data("list");
                // add more data to list
                list.$element = $list;
                list.id = $list.attr("id");
                list.elementId = $list.data("id");
                // read and store the page size information
                var pageSizes = list.itemsPerPage;
                var sizeArrayNum = [];
                if (pageSizes !== undefined) {
                    var sizeArrayString = pageSizes.split("-");
                    sizeArrayString.forEach(function (numString) {
                        sizeArrayNum.push(Number(numString)) })
                }
                if (sizeArrayNum.length == 0) {
                    sizeArrayNum.push(5); // default size
                }
                list.pageSizes = sizeArrayNum;
                list.$editbox = $list.find(".list-editbox");
                list.$entries = $list.find(".list-entries");
                list.$spinner = $list.find(".list-spinner");
                list.$pagination = $list.find(".list-pagination");
                list.$noresults = $list.find(".list-noresults");
                list.initialLoad = true;
                list.locked = false;
                list.autoload = false;
                list.notclicked = true;
                let screenSize = Mercury.gridInfo().grid == 'xxl' ? 'xl' : Mercury.gridInfo().grid;
                if (list.appendSwitch.indexOf(screenSize) >= 0) {
                    // I think this is a cool way for checking the screen size ;)
                    list.option = "append";
                    $list.removeClass("list-paginate").addClass("list-append");
                } else {
                    list.option = "paginate";
                    $list.removeClass("list-append").addClass("list-paginate");
                }
                if (DEBUG) console.info("Lists.init() List data found - id=" + list.id + ", elementId=" + list.elementId + " option=" + list.option);
                if ((list.option === "append") && (list.appendOption === "noclick")) {
                    // list automatically loads in scrolling
                    list.autoload = true;
                    m_autoLoadLists.push(list);
                };
                list.$facets = jQ("#facets_" + list.elementId);
                // store list data in global array
                m_lists[list.id] = list;
                // store list in global group array
                var group = m_listGroups[list.elementId];
                if (typeof group !== 'undefined') {
                    group.push(list);
                } else {
                    m_listGroups[list.elementId] = [list];
                }
            }

            var initParams = "";
            if (typeof list.initparams !== "undefined") {
                initParams = list.initparams;
                if (DEBUG) console.info("Lists.init() Data init params - " + initParams);
            }
            const pageParam = 'p_' + list.elementId;
            let pageStr = undefined;
            if(Mercury.isEditMode()) {
                if(urlParams.has(pageParam)) {
                    pageStr = urlParams.get(pageParam);
                }
            } else {
                const state = window.history.state ? window.history.state : {};
                pageStr = state[pageParam];
            }
            if(pageStr) {
                const page = parseInt(pageStr);
                if(!isNaN(page) && page > 1) {
                    initParams = 'page=' + page + (initParams == '' ? '' : ('&' + initParams));
                }
            }
            // load the initial list
            updateInnerList(list.id, initParams, true, true, waitHandler);
        });

        if (m_autoLoadLists.length > 0) {
            // only enable scroll listener if we have at least one autoloading gallery
            jQ(window).on('scroll', handleAutoLoaders);
        }
    }

    var $staticGroupListElements = jQ('.type-static-list .list-with-groups.list-entries');
    if (DEBUG) console.info("Lists.init() .type-static-list .list-with-groups elements found: " + $staticGroupListElements.length);

    if ($staticGroupListElements.length > 0 ) {
        $staticGroupListElements.each(function() {

            // rewrite content of each list group
            var $list = jQ(this);
            var $clone = $list.clone();

            var $groups = $clone.find("div[listgroup]");
            if ($groups.length > 0) {
                // the search results should be grouped
                if (DEBUG) console.info("Lists.init() Found static list with " + $groups.length + " groups");
                combineGroups($groups, true);
                $list.replaceWith($clone);
            }
        });
        _OpenCmsReinitEditButtons(DEBUG);
    }

    var $listArchiveFilters = jQ('.type-list-filter, .type-list-calendar');
    if (DEBUG) console.info("Lists.init() .type-list-filter elements found: " + $listArchiveFilters.length);

    if ($listArchiveFilters.length > 0) {
        $listArchiveFilters.each(function() {

            // initialize filter archives
            var $archiveFilter = jQ(this);

            /** @type {ListFilter} */
            var filter = $archiveFilter.data("filter");
            if (typeof filter !== 'undefined') {
                filter.$element = $archiveFilter;
                filter.id = $archiveFilter.attr("id");
                filter.elementId = $archiveFilter.data("id");
                filter.$textsearch = $archiveFilter.find("#textsearch_" + filter.id);
                filter.hasResetButtons = $archiveFilter.find("#resetbuttons_" + filter.id).length > 0;
                filter.$directlink = $archiveFilter.find(".directlink");

                // unfold categories if on desktop and responsive setting is used
                var $collapses = $archiveFilter.find('#cats_' + filter.id + ', #folder_' + filter.id  + ', #arch_' + filter.id);
                if ($collapses.length > 0) {
                    if (DEBUG) console.info("Lists.init() collapse elements found for filter id " + filter.id + ": " + $collapses.length);
                    $collapses.each(function() {
                        var $collapse = jQ(this);
                        if (($collapse.hasClass('op-lg') && Mercury.gridInfo().isMinLg())
                            || ($collapse.hasClass('op-md') && Mercury.gridInfo().isMinMd())
                            || ($collapse.hasClass('op-sm') && Mercury.gridInfo().isMinSm())) {
                            $collapse.collapse('show');
                        }
                    });
                }

                // store filter data in global array
                m_archiveFilters[filter.id] = filter;

                // store filter in global group array
                var group = m_archiveFilterGroups[filter.elementId];
                if (typeof group !== 'undefined') {
                    group.push(filter);
                } else {
                    m_archiveFilterGroups[filter.elementId] = [filter];
                }

                if (filter.hasResetButtons && m_listResetButtons[filter.elementId] == undefined) {
                  // tell list, that it has to track reset buttons
                  m_listResetButtons[filter.elementId] = [];
                }

                // attach key listeners for keyboard support
                $archiveFilter.find("li > a").on("keydown", function(e) {
                    if (e.type == "keydown" && (e.which == 13 || e.which == 32)) {
                        jQ(this).click();
                        e.preventDefault();
                    }
                });
                if (DEBUG) console.info("Lists.init() .type-list-filter data found - id=" + filter.id + ", elementId=" + filter.elementId);

                if (typeof filter.initparams !== "undefined" && filter.initparams != "") {
                    if (DEBUG) console.info("Lists.init() Data filter init params - " + filter.initparams);
                    // highlight filter correctly
                    listFilter(filter.elementId, null, filter.id, filter.initparams, false);
                }
            } else {
                if (DEBUG) console.info("Lists.init() .type-list-filter found without data, ignoring!");
            }

        });
    }

    waitHandler.ready();

}

export function setFlagScrollToAnchor(flagScrollToAnchor) {

    m_flagScrollToAnchor = !!flagScrollToAnchor;
}
