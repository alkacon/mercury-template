<%@ tag pageEncoding="UTF-8"
    display-name="data-organization"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for organizations." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The XML content to use for data generation."%>

<%@ attribute name="locData" type="java.util.Map" required="true"
    description="Location data as given by location-vars.tag."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:data-contact-vars content="${content}" locData="${locData}">

<%--
# JSON-LD generation for Mercury organization.
# See: https://schema.org/Organization
--%>
<cms:jsonobject var="jsonLd">
    <cms:jsonvalue key="@context" value="https://schema.org" />
    <cms:jsonvalue key="@type" value="Organization" />
    <cms:jsonvalue key="name" value="${not empty strOrgName ? strOrgName : null}" />
    <cms:jsonvalue key="url" value="${not empty strWebsiteUrl ? strWebsiteUrl : null}" />
    <cms:jsonvalue key="image" value="${not empty strImageUrl ? strImageUrl : null}" />
    <cms:jsonvalue key="telephone" value="${not empty strPhone ? strPhone : not empty strMobile ? strMobile : null}" />
    <cms:jsonvalue key="email" value="${not empty strEmail ? strEmail : null}" />
    <cms:jsonvalue key="faxNumber" value="${not empty strFax ? strFax : null}" />
    <cms:jsonobject key="address">
        <cms:jsonvalue key="@type" value="PostalAddress" />
        <cms:jsonvalue key="streetAddress" value="${not empty strAddressLine ? strAddressLine : null}" />
        <cms:jsonvalue key="postalCode" value="${not empty strPostalCode ? strPostalCode : null}" />
        <cms:jsonvalue key="addressLocality" value="${not empty strLocality ? strLocality : null}" />
        <cms:jsonvalue key="addressRegion" value="${not empty strRegion ? strRegion : null}" />
        <cms:jsonvalue key="addressCountry" value="${not empty strCountry ? strCountry : null}" />
        <c:if test="${(not empty strLat) and (not empty strLng)}">
            <cms:jsonobject key="areaServed" mode="object">
                <cms:jsonvalue key="@type" value="Place" />
                <cms:jsonobject key="geo" mode="object">
                    <cms:jsonvalue key="@type" value="GeoCoordinates" />
                    <cms:jsonvalue key="latitude" value="${strLat}" />
                    <cms:jsonvalue key="longitude" value="${strLng}" />
                </cms:jsonobject>
            </cms:jsonobject>
        </c:if>
    </cms:jsonobject>
</cms:jsonobject>

</mercury:data-contact-vars>

<script type="application/ld+json"><%----%>
    ${cms.isOnlineProject ? jsonLd.compact : jsonLd.pretty}
</script><%----%>
