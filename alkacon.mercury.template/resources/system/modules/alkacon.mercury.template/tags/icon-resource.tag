<%@ tag pageEncoding="UTF-8"
    display-name="icon-resource"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays icons from different icon sets." %>


<%@ attribute name="icon" type="java.lang.String" required="true"
    description="The name or id of the icon to render.
    The selection is based on a prefix.
    Supported prefixes are:
    fa- : use Fork Awesome
    bi- : use Boostrap Icons.
    In case no prefix is given, the default is Fork Awesome" %>

<%@ attribute name="setFallback" type="java.lang.Boolean" required="false"
    description="If 'true' a default icon (question mark) is returned in case the requested icon is not found." %>

<%@ attribute name="fromImage" type="java.lang.Boolean" required="false"
    description="If 'true', then do NOT use an icon from a default font but treat the 'icon' parameter as path to an image resource." %>


<%@ variable name-given="iconResource" scope="AT_END" declare="true" variable-class="org.opencms.jsp.CmsJspResourceWrapper"
    description="The icon resource that has been found." %>

<%@ variable name-given="iconPath" scope="AT_END" declare="true" variable-class="java.lang.String"
    description="The icon name." %>

<%@ variable name-given="iconName" scope="AT_END" declare="true" variable-class="java.lang.String"
    description="The icon name." %>

<%@ variable name-given="iconIsValid" scope="AT_END" declare="true" variable-class="java.lang.Boolean"
    description="Will be 'true' in case the requested icon resource has been found." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="icon"           value="${fn:trim(icon)}" />

<c:choose>
    <c:when test="${fromImage}">
        <c:set var="iconPath" value="${icon}" />
        <c:set var="iconName" value="ico-from-image" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'bi-')}">
        <c:set var="iconFile" value="${fn:substringAfter(icon, 'bi-')}" />
        <c:set var="iconPath" value="/system/modules/alkacon.mercury.theme/icons/bi/${iconFile}.svg" />
        <c:set var="iconName" value="ico-${icon}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'fa-')}">
        <c:set var="iconFile" value="${fn:substringAfter(icon, 'fa-')}" />
        <c:set var="iconPath" value="/system/modules/alkacon.mercury.theme/icons/fa/${iconFile}.svg" />
        <c:set var="iconName" value="ico-${icon}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'fab-')}">
        <c:set var="iconFile" value="${fn:substringAfter(icon, 'fab-')}" />
        <c:set var="iconPath" value="/system/modules/alkacon.mercury.theme/icons/fab/${iconFile}.svg" />
        <c:set var="iconName" value="ico-${icon}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'fas-')}">
        <c:set var="iconFile" value="${fn:substringAfter(icon, 'fas-')}" />
        <c:set var="iconPath" value="/system/modules/alkacon.mercury.theme/icons/fas/${iconFile}.svg" />
        <c:set var="iconName" value="ico-${icon}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'far-')}">
        <c:set var="iconFile" value="${fn:substringAfter(icon, 'far-')}" />
        <c:set var="iconPath" value="/system/modules/alkacon.mercury.theme/icons/far/${iconFile}.svg" />
        <c:set var="iconName" value="ico-${icon}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'nf-')}">
        <c:set var="iconFile" value="${fn:substringAfter(icon, 'nf-')}" />
        <c:set var="iconPath" value="/system/modules/alkacon.mercury.theme/icons/nf/${iconFile}.svg" />
        <c:set var="iconName" value="ico-${icon}" />
    </c:when>
    <c:otherwise>
        <c:set var="iconPath" value="/system/modules/alkacon.mercury.theme/icons/fa/${icon}.svg" />
        <c:set var="iconName" value="ico-fa-${icon}" />
    </c:otherwise>
</c:choose>
<c:set var="iconResource" value="${cms.vfs.readResource[iconPath]}" />
<c:set var="iconIsValid" value="${not empty iconResource}" />
<c:if test="${setFallback and not iconIsValid}">
    <c:set var="iconResource" value="${cms.vfs.readResource['/system/modules/alkacon.mercury.theme/icons/fa/question-circle.svg']}" />
</c:if>

