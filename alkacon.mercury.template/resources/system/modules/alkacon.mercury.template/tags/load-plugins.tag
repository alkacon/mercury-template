<%@ tag pageEncoding="UTF-8"
    display-name="load-plugins"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Loads template plugins." %>

<%@ attribute name="group" type="java.lang.String" required="true"
    description="Group of plugins to load." %>

<%@ attribute name="type" type="java.lang.String" required="false"
    description="How to include the group.
    Valid option are: 'jsp-nocache', 'css', 'js-defer' or 'js-async'.
    If the type is not provided, the group name is used as type." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="type" value="${empty type ? group : type}" />
<c:set var="plugins" value="${cms.plugins[group]}" />

<c:forEach var="plugin" items="${plugins}">
    <c:set var="versionDate" value="" />
    <c:if test="${(type eq 'css') or (type eq 'js-defer') or (type eq 'js-async')}">
        <c:set var="path" value="${plugin.path}" />
        <c:if test="${not empty path}">
            <c:set var="res" value="${cms.wrap[path].toResource}" />
            <c:if test="${not empty res}">
                <c:set var="versionDate" value="?ver=${res.dateLastModified}" />
            </c:if>
        </c:if>
    </c:if>
    <c:if test="${empty macroResolver and ((type eq 'css') or (type eq 'css-inline'))}">
        <%-- Initialize a macro resolver for CSS media queries. --%>
        <m:macro-resolver var="macroResolver" cms="${cms.vfs.cmsObject}" addBreakpoints="${true}" />
    </c:if>
    <c:choose>
        <c:when test="${type eq 'jsp'}">
            <cms:include file="${plugin.path}" />
        </c:when>
        <c:when test="${type eq 'jsp-nocache'}">
            <cms:include file="${plugin.path}" cacheable="false" />
        </c:when>
        <c:when test="${type eq 'css'}">
            <c:set var="mediaQuery" value="${null}" />
            <c:set var="mediaAttr" value="${plugin.attributes['media']}" />
            <c:if test="${not empty mediaAttr}">
                <c:set var="mediaQuery" value="media=\"(${macroResolver.resolveMacros(mediaAttr)})\" " />
            </c:if>
            <link rel="stylesheet" ${mediaQuery}href="${plugin.link}${versionDate}"><m:nl />
            <c:set var="inlineAttr" value="${plugin.attributes['inline']}" />
            <c:if test="${not empty inlineAttr}">
                <m:print delimiter="">
                    <style>${macroResolver.resolveMacros(inlineAttr)}</style>
                </m:print>
            </c:if>
        </c:when>
        <c:when test="${type eq 'css-inline'}">
            <style>${cms.wrap[plugin.path].toResource.content}</style><m:nl />
        </c:when>
        <c:when test="${type eq 'js-defer'}">
            <script defer src="${plugin.link}${versionDate}"></script><m:nl />
        </c:when>
        <c:when test="${type eq 'js-async'}">
            <script async src="${plugin.link}${versionDate}"></script><m:nl />
        </c:when>
    </c:choose>
</c:forEach>
