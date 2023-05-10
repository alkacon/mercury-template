<%@ tag pageEncoding="UTF-8"
    display-name="email"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays an email address as link with optional obfuscation." %>


<%@ attribute name="email" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="true"
    description="Value wrapper for the email. Has to use the nested schema of type email." %>

<%@ attribute name="obfuscate" type="java.lang.Boolean" required="false"
    description="Indicates if the email should be obfuscated or not." %>

<%@ attribute name="linkToForm" type="java.lang.String" required="false"
    description="Link to the contact form page, used for email in case sitemap option 'mercury.contact.form' is active." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="CSS class added to the a tag surrounding the email address."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:if test="${not empty css}">
    <c:set var="css">class="${css}"</c:set>
</c:if>

<c:set var="obfuscate" value="${empty obfuscate ? email.value.ObfuscateEmail.toBoolean : obfuscate}" />

<c:choose>
    <c:when test="${(not empty linkToForm) and cms.sitemapConfig.attribute['mercury.contact.form'].toBoolean}">
        <c:set var="obfuscate" value="${false}" />
        <c:set var="href" value="${linkToForm}" />
        <fmt:message var="text" key="msg.page.contact.obfuscatedemail"/>
    </c:when>
    <c:when test="${obfuscate}">
        <c:set var="href">javascript:unobfuscateString('<mercury:obfuscate text="${email.value.Email}"/>', true);</c:set>
        <fmt:message var="text" key="msg.page.contact.obfuscatedemail" />
    </c:when>
    <c:otherwise>
        <c:set var="obfuscate" value="${false}" />
        <c:set var="href">mailto:${email.value.Email}</c:set>
        <c:set var="text" value="${email.value.Email}" />
    </c:otherwise>
</c:choose>

<a ${css} href="${fn:replace(href, ' ','')}" title="${text}"><%----%>
    <%-- Set class="email" so that hCard microformat can be supported --%>
    <span ${obfuscate ? '' : 'class="email"'}>${text}</span><%----%>
</a><%----%>

</cms:bundle>