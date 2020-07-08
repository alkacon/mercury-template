<%@ tag display-name="meta-value"
    pageEncoding="UTF-8"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates the canonical link for the current page." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="isSearchPage"       value="${fn:startsWith(cms.pageResource.link, cms.functionDetail['Search page'])}" />
<c:set var="isListPage"         value="${not isSearchPage and (not empty param.page)}" />
<c:set var="hasRequestLocale"   value="${not empty param.__locale}" />

<%--
    Check for request parameters.
    There are a number of edge cases where the Mercury template will generate a link that contains parameters.
    For the canonical URL, sometimes these parameters are required, sometimes they can be neglected.
    This implementation handles parameters for
        a) the search page (just ignore all parameters)
        b) lists (keep the selected page)
        c) __locale requests (important for detail pages to generate the right canonical URL)
    If other parameters are found we do not want to set a potential wrong canonical URL.
    So we do not set the canonical URL for a request that contains other parameters.
--%>
<c:if test="${not isSearchPage and not isListPage and not hasRequestLocale}">
    <c:set var="requestQueryString"><%= request.getQueryString() != null ? request.getQueryString() : "" %></c:set>
</c:if>

<c:if test="${empty requestQueryString}">

    <%--
        Parameters that have to be appended to the canonical link.
        This is currently only implemented for list pages.
    --%>
    <c:if test="${isListPage and param.page ne '1'}">
        <c:set var="canonicalParams" value="?page=${param.page}" />
    </c:if>

    <%--
        Generate hreflang links for locale variations of the page.
        Calculated first because in case a __locale parameter is found, the canonical URL is adjusted.
        According to YOAST [https://yoast.com/hreflang-ultimate-guide/] hreflang must reflect the canonical URL.
    --%>
    <c:set var="locales" value="${cms.site.translationLocales}" />
    <c:if test="${locales.size() > 1}">
        <c:set var="hreflangURLs">
            <c:forEach var="locale" items="${locales}" varStatus="status">
                <c:set var="targetLink" value="${null}" />
                <c:set var="targetLocale" value="${locale.language}" />
                <c:choose>
                    <c:when test="${cms.detailRequest and not cms.detailContent.xml.hasLocale[targetLocale]}">
                        <c:set var="targetLink" value="" />
                    </c:when>
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
                    <link rel="alternate" hreflang="${targetLocale}" href="${cms.site.url}${targetLink}${canonicalParams}" /><mercury:nl /><%----%>
                    <c:if test="${hasRequestLocale and (targetLocale eq param.__locale)}">
                        <c:set var="canonicalURL" value="${targetLink}" />
                    </c:if>
                </c:if>
            </c:forEach>
        </c:set>
    </c:if>

    <%--
        Check if meta-info was used to custom set a canonical URL.
        If this is so, canonical parameters are ignored.
    --%>
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

    <%--
        Set the canonical URL it is is not set already.
        It may have been set by the hreflang calculation OR the meta information before.
    --%>
    <c:if test="${empty canonicalURL}">
        <c:set var="canonicalURL" value="${cms.detailRequest ? cms.detailContent.link : cms.pageResource.link}${canonicalParams}" />
    </c:if>

    <%-- Output the canonical URL --%>
    <c:if test="${fn:startsWith(canonicalURL, '/')}">
        <c:set var="canonicalURL" value="${cms.site.url}${canonicalURL}" />
    </c:if>
    <link rel="canonical" href="${canonicalURL}" /><mercury:nl /><%----%>

    <%-- Output the hreflang links --%>
    ${hreflangURLs}

</c:if>
