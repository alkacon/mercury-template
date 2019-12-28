<%@ tag pageEncoding="UTF-8"
    display-name="data-organization-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for organizations (from site properties)." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The XML content to use for data generation."%>

<%@ variable name-given="orgJsonLd" declare="true"
    description="A JSON-LD object created for the organization." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="orgName" value="${content.wrap.propertySearch['site.organization']}" />
<c:if test="${not empty orgName}">
    <cms:jsonobject var="orgJsonLd" mode="object">
        <cms:jsonvalue key="@type" value="Organization" />
        <cms:jsonvalue key="name" value="${orgName}" />
        <c:set var="orgLogo" value="${content.wrap.propertySearch['site.organization.logo']}" />
        <c:if test="${not empty orgLogo}">
            <cms:jsonobject key="logo">
                <cms:jsonvalue key="@type" value="ImageObject" />
                <c:if test="${cms.vfs.existsResource[orgLogo]}">
                    <c:set var="orgLogo" value="${cms.site.url}${cms.vfs.readResource[orgLogo].link}" />
                </c:if>
                <cms:jsonvalue key="url" value="${orgLogo}" />
            </cms:jsonobject>
        </c:if>
    </cms:jsonobject>
</c:if>

<jsp:doBody/>