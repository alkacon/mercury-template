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

<c:set var="title"   value="${value.Question}" />

<mercury:teaser-piece
    cssWrapper="type-faq ${setEffect}${' '}${setCssWrapper}"
    intro="${setShowIntro ? intro : null}"
    headline="${title}"
    date="${value.Date.toInstanceDate}"
    paraCaption="${paragraph.value.Caption}"
    paraText="${paragraph.value.Text}"
    pieceLayout="${setPieceLayout}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"

    teaserType="${displayType}"
    link="${linkToDetail}"
    hsize="${setHsize}"
    dateFormat="${setDateFormat}"
    textLength="${setTextLength}"
    buttonText="${setButtonText}">

    <jsp:attribute name="markupVisual">
        <c:if test="${setShowVisual}">
            <c:set var="image" value="${paragraph.value.Image}" />
            <mercury:image-animated image="${image}" ratio="${setRatio}" test="${not empty image}" setTitle="${false}" />
        </c:if>
    </jsp:attribute>

</mercury:teaser-piece>

</mercury:teaser-settings>
</cms:formatter>
</mercury:init-messages>