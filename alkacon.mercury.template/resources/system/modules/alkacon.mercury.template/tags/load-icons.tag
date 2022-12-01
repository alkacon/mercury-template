<%@ tag pageEncoding="UTF-8"
    display-name="load-icons"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Loads icon font set depending on the sitemap configuration." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="version"            value="my-1" />
<c:set var="fontConfig"         value="${cms.sitemapConfig.attribute['mercuryIconFontConfig'].toString}" />

<%-- Include icon CSS --%>
<c:choose>
    <c:when test="${fontConfig eq 'awesomeSelection'}">
        <%-- Load Fork Awesome icon selection CSS--%>
        <c:set var="cssPath"    value="/system/modules/alkacon.mercury.theme/css/awesome-selection.min.css" />
        <c:set var="fontPath"   value="/system/modules/alkacon.mercury.theme/fonts/awesome-selection.woff2" />
    </c:when>
    <c:when test="${fontConfig eq 'bootstrapSelection'}">
        <%-- Load Bootstrap icon selection CSS--%>
        <c:set var="cssPath"    value="/system/modules/alkacon.mercury.theme/css/bootstrap-selection.min.css" />
        <c:set var="fontPath"   value="/system/modules/alkacon.mercury.theme/fonts/bootstrap-selection.woff2" />
    </c:when>
    <c:otherwise>
        <%-- Load full Fork Awesome CSS --%>
        <c:set var="cssPath"    value="/system/modules/alkacon.mercury.theme/css/awesome-full.min.css" />
        <c:set var="fontPath"   value="/system/modules/alkacon.mercury.theme/fonts/awesome-full.woff2" />
    </c:otherwise>
</c:choose>

<link href="<mercury:link-resource resource='${cssPath}'/>" rel="stylesheet"><%----%>
<mercury:nl />

<jsp:doBody />

<%-- Preload the icon fonts. --%>
<link href="<cms:link>${fontPath}</cms:link>?v=${version}" rel="preload" as="font" type="font/woff2" crossorigin><%----%>
<mercury:nl />
<%--
    NOTE: It is NOT possible to use <mercury:link-resource /> here for preloading fonts!
    This is because the path WITH PARAMETERS given in the CSS must exactly match the preload path.
    <mercury:link-resource /> would append a parameter hash value based on the date last modified, which is NOT what is in the CSS.
    Therefore the preload would fail!
--%>
