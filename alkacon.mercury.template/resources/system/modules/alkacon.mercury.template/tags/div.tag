<%@ tag
    pageEncoding="UTF-8"
    display-name="link"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Adds an optional div wrapper around a body" %>


<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the generated div tag" %>

<%@ attribute name="style" type="java.lang.String" required="false"
    description="Optional CSS inline styles added to the generated div tag" %>

<%@ attribute name="attr" type="java.lang.String" required="false"
    description="Optional attribute(s) added directly to the generated div tag." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="Can be used to defer the decision to actually create the markup around the body to the calling element.
    If not set or 'true', the markup from this tag is generated around the body of the tag.
    Otherwise everything is ignored and just the body of the tag is returned. " %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<c:choose>
<c:when test="${empty test or test}">

    <jsp:doBody var="body" />

    <c:choose>

        <c:when test="${not empty body}">
            ${'<div'}
                <c:if test="${not empty css}">${' '}class="${css}"</c:if>
                <c:if test="${not empty style}">${' '}style="${style}"</c:if>
                <c:if test="${not empty attr}">${' '}${attr}</c:if>
            ${'>'}
                ${body}
            ${'</div>'}
        </c:when>

        <c:otherwise>
            ${body}
        </c:otherwise>

    </c:choose>

</c:when>
<c:otherwise>
    <%-- Initial test did fail --%>
    <jsp:doBody />
</c:otherwise>
</c:choose>