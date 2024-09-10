<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<m:init-messages>

<cms:formatter var="content" val="value">
<m:teaser-settings content="${content}">

<c:set var="invalidDecoy"   value="${not value.Link.value.URI.isSet}" />

<c:choose>
<c:when test="${invalidDecoy and not cms.isEditMode}">
    <c:out value="<!-- Invalid decoy -->" escapeXml="false" />
</c:when>
<c:otherwise>
    <c:set var="intro"      value="${value.Intro}" />
    <c:set var="title"      value="${value.Title}" />
    <c:set var="preface"    value="${value.Preface}" />

    <m:list-badge var="badge" type="decoy" test="${cms.isEditMode}" />

    <m:teaser-piece
        teaserClass="${setTeaserClass}"
        cssWrapper="type-decoy${setCssWrapperAll}${invalidDecoy ? ' disabled' : ''}"
        intro="${setShowIntro ? intro : null}"
        headline="${title}"
        headlineSuffix="${badge}"
        preface="${preface}"
        date="${value.Date.toInstanceDate}"
        paraText="${value.Text}"
        piecePreMarkup="${setElementPreMarkup}"
        pieceLayout="${setPieceLayout}"
        sizeDesktop="${setSizeDesktop}"
        sizeMobile="${setSizeMobile}"

        teaserType="${displayType}"
        link="${value.Link}"
        linkOption="${setLinkOption}"
        hsize="${setHsize}"
        dateFormat="${setDateFormat}"
        textLength="${setTextLength}"
        headingInBody="${setHeadingInBody}"
        buttonText="${setButtonText}">

        <jsp:attribute name="markupVisual">
            <c:if test="${setShowVisual}">
                <c:set var="image"   value="${value.Image}" />
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
</c:otherwise>
</c:choose>

</m:teaser-settings>
</cms:formatter>
</m:init-messages>