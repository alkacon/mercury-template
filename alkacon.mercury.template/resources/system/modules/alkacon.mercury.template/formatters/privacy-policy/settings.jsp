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

<c:set var="privacyCookie"              value="${cookie['privacy-options'].value}" />
<c:set var="cookiesAcceptedTechnical"   value="${fn:contains(privacyCookie, '|technical')}" />
<c:set var="cookiesAcceptedExternal"    value="${fn:contains(privacyCookie, '|external')}" />
<c:set var="cookiesAcceptedStatistical" value="${fn:contains(privacyCookie, '|statistical')}" />
<c:set var="cssWrapper"                 value="${cms.element.settings.cssWrapper}" />

<mercury:nl />
<div class="element type-privacy-policy pp-settings ${cssWrapper}"><%----%>

<div class="pp-toggle pp-toggle-technical animated"><%----%>
    <input id="cookies-accepted-technical" type="checkbox" class="toggle-check" checked disabled><%----%>
    <label for="cookies-accepted-technical" class="toggle-label">
        <span class="toggle-box"><%----%>
            <span class="toggle-inner" <%--
            --%>data-checked="<fmt:message key="msg.page.privacypolicy.toggle.active" />" <%--
            --%>data-unchecked="<fmt:message key="msg.page.privacypolicy.toggle.inactive" />"><%----%>
            </span><%----%>
            <span class="toggle-slider"></span><%----%>
        </span><%----%>
    </label><%----%>
    <div class="toggle-text"><fmt:message key="msg.page.privacypolicy.toggle.label.technical" /></div><%----%>
</div><%----%>

<div class="pp-toggle pp-toggle-external animated"><%----%>
    <input id="cookies-accepted-external" type="checkbox" class="toggle-check optional"${cookiesAcceptedExternal ? ' checked' : ''}><%----%>
    <label for="cookies-accepted-external" class="toggle-label">
        <span class="toggle-box"><%----%>
            <span class="toggle-inner" <%--
            --%>data-checked="<fmt:message key="msg.page.privacypolicy.toggle.active" />" <%--
            --%>data-unchecked="<fmt:message key="msg.page.privacypolicy.toggle.inactive" />"><%----%>
            </span><%----%>
            <span class="toggle-slider"></span><%----%>
        </span><%----%>
    </label><%----%>
    <div class="toggle-text"><fmt:message key="msg.page.privacypolicy.toggle.label.external" /></div><%----%>
</div><%----%>

<div class="pp-toggle pp-toggle-statistical animated"><%----%>
    <input id="cookies-accepted-statistical" type="checkbox" class="toggle-check optional"${cookiesAcceptedStatistical ? ' checked' : ''}><%----%>
    <label for="cookies-accepted-statistical" class="toggle-label">
        <span class="toggle-box"><%----%>
            <span class="toggle-inner" <%--
            --%>data-checked="<fmt:message key="msg.page.privacypolicy.toggle.active" />" <%--
            --%>data-unchecked="<fmt:message key="msg.page.privacypolicy.toggle.inactive" />"><%----%>
            </span><%----%>
            <span class="toggle-slider"></span><%----%>
        </span><%----%>
    </label><%----%>
    <div class="toggle-text"><fmt:message key="msg.page.privacypolicy.toggle.label.statistical" /></div><%----%>
</div><%----%>

</div><%----%>
<mercury:nl />

</cms:bundle>
</cms:formatter>