<%@ tag pageEncoding="UTF-8"
    display-name="data-person"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for persons." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The XML content to use for data generation."%>

<%@ attribute name="locData" type="java.util.Map" required="true"
    description="Location data as given by location-vars.tag."%>

<%@ attribute name="organization" type="java.lang.String" required="false"
    description="The name of the organization this person belongs to."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="value" value="${content.value}" />
<c:set var="contact" value="${value.Contact}" />
<c:if test="${not empty value.Contact}">
    <c:set var="websiteLink" value="${contact.value.Website}" />
    <c:if test="${websiteLink.isSet and websiteLink.value.URI.isSet}">
        <c:set var="websiteURL" value="${websiteLink.value.URI.toLink}" />
    </c:if>
    <c:if test="${not empty websiteURL and fn:startsWith(websiteURL, '/')}">
        <c:set var="websiteURL" value="${cms.site.url}${websiteURL}" />
    </c:if>
    <c:set var="telephone" value="${contact.value.Phone.toString}" />
    <c:if test="${empty phone}">
        <c:set var="phone" value="${contact.value.Mobile.toString}" />
    </c:if>
    <c:set var="email" value="${contact.value.Email.value.Email.toString}" />
    <c:set var="faxNumber" value="${contact.value.Fax.toString}" />
</c:if>
<c:if test="${value.Image.isSet and value.Image.value.Image.isSet}">
    <c:set var="image" value="${value.Image.value.Image.toImage.srcUrl}" />
</c:if>
<c:if test="${not empty image and fn:startsWith(image, '/')}">
    <c:set var="image" value="${cms.site.url}${image}" />
</c:if>

<%--
# JSON-LD generation for Mercury persons.
# See: https://schema.org/Person
--%>
<cms:jsonobject var="jsonLd">
    <cms:jsonvalue key="@context" value="http://schema.org" />
    <cms:jsonvalue key="@type" value="Person" />
    <cms:jsonvalue key="honorificPrefix" value="${value.Name.value.Title.toString}" />
    <cms:jsonvalue key="givenName" value="${value.Name.value.FirstName.toString}" />
    <cms:jsonvalue key="additionalName" value="${value.Name.value.MiddleName.toString}" />
    <cms:jsonvalue key="familyName" value="${value.Name.value.LastName.toString}" />
    <cms:jsonvalue key="jobTitle" value="${value.Position.toString}" />
    <cms:jsonvalue key="url" value="${websiteURL}" />
    <cms:jsonvalue key="image" value="${image}" />
    <cms:jsonvalue key="telephone" value="${telephone}" />
    <cms:jsonvalue key="email" value="${email}" />
    <cms:jsonvalue key="faxNumber" value="${faxNumber}" />
    <cms:jsonvalue key="memberOf" value="${organization}" />
    <c:if test="${not empty locData}">
        <cms:jsonobject key="address">
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
</cms:jsonobject>

<script type="application/ld+json"><%----%>
    ${cms.isOnlineProject ? jsonLd.compact : jsonLd.pretty}
</script><%----%>
