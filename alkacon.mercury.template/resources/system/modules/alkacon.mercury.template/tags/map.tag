<%@ tag pageEncoding="UTF-8"
    display-name="map"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates the markup for OSM or Google maps." %>


<%@ attribute name="provider" type="java.lang.String" required="true"
    description="Can be either 'osm' or 'google' or 'auto'.
    If set to 'auto', the map provider is guessed by reading the available API keys properties.
    If both OSM and Google API keys are found, OSM is used." %>

<%@ attribute name="id" type="java.lang.String" required="true"
    description="The id the map should use." %>

<%@ attribute name="markers" type="java.util.ArrayList" required="true"
    description="A list of map marker points from the Location picker widget." %>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="The display ratio of the map, e.g. '1-1' or '16-9'" %>

<%@ attribute name="ratioLg" type="java.lang.String" required="false"
    description="Map ratio for large screens." %>

<%@ attribute name="zoom" type="java.lang.String" required="false"
    description="The initial map zoom factor. If not set, will use '13' for OSM and '14' for Google as default.
    If set to 'firstMarker' the zoom level of the first marker will be used." %>

<%@ attribute name="showFacilities" type="java.lang.Boolean" required="false"
    description="If true, show the facility information of a marker in the info window." %>

<%@ attribute name="showLink" type="java.lang.Boolean" required="false"
    description="If true, show the link of a marker in the info window." %>

<%@ attribute name="showRoute" type="java.lang.Boolean" required="false"
    description="If true, show route option for each marker in the info window.
    Currently only supported for Google maps, not OSM." %>

<%@ attribute name="type" type="java.lang.String" required="false"
    description="The map type. If not set, will use 'ROADMAP' as default.
    Currently only supported for Google maps, not OSM." %>

<%@ attribute name="subelementWrapper" type="java.lang.String" required="false"
    description="If set, the map is generated as sub element of another element, e.g. from a POI.
    In this case the a surrounding div is added required for JS map initialization." %>

<%@ attribute name="disableEditModePlaceholder" type="java.lang.Boolean" required="false"
    description="If set, disables the map placeholder in edit mode." %>

<%@ attribute name="cssPath" type="java.lang.String" required="false"
    description="Path the map CSS file that must be loaded by JavaScript.
    This is required in case the map is displayed in a list." %>

<%@ attribute name="markerCluster" type="java.lang.Boolean" required="false"
    description="Whether to cluster nearby markers." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">
<m:content-properties>

<%-- OSM API key --%>
<c:set var="osmApiKey" value="${contentPropertiesSearch['osm.apikey']}" />
<%-- Google Maps API key --%>
<c:set var="googleApiKey" value="${contentPropertiesSearch['google.apikey']}" />

<c:if test="${provider eq 'auto'}">
    <c:choose>
        <c:when test="${(not empty osmApiKey) and (osmApiKey ne 'none') and (osmApiKey ne 'google')}">
            <c:set var="provider" value="osm" />
        </c:when>
        <c:when test="${(not empty googleApiKey) and (googleApiKey ne 'none') and (googleApiKey ne 'osm')}">
            <c:set var="provider" value="google" />
        </c:when>
        <c:otherwise>
            <%-- If no API key is available OSM will display a placeholder --%>
            <c:set var="provider" value="osm" />
        </c:otherwise>
    </c:choose>
</c:if>

<c:set var="isOsm"          value="${not (provider eq 'google')}" />
<c:set var="type"           value="${isOsm ? null : type}" />
<c:set var="apiKey"         value="${isOsm ? osmApiKey : googleApiKey}" />
<c:set var="noApiKey"       value="${empty apiKey or (apiKey eq 'none')}" />
<c:set var="ratio"          value="${empty ratio ? '16-9' : ratio}" />
<c:set var="ratioLg"        value="${(empty ratioLg) or ('desk' eq ratioLg) ? ratio : ratioLg}" />
<c:set var="showRoute"      value="${showRoute and not isOsm}" />
<c:set var="disableEditModePlaceholder" value="${disableEditModePlaceholder eq true}" />

<%-- Set zoom level --%>
<c:choose>
    <c:when test="${empty zoom}">
        <c:set var="zoom" value="${14}" />
    </c:when>
    <c:when test="${(zoom eq 'firstMarker') and (fn:length(markers) > 0)}">
        <c:set var="zoom" value="${cms:mathRound(cms:toNumber(markers[0].zoom, 14))}" />
    </c:when>
    <c:otherwise>
        <c:set var="zoom" value="${cms:mathRound(cms:toNumber(zoom, 14))}" />
    </c:otherwise>
