<%@ tag
    pageEncoding="UTF-8"
    display-name="pageinfo"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    import ="org.opencms.workplace.CmsWorkplace"
    description="Generates a DIV with runtime information that can be used from JavaScipt." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="property" value="${cms.vfs.readPropertiesSearch[cms.requestContext.uri]}" />

<%-- Google Maps API key --%>
<c:set var="googleApiKey" value="${property['google.apikey']}" />

<%-- Google Maps API key for the workplace--%>
<c:set var="googleApiKeyWorkplace" value="${property['google.apikey.workplace']}" />

<%-- Google Analytics ID --%>
<c:set var="googleAnalyticsId" value="${property['google.analytics']}" />

<%-- OSM API key --%>
<c:set var="osmApiKey" value="${property['osm.apikey']}" />

<%-- OSM style URL --%>
<c:set var="osmStyleUrl" value="${property['osm.styleurl']}" />

<%-- Piwik URL --%>
<c:set var="piwikUrl" value="${property['piwik.url']}" />

<c:if test="${not empty piwikUrl}">
    <c:set var="piwikId" value="${property['piwik.id']}" />
    <c:set var="piwikAddData" value="${property['piwik.data']}" />
    <c:set var="piwikData"> data-piwik='{<%--
        --%><c:if test="${not empty piwikId}">"id":"${piwikId}",</c:if><%--
        --%><c:if test="${not empty piwikAddData}">${piwikAddData},</c:if><%--
        --%>"url":"${piwikUrl}"}' <%--
--%></c:set>
</c:if>

<%-- OpenCms project --%>
<c:set var ="project" value="${cms.isOnlineProject ? 'online' : 'offline'}" />

<mercury:nl/>
<div id="template-info" data-info='{<%--
    --%><c:if test="${not empty googleApiKey}">"googleApiKey":"${googleApiKey}",</c:if><%--
    --%><c:if test="${not empty googleAnalyticsId}">"googleAnalyticsId":"${googleAnalyticsId}",</c:if><%--
    --%><c:if test="${not empty osmApiKey}">"osmApiKey":"${osmApiKey}",</c:if><%--
    --%><c:if test="${not empty osmApiKey}">"osmSpriteUrl":"<%= CmsWorkplace.getStaticResourceUri("/osm/sprite") %>",</c:if><%--
    --%><c:if test="${not empty osmApiKey and not empty osmStyleUrl}">"osmStyleUrl":"${osmStyleUrl}",</c:if><%--
    --%><c:if test="${not empty googleApiKeyWorkplace}">"googleApiKeyWorkplace":"${googleApiKeyWorkplace}",</c:if><%--
    --%>"editMode":"${cms.isEditMode}",<%--
    --%>"project":"${project}",<%--
    --%>"locale":"${cms.locale}"<%--
--%>}'${' '}${piwikData}><%----%>
<mercury:nl/>

<div id="template-grid-info" class="template-grid-info"></div>
<div id="template-sass-version"></div>
<div id="template-plugins-version"></div><%----%>

</div>
<mercury:nl/>

<div id="topcontrol"></div>

