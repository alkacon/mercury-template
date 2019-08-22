<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<mercury:init-messages>

<cms:formatter var="content" val="value">
<mercury:teaser-settings content="${content}">

<c:set var="paragraphIntro"         value="${value.Introduction}" />
<c:set var="paragraphText"          value="${content.valueList.Text['0']}" />

<c:set var="intro"   value="${value['TeaserData/TeaserIntro'].isSet ? value['TeaserData/TeaserIntro'] : value.Intro}" />
<c:set var="title"   value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />
<c:set var="preface" value="${value['TeaserData/TeaserPreface'].isSet ? value['TeaserData/TeaserPreface'] : null}" />

<mercury:teaser-piece
    cssWrapper="type-job ${setEffect}${' '}${setCssWrapper}"
    intro="${setShowIntro ? intro : null}"
    headline="${title}"
    preface="${preface}"
    date="${value.Date.toInstanceDate}"
    paraCaption="${paragraphIntro.value.Caption.isSet ? paragraphIntro.value.Caption : paragraphText.value.Caption}"
    paraText="${paragraphIntro.value.Text.isSet ? paragraphIntro.value.Text : paragraphText.value.Text}"
    pieceLayout="${setPieceLayout}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"

    teaserType="${displayType}"
    link="${linkToDetail}"
    hsize="${setHsize}"
    dateFormat="${setDateFormat}"
    textLength="${value['TeaserData/TeaserPreface'].isSet ? -1 : setTextLength}"
    buttonText="${setButtonText}">

    <jsp:attribute name="markupVisual">
        <c:if test="${setShowVisual}">
            <c:set var="image" value="${paragraphIntro.value.Image.isSet ? paragraphIntro.value.Image : (paragraphText.value.Image.isSet ? paragraphText.value.Image : null)}" />
            <mercury:image-animated image="${image}" ratio="${setRatio}" test="${not empty image}" setTitle="${false}" />
        </c:if>
    </jsp:attribute>

</mercury:teaser-piece>

</mercury:teaser-settings>
</cms:formatter>
</mercury:init-messages>