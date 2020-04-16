<%@ tag pageEncoding="UTF-8"
    display-name="email"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays an email address as link with optional obfuscation." %>


<%@ attribute name="email" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="true"
    description="Value wrapper for the email. Has to use the nested schema of type email." %>

<%@ attribute name="placeholder" fragment="true" required="true"
    description="Text to show in case the Email is obfuscated." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="CSS class added to the a tag surrounding the email address."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:if test="${not empty css}">
    <c:set var="css">class="${css}"</c:set>
</c:if>

<c:choose>
    <c:when test="${email.value.ObfuscateEmail.stringValue}">
        <c:set var="obfuscate" value="true" />
        <c:set var="href">javascript:unobfuscateString('<mercury:obfuscate text="${email.value.Email}"/>', true);</c:set>
        <jsp:invoke fragment="placeholder" var="address" />
    </c:when>
    <c:otherwise>
        <c:set var="href">mailto:${email.value.Email}</c:set>
        <c:set var="address">${email.value.Email}</c:set>
    </c:otherwise>
</c:choose>

<a ${css} href="${href}" title="${address}"><%----%>
    <%-- Set class="email" so that hCard microformat can be supported --%>
    <span ${obfuscate ? '' : 'class="email" itemprop="email"'}>${address}</span><%----%>
</a><%----%>
