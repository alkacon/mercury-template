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

"use strict";

// the global objects that must be passed to this module
var jQ;
var DEBUG;

// all initialized lists by unique instance id
var m_lists = {};

// all initialized list archive filters by unique instance id
var m_archiveFilters = {};

// groups of lists by element id (potentially more then one on a page)
var m_listGroups = {};

// groups of archive filters lists by list element id (potentially more then one on a page)
var m_archiveFilterGroups = {};

// all auto loading lists as array for easy iteration
var m_autoLoadLists = [];

function calculateStateParameter(filter, liId, resetActive) {
    var $li = $( 'li#' + liId);
    var value = $li.data("value")
    var paramkey = liId.indexOf('cat_') == 0 ? (resetActive && $li.hasClass("active") ? '' : filter.catparamkey) : liId.indexOf('folder_') == 0 ? filter.folderparamkey : resetActive && $li.hasClass("active") ? '' : filter.archiveparamkey;
    var stateParameter =
        typeof paramkey !== 'undefined' && paramkey != '' && typeof value !== 'undefined' && value != ''
            ? '&' + paramkey + '=' + encodeURIComponent(value)
            : '';
    return stateParameter;
}

function splitRequestParameters(paramstring) {
    var params={};
    paramstring.replace(/[?&]*([^=&]+)=([^&]*)/gi, function(str,key,value) {
        params[key] = decodeURIComponent(value);
    });
    return params;
}

// retrieves the set filters from other category filters and combines the filter parameters
function getAdditionalFilterParams(filter) {
    var filterGroup = m_archiveFilterGroups[filter.elementId];
    var params = "";
    if (typeof filterGroup !== 'undefined') {
        for (var i=0; i<filterGroup.length; i++) {
            var fi = filterGroup[i];
            //TODO: Query
            if (fi.combinable && fi.id != filter.id) {
                var query = fi.$textsearch.val();
                if(typeof query !== 'undefined' && query != '') {
                    params += '&' + fi.$textsearch.attr('name') + '=' + encodeURIComponent(query);
                }
                fi.$element.find("li.active").each( function() {
                    var p = calculateStateParameter(fi, this.id, false);
                    params += p;
                });
            }
        }
    }
    return params;
}

