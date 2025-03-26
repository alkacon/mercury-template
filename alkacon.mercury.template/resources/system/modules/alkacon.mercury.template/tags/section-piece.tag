<%@ tag pageEncoding="UTF-8"
    display-name="section-piece"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Displays a content section like a paragraph." %>

<%@ attribute name="pieceLayout" type="java.lang.Integer" required="true"
    description="The layout option to generate. Valid values are 0 to 9.
    // 0. Heading, Image, Text, Link (full width)
    // 1. Image, Heading, Text, Link (full width)
    // 2. Heading on top, Image left, Text and Link right (separate column)
    // 3. Heading on top, Image right, Text and Link left (separate column)
    // 4. Heading on top, Image left, Text and Link right (floating around image)
    // 5. Heading on top, Image right, Text and Link left (floating around image)
    // 6. Image left, Heading, Text and Link right (separate column)
    // 7. Image right, Heading, Text and Link left (separate column)
    // 8. Image left, Heading, Text and Link right (floating around image)
    // 9. Image right, Heading, Text and Link left (floating around image)
    // 10. Heading, Text, Link, Image (full width)
    // 11. Heading, Text, Image, Link (full width)
    " %>

<%@ attribute name="sizeMobile" type="java.lang.Integer" required="false"
    description="Mobile grid size for the visual. Valid values are 1 to 12, 0 and 99.
    The special value 0 means 'hide the visual'.
    The special value 99 means 'use the default'
    The default will depend on the desktop size, e.g. for destop 4 this would be mobile 12." %>

<%@ attribute name="sizeDesktop" type="java.lang.Integer" required="false"
    description="Desktop grid size for the visual if displayed in a column. Valid values are 1 to 12, 0 and 99.
    The special value 0 means 'hide the visual'.
    The special value 99 means 'use the default'.
    The default normally is 4." %>

<%@ attribute name="pieceTag" type="java.lang.String" required="false"
    description="The tag to generate. Defaults to 'div' if not provided." %>

<%@ attribute name="pieceClass" type="java.lang.String" required="false"
    description="The class to generate. Defaults to 'piece' if not provided." %>

<%@ attribute name="heading" type="java.lang.Object" required="false"
    description="The optional section heading." %>

<%@ attribute name="image" type="java.lang.Object" required="false"
    description="The image to display as visual." %>

<%@ attribute name="text" type="java.lang.Object" required="false"
    description="The optional section text." %>

<%@ attribute name="link" type="java.lang.Object" required="false"
    description="The optional section link." %>

<%@ attribute name="hsize" type="java.lang.Integer" required="false"
    description="The heading level of the section heading." %>

<%@ attribute name="imageRatio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="imageRatioLg" type="java.lang.String" required="false"
    description="Image ratio for large screens." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' selectors to add to the generated div surrounding the section." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attributes to add to the generated div surrounding section." %>

<%@ attribute name="textOption" type="java.lang.String" required="false"
    description="Controls if the tag body text is displayed or not. Default is 'Display as normal text'." %>

<%@ attribute name="linkOption" type="java.lang.String" required="false"
    description="Controls if and how the link is displayed. Possible values are:
    'button':           Display a regular size link button.
    'button-sm':        Display a small size link button.
    'button-full':      Display a link button that is as wide as it's parent element.
    'text':             Display the link as text, not as button.
    'heading':          Link the heading, do not display a separate link button or text.
    'none' / 'false':   Do not display / use the link at all.
    Default is 'button'." %>

<%@ attribute name="suppressLinks" type="java.lang.Boolean" required="false"
    description="Controls if links are generated, or if a markup is generated without actual links. Default is 'false'.
    This can be used in case the entire section is to be contained in one link." %>

<%@ attribute name="textAlignment" type="java.lang.String" required="false"
    description="Controls the alignment of the text elements. Default is left aligned." %>

<%@ attribute name="headingOption" type="java.lang.String" required="false"
    description="Controls how the heading is displayed. Default is 'full'." %>

