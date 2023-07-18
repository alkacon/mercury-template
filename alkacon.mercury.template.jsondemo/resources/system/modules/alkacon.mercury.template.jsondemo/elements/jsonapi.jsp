<%@page import="java.util.Map"%>
<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>

<jsp:useBean id="uris" class="java.util.HashMap" />
<c:set target="${uris}" property="demo11" value="/json/?wrapper=false" />
<c:set target="${uris}" property="demo12" value="/json/sites/default/mercury-demo/?wrapper=false" />
<c:set target="${uris}" property="demo13" value="/json/sites/default/mercury-demo/.content/?wrapper=false" />
<c:set target="${uris}" property="demo14" value="/workplace#!explorer/9c8c654b-0503-11ec-bbda-0242ac11002b!!/sites/default!!/mercury-demo/.content/!!" />
<c:set target="${uris}" property="demo21" value="/json/sites/default/mercury-json/.content/list-m/list_00001.xml?content&wrapper=false&locale=en&fallbackLocale&rows=1" />
<c:set target="${uris}" property="demo31" value="/json/sites/default/mercury-json/demo-3/page-editor/index.html" />
<c:set var="exists" value="${not empty uris.get(param.uri)}" />
<c:choose>
    <c:when test="${exists}">
        <c:set var="uri">
            <cms:link>${uris.get(param.uri)}</cms:link>
        </c:set>
        <%
        String uri = (String)pageContext.getAttribute("uri");
        response.sendRedirect(uri);
        %>
    </c:when>
    <c:otherwise>
        {"error","not found"}
    </c:otherwise>
</c:choose>