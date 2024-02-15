<%@ tag pageEncoding="UTF-8"
    display-name="location-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Collects location data from a POI file or inline fields and sets a series of variables for quick acess." %>


<%@ attribute name="data" type="java.lang.Object" required="true"
    description="The location to use. Can be a either a POI content access wrapper,
    a VFS path to a POI that should be read OR
    a manual nested content address wrapper." %>

<%@ attribute name="onlineUrl" type="java.lang.Object" required="false"
    description="An object that containt the online URL location to use." %>

<%@ attribute name="fallbackOnlineUrl" type="java.lang.String" required="false"
    description="Fallback URL that is used in the case of a virtual location with no online URL given." %>

<%@ attribute name="addMapInfo" type="java.lang.Boolean" required="false"
    description="If true, data for a location map is generated as well." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="If provided and false, the location data is not collected." %>

<%@ attribute name="createJsonLd" type="java.lang.Boolean" required="false"
    description="Controls if a JSON-LD object is created for the location and stored in the variable 'locJsonLd'.
    Default is 'false' if not provided." %>


<%@ variable name-given="locData" declare="true"
    description="A map that contains the data read for the location as properties." %>

<%@ variable name-given="locJsonLd" declare="true"
    description="A JSON-LD object created for the location of type 'place'.
    This will only be created if the attribute createJsonLd has been set to 'true'." %>

<%@ variable name-given="adrJsonLd" declare="true"
    description="A JSON-LD object created for the address of the location.
    This will only be created if the attribute createJsonLd has been set to 'true'." %>

