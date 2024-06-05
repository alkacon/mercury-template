<%@tag pageEncoding="UTF-8"
    display-name="nl"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generate debug output for elements." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${cms.isEditMode}">

    <m:nl />
    ${'<!--'}
    <m:nl />

    <%-- Output all settings --%>
    ${'Settings:'}<m:nl />
    <c:forEach var="setting" items="${cms.element.settings}">
        <c:out value="${setting.key}" />: <c:out value="${setting.value}" /><m:nl />
    </c:forEach>

    ${'-->'}
    <m:nl />
</c:if>