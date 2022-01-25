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
<c:set var="showMapRoute"       	value="${setting.showMapRoute.toBoolean}" />
<c:set var="mapType"       			value="${setting.mapType.toString}" />

<c:set var="ade"                    value="${cms.isEditMode}" />

<%-- Check API key --%>
<c:set var="apiKey" value="${cms.vfs.readPropertiesSearch[cms.requestContext.uri]['google.apikey']}" />
<c:choose>
    <c:when test="${apiKey eq 'osm'}">
        <c:set var="provider" 	value="osm" />
        <c:set var="jsMapObj"   value="OsmMap" />
    </c:when>
    <c:otherwise>
        <c:set var="provider" 	value="google" />
        <c:set var="jsMapObj"   value="GoogleMap" />
    </c:otherwise>
</c:choose>

<mercury:nl />
<div class="element type-map pivot map-${provider}${' '}${cssWrapper}">
<%----%>

    <mercury:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading" />

    <c:if test="${showDescription and value.Description.isSet}">
        <div ${ade ? value.Description.rdfaAttr : ''}>${value.Description}</div>
    </c:if>

    <c:set var="id"><mercury:idgen prefix='map' uuid='${cms.element.instanceId}' /></c:set>

    <%-- Collects all map marker groups found, this is a Map since we can not add elements to lists in EL --%>
    <jsp:useBean id="markerGroups"  class="java.util.LinkedHashMap" />
    <jsp:useBean id="markerList"    class="java.util.ArrayList" />
    <jsp:useBean id="coordBean"     class="org.opencms.widgets.CmsLocationPickerWidgetValue" />

    <c:forEach var="poi" items="${content.valueList.MapPoi}" varStatus="status">
        <mercury:location-vars data="${poi.value.PoiLink}" addMapInfo="true" >

            <c:if test="${not empty locData}">
                <c:set var="markerGroup" value="${poi.value.MarkerGroup.isEmptyOrWhitespaceOnly ? 'default' : fn:trim(poi.value.MarkerGroup)}" />
                <c:set target="${markerGroups}" property="${markerGroup}" value="used"/>

                <c:set target="${locData}" property="group" value="${markerGroup}" />
                <c:set var="ignore" value="${markerList.add(locData)}" />
            </c:if>

        </mercury:location-vars>
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
                 <c:set var="markerAddress"><div class="geoAdr"></div></c:set>
                 <c:set var="markerNeedsGeoCode" value="true" />
            </c:otherwise>
        </c:choose>

        <c:set var="locData" value="${{
            'name': marker.value.Caption.isEmptyOrWhitespaceOnly ? '' : fn:trim(marker.value.Caption),
            'lat': coordBean.lat,
            'lng': coordBean.lng,
            'addressMarkup': markerAddress,
            'geocode': markerNeedsGeoCode,
            'group': markerGroup,
            'info': markerInfo
        }}" />
        <c:set var="ignore" value="${markerList.add(locData)}" />

    </c:forEach>

    <mercury:map
         provider="${provider}"
         id="${id}"
         ratio="${cms.element.setting.mapRatio}"
         zoom="${cms.element.setting.mapZoom}"
         markers="${markerList}"
         type="${mapType}"
         showRoute="${showMapRoute}"
    />

    <c:if test="${showGroupButtons and (fn:length(markerGroups) > 1)}">
        <div class="mapbuttons"><%----%>
            <button class="btn btn-sm" onclick="${jsMapObj}.showMarkers('${id}','showall');"><%----%>
                <fmt:message key="msg.page.map.button.showmarkers" />
            </button><%----%>
            <mercury:nl />
            <c:forEach var="markerGroup" items="${markerGroups}">
                <button class="btn btn-sm blur-focus" onclick="${jsMapObj}.showMarkers('${id}', '${cms:encode(markerGroup.key)}');"><%----%>
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