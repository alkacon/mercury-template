<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

   <cms:secureparams />
<mercury:init-messages reload="true">

<cms:formatter var="content" val="value">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper.toString}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="showDescription"        value="${setting.showDescription.toBoolean}" />
<c:set var="showGroupButtons"       value="${setting.showGroupButtons.toBoolean}" />

<c:set var="ade"                    value="${true}" />

<%-- get width and height of map from content --%>
<c:set var="mapsize">${content.value.MapSize}</c:set>
<c:set var="sizesep">${fn:indexOf(mapsize, "x")}</c:set>
<c:if test="${sizesep != -1}">
    <c:set var="mapw">${fn:trim(fn:substringBefore(mapsize, "x"))}</c:set>
    <c:set var="maph">${fn:trim(fn:substringAfter(mapsize, "x"))}</c:set>
</c:if>
<c:if test="${not fn:contains(mapw, '%')}">
    <c:set var="mapw">${mapw}px</c:set>
</c:if>
<c:if test="${not fn:contains(maph, '%')}">
    <c:set var="maph">${maph}px</c:set>
</c:if>

<mercury:nl />
<div class="element type-map map-osm ${cssWrapper}">
<%----%>

    <mercury:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading" />

    <c:if test="${showDescription and value.Description.isSet}">
        <div ${ade ? value.Description.rdfaAttr : ''}>${value.Description}</div>
    </c:if>

    <c:set var="id"><mercury:idgen prefix='map' uuid='${cms.element.instanceId}' /></c:set>

    <%-- Collects all map marker groups found, this is a Map since we can not add elements to lists in EL --%>
    <jsp:useBean id="markerGroups" class="java.util.LinkedHashMap" />

    <c:set var="markerList" value="${cms:createList()}" />
    <jsp:useBean id="coordBean" class="org.opencms.widgets.CmsLocationPickerWidgetValue" />

    <c:forEach var="poi" items="${content.valueList.MapPoi}" varStatus="status">
        <mercury:location-data data="${poi.value.PoiLink}" addMapInfo="true" >

            <c:set var="markerGroup" value="${poi.value.MarkerGroup.isEmptyOrWhitespaceOnly ? 'default' : fn:trim(poi.value.MarkerGroup)}" />
            <c:set target="${markerGroups}" property="${markerGroup}" value="used"/>

            <c:set target="${locData}" property="group" value="${markerGroup}" />
            ${cms:addToList(markerList, locData)}

        </mercury:location-data>
    </c:forEach>

    <c:forEach var="marker" items="${content.valueList.MapCoord}" varStatus="status">
        <jsp:setProperty name="coordBean" property="wrappedValue" value="${marker.value.Coord.stringValue}" />

        <c:set var="markerGroup" value="${marker.value.MarkerGroup.isEmptyOrWhitespaceOnly ? 'default' : fn:trim(marker.value.MarkerGroup)}" />
        <c:set target="${markerGroups}" property="${markerGroup}" value="used"/>

        <c:choose>
            <c:when test="${not marker.value.Address.isEmptyOrWhitespaceOnly}">
                 <c:set var="markerAddress" value="${cms:escapeHtml(fn:trim(marker.value.Address))}" />
                 <c:set var="markerNeedsGeoCode" value="false" />
            </c:when>
            <c:otherwise>
                 <%-- This will be replaced by Google GeoCoder in JavaScript --%>
                 <c:set var="markerAddress" value="<div class='geoAdr'></div>" />
                 <c:set var="markerNeedsGeoCode" value="true" />
            </c:otherwise>
        </c:choose>

        <c:set var="locData" value="${cms:jsonToMap(leer)}" />
        <c:set target="${locData}" property="name" value="${marker.value.Caption.isEmptyOrWhitespaceOnly ? '' : fn:trim(marker.value.Caption)}" />
        <c:set target="${locData}" property="lat" value="${coordBean.lat}" />
        <c:set target="${locData}" property="lng" value="${coordBean.lng}" />
        <c:set target="${locData}" property="addressMarkup" value="${markerAddress}" />
        <c:set target="${locData}" property="geocode" value="${markerNeedsGeoCode}" />
        <c:set target="${locData}" property="group" value="${markerGroup}" />
        <c:set target="${locData}" property="info" value="${markerInfo}" />
        ${cms:addToList(markerList, locData)}

    </c:forEach>

    <mercury:map-osm
         id="${id}"
         ratio="${cms.element.setting.mapRatio}"
         zoom="${cms.element.setting.mapZoom}"
         markers="${markerList}"
    />

    <c:if test="${showGroupButtons and (fn:length(markerGroups) > 1)}">
        <div class="mapbuttons"><%----%>
            <button class="btn btn-sm" onclick="OsmMap.showMarkers('${id}','showall');"><%----%>
                <fmt:message key="msg.page.map.button.showmarkers" />
            </button><%----%>
            <mercury:nl />
            <c:forEach var="markerGroup" items="${markerGroups}">
                <button class="btn btn-sm blur-focus" onclick="OsmMap.showMarkers('${id}', '${cms:encode(markerGroup.key)}');"><%----%>
                    <fmt:message key="msg.page.map.button.show">
                        <fmt:param><c:out value="${markerGroup.key}" /></fmt:param>
                    </fmt:message>
                </button><%----%>
                <mercury:nl />
            </c:forEach>
        </div><%----%>
    </c:if>
</div>
<%----%>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
