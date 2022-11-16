<%@ tag pageEncoding="UTF-8"
    display-name="load-icons"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Loads icon font set depending on the sitemap configuration." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="configuredSet" value="${cms.sitemapConfig.attribute['mercuryIconFontConfig'].toString}" />

<c:choose>
    <c:when test="${configuredSet eq 'awesomeReduced'}">
        <c:set var="loadAwesomeReduced" value="${true}" />
    </c:when>
    <c:when test="${configuredSet eq 'bootstrap'}">
        <c:set var="loadAwesomeReduced" value="${true}" />
        <c:set var="loadBootstrap" value="${true}" />
    </c:when>
    <c:when test="${configuredSet eq 'awesomeFullAndBootstrap'}">
        <c:set var="loadAwesomeReduced" value="${false}" />
        <c:set var="loadBootstrap" value="${true}" />
    </c:when>
    <c:otherwise>
        <%-- awesomeFull --%>
        <c:set var="loadAwesomeReduced" value="${false}" />
    </c:otherwise>
</c:choose>

<%-- Include icon CSS --%>
<c:choose>
    <c:when test="${loadAwesomeReduced}">
        <%-- Load reduced Fork Awesome CSS--%>
        <link href="<mercury:link-resource resource='/system/modules/alkacon.mercury.theme/css/fork-awesome-reduced.min.css'/>" rel="stylesheet"><%----%>
    </c:when>
    <c:otherwise>
        <%-- Load full Fork Awesome CSS --%>
        <link href="<mercury:link-resource resource='/system/modules/alkacon.mercury.theme/css/fork-awesome-full.min.css'/>" rel="stylesheet"><%----%>
    </c:otherwise>
</c:choose>
<mercury:nl />

<c:if test="${loadBootstrap}">
    <%-- Load Bootstrap icon CSS--%>
    <link href="<mercury:link-resource resource='/system/modules/alkacon.mercury.theme/css/bootstrap-icons.min.css'/>" rel="stylesheet"><%----%>
    <mercury:nl />
</c:if>

<jsp:doBody />

<%--
    Preload the icon fonts.

    NOTE: It is NOT possible to use <mercury:link-resource /> for preloading fonts!
    This is because the path WITH PARAMETERS given in the CSS must exactly match the preload path.
    <mercury:link-resource /> would append a parameter hash value based on the date last modified, which is NOT what is in the CSS.
    Therefore the preload would fail!
--%>
<c:choose>
    <c:when test="${loadAwesomeReduced}">
        <%-- Preload reduced Fork Awesome font --%>
        <link href="/system/modules/alkacon.mercury.theme/fonts/forkawesome-reduced.woff2?v=1.1.7" rel="preload" as="font" type="font/woff2" crossorigin><%----%>
    </c:when>
    <c:otherwise>
        <%-- Preload full Fork Awesome font --%>
        <link href="/system/modules/alkacon.mercury.theme/fonts/forkawesome-full.woff2?v=1.1.7" rel="preload" as="font" type="font/woff2" crossorigin><%----%>
    </c:otherwise>
</c:choose>
<mercury:nl />

<c:if test="${loadBootstrap}">
    <%-- Preload Bootstrap icon font --%>
        <link href="/system/modules/alkacon.mercury.theme/fonts/bootstrap-icons.woff2?24e3eb84d0bcaf83d77f904c78ac1f47" rel="preload" as="font" type="font/woff2" crossorigin><%----%>
    <mercury:nl />
</c:if>


