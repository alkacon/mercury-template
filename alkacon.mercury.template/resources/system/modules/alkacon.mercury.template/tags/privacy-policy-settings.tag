<%@ tag pageEncoding="UTF-8"
    display-name="privacy-policy-settings"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays the 'privacy policy' settings." %>


<%@ attribute name="cssWrapper" type="java.lang.String" required="true"
    description="The CSS wrapper class to use." %>

<%@ attribute name="contentPropertiesSearch" type="java.util.Map" required="false"
    description="The properties read from the URI resource with search." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

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
    <input id="cookies-accepted-external" type="checkbox" class="toggle-check optional"><%----%>
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
    <input id="cookies-accepted-statistical" type="checkbox" class="toggle-check optional"><%----%>
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

<c:if test="${not empty contentPropertiesSearch}">
<c:set var="matomoUrl"  value="${contentPropertiesSearch['matomo.url']}" />
<c:set var="hasMatomoUrl" value="${not empty matomoUrl ? matomoUrl ne 'none' : false}" />

<c:if test="${hasMatomoUrl}">
    <div class="pp-element pp-matomo box"><%----%>
    <c:choose>
        <c:when test="${not cms.isOnlineProject}">
            <div class="not-online"><%----%>
                <fmt:message key="msg.page.privacypolicy.matomo.label.notonline" />
            </div><%----%>
        </c:when>
        <c:otherwise>
            <div class="optout-form"><%----%>
                <div><%----%>
                    <fmt:message key="msg.page.privacypolicy.matomo.label.optoutmessage" />
                </div><%----%>
                <div><%----%>
                    <input type="checkbox" id="pp-matomo-optout" <%--
                    --%>data-msg='{"msgin":"<fmt:message key="msg.page.privacypolicy.matomo.label.optedin" />",<%--
                             --%> "msgout":"<fmt:message key="msg.page.privacypolicy.matomo.label.optedout" />"}' /><%----%>
                    <label for="pp-matomo-optout"><span></span></label><%----%>
                </div><%----%>
            </div><%----%>
        </c:otherwise>
    </c:choose>
    </div><%----%>
    <mercury:nl />
</c:if>
</c:if>

</div><%----%>
<mercury:nl />

</cms:bundle>