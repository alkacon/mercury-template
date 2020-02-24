<%@ tag pageEncoding="UTF-8"
    display-name="list-sort-button"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a sort options dropdown button for the list."%>


<%@ attribute name="elementId" type="java.lang.String" required="false"
    description="The id of the list content element (UID of the list resource)." %>

<%@ attribute name="label" type="java.lang.String" required="false"
    description="The label that is used for the button." %>

<%@ attribute name="params" type="java.lang.String" required="false"
    description="Can be used to select the sort options to show. Shows all options if not set." %>

<%@ attribute name="searchconfig" type="java.lang.String" required="false"
    description="The configuration string that was used by the cms:search tag." %>

<%@ attribute name="searchresult" type="org.opencms.jsp.search.result.I_CmsSearchResultWrapper" required="false"
    description="The results of the search performed by the cms:search tag." %>

<%@ attribute name="render" type="java.lang.Boolean" required="false"
    description="Determines if the content should be rendered or given as a list of items in the listItems variable." %>


<%@ variable name-given="listItems" scope="AT_END" declare="true"
    description="The items of the button stored in a list." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<%-- Acquire search result --%>
<c:choose>
<c:when test="${not empty searchresult}">
    <c:set var="search" value="${searchresult}" />
</c:when>
<c:when test="${not empty searchconfig}">
    <cms:search configString="${searchconfig}" var="search" addContentInfo="true" />
</c:when>
<c:otherwise>
    <%-- If no search results or config given, set error flag --%>
    <c:set var="error" value="true" />
</c:otherwise>
</c:choose>


<%-- Start processing button --%>
<c:if test="${not error}">

    <c:set var="sortController" value="${search.controller.sorting}" />
    <c:if test="${not empty sortController and not empty sortController.config.sortOptions}">
        <c:set var="sortOption" value="${sortController.config.sortOptions[0]}" />
        <c:set var="sortIndex" value="1" />
        <c:if test="${sortController.state.checkSelected[sortOption] != true}">
            <c:set var="sortOption" value="${sortController.config.sortOptions[1]}" />
            <c:set var="sortIndex" value="0" />
        </c:if>
    </c:if>

    <c:set var="head">
        <c:out value='<div class="list-option">' escapeXml='false' />
            <button${' '}<%--
                --%>type="button"${' '}<%--
                --%>class="dropdown-toggle btn"${' '}<%--
                --%>data-toggle="dropdown"${' '}<%--
                --%>data-display="static"${' '}<%--
                --%>aria-haspopup="true"${' '}<%--
                --%>aria-expanded="false"${' '}<%--
                --%>aria-expanded="true"<%--
            --%>><%--
            --%><span>${label}</span><%--
            --%></button><%----%>
            <mercury:nl />
            <c:out value='<ul class="list-optionlist dropdown-menu">' escapeXml='false' />
    </c:set>

    <c:set var="delimiter" value="|" />

    <c:set var="items">
        <c:forEach var="sortOption" items="${sortController.config.sortOptions}" varStatus="status">
            <c:if test="${empty params || fn:contains(params, sortOption.paramValue)}">
                <c:set var="selected">${sortController.state.checkSelected[sortOption] ? ' class="active"' : ""}</c:set>
                <li ${selected}><%----%>
                    <a href="javascript:void(0)" onclick="DynamicList.facetFilter(<%--
                    --%>'${elementId}', <%--
                    --%>'SORT', <%--
                    --%>'${search.stateParameters.setSortOption[sortOption.paramValue]}')"><%----%>
                        <fmt:message key="msg.page.list.sort.${sortOption.label}" />
                    </a><%----%>
                </li><%----%>
                <mercury:nl />
            </c:if>
        </c:forEach>
    </c:set>

    <c:set var="foot">
        <c:out value='</ul>' escapeXml='false' />
        <c:out value='</div>' escapeXml='false' />
    </c:set>

    <c:set var="listItems" value="${items}" />
    <c:if test="${render != 'false'}">
        ${head}
        <c:forTokens items="${items}" delims="|" var="item">
            ${item}
        </c:forTokens>
        ${foot}
    </c:if>

</c:if>
