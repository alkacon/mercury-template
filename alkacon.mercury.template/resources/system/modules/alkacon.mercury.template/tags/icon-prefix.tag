<%@ tag pageEncoding="UTF-8"
    display-name="icon-prefix"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays a text label with optional icon based on the Font-Awesome library." %>


<%@ attribute name="icon" type="java.lang.String" required="true"
    description="The icon to show." %>

<%@ attribute name="text" required="false" fragment="true"
    description="The text label to show." %>

<%@ attribute name="showIcon" type="java.lang.Boolean" required="true"
    description="If 'true' then show the icon." %>

<%@ attribute name="showText" type="java.lang.Boolean" required="true"
    description="If 'true' then show the text." %>

<%@ attribute name="icontitle" required="false" fragment="true"
    description="The aria-label attribute to add to the icon. Uses the value of 'text' if not set." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:if test="${((not empty icon) and ('none' ne icon)) or (not empty text)}">

    <jsp:invoke fragment="text" var="textLabel" />
    <span class="icon-label"><%----%>
        <c:if test="${showIcon}">
            <jsp:invoke fragment="icontitle" var="iconLabel" />
            <c:if test="${not showText and empty iconLabel}">
                <c:set var="iconLabel" value="${textLabel}" />
            </c:if>
            <mercury:icon icon="${icon}" tag="span" ariaLabel="${iconLabel}" />
        </c:if>
        <c:if test="${showText}">
            ${textLabel}
        </c:if>
    </span><%----%>

</c:if>