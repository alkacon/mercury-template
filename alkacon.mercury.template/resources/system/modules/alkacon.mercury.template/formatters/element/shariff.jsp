<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<mercury:init-messages reload="true">
<cms:formatter var="content" val="value">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />

<c:set var="cssWrapper">
    ${cssWrapper}
    ${' '}${setting.theme}
    ${' '}${setting.orientation}
    ${' '}${setting.verbose}
    ${' '}${setting.shape}
</c:set>

${nl}
<div class="element type-shariff social-icons ${fn:replace(cssWrapper, 'default', '')}"><%----%>

    <mercury:heading level="${hsize}" text="${value.Title}" css="heading" />

    <c:set var="services">[&quot;${fn:replace(value.Services, ',', '&quot;,&quot;')}&quot;]</c:set>
    <c:set var="mailAttrs" value="" />
    <c:if test="${fn:contains(value.Services.stringValue, 'mail')}">
        <c:if test="${value.MailConfig.isSet}">
            <c:choose>
                <c:when test="${value.MailConfig.value.FormLink.isSet}">
                    <c:set var="mailAttrs">data-mail-url="<cms:link>${value.MailConfig.value.FormLink}</cms:link>"</c:set>
                </c:when>
                <c:when test="${value.MailConfig.value.Mail.isSet}">
                    <c:set var="mailAttrs">data-mail-url="mailto:${value.MailConfig.value.Mail.value.MailTo}"</c:set>
                    <c:if test="${value.MailConfig.value.Mail.value.Subject.isSet}">
                        <c:set var="mailAttrs">${mailAttrs}${' '}data-mail-subject="${value.MailConfig.value.Mail.value.Subject}"</c:set>
                    </c:if>
                    <c:if test="${value.MailConfig.value.Mail.value.Body.isSet}">
                        <c:set var="mailAttrs">${mailAttrs}${' '}data-mail-body="${value.MailConfig.value.Mail.value.Body}"</c:set>
                    </c:if>
                </c:when>
            </c:choose>
        </c:if>
    </c:if>
    <c:set var="lang">en</c:set>
    <c:if test="${fn:contains('bg,cs,da,de,en,es,fi,fr,hr,hu,it,ja,ko,nl,no,pl,pt,ro,ru,sk,sl,sr,sv,tr,zh', cms.locale.language)}">
        <c:set var="lang">${cms.locale}</c:set>
    </c:if>
    <div class="shariff" data-services="${services}" data-lang="${lang}" ${mailAttrs}></div><%----%>

</div><%----%>
${nl}

</cms:formatter>

</mercury:init-messages>