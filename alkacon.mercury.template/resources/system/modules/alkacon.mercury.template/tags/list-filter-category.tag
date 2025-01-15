<%@ tag pageEncoding="UTF-8"
    display-name="list-filter-category"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays a list of categories from the facet of the search result." %>


<%@ attribute name="search" type="org.opencms.jsp.search.result.CmsSearchResultWrapper" required="true"
    description="The complete search result." %>

<%@ attribute name="facetValues" type="java.util.List" required="true"
    description="The search result for the category facet." %>

<%@ attribute name="facetController" type="org.opencms.jsp.search.controller.I_CmsSearchControllerFacetField" required="true"
    description="The controller for the category facet." %>

<%@ attribute name="categoryFilterId" type="java.lang.String" required="true"
    description="The id of the category filter element." %>

<%@ attribute name="catfilter" type="java.lang.String" required="false"
    description="Filter for categories by the localized name." %>

<%@ attribute name="onlyLeafs" type="java.lang.Boolean" required="false"
    description="Flag, indicating if only leaf categories should be displayed." %>

<%@ attribute name="displayCatPath" type="java.lang.Boolean" required="false"
    description="Flag, indicating if the whole path of the category should be displayed." %>

<%@ attribute name="showCatCount" type="java.lang.Boolean" required="false"
    description="Flag, indicating if count for category should be displayed. Default is 'true'." %>

<%@ attribute name="showAll" type="java.lang.Boolean" required="false"
    description="If provided, the 'all' option is displayed." %>

<%@ attribute name="targetUri" type="java.lang.String" required="false"
    description="The (site path) where to link to, usually where the list for the category filter is placed on. If not provided, the current page is default." %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="onlyLeafs"          value="${empty onlyLeafs ? false : onlyLeafs}" />
<c:set var="displayCatPath"     value="${empty displayCatPath ? false : displayCatPath}" />
<c:set var="showCatCount"       value="${empty showCatCount ? true : showCatCount}" />
<c:set var="showAllOption"      value="${empty showAll ? false : showAll}" />
<c:set var="onlyLeafs"          value="${empty onlyLeafs ? false : onlyLeafs}" />
<c:set var="targetUri"          value="${empty targetUri ? cms.requestContext.uri : targetUri}" />

<m:nl />
<ul><%----%>
<m:nl />

    <%-- BEGIN: Calculate category filters --%>
    <c:set var="catFilters" value="${not empty catfilter ? fn:replace(catfilter,' ','') : ''}" />
    <c:set var="blacklistFilter" value="${empty catFilters}" />
    <c:if test="${not empty catFilters}">
        <c:choose>
        <c:when test="${fn:startsWith(catFilters,'whitelist:')}">
            <c:set var="catFilters" value="${fn:replace(catFilters,'whitelist:','')}" />
        </c:when>
        <c:when test="${fn:startsWith(catFilters,'blacklist:')}">
            <c:set var="catFilters" value="${fn:replace(catFilters,'blacklist:','')}" />
            <c:set var="blacklistFilter" value="true" />
        </c:when>
        </c:choose>
        <c:set var="catFilters" value='${fn:split(catFilters, ",")}' />
    </c:if>
    <%-- END: Calculate category filters --%>

    <c:set var="dataparam"></c:set>
    <c:set var="basicSearchStateParameters" value="${search.stateParameters.resetAllFacetStates.newQuery['']}" />

    <c:forEach var="value" items="${facetValues}" varStatus="outerStatus">
        <c:if test="${not empty cms.readCategory[value.name]}">
            <c:if test="${not onlyLeafs or outerStatus.last or not fn:startsWith(facetValues[outerStatus.count].name, value.name)}">
                <c:set var="active" value="${facetController.state.isChecked[value.name]}" />

                <%-- BEGIN: Calculate category label --%>
                <c:set var="catCompareLabel" value="" />
                <c:set var="label" value="" />
                <c:forEach var="category" items="${cms.readPathCategories[value.name]}" varStatus="status">
                    <c:if test="${displayCatPath or status.last}">
                        <c:set var="label">${label}${category.title}</c:set>
                        <c:set var="catId"><m:idgen prefix="cat_${categoryFilterId}" uuid="${category.id}" /></c:set>
                    </c:if>
                    <c:set var="catCompareLabel">${catCompareLabel}${category.title}</c:set>
                    <c:if test="${not status.last}">
                        <c:if test="${displayCatPath}"><c:set var="label" value="${label} / "/></c:if>
                        <c:set var="catCompareLabel">${catCompareLabel}/</c:set>
                    </c:if>
                </c:forEach>
                <%-- END: Calculate category label --%>

                <c:set var="catCompareLabel" value="${fn:replace(catCompareLabel,' ','')}" />
                <c:set var="isMatchedByFilter" value="false" />
                <c:forEach var="filterValue" items="${catFilters}" varStatus="status">
                    <c:if test="${isMatchedByFilter or fn:contains(catCompareLabel, filterValue)}">
                        <c:set var="isMatchedByFilter" value="true" />
                    </c:if>
                </c:forEach>

                <c:if test="${blacklistFilter != isMatchedByFilter}">
                    <c:if test="${showAllOption}">
                        <li id="cat_${categoryFilterId}" class="enabled levelAll" <%--
                            --%>data-category-id="cat_${categoryFilterId}" <%--
                            --%>data-param=""><%----%>
                            <a tabindex="0" class="fi-toggle" <%--
                                --%>href="<cms:link>${targetUri}?${basicSearchStateParameters}</cms:link>"><%----%>
                                <span class="li-entry"><%----%>
                                    <span class="li-label"><fmt:message key="msg.page.list.facet.category.all" /></span><%----%>
                                </span><%----%>
                             </a><%----%>
                        </li><%----%>
                        <m:nl />
                        <c:set var="showAllOption" value="${false}" />
                    </c:if>

                    <c:set var="currentLevel" value="${fn:length(fn:split(value.name, '/'))}" />
                    <li id="${catId}" class="enabled level${currentLevel}${active ? ' active' : ''}" <%--
                        --%>data-category-id="${catId}" <%--
                        --%>data-value="${value.name}" <%--
                        --%>data-label="${label.replace('"','&quot')}"><%----%>
                        <a tabindex="0" class="fi-toggle" <%--
                            --%>href="<cms:link>${targetUri}?${empty active ? basicSearchStateParameters.checkFacetItem[facetController.config.name][value.name] : basicSearchStateParameters}</cms:link>"><%----%>
                            <span class="li-entry"><%----%>
                                <span class="li-label">${label}</span><%----%>
                                <c:if test="${showCatCount}">
                                    <span class="li-count">${value.count}</span><%----%>
                                </c:if>
                            </span><%----%>
                        </a><%----%>
                    </li><%----%>
                    <m:nl />
                </c:if>
            </c:if>
        </c:if>
    </c:forEach>
</ul><%----%>
<m:nl />