<%@ variable name-given="locAttendanceMode" declare="true"
    description="A String that will hold the information about the attendance mode.
    This will only be created if the attribute createJsonLd has been set to 'true'." %>


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

    <c:choose>
        <c:when test="${cms:isWrapper(onlineUrl)}">
            <c:choose>
                <c:when test="${onlineUrl.isSet and onlineUrl.value.URI.isSet}">
                    <c:set var="targetUrl" value="${onlineUrl.value.URI.toLink}" />
                </c:when>
                <c:when test="${onlineUrl.isSet and
                    ((onlineUrl.typeName == 'OpenCmsVfsFile') or
                    (onlineUrl.typeName == 'OpenCmsVarLink') or
                    (onlineUrl.typeName == 'OpenCmsString'))}">
                        <c:set var="targetUrl" value="${onlineUrl.toLink}" />
                </c:when>
                <c:when test="${not empty fallbackOnlineUrl}">
                    <c:set var="targetUrl" value="${fallbackOnlineUrl}" />
                </c:when>
            </c:choose>
        </c:when>
        <c:when test="${not empty onlineUrl}">
            <c:set var="targetUrl" value="${onlineUrl.toString()}" />
        </c:when>
    </c:choose>

    <c:if test="${not empty poi}">
        <c:set var="adr" value="${poi.value.Address}" />
        <c:set target="${locData}" property="name" value="${poi.value.Title.toString}" />
        <c:set target="${locData}" property="paragraph" value="${poi.value.Paragraph}" />
        <c:if test="${not empty poi.valueList.Paragraph}">
            <c:set var="poiLink" value="${poi.valueList.Paragraph.get(0).value.Link}" />
            <c:if test="${empty poiLink}">
                <c:set var="poiLink" value="${poi.valueList.Paragraph.get(poi.valueList.Paragraph.size() - 1).value.Link}" />
            </c:if>
            <c:set target="${locData}" property="link" value="${poiLink}" />
        </c:if>
        <c:if test="${poi.value.Facilities.isSet}">
            <c:set target="${locData}" property="facilities" value="${poi.value.Facilities}" />
        </c:if>
        <c:set var="coordData" value="${poi.value.Coord}" />
    </c:if>

    <c:if test="${not empty adr}">
        <c:set target="${locData}" property="streetAddress" value="${adr.value.StreetAddress.toString}" />
        <c:set target="${locData}" property="extendedAddress" value="${adr.value.ExtendedAddress.toString}" />
        <c:set target="${locData}" property="postalCode" value="${adr.value.PostalCode.toString}" />
        <c:set target="${locData}" property="locality" value="${adr.value.Locality.toString}" />
        <c:set target="${locData}" property="region" value="${adr.value.Region.toString}" />
        <c:set target="${locData}" property="country" value="${adr.value.Country.toString}" />
        <c:set var="coordData" value="${coordData.isSet ? coordData : adr.value.Coord}" />
    </c:if>

    <c:if test="${coordData.isSet}">
        <jsp:useBean id="coordBean" class="org.opencms.widgets.CmsLocationPickerWidgetValue" />
        <jsp:setProperty name="coordBean" property="wrappedValue" value="${coordData}" />
        <c:set target="${locData}" property="lat" value="${coordBean.lat.toString()}" />
        <c:set target="${locData}" property="lng" value="${coordBean.lng.toString()}" />
        <c:set target="${locData}" property="zoom" value="${coordBean.zoom}" />
        <c:set target="${locData}" property="geocode" value="${false}" />
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

    <c:if test="${createJsonLd}">
        <c:if test="${(not empty locData.name) or (not empty locData.streetAddress)}">

            <c:if test="${not empty locData.streetAddress}">
                <cms:jsonobject var="adrJsonLd" mode="object">
                    <cms:jsonvalue key="@type" value="PostalAddress" />
                    <c:set var="street" value="${locData.streetAddress}" />
                    <c:if test="${not empty locData.ExtendedAddress}">
                        <c:set var="street" value="${street}${empty street ? '' : ' '}${locData.ExtendedAddress}" />
                    </c:if>
                    <cms:jsonvalue key="streetAddress" value="${street}" />
                    <c:if test="${not empty locData.postalCode}">
                        <cms:jsonvalue key="postalCode" value="${locData.postalCode}" />
                    </c:if>
                    <c:if test="${not empty locData.locality}">
                        <cms:jsonvalue key="addressLocality" value="${locData.locality}" />
                    </c:if>
                    <c:if test="${not empty locData.region}">
                        <cms:jsonvalue key="addressRegion" value="${locData.region}" />
                    </c:if>
                    <c:if test="${not empty locData.country}">
                        <cms:jsonvalue key="addressCountry" value="${locData.country}" />
                    </c:if>
                    <c:if test="${(not empty locData.lat) and (not empty locData.lng)}">
                        <cms:jsonobject key="areaServed" mode="object">
                            <cms:jsonvalue key="@type" value="Place" />
                            <cms:jsonobject key="geo" mode="object">
                                <cms:jsonvalue key="@type" value="GeoCoordinates" />
                                <cms:jsonvalue key="latitude" value="${locData.lat}" />
                                <cms:jsonvalue key="longitude" value="${locData.lng}" />
                            </cms:jsonobject>
                        </cms:jsonobject>
                    </c:if>
                </cms:jsonobject>
            </c:if>

            <cms:jsonobject var="locJsonLdPlace" mode="object">
                <cms:jsonvalue key="@type" value="Place" />
                <c:if test="${not empty locData.name}">
                    <cms:jsonvalue key="name" value="${locData.name}" />
                </c:if>
                <c:if test="${not empty locData.streetAddress}">
                    <cms:jsonvalue key="address" value="${adrJsonLd}" />
                </c:if>
            </cms:jsonobject>
        </c:if>

        <c:if test="${not empty targetUrl}">
            <cms:jsonobject var="locJsonLdUrl" mode="object">
                <cms:jsonvalue key="@type" value="VirtualLocation" />
                <cms:jsonvalue key="url" value="${targetUrl}" />
            </cms:jsonobject>
        </c:if>

        <c:choose>
            <c:when test="${not empty locJsonLdPlace and not empty locJsonLdUrl}">
                <cms:jsonarray var="locJsonLd" mode="object">
                    <cms:jsonvalue value="${locJsonLdPlace}" />
                    <cms:jsonvalue value="${locJsonLdUrl}" />
                </cms:jsonarray>
                <c:set var="locAttendanceMode"  value="https://schema.org/MixedEventAttendanceMode" />
            </c:when>
            <c:when test="${not empty locJsonLdPlace}">
                <c:set var="locJsonLd" value="${locJsonLdPlace}" />
                <c:set var="locAttendanceMode"  value="https://schema.org/OfflineEventAttendanceMode" />
            </c:when>
            <c:when test="${not empty locJsonLdUrl}">
                <c:set var="locJsonLd" value="${locJsonLdUrl}" />
                <c:set var="locAttendanceMode"  value="https://schema.org/OnlineEventAttendanceMode" />
            </c:when>
        </c:choose>
    </c:if>

</c:if>


<jsp:doBody/>