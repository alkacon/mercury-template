<%@ tag display-name="meta-value"
    pageEncoding="UTF-8"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates the canonical link for the current page." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="requestQueryString"><%= request.getQueryString() != null ? request.getQueryString() : "" %></c:set>

<%-- Check for request parameters --%>
<%--
    There are a number of edge cases where OpenCms will generate a link that contains parameters.
    For the canonical URL, sometimes these parameters are required, sometimes they could be neglected.
    At the moment detailed parameter analysis is not implemented.
    We want to avoid setting a potential wrong canonical URL.
    So we do not set the canonical URL for a request that contains parameters.
--%>
<c:if test="${empty requestQueryString}">

    <%-- Check if meta-info was used to custom set a canonical URL --%>
    <c:if test="${not empty cms.meta.canonicalURL}">
        <c:choose>
            <c:when test="${fn:startsWith(cms.meta.canonicalURL, '/') and cms.vfs.exists[cms.meta.canonicalURL]}">
                <c:set var="res" value="${cms.vfs.resource[cms.meta.canonicalURL]}" />
                <c:set var="canonicalURL" value="${res.file ? res.link : res.navigationDefaultFile.link}" />
            </c:when>
            <c:otherwise>
                <c:set var="canonicalURL" value="${cms.meta.canonicalURL}" />
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${empty canonicalURL}">
        <c:set var="canonicalURL" value="${cms.detailRequest ? cms.detailContent.link : cms.pageResource.link}" />
    </c:if>

    <%-- Output the canonical URL --%>
    <c:if test="${fn:startsWith(canonicalURL, '/')}">
        <c:set var="canonicalURL" value="${cms.site.url}${canonicalURL}" />
    </c:if>
    <link rel="canonical" href="${canonicalURL}" /><mercury:nl /><%----%>


    <%-- List locale variations of the page as hreflang links --%>
    <%--
        According to YOAST [https://yoast.com/hreflang-ultimate-guide/] hreflang must reflect the canonical URL.
        Since we do not provide a canonical URL for parameter requests, we do not provide hreflang in this case either.
    --%>
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

</c:if>
