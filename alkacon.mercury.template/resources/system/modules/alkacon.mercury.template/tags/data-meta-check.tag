<%@ tag pageEncoding="UTF-8"
    display-name="data-meta-check"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays meta informations in edit mode." %>


<%@ attribute name="label" type="java.lang.String" required="true"
    description="The label to display for the meta info." %>

<%@ attribute name="valid" type="java.lang.Boolean" required="true"
    description="Controls if the meta info is shown as 'valid' or not." %>

<%@ attribute name="optional" type="java.lang.Boolean" required="false"
    description="Controls if the meto info is optional or required (the default). A missig info is shown in red if required, or in orange if optional." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the generated div tag." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="Can be used to defer the decision to actually create the markup around the body to the calling element.
    If not set or 'true', the markup from this tag is generated around the body of the tag.
    Otherwise everything is ignored and just the body of the tag is returned. " %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${empty test or test}">

    <div class="meta-info-check${valid ? ' mi-valid' : ' mi-invalid'}${optional ? ' mi-optional' : ' mi-required'}${empty css ? '' : ' '.concat(css)}"><%----%>
        <m:icon icon="${valid ? 'fa-check-square' : (optional ? 'fa-info-circle' : 'fa-warning')}" inline="${true}" tag="span" /><%----%>
        <span class="mi-label"><%----%>
            <fmt:message key="${label}" />
        </span><%----%>
        <c:choose>
            <c:when test="${not valid and not optional}">
                <span class="mi-notice"><fmt:message key="msg.page.meta-info.required" /></span><%----%>
            </c:when>
            <c:when test="${not valid and optional}">
                <span class="mi-notice"><fmt:message key="msg.page.meta-info.optional" /></span><%----%>
            </c:when>
        </c:choose>
    </div><%----%>

</c:if>
