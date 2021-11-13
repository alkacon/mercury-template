<%@ tag pageEncoding="UTF-8"
    display-name="link"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a link with optional icon prefix.
    The link text is parsed to check for special 'icon:' and 'id:' parts." %>


<%@ attribute name="link" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="true"
    description="A XML value wrapper that contains the link." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the generated href tag." %>

<%@ attribute name="addSpan" type="java.lang.String" required="false"
    description="If provided, adds a SPAN tag around the generated href tag with a class containing the argument value." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="linkText" value="${link.value.Text}" />
<c:choose>
    <c:when test="${fn:contains(linkText, '//')}">
        <c:set var="linkParts" value="${fn:split(linkText, '//')}" />
        <c:forEach var="linkPart" items="${linkParts}">
            <c:choose>
                <c:when test="${fn:startsWith(linkPart, 'icon:')}">
                    <c:set var="linkIcon"><span class="ls-icon fa fa-${fn:substringAfter(linkPart, 'icon:')}"></span></c:set>
                </c:when>
                <c:when test="${fn:startsWith(linkPart, 'id:')}">
                    <c:set var="linkAttr">id="${fn:substringAfter(linkPart, 'id:')}"</c:set>
                </c:when>
                <c:otherwise>
                     <c:set var="linkMessage"><span>${linkPart}</span></c:set>
                </c:otherwise>
            </c:choose>
        </c:forEach>
    </c:when>
    <c:when test="${fn:startsWith(linkText, 'icon:')}">
        <c:set var="linkIcon"><span class="ls-icon fa fa-${fn:substringAfter(linkText, 'icon:')}"></span></c:set>
    </c:when>
    <c:otherwise>
         <c:set var="linkMessage" value="${linkText}" />
    </c:otherwise>
</c:choose>

<mercury:link link="${link}" css="${css}" attr="${linkAttr}">
    ${empty addSpan ? '' : '<span class=\"'.concat(addSpan).concat('\">')}
    ${linkIcon}${linkMessage}
    ${empty addSpan ? '' : '</span>'}
</mercury:link>

