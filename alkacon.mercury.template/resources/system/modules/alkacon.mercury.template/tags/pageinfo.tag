<%@ tag pageEncoding="UTF-8"
    display-name="pageinfo"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    import ="org.opencms.workplace.CmsWorkplace"
    description="Generates a DIV with runtime information that can be used from JavaScipt." %>


<%@ attribute name="contentPropertiesSearch" type="java.util.Map" required="true"
    description="The properties read from the URI resource with search." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<%-- Google Maps API key --%>
<c:set var="googleApiKey" value="${contentPropertiesSearch['google.apikey']}" />

<%-- Google Maps API key for the workplace--%>
<c:set var="googleApiKeyWorkplace" value="${contentPropertiesSearch['google.apikey.workplace']}" />

<%-- Google Analytics ID --%>
<c:set var="googleAnalyticsId" value="${contentPropertiesSearch['google.analytics']}" />

<%-- OSM API key --%>
<c:set var="osmApiKey" value="${contentPropertiesSearch['osm.apikey']}" />

<%-- OSM style URL --%>
<c:set var="osmStyleUrl" value="${contentPropertiesSearch['osm.styleurl']}" />

<%-- Piwik URL --%>
<c:set var="piwikUrl" value="${contentPropertiesSearch['piwik.url']}" />

<c:if test="${not empty piwikUrl}">
    <c:set var="piwikId" value="${contentPropertiesSearch['piwik.id']}" />
    <c:set var="piwikAddData" value="${contentPropertiesSearch['piwik.data']}" />
    <c:set var="piwikData">data-piwik='{<%--
        --%><c:if test="${not empty piwikId}">"id":"${piwikId}",</c:if><%--
        --%><c:if test="${not empty piwikAddData}">${piwikAddData},</c:if><%--
        --%>"url":"${piwikUrl}"}' <%--
--%></c:set>
</c:if>

<%-- Matomo URL --%>
<c:set var="matomoUrl" value="${contentPropertiesSearch['matomo.url']}" />

<c:if test="${not empty matomoUrl}">
    <c:set var="matomoId" value="${contentPropertiesSearch['matomo.id']}" />
    <c:set var="matomoJst" value="${contentPropertiesSearch['matomo.jst']}" />
    <c:set var="useMatomoJst" value="${not empty matomoJst ? fn:contains(matomoJst, 'true') : false}" />
    <c:set var="useMatomoDnt" value="${not empty matomoJst ? fn:contains(matomoJst, 'dnt') : false}" />
    <c:set var="matomoAddData" value="${contentPropertiesSearch['matomo.data']}" />
    <c:set var="matomoData">data-matomo='{<%--
        --%><c:if test="${not empty matomoId}">"id":"${matomoId}",</c:if><%--
        --%>"jst":${useMatomoJst},<%--
        --%>"dnt":${useMatomoDnt},<%--
        --%><c:if test="${not empty matomoAddData}">${matomoAddData},</c:if><%--
        --%>"url":"${matomoUrl}"}' <%--
--%></c:set>
</c:if>

<%-- OpenCms project --%>
<c:set var ="project" value="${cms.isOnlineProject ? 'online' : 'offline'}" />

<%-- Icon configuration --%>
<c:if test="${fn:contains(cms.sitemapConfig.attribute['mercury.iconFont.config'].toString, 'Selection')}">
    <c:set var="iconConfig"><cms:link>/system/modules/alkacon.mercury.theme/icons/fa/at.svg</cms:link></c:set>
    <c:set var="iconConfigBase64"><m:obfuscate text="${iconConfig}" type="base64"/></c:set>
    <c:if test="${fn:contains(cms.sitemapConfig.attribute['mercury.iconFont.config'].toString, 'awesome')}">
        <c:set var="fullIcons"><m:link-resource resource='/system/modules/alkacon.mercury.theme/css/awesome-full.min.css'/></c:set>
        <c:set var="fullIconsBase64"><m:obfuscate text="${fullIcons}" type="base64"/></c:set>
    </c:if>
</c:if>

<m:nl/>
<div id="template-info" data-info='{<%--
    --%><c:if test="${not empty googleApiKey}">"googleApiKey":"${googleApiKey}",</c:if><%--
    --%><c:if test="${not empty googleAnalyticsId}">"googleAnalyticsId":"${googleAnalyticsId}",</c:if><%--
    --%><c:if test="${not empty osmApiKey}">"osmApiKey":"${osmApiKey}",</c:if><%--
    --%><c:if test="${not empty osmApiKey}">"osmSpriteUrl":"<%= CmsWorkplace.getStaticResourceUri("/osm/sprite") %>",</c:if><%--
    --%><c:if test="${not empty osmApiKey and not empty osmStyleUrl}">"osmStyleUrl":"${osmStyleUrl}",</c:if><%--
    --%><c:if test="${not empty googleApiKeyWorkplace}">"googleApiKeyWorkplace":"${googleApiKeyWorkplace}",</c:if><%--
    --%><c:if test="${not empty iconConfigBase64}">"iconConfig":"${iconConfigBase64}",</c:if><%--
    --%><c:if test="${not empty fullIconsBase64}">"fullIcons":"${fullIconsBase64}",</c:if><%--
    --%>"editMode":"${cms.isEditMode}",<%--
    --%>"project":"${project}",<%--
    --%>"context":"<cms:link>/</cms:link>",<%--
    --%>"locale":"${cms.locale}"<%--
--%>}'<%--
--%>${empty matomoData ? '' : ' '.concat(matomoData)}<%--
--%>${empty piwikData ? '' : ' '.concat(piwikData)}<%--
--%>><%----%>
<m:nl/>

<div id="template-grid-info"></div><%----%>

</div><%----%>
<m:nl/>

<div id="topcontrol" tabindex="0"></div>

