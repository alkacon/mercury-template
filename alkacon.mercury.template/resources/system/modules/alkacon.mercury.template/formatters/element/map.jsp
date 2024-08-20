<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<m:init-messages reload="true">

<cms:formatter var="content" val="value">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:setting-defaults>

<c:set var="provider"               value="${setting.mapProvider.validate(['osm','google'],'google').toString}" />
<c:set var="pieceLayout"            value="${10}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="showDescription"        value="${setting.showDescription.toBoolean}" />
<c:set var="showLink"               value="${setting.showLink.toBoolean}" />
<c:set var="showFacilities"         value="${setting.showFacilities.toBoolean}" />
<c:set var="showGroupButtons"       value="${setting.showGroupButtons.toBoolean}" />
<c:set var="showRoute"              value="${setting.showMapRoute.toBoolean}" />
<c:set var="mapType"                value="${setting.mapType.toString}" />
<c:set var="mapMarkerCluster"       value="${setting.mapMarkerCluster.toBoolean}" />

<c:set var="ade"                    value="${cms.isEditMode}" />

<%-- Check API key --%>
<c:set var="apiKey" value="${cms.vfs.readPropertiesSearch[cms.requestContext.uri][provider.concat('.apikey')]}" />
<c:choose>
    <c:when test="${(provider eq 'google') and (apiKey eq 'osm')}">
        <c:set var="provider"   value="osm" />
        <c:set var="jsMapObj"   value="OsmMap" />
    </c:when>
    <c:when test="${(provider eq 'osm') and (apiKey eq 'google')}">
        <c:set var="provider"   value="google" />
        <c:set var="jsMapObj"   value="GoogleMap" />
    </c:when>
    <c:when test="${(provider eq 'osm')}">
        <c:set var="jsMapObj"   value="OsmMap" />
    </c:when>
    <c:otherwise>
        <%-- provider must be "google" --%>
        <c:set var="jsMapObj"   value="GoogleMap" />
    </c:otherwise>
</c:choose>

<m:section-piece
    cssWrapper="element type-map map-${provider}${setCssWrapperAll}"
    cssVisual="map-visual"
    pieceLayout="${pieceLayout}"
    heading="${value.Title}"
    hsize="${hsize}"
    text="${showDescription ? value.Description : null}"
    ade="${ade}">

    <jsp:attribute name="markupVisual">

        <c:set var="id"><m:idgen prefix='map' uuid='${cms.element.instanceId}' /></c:set>

        <%-- Collects all map marker groups found, this is a Map since we can not add elements to lists in EL --%>
        <jsp:useBean id="markerGroups"  class="java.util.LinkedHashMap" />
        <jsp:useBean id="markerList"    class="java.util.ArrayList" />
        <jsp:useBean id="coordBean"     class="org.opencms.widgets.CmsLocationPickerWidgetValue" />

        <c:forEach var="poi" items="${content.valueList.MapPoi}" varStatus="status">
            <m:map-marker-vars content="${cms.vfs.readXml[poi.value.PoiLink]}" showLink="${showLink}" showFacilities="${showFacilities}" showRoute="${showRoute}">
                <c:if test="${not empty markerData}">
                    <c:set var="markerGroup" value="${poi.value.MarkerGroup.isEmptyOrWhitespaceOnly ? 'default' : fn:trim(poi.value.MarkerGroup)}" />
                    <c:set target="${markerGroups}" property="${markerGroup}" value="used"/>

                    <c:set target="${markerData}" property="group" value="${markerGroup}" />
                    <c:set var="ignore" value="${markerList.add(markerData)}" />
                </c:if>
            </m:map-marker-vars>
        </c:forEach>

        <c:forEach var="marker" items="${content.valueList.MapCoord}" varStatus="status">

            <m:map-marker-vars marker="${marker}" showLink="${showLink}" showFacilities="${showFacilities}" showRoute="${showRoute}">
                <c:if test="${not empty markerData}">
                    <c:set var="markerGroup" value="${marker.value.MarkerGroup.isEmptyOrWhitespaceOnly ? 'default' : fn:trim(marker.value.MarkerGroup)}" />
                    <c:set target="${markerGroups}" property="${markerGroup}" value="used"/>

                    <c:set target="${markerData}" property="group" value="${markerGroup}" />
                    <c:set var="ignore" value="${markerList.add(markerData)}" />
                </c:if>
            </m:map-marker-vars>
        </c:forEach>

        <m:map
             provider="${provider}"
             id="${id}"
             ratio="${cms.element.setting.mapRatio}"
             zoom="${cms.element.setting.mapZoom}"
             markers="${markerList}"
             type="${mapType}"
             showLink="${showLink}"
             showFacilities="${showFacilities}"
             showRoute="${showRoute}"
             markerCluster="${mapMarkerCluster}"
        />

        <c:if test="${showGroupButtons and (fn:length(markerGroups) > 1)}">
            <div class="mapbuttons"><%----%>
                <button class="btn btn-sm" onclick="${jsMapObj}.showMarkers('${id}','showall');"><%----%>
                    <fmt:message key="msg.page.map.button.showmarkers" />
                </button><%----%>
                <m:nl />
                <c:forEach var="markerGroup" items="${markerGroups}">
                    <button class="btn btn-sm blur-focus" onclick="${jsMapObj}.showMarkers('${id}', '${cms:encode(markerGroup.key)}');"><%----%>
                        <fmt:message key="msg.page.map.button.show">
                            <fmt:param><c:out value="${markerGroup.key}" /></fmt:param>
                        </fmt:message>
                    </button><%----%>
                    <m:nl />
                </c:forEach>
            </div><%----%>
        </c:if>

    </jsp:attribute>

</m:section-piece>

</m:setting-defaults>

</cms:bundle>
</cms:formatter>

</m:init-messages>