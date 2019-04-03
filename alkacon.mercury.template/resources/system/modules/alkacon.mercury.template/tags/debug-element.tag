<%@tag
    pageEncoding="UTF-8"
    display-name="nl"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generate debug output for elements." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${cms.isEditMode}">

    <mercury:nl />
    ${'<!--'}
    <mercury:nl />

    <%-- Output all settings --%>
    ${'Settings:'}<mercury:nl />
    <c:forEach var="setting" items="${cms.element.settings}">
        <c:out value="${setting.key}" />: <c:out value="${setting.value}" /><mercury:nl />
    </c:forEach>

    ${'-->'}
    <mercury:nl />
</c:if>