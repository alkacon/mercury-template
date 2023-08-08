<%@page pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams replaceInvalid="bad_param" />

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

<mercury:privacy-policy-vars setPolicyLinks="${true}" content="${content}">

<c:if test="${showBanner}">
    <c:set var="bannerHtml">
        <div class="banner"><%----%>
            <div class="container"><%----%>
                <div class="title" tabindex="0">${value.Title}</div><%----%>
                <div class="message"><%----%>
                    <div>${value.PolicyText}</div><%----%>
                </div><%----%>
                <form class="selection"><%----%>
                    <div class="options"><%----%>
                        <label for="use-technical"><%----%>
                            <input id="use-technical" type="checkbox" checked disabled><i></i><%----%>
                            <span><fmt:message key="msg.page.privacypolicy.toggle.label.technical" /></span><%----%>
                        </label><%----%>
                        <label for="use-external"><%----%>
                            <input id="use-external" type="checkbox" tabindex="0"><i></i><%----%>
                            <span><fmt:message key="msg.page.privacypolicy.toggle.label.external" /></span><%----%>
                        </label><%----%>
                        <label for="use-statistical"><%----%>
                            <input id="use-statistical" type="checkbox" tabindex="0"><i></i><%----%>
                            <span><fmt:message key="msg.page.privacypolicy.toggle.label.statistical" /></span><%----%>
                        </label><%----%>
                    </div><%----%>
                    <div class="buttons"><%----%>
                        <button class="btn btn-save" type="submit" tabindex="0">${value.SaveButtonText.isSet ? value.SaveButtonText : btnSaveDef}</button><%----%>
                        <button class="btn btn-accept" type="submit" tabindex="0">${value.AcceptAllButtonText.isSet ? value.AcceptAllButtonText : btnAcceptDef}</button><%----%>
                    </div><%----%>
                </form><%----%>
                <button class="btn btn-close" tabindex="0" title="<fmt:message key="msg.page.privacypolicy.btn-close" />">&#x2715</button><%----%>
                <c:if test="${hasPolicyLinks and value.ShowLinks.useDefault('true').toBoolean}">
                    <div class="links"><%----%>
                        <ul><%----%>
                            <c:if test="${not empty policyLinkImprint}">
                                <li><a href="${policyLinkImprint}">${policyTextImprint}</a></li><%----%>
                            </c:if>
                            <c:if test="${not empty policyLinkPolicy}">
                                <li><a href="${policyLinkPolicy}">${policyTextPolicy}</a></li><%----%>
                            </c:if>
                            <c:if test="${not empty policyLinkLegal}">
                                <li><a href="${policyLinkLegal}">${policyTextLegal}</a></li><%----%>
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
    <c:if test="${not empty policyLinkImprint}">
        <cms:jsonvalue key="lImp" value="${policyLinkImprint}" />
        <cms:jsonvalue key="lImpTxt" value="${policyTextImprint}" />
    </c:if>
    <c:if test="${not empty policyLinkPolicy}">
        <cms:jsonvalue key="lPol" value="${policyLinkPolicy}" />
        <cms:jsonvalue key="lPolTxt" value="${policyTextPolicy}" />
    </c:if>
    <c:if test="${not empty policyLinkLegal}">
        <cms:jsonvalue key="lLeg" value="${policyLinkLegal}" />
        <cms:jsonvalue key="lLegTxt" value="${policyTextLegal}" />
    </c:if>
    <c:if test="${DEBUG}">
        <cms:jsonvalue key="_dbgShowLinks" value="${hasPolicyLinks and value.ShowLinks.useDefault('true').toBoolean}" />
        <cms:jsonvalue key="_dbgPath" value="${param.path}" />
        <cms:jsonvalue key="_dbgPolicyFile" value="${content.filename}" />
    </c:if>
</cms:jsonobject>

<%----%>${DEBUG ? policy.verbose : policy.compact}<%----%>

</mercury:privacy-policy-vars>
</cms:bundle>
</cms:formatter>
