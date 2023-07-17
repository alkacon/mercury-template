<%@ tag display-name="meta-value"
    pageEncoding="UTF-8"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Generates the canonical link for the current page." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<%@ attribute name="renderMetaTags" type="java.lang.Boolean" required="true"
    description="Controls if HTML header meta tags are rendered." %>

<%@ variable name-given="canonicalURL" declare="true"
    description="The canonical URL of the resource currently rendered." %>


<c:set var="isSearchPage"       value="${fn:startsWith(cms.pageResource.link, cms.functionDetailPage['Search page'])}" />
<c:set var="isListPage"         value="${not isSearchPage and (not empty param.page)}" />
<c:set var="hasRequestLocale"   value="${not empty param.__locale}" />
<c:set var="isPreviewLink"      value="${not empty param.__disableDirectEdit}" />

<%--
    Check for request parameters.
    There are a number of edge cases where the Mercury template will generate a link that contains parameters.
    For the canonical URL, sometimes these parameters are required, sometimes they can be neglected.
    This implementation handles parameters for
        a) the search page (just ignore all parameters)
        b) lists (keep the selected page)
        c) __locale requests (important for detail pages to generate the right canonical URL)
        d) __disableDirectEdit requests (additional parameters here are just ignored)
    If other parameters are found we do not want to set a potential wrong canonical URL.
    So we do not set the canonical URL for a request that contains other parameters.
--%>
<c:if test="${not isSearchPage and not isListPage and not hasRequestLocale and not isPreviewLink}">
    <c:set var="requestQueryString"><%= request.getQueryString() != null ? request.getQueryString() : "" %></c:set>
</c:if>

<c:if test="${empty requestQueryString}">

    <%--
        Parameters that have to be appended to the canonical link.
        This is currently only implemented for list pages.
    --%>
    <c:if test="${isListPage and param.page ne '1'}">
        <c:set var="pageNum" value="${cms.wrap[param.page].toInteger}" />
        <c:set var="canonicalParams" value="${empty pageNum ? null : '?page='.concat(pageNum)}" />
    </c:if>

    <%--
        Generate hreflang links for locale variations of the page.
        Calculated first because in case a __locale parameter is found, the canonical URL is adjusted.
        According to YOAST [https://yoast.com/hreflang-ultimate-guide/] hreflang must reflect the canonical URL.
    --%>
    <c:set var="detailContentLink" value="${cms.detailRequest ? cms.detailContent.link : null}" />
    <c:set var="locales" value="${cms.site.translationLocales}" />
    <c:if test="${locales.size() > 1}">
        <c:set var="hreflangURLs">
            <c:set var="requestedLocaleNotAvailable" value="${false}" />
            <c:forEach var="locale" items="${locales}" varStatus="status">
                <c:set var="targetLink" value="${null}" />
                <c:set var="targetLocale" value="${locale.language}" />
                <c:choose>
                    <c:when test="${cms.detailRequest and not requestedLocaleNotAvailable and not cms.detailContent.xml.hasLocale[targetLocale]}">
                        <c:set var="targetLink" value="" />
                        <c:if test="${targetLocale eq cms.locale.language}">
                            <%-- Resource not available in requested locale --%>
                            <c:set var="requestedLocaleNotAvailable" value="${true}" />
                        </c:if>
                    </c:when>
                    <c:when test="${cms.detailRequest}">
                        <c:set var="targetLink">
                            <cms:link locale="${targetLocale}" baseUri="${cms.localeResource[targetLocale].sitePath}">${cms.detailContent.sitePath}</cms:link>
                        </c:set>
                        <c:set var="splitTargetLink" value="${fn:split(targetLink, '/')}" />
                        <c:set var="targetLinkEnd" value="${splitTargetLink[fn:length(splitTargetLink)-1]}/" />
                        <c:if test="${fn:endsWith(detailContentLink, targetLinkEnd)}">
                            <c:set var="canonicalLocaleURL" value="${targetLink}" />
                        </c:if>
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
            <c:if test="${empty canonicalURL and requestedLocaleNotAvailable and not empty canonicalLocaleURL}">
                <c:set var="canonicalURL" value="${canonicalLocaleURL}" />
            </c:if>
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
        <c:set var="canonicalURL" value="${cms.detailRequest ? detailContentLink : cms.pageResource.link}${canonicalParams}" />
    </c:if>
    <c:if test="${fn:startsWith(canonicalURL, '/')}">
        <c:set var="canonicalURL" value="${cms.site.url}${canonicalURL}" />
    </c:if>

    <c:if test="${renderMetaTags}">
        <%-- Output the canonical URL --%>
        <link rel="canonical" href="${canonicalURL}" /><%----%>
        <mercury:nl />
        <mercury:nl />

        <c:if test="${not empty hreflangURLs}">
            <%-- Output the hreflang links --%>
            ${hreflangURLs}
            <mercury:nl />
            <mercury:nl />
        </c:if>
    </c:if>

</c:if>

<jsp:doBody/>
