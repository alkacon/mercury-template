<%@tag
    pageEncoding="UTF-8"
    display-name="content-properties"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Reads the properties for the current page." %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>

<%@ variable name-given="contentUri" declare="true"
    description="The URI of the resource currently rendered.
    This can be either the request context URI, or a detail content site path." %>

<%@ variable name-given="contentProperties" declare="true"
    description="The properties read directly from the URI resource." %>

<%@ variable name-given="contentPropertiesSearch" declare="true"
    description="The properties read from the URI resource with search." %>

<%@ variable name-given="contentPropertiesSearchDetail" declare="true"
    description="The properties read from the URI resource OR detail resource with search." %>

<c:choose>
<c:when test="${cms.detailRequest}">
    <c:set var="contentUri" value="${cms.detailContentSitePath}" />
</c:when>
<c:otherwise>
    <c:set var="contentUri" value="${cms.requestContext.uri}" />
</c:otherwise>
</c:choose>

<c:set var="contentProperties" value="${cms.vfs.readProperties[contentUri]}" />
<c:set var="contentPropertiesSearch" value="${cms.vfs.readPropertiesSearch[cms.requestContext.uri]}" />
<c:set var="contentPropertiesSearchDetail" value="${cms.vfs.readPropertiesSearch[contentUri]}" />

<jsp:doBody/>