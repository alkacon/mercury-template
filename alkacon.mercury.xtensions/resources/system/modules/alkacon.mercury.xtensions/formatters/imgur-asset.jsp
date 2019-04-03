<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<mercury:init-messages reload="true">

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.xtensions.imgur-asset.messages">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper.toString}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="effect"                 value="${setting.effect.isSetNotNone ? setting.effect.toString : null}" />
<c:set var="showImageSubtitle"      value="${setting.showImageSubtitle.toBoolean}"/>
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}"/>
<c:set var="showText"               value="${setting.showText.toBoolean}"/>
<c:set var="showLink"               value="${setting.showLink.toBoolean}"/>
<c:set var="useImgurTitle"          value="${setting.useImgurTitle.toBoolean}" />

<c:set var="image"                  value="${value.Item}" />
<c:set var="imageLink"              value="${image.value.Id}" />
<c:set var="imageTitleCopyright"    value="${image.value.Title}" />

<mercury:piece
    cssWrapper="element type-imgur-section piece ${cssWrapper}${' '}${effect}"
    pieceLayout="${1}">

    <jsp:attribute name="heading">
        <c:if test="${showImageSubtitle}">
            <c:choose>
                <c:when test="${not useImgurTitle}">
                    <mercury:heading level="${hsize}" text="${value.Title}" css="subtitle" ade="${false}" />
                </c:when>
                <c:otherwise>
                    <mercury:heading level="${hsize}" text="${value.Item.value.Title}" css="subtitle" ade="${false}" />
                </c:otherwise>
            </c:choose>
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="visual">
        <c:choose>
            <c:when test="${not empty imageLink}">
                <div class="effect-box"><%----%>
                    <div class="image-src-box"><%----%>
                        <img src="${imageLink}" alt="${imageTitleCopyright}" class="animated" ><%----%>
                    </div><%----%>
                    <mercury:nl />
                    <c:if test="${showImageCopyright}">
                        <div class="copyright"><%----%>
                            <div class="text">Courtesy of Imgur</div><%----%>
                        </div><%----%>
                        <mercury:nl />
                    </c:if>
                </div><%----%>
                <mercury:nl />
            </c:when>
            <c:otherwise>
                <c:if test="${cms.isEditMode}">
                    <fmt:setLocale value="${cms.workplaceLocale}" />
                    <cms:bundle basename="alkacon.mercury.template.messages">
                        <mercury:alert type="warning">
                            <jsp:attribute name="head">
                                <fmt:message key="msg.page.noImage" />
                            </jsp:attribute>
                            <jsp:attribute name="text">
                                <fmt:message key="msg.page.noImage.hint" />
                            </jsp:attribute>
                        </mercury:alert>
                    </cms:bundle>
                </c:if>
            </c:otherwise>
        </c:choose>
    </jsp:attribute>

    <jsp:attribute name="text">
        <c:if test="${showText}">
            <c:choose>
                <c:when test="${value.Text.isSet}">
                    <div class="text" ${value.Text.rdfaAttr}><%----%>
                        ${value.Text}
                    </div><%----%>
                </c:when>
                <c:otherwise>
                    <div class="text"><%----%>
                        ${value.Item.value.Description}
                    </div>
                </c:otherwise><%----%>
            </c:choose>
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="link">
        <c:if test="${showLink}">
            <mercury:link link="${value.Item.value.Data}" css="btn" newWin="${true}" >
                <fmt:message key="msg.page.imgur-section.link" />
            </mercury:link>
        </c:if>
    </jsp:attribute>

</mercury:piece>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>