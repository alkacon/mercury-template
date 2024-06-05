<%@ tag pageEncoding="UTF-8"
    display-name="link-resource"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a resource link with date info attached.
        To the link a paramater '?ver=($date-last-modified)' is attached, which will force a reload in case the file has changed.
        Used for generating links to CSS / JS files or other resources that should not be served from the cache if changed." %>


<%@ attribute name="resource" type="java.lang.Object" required="true"
    description="An object that contains the resource to generate the link to." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:choose>
    <c:when test="${cms:isWrapper(resource)}">
        <c:set var="targetRes" value="${resource.toResource}" />
    </c:when>
    <c:otherwise>
        <c:set var="targetRes" value="${cms.wrap[resource].toResource}" />
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${not empty targetRes}">
        <c:set var="targetLink" value="${targetRes.sitePath}" />
        <cms:link>${targetLink}?ver=${targetRes.dateLastModified}</cms:link>
    </c:when>
    <c:when test="${not cms.isOnlineProject}">
        <!-- Unable to link to resource '${resource}' --><m:nl />
    </c:when>
</c:choose>

