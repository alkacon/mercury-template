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
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


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
    <c:choose>
        <c:when test="${type eq 'jsp'}">
            <cms:include file="${plugin.path}" />
        </c:when>
        <c:when test="${type eq 'jsp-nocache'}">
            <cms:include file="${plugin.path}" cacheable="false" />
        </c:when>
        <c:when test="${type eq 'css'}">
            <link href="${plugin.link}${versionDate}" rel="stylesheet"><mercury:nl />
        </c:when>
        <c:when test="${type eq 'js-defer'}">
            <script defer src="${plugin.link}${versionDate}"></script><mercury:nl />
        </c:when>
        <c:when test="${type eq 'js-async'}">
            <script async src="${plugin.link}${versionDate}"></script><mercury:nl />
        </c:when>
    </c:choose>
</c:forEach>