<%@ attribute name="headingAsDiv" type="java.lang.Boolean" required="false"
    description="Controls if headings are generated using regular <h1> ... <h6> tags, or as divs that contain a marker class 'h1' ... 'h6'." %>

<%@ attribute name="headingTabindex" type="java.lang.Boolean" required="false"
    description="Controls adding the 'tabindex' attribute to the generated heading.
    If not set, use default 'true' when 'hsize' is in range 1 to 4, 'false' for all other sizes.
    If 'false' is set explicitly, supress genertion of tabindex attribute for all sizes" %>

<%@ attribute name="showImageCopyright" type="java.lang.Boolean" required="false"
    description="Controls if the image copyright is displayed as image overlay. Default is 'false'." %>

<%@ attribute name="showImageSubtitle" type="java.lang.Boolean" required="false"
    description="Controls if the image subtitle is displayed below the image. Default is 'false'." %>

<%@ attribute name="showImageZoom" type="java.lang.Boolean" required="false"
    description="Controls if a zoom option for the image is displayed. Default is 'true'." %>

<%@ attribute name="showImageLink" type="java.lang.Boolean" required="false"
    description="Controls if image is linked or not. Default is 'false'." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="false"
    description="Controls if ADE is enabled or not. Default is 'true'." %>

<%@ attribute name="emptyWarning" type="java.lang.Boolean" required="false"
    description="If 'true', a warning is shown in offline mode in case no content has been generated. Default is 'true'." %>

<%@ attribute name="markupVisual" fragment="true" required="false"
    description="Markup shown for the visual if the visual is not an image.
    If both attributes 'markupVisual' and 'image' are provided, only the 'markupVisual' will be displayed." %>

<%@ attribute name="cssVisual" type="java.lang.String" required="false"
    description="'class' selectors to add to the tag surrounding the visual." %>

<%@ attribute name="markupText" fragment="true" required="false"
    description="Markup shown for the text if the text is not an XML content value.
    If both attributes 'markupText' and 'text' are provided, only the 'markupText' will be displayed." %>

<%@ attribute name="cssText" type="java.lang.String" required="false"
    description="'class' selectors to add to the tag surrounding the text." %>

<%@ attribute name="addHeadingId" type="java.lang.Boolean" required="false"
    description="Adds an automatically generated ID attribute for the heading, for use in anchor links.
    The ID attribute will be generated from the provided text, which will be translated according to the configured file name translation rules.
    The result will also be all lower case.
    Default is 'false' if not provided." %>

<%@ attribute name="addHeadingAnchorlink" type="java.lang.Boolean" required="false"
    description="Adds a heading anchor link after the heading that can be used do easily bookmark or link to this heading.
    If this option is 'true', then the value of 'addHeadingId' is ignored and the ID is always generated.
    Default is 'false' if not provided." %>

<%@ attribute name="piecePreMarkup" type="java.lang.String" required="false"
    description="Markup to add inside the piece before the heading, body and everything else." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="ade"                value="${empty ade ? cms.isEditMode : ade}" />
<c:set var="linkHeading"        value="${empty linkOption or empty link ? false : (linkOption eq 'heading')}" />
<c:set var="headingTabindex"    value="${empty headingTabindex ? true : headingTabindex}" />
<c:set var="hsize"              value="${empty hsize ? 2 : (hsize < 1 ? (linkHeading ? 3 : hsize) : hsize)}" />
<c:set var="showText"           value="${empty text and empty markupText ? false : (empty textOption ? true : (textOption ne 'none'))}" />
<c:set var="sizeDesktop"        value="${imageRatioLg eq 'no-img' ? 0 : sizeDesktop}" />
<c:set var="sizeMobile"         value="${imageRatio eq 'no-img' ? 0 : ((sizeDesktop == 0) and (sizeMobile == 99)  ? 12 : sizeMobile)}" />
<c:set var="showVisualDesktop"  value="${empty image and empty markupVisual ? false : (empty sizeDesktop ? true : sizeDesktop != 0)}" />
<c:set var="showVisualMobile"   value="${empty image and empty markupVisual ? false : (empty sizeMobile ? true : sizeMobile != 0)}" />
<c:set var="showVisual"         value="${showVisualDesktop or showVisualMobile}" />
<c:set var="showHeading"        value="${empty heading or (hsize < 1) ? false : (empty headingOption ? true : (headingOption ne 'none'))}" />
<c:set var="showLinkOption"     value="${empty linkOption or linkHeading ? true : (linkOption ne 'none') and (linkOption ne 'false')}" />
<c:set var="showLink"           value="${empty link or linkHeading ? false : showLinkOption}" />
<c:set var="defaultText"        value="${showText and empty markupText}" />

