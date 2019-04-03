<%@ tag
    display-name="meta-value"
    pageEncoding="UTF-8"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Normalizes a meta value for the page header by removing HTML, newlines etc." %>

<%@ attribute name="text" type="java.lang.String" required="true"
    description="The text to normalize." %>

<%@ attribute name="trim" type="java.lang.Integer" required="false"
    description="Reduce the text length to a maximum of chars, default is unlimited." %>

<%@ attribute name="keepHtml" type="java.lang.Boolean" required="false"
    description="Keep HTML tags in the text, default is false." %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:if test="${not keepHtml}">
    <c:set var="text" value="${cms:stripHtml(text)}" />
</c:if>
<c:if test="${trim > 0}">
    <c:set var="text" value="${cms:trimToSize(text, trim)}" />
</c:if>
<c:set var="text"><%=
    ((java.lang.String)getJspContext().getAttribute("text")).replaceAll("[\\p{javaWhitespace}|\\s|\\u00A0]+(&nbsp)*|(&nbsp)+", " ").trim()
%></c:set>
<c:out value="${text}" />
