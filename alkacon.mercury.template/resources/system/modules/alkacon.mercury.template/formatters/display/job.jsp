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

<c:set var="paragraphIntro"         value="${value.Introduction}" />
<c:set var="paragraphText"          value="${content.valueList.Text['0']}" />

<c:set var="intro"   value="${value['TeaserData/TeaserIntro'].isSet ? value['TeaserData/TeaserIntro'] : value.Intro}" />
<c:set var="title"   value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />
<c:set var="preface" value="${value['TeaserData/TeaserPreface'].isSet ? value['TeaserData/TeaserPreface'] : null}" />

<m:teaser-piece
    cssWrapper="type-job${setCssWrapperAll}"
    intro="${setShowIntro ? intro : null}"
    headline="${title}"
    headlineSuffix="${setOrderBadge}"
    preface="${preface}"
    date="${value.Date.toInstanceDate}"
    paraCaption="${paragraphIntro.value.Caption.isSet ? paragraphIntro.value.Caption : paragraphText.value.Caption}"
    paraText="${paragraphIntro.value.Text.isSet ? paragraphIntro.value.Text : paragraphText.value.Text}"
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
            <c:set var="image" value="${paragraphIntro.value.Image.isSet ? paragraphIntro.value.Image : (paragraphText.value.Image.isSet ? paragraphText.value.Image : null)}" />
            <m:image-animated
                image="${image}"
                ratio="${setRatio}"
                ratioLg="${setRatioLg}"
                test="${not empty image}"
                setTitle="${false}"
                showCopyright="${setShowCopyright}"
            />
        </c:if>
    </jsp:attribute>

</m:teaser-piece>

</m:teaser-settings>
</cms:formatter>
</m:init-messages>