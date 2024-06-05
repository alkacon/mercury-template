<%@ tag pageEncoding="UTF-8"
    display-name="load-resopurce"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Loads a resource.
    The file name of the resource is constructed by the provided attributes.
    The resource is made availabe in the body.
    A check is made if the resource exists or not.
    If the resource does not exist, a HTML comment is generated indicating the issue, but no exception is thrown." %>


<%@ attribute name="path" type="java.lang.String" required="true"
    description="The path to use for the resource." %>

<%@ attribute name="defaultPath" type="java.lang.String" required="false"
    description="Default for the path in case 'path' is empty." %>

<%@ attribute name="name" type="java.lang.String" required="false"
description="Resource name that is appended to the path." %>


<%@ variable name-given="resourcePath" declare="true"
    description="The constructed file name of the loaded resource." %>

<%@ variable name-given="resource" declare="true"
    description="The loaded resource." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="resPath" value="${empty path ? defaultPath : path}" />

<c:if test="${not empty resPath and (resPath ne 'none')}">
    <c:set var="resourcePath" value="${empty name ? resPath : resPath.concat(name) }" />
    <c:set var="resource" value="${cms.vfs.readResource[resourcePath]}" />
    <c:choose>
        <c:when test="${not empty resource}">
            <jsp:doBody />
        </c:when>
        <c:otherwise>
            <!-- Unable to load '${resourcePath}' (resource does not exist) --><m:nl />
        </c:otherwise>
    </c:choose>
</c:if>