<%@ tag pageEncoding="UTF-8"
    display-name="data-person"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for persons." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The XML content to use for data generation."%>

<%@ attribute name="showAddress" type="java.lang.Boolean" required="false"
    description="Include the persons address in the output." %>

<%@ attribute name="showOrganization" type="java.lang.String" required="false"
    description="Include the organization information in the output." %>

<%@ attribute name="orgContent" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="false"
    description="A content access bean of type m-organization.
    If provided the 'organization' information will be generated from this content.
    Otherwise the 'organization' information will be generated from the 'LinkToOrganization' relation of the person content." %>

<%@ attribute name="storePersJsonLdObject" type="java.lang.Boolean" required="false"
    description="Controls if a JSON-LD object is created for the person and stored in the variable 'persJsonLd'.
    If this is set to 'true', no output is written, only the object is generated and stored in the variable.
    Default is 'false' if not provided." %>

<%@ variable name-given="persJsonLd" scope="AT_END" declare="true" variable-class="org.opencms.jsp.util.CmsJspJsonWrapper"
    description="A JSON-LD object created for the person.
    This will only be created if the attribute 'storePersJsonLdObject' has been set to 'true'." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="value"                  value="${content.value}" />
<c:set var="contact"                value="${content.value.Contact.value}" />
<c:set var="name"                   value="${content.value.Name.value}" />

<c:choose>
    <c:when test="${content.typeName eq 'm-contact'}">
        <c:set var="strWebsiteUrl"  value="${contact.Website.isSet ? contact.Website.toLink : null}" />
    </c:when>
    <c:otherwise>
        <c:set var="strWebsiteUrl"  value="${contact.Website.value.URI.isSet ? contact.Website.value.URI.toLink : null}" />
    </c:otherwise>
</c:choose>
<c:if test="${not empty strWebsiteUrl and fn:startsWith(strWebsiteUrl, '/')}">
    <c:set var="strWebsiteUrl"      value="${cms.site.url}${strWebsiteUrl}" />
</c:if>

<c:set var="strImageUrl"            value="${value.Image.value.Image.isSet ? value.Image.value.Image.toImage.srcUrl : null}" />
<c:if test="${not empty strImageUrl and fn:startsWith(strImageUrl, '/')}">
    <c:set var="strImageUrl"        value="${cms.site.url}${strImageUrl}" />
</c:if>

<c:set var="showOrg"                value="${showOrganization eq 'true'}" />
<c:set var="showOrgLink"            value="${showOrganization eq 'link'}" />

<c:set var="valAddress"             value="${value.Contact.value.AddressChoice}" />
<c:if test="${(showOrg and (value.LinkToOrganization.isSet or not empty orgContent)) or (showAddress and showOrgLink and not value.Contact.value.AddressChoice.isSet)}">
    <c:set var="orgContent"         value="${empty orgContent ? cms.vfs.readXml[value.LinkToOrganization] : orgContent}" />
    <c:if test="${showOrg}">
        <mercury:data-organization content="${orgContent}" storeOrgJsonLdObject="${true}" showAddress="${false}" showPerson="${false}" />
    </c:if>
    <c:if test="${not value.Contact.value.AddressChoice.isSet}">
        <c:set var="valAddress"     value="${orgContent.value.Contact.value.AddressChoice}" />
    </c:if>
</c:if>

<%--
# JSON-LD generation for Mercury persons.
# See: https://schema.org/Person
--%>
<cms:jsonobject var="jsonLd">
    <c:if test="${not storePersJsonLdObject}">
        <cms:jsonvalue key="@context"       value="https://schema.org" />
    </c:if>
    <cms:jsonvalue key="@type"              value="Person" />

    <cms:jsonvalue key="honorificPrefix"    value="${name.Title.isSet ? name.Title.toString : null}" />
    <cms:jsonvalue key="givenName"          value="${name.FirstName.isSet ? name.FirstName.toString : null}" />
    <cms:jsonvalue key="additionalName"     value="${name.MiddleName.isSet ? name.MiddleName.toString : null}" />
    <cms:jsonvalue key="familyName"         value="${name.LastName.isSet ? name.LastName.toString : null}" />
    <cms:jsonvalue key="jobTitle"           value="${value.Position.isSet ? value.Position.toString : null}" />

    <cms:jsonvalue key="telephone"          value="${contact.Phone.isSet ? contact.Phone.toString : (contact.Mobile.isSet ? contact.Mobile.toString : null)}" />
    <cms:jsonvalue key="faxNumber"          value="${contact.Fax.isSet ? contact.Fax.toString : null}" />

    <cms:jsonvalue key="email"              value="${contact.Email.value.Email.isSet and not contact.Email.value.ObfuscateEmail.toBoolean ? contact.Email.value.Email.toString : null}" />

    <cms:jsonvalue key="url"                value="${strWebsiteUrl}" />
    <cms:jsonvalue key="image"              value="${strImageUrl}" />

    <c:if test="${showAddress}">
        <mercury:location-vars data="${valAddress}" addMapInfo="${true}" createJsonLd="${true}" >
            <cms:jsonvalue key="address" value="${adrJsonLd}" />
        </mercury:location-vars>
    </c:if>

    <c:if test="${showOrg}">
        <c:choose>
            <c:when test="${not empty orgJsonLd}">
                <cms:jsonvalue key="memberOf"   value="${orgJsonLd}" />
            </c:when>
            <c:when test="${value.Organization.isSet}">
                <cms:jsonvalue key="memberOf"   value="${value.Organization.toString}" />
            </c:when>
        </c:choose>
    </c:if>

</cms:jsonobject>

<c:choose>
    <c:when test="${storePersJsonLdObject}">
        <c:set var="persJsonLd" value="${jsonLd}" />
    </c:when>
    <c:otherwise>
        <script type="application/ld+json"><%----%>
            ${cms.isOnlineProject ? jsonLd.compact : jsonLd.pretty}
        </script><%----%>
    </c:otherwise>
</c:choose>