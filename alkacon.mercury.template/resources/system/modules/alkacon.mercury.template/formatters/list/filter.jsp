<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<mercury:init-messages reload="true">

<cms:formatter var="content" val="value" locale="en">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

    <%-- We just want to load facet metadata here, no actual results, so the count is 0 --%>
    <mercury:list-search
        config="${content}"
        count="0"
    />

    <c:set var="setting"        value="${cms.element.setting}" />
    <c:set var="cssWrapper"     value="${setting.cssWrapper}" />

    <c:set var="searchLabel"    value="${setting.searchlabel.toString}" />
    <c:set var="showSearch"     value="${setting.showsearch.toBoolean}" />
    <c:set var="showReset"     value="${setting.showresetbutton.toBoolean}" />

    <c:set var="categoryLabel"  value="${setting.headline.toString}" />
    <c:set var="categoryVal"    value="${setting.showcategories.toString}" />
    <c:set var="categoriesOpen" value="${categoryVal eq 'opened'}" />
    <c:set var="categoriesResp" value="${categoryVal.contains('op-')}" />
    <c:set var="showCategories" value="${(categoriesOpen || categoriesResp || categoryVal eq 'closed') and not empty categoryFacetResult and cms:getListSize(categoryFacetResult.values) > 0}" />
    <c:set var="showCatCount"   value="${not fn:contains(setting.showCatCount.useDefault('true').toString, 'false')}" />
    <c:set var="showAllOption"  value="${not fn:contains(setting.showCatCount.useDefault('true').toString, 'hide-all')}" />

    <c:set var="archiveLabel"   value="${setting.archivelabel.toString}" />
    <c:set var="archiveVal"     value="${setting.showarchive.toString}" />
    <c:set var="archiveOpen"    value="${archiveVal eq 'opened'}" />
    <c:set var="archiveResp"    value="${archiveVal.contains('op-')}" />
    <c:set var="showArchive"    value="${(archiveOpen || archiveResp || archiveVal eq 'closed') and not empty rangeFacet and cms:getListSize(rangeFacet.counts) > 0}" />

    <c:set var="folderLabel"    value="${setting.folderlabel.toString}" />
    <c:set var="folderVal"      value="${setting.showfolders.toString}" />
    <c:set var="foldersOpen"    value="${folderVal eq 'opened'}" />
    <c:set var="foldersResp"    value="${folderVal.contains('op-')}" />
    <c:set var="showFolders"    value="${(foldersOpen || foldersResp || setting.showfolders.toString eq 'closed') and not empty folderFacetResult and cms:getListSize(folderFacetResult.values) > 0}" />

    <c:set var="showDirectLink" value="${cms.isEditMode and 'true' eq cms.readAttributeOrProperty[cms.requestContext.uri]['mercury.list.filter.directlink']}" />

    <c:set var="combine"        value="${setting.combine.toBoolean}" />

    <c:set var="targetUri"      value="${setting.targetUri.toString}" />

    <c:set var="elementId"><mercury:idgen prefix="le" uuid="${cms.element.id}" /></c:set>
    <c:set var="filterId"><mercury:idgen prefix="la" uuid="${cms.element.instanceId}" /></c:set>

    <c:if test="${empty targetUri}">
        <c:set var="targetUri" value="${cms.vfs.propertySearch[cms.requestContext.uri]['mercury.list']}" />
    </c:if>
    <c:set var="basicSearchParameters" value="${search.emptyStateParameters}" />

    <c:set var="initparams" value="" />
    <c:if test="${not empty param.facet_category_exact}">
        <c:set var="initparams" value="&facet_category_exact=${param.facet_category_exact}" />
       </c:if>
    <c:if test="${not empty param.q}">
        <c:set var="initparams" value="${initparams}&q=${param.q}" />
       </c:if>
    <c:if test="${not empty param.facet_instancedate}">
        <c:set var="initparams" value="${initparams}&facet_instancedate=${param.facet_instancedate}" />
       </c:if>
    <c:if test="${not empty param['facet_parent-folders']}">
        <c:set var="initparams" value="${initparams}&facet_parent-folders=${param['facet_parent-folders']}" />
       </c:if>
    <c:if test="${not empty initparams}">
        <c:set var="initparams">${initparams.replace("'","&#39;")}</c:set>
        <c:set var="initparams" value="reloaded${initparams}" />
    </c:if>

    <c:set var="resetButtonTitle"><fmt:message key="msg.page.list.resetbutton.title" /></c:set>

    <mercury:nl />
    <div class="element type-list-filter pivot ${cssWrapper}" <%--
    --%>id="${filterId}" <%--
    --%>data-id="${elementId}" <%--
    --%>data-filter='{<%--
        --%>"search":"${showSearch}", <%--
        --%>"reset":"${showReset}", <%--
        --%>"categories":"${showCategories}", <%--
        --%>"archive":"${showArchive}", <%--
        --%>"folders":"${showFolders}", <%--
        --%>"searchstatebase":"${search.controller.common.config.reloadedParam}", <%--
        --%>"catparamkey":"${categoryFacetController.config.paramKey}", <%--
        --%>"archiveparamkey":"${rangeFacetController.config.paramKey}", <%--
        --%>"folderparamkey":"${folderFacetController.config.paramKey}", <%--
        --%>"combinable": true, <%--
        --%>"combine": ${combine},<%--
        --%>"resetbuttontitle": "${resetButtonTitle}"<%--_
        --%><c:if test="${not empty targetUri}">, "target":"<cms:link>${targetUri}</cms:link>"</c:if><%--
        --%><c:if test="${not empty initparams}">, "initparams":"${initparams}"</c:if><%--
        --%>}'><%----%>
        <mercury:nl />

        <c:if test="${showSearch}">
            <c:if test="${empty searchLabel}">
                <c:set var="searchLabel"><fmt:message key="msg.page.search.inlist" /></c:set>
            </c:if>
            <c:set var="searchResetLabel"><fmt:message key="msg.page.search.inlist.resetlabel" /></c:set>
            <div class="filterbox search"><%----%>
            <mercury:nl />

                <form class="styled-form bo-none" id="queryform_${filterId}" onsubmit="DynamicList.archiveSearch(<%--
                    --%>'${filterId}', <%--
                --%>'${search.controller.common.config.queryParam}='<%--
                --%>); <%--
                   --%>return false;" action="<cms:link>${targetUri}</cms:link>"><%----%>

                    <c:set var="fieldId">textsearch_${filterId}</c:set>
                        <c:set var="escapedQuery">${fn:replace(search.controller.common.state.query,'"','&quot;')}</c:set>
                        <input type="hidden" name="${search.controller.common.config.lastQueryParam}" value="${escapedQuery}" /><%----%>
                        <input type="hidden" name="${search.controller.common.config.reloadedParam}" /><%----%>
                        <label for="${fieldId}" class="input"><%----%>
                            <span class="sr-only"><c:out value="${searchLabel}" /></span><%----%>
                            <mercury:icon icon="search" tag="span" cssWrapper="icon-prepend" inline="${false}" />
                            <input <%--
                            --%>name="${search.controller.common.config.queryParam}" <%--
                            --%>id="${fieldId}" <%--
                            --%>type="text" <%--
                            --%>value="${escapedQuery}" <%--
                            --%>data-label="${fn:replace(searchResetLabel,'"','&quot;')}" <%--
                            --%>placeholder="<c:out value="${searchLabel}" />"><%----%>
                        </label><%----%>
                </form><%----%>
            </div><%----%>
            <mercury:nl />
        </c:if>

        <c:if test="${showReset}">
            <%-- IMPORTANT: The div must really be empty. Otherwise CSS style :empty does not match. --%>
            <div id="resetbuttons_${filterId}" class="filterbox resetbuttons"><%-- Filled dynamically via JavaScript. --%></div>
        </c:if>

        <c:if test="${showCategories}">
            <c:if test="${empty categoryLabel}">
                <c:set var="categoryLabel"><fmt:message key="msg.page.categories" /></c:set>
            </c:if>

            <div class="filterbox categories"><%----%>
            <mercury:nl />

                <%-- get the currently checked item - if not present it's just empty. --%>
                <c:set var="checkedItem" value="${categoryFacetController.state.checkedEntries[0]}"/>
                <%-- Open the facet if it has a checked entry independent of the according element setting. --%>
                <c:set var="categoriesOpen" value="${categoriesOpen || not empty checkedItem}"/>

                <button type="button" <%--
                --%>class="btn btn-block li-label ${categoriesOpen ? '' : 'collapsed'}${categoriesResp ? ' resp' : ''}" <%--
                --%>data-bs-target="#cats_${filterId}" <%--
                --%>data-bs-toggle="collapse" <%--
                --%>aria-controls="cats_${filterId}" <%--
                --%>aria-expanded="${categoriesOpen}"><%--
                --%><c:out value="${categoryLabel}" /><%--
             --%></button><%----%>
                <div id="cats_${filterId}" class="collapse${categoriesOpen ? ' show' : ''}${categoriesResp ? ' '.concat(categoryVal) : ''}"><%----%>
                    <mercury:list-filter-category
                        search="${search}"
                        facetValues="${categoryFacetResult.values}"
                        facetController="${categoryFacetController}"
                        categoryFilterId="${filterId}"
                        catfilter="${setting.catfilters.toString}"
                        onlyLeafs="${fn:contains(setting.catdisplayoptions.toString, 'onlyleafs')}"
                        displayCatPath="${fn:contains(setting.catdisplayoptions.toString, 'fullpath')}"
                        showCatCount="${showCatCount}"
                        targetUri="${targetUri}"
                        showAll="${showAllOption}"
                    />
                </div><%----%>
            </div><%----%>
            <mercury:nl />
        </c:if>

        <c:if test="${showFolders}">
            <c:if test="${empty folderLabel}">
                <c:set var="folderLabel"><fmt:message key="msg.page.folders" /></c:set>
            </c:if>
            <div class="filterbox folders"><%----%>
            <mercury:nl />

                <%-- get the currently checked item - if not present it's just empty. --%>
                <c:set var="checkedItem" value="${folderFacetController.state.checkedEntries[0]}"/>
                <%-- Open the facet if it has a checked entry independent of the according element setting. --%>
                <c:set var="foldersOpen" value="${foldersOpen || not empty checkedItem}"/>

                <button type="button" <%--
                --%>class="btn btn-block li-label ${foldersOpen ? '' : 'collapsed'}" <%--
                --%>data-bs-target="#folder_${filterId}" <%--
                --%>data-bs-toggle="collapse" <%--
                --%>aria-controls="folder_${filterId}" <%--
                --%>aria-expanded="${foldersOpen}"><%--
                --%><c:out value="${folderLabel}" /><%--
             --%></button><%----%>

                <div id="folder_${filterId}" class="collapse${foldersOpen ? ' show' : ''}${foldersResp ? ' '.concat(folderVal) : ''}"><%----%>
                    <%-- check if there might be more than one main folder (TODO: Improve this check) --%>
                    <c:set var="hasMultiplePaths" value="${cms:getListSize(content.valueList.SearchFolder) > 1}" />

                    <%-- Get the currently checked folder facet items. --%>
                    <c:set var="checkedEntries" value="${folderFacetController.state.checkedEntries}" />

                    <c:set var="foldersOpen" value="${foldersOpen || foldersResp}"/>
                    <c:set var="collapseIdPrefix"><mercury:idgen prefix="nav" uuid="${cms.element.instanceId}" /></c:set>

                    <%-- Start building the HTML for the folder facet items.
                         It has to be exactly like the HTML for the side navigation.
                    --%>
                    <ul class="nav-side"><%----%>
                        <mercury:nl />
                        <%-- If multiple folders are present, prepend an "all" folder. --%>
                        <c:if test="${hasMultiplePaths}">
                            <c:set var="folderId">folder_${filterId}_0</c:set>
                            <c:out escapeXml='false' value='<li id="${folderId}" data-param="" class="currentpage enabled">' />
                                <c:set var="onclick">onclick="DynamicList.archiveFilter(<%--
                                                --%>'${filterId}', <%--
                                                --%>'${folderId}'<%--
                                            --%>); return false;"</c:set>
                                <c:set var="collapseId">${collapseIdPrefix}_${0}</c:set>
                                <a ${onclick} href="<cms:link>${targetUri}?${basicSearchParameters}</cms:link>" class="nav-label"><fmt:message key="msg.page.list.facet.folder.all"/></a><%--
                            --%><a href="<cms:link>${targetUri}?${basicSearchParameters}</cms:link>" <%--
                                --%>class="collapse show" <%--
                                --%>data-bs-toggle="collapse" <%--
                                --%>data-bs-target="#${collapseId}" <%--
                                --%>aria-expanded="true" <%--
                                --%>aria-controls="${collapseId}">&nbsp;</a><%----%>
                                <c:out escapeXml='false' value='<ul class="collapse show" id="${collapseId}">' />
                        </c:if>

                        <%-- Clear the start folder path. This implies that we have not rendered any item yet. --%>
                        <c:set var="startFolderPath"></c:set>

                        <c:set var="folderParameterMap" value="${basicSearchParameters.checkFacetItem[folderFacetController.config.name]}" />

                        <%-- Render the facet items. We always render the previous item, since it is necessary to know the navigation tree level of the next. --%>
                        <c:forEach items="${folderFacetResult.values}" var="value" varStatus="status" >
                            <%-- Folder: ${value.name} (${value.count}) --%>
                            <c:set var="folder" value="${value.name}" />

                            <%-- Check, if the folder should be displayed at all. If we collect facet entries also for empty folders, not every folder should be shown. --%>
                            <c:set var="shouldDisplay" value="${false}" />
                            <c:forEach var="configuredFolder" items="${content.valueList.SearchFolder}" varStatus="shouldDisplayStatus">
                                <c:if test="${fn:startsWith(folder, configuredFolder.xmlText['link/target'])}">
                                    <c:set var="shouldDisplay" value="${true}" />
                                    <c:set var="shouldDisplayStatus.index" value="${cms:getListSize(content.valueList.SearchFolder)}" /> <%-- break for the loop --%>
                                </c:if>
                            </c:forEach>

                            <%-- Act only if the folder should be shown. --%>
                            <c:if test="${shouldDisplay}">

                                <c:set var="currentSitePath" value="${cms.sitePath[folder]}" />
                                <c:set var="currentDeps" value="${fn:length(fn:split(currentSitePath,'/'))}" />

                                <c:choose>
                                <%-- The first item - do not show anything. --%>
                                <c:when test="${empty startFolderPath}">
                                    <c:set var="startFolderPath">${currentSitePath}</c:set>
                                    <c:set var="startDeps" value="${currentDeps}" />
                                </c:when>

                                <%-- There has been an item before - show it. --%>
                                <c:otherwise>
                                    <c:set var="liAttrs">id="${folderId}" data-value="${previousFolder}" ${isCurrentPage ? ' class="currentpage enabled"' : 'class="enabled"'} data-label="${label.replace('"','&quot;')}"</c:set>
                                    <c:out escapeXml='false' value='<li ${liAttrs}>' />
                                    <a ${onclick} href="<cms:link>${targetUri}?${folderParameterMap[previousFolder]}</cms:link>" class="nav-label">${label}</a><%----%>
                                    <mercury:nl />

                                    <c:choose>
                                    <%-- The current item will be from a completely different folder than the previous one.
                                         So close all open nested lists.
                                     --%>
                                    <c:when test="${not fn:startsWith(currentSitePath, startFolderPath)}">
                                        <c:out escapeXml='false' value='</li>' /><%-- close the last item --%>
                                        <c:if test="${previousDeps > startDeps}">
                                            <c:forEach begin="1" end="${previousDeps - startDeps}">
                                                <c:out escapeXml='false' value='</ul></li>' />
                                            </c:forEach>
                                        </c:if>
                                        <c:set var="startFolderPath">${currentSitePath}</c:set>
                                        <c:set var="startDeps" value="${currentDeps}" />
                                    </c:when>

                                    <%-- The current item is a sub-folder of the previous one - start a new sub-level --%>
                                    <c:when test="${currentDeps > previousDeps}">
                                        <c:set var="collapseId">${collapseIdPrefix}_${status.count}</c:set>
                                        <a href="#${collapseId}" <%--
                                        --%>class="collapse${foldersOpen || isCurrentPage ? ' show' : ' collapsed'}" <%--
                                        --%>data-bs-toggle="collapse"  <%--
                                        --%>data-bs-target="#${collapseId}"  <%--
                                        --%>aria-controls="${collapseId}" <%--
                                        --%>aria-expanded="${foldersOpen || isCurrentPage}">&nbsp;</a><%----%>
                                        <mercury:nl />
                                        <c:set var="collapseIn" value="${foldersOpen || isCurrentPage ? ' show' : ''}" />
                                        <c:out escapeXml='false' value='<ul class="collapse${collapseIn}" id="${collapseId}">' />
                                    </c:when>

                                    <%-- Stay on the same level or go some levels up --%>
                                    <c:otherwise>
                                        <c:out escapeXml='false' value='</li>' />
                                        <%-- Go up some levels if necessary, since the current item is on a higher level than the previous. --%>
                                        <c:if test="${currentDeps < previousDeps}">
                                            <c:forEach begin="1" end="${previousDeps - currentDeps}">
                                                <c:out escapeXml='false' value='</ul></li>' />
                                            </c:forEach>
                                        </c:if>
                                    </c:otherwise>
                                    </c:choose>

                                </c:otherwise>
                                </c:choose>

                                <%-- Prepare values for the next iteration. --%>

                                <c:set var="sitePath" value="${cms.sitePath[folder]}" />
                                <c:set var="previousFolder" value="${folder}" />

                                <c:set var="label">${cms.vfs.readPropertiesLocale[sitePath][cms.locale]["Title"]}</c:set>
                                <c:if test="${empty label}">
                                    <c:set var="label">${cms.vfs.resource[sitePath].name}</c:set>
                                </c:if>

                                <c:set var="folderId" value="folder_${filterId}_${status.count}" />

                                <c:set var="onclick">onclick="DynamicList.archiveFilter(<%--
                                                --%>'${filterId}', <%--
                                                --%>'${folderId}'<%--
                                            --%>); return false;"<%--
                            --%></c:set>

                                <c:set var="isCurrentPage" value="${false}" />
                                   <c:forEach var="checkedItem" items="${checkedEntries}">
                                       <c:if test="${fn:startsWith(checkedItem, folder)}">
                                           <c:set var="isCurrentPage" value="${true}" />
                                       </c:if>
                                   </c:forEach>

                                   <c:set var="previousDeps" value="${currentDeps}" />
                               </c:if>
                        </c:forEach>

                        <%-- Check, if some item has been rendered at all and, if yes, if some nesting levels have to be closed. --%>
                        <c:if test="${not empty startFolderPath}">
                            <li id="${folderId}" data-value="${previousFolder}"${isCurrentPage ? ' class="currentpage enabled"' : ' class="enabled"'}><%----%>
                                <a ${onclick} href="<cms:link>${targetUri}?${folderParameterMap[previousFolder]}</cms:link>" class="nav-label">${label}</a><%----%>
                            </li><%----%>
                            <c:if test="${previousDeps > startDeps}">
                                <c:forEach begin="1" end="${previousDeps - startDeps}">
                                    <c:out escapeXml='false' value='</ul></li>' />
                                </c:forEach>
                            </c:if>
                        </c:if>

                        <%-- Close the "All" folder and it's nesting level. --%>
                        <c:if test="${hasMultiplePaths}">
                            <c:out escapeXml='false' value='</ul></li>' />
                        </c:if>
                    </ul><%----%>
                </div><%----%>
            </div><%----%>
            <mercury:nl />
        </c:if>

        <c:if test="${showArchive}">
            <c:if test="${empty archiveLabel}">
                <c:set var="archiveLabel"><fmt:message key="msg.page.archive" /></c:set>
            </c:if>
            <%-- get the currently checked item - if not present it's just empty. --%>
            <c:set var="checkedItem" value="${rangeFacetController.state.checkedEntries[0]}"/>
            <%-- Open the facet if it has a checked entry independent of the according element setting. --%>
            <c:set var="archiveOpen" value="${archiveOpen || not empty checkedItem}"/>
            <div class="filterbox archive"><%----%>
            <mercury:nl />

                <button type="button" <%--
                --%>class="btn btn-block li-label ${archiveOpen ? '' : 'collapsed'}" <%--
                --%>data-bs-target="#arch_${filterId}" <%--
                --%>data-bs-toggle="collapse" <%--
                --%>aria-controls="arch_${filterId}" <%--
                --%>aria-expanded="${archiveOpen}"><%--
                --%><c:out value="${archiveLabel}" /><%--
            --%></button><%----%>

                <div id="arch_${filterId}" class="collapse${archiveOpen ? ' show' : ''}${archiveResp ? ' '.concat(archiveVal) : ''}"><%----%>

                    <c:set var="archiveHtml" value="" />
                    <c:set var="yearHtml" value="" />
                    <c:set var="prevYear" value="-1" />

                    <%-- get the current year --%>
                    <c:choose>
                        <c:when test="${empty checkedItem}">
                            <jsp:useBean id="now" class="java.util.Date" />
                            <c:set var="showedYear"><fmt:formatDate value="${now}" pattern="yyyy" /></c:set>
                        </c:when>
                        <c:otherwise>
                            <fmt:parseDate var="checkedDate" pattern="yyyy-MM-dd'T'HH:mm:ss'Z'" value="${checkedItem}" timeZone="UTC"/>
                            <c:set var="showedYear"><fmt:formatDate value="${checkedDate}" pattern="yyyy" /></c:set>
                        </c:otherwise>
                    </c:choose>
                    <c:forEach var="facetItem" items="${rangeFacet.counts}" varStatus="status">
                        <c:set var="active">${rangeFacetController.state.isChecked[facetItem.value] ? ' class="active enabled"' : ' class="enabled"'}</c:set>
                        <fmt:parseDate var="fDate" pattern="yyyy-MM-dd'T'HH:mm:ss'Z'" value="${facetItem.value}" timeZone="UTC"/>
                        <c:set var="currYear"><fmt:formatDate value="${fDate}" pattern="yyyy" /></c:set>
                        <c:set var="activeYear" value="${currYear eq showedYear}" />
                        <c:if test="${prevYear != currYear}">
                            <%-- another year, generate year toggle button --%>
                            <c:if test="${not status.first}">
                                <%-- close month list of previous year --%>
                                <c:set var="yearHtml">${yearHtml}<c:out value='</ul>' escapeXml='false' /></c:set>
                            </c:if>
                            <c:set var="archiveHtml">${yearHtml}${archiveHtml}</c:set>
                            <c:set var="yearId">y_${currYear}_${filterId}</c:set>
                            <c:set var="yearHtml">
                                <button type="button" <%--
                                --%>class="btn btn-block year li-label ${activeYear ? '' : 'collapsed'}" <%--
                                --%>data-bs-target="#${yearId}" <%--
                                --%>data-bs-toggle="collapse" <%--
                                --%>aria-controls="${yearId}" <%--
                                --%>aria-expanded="${activeYear}"><%--
                                --%>${currYear}<%--
                            --%></button><%----%>
                                <c:set var="in" value="${activeYear ? 'show' : ''}" />
                                <c:out value='<ul class="year collapse ${in}" id="${yearId}">' escapeXml='false' />
                            </c:set>
                        </c:if>

                        <c:set var="archiveQueryMap" value="${basicSearchParameters.checkFacetItem[rangeFacetController.config.name]}" />
                        <%-- add month list entry to current year --%>
                        <c:set var="currMonth"><fmt:formatDate value="${fDate}" pattern="MMM"/></c:set>
                        <c:set var="monthId">${yearId}${currMonth}</c:set>
                        <c:set var="yearHtml">
                            ${yearHtml}
                            <mercury:nl />
                            <li id="${monthId}" ${active} tabindex="0" data-value="${facetItem.value}" data-label="${currMonth}${' '}${currYear}" onclick="DynamicList.archiveFilter(<%--
                                    --%>'${filterId}', <%--
                                --%>'${monthId}'<%--
                                --%>); return false;"><%----%>
                                <a href="<cms:link>${targetUri}?${active ? basicSearchParameters : archiveQueryMap[facetItem.value]}</cms:link>" ><%----%>
                                    <span class="li-entry"><%----%>
                                        <span class="li-label">${currMonth}</span><span class="li-count">${facetItem.count}</span><%----%>
                                    </span><%----%>
                                </a><%----%>
                            </li><%----%>
                        </c:set>
                        <c:set var="prevYear" value="${currYear}" />
                    </c:forEach>

                    <%-- close month list of last year --%>
                    <c:set var="archiveHtml">${yearHtml}<c:out value='</ul>' escapeXml='false' />${archiveHtml}</c:set>
                    ${archiveHtml}
                </div><%----%>

            </div><%----%>
            <mercury:nl />
        </c:if>

        <c:if test="${showDirectLink}">
            <div class="directlink"><%----%>
                <mercury:link link="${cms.site.url}${cms.requestContext.uri}" css="btn btn-block oct-meta-info external" newWin="${true}">
                    <fmt:message key="msg.page.list.directlink.label" />
                </mercury:link>
            </div><%----%>
            <mercury:nl />
        </c:if>
    </div><%----%>
    <mercury:nl />
</cms:bundle>
</cms:formatter>

</mercury:init-messages>
