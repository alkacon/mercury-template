<%@ tag
    pageEncoding="UTF-8"
    display-name="map"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays an OpenStreetMap." %>


<%@ attribute name="id" type="java.lang.String" required="true"
    description="The id the map should use." %>

<%@ attribute name="markers" type="java.util.ArrayList" required="true"
    description="A list of map marker points from the Location picker widget." %>

<%@ attribute name="ratio" type="java.lang.String" required="true"
    description="The display ratio of the map, e.g. '1-1' or '16-9'. Default is '16-9'." %>

<%@ attribute name="zoom" type="java.lang.String" required="false"
    description="The initial map zoom factor. If not set, will use '14' as default." %>

<%@ attribute name="centerLat" type="java.lang.String" required="false"
    description="The center latitude of the map.
    Will use the first marker point latitude if not specified." %>

<%@ attribute name="centerLng" type="java.lang.String" required="false"
    description="The center longitude of the map
    Will use the first marker point longitude if not specified." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:content-properties>

<%-- OSM Maps API key --%>
<c:set var="osmApiKey" value="${contentPropertiesSearch['osm.apikey']}" />
<c:set var="noApiKey" value="${empty osmApiKey or (osmApiKey eq 'none')}" />

<c:set var="ratio" value="${empty ratio ? '16-9' : ratio}" />

<c:if test="${not noApiKey}">
    <%-- Default location is the center of Germany --%>
    <c:if test="${empty centerLat}">
        <c:set var="centerLat" value="${empty markers ? '51.163409' : markers[0].lat}" />
    </c:if>
    <c:if test="${empty centerLng}">
        <c:set var="centerLng" value="${empty markers ? '10.447721' : markers[0].lng}" />
    </c:if>

    <%-- Set other variable defaults --%>
    <c:choose>
        <%-- Note: Zoom levels set with Google must be reduced by 1 to show the same area --%>
        <c:when test="${empty zoom}">
            <c:set var="zoom" value="${13}" />
        </c:when>
        <c:when test="${(zoom eq 'firstMarker') and (fn:length(markers) > 0)}">
            <c:set var="zoom" value="${cms:mathRound(cms:toNumber(markers[0].zoom, 14)) - 1}" />
        </c:when>
        <c:otherwise>
            <c:set var="zoom" value="${cms:mathRound(cms:toNumber(zoom, 14)) - 1}" />
        </c:otherwise>
    </c:choose>

    <c:set var="nl" value="
    " />

    <c:forEach var="marker" items="${markers}" varStatus="status">
        <c:choose>
         <c:when test="${cms:isEmptyOrWhitespaceOnly(marker.name)}">
             <c:set target="${marker}" property="infoMarkup" value=""/>
         </c:when>
         <c:otherwise>
             <c:set target="${marker}" property="infoMarkup"><%--
            --%><div class="map-marker"><%--
            --%><c:if test="${not empty marker.name}"><div class="markhead">${marker.name}</div></c:if><%--
            --%><c:if test="${not empty marker.addressMarkup}"><div class="marktxt">${marker.addressMarkup}</div></c:if><%--
            --%><c:if test="${not empty marker.routeMarkup}">${marker.routeMarkup}</c:if><%--
            --%></div><%--
        --%></c:set>
         </c:otherwise>
        </c:choose>

        <c:set var="markerJson">${markerJson}<%--
        --%>${nl}{<%--
            --%>"lat":"${marker.lat}", <%--
            --%>"lng":"${marker.lng}", <%--
            --%>"geocode":"${marker.geocode}", <%--
            --%>"title":"${cms:encode(marker.name)}", <%--
            --%>"group":"${empty marker.group ? 'default' : cms:encode(marker.group)}", <%--
            --%>"info":"${cms:encode(marker.infoMarkup)}"<%--
        --%>}<%--
        --%><c:if test="${not status.last}">, </c:if>
        </c:set>

    </c:forEach>
</c:if>

<mercury:padding-box ratio="${ratio}">

    ${'<'}div id="${id}" class="mapwindow placeholder${noApiKey ? ' error' : ''}" <%--
   --%> data-map='{<%--
        --%>"zoom":"${zoom}", <%--
        --%>"ratio":"${ratio}", <%--
        --%>"geocoding":"true", <%--
        --%>"centerLat":"${centerLat}", <%--
        --%>"centerLng":"${centerLng}"<%--
        --%><c:if test="${not empty markerJson}">, <%--
        --%>  "markers":[${nl}${markerJson}]<%--
        --%></c:if><%--
    --%> }'<%--
    --%><c:if test="${cms.isEditMode}">
            <fmt:setLocale value="${cms.workplaceLocale}" />
            <cms:bundle basename="alkacon.mercury.template.messages">
                <c:choose>
                    <c:when test="${noApiKey}">
                        data-hidemessage='<fmt:message key="msg.page.map.osm.nokey" />' <%----%>
                    </c:when>
                    <c:otherwise>
                        data-hidemessage='<fmt:message key="msg.page.map.osm.hide" />' <%----%>
                    </c:otherwise>
                </c:choose>
            </cms:bundle>
        </c:if>
    ${'></div>'}
    <mercury:nl />

</mercury:padding-box>

</mercury:content-properties>