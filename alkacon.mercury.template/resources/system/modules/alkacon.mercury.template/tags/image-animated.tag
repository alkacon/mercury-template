<%@ tag pageEncoding="UTF-8"
    display-name="image-animated"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays a responsive image with optional animation effects." %>


<%@ attribute name="image" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="true"
    description="The image to format. Must be a nested image content."%>

<%@ attribute name="sizes" type="java.lang.String" required="false"
    description="Sizes (width in pixel) to create image variations for. This must be a comma separated list e.g. '100,200,400,800'." %>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="ratioXs" type="java.lang.String" required="false"
    description="Image ratio for small screens." %>

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


<%-- ####### These variables are actually set in the mercury:image-vars tag included ####### --%>
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
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:image-vars
    image="${image}"
    ratio="${ratio}"
    title="${title}"
    ade="${empty ade ? false : ade}">

<c:set var="test" value="${empty test ? true : test}" />
<c:set var="setTitle" value="${empty setTitle ? true : setTitle}" />

<c:set var="ratioXs" value="${(empty ratioXs) or ('desk' eq ratioXs) ? ratio : ratioXs}" />
<c:set var="adoptRatioToScreen" value="${(not empty ratioXs) and (ratio ne ratioXs)}" />

<c:choose>
    <c:when test="${addEffectPiece}">
        <c:set var="effectWrapper" value="effect-piece" />
    </c:when>
    <c:when test="${empty addEffectBox or addEffectBox}">
        <c:set var="effectWrapper" value="effect-box" />
    </c:when>
</c:choose>

<c:choose>

<c:when test="${not empty imageBean and test}">
    <mercury:div css="${effectWrapper}${not empty effectWrapper and not empty cssWrapper ? ' ':''}${cssWrapper}" attr="${attrWrapper}" test="${not empty effectWrapper or not empty cssWrapper or not empty attrWrapper}">
        <c:choose>
            <c:when test="${showImageZoom and (adoptRatioToScreen or imageIsSvg)}">
                <%-- Use original image proportions (without ratio applied) for image zooming in case there are different mobile / desktop ratios, or the image is an SVG. --%>
                <c:set var="zoomData">
                    <mercury:image-zoomdata
                        src="${imageUnscaledBean.srcUrl}"
                        title="${imageTitle}"
                        alt="${empty imageDescription ? imageTitle : imageDescription}"
                        copyright="${imageCopyrightHtml}"
                        height="${imageUnscaledBean.scaler.height}"
                        width="${imageUnscaledBean.scaler.width}"
                        imageBean="${imageUnscaledBean}"
                    />
                </c:set>
            </c:when>
            <c:when test="${showImageZoom}">
                <%-- Bitmap image and mobile / desktop ratio is the same, apply ratio for image zooming. --%>
                <c:set var="zoomData">
                    <mercury:image-zoomdata
                        src="${imageUrl}"
                        title="${imageTitle}"
                        alt="${empty imageDescription ? imageTitle : imageDescription}"
                        copyright="${imageCopyrightHtml}"
                        height="${imageHeight}"
                        width="${imageWidth}"
                        imageBean="${imageBean}"
                    />
                </c:set>
            </c:when>
        </c:choose>
        <c:if test="${adoptRatioToScreen}">
            <cms:addparams>
                <cms:param name="cssgrid" value="hidden-lg hidden-xl hidden-xxl" />
                <mercury:image-srcset
                    imagebean="${ratioXs eq 'none' ? imageUnscaledBean : imageBean.scaleRatio[ratioXs]}"
                    sizes="${sizes}"
                    alt="${empty alt ? (empty imageDescription ? imageTitle : imageDescription) : alt}"
                    title="${setTitle ? (showCopyright ? (empty imageDescription ? imageTitle : imageDescription) : (empty imageDescription ? imageTitleCopyright : imageDescriptionCopyright)) : null}"
                    copyright="${showCopyright ? imageCopyrightHtml : null}"
                    cssImage="${empty effectWrapper ? '' : 'animated'}${not empty effectWrapper and not empty cssImage ? ' ' : ''}${cssImage}"
                    cssWrapper="${showImageZoom ? 'zoomer' : ''} hidden-lg-up"
                    attrImage="${attrImage}"
                    attrWrapper="${imageDndAttr}"
                    isSvg="${imageIsSvg}"
                    zoomData="${zoomData}"
                    noScript="${noScript}"
                />
            </cms:addparams>
        </c:if>
        <cms:addparams>
            <c:if test="${adoptRatioToScreen}">
                <c:set var="desktopWrapper" value=" hidden-xs-sm-md" />
                <cms:param name="cssgrid" value="hidden-xs hidden-sm hidden-md" />
            </c:if>
            <mercury:image-srcset
                imagebean="${imageBean}"
                sizes="${sizes}"
                alt="${empty alt ? (empty imageDescription ? imageTitle : imageDescription) : alt}"
                title="${setTitle ? (showCopyright ? (empty imageDescription ? imageTitle : imageDescription) : (empty imageDescription ? imageTitleCopyright : imageDescriptionCopyright)) : null}"
                copyright="${showCopyright ? imageCopyrightHtml : null}"
                cssImage="${empty effectWrapper ? '' : 'animated'}${not empty effectWrapper and not empty cssImage ? ' ' : ''}${cssImage}"
                cssWrapper="${showImageZoom ? 'zoomer' : ''}${desktopWrapper}"
                attrImage="${attrImage}"
                attrWrapper="${imageDndAttr}"
                isSvg="${imageIsSvg}"
                zoomData="${zoomData}"
                noScript="${noScript}"
            />
        </cms:addparams>
        <%-- ####### JSP body inserted here ######## --%>
        <jsp:doBody/>
        <%-- ####### /JSP body inserted here ######## --%>
    </mercury:div>
    <mercury:nl />
</c:when>

<c:otherwise>
    <c:if test="${cms.isEditMode and test}">
        <%-- ###### No image: Output warning in offline version ###### --%>
        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <mercury:alert type="warning">
                <jsp:attribute name="head">
                    <fmt:message key="msg.page.noImage" />
                </jsp:attribute>
                <jsp:attribute name="text">
                    <fmt:message key="msg.page.noImage.hint" />
                </jsp:attribute>
            </mercury:alert>
        </cms:bundle>
    </c:if>
    <%-- ####### JSP body inserted here ######## --%>
    <jsp:doBody/>
    <%-- ####### /JSP body inserted here ######## --%>
</c:otherwise>

</c:choose>

</mercury:image-vars>