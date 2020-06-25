<%@page pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="showBanner" value="${param.display ne '0'}" />
<c:set var="ignore"     value="${cms.requestContext.setUri(param.path)}" />
<c:set var="DEBUG"      value="${false}" />

<fmt:message var="btnSaveDef" key="msg.page.privacypolicy.button.banner.save" />
<fmt:message var="btnAcceptDef" key="msg.page.privacypolicy.button.banner.accept" />
<fmt:message var="extTitleDef" key="msg.page.privacypolicy.external.title" />
<fmt:message var="extFootDef" key="msg.page.privacypolicy.external.footer" />

<c:set var="linkDefaultUri" value="${cms.functionDetail['##DEFAULT##']}" />

<c:set var="linkImprintUri" value="${value.LinkImprint.value.URI.toLink}" />
<c:if test="${empty linkImprintUri}">
    <c:set var="linkImprintUri" value="${cms.functionDetail['Imprint']}" />
    <c:if test="${(linkImprintUri eq linkDefaultUri) or fn:contains(linkImprintUri, 'No detail page')}">
        <c:set var="linkImprintUri" value="${null}" />
    </c:if>
</c:if>
<c:if test="${not empty linkImprintUri}">
    <c:set var="hasLinks" value="${true}" />
    <c:set var="linkImprintText" value="${value.LinkImprint.value.Text.toString}" />
    <c:if test="${empty linkImprintText}">
        <fmt:message var="linkImprintText" key="msg.page.privacypolicy.link.imprint" />
    </c:if>
</c:if>

<c:set var="linkPolicyUri" value="${value.LinkPolicy.value.URI.toLink}" />
<c:if test="${empty linkPolicyUri}">
    <c:set var="linkPolicyUri" value="${cms.functionDetail['Datenschutz']}" />
    <c:if test="${(linkPolicyUri eq linkDefaultUri) or fn:contains(linkPolicyUri, 'No detail page')}">
        <c:set var="linkPolicyUri" value="${null}" />
    </c:if>
</c:if>
<c:if test="${not empty linkPolicyUri}">
    <c:set var="hasLinks" value="${true}" />
    <c:set var="linkPolicyText" value="${value.LinkPolicy.value.Text.toString}" />
    <c:if test="${empty linkPolicyText}">
        <fmt:message var="linkPolicyText" key="msg.page.privacypolicy.link.policy" />
    </c:if>
</c:if>

<c:set var="linkLegalUri" value="${value.LinkLegal.value.URI.toLink}" />
<c:if test="${empty linkLegalUri}">
    <c:set var="linkLegalUri" value="${cms.functionDetail['Rechtliche Hinweise']}" />
    <c:if test="${(linkLegalUri eq linkDefaultUri) or fn:contains(linkLegalUri, 'No detail page')}">
        <c:set var="linkLegalUri" value="${null}" />
    </c:if>
</c:if>
<c:if test="${not empty linkLegalUri}">
    <c:set var="hasLinks" value="${true}" />
    <c:set var="linkLegalText" value="${value.LinkLegal.value.Text.toString}" />
    <c:if test="${empty linkLegalText}">
        <fmt:message var="linkLegalText" key="msg.page.privacypolicy.link.legal" />
    </c:if>
</c:if>