function listFilter(id, triggerId, filterId, searchStateParameters, removeOthers) {

    if (DEBUG) console.info("List: listFilter() called elementId=" + id);

    // reset filters of not sorting
    var filterGroup = m_archiveFilterGroups[id];
    var filter = m_archiveFilters[filterId]
    var removeAllFilters = !(filter && filter.combine);
    if ((triggerId != "SORT") && (typeof filterGroup !== "undefined")) {
        // potentially the same filter may be on the same page
        // here we make sure to reset them all
        var triggeredWasActive = triggerId != null && jQ("#" + triggerId).hasClass("active");
        for (var i=0; i<filterGroup.length; i++) {
            var fi = filterGroup[i];
            // remove all active / highlighted filters
            // unless filters should be combined
            if (removeOthers && (removeAllFilters || !fi.combinable || fi.id == filterId)) {
                var $liactive = fi.$element.find("li.active");
                $liactive.removeClass("active");
                // clear text input if wanted
                if (triggerId != fi.$textsearch.id) {
                    fi.$textsearch.val('');
                }
            }
            if (triggerId != null) {
                fi.$element.find("li.currentpage").removeClass("currentpage");
                var $current = fi.$element.find("#" + triggerId).first();
                if (DEBUG) console.info("List: Current has class active? : " + $current.hasClass("active") + " - " + $current.attr("class"));
                // activate / highlight clicked filter
                if (triggerId.indexOf("folder_") == 0) {
                    $current.addClass("currentpage");
                    $current.parentsUntil("ul.list-group").addClass("currentpage");
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
    } else {
        var archive = m_archiveFilters[filterId];
        // list is not on this page, check filter target attribute
        var target = archive.target;
        if (typeof target !== "undefined" && target !== window.location.pathname && target + "index.html" !== window.location.pathname) {
            if (DEBUG) console.info("List: No list group found on page, trying redirect to " + target);
            var params = splitRequestParameters("reloaded=true&" + searchStateParameters);

            Mercury.post(target, params);
        } else {
            console.error("List: Unable to load list!\nNo dynamic list found on the page and property 'mercury.list' not set.");
        }
    }
}

function updateInnerList(id, searchStateParameters, reloadEntries) {
    searchStateParameters = searchStateParameters || "";
    reloadEntries = reloadEntries || false;

    var list = m_lists[id];

    if (DEBUG) console.info("List: updateInnerList() called instanceId=" + list.id + " elementId=" + list.elementId + " parameters=" + searchStateParameters);

    if (!list.locked) {
        list.locked = true;

        var ajaxOptions = "&";
        if (reloadEntries) {
            // hide the "no results found" message during search
            list.$editbox.hide();
        } else {
            // fade out the load more button
            list.$element.find('.loadMore').addClass("fadeOut");
            // we don't need to calculate facets again if we do not reload all entries
            ajaxOptions = "&hideOptions=true&";
        }

        // calculate the spinner position in context to the visible list part
        var scrollTop = jQ(window).scrollTop();
        var windowHeight = jQ(window).height();
        var elementTop = list.$element.offset().top;
        var elementHeight = list.$element.outerHeight(true);
        var visibleHeight = Math.min(scrollTop + windowHeight, elementTop + elementHeight) - Math.max(scrollTop, elementTop);
        var invisibleHeight = elementHeight - visibleHeight;
        var spinnerPos = ((0.5 * visibleHeight) + invisibleHeight) / elementHeight * 100.0;

        if (DEBUG && false) console.info("List: Spinner animation" +
            " scrollTop=" + scrollTop +
            " windowHeight=" + windowHeight +
            " elementTop=" + elementTop +
            " elementHeight=" + elementHeight +
            " visibleHeight=" + visibleHeight +
            " invisibleHeight=" + invisibleHeight +
            " spinnerPos=" + spinnerPos
        )

        // show the spinner
        if (visibleHeight > 0) {
            list.$spinner.css("top", spinnerPos + "%").fadeIn(250);
        }

        jQ.get(buildAjaxLink(list, ajaxOptions, searchStateParameters), function(ajaxListHtml) {
            generateListHtml(list, reloadEntries, ajaxListHtml)
        }, "html");
    }
}

function buildAjaxLink(list, ajaxOptions, searchStateParameters) {

    if (DEBUG) console.info("List: buildAjaxLink() called - searchStateParameters='" + searchStateParameters + "'");

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
        /* The first option is only used by the old lists. NG lists use the settings. */
        params = params + "&facets=" + list.$facets.data("facets");
        params = params + list.$facets.data("settings");
    }
    return list.ajax + (list.ajax.indexOf('?') >= 0 ? '&' : '?') + params + ajaxOptions + searchStateParameters;
}

function generateListHtml(list, reloadEntries, listHtml) {
    if (DEBUG) console.info("List: generateListHtml() called");

    var $result = jQ(listHtml);
    // collect information about the search result
    var resultData = $result.find('#resultdata').first().data('result');
    if (DEBUG) console.info("List: Search result - list=" + list.id + ", reloaded=" + resultData.reloaded + ", start=" + resultData.start + ", end=" + resultData.end + ", entries=" + resultData.found + ", pages=" + resultData.pages + ", currentPage=" + resultData.currentPage);

    // append all results from the ajax call to a new element that is not yet displayed
    var $newPage = jQ('<span></span>');

    var $newEntries;
    var $groups = $result.find("div[listgroup]");
    if ($groups.length > 0) {
        // the search results should be grouped
        if (DEBUG) console.info("List: Search result - list=" + list.id + " contains " + $groups.length + " groups");
        combineGroups($groups, false);
        $newEntries = $result.find(".list-entry:parent");
    } else {
        // no grouping of search results required
        $newEntries = $result.find(".list-entry");
    }

    // clear the pagination element
    list.$pagination.empty();

    if (reloadEntries) {
        // set min-height of list to avoid screen flicker
        list.$entries.css("min-height", list.$entries.height() + 'px');
        // remove the old entries when list is reloaded
        list.$entries.empty();
    }

    // add the new elements to the list
    $newEntries.appendTo(list.$entries);

    // set pagination element with new content
    $result.find('.list-append-position').appendTo(list.$pagination);

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

    // trigger "listLoaded" event
    jQ('#' + list.id).trigger("list:loaded");

    // fade out the spinner
    list.$spinner.fadeOut(250);
    list.locked = false;

    if ((list.appendOption == "clickfirst") && list.notclicked && !reloadEntries) {
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

    // there may be videos in the list
    Mercury.initElements('#' + list.id);

    if ((resultData.reloaded == "true") && reloadEntries) {
        if (! list.$element.visible()) {
            if (DEBUG) console.info("List: Scrolling to anchor");
            Mercury.scrollToAnchor(list.$element, -20);
        }
    }
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
        <Setting>
          <PropertyName><![CDATA[requiredListWrapper]]></PropertyName>
          <Widget><![CDATA[hidden]]></Widget>
          <Default><![CDATA[list-with-groups]]></Default>
          <Visibility><![CDATA[parent]]></Visibility>
        </Setting>
 */
function combineGroups($groups, isStatic) {
    isStatic = isStatic || false;
    if (DEBUG) console.info("List: Combining list with " + $groups.length + " groups for a " + isStatic ? "static" : "dynamic" + " list" );
    var lastGroupId, $lastGroup;
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
            $this.appendTo($lastGroup);
            if (isStatic) {
                // must handle HTML differently for static lists
                $thisListEntry.remove();
            } else {
                $thisListEntry.empty();
            }
        }
    });
}


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

                updateInnerList(list.id, list.$element.find('.loadMore').attr('data-load'), false);
            }
        }
    }
}

