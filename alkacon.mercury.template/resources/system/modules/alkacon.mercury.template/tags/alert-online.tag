<%@ tag pageEncoding="UTF-8"
    display-name="alert-online"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Displays an alert box that is visible online." %>

<%@ attribute name="addNoscriptTags" type="java.lang.Boolean" required="false"
    description="Controls if the alert is wrapped by noscript tags. Default is 'false'." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes to attach to the heading." %>

<%@ attribute name="attr" type="java.lang.String" required="false"
    description="Attribute(s) to add directly to the generated tag." %>

<%@ attribute name="showJsWarning" type="java.lang.Boolean" required="false"
    description="Controls a default 'JavsScript is required' message is shown as head. Default is 'false'." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="If povided, the warning message will only be shown in case this test resolves to 'true'." %>

<%@ attribute name="head" required="false" fragment="true"
    description="Markup inserted as head." %>

<%@ attribute name="text" required="false" fragment="true"
    description="Markup inserted as text." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>

<c:set var="addNoscriptTags" value="${not empty addNoscriptTags ? addNoscriptTags : showJsWarning}" />

${addNoscriptTags ? '<noscript>' : ''}

<div class="online-warn box${empty css ? '' : ' '.concat(css)}"${empty attr ? '' : ' '.concat(attr)}><%----%>
    <c:if test="${showJsWarning}">
        <fmt:setLocale value="${cms.locale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <div class="head"><fmt:message key="msg.page.javaScript.required" /></div><%----%>
        </cms:bundle>
    </c:if>
    <c:if test="${not empty head}">
        <div class="warn-head h2"><jsp:invoke fragment="head" /></div><%----%>
    </c:if>
    <c:if test="${not empty text}">
        <div class="warn-text"><jsp:invoke fragment="text" /></div><%----%>
    </c:if>
</div><%----%>

${addNoscriptTags ? '</noscript>' : ''}
