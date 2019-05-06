<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />

<c:set var="currentSite"            value="${cms.vfs.readSubsiteFor(cms.requestContext.uri)}" />

<c:if test="${cms.detailRequest}">
    <c:set var="sourceSite"         value="${cms.vfs.readSubsiteFor(cms.detailContent.sitePath)}" />
</c:if>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<mercury:nl />
<c:choose>
    <c:when test="${(not empty sourceSite) and not (currentSite eq sourceSite)}">
        <c:set var="sourceSiteProps" value="${cms.vfs.readProperties[sourceSite]}" />
        <c:set var="sourceSiteName" value="${not empty sourceSiteProps['teamplte.sitename'] ? sourceSiteProps['teamplte.sitename'] : sourceSiteProps['Title'] }" />
        <div class="element type-sourcesite ${cssWrapper}"><%----%>
            <fmt:message key="msg.page.sourcesite.other">
                <fmt:param><a href="${cms.vfs.link[sourceSite.rootPath]}">${sourceSiteName}</a></fmt:param>
            </fmt:message>
        </div><%----%>
    </c:when>
    <c:when test="${empty sourceSite and cms.isEditMode}">
        <div class="element type-sourcesite oct-meta ${cssWrapper}"><%----%>
            <div class="marker"><%----%>
                <fmt:message key="msg.page.sourcesite.unknown" /><%----%>
            </div><%----%>
        </div><%----%>
    </c:when>
    <c:when test="${cms.isEditMode}">
        <div class="element type-sourcesite oct-meta ${cssWrapper}"><%----%>
            <div class="marker"><%----%>
                <fmt:message key="msg.page.sourcesite.same" /><%----%>
            </div><%----%>
        </div><%----%>
    </c:when>
    <c:otherwise>
        <!-- <fmt:message key="msg.page.sourcesite.same" />  --><%----%>
    </c:otherwise>
</c:choose>
<mercury:nl />

</cms:bundle>
