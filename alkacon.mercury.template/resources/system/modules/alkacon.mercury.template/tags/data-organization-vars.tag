<%@ tag pageEncoding="UTF-8"
    display-name="data-organization-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for organizations (from site properties)." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The XML content to use for data generation."%>

<%@ variable name-given="orgJsonLd" declare="true"
    description="A JSON-LD object created for the organization." %>

<%@ attribute name="logoAsImageObject" type="java.lang.Boolean" required="false"
    description="If true, a subnode of type ImageObject is generated for the logo,
    otherwise the logo URL is directly inserted.
    The Google tools are not quite clear what is the best way of doing this!" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="orgName" value="${content.wrap.propertySearch['site.organization']}" />
<c:if test="${not empty orgName}">
    <cms:jsonobject var="orgJsonLd" mode="object">
        <cms:jsonvalue key="@type" value="Organization" />
        <cms:jsonvalue key="name" value="${orgName}" />
        <c:set var="sameAs" value="${content.wrap.propertySearch['site.organization.url']}" />
        <c:if test="${not empty sameAs}">
            <cms:jsonvalue key="sameAs" value="${sameAs}" />
        </c:if>
        <c:set var="logo" value="${content.wrap.propertySearch['site.organization.logo']}" />
        <c:if test="${(not empty logo) and cms.vfs.existsResource[logo]}">
            <c:choose>
                <c:when test="${not logoAsImageObject}">
                    <cms:jsonvalue key="logo" value="${cms.site.url}${cms.vfs.readResource[logo].link}" />
                </c:when>
                <c:otherwise>
                    <cms:jsonobject key="logo">
                        <cms:jsonvalue key="@type" value="ImageObject" />
                        <cms:jsonvalue key="url" value="${cms.site.url}${cms.vfs.readResource[logo].link}" />
                    </cms:jsonobject>
                </c:otherwise>
            </c:choose>
        </c:if>
    </cms:jsonobject>
</c:if>

<jsp:doBody/>