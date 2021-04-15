<%@ tag pageEncoding="UTF-8"
    display-name="set-siteroot"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Sets the site root and the uri for elements in the system folder.
    This is required in case the site root - and optionally the uri - of the page calling the element is needed to correctly generate the output of the element.
    Since the requested ressource is in the system folder, the uri set will initially be reflecting the resource in the system folder.
    In case the 'alternative website path' feature in the OpenCms site configfuration is used the site may also be different." %>


<%@ attribute name="siteRoot" type="java.lang.String" required="true"
    description="The site root of the alternative website path to use." %>

<%@ attribute name="sitePath" type="java.lang.String" required="false"
    description="The site path (ms.requestContext.uri) to use." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<c:if test="${(not empty siteRoot) and (siteRoot ne cms.requestContext.siteRoot)}">
    <c:set var="ignore" value="${cms.requestContext.setSiteRoot(siteRoot)}" />
    <c:set var="ignore" value="${cms.controllerCms.requestContext.setSiteRoot(siteRoot)}" />
</c:if>

<c:if test="${(not empty sitePath) and (sitePath ne cms.requestContext.uri)}">
    <c:set var="ignore" value="${cms.requestContext.setUri(sitePath)}" />
    <c:set var="ignore" value="${cms.controllerCms.requestContext.setUri(sitePath)}" />
</c:if>