</c:choose>
<%-- Note: Zoom levels for OSM must be reduced by 1 to show the same area as Google --%>
<c:set var="zoom" value="${isOsm ? zoom - 1 : zoom}" />

<%-- Set map center, default location is the center of Germany --%>
<c:set var="centerLat" value="${empty markers ? '51.163409' : markers[0].lat}" />
<c:set var="centerLng" value="${empty markers ? '10.447721' : markers[0].lng}" />


<%-- Do costly generation of JSON only if the map can be displayed --%>
<c:if test="${not noApiKey}">
    <fmt:message var="linkDefaultText" key="msg.page.map.link.default.text" />

    <%-- Generate marker list --%>
    <cms:jsonarray var="markerList" mode="object">
        <c:forEach var="marker" items="${markers}" varStatus="status">

            <%-- Generate the actual JSON --%>
            <cms:jsonobject>
                <cms:jsonvalue key="lat" value="${marker.lat}" />
                <cms:jsonvalue key="lng" value="${marker.lng}" />
                <cms:jsonvalue key="geocode" value="${marker.geocode}" />
                <cms:jsonvalue key="group" value="${empty marker.group ? 'default' : marker.group}" />
                <cms:jsonvalue key="info" value="${marker.infoMarkup}" />
            </cms:jsonobject>

        </c:forEach>
    </cms:jsonarray>

</c:if>

<%-- Generate map data JSON --%>
<cms:jsonobject var="mapData">
    <cms:jsonvalue key="zoom" value="${zoom}" />
    <cms:jsonvalue key="ratio" value="${ratio}" />
    <cms:jsonvalue key="ratioLg" value="${ratioLg}" />
    <cms:jsonvalue key="geocoding" value="true" />
    <cms:jsonvalue key="centerLat" value="${centerLat}" />
    <cms:jsonvalue key="centerLng" value="${centerLng}" />
    <c:if test="${not empty type}">
        <cms:jsonvalue key="type" value="${type}" />
    </c:if>
    <c:if test="${not empty markerList}">
        <cms:jsonvalue key="markers" value="${markerList}" />
    </c:if>
    <c:if test="${isOsm}">
        <c:set var="cssPath"><m:link-resource resource="/system/modules/alkacon.mercury.template/osmviewer/map.css" /></c:set>
        <cms:jsonvalue key="css" value="${cssPath}" />
    </c:if>
    <cms:jsonvalue key="markerCluster" value="${empty markerCluster ? false : markerCluster}" />
    <cms:jsonvalue key="markerTitle"><fmt:message key="msg.page.map.marker.title" /></cms:jsonvalue>
</cms:jsonobject>

<fmt:message var="cookieMessage" key="msg.page.privacypolicy.message.map-${provider}" />

<c:if test="${not empty subelementWrapper}">
${'<'}div class="${subelementWrapper} type-map map-${provider}"${'>'}
<m:nl />
</c:if>

<m:padding-box ratio="${ratio}" ratioLg="${ratioLg}" test="${ratio ne 'no-ratio'}">

    ${'<'}div id="${id}" class="mapwindow placeholder${noApiKey ? ' error' : ''}" <%--
    --%>data-map='${mapData.compact}'<%--
    --%><m:data-external-cookies message="${cookieMessage}" test="${not noApiKey}" /><%--
    --%><c:if test="${cms.isEditMode and not disableEditModePlaceholder}">
            <fmt:setLocale value="${cms.workplaceLocale}" />
            <cms:bundle basename="alkacon.mercury.template.messages">
                <c:choose>
                    <c:when test="${noApiKey}"><%--
                    --%> data-placeholder='<fmt:message key="msg.page.map.${provider}.nokey" />' <%--
                --%></c:when>
                    <c:otherwise><%--
                    --%> data-placeholder='<fmt:message key="msg.page.placeholder.map.${provider}" />' <%--
                --%></c:otherwise>
                </c:choose>
            </cms:bundle>
        </c:if>
    ${'>'}
    <m:alert-online showJsWarning="${true}" addNoscriptTags="${true}" />
    ${'</div>'}

</m:padding-box>

<c:if test="${not empty subelementWrapper}">
${'</div>'}
</c:if>

</m:content-properties>
</cms:bundle>
