<%@ tag
    pageEncoding="UTF-8"
    display-name="map"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays an map, selecting from OSM or Google." %>

<%@ attribute name="provider" type="java.lang.String" required="false"
    description="Can be either 'osm' or 'google'.
    If not set or 'auto', the map provider is guessed by reading the available API keys properties.
    If both OSM and Google API keys are found, OSM is used." %>

<%@ attribute name="id" type="java.lang.String" required="true"
    description="The id the map should use." %>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="The display ratio of the map, e.g. '1-1' or '16-9'" %>

<%@ attribute name="zoom" type="java.lang.String" required="false"
    description="The initial map zoom factor. If not set, will use '14' as default." %>

<%@ attribute name="markers" type="java.util.ArrayList" required="true"
    description="A list of map marker points from the Location picker widget." %>

<%@ attribute name="showRoute" type="java.lang.Boolean" required="false"
    description="If true, show route option for each marker in info window." %>

<%@ attribute name="type" type="java.lang.String" required="false"
    description="Only for Google maps. The map display type. If not set, will use 'ROADMAP' as default." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:if test="${(empty provider) or (provider eq 'auto')}">
    <mercury:content-properties>
        <%-- Google Maps API key --%>
        <c:set var="googleApiKey" value="${contentPropertiesSearch['google.apikey']}" />
        <%-- OSM API key --%>
        <c:set var="osmApiKey" value="${contentPropertiesSearch['osm.apikey']}" />
        <c:choose>
            <c:when test="${(not empty osmApiKey) and (osmApiKey ne 'none')}">
            </c:when>
            <c:when test="${(not empty googleApiKey) and (googleApiKey ne 'none')}">
                <c:set var="provider" value="google" />
            </c:when>
            <c:otherwise>
                <%-- If no API key is available OSM will display a placeholder --%>
                <c:set var="provider" value="osm" />
            </c:otherwise>
        </c:choose>
    </mercury:content-properties>
</c:if>

<c:choose>
    <c:when test="${provider eq 'google'}">
        <mercury:nl />
        <div class="subelement type-map map-google"><mercury:nl />
            <mercury:map-google
                 id="${id}"
                 ratio="${ratio}"
                 zoom="${zoom}"
                 type="${type}"
                 showRoute="${showRoute}"
                 markers="${markers}"
            />
        </div><mercury:nl />
    </c:when>
    <c:otherwise>
        <mercury:nl />
        <div class="subelement type-map map-osm"><mercury:nl />
            <mercury:map-osm
                 id="${id}"
                 ratio="${ratio}"
                 zoom="${zoom}"
                 markers="${markers}"
            />
        </div><mercury:nl />
    </c:otherwise>
</c:choose>

