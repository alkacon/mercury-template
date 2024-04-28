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

<mercury:load-plugins group="detail-setting-defaults" type="jsp-nocache" />

<mercury:setting-defaults>

<c:set var="pieceLayout"        value="${setting.pieceLayout.toInteger}" />
<c:set var="sizeDesktop"        value="${setting.visualOption.toInteger}" />
<c:set var="sizeMobile"         value="${setting.sizeMobile.isSetNotNone ? setting.sizeMobile.toInteger : null}" />
<c:set var="hsize"              value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"         value="${setting.imageRatio.toString}" />
<c:set var="imageRatioLg"       value="${setting.imageRatioLg.toString}" />
<c:set var="linkOption"         value="${setting.linkOption.toString}" />
<c:set var="showImageCopyright" value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showImageSubtitle"  value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageZoom"      value="${setting.showImageZoom.toBoolean}" />
<c:set var="showImageLink"      value="${setting.showImageLink.toBoolean}" />
<c:set var="textAlignment"      value="${setting.textAlignment.toString}" />

<c:set var="headingOption"      value="${setting.headingOption.toString}" />
<c:set var="textOption"         value="${setting.textOption.toString}" />

<mercury:section-piece
    cssWrapper="element type-section${setCssWrapperAll}"
    pieceLayout="${pieceLayout < 11 ? pieceLayout : 4}"
    sizeDesktop="${sizeDesktop}"
    sizeMobile="${sizeMobile}"
    heading="${value.Title}"
    addHeadingId="${cms.sitemapConfig.attribute['template.section.add.heading.id'].toBoolean}"
    addHeadingAnchorlink="${cms.sitemapConfig.attribute['template.section.add.heading.anchorlink'].toBoolean}"
    image="${value.Image}"
    text="${value.Text}"
    link="${value.Link}"
    hsize="${hsize}"
    imageRatio="${imageRatio}"
    imageRatioLg="${imageRatioLg}"
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

</mercury:setting-defaults>

</cms:formatter>
</mercury:init-messages>