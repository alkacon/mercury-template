<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<m:init-messages>

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="setting"            value="${cms.element.setting}" />
<c:set var="baseUri"            value="${setting.pageUri.toString}" />
<c:set var="squareGrid"         value="${setting.squareGrid.toString}" />
<c:set var="firstSquare"        value="${setting.firstSquare.toString}" />
<c:set var="showPreface"        value="${setting.showPreface.toBoolean}" />
<c:set var="dateFormat"         value="${setting.dateFormat}"/>
<c:set var="ratio"              value="${setting.imageRatio.toString}"/>
<c:set var="effect"             value="${setting.effect.isSetNotNone ? setting.effect.toString.concat(' effect-piece') : ''}" />
<c:set var="showImageCopyright" value="${setting.showImageCopyright.toBoolean}" />

<c:set var="paragraph"          value="${content.valueList.Paragraph['0']}" />
<c:set var="title"              value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />
<c:set var="image"              value="${value['TeaserData/TeaserImage'].isSet ? value['TeaserData/TeaserImage'] : (value.Image.isSet ? value.Image : paragraph.value.Image) }" />

<c:if test="${showPreface}">
    <c:set var="preface"        value="${value['TeaserData/TeaserPreface'].isSet ? value['TeaserData/TeaserPreface'] : value.Preface}" />
    <c:set var="minHeight"      value="min-height show-preface" />
</c:if>

<c:if test="${dateFormat.isSetNotNone}">
    <c:set var="seriesInfo" value="${value.Dates.toDateSeries}" />
    <c:set var="date" value="${seriesInfo.instanceInfo.get(param.instancedate)}" />
    <c:set var="dateStr"><m:instancedate date="${date}" format="${dateFormat.toString}" /></c:set>
    <c:if test="${empty minHeight}"><c:set var="minHeight" value="min-height" /></c:if>
</c:if>

<m:list-badge var="badge" seriesInfo="${seriesInfo}" test="${cms.isEditMode}" />

<c:set var="imgRatio" value="${ratio}" />

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
        <c:set var="addClear" value="${squareGrid eq '4' ? (param.resultInList eq 6) : (param.resultInList eq 4)}" />
    </c:when>
    <c:when test="${firstSquare eq 'firstOnPageLarge'}">
        <c:set var="firstLarge" value="${param.resultOnPage eq 1}" />
        <c:set var="addClear" value="${firstLarge ? true : (squareGrid eq '4' ? (param.resultOnPage eq 6) : (param.resultOnPage eq 4))}" />
    </c:when>
    <c:when test="${firstSquare eq 'firstOnPageFlip'}">
        <c:set var="firstLarge" value="${param.resultOnPage eq 1}" />
        <c:set var="firstOnPageFlip" value="${(param.resultPage % 2) eq 0}" />
        <c:set var="addClear" value="${firstLarge ? true : (squareGrid eq '4' ? (param.resultOnPage eq 6) : (param.resultOnPage eq 4))}" />
    </c:when>
</c:choose>

<c:if test="${ratio eq '16-9'}"><c:set var="imgRatio" value="1600-960" /></c:if>
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
<c:if test="${addClear}">
    <c:set var="tileClass" value="${tileClass} clear-row" />
</c:if>

<c:if test="${not empty param.instancedate}">
    <c:set var="linkParameters">?instancedate=${param.instancedate}</c:set>
</c:if>
<c:set var="link"><cms:link baseUri="${baseUri}">${content.filename}${linkParameters}</cms:link></c:set>

<m:nl />
<div class="type-event text-below-on-xs ${tileClass}${' '}${effect}"><%----%>
    <div class="content"><%----%>

    <m:link link="${link}">
        <cms:addparams>
            <cms:param name="cssgrid" value="${tileClass}" />
            <m:image-animated
                image="${image}"
                ratio="${imgRatio}"
                alt="${showImageCopyright ? 'nocopy' : null}"
                title="${title}">
                <c:set var="copyright" value="${imageCopyrightHtml}" />
            </m:image-animated>
        </cms:addparams>

        <div class="text-overlay"><%----%>
            <c:if test="${not empty dateStr}"><div class="teaser-date">${dateStr}</div></c:if>
            <h2 class="title"><c:out value="${title}" />${badge}</h2><%----%>
            <c:if test="${not empty preface}"><h3 class="preface"><c:out value="${preface}" /></h3></c:if>
        </div><%----%>
        <c:if test="${showImageCopyright}"><div class="copyright">${copyright}</div></c:if>
    </m:link>

    </div><%----%>
</div><%----%>
<m:nl />

</cms:bundle>
</cms:formatter>

</m:init-messages>


