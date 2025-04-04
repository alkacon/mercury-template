<%@ tag pageEncoding="UTF-8"
    display-name="contact-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Collects contact data from different content types and sets a series of variables for quick acess." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="Must be a content element of type 'contact information', 'person' or 'organization'." %>

<%@ attribute name="showPosition" type="java.lang.Boolean" required="false"
    description="Show the contact position." %>

<%@ attribute name="showOrganization" type="java.lang.Boolean" required="false"
    description="Show the contact organization." %>


<%@ variable name-given="valKind" declare="true"
    description="The contact kind. Can be 'org' or 'person'. Default is 'person'." %>

<%@ variable name-given="valName" declare="true"
    description="The name to display for the contact." %>

<%@ variable name-given="valPosition" declare="true"
    description="The position to display for the contact." %>

<%@ variable name-given="valOrganization" declare="true"
    description="The organization to display for the contact." %>

<%@ variable name-given="valAddress" declare="true"
    description="The address to display for the contact." %>

<%@ variable name-given="valLinkToRelated" declare="true"
    description="The link to the organization (for persons) or to the contact person (for organizations). Empty for POI." %>

<%@ variable name-given="valLinkToWebsite" declare="true"
    description="The link to the contact website. For person / organizations this is 'content.value.Contact.value.Website', for poi this is 'content.value.Link'." %>

<%@ variable name-given="kindModern" declare="true"
    description="If true, these contact vars are based on content type 'm-organization' or 'm-person'." %>

<%@ variable name-given="kindCss" declare="true"
    description="CSS selector added to the generated div to identify the contact type (person or organization)." %>

<%@ variable name-given="setShowOrganization" declare="true" %>
<%@ variable name-given="setShowPosition" declare="true" %>
<%@ variable name-given="setShowName" declare="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="value"                  value="${content.value}" />

<c:set var="valName"                value="${value.Name}" />
<c:set var="valPosition"            value="${value.Position}" />
<c:set var="valOrganization"        value="${value.Organization}" />
<c:set var="valAddress"             value="${value.Contact.value.AddressChoice}" />
<c:set var="valLinkToWebsite"       value="${value.Contact.value.Website}" />

<c:choose>
    <c:when test="${content.typeName eq 'm-organization'}">
        <c:set var="valKind"                value="org" />
        <c:set var="useLinkedContent"       value="${showOrganization}" />
        <c:set var="setShowName"            value="${false}" />
        <c:set var="setShowPosition"        value="${false}" />
        <c:set var="setShowOrganization"    value="${true}" />
        <c:set var="kindModern"             value="${true}" />
    </c:when>
    <c:when test="${content.typeName eq 'm-person'}">
        <c:set var="valKind"                value="pers" />
        <c:set var="useLinkedContent"       value="${showOrganization}" />
        <c:set var="setShowName"            value="${true}" />
        <c:set var="setShowPosition"        value="${showPosition}" />
        <c:set var="setShowOrganization"    value="${false}" />
        <c:set var="kindModern"             value="${true}" />
    </c:when>
    <c:when test="${content.typeName eq 'm-poi'}">
        <c:set var="valKind"                value="poi" />
        <c:set var="valName"                value="${value.Title}" />
        <c:set var="valAddress"             value="${content}" />
        <c:set var="valLinkToWebsite"       value="${
            not empty content.valueList.Paragraph ?
                (not empty content.valueList.Paragraph.get(0).value.Link ?
                    content.valueList.Paragraph.get(0).value.Link :
                    content.valueList.Paragraph.get(content.valueList.Paragraph.size() - 1).value.Link
                ) :
                null
        }" />
        <c:set var="useLinkedContent"       value="${false}" />
        <c:set var="setShowName"            value="${true}" />
        <c:set var="setShowPosition"        value="${false}" />
        <c:set var="setShowOrganization"    value="${false}" />
        <c:set var="kindModern"             value="${true}" />
    </c:when>
    <c:otherwise>
        <%-- Content must be of type 'm-contact' --%>
        <c:set var="valKind"                value="${value.Kind.isSet ? value.Kind.toString : 'pers'}" />
        <c:set var="useLinkedContent"       value="${false}" />
        <c:set var="setShowName"            value="${valKind eq 'org' ? showOrganization : true}" />
        <c:set var="setShowPosition"        value="${showPosition and setShowName}" />
        <c:set var="setShowOrganization"    value="${valKind eq 'org' ? true : showOrganization}" />
        <c:set var="kindModern"             value="${false}" />
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${valKind eq 'org'}">
        <c:set var="kindCss" value="contact-org" />
    </c:when>
    <c:when test="${valKind eq 'poi'}">
        <c:set var="kindCss" value="contact-poi" />
    </c:when>
    <c:otherwise>
        <c:set var="kindCss" value="contact-pers" />
    </c:otherwise>
</c:choose>

<c:if test="${useLinkedContent}">
    <c:if test="${value.LinkToManager.isSet}">
        <%-- If this is true, the content must be of type 'm-organization' --%>
        <c:set var="managerContent"     value="${cms.vfs.readXml[value.LinkToManager]}" />
        <c:set var="valName"            value="${managerContent.value.Name}" />
        <c:set var="valPosition"        value="${managerContent.value.Position}" />
        <c:set var="valLinkToRelated"><cms:link baseUri="${cms.requestContext.uri}">${value.LinkToManager}</cms:link></c:set>
        <c:set var="setShowName"        value="${true}" />
        <c:set var="setShowPosition"    value="${true}" />
    </c:if>
    <c:if test="${value.LinkToOrganization.isSet}">
        <%-- If this is true, the content must be of type 'm-person' --%>
        <c:set var="orgContent"         value="${cms.vfs.readXml[value.LinkToOrganization]}" />
        <c:set var="valOrganization"    value="${orgContent.value.Organization}" />
        <c:set var="valLinkToRelated"><cms:link baseUri="${cms.requestContext.uri}">${value.LinkToOrganization}</cms:link></c:set>
        <c:set var="setShowOrganization" value="${true}" />
        <c:if test="${not value.Contact.value.AddressChoice.isSet}">
            <c:set var="valAddress"     value="${orgContent.value.Contact.value.AddressChoice}" />
        </c:if>
    </c:if>
</c:if>

<jsp:doBody/>