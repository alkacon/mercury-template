<%@ tag pageEncoding="UTF-8"
    display-name="set-siteroot"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Sets the site root for pages in the system folder.
    This is required in case the 'alternative website path' feature in the OpenCms site configfuration is used.
    The reason is that for the system folder, the site root of alternative websites has to be adjusted manually." %>

<%@ attribute name="siteRoot" type="java.lang.String" required="true"
    description="The site root of the alternative website path to use." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<c:if test="${(not empty siteRoot) and (siteRoot ne cms.requestContext.siteRoot)}">
    <c:set var="ignore" value="${cms.requestContext.setSiteRoot(siteRoot)}" />
    <c:set var="ignore" value="${cms.controllerCms.requestContext.setSiteRoot(siteRoot)}" />
</c:if>
