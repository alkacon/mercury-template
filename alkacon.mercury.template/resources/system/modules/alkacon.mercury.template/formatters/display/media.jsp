<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<m:init-messages>

<cms:formatter var="content" val="value">
<m:teaser-settings content="${content}">

<c:set var="intro"      value="${value['TeaserData/TeaserIntro'].isSet ? value['TeaserData/TeaserIntro'] : value.Intro}" />
<c:set var="title"      value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />
<c:set var="preface"    value="${value['TeaserData/TeaserPreface'].isSet ? value['TeaserData/TeaserPreface'] : value.Preface}" />

<c:set var="isAudio"    value="${value.MediaContent.value.Audio.isSet}" />
<c:set var="isFlexible" value="${value.MediaContent.value.Flexible.isSet}" />

<m:teaser-piece
    cssWrapper="type-media${isAudio ? ' audio ' : ' '}${setCssWrapperAll}"
    intro="${setShowIntro ? intro : null}"
    headline="${title}"
    headlineSuffix="${setOrderBadge}"
    preface="${preface}"
    date="${value.Date.toInstanceDate}"
    paraText="${value.Text}"
    noLinkOnVisual="${true}"
    piecePreMarkup="${setElementPreMarkup}"
    pieceLayout="${setPieceLayout}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"

    teaserType="${displayType}"
    link="${linkToDetail}"
    linkOption="${setLinkOption}"
    linkNewWin="${setLinkNewWin}"
    hsize="${setHsize}"
    dateFormat="${setDateFormat}"
    textLength="${value['TeaserData/TeaserPreface'].isSet ? -1 : setTextLength}"
    headingInBody="${setHeadingInBody}"
    buttonText="${setButtonText}">

    <jsp:attribute name="markupVisual">
        <c:if test="${setShowVisual}">
            <m:media-box
                content="${content}"
                ratio="${setRatio}"
                ratioLg="${setRatioLg}"
                link="${isFlexible ? linkToDetail : ''}"
                showMediaTime="${true}"
                showCopyright="${setShowCopyright}"
            />
        </c:if>
    </jsp:attribute>

</m:teaser-piece>

</m:teaser-settings>
</cms:formatter>
</m:init-messages>