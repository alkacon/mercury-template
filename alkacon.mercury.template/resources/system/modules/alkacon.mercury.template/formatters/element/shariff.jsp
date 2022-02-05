<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<mercury:init-messages reload="true">
<cms:formatter var="content" val="value">

<mercury:setting-defaults content="${content}">

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="ade"                    value="${cms.isEditMode}" />

<c:set var="cssWrapper"             value="${setCssWrapperAll}${' '}${setting.theme}${' '}${setting.orientation}${' '}${setting.verbose}${' '}${setting.shape}" />

<mercury:nl />
<div class="element type-shariff pivot social-icons${fn:replace(cssWrapper, 'default', '')}"><%----%>

    <mercury:heading level="${hsize}" text="${value.Title}" css="heading" ade="${ade}" />

    <c:set var="services">[&quot;${fn:replace(value.Services, ',', '&quot;,&quot;')}&quot;]</c:set>
    <c:set var="mailAttrs" value="" />
    <c:if test="${fn:contains(value.Services.stringValue, 'mail')}">
        <fmt:setLocale value="${cms.locale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <c:set var="mailSubject"><fmt:message key="msg.page.shariff.mailSubject" /></c:set>
            <c:set var="mailBody"><fmt:message key="msg.page.shariff.mailBody" /></c:set>
            <c:if test="${value.MailConfig.value.Mail.isSet}">
                <c:if test="${value.MailConfig.value.Mail.value.Subject.isSet}">
                    <c:set var="mailSubject" value="${value.MailConfig.value.Mail.value.Subject}" />
                </c:if>
                <c:if test="${value.MailConfig.value.Mail.value.Body.isSet}">
                    <c:set var="mailBody" value="${value.MailConfig.value.Mail.value.Body}" />
                </c:if>
            </c:if>
            <c:set var="mailAttrs"><%--
            --%>data-mail-url='mailto:'${' '}<%--
            --%>data-mail-subject='<c:out value="${mailSubject}" />'${' '}<%--
            --%>data-mail-body='<c:out value="${mailBody}" />'<%--
        --%></c:set>
        </cms:bundle>
    </c:if>
    <c:set var="lang">en</c:set>
    <c:if test="${fn:contains('bg,cs,da,de,en,es,fi,fr,hr,hu,it,ja,ko,nl,no,pl,pt,ro,ru,sk,sl,sr,sv,tr,zh', cms.locale.language)}">
        <c:set var="lang">${cms.locale}</c:set>
    </c:if>
    <div class="shariff" data-services="${services}" data-lang="${lang}" ${mailAttrs}></div><%----%>

</div><%----%>
<mercury:nl />

</mercury:setting-defaults>

</cms:formatter>

</mercury:init-messages>