<%@ tag pageEncoding="UTF-8"
    display-name="load-plugins"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Loads template plugins." %>

<%@ attribute name="group" type="java.lang.String" required="true"
    description="Group of plugins to load." %>

<%@ attribute name="type" type="java.lang.String" required="true"
    description="How to include the group." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="plugins" value="${cms.plugins[group]}" />
<c:forEach var="plugin" items="${plugins}">
    <c:choose>
        <c:when test="${type eq 'jsp-nocache'}">
            <cms:include file="${plugin.link}" cacheable="false" />
        </c:when>
        <c:when test="${type eq 'js-async'}">
            <script async src="${plugin.link}"></script><mercury:nl />
        </c:when>
        <c:when test="${type eq 'js'}">
            <script src="${plugin.link}"></script><mercury:nl />
        </c:when>
        <c:when test="${type eq 'css'}">
            <link href="${plugin.link}" rel="stylesheet"><mercury:nl />
        </c:when>
    </c:choose>
</c:forEach>
