<%@ tag pageEncoding="UTF-8"
    display-name="contact-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Collects contact data from different content types and sets a series of variables for quick acess." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="Must be a content element of type 'contact information', 'person' or 'organization'." %>

<%@ attribute name="kind" type="java.lang.Object" required="true"
    description="The contact type to generate.
    Can be 'pers' for person or 'org' for organization." %>

<%@ attribute name="showName" type="java.lang.Boolean" required="false"
    description="Show the contact name." %>

<%@ attribute name="showPosition" type="java.lang.Boolean" required="false"
    description="Show the contact position." %>

<%@ attribute name="showOrganization" type="java.lang.Boolean" required="false"
    description="Show the contact organization." %>


<%@ variable name-given="valName" declare="true"
    description="The name to display for the contact." %>

<%@ variable name-given="valPosition" declare="true"
    description="The position to display for the contact." %>

<%@ variable name-given="valOrganization" declare="true"
    description="The organization to display for the contact." %>

<%@ variable name-given="valAddress" declare="true"
    description="The address to display for the contact." %>

<%@ variable name-given="kindCss" declare="true"
    description="CSS selector added to the generated div to identify the contact type (person or organization)." %>

<%@ variable name-given="kindAttr" declare="true"
    description="Attribute for schema.org added to the generated div to identify the contact type (person or organization)." %>

<%@ variable name-given="setShowName" declare="true" %>
<%@ variable name-given="setShowOrganization" declare="true" %>
<%@ variable name-given="setShowPosition" declare="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>


<c:set var="value"                  value="${content.value}" />

<c:set var="valName"                value="${value.Name}" />
<c:set var="valPosition"            value="${value.Position}" />
<c:set var="valOrganization"        value="${value.Organization}" />
<c:set var="valAddress"             value="${value.Contact.value.AddressChoice}" />

<c:set var="setShowName"             value="${showName}" />
<c:set var="setShowPosition"         value="${showPosition}" />
<c:set var="setShowOrganization"     value="${showOrganization}" />


<c:choose>
    <c:when test="${kind eq 'org'}">
        <c:set var="kindCss" value="contact-org" />
        <c:set var="kindAttr">itemscope itemtype="https://schema.org/Organization"</c:set>
    </c:when>
    <c:otherwise>
        <c:set var="kindCss" value="contact-pers" />
        <c:set var="kindAttr">itemscope itemtype="http://schema.org/Person"</c:set>
    </c:otherwise>
</c:choose>

<c:if test="${value.LinkToManager.isSet}">
    <c:set var="managerContent"     value="${cms.vfs.readXml[value.LinkToManager]}" />
    <c:set var="valName"            value="${managerContent.value.Name}" />
    <c:set var="valPosition"        value="${managerContent.value.Position}" />
    <c:set var="setShowName"        value="${true}" />
    <c:set var="setShowPosition"    value="${true}" />
</c:if>
<c:if test="${value.LinkToOrganization.isSet}">
    <c:set var="orgContent"         value="${cms.vfs.readXml[value.LinkToOrganization]}" />
    <c:set var="valOrganization"    value="${orgContent.value.Organization}" />
    <c:set var="setShowOrganization" value="${true}" />
    <c:if test="${not value.Contact.value.AddressChoice.isSet}">
        <c:set var="valAddress"     value="${orgContent.value.Contact.value.AddressChoice}" />
    </c:if>
</c:if>

<jsp:doBody/>