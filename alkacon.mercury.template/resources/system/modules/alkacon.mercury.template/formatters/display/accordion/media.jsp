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
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="setting"            value="${cms.element.setting}" />
<c:set var="hsize"              value="${setting.hsize.isSet ? setting.hsize.toInteger : 3}" />
<c:set var="imageRatio"         value="${setting.imageRatio.isSet ? setting.imageRatio.toString : null}"/>
<c:set var="showImageZoom"      value="${setting.showImageZoom.toBoolean}" />
<c:set var="showImageCopyright" value="${setting.showImageCopyright.toBoolean}" />

<mercury:teaser-accordion title="${value.Title}" cssWrapper="type-media">

    <mercury:section-piece
        pieceLayout="${9}"
        sizeDesktop="${6}"
        sizeMobile="${12}"
        heading="${value.Preface}"
        text="${value.Text}"
        imageRatio="${imageRatio}"
        showImageZoom="${showImageZoom}"
        hsize="${hsize + 1}"
        ade="${false}">

        <jsp:attribute name="markupVisual">
            <mercury:media-box
                content="${content}"
                ratio="${empty imageRatio ? '4-3' : imageRatio}"
                showCopyright="${showImageCopyright}"
                showMediaTime="${true}" />
        </jsp:attribute>

    </mercury:section-piece>

</mercury:teaser-accordion>
</cms:bundle>
</cms:formatter>
</mercury:init-messages>