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

<c:set var="ignore"             value="${cms.requestContext.setUri(param.path)} }" />


<fmt:message var="btnSaveDef" key="msg.page.privacypolicy.button.save" />
<fmt:message var="btnAcceptDef" key="msg.page.privacypolicy.button.accept" />
<fmt:message var="extTitleDef" key="msg.page.privacypolicy.external.title" />
<fmt:message var="extFootDef" key="msg.page.privacypolicy.external.footer" />

<c:set var="bannerHtml">
    <mercury:nl />
    <!DOCTYPE html><%----%>
    <html><%----%>
    <body><%----%>

    <div><%-- Outer DIV required otherwise JavaScript does not work --%>
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
                    <a class="btn btn-accept">${value.AcceptButtonText.isSet ? value.AcceptButtonText : btnAcceptDef}</a><%----%>
                </div><%----%>
            </div><%----%>
        </div><%----%>
    </div><%----%>
    </div><%----%>

    </body><%----%>
    </html><%----%>
    <mercury:nl />
</c:set>

<cms:jsonobject var="policy">
    <cms:jsonvalue key="banner" value="${bannerHtml}" />
    <cms:jsonvalue key="daysA">${value.CookieExpirationDays.useDefault("90")}</cms:jsonvalue>
    <cms:jsonvalue key="daysS">${value.CookieExpirationDaysNoStats.useDefault("1")}</cms:jsonvalue>
    <cms:jsonvalue key="nHead">${value.ExternalTitle.isSet ? value.ExternalTitle : extTitleDef}</cms:jsonvalue>
    <cms:jsonvalue key="nMsg"><fmt:message key="msg.page.privacypolicy.external.message" /></cms:jsonvalue>
    <cms:jsonvalue key="nFoot">${value.ExternalFooter.isSet ? value.ExternalFooter : extFootDef}</cms:jsonvalue>
    <cms:jsonvalue key="togOn"><fmt:message key="msg.page.privacypolicy.toggle.active" /></cms:jsonvalue>
    <cms:jsonvalue key="togOff"><fmt:message key="msg.page.privacypolicy.toggle.inactive" /></cms:jsonvalue>
    <cms:jsonvalue key="togLEx"><fmt:message key="msg.page.privacypolicy.toggle.label.external" /></cms:jsonvalue>
</cms:jsonobject>

<%----%>${policy.verbose}<%----%>

</cms:bundle>
</cms:formatter>
