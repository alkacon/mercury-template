<%@ tag pageEncoding="UTF-8"
    display-name="alert-meta"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Displays a meta alert box for the page editor." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the generated info alert box" %>

<%@ attribute name="icon" type="java.lang.String" required="false"
    description="Optional icon added to the generated info alert box" %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="If provided, the warning message will only be shown in case this test resolves to 'true'." %>

<%@ attribute name="text" required="false" fragment="true"
    description="Markup inserted as text in the generated marker div." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${empty test ? true : test}">
    <mercury:nl />
    <div class="${empty css ? '' : css.concat(' ')}oct-meta"><%----%>
        <div class="marker"><%----%>
            <c:if test="${not empty icon}">
                <mercury:icon icon="${icon}" tag="span" use="alert-meta" />
            </c:if>
            <jsp:invoke fragment="text" />
        </div><%----%>
    </div><%----%>
    <mercury:nl />
</c:if>


