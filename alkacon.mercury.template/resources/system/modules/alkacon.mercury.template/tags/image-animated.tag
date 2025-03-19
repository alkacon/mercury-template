<%@ tag pageEncoding="UTF-8"
    display-name="image-animated"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays a responsive image with optional animation effects." %>


<%@ attribute name="image" type="java.lang.Object" required="true"
    description="The image to format. Must be a nested image content."%>

<%@ attribute name="sizes" type="java.lang.String" required="false"
    description="Sizes (width in pixel) to create image variations for. This must be a comma separated list e.g. '100,200,400,800'." %>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="ratioLg" type="java.lang.String" required="false"
    description="Image ratio for large screens." %>

<%@ attribute name="lazyLoad" type="java.lang.Boolean" required="false"
    description="Use lazy loading or not? Default is 'true'."%>

<%@ attribute name="lazyLoadAutoSizes" type="java.lang.Boolean" required="false"
    description="false (default): use lazy loading with 'sizes' being calculated from the bootstrap bean. true: use lazy loading and require 'sizes: auto' to work - this will (for now) use JavaScript instead of native browser support."%>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="Text used in the image 'alt' and 'title' attributes."%>

<%@ attribute name="alt" type="java.lang.String" required="false"
    description="Text used in the image 'alt' attribute." %>

<%@ attribute name="setTitle" type="java.lang.Boolean" required="false"
    description="If 'true' a 'title' attribute is added to the generated image tag.
    If 'false' the image will have only an 'alt' but no 'title' attribute.
    No 'title' attribute be required in case the image is inside a tag that already has a 'title' attribute set, e.g. as in list teasers.
    Default is 'true' if not provided." %>

<%@ attribute name="showCopyright" type="java.lang.Boolean" required="false"
    description="If 'true' the copyright information of the image will be displayed as an image overlay.
    If 'false' no coypright overlay will be displayed, but the copyright information will be appended to the 'title' attribute.
    Default is 'false' if not provided." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="false"
    description="Enables advanced direct edit for the generated content.
    Default is 'false' if not provided." %>

<%@ attribute name="noScript" type="java.lang.Boolean" required="false"
    description="Generate noscript tags for lazy loading images or not?
    Default is 'true'." %>

<%@ attribute name="showImageZoom" type="java.lang.Boolean" required="false"
    description="Enables a zoom option for the image." %>

<%@ attribute name="addEffectBox" type="java.lang.Boolean" required="false"
    description="Adds the 'effect-box' CSS selector used for animation effects. Default is 'true'." %>

<%@ attribute name="addEffectPiece" type="java.lang.Boolean" required="false"
    description="Adds the 'effect-piece' CSS selector used for animation effects. Default is 'false'.
    If this is set to 'true' is will set 'addEffectBox' to 'false'." %>

<%@ attribute name="cssImage" type="java.lang.String" required="false"
    description="'class' atttribute to set directly on the generated img tag."%>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' atttribute to set on the src-box div surrounding the generated img." %>

<%@ attribute name="attrImage" type="java.lang.String" required="false"
    description="Attribute(s) to add directly to the generated img tag." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attribute(s) to add on the src-box div surrounding the generated img." %>

<%@ attribute name="test" type="java.lang.String" required="false"
    description="Can be used to defer the decision to actually create the markup around the body to the calling element.
    If not set or 'true', the markup from this tag is generated around the body of the tag.
    Otherwise everything is ignored and just the body of the tag is returned. "%>