<c:choose>
<c:when test="${showHeading or showText or showVisual or showLink}">

    <c:if test="${showVisual and empty markupVisual}">
        <%-- To set the visual css wrapper, the image orientation must be known. Also check if the image is from the icon folder. --%>
        <m:image-vars
            image="${image}"
            ratio="${showVisualMobile ? imageRatio : imageRatioLg}"
            ade="${false}">
                <c:set var="showVisual" value="${not empty imageBean}" />
                <c:set var="isIconImage" value="${imageIsSvg and fn:startsWith(imageBean.resource.rootPath, '/system/modules/alkacon.mercury.theme/icons/')}" />
                <c:set var="visualOrientation" value="${' '.concat(imageOrientation)}" />
        </m:image-vars>
    </c:if>

    <%-- pmv class: (p)iece (m)inimum (v)isual - set width to 32px for icons --%>
    <m:piece
        cssWrapper="${cssWrapper}${isIconImage ? ' pmv' : ''}"
        attrWrapper="${attrWrapper}"
        pieceLayout="${pieceLayout}"
        sizeDesktop="${sizeDesktop}"
        sizeMobile="${sizeMobile}"
        pieceTag="${pieceTag}"
        pieceClass="${pieceClass}"
        piecePreMarkup="${piecePreMarkup}"
        cssText="${showText and (textOption ne 'default') ? textOption : ''}${not empty cssText ? ' '.concat(cssText) : null}"
        attrVisual="${ade ? image.rdfaAttr : null}"
        cssVisual="rs_skip${visualOrientation}${not empty cssVisual ? ' '.concat(cssVisual) : null}"
        textAlignment="${textAlignment}"
        attrBody="${ade and showLinkOption and cms:isWrapper(link) and (empty link or (link.exists and not link.isSet)) ? link.rdfaAttr : null}"
        cssBody="${defaultText ? 'default' : null}"
        attrText="${ade ? text.rdfaAttr : null}"
        attrLink="${ade and cms:isWrapper(link) ? link.rdfaAttr : null}">

        <jsp:attribute name="heading">
            <c:if test="${showHeading}">
                <c:set var="headingCss" value="piece-heading" />
                <c:if test="${addHeadingId or addHeadingAnchorlink}">
                    <c:set var="headingId"><m:translate-name name="${fn:trim(heading)}" />-${fn:substringBefore(cms.element.instanceId, '-')}</c:set>
                    <c:if test="${addHeadingAnchorlink}">
                        <c:set var="anchorLinkSuffix"><a class="anchor-link" href="#${headingId}"></a></c:set>
                        <c:set var="headingCss" value="piece-heading anchor-link-parent" />
                    </c:if>
                </c:if>
                <c:choose>
                    <c:when test="${linkHeading and not suppressLinks}">
                        <m:heading
                            level="${hsize}"
                            suffix="${anchorLinkSuffix}"
                            tabindex="${headingTabindex and (empty anchorLinkSuffix)}"
                            headingAsDiv="${headingAsDiv}"
                            ade="${false}"
                            css="${headingCss}"
                            id="${headingId}">
                            <jsp:attribute name="markupText">
                                <m:link link="${link}" css="piece-heading-link" setTitle="true">
                                    <c:out value="${heading}" />
                                </m:link>
                            </jsp:attribute>
                        </m:heading>
                    </c:when>
                    <c:otherwise>
                        <m:heading
                            text="${heading}"
                            level="${hsize}"
                            suffix="${anchorLinkSuffix}"
                            tabindex="${headingTabindex}"
                            headingAsDiv="${headingAsDiv}"
                            ade="${ade}"
                            css="${headingCss}"
                            id="${headingId}"
                        />
                    </c:otherwise>
                </c:choose>
            </c:if>
        </jsp:attribute>

        <jsp:attribute name="visual">
            <%-- Note: It is important set the image inside the attribute, because otherwise the cssgrid for the image size is not calculated correctly. --%>
            <%-- However, to set the visual css wrapper, the image orientation must be known - hence the image vars must be read above. --%>
            <c:choose>
                <c:when test="${showVisual and empty markupVisual}">
                    <c:set var="showImageLink"  value="${empty showImageLink or suppressLinks ? false : showImageLink}" />
                    <c:set var="showImageZoom" value="${suppressLinks ? false : (empty showImageZoom ? true : showImageZoom)}" />
                    <m:link
                        link="${link}"
                        test="${showImageLink}"
                        attr="${showLink or linkHeading ? 'tabindex=\"-1\"' : ''}"
                        setTitle="${true}" >
                        <m:image-animated
                            image="${image}"
                            ratio="${imageRatio}"
                            ratioLg="${imageRatioLg}"
                            setTitle="${not showImageLink}"
                            showCopyright="${showImageCopyright}"
                            showImageZoom="${showImageZoom and not showImageLink}"
                            ade="${ade}">
                            <c:set var="imageSubtext">
                                <c:if test="${showImageSubtitle and not empty imageTitle}">
                                    <div class="subtitle"${showImageLink ? '' : ' aria-hidden=\"true\"'}>${imageTitle}</div><%----%>
                                </c:if>
                            </c:set>
                        </m:image-animated>
                    </m:link>
                    <c:out value="${imageSubtext}" escapeXml="false" />
                </c:when>
                <c:when test="${showVisual}">
                    <jsp:invoke fragment="markupVisual"/>
                </c:when>
            </c:choose>
        </jsp:attribute>

        <jsp:attribute name="text">
            <c:choose>
                <c:when test="${defaultText}">
                    <c:out value="${text}" escapeXml="false" />
                </c:when>
                <c:when test="${showText}">
                    <jsp:invoke fragment="markupText"/>
                </c:when>
            </c:choose>
        </jsp:attribute>

        <jsp:attribute name="link">
            <c:if test="${showLink}">
                <c:choose>
                    <c:when test="${linkOption eq 'button-full'}">
                        <c:set var="linkCss" value="btn btn-block piece-btn" />
                    </c:when>
                    <c:when test="${linkOption eq 'button-sm'}">
                        <c:set var="linkCss" value="btn btn-sm piece-btn" />
                    </c:when>
                    <c:when test="${linkOption eq 'text'}">
                        <c:set var="linkCss" value="piece-text-link" />
                    </c:when>
                    <c:when test="${fn:startsWith(linkOption, 'custom=')}">
                        <c:set var="linkCss" value="${fn:substringAfter(linkOption, 'custom=')}" />
                    </c:when>
                    <c:otherwise>
                        <%-- default is 'button' --%>
                        <c:set var="linkCss" value="btn piece-btn" />
                    </c:otherwise>
                </c:choose>
                <m:link link="${link}" css="${linkCss}" createSpan="${suppressLinks}" />
            </c:if>
        </jsp:attribute>

    </m:piece>
</c:when>
<c:when test="${cms.isEditMode and (empty emptyWarning or emptyWarning)}">
    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">
        <m:alert type="warning">
            <jsp:attribute name="head">
                <fmt:message key="msg.page.section.empty.head" />
            </jsp:attribute>
            <jsp:attribute name="text">
                <div><fmt:message key="msg.page.section.empty.text" /></div>
                <div class="small">${cms.element.sitePath}</div>
            </jsp:attribute>
        </m:alert>
    </cms:bundle>
</c:when>
</c:choose>