<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<mercury:init-messages>

<cms:formatter var="content" val="value">

<mercury:setting-defaults content="${content}">

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />

<c:set var="showOrganization"       value="${setting.showOrganization.toBoolean}" />
<c:set var="showName"               value="${setting.showName.useDefault('true').toBoolean}" />
<c:set var="showPosition"           value="${setting.showPosition.toBoolean}" />
<c:set var="showAddress"            value="${setting.showAddress.toString eq 'true'}" />
<c:set var="showAddressAlways"      value="${setting.showAddress.toString eq 'always'}" />
<c:set var="showDescription"        value="${setting.showDescription.toBoolean}" />
<c:set var="showPhone"              value="${setting.showPhone.toBoolean}" />
<c:set var="showWebsite"            value="${setting.showWebsite.toBoolean}" />
<c:set var="showEmail"              value="${setting.showEmail.toBoolean}" />
<c:set var="showVcard"              value="${setting.showVcard.toBoolean}" />

<c:set var="showImageZoom"          value="${setting.showImageZoom.toBoolean}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="imageRatio"             value="${setting.imageRatio.toString}" />
<c:set var="showImage"              value="${(imageRatio ne 'no-img') and value.Image.value.Image.isSet}" />

<c:set var="setSizeDesktop"         value="${setting.pieceSizeDesktop.toInteger}" />
<c:set var="setSizeMobile"          value="${setting.pieceSizeMobile.toInteger}" />

<c:set var="labelOption"            value="${setting.labels.toString}" />
<c:set var="linkOption"             value="${setting.linkOption.toString}" />

<c:set var="compactLayout"          value="${setting.compactLayout.toBoolean ? 'compact ' : ''}" />

<c:set var="hsizeTitle"             value="${hsize}" />
<c:set var="hsize"                  value="${value.Title.isSet ? hsize + 1 : hsize}" />

<c:set var="valKind"                value="${value.Kind.isSet ? value.Kind : setting.schemaKind.useDefault('pers').toString}" />

<mercury:contact-vars
    content="${content}"
    kind="${valKind}"
    showName="${showName}"
    showPosition="${showPosition}"
    showOrganization="${showOrganization}">

<mercury:nl />
<mercury:section-piece
    cssWrapper="element type-contact ${kindCss}${compactLayout}${setCssWrapperAll}"
    pieceLayout="${pieceLayout}"
    attrWrapper="${kindAttr}"
    heading="${value.Title}"
    hsize="${hsizeTitle}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"
    ade="${false}">

    <jsp:attribute name="markupVisual">
        <c:if test="${showImage}">
            <mercury:contact
                kind="${valKind}"
                image="${value.Image}"
                name="${valName}"
                organization="${valOrganization}"
                imageRatio="${imageRatio}"
                link="${value.Link}"
                linkOption="${linkOption eq 'imageOverlay' ? 'imageOverlay' : ''}"
                hsize="${hsize}"
                showImage="${true}"
                showImageZoom="${showImageZoom}"
                showImageCopyright="${showImageCopyright}"
            />
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="markupText">
        <mercury:contact
            kind="${valKind}"
            link="${value.Link}"
            name="${valName}"
            position="${valPosition}"
            organization="${valOrganization}"
            description="${value.Description}"
            data="${value.Contact}"
            address="${valAddress}"
            labelOption="${labelOption}"
            linkOption="${linkOption}"
            hsize="${hsize}"
            showName="${setShowName}"
            showPosition="${setShowPosition}"
            showAddress="${showAddress}"
            showAddressAlways="${showAddressAlways}"
            showOrganization="${setShowOrganization}"
            showDescription="${showDescription}"
            showPhone="${showPhone}"
            showWebsite="${showWebsite}"
            showEmail="${showEmail}"
            showVcard="${showVcard}"
        />
    </jsp:attribute>
</mercury:section-piece>
</mercury:contact-vars>

</mercury:setting-defaults>

</cms:formatter>
</mercury:init-messages>