<%-- These variables are actually set in the m:image-vars tag included --%>
<%@ variable name-given="imageBean" declare="true" variable-class="org.opencms.jsp.util.CmsJspImageBean" %>
<%@ variable name-given="imageLink" declare="true" %>
<%@ variable name-given="imageUnscaledLink" declare="true" %>
<%@ variable name-given="imageUrl" declare="true" %>
<%@ variable name-given="imageCopyright" declare="true" %>
<%@ variable name-given="imageCopyrightHtml" declare="true" %>
<%@ variable name-given="imageTitle" declare="true" %>
<%@ variable name-given="imageTitleCopyright" declare="true" %>
<%@ variable name-given="imageDescription" declare="true" %>
<%@ variable name-given="imageDescriptionCopyright" declare="true" %>
<%@ variable name-given="imageWidth" declare="true" %>
<%@ variable name-given="imageHeight" declare="true" %>
<%@ variable name-given="imageOrientation" declare="true" %>
<%@ variable name-given="imageIsSvg" declare="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="test"           value="${empty test ? true : test}" />

<c:set var="ratioLg"        value="${(empty ratioLg) or ('desk' eq ratioLg) ? ratio : ratioLg}" />
<c:set var="hideMobile"     value="${ratio eq 'no-img'}" />
<c:set var="hideDesktop"    value="${ratioLg eq 'no-img'}" />

<c:set var="test"           value="${test and not (hideDesktop and hideMobile)}" />

