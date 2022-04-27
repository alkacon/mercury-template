<%@ tag pageEncoding="UTF-8"
    display-name="privacy-policy-settings"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays the 'privacy policy' settings." %>


<%@ attribute name="cssWrapper" type="java.lang.String" required="true"
    description="The CSS wrapper class to use." %>

<%@ attribute name="policyFile" type="java.lang.String" required="false"
    description="The privacy policy configuration file." %>

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
<mercury:nl />

<div class="pp-toggle pp-toggle-technical animated"><%----%>
    <input id="cookies-accepted-technical" type="checkbox" class="toggle-check" checked disabled><%----%>
    <label for="cookies-accepted-technical" class="toggle-label"><%----%>
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
<mercury:nl />

<div class="pp-toggle pp-toggle-external animated"><%----%>
    <input id="cookies-accepted-external" type="checkbox" class="toggle-check optional"><%----%>
    <label for="cookies-accepted-external" class="toggle-label"><%----%>
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
<mercury:nl />

<div class="pp-toggle pp-toggle-statistical animated"><%----%>
    <input id="cookies-accepted-statistical" type="checkbox" class="toggle-check optional"><%----%>
    <label for="cookies-accepted-statistical" class="toggle-label"><%----%>
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
<mercury:nl />

<c:if test="${not empty contentPropertiesSearch and not empty policyFile and policyFile ne 'none'}">
    <c:set var="matomoJst" value="${contentPropertiesSearch['matomo.jst']}" />
    <c:set var="useMatomoJst" value="${not empty matomoJst ? fn:contains(matomoJst, 'true') : false}" />
    <c:set var="useMatomoDnt" value="${not empty matomoJst ? fn:contains(matomoJst, 'dnt') : false}" />
    <c:set var="matomoUrl"  value="${contentPropertiesSearch['matomo.url']}" />
    <c:set var="hasMatomoUrl" value="${not empty matomoUrl ? matomoUrl ne 'none' : false}" />
    <c:set var="matomoId"  value="${contentPropertiesSearch['matomo.id']}" />
    <c:set var="hasMatomoId" value="${not empty matomoId ? matomoId ne 'none' : false}" />

    <c:if test="${useMatomoJst and hasMatomoUrl and hasMatomoId}">

        <c:if test="${not fn:startsWith(policyFile, '/')}">
            <c:set var="subSitePolicy" value="${cms.subSitePath.concat('.content/').concat(policyFile)}" />
            <c:set var="sitePolicy" value="${'/.content/'.concat(policyFile)}" />
            <c:set var="policyFile" value="${cms.vfs.exists[subSitePolicy] ? subSitePolicy : sitePolicy}" />
        </c:if>
        <c:set var="policyRes" value="${cms.vfs.readXml[policyFile]}" />

        <c:choose>
            <c:when test="${not cms.isOnlineProject}">
                <div class="pp-element box not-online"><%----%>
                    <fmt:message key="msg.page.privacypolicy.Matomo.notonline" />
                </div><%----%>
            </c:when>
            <c:otherwise>
                <cms:jsonobject var="matomoJst">
                    <fmt:message key="msg.page.privacypolicy.Matomo.JsTrackingText" var="JsTrackingText" />
                    <cms:jsonvalue key="jsttext">${policyRes.value.MatomoPolicy.value.JsTrackingText.isSet ? policyRes.value.MatomoPolicy.value.JsTrackingText : JsTrackingText}</cms:jsonvalue>
                    <fmt:message key="msg.page.privacypolicy.Matomo.JsTrackingOn" var="JsTrackingOn" />
                    <cms:jsonvalue key="jston">${policyRes.value.MatomoPolicy.value.JsTrackingOn.isSet ? policyRes.value.MatomoPolicy.value.JsTrackingOn : JsTrackingOn}</cms:jsonvalue>
                    <fmt:message key="msg.page.privacypolicy.Matomo.JsTrackingOff" var="JsTrackingOff" />
                    <cms:jsonvalue key="jstoff">${policyRes.value.MatomoPolicy.value.JsTrackingOff.isSet ? policyRes.value.MatomoPolicy.value.JsTrackingOff : JsTrackingOff}</cms:jsonvalue>
                    <c:if test="${useMatomoDnt}">
                        <fmt:message key="msg.page.privacypolicy.Matomo.DntText" var="DntText" />
                        <cms:jsonvalue key="dnttext">${policyRes.value.MatomoPolicy.value.DntText.isSet ? policyRes.value.MatomoPolicy.value.DntText : DntText}</cms:jsonvalue>
                    </c:if>
                </cms:jsonobject>
                <div id="pp-matomo-jst" class="pp-element box" data-jst='${matomoJst.compact}'><%----%>
                    <div class="jst-msg"></div><%----%>
                    <div class="jst-btn"><%----%>
                        <label for="pp-matomo-optout" class="checkbox"><%----%>
                            <input type="checkbox" id="pp-matomo-optout" /><%----%>
                            <i></i><%----%>
                            <span></span><%----%>
                        </label><%----%>
                    </div><%----%>
                </div><%----%>
            </c:otherwise>
        </c:choose>
        <mercury:nl />

    </c:if>
</c:if>

</div><%----%>
<mercury:nl />

</cms:bundle>