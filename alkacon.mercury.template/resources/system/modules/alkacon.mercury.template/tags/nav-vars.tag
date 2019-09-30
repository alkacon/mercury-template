<%@ tag pageEncoding="UTF-8"
    display-name="nav-items"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Sets data that controls how a navigation is build." %>


<%@ attribute name="params" type="java.util.Map" required="true"
    description="The parameters passed to the page."%>


<%@ variable name-given="currentPageUri" declare="true"
    description="The page uri of the navigation." %>

<%@ variable name-given="currentPageFolder" declare="true"
    description="The start folder of the navigation, that is the folder that contains the page uri." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>


<%-- Check for nav path parameter and use this if it exists --%>
<c:set var="navpath"                    value="${params.navpath}" />
<c:if test="${not empty navpath}">
    <c:set var="navpathRes"             value="${cms.vfs.resource[navpath]}" />
    <c:set var="navpathRes"             value="${not empty navpathRes and (navpathRes.propertySearch['mercury.navpath'] eq 'param') ? navpathRes : null}" />
</c:if>

<c:set var="currentPageFolder"          value="${empty navpathRes ? cms.requestContext.folderUri : navpathRes.sitePathFolder}" />
<c:set var="currentPageUri"             value="${empty navpathRes ? cms.requestContext.uri : navpathRes.sitePath}" />

<jsp:doBody/>