/****** Exported functions ******/

export function facetFilter(id, triggerId, searchStateParameters) {
    listFilter(id, triggerId, null, searchStateParameters, true);
}

export function archiveFilter(id, triggerId) {
    var filter = m_archiveFilters[id];
    // if filters of other filter elements should be combined with that one - get the other filters that are set
    var additionalFilters = filter.combine ? getAdditionalFilterParams(filter) : "";
    // calculate the filter query part for the just selected item
    var additionalStateParameter = calculateStateParameter(filter, triggerId, true);
    listFilter(filter.elementId, triggerId, id, filter.searchstatebase + additionalFilters + additionalStateParameter, true);
}

export function archiveSearch(id, searchStateParameters) {
    var filter = m_archiveFilters[id];
    // if filters of other filter elements should be combined with that one - get the other filters that are set
    var additionalFilters = filter.combine ? getAdditionalFilterParams(filter) : "";
    listFilter(filter.elementId, null, filter.id, searchStateParameters + encodeURIComponent(filter.$textsearch.val()) + additionalFilters, true);
}

export function update(id, searchStateParameters, reloadEntries) {
    updateInnerList(id, searchStateParameters, reloadEntries == "true");
}

export function init(jQuery, debug) {

    jQ = jQuery;
    DEBUG = debug;

    if (DEBUG) console.info("Lists.init()");

    var $listElements = jQ('.list-dynamic');
    if (DEBUG) console.info(".list-dynamic elements found: " + $listElements.length);

    if ($listElements.length > 0 ) {
        $listElements.each(function() {

            // initialize lists with values from data attributes
            var $list = jQ(this);

            if (typeof $list.data("list") !== 'undefined') {
                // read list data
                var list = $list.data("list");
                // add more data to list
                list.$element = $list;
                list.id = $list.attr("id");
                list.elementId = $list.data("id");
                list.$editbox = $list.find(".list-editbox");
                list.$entries = $list.find(".list-entries");
                list.$spinner = $list.find(".list-spinner");
                list.$pagination = $list.find(".list-pagination");
                list.locked = false;
                list.autoload = false;
                list.notclicked = true;
                if (list.appendSwitch.indexOf(Mercury.gridInfo().grid) >= 0) {
                    // I think this is a cool way for checking the screen size ;)
                    list.option = "append";
                    $list.removeClass("list-paginate").addClass("list-append");
                } else {
                    list.option = "paginate";
                    $list.removeClass("list-append").addClass("list-paginate");
                }
                if ((list.option == "append") && (list.appendOption == "noclick")) {
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
                if (DEBUG) console.info("List: Data found - id=" + list.id + ", elementId=" + list.elementId + " option=" + list.option);
            }

            var initParams = "";
            if (typeof list.initparams !== "undefined") {
                initParams = list.initparams;
                if (DEBUG) console.info("List: Data init params - " + initParams);
            }
            // load the initial list
            updateInnerList(list.id, initParams, true);
        });

        if (m_autoLoadLists.length > 0) {
            // only enable scroll listener if we have at least one autoloading gallery
            jQ(window).on('scroll', handleAutoLoaders);
        }
    }

    var $staticGroupListElements = jQ('.type-static-list .list-with-groups.list-entries');
    if (DEBUG) console.info(".type-static-list .list-with-groups elements found: " + $staticGroupListElements.length);

    if ($staticGroupListElements.length > 0 ) {
        $staticGroupListElements.each(function() {

            // rewrite content of each list group
            var $list = jQ(this);
            var $clone = $list.clone();

            var $groups = $clone.find("div[listgroup]");
            if ($groups.length > 0) {
                // the search results should be grouped
                if (DEBUG) console.info("List: Found static list with " + $groups.length + " groups");
                combineGroups($groups, true);
                $list.replaceWith($clone);
            }
        });
        _OpenCmsReinitEditButtons(DEBUG);
    }

    var $listArchiveFilters = jQ('.type-list-filter');
    if (DEBUG) console.info(".type-list-filter elements found: " + $listArchiveFilters.length);

    if ($listArchiveFilters.length > 0 ) {
        $listArchiveFilters.each(function() {

            // initialize filter archives
            var $archiveFilter = jQ(this);

            var filter = $archiveFilter.data("filter");
            filter.$element = $archiveFilter;
            filter.id = $archiveFilter.attr("id");
            filter.elementId = $archiveFilter.data("id");
            filter.$form = $archiveFilter.find("#queryform_" + filter.id);
            filter.$textsearch = $archiveFilter.find("#textsearch_" + filter.id);

            // store filter data in global array
            m_archiveFilters[filter.id] = filter;

            // store filter in global group array
            var group = m_archiveFilterGroups[filter.elementId];
            if (typeof group !== 'undefined') {
                group.push(filter);
            } else {
                m_archiveFilterGroups[filter.elementId] = [filter];
            }

            // attach key listeners for keyboard support
            $archiveFilter.find("li > a").on("keydown", function(e) {
                if (e.type == "keydown" && (e.which == 13 || e.which == 32)) {
                    jQ(this).click();
                    e.preventDefault();
                }
            });
            if (DEBUG) console.info("List: Archive filter data found - id=" + filter.id + ", elementId=" + filter.elementId);

            if (typeof filter.initparams !== "undefined" && filter.initparams != "") {
                if (DEBUG) console.info("List: Data filter init params - " + filter.initparams);
                // highlight filter correctly
                listFilter(filter.elementId, null, filter.id, filter.initparams, false);
            }

        });
    }
}
