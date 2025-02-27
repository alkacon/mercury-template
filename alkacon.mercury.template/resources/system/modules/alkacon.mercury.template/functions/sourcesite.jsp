<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>
<%@page import="org.opencms.main.OpenCms" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />

<c:set var="currentSite"            value="${cms.vfs.readSubsiteFor(cms.requestContext.uri)}" />
<c:if test="${cms.detailRequest}">
    <c:set var="sourceSite"         value="${cms.vfs.readSubsiteFor(cms.detailContent.sitePath)}" />
</c:if>
<c:set var="sharedFolder"           value="${OpenCms.getSiteManager().getSharedFolder()}" />
<c:set var="isSharedFolder"         value="${fn:startsWith(sourceSite.rootPath, sharedFolder)}" />
<c:if test="${isSharedFolder}">
    <c:set var="sourceSiteProp"     value="${cms.vfs.propertySearch[sourceSite.rootPath]['mercury.sourcesite']}" />
    <c:if test="${not empty sourceSiteProp and fn:startsWith(sourceSiteProp, cms.site.siteRoot)}">
        <c:set var="sourceSiteProp" value="${fn:substringAfter(sourceSiteProp, cms.site.siteRoot)}" />
    </c:if>
    <c:set var="sourceSite"         value="${empty sourceSiteProp ? '' : cms.vfs.readSubsiteFor(sourceSiteProp)}" />
</c:if>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:choose>
    <c:when test="${(not empty sourceSite) and not (currentSite eq sourceSite)}">
        <c:set var="sourceSiteProps" value="${cms.vfs.readProperties[sourceSite]}" />
        <c:set var="sourceSiteName" value="${not empty sourceSiteProps['mercury.sitename'] ? sourceSiteProps['mercury.sitename'] : sourceSiteProps['Title'] }" />
        <m:nl />
        <div class="element type-sourcesite pivot ${cssWrapper}"><%----%>
            <fmt:message key="msg.page.sourcesite.other">
                <fmt:param><a href="${cms.vfs.link[sourceSite.rootPath]}">${sourceSiteName}</a></fmt:param>
            </fmt:message>
        </div><%----%>
        <m:nl />
    </c:when>
    <c:when test="${isSharedFolder and empty sourceSite and cms.isEditMode}">
        <m:alert-meta icon="info-circle" css="element type-sourcesite pivot ${cssWrapper}">
            <jsp:attribute name="text">
                <fmt:message key="msg.page.sourcesite.shared" />
            </jsp:attribute>
        </m:alert-meta>
    </c:when>
    <c:when test="${empty sourceSite and cms.isEditMode}">
        <m:alert-meta icon="info-circle" css="element type-sourcesite pivot ${cssWrapper}">
            <jsp:attribute name="text">
                <fmt:message key="msg.page.sourcesite.unknown" />
            </jsp:attribute>
        </m:alert-meta>
    </c:when>
    <c:when test="${cms.isEditMode}">
        <m:alert-meta icon="info-circle" css="element type-sourcesite pivot ${cssWrapper}">
            <jsp:attribute name="text">
                <fmt:message key="msg.page.sourcesite.same" />
            </jsp:attribute>
        </m:alert-meta>
    </c:when>
</c:choose>

</cms:bundle>
