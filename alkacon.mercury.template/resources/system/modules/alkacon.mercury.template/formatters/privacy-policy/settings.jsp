<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="cookiesAccepted"    value="${cookie.containsKey('privacy-cookies-accepted')}" />
<c:set var="cssWrapper"         value="${cms.element.settings.cssWrapper}" />
<c:set var="title"              value="${value.ToggleLabel.isSet ? value.ToggleLabel.toString : value.Title.toString.concat(':')}" />

<c:set var="declineButtonText">
    <c:choose>
        <c:when test="${value.DeclineButtonText.isSet}">${value.DeclineButtonText.toString}</c:when>
        <c:otherwise><fmt:message key="label.PrivacyPolicy.DeclineButtonText.default" /></c:otherwise>
    </c:choose>
</c:set>

<c:set var="cookieDays"         value="${value.CookieExpirationDays.isSet ? value.CookieExpirationDays.toInteger : 0}" />
<c:if test="${cookieDays > 0}">
    <c:set var="acceptData"> data-days="${cookieDays}"</c:set>
</c:if>

<mercury:nl />
<div class="element type-privacy-policy pp-settings"><%----%>

<div class="pp-toggle animated ${cssWrapper}"><%----%>
    <input id="privacy-policy-toggle" type="checkbox" class="toggle-check" ${cookiesAccepted ? 'checked' : ''}${acceptData}><%----%>
    <label for="privacy-policy-toggle" class="toggle-label">
        <span class="toggle-text">${title}</span><%----%>
        <span class="toggle-box"><%----%>
            <span class="toggle-inner" <%--
            --%>data-checked="${value.AcceptButtonText}" <%--
            --%>data-unchecked="${declineButtonText}"><%----%>
            </span><%----%>
            <span class="toggle-slider"></span><%----%>
        </span><%----%>
    </label><%----%>
</div><%----%>

</div><%----%>
<mercury:nl />

</cms:bundle>
</cms:formatter>