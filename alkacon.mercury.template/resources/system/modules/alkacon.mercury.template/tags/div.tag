<%@ tag pageEncoding="UTF-8"
    display-name="div"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Adds either one or two optional div wrapper(s) around a body." %>


<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the 1st (outer) generated div tag." %>

<%@ attribute name="style" type="java.lang.String" required="false"
    description="Optional CSS inline styles added to the 1st (outer) generated div tag." %>

<%@ attribute name="attr" type="java.lang.String" required="false"
    description="Optional attribute(s) added directly to the 1st (outer) generated div tag." %>

<%@ attribute name="css2" type="java.lang.String" required="false"
    description="Optional CSS classes added to the optional 2nd (inner) generated div tag." %>

<%@ attribute name="style2" type="java.lang.String" required="false"
    description="Optional CSS inline styles added to the optional 2nd (inner) generated div tag." %>

<%@ attribute name="attr2" type="java.lang.String" required="false"
    description="Optional attribute(s) added directly to the optional 2nd (inner) generated div tag." %>

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
                <c:choose>
                    <c:when test="${not empty css2 or not empty style2 or not empty attr2}">
                        ${'<div'}
                            <c:if test="${not empty css2}">${' '}class="${css2}"</c:if>
                            <c:if test="${not empty style2}">${' '}style="${style2}"</c:if>
                            <c:if test="${not empty attr2}">${' '}${attr2}</c:if>
                        ${'>'}
                            ${body}
                        ${'</div>'}
                    </c:when>
                    <c:otherwise>
                         ${body}
                    </c:otherwise>
                </c:choose>
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