<c:if test="${showBanner}">
    <c:set var="bannerHtml">
        <div class="banner"><%----%>
            <div class="container"><%----%>
                <div class="title">${value.Title}</div><%----%>
                <div class="message"><%----%>
                    <div>${value.PolicyText}</div><%----%>
                </div><%----%>
                <div class="selection">
                    <div class="options"><%----%>
                        <label for="use-technical"><%----%>
                            <input id="use-technical" type="checkbox" checked disabled><i></i><%----%>
                            <span><fmt:message key="msg.page.privacypolicy.toggle.label.technical" /></span><%----%>
                        </label><%----%>
                        <label for="use-external"><%----%>
                            <input id="use-external" type="checkbox"><i></i><%----%>
                            <span><fmt:message key="msg.page.privacypolicy.toggle.label.external" /></span><%----%>
                        </label><%----%>
                        <label for="use-statistical"><%----%>
                            <input id="use-statistical" type="checkbox"><i></i><%----%>
                            <span><fmt:message key="msg.page.privacypolicy.toggle.label.statistical" /></span><%----%>
                        </label><%----%>
                    </div><%----%>
                    <div class="buttons"><%----%>
                        <a class="btn btn-save">${value.SaveButtonText.isSet ? value.SaveButtonText : btnSaveDef}</a><%----%>
                        <a class="btn btn-accept">${value.AcceptAllButtonText.isSet ? value.AcceptAllButtonText : btnAcceptDef}</a><%----%>
                    </div><%----%>
                </div><%----%>
                <c:if test="${hasLinks and value.ShowLinks.useDefault('true').toBoolean}">
                    <div class="links"><%----%>
                        <ul><%----%>
                            <c:if test="${not empty linkImprintUri}">
                                <li><a href="${linkImprintUri}">${linkImprintText}</a></li><%----%>
                            </c:if>
                            <c:if test="${not empty linkPolicyUri}">
                                <li><a href="${linkPolicyUri}">${linkPolicyText}</a></li><%----%>
                            </c:if>
                            <c:if test="${not empty linkLegalUri}">
                                <li><a href="${linkLegalUri}">${linkLegalText}</a></li><%----%>
                            </c:if>
                        </ul><%----%>
                    </div><%----%>
                </c:if>
            </div><%----%>
        </div><%----%>
    </c:set>
</c:if>

<cms:jsonobject var="policy">
    <c:if test="${not empty bannerHtml}">
        <cms:jsonvalue key="banner" value="${bannerHtml}" />
    </c:if>
    <cms:jsonvalue key="daysA">${value.CookieExpirationDays.useDefault("90")}</cms:jsonvalue>
    <cms:jsonvalue key="daysS">${value.CookieExpirationDaysNoStats.useDefault("1")}</cms:jsonvalue>
    <cms:jsonvalue key="nHead">${value.ExternalTitle.isSet ? value.ExternalTitle : extTitleDef}</cms:jsonvalue>
    <cms:jsonvalue key="nFoot">${value.ExternalFooter.isSet ? value.ExternalFooter : extFootDef}</cms:jsonvalue>
    <cms:jsonvalue key="nMsg"><fmt:message key="msg.page.privacypolicy.external.message" /></cms:jsonvalue>
    <cms:jsonvalue key="nClick"><fmt:message key="msg.page.privacypolicy.external.clickme" /></cms:jsonvalue>
    <cms:jsonvalue key="togOn"><fmt:message key="msg.page.privacypolicy.toggle.active" /></cms:jsonvalue>
    <cms:jsonvalue key="togOff"><fmt:message key="msg.page.privacypolicy.toggle.inactive" /></cms:jsonvalue>
    <cms:jsonvalue key="togLEx"><fmt:message key="msg.page.privacypolicy.toggle.label.external" /></cms:jsonvalue>
    <cms:jsonvalue key="btAcc"><fmt:message key="msg.page.privacypolicy.button.modal.accept" /></cms:jsonvalue>
    <cms:jsonvalue key="btDis"><fmt:message key="msg.page.privacypolicy.button.modal.dismiss" /></cms:jsonvalue>
    <c:if test="${not empty linkImprintUri}">
        <cms:jsonvalue key="lImp" value="${linkImprintUri}" />
        <cms:jsonvalue key="lImpTxt" value="${linkImprintText}" />
    </c:if>
    <c:if test="${not empty linkPolicyUri}">
        <cms:jsonvalue key="lPol" value="${linkPolicyUri}" />
        <cms:jsonvalue key="lPolTxt" value="${linkPolicyText}" />
    </c:if>
    <c:if test="${not empty linkLegalUri}">
        <cms:jsonvalue key="lLeg" value="${linkLegalUri}" />
        <cms:jsonvalue key="lLegTxt" value="${linkLegalText}" />
    </c:if>
    <c:if test="${DEBUG}">
        <cms:jsonvalue key="_dbgShowLinks" value="${hasLinks and value.ShowLinks.useDefault('true').toBoolean}" />
        <cms:jsonvalue key="_dbgPath" value="${param.path}" />
        <cms:jsonvalue key="_dbgPolicyFile" value="${content.filename}" />
    </c:if>
</cms:jsonobject>

<%----%>${DEBUG ? policy.verbose : policy.compact}<%----%>

</cms:bundle>
</cms:formatter>
