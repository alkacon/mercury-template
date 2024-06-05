<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true" %>
<%@page import="alkacon.mercury.webform.CmsFormDataAjaxHandler" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />

<c:if test="${not cms.isOnlineProject}">
<fmt:setLocale value="${cms.locale}"/>
<cms:bundle basename="alkacon.mercury.template.messages">

<%
    CmsFormDataAjaxHandler formDataHandler = new CmsFormDataAjaxHandler(pageContext, request, response);
    request.setAttribute("formDataHandler", formDataHandler);
    formDataHandler.deleteSubmissions(request.getParameter("uuid"), request.getParameter("formdata"));
%>

<c:choose>
    <c:when test="${not empty formDataHandler.error}">
        <div class="subelement oct-meta-info box"><%----%>
            <fmt:message key="${formDataHandler.error}" />
        </div><%----%>
    </c:when>
    <c:when test="${not empty formDataHandler.info}">
        <div class="subelement box"><%----%>
            <fmt:message key="${formDataHandler.info}" />
        </div><%----%>
    </c:when>
</c:choose>

</cms:bundle>
</c:if>