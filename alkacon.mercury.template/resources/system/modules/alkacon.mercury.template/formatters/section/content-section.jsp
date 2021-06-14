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

<mercury:init-messages>
<cms:formatter var="content" val="value">

<c:set var="setting"            value="${cms.element.setting}" />
<c:set var="cssWrapper"         value="${setting.cssWrapper.isSet ? ' '.concat(setting.cssWrapper.toString) : null}" />
<c:set var="effect"             value="${setting.effect.isSetNotNone ? ' '.concat(setting.effect.toString) : null}" />
<c:set var="cssVisibility"      value="${setting.cssVisibility.toString ne 'always' ? ' '.concat(setting.cssVisibility.toString) : null}" />
<c:set var="pieceLayout"        value="${setting.pieceLayout.toInteger}" />
<c:set var="sizeDesktop"        value="${setting.visualOption.toInteger}" />
<c:set var="sizeMobile"         value="${setting.sizeMobile.isSetNotNone ? setting.sizeMobile.toInteger : null}" />
<c:set var="hsize"              value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"         value="${setting.imageRatio.toString}" />
<c:set var="linkOption"         value="${setting.linkOption.toString}" />
<c:set var="showImageCopyright" value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showImageSubtitle"  value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageZoom"      value="${setting.showImageZoom.toBoolean}" />
<c:set var="showImageLink"      value="${setting.showImageLink.toBoolean}" />
<c:set var="textAlignment"      value="${setting.textAlignment.toString}" />

<c:set var="headingOption"      value="${setting.headingOption.toString}" />
<c:set var="textOption"         value="${setting.textOption.toString}" />

<mercury:section-piece
    cssWrapper="element type-section${cssWrapper}${effect}${cssVisibility}"
    pieceLayout="${pieceLayout < 11 ? pieceLayout : 4}"
    sizeDesktop="${sizeDesktop}"
    sizeMobile="${sizeMobile}"
    heading="${value.Title}"
    image="${value.Image}"
    text="${value.Text}"
    link="${value.Link}"
    hsize="${hsize}"
    imageRatio="${imageRatio}"
    textOption="${textOption}"
    textAlignment="${textAlignment}"
    linkOption="${linkOption}"
    showImageCopyright="${showImageCopyright}"
    showImageSubtitle="${showImageSubtitle}"
    showImageZoom="${showImageZoom}"
    showImageLink="${showImageLink}"
    ade="${cms.isEditMode}"
    emptyWarning="${true}"
/>

</cms:formatter>
</mercury:init-messages>