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


<cms:secureparams />
<mercury:init-messages>

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.media.messages">

<c:set var="setting"            value="${cms.element.setting}" />
<c:set var="squareGrid"         value="${setting.squareGrid.toString}" />
<c:set var="firstSquare"        value="${setting.firstSquare.toString}" />
<c:set var="showPreface"        value="${setting.showPreface.toBoolean}" />
<c:set var="dateFormat"         value="${setting.dateFormat}"/>
<c:set var="ratio"              value="${setting.imageRatio.toString}"/>
<c:set var="animationClass"     value="${setting.effect.isSetNotNone ? setting.effect.toString.concat(' effect-box') : ''}" />

<c:set var="title"              value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />

<c:if test="${showPreface}">
    <c:set var="preface"        value="${value['TeaserData/TeaserPreface'].isSet ? value['TeaserData/TeaserPreface'] : value.Preface}" />
    <c:set var="minHeight"      value="min-height show-preface" />
</c:if>

<mercury:media-vars content="${content}" ratio="${ratio}">

<c:set var="imgRatio" value="${ratio}" />

<c:if test="${Headline.isSet and (titleOption eq 'showHeadline')}">
    <c:set var="headline">${Headline}</c:set>
</c:if>

<c:if test="${dateFormat.isSetNotNone and value.Date.isSet}">
    <c:set var="dateStr"><mercury:instancedate date="${value.Date.toInstanceDate}" format="${dateFormat.toString}" /></c:set>
    <c:if test="${empty minHeight}"><c:set var="minHeight" value="min-height" /></c:if>
</c:if>

<c:choose>
    <c:when test="${squareGrid eq '4'}">
        <c:set var="tileClassLarge" value="square-xs-12 square-xl-6" />
        <c:set var="tileClassSmall" value="square-xs-12 square-md-6 square-xl-3" />
    </c:when>
    <c:otherwise>
        <c:set var="tileClassLarge" value="square-xs-12 square-xl-8" />
        <c:set var="tileClassSmall" value="square-xs-12 square-md-6 square-xl-4" />
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${firstSquare eq 'firstOnlyLarge'}">
        <c:set var="firstLarge" value="${(param.resultPage eq 1) and (param.resultOnPage eq 1)}" />
    </c:when>
    <c:when test="${firstSquare eq 'firstOnPageLarge'}">
        <c:set var="firstLarge" value="${param.resultOnPage eq 1}" />
    </c:when>
    <c:when test="${firstSquare eq 'firstOnPageFlip'}">
        <c:set var="firstLarge" value="${param.resultOnPage eq 1}" />
        <c:set var="firstOnPageFlip" value="${(param.resultPage % 2) eq 0}" />
    </c:when>
</c:choose>

<c:if test="${ratio eq '16-9'}"><c:set var="imgRatio" value="1600-920" /></c:if>
<c:choose>
    <c:when test="${firstLarge}">
        <c:set var="tileClass" value="square-col square-${ratio} square-large ${minHeight}${' '}${tileClassLarge}" />
        <c:if test="${firstOnPageFlip}">
            <c:set var="tileClass" value="${tileClass} float-md-right" />
        </c:if>
     </c:when>
    <c:otherwise>
        <c:set var="tileClass" value="square-col square-${ratio} square-small ${minHeight}${' '}${tileClassSmall}" />
    </c:otherwise>
</c:choose>

<c:set var="pmt" value="${not empty previewSpecial ? ' is-social' : ''}" />
<c:set var="pbg" value="${not empty previewSpecial and empty image ? ' pbg-'.concat(previewSpecial) : ''}" />

<mercury:nl />
<div class="type-media text-below-on-xs ${tileClass}"><%----%>
    <div class="content ${animationClass}${pmt}${pbg}"><%----%>
        <div class="preview ${cssClass}" <c:if test="${not empty template}">data-preview='{"template":"${cms:encode(template)}"}'</c:if>><%----%>

            <c:choose>
                <c:when test="${not empty image}">
                    <cms:addparams>
                        <cms:param name="cssgrid" value="${tileClass}" />
                        <mercury:image-animated
                            image="${image}"
                            ratio="${imgRatio}"
                            title="${title}" />
                    </cms:addparams>
                </c:when>
                <c:when test="${not empty mediaPreviewHtml}">
                    <div class="centered image">${mediaPreviewHtml}</div><%----%>
                </c:when>
                <c:otherwise>
                    <%-- needed because this div is used to size the image in case of '.text-below-on-xs' --%>
                    <div class="image-src-box"></div><%----%>
                </c:otherwise>
            </c:choose>

            <div class="centered icon"><%----%>
                <span class="fa fa-${icon}"></span><%----%>
                <c:if test="${caseDynamicListNoscript or caseStandardElement}">
                    ${caseStandardElement ? '<noscript>' : ''}
                    <div><fmt:message key="msg.page.javaScript.required" /></div><%----%>
                    ${caseStandardElement ? '</noscript>' : ''}
                </c:if>
            </div><%----%>

            <div class="text-overlay"><%----%>
                <c:if test="${not empty dateStr}"><div class="teaser-date"><c:out value="${dateStr}"></c:out></div></c:if>
                <c:if test="${not empty content.value.Length}"><div class="media-length"><c:out value="${content.value.Length}"></c:out></div></c:if>
                <h2 class="title"><c:out value="${title}" /></h2><%----%>
                <c:if test="${not empty preface}"><h3 class="preface"><c:out value="${preface}" /></h3></c:if>
            </div><%----%>

        </div><%----%>
    </div><%----%>
</div><%----%>
<mercury:nl />

</mercury:media-vars>
</cms:bundle>
</cms:formatter>
</mercury:init-messages>