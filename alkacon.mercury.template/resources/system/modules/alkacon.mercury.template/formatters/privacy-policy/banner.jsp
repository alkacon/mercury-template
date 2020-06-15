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

<c:set var="disabledMessage"    value="${fn:replace(cms:stripHtml(value.DisabledMessage), '\"', '')}" />
<c:set var="ignore"             value="${cms.requestContext.setUri(param.path)} }" />

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
                    <c:if test="${value.DeclineButtonText.isSet}"><%--
                    --%><a class="btn btn-save">${value.DeclineButtonText}</a><%--
                --%></c:if><%--
                --%><a class="btn btn-accept">${value.AcceptButtonText}</a><%----%>
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
    <cms:jsonvalue key="togA"><fmt:message key="msg.page.privacypolicy.toggle.active" /></cms:jsonvalue>
    <cms:jsonvalue key="togS"><fmt:message key="msg.page.privacypolicy.toggle.inactive" /></cms:jsonvalue>
    <cms:jsonvalue key="togLEx"><fmt:message key="msg.page.privacypolicy.toggle.label.external" /></cms:jsonvalue>
    <cms:jsonvalue key="daysA">${content.value.CookieExpirationDays}</cms:jsonvalue>
    <cms:jsonvalue key="daysS">1</cms:jsonvalue>
    <cms:jsonvalue key="nHead"><fmt:message key="msg.page.privacypolicy.notice.heading" /></cms:jsonvalue>
    <cms:jsonvalue key="nMsg"><fmt:message key="msg.page.privacypolicy.notice.message" /></cms:jsonvalue>
    <cms:jsonvalue key="nFoot">${content.value.DisabledMessage}</cms:jsonvalue>
    <cms:jsonvalue key="banner" value="${bannerHtml}" />
</cms:jsonobject>

<%----%>${policy.verbose}<%----%>

</cms:bundle>
</cms:formatter>
