<%@ tag pageEncoding="UTF-8"
    display-name="nav-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Sets data that controls how a navigation is build." %>


<%@ attribute name="params" type="java.util.Map" required="true"
    description="The JSP parameters passed to the page."%>

<%@ attribute name="navPathRes" type="org.opencms.jsp.CmsJspResourceWrapper" required="false"
    description="The resource from the URI to display the the navigation for."%>


<%@ variable name-given="currentPageUri" declare="true"
    description="The page uri of the navigation." %>

<%@ variable name-given="currentPageFolder" declare="true"
    description="The start folder of the navigation, that is the folder that contains the page uri." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<%-- Check for nav path parameter and use this if it exists --%>

<c:choose>
    <c:when test="${not empty navPathRes}">
        <%-- Skip other cases --%>
    </c:when>
    <c:when test="${not empty param and not empty params.navpath}">
        <c:set var="navPathRes"             value="${cms.vfs.resource[params.navpath]}" />
        <c:set var="navPathRes"             value="${not empty navPathRes and (navPathRes.propertySearch['mercury.navpath'] eq 'param') ? navPathRes : null}" />
    </c:when>
    <c:when test="${not empty cms.meta.navPathRes}">
        <c:set var="navPathRes"             value="${cms.vfs.resource[cms.meta.navPathRes]}" />
    </c:when>
</c:choose>

<%-- Make sure the navPathRes is in the current site --%>
<c:set var="navPathRes" value="${(not empty navPathRes) and fn:startsWith(navPathRes.rootPath, cms.requestContext.siteRoot) ? navPathRes : null}" />

<c:set var="currentPageFolder"          value="${empty navPathRes ? cms.requestContext.folderUri : navPathRes.sitePathFolder}" />
<c:set var="currentPageUri"             value="${empty navPathRes ? cms.requestContext.uri : navPathRes.sitePath}" />

<jsp:doBody/>
