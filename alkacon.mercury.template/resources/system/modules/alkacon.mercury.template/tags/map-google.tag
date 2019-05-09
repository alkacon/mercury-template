<%@ tag
    pageEncoding="UTF-8"
    display-name="map"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays a Google map." %>


<%@ attribute name="id" type="java.lang.String" required="true"
    description="The id the map should use." %>

<%@ attribute name="markers" type="java.util.ArrayList" required="true"
    description="A list of map marker points from the Location picker widget." %>

<%@ attribute name="showRoute" type="java.lang.Boolean" required="false"
    description="If true, show route option for each marker in info window." %>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="The display ratio of the map, e.g. '1-1' or '16-9'" %>

<%@ attribute name="zoom" type="java.lang.String" required="false"
    description="The initial map zoom factor. If not set, will use '14' as default." %>

<%@ attribute name="type" type="java.lang.String" required="false"
    description="The map type. If not set, will use 'ROADMAP' as default." %>

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


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="property" value="${cms.vfs.readPropertiesSearch[cms.requestContext.uri]}" />

<%-- Google Maps API key --%>
<c:set var="googleApiKey" value="${property['google.apikey']}" />
<c:set var="noApiKey" value="${empty googleApiKey or (googleApiKey eq 'none')}" />

<c:set var="ratio" value="${empty ratio ? '16-9' : ratio}" />

<%-- We need the newline in an EL variable later --%>
<c:set var="nl"><mercury:nl/></c:set>

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
        <c:when test="${empty zoom}">
            <c:set var="zoom" value="14" />
        </c:when>
        <c:when test="${(zoom eq 'firstMarker') and (fn:length(markers) > 0)}">
            <c:set var="zoom" value="${markers[0].zoom}" />
        </c:when>
        <c:otherwise>
            <c:set var="zoom" value="${cms:mathRound(cms:toNumber(zoom, 14))}" />
        </c:otherwise>
    </c:choose>

    <c:if test="${empty type}">
        <c:set var="type" value="ROADMAP" />
    </c:if>

    <c:forEach var="marker" items="${markers}" varStatus="status">

        <c:if test="${showRoute}">
            <c:set target="${marker}" property="routeMarkup"><%--
            --%><div class="markroute"><%--
                --%><div class="head"><fmt:message key="msg.page.map.route" /></div><%--
                --%><div class="message"><fmt:message key="msg.page.map.start" /></div><%--
                --%><form action="https://maps.google.com/maps" method="get" target="_blank" rel="noopener"><%--
                    --%><input type="text" class="form-control" size="15" maxlength="60" name="saddr" value="" /><%--
                    --%><input value="<fmt:message key="msg.page.map.route.button" />" type="submit" class="btn btn-xs"><%--
                    --%><input type="hidden" name="daddr" value="${marker.lat},${marker.lng}"/><%--
                --%></form><%--
            --%></div><%--
        --%></c:set>
        </c:if>

        <c:set target="${marker}" property="infoMarkup"><%--
            --%><div class="map-marker"><%--
            --%><c:if test="${not empty marker.name}"><div class="markhead">${marker.name}</div></c:if><%--
            --%><c:if test="${not empty marker.addressMarkup}"><div class="marktxt">${marker.addressMarkup}</div></c:if><%--
            --%><c:if test="${not empty marker.routeMarkup}">${marker.routeMarkup}</c:if><%--
            --%></div><%--
        --%></c:set>

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
            --%>"type":"${type}", <%--
            --%>"ratio":"${ratio}", <%--
            --%>"geocoding":"true", <%--
            --%>"centerLat":"${centerLat}", <%--
            --%>"centerLng":"${centerLng}"<%--
            --%><c:if test="${not empty markerJson}">, <%--
            --%>  "markers":[${nl}${markerJson}]<%--
            --%></c:if><%--
        --%> }'<%--
    --%><c:if test="${not noApiKey}"><%--
    --%></c:if><%--
    --%><c:if test="${cms.isEditMode}">
            <fmt:setLocale value="${cms.workplaceLocale}" />
            <cms:bundle basename="alkacon.mercury.template.messages">
                <c:choose>
                    <c:when test="${noApiKey}">
                        data-hidemessage='<fmt:message key="msg.page.map.google.nokey" />' <%----%>
                    </c:when>
                    <c:otherwise>
                        data-hidemessage='<fmt:message key="msg.page.map.google.hide" />' <%----%>
                    </c:otherwise>
                </c:choose>
            </cms:bundle>
        </c:if>
    ${'></div>'}
    <mercury:nl />

</mercury:padding-box>

</cms:bundle>
