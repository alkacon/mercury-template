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

<m:init-messages>
<cms:formatter var="content" val="value">

<m:setting-defaults>

<c:set var="pieceLayout"        value="${setting.pieceLayout.toInteger}" />
<c:set var="sizeDesktop"        value="${setting.visualOption.toInteger}" />
<c:set var="sizeMobile"         value="${setting.sizeMobile.isSetNotNone ? setting.sizeMobile.toInteger : null}" />
<c:set var="headingAsDiv"       value="${setting.hsize.toString.startsWith('.h')}" />
<c:set var="hsize"              value="${headingAsDiv ? cms.wrap(setting.hsize.toString.substring(2)).toInteger : setting.hsize.toInteger}" />
<c:set var="imageRatio"         value="${setting.imageRatio.toString}" />
<c:set var="linkOption"         value="${setting.linkOption.toString}" />
<c:set var="showImageCopyright" value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showImageSubtitle"  value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageZoom"      value="${setting.showImageZoom.toBoolean}" />
<c:set var="showImageLink"      value="${setting.showImageLink.toBoolean}" />
<c:set var="textAlignment"      value="${setting.textAlignment.toString}" />
<c:set var="verticalAlignment"  value="${setting.verticalAlignment.isSetNotNone ? setting.verticalAlignment.toString : null}" />
<c:set var="boxRatio"           value="${setting.boxRatio.isSetNotNone ? setting.boxRatio.toString : null}" />

<c:set var="headingOption"      value="${setting.headingOption.toString}" />
<c:set var="textOption"         value="${setting.textOption.toString}" />

<c:set var="hasLink"            value="${value.Link.isSet and value.Link.value.URI.isSet}"/>

<%-- Note regarding css wrappers: Apply wrappers 2 and 3 to the .piece inner div --%>
<c:set var="boxWrapper"         value="${fn:contains(setCssWrapper, 'box') ? '' : ' box'}" />

<m:nl />
<div class="element type-linkbox${hasLink ? ' fully-linked' : ''}${boxWrapper}${setCssWrapperAll}${not empty boxRatio ? ' box-ratio-'.concat(boxRatio) : ''}${not empty verticalAlignment ? ' valign-'.concat(verticalAlignment) : ''}${setEffect}${setCssVisibility}"><%----%>
<m:nl />

${setElementPreMarkup}

<m:link link="${value.Link}" testFailTag="span" css="linkbox-link">

<m:section-piece
    cssWrapper="linkbox-content adjust-headings${setCssWrapperExtra}"
    pieceLayout="${pieceLayout < 11 ? pieceLayout : 4}"
    sizeDesktop="${sizeDesktop}"
    sizeMobile="${sizeMobile}"
    heading="${value.Title}"
    addHeadingId="${cms.sitemapConfig.attribute['template.section.add.heading.id'].toBoolean}"
    addHeadingAnchorlink="${false}"
    image="${value.Image}"
    text="${fn:contains(value.Text.toString, 'href') ? fn:trim(cms:stripHtml(value.Text)) : value.Text}"
    link="${value.Link}"
    suppressLinks="${true}"
    hsize="${hsize}"
    headingAsDiv="${headingAsDiv}"
    imageRatio="${imageRatio}"
    textOption="${textOption}"
    textAlignment="${textAlignment}"
    linkOption="${linkOption}"
    showImageCopyright="${showImageCopyright}"
    showImageSubtitle="${showImageSubtitle}"
    showImageZoom="${showImageZoom}"
    showImageLink="${showImageLink}"
    ade="${false}"
    emptyWarning="${true}"
/>

</m:link>

</div><%----%>
<m:nl />

</m:setting-defaults>

</cms:formatter>
</m:init-messages>