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

<c:if test="${not empty cms.meta.canonicalURL}">
    <c:choose>
        <c:when test="${fn:startsWith(cms.meta.canonicalURL, '/') and cms.vfs.exists[cms.meta.canonicalURL]}">
            <c:set var="res" value="${cms.vfs.resource[cms.meta.canonicalURL]}" />
            <c:set var="canonicalLink" value="${cms.site.url}${res.file ? res.link : res.navigationDefaultFile.link}" />
        </c:when>
        <c:when test="${fn:startsWith(cms.meta.canonicalURL, '/')}">
            <c:set var="canonicalLink" value="${cms.site.url}${cms.meta.canonicalURL}" />
        </c:when>
        <c:otherwise>
            <c:set var="canonicalLink" value="${cms.meta.canonicalURL}" />
        </c:otherwise>
    </c:choose>
</c:if>
<c:if test="${empty canonicalLink}">
    <c:set var="canonicalLink" value="${cms.site.url}${cms.detailRequest ? cms.detailContent.link : cms.pageResource.link}" />
</c:if>

<%-- Generate the canonical link --%>
<c:if test="${canonicalLink ne requestUri}">
    <%-- Check for request parameters --%>
    <c:set var="requestQueryString"><%= request.getQueryString() != null ? request.getQueryString() : "" %></c:set>
    <c:if test="${empty requestQueryString}">
        <%-- Let the robot decide what to do with an URI that contains parameters, don't set canonical link in this case --%>
        <link rel="canonical" href="${canonicalLink}" /><mercury:nl /><%----%>
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