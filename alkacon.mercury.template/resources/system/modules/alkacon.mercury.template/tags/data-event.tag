<%@ tag pageEncoding="UTF-8"
    display-name="data-event"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for events." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The event XML content to use for data generation."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<jsp:useBean id="eventschema" class="java.util.LinkedHashMap"/>

<c:set target="${eventschema}" property="name" value="${content.value.Title}" />
<c:set var="date" value="${content.value.Dates.toDateSeries.instanceInfo.get(param.instancedate)}" />
<c:if test="${not empty date}">
    <c:if test="${not empty date.start}">
        <c:set target="${eventschema}" property="startDate"><fmt:formatDate value="${date.start}" pattern="yyyy-MM-dd'T'HH:mm" /></c:set>
    </c:if>
    <c:if test="${not empty date.end and not (date.end eq date.start)}">
        <c:set target="${eventschema}" property="endDate"><fmt:formatDate value="${date.end}" pattern="yyyy-MM-dd'T'HH:mm" /></c:set>
    </c:if>
</c:if>

<c:choose>
    <c:when test="${content.value.Teaser.isSet}">
        <c:set target="${eventschema}" property="description" value="${content.value.Teaser}" />
    </c:when>
    <c:otherwise>
        <c:set var="textFound" value="false" />
        <c:forEach var="text" items="${content.valueList.Paragraph}" varStatus="status">
            <c:if test="${not textFound and text.value.Text.isSet}">
                <c:set target="${eventschema}" property="description" value="${text.value.Text}" />
                <c:set var="textFound" value="true" />
            </c:if>
        </c:forEach>
    </c:otherwise>
</c:choose>

<c:set var="imageElement" value="" />
<c:choose>
    <c:when test="${content.value.TeaserImage.isSet}">
        <c:set var="imageElement" value="${content.value.TeaserImage}" />
        <c:set var="imagePath">${cms.site.url}<cms:link>${content.value.TeaserImage}</cms:link></c:set>
         <c:set target="${eventschema}" property="image" value="${imagePath}" />
    </c:when>
    <c:otherwise>
        <c:forEach var="text" items="${content.valueList.Paragraph}" varStatus="status">
            <c:if test="${empty imageElement and text.value.Image.isSet}">
                <c:set var="imageElement" value="${text.value.Image}" />
                <mercury:image-vars image="${imageElement}">
                    <jsp:useBean id="eventimage" class="java.util.LinkedHashMap"/>
                    <c:set target="${eventimage}" property="@type" value="ImageObject" />
                    <c:set target="${eventimage}" property="contenturl" value="${cms.site.url.concat(imageUrl)}" />
                    <c:set target="${eventimage}" property="url" value="${cms.site.url.concat(imageUrl)}" />
                    <c:set target="${eventimage}" property="width" value="${''.concat(imageWidth)}" />
                    <c:set target="${eventimage}" property="height" value="${''.concat(imageHeight)}" />
                    <c:if test="${not empty imageTitle}"><c:set target="${eventimage}" property="name" value="${imageTitle}" /></c:if>
                    <c:if test="${not empty imageCopyright}"><c:set target="${eventimage}" property="copyrightHolder" value="${imageCopyright}" /></c:if>
                    <c:set target="${eventschema}" property="image" value="${eventimage}" />
                </mercury:image-vars>
            </c:if>
        </c:forEach>
    </c:otherwise>
</c:choose>

<mercury:location-data data="${content.value.AddressChoice}">

<c:if test="${(not empty locData.name) or (not empty locData.streetAddress) or content.value.LocationNote.isSet}">
    <jsp:useBean id="eventlocation" class="java.util.LinkedHashMap"/>
    <c:set target="${eventlocation}" property="@type" value="Place" />
    <c:if test="${not empty locName}">
        <c:set target="${eventlocation}" property="name" value="${locData.name}" />
    </c:if>

    <c:if test="${(not empty locData.streetAddress) or content.value.LocationNote.isSet}">
        <jsp:useBean id="eventaddress" class="java.util.LinkedHashMap"/>
        <c:set target="${eventaddress}" property="@type" value="PostalAddress" />
    </c:if>

    <c:if test="${not empty locData.streetAddress}">
        <c:set var="street" value="${locData.streetAddress}" />
        <c:if test="${not empty locData.extendedAddress}">
            <c:set var="street">${street}${empty street ? '' : ' '}${locData.extendedAddress}</c:set>
        </c:if>
        <c:if test="${not empty street}">
            <c:set target="${eventaddress}" property="streetAddress" value="${street}" />
        </c:if>
        <c:if test="${not empty locData.postalCode}">
            <c:set target="${eventaddress}" property="postalCode" value="${locData.postalCode}" />
        </c:if>
        <c:if test="${not empty locData.locality}">
            <c:set target="${eventaddress}" property="addressLocality" value="${locData.locality}" />
        </c:if>
        <c:if test="${not empty locData.region}">
            <c:set target="${eventaddress}" property="addressRegion" value="${locData.region}" />
        </c:if>
        <c:if test="${not empty locData.country}">
            <c:set target="${eventaddress}" property="addressCountry" value="${locData.country}" />
        </c:if>
    </c:if>

    <c:if test="${content.value.LocationNote.isSet}">
        <c:set target="${eventaddress}" property="description" value="${content.value.LocationNote}" />
    </c:if>

    <c:if test="${(not empty locData.lat) and (not empty locData.lng)}">
        <jsp:useBean id="geo" class="java.util.LinkedHashMap"/>
        <c:set target="${geo}" property="@type" value="GeoCoordinates" />
        <c:set target="${geo}" property="latitude" value="${locData.lat}" />
        <c:set target="${geo}" property="longitude" value="${locData.lng}" />
        <c:set target="${eventlocation}" property="geo" value="${geo}" />
    </c:if>

    <c:if test="${(not empty street) or content.value.LocationNote.isSet}">
        <c:set target="${eventlocation}" property="address" value="${eventaddress}" />
    </c:if>

    <c:set target="${eventschema}" property="location" value="${eventlocation}" />
</c:if>

</mercury:location-data>

<c:set var="url">${cms.site.url}<cms:link>${content.filename}</cms:link></c:set>

<mercury:data-json-ld type="Event" url="${url}" properties="${eventschema}" />