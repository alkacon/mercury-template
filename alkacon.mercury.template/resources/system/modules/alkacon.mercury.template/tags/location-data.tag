<%@ tag pageEncoding="UTF-8"
    display-name="location-data"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Collects location data from a POI file or inline fields." %>


<%@ attribute name="data" type="java.lang.Object" required="true"
    description="The location to read. Can be a either a POI content access wrapper,
    a VFS path to a POI that should be read OR
    a manual nested content formation wrapper." %>

<%@ attribute name="addMapInfo" type="java.lang.Boolean" required="false"
    description="If true, data for a location map is generated as well." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="If provided and false, the location data is not collected." %>


<%@ variable name-given="locData" declare="true"
    description="A map that contains the data read for the location as properties." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>

<jsp:useBean id="locData" class="java.util.HashMap" />

<c:if test="${empty test or test}">
    <c:choose>
        <c:when test="${data.getClass().simpleName eq 'CmsJspContentAccessBean'}">
            <%-- POI content has been passed --%>
            <c:set var="poi" value="${data}" />
        </c:when>
        <c:when test="${cms:isWrapper(data)}">
            <c:choose>
                <c:when test="${data.isSet and (data.typeName == 'OpenCmsVfsFile')}">
                    <%-- VFS file link to POI content has been passed --%>
                    <c:set var="poi" value="${cms.vfs.readXml[data]}" />
                </c:when>
                <c:when test="${data.value.PoiLink.isSet}">
                    <%-- Choice element with file link to POI content has been passed --%>
                    <c:set var="poi" value="${cms.vfs.readXml[data.value.PoiLink]}" />
                </c:when>
                <c:when test="${data.value.Address.isSet}">
                    <%-- Choice element with manual entered address has been passed --%>
                    <c:set var="adr" value="${data.value.Address}" />
                    <c:set target="${locData}" property="name" value="${adr.value.Name.toString}" />
                </c:when>
            </c:choose>
        </c:when>
    </c:choose>

    <c:if test="${not empty poi}">
        <c:set var="adr" value="${poi.value.Address}" />
        <c:set target="${locData}" property="name" value="${poi.value.Title.toString}" />
        <c:if test="${poi.value.Coord.isSet}">
            <jsp:useBean id="coordBean" class="org.opencms.widgets.CmsLocationPickerWidgetValue" />
            <jsp:setProperty name="coordBean" property="wrappedValue" value="${poi.value.Coord}" />
            <c:set target="${locData}" property="lat" value="${coordBean.lat.toString()}" />
            <c:set target="${locData}" property="lng" value="${coordBean.lng.toString()}" />
            <c:set target="${locData}" property="zoom" value="${coordBean.zoom}" />
            <c:set target="${locData}" property="geocode" value="${false}" />
        </c:if>
    </c:if>

    <c:if test="${not empty adr}">
        <c:set target="${locData}" property="streetAddress" value="${adr.value.StreetAddress.toString}" />
        <c:set target="${locData}" property="extendedAddress" value="${adr.value.ExtendedAddress.toString}" />
        <c:set target="${locData}" property="postalCode" value="${adr.value.PostalCode.toString}" />
        <c:set target="${locData}" property="locality" value="${adr.value.Locality.toString}" />
        <c:set target="${locData}" property="region" value="${adr.value.Region.toString}" />
        <c:set target="${locData}" property="country" value="${adr.value.Country.toString}" />
    </c:if>

    <c:if test="${addMapInfo and (not empty locData.streetAddress)}">
        <c:set var="addressMarkup">${locData.streetAddress}</c:set>
        <c:if test="${not empty locData.extendedAddress}">
            <c:set var="addressMarkup">${addressMarkup}<br>${locData.extendedAddress}</c:set>
        </c:if>
        <c:set var="addressMarkup">${addressMarkup}<br>${locData.postalCode}</c:set>
        <c:set var="addressMarkup">${addressMarkup}${' '}${locData.locality}</c:set>
        <c:if test="${(not empty locData.region) or (not empty locData.country)}">
            <c:set var="addressMarkup">${addressMarkup}<br></c:set>
            <c:if test="${(not empty locData.region)}">
                <c:set var="addressMarkup">${addressMarkup}${locData.region}</c:set>
            </c:if>
            <c:if test="${(not empty locData.country)}">
                <c:set var="addressMarkup">${addressMarkup}${' '}${locData.country}</c:set>
            </c:if>
        </c:if>
        <c:set target="${locData}" property="addressMarkup" value="${addressMarkup}" />
    </c:if>
</c:if>

<jsp:doBody/>