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
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>

<c:choose>
    <c:when test="${cms:isWrapper(resource)}">
        <c:choose>
            <c:when test="${resource.isSet and resource.value.URI.isSet}">
                <c:set var="targetLink" value="${resource.value.URI.toLink}" />
            </c:when>
            <c:when test="${resource.isSet and
                ((resource.typeName == 'OpenCmsVfsFile') or
                (resource.typeName == 'OpenCmsVarLink') or
                (resource.typeName == 'OpenCmsString'))}">
                    <c:set var="targetLink" value="${resource.toLink}" />
            </c:when>
        </c:choose>
        <c:set var="targetRes" value="${resource.toResource}" />
    </c:when>
    <c:otherwise>
        <c:set var="targetRes" value="${cms.wrap[resource].toResource}" />
        <c:set var="targetLink" value="${targetRes.link}" />
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${not empty targetLink}">
        <c:out value="${targetLink}" escapeXml="false" />
        <c:if test="${not empty targetRes}">
            <c:out value="?ver=${targetRes.dateLastModified}" escapeXml="false" />
        </c:if>
    </c:when>
    <c:when test="${not cms.isOnlineProject}">
        <!-- Unable to generate a link to resource '${link} -->
    </c:when>
</c:choose>

