<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    import="org.opencms.file.*, org.opencms.main.*, org.opencms.util.*"
    trimDirectiveWhitespaces="true" %>

<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="setting"        value="${cms.element.setting}" />
<c:set var="cssWrapper"     value="${setting.cssWrapper.toString}" />
<c:set var="disqusSite"     value="${setting.disqusSite.toString}" />
<c:set var="clickToLoad"    value="${setting.clickToLoad.toBoolean}" />

<c:if test="${empty disqusSite}">
    <c:set var="disqusSite"><cms:property name="disqus.site" file="search" default=""/></c:set>
</c:if>

<m:nl/>
<div class="element type-comments comments-disqus pivot ${cssWrapper}"><%----%>

<c:choose>
    <c:when test="${cms.edited}">
        <div>${cms.enableReload}</div><%----%>
        <m:alert type="error" css="box-noheight">
            <jsp:attribute name="head">
                <fmt:message key="msg.page.comments.edited" />
            </jsp:attribute>
        </m:alert>
    </c:when>
    <c:when test="${empty disqusSite and cms.isEditMode}">
        <m:alert type="warning" css="box-noheight">
            <jsp:attribute name="head">
                <fmt:message key="msg.page.disqus.notset" />
            </jsp:attribute>
        </m:alert>
    </c:when>
    <c:when test="${empty disqusSite}">
        <!-- <fmt:message key="msg.page.disqus.notset" /> --><%----%>
    </c:when>
    <c:otherwise>

        <c:set var="cmsObject" value="${cms.vfs.cmsObject}"/>
        <c:set var="fileName">${cms.requestContext.uri}</c:set>
        <c:choose>
            <c:when test="${cms.detailRequest}">
                <c:set var="pageId" value="${cms.detailContentId}" />
                <c:set var="pageUrl"><%= OpenCms.getLinkManager().getPermalink((CmsObject)pageContext.getAttribute("cmsObject"),(String)pageContext.getAttribute("fileName"), (CmsUUID)pageContext.getAttribute("pageId")) %></c:set>
                <c:set var="pageId" value="${cms.locale}-${pageId}" />
            </c:when>
            <c:otherwise>
                <c:set var="pageId">${cms.locale}-${cms.vfs.readResource[fileName].structureId}</c:set>
                <c:set var="pageUrl"><%= OpenCms.getLinkManager().getOnlineLink((CmsObject)pageContext.getAttribute("cmsObject"),(String)pageContext.getAttribute("fileName")) %></c:set>
            </c:otherwise>
        </c:choose>

        <c:if test="${clickToLoad}">
            <button type="button" class="btn-toggle btn" ><%----%>
                <fmt:message key="msg.page.comments" /><%----%>
            </button><%----%>
        </c:if>

        <%-- Generate Comments data JSON --%>
        <cms:jsonobject var="commentsData">
            <cms:jsonvalue key="site" value="${cms:encode(disqusSite)}" />
            <cms:jsonvalue key="load" value="${clickToLoad}" />
            <cms:jsonvalue key="id" value="${pageId}" />
            <cms:jsonvalue key="url" value="${cms:encode(pageUrl)}" />
        </cms:jsonobject>

        <fmt:message var="cookieMessage" key="msg.page.privacypolicy.message.disqus" />

        <div id="disqus_thread" <%--
        --%><c:if test="${clickToLoad}">style="display: none;" </c:if><%--
            --%>data-comments='${commentsData.compact}'<%--
            --%><m:data-external-cookies message="${cookieMessage}" /><%--
        --%>></div><%----%>

            <m:alert-online showJsWarning="${true}" >
                <jsp:attribute name="text">
                    <fmt:message key="msg.page.noscript.comments" />
                </jsp:attribute>
            </m:alert-online>
    </c:otherwise>
</c:choose>

</div><%----%>
<m:nl/>

</cms:bundle>