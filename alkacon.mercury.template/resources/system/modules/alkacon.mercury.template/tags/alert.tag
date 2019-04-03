<%@tag
    pageEncoding="UTF-8"
    display-name="alert"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Displays an alert box for the page editor." %>

<%@ attribute name="type" type="java.lang.String" required="true"
    description="Type of the alert box to display.
    Valid values are 'warning', 'error' and 'editor'." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the generated alert box" %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="If provided, the warning message will only be shown in case this test resolves to 'true'.
    If not provided, it defaults to a test if the page is rendered in edit mode." %>

<%@ attribute name="head" required="false" fragment="true"
    description="Markup inserted as head." %>

<%@ attribute name="text" required="false" fragment="true"
    description="Markup inserted as text." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${empty test ? cms.isEditMode : test}">
    <div class="oct-alert oct-alert-${type}${' '}${css}"><%----%>
        <c:if test="${not empty head}">
            <div class="head"><jsp:invoke fragment="head" /></div><%----%>
        </c:if>
        <c:if test="${not empty text}">
            <div class="text"><jsp:invoke fragment="text" /></div><%----%>
        </c:if>
    </div>
<%----%>
</c:if>


