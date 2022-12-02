<%@ tag pageEncoding="UTF-8"
    display-name="contact-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Collects contact data from different content types and sets a series of variables for quick acess." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="Must be a content element of type 'contact information', 'person' or 'organization'." %>

<%@ attribute name="locData" type="java.util.Map" required="true"
    description="Location data as given by location-vars.tag."%>

<%-- Data available for both, organizations and persons --%>
<%@ variable name-given="strWebsiteUrl" declare="true"
    description="The website URL as string." %>

<%@ variable name-given="strImageUrl" declare="true"
    description="The image URL as string." %>

<%@ variable name-given="strPhone" declare="true"
    description="The phone number as string." %>

<%@ variable name-given="strMobile" declare="true"
    description="The mobile number as string." %>

<%@ variable name-given="strFax" declare="true"
    description="The fax number as string." %>

<%@ variable name-given="strEmail" declare="true"
    description="The email address as string." %>

<%@ variable name-given="strAddressLine" declare="true"
    description="The address line as string." %>

<%@ variable name-given="strPostalCode" declare="true"
    description="The postal code as string." %>

<%@ variable name-given="strLocality" declare="true"
    description="The locality as string." %>

<%@ variable name-given="strRegion" declare="true"
    description="The region as string." %>

<%@ variable name-given="strCountry" declare="true"
    description="The country as string." %>

<%@ variable name-given="strLat" declare="true"
    description="The latitude as string." %>

<%@ variable name-given="strLng" declare="true"
    description="The longitude as string." %>

<%-- Data available for persons only --%>
<%@ variable name-given="strPersTitle" declare="true"
    description="The person's honoric title as string." %>

<%@ variable name-given="strPersFirstName" declare="true"
    description="The person's first name as string." %>

<%@ variable name-given="strPersMiddleName" declare="true"
    description="The person's middle name as string." %>

<%@ variable name-given="strPersLastName" declare="true"
    description="The person's last name as string." %>

<%@ variable name-given="strPersPosition" declare="true"
    description="The person's job position as string." %>

<%-- Data available for organizations only --%>
<%@ variable name-given="strOrgName" declare="true"
    description="The organization's name as string." %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="value"                 value="${content.value}" />
<c:set var="contact"               value="${value.Contact}" />

<c:set var="websiteLink"           value="${contact.value.Website}" />
<c:if test="${websiteLink.isSet and websiteLink.value.URI.isSet}">
    <c:set var="strWebsiteUrl"     value="${websiteLink.value.URI.toLink}" />
</c:if>
<c:if test="${not empty strWebsiteUrl and fn:startsWith(strWebsiteUrl, '/')}">
    <c:set var="strWebsiteUrl"     value="${cms.site.url}${strWebsiteUrl}" />
</c:if>
<c:if test="${value.Image.isSet and value.Image.value.Image.isSet}">
    <c:set var="strImageUrl"       value="${value.Image.value.Image.toImage.srcUrl}" />
</c:if>
<c:if test="${not empty strImageUrl and fn:startsWith(strImageUrl, '/')}">
    <c:set var="strImageUrl"       value="${cms.site.url}${strImageUrl}" />
</c:if>
<c:set var="strPhone"              value="${contact.value.Phone.toString}" />
<c:set var="strMobile"             value="${contact.value.Mobile.toString}" />
<c:set var="strFax"                value="${contact.value.Fax.toString}" />
<c:set var="strEmail"              value="${contact.value.Email.value.Email.toString}" />
<c:set var="strAddressLine"        value="${locData.streetAddress}" />
<c:if test="${not empty locData.ExtendedAddress}">
    <c:set var="strAddressLine"    value="${strAddressLine}${empty strAddressLine ? '' : ' '}${locData.ExtendedAddress}" />
</c:if>
<c:set var="strPostalCode"         value="${locData.postalCode}" />
<c:set var="strLocality"           value="${locData.locality}" />
<c:set var="strRegion"             value="${locData.region}" />
<c:set var="strCountry"            value="${locData.country}" />
<c:set var="strLat"                value="${locData.lat}" />
<c:set var="strLng"                value="${locData.lng}" />
<c:if test="${not empty value.Name}">
    <c:set var="strPersTitle"      value="${value.Name.value.Title.toString}" />
    <c:set var="strPersFirstName"  value="${value.Name.value.FirstName.toString}" />
    <c:set var="strPersMiddleName" value="${value.Name.value.MiddleName.toString}" />
    <c:set var="strPersLastName"   value="${value.Name.value.LastName.toString}" />
</c:if>
<c:set var="strPersPosition"       value="${value.Position.toString}" />
<c:set var="strOrgName"            value="${value.Organization.toString}" />

<jsp:doBody/>