<m:image-vars
    image="${image}"
    ratio="${hideMobile ? ratioLg : ratio}"
    title="${title}"
    ade="${empty ade ? false : ade}">

    <c:choose>
        <c:when test="${not empty imageBean and test}">

            <c:set var="setTitle" value="${empty setTitle ? true : setTitle}" />
            <c:set var="noTitleCopyright" value="${alt eq 'nocopy'}" />
            <c:set var="alt" value="${noTitleCopyright ? null : alt}" />
            <c:set var="imgAlt" value="${empty alt ? (empty imageDescription ? imageTitle : imageDescription) : alt}" />
            <c:set var="imgTitle" value="${setTitle ? (showCopyright or noTitleCopyright ? (empty imageDescription ? imageTitle : imageDescription) : (empty imageDescription ? imageTitleCopyright : imageDescriptionCopyright)) : null}" />

            <c:set var="adaptRatioToScreen" value="${ratio ne ratioLg}" />
            <c:if test="${adaptRatioToScreen}">
                <%-- Note: The 'template.piece.breakpoint' sitemap attribute is NOT used here on purpose.
                    So far all use cases indicate treating the 'MD' size like a desktop (large) screen provides the best results. --%>
                <c:set var="mobileGrid"     value="hidden-md hidden-lg hidden-xl hidden-xxl" />
                <c:set var="mobileWrapper"  value="hidden-md-up " />
                <c:set var="desktopGrid"    value="hidden-xs hidden-sm" />
                <c:set var="desktopWrapper" value="hidden-xs-sm " />
            </c:if>
            <c:if test="${hideMobile or hideDesktop}">
                <c:set var="hideWrapper"    value="${hideMobile ? desktopWrapper : (hideDesktop ? mobileWrapper : '')}" />
            </c:if>

            <c:choose>
                <c:when test="${addEffectPiece}">
                    <c:set var="imageWrapper" value="image-src-box presized use-ratio ${hideWrapper}${showImageZoom ? 'zoomer ' : ''}effect-piece" />
                </c:when>
                <c:otherwise>
                    <c:set var="imageWrapper" value="image-src-box presized use-ratio ${hideWrapper}${showImageZoom ? 'zoomer ' : ''}effect-box" />
                </c:otherwise>
            </c:choose>

            <c:if test="${showImageZoom}">
                <%-- Use original image proportions (without ratio applied) for image zooming in case there are different mobile / desktop ratios, or the image is an SVG. --%>
                <%-- Bitmap image and mobile / desktop ratio is the same, apply ratio for image zooming if not disabled in sitemap attribute. --%>
                <c:set var="zoomFull" value="${imageIsSvg or (adaptRatioToScreen and (hideDesktop eq hideMobile)) or cms.sitemapConfig.attribute['template.imageZoom.full'].toBoolean}" />
                <c:set var="zoomDataWrapper">
                    <m:image-zoomdata
                        src="${zoomFull ? imageUnscaledBean.srcUrl : imageUrl}"
                        title="${imageTitle}"
                        alt="${empty imageDescription ? imageTitle : imageDescription}"
                        copyright="${imageCopyrightHtml}"
                        height="${zoomFull ? imageUnscaledBean.scaler.height : imageHeight}"
                        width="${zoomFull ? imageUnscaledBean.scaler.width : imageWidth}"
                        imageBean="${imageBean}"
                    />
                </c:set>
                <%-- Set the wrapper to the surrounding div, saving some bytes in page size --%>
                <c:set var="attrWrapper" value="${empty attrWrapper ? zoomDataWrapper : attrWrapper.concat(' ').concat(zoomDataWrapper)}" />
            </c:if>

            <div class="${cssWrapper}${empty cssWrapper ? '':' '}${imageWrapper}"${empty attrWrapper ? '':' '}${attrWrapper}${empty imageDndAttr ? '':' '}${imageDndAttr}><%----%>
                <c:if test="${not hideMobile}">
                    <cms:addparams>
                        <c:if test="${adaptRatioToScreen}">
                            <cms:param name="cssgrid" value="${mobileGrid}" />
                        </c:if>
                        <m:image-srcset
                            imagebean="${imageBean}"
                            sizes="${sizes}"
                            lazyLoad="${lazyLoad}"
                            lazyLoadAutoSizes="${lazyLoadAutoSizes}"
                            alt="${imgAlt}"
                            title="${imgTitle}"
                            cssImage="${mobileWrapper}animated${not empty cssImage ? ' ' : ''}${cssImage}"
                            attrImage="${attrImage}"
                            isSvg="${imageIsSvg}"
                            addPaddingBox="${false}"
                            noScript="${noScript}"
                        />
                    </cms:addparams>
                </c:if>
                <c:if test="${adaptRatioToScreen and not hideDesktop}">
                    <cms:addparams>
                        <cms:param name="cssgrid" value="${desktopGrid}" />
                        <m:image-srcset
                            imagebean="${ratioLg eq 'none' ? imageUnscaledBean : imageBean.scaleRatio[ratioLg]}"
                            sizes="${sizes}"
                            lazyLoad="${lazyLoad}"
                            lazyLoadAutoSizes="${lazyLoadAutoSizes}"
                            alt="${imgAlt}"
                            title="${imgTitle}"
                            cssImage="${desktopWrapper}animated${not empty cssImage ? ' ' : ''}${cssImage}"
                            attrImage="${attrImage}"
                            isSvg="${imageIsSvg}"
                            addPaddingBox="${false}"
                            noScript="${noScript}"
                        />
                    </cms:addparams>
                </c:if>
                <m:data-image imageBean="${imageBean}" copyright="${imageCopyright}" />
                <c:if test="${showCopyright and not empty imageCopyrightHtml}">
                    <div class="copyright image-copyright" aria-hidden="true"><%----%>
                        <m:out value="${imageCopyrightHtml}" lenientEscaping="${true}" />
                    </div><%----%>
                </c:if>
                <%-- JSP body inserted here --%>
                <jsp:doBody/>
                <%-- /JSP body inserted here --%>
            </div><%----%>
            <m:nl />
        </c:when>

        <c:otherwise>
            <c:if test="${cms.isEditMode and test}">
                <%-- No image: Output warning in offline version --%>
                <fmt:setLocale value="${cms.workplaceLocale}" />
                <cms:bundle basename="alkacon.mercury.template.messages">
                    <m:alert type="warning">
                        <jsp:attribute name="head">
                            <fmt:message key="msg.page.noImage" />
                        </jsp:attribute>
                        <jsp:attribute name="text">
                            <fmt:message key="msg.page.noImage.hint" />
                        </jsp:attribute>
                    </m:alert>
                </cms:bundle>
            </c:if>
            <%-- JSP body inserted here --%>
            <jsp:doBody/>
            <%-- /JSP body inserted here --%>
        </c:otherwise>

    </c:choose>

</m:image-vars>