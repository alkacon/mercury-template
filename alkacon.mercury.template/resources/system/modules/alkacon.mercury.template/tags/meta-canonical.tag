<%@ tag display-name="meta-value"
    pageEncoding="UTF-8"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates the canonical link for the current page." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="requestUri"><%= request.getPathInfo() %></c:set>
<c:set var="canonicalLink" value="${cms.detailRequest ? cms.detailContent.link : cms.pageResource.link}" />

<%-- Generate the canonical link --%>
<c:if test="${canonicalLink ne requestUri}">
    <%-- Check for request parameters --%>
    <c:set var="requestQueryString"><%= request.getQueryString() != null ? request.getQueryString() : "" %></c:set>
    <c:if test="${empty requestQueryString}">
        <%-- Let the robot decide what to do with an URI that contains parameters, don't set canonical link in this case --%>
        <link rel="canonical" href="${cms.site.url}${canonicalLink}${not empty requestQueryString ? '?'.concat(requestQueryString) : ''}" /><mercury:nl /><%----%>
    </c:if>
</c:if>

<%-- List locale variations of the page --%>
<c:set var="locales" value="${cms.site.translationLocales}" />
<c:if test="${locales.size() > 1}">
    <c:forEach var="locale" items="${locales}" varStatus="status">
        <c:set var="targetLink" value="${null}" />
        <c:set var="targetLocale" value="${locale.language}" />
        <c:choose>
            <c:when test="${cms.detailRequest}">
                <c:set var="targetLink">
                    <cms:link locale="${targetLocale}" baseUri="${cms.localeResource[targetLocale].sitePath}">${cms.detailContent.sitePath}</cms:link>
                </c:set>
            </c:when>
            <c:otherwise>
                <c:set var="targetLink" value="${cms.pageResource.localeResource[targetLocale].link}" />
            </c:otherwise>
        </c:choose>
        <c:if test="${not empty targetLink}">
            <%-- Output of alternate language link --%>
            <link rel="alternate" hreflang="${targetLocale}" href="${cms.site.url}${targetLink}" /><mercury:nl /><%----%>
        </c:if>
    </c:forEach>
</c:if>