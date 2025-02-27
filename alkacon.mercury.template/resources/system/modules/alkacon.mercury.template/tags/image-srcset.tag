<%@ tag pageEncoding="UTF-8"
    display-name="image-srcset"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates source set data for an image." %>


<%@ attribute name="imagebean" type="org.opencms.jsp.util.CmsJspImageBean" required="true"
    description="The image bean to generate source set for."%>

<%@ attribute name="src" type="java.lang.String" required="false"
    description="'src' atttribute to set on the generated img tag."%>

<%@ attribute name="width" type="java.lang.String" required="false"
    description="'width' atttribute to set on the generated img tag."%>

<%@ attribute name="height" type="java.lang.String" required="false"
    description="'height' atttribute to set on the generated img tag."%>

<%@ attribute name="alt" type="java.lang.String" required="false"
    description="'alt' atttribute to set on the generated img tag."%>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="'title' atttribute to set on the generated img tag."%>

<%@ attribute name="copyright" type="java.lang.String" required="false"
    description="Copyright information to display as an image overlay. If this is emtpy, no copyright overlay will be displayed." %>

<%@ attribute name="srcSet" type="java.lang.Boolean" required="false"
    description="Generate image source set data or not?"%>

<%@ attribute name="sizes" type="java.lang.String" required="false"
    description="Sizes (width in pixel) to create image variations for. This must be a comma separated list e.g. '100,200,400,800'." %>

<%@ attribute name="lazyLoad" type="java.lang.Boolean" required="false"
    description="Use lazy loading or not? Default is 'true'."%>

<%@ attribute name="lazyLoadAutoSizes" type="java.lang.Boolean" required="false"
    description="false (default): use lazy loading with 'sizes' being calculated from the bootstrap bean. true: use lazy loading and require 'sizes: auto' to work - this will (for now) use JavaScript instead of native browser support."%>

<%@ attribute name="addPaddingBox" type="java.lang.Boolean" required="false"
    description="Add a padding box (div with class 'presized') around the image? If 'true' the box will be added when needed. If 'false' no box will be added. Default is 'true'."%>

<%@ attribute name="noScript" type="java.lang.Boolean" required="false"
    description="Generate noscript tags for lazy loading images or not? Default is 'true'." %>

<%@ attribute name="isSvg" type="java.lang.Boolean" required="false"
    description="Can be set if the type of the image is known as SVG in advance. If this is NOT set, then the type is determined from the image name." %>

<%@ attribute name="cssImage" type="java.lang.String" required="false"
    description="'class' atttribute to set directly on the generated img tag."%>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' atttribute to set on the src-box div surrounding the generated img." %>

<%@ attribute name="attrImage" type="java.lang.String" required="false"
    description="Attribute(s) to add directly to the generated img tag." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attribute(s) to add on the src-box div surrounding the generated img." %>

<%@ attribute name="zoomData" type="java.lang.String" required="false"
    description="Zoom data attribute added directly to the generated image tag." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<%--
Supported techniques and variations:

SrcSet support
    Using a special "Boostrap Bean", we keep track of the size of the current space (width) for the image.
    We calculate a pixel with for all 5 BS grid sizes and also 2x for retina displays.
    For the smallest size XS, images will often occupy the whole space (100vw).
    For this case we generate a set of size reduced version based on the width from the original image.
    We also keep track if "hidden-xs" BS classes are used.
Lazy loading support
    Support for lazy loading of images using the native browser <img loading="lazy"> functionality.
    Not longer based on the great 'Lazysizes' script (see https://github.com/aFarkas/lazysizes).
Noscript support
    Support for generating <noscript> tags in case lazy loading is active.
    This will add a <noscript> element with a standed im tag.
    Keep in mind that in the <noscript> case, the first img tag is still visible, so we need to hide this by CSS.
    Moreover, because the dynamic list generates a <noscript> version of the whole list,
    we must never create <noscript> tags for images already in the <noscript> list.
SVG placeholder image, background image and image sizing
    In case lazy loading is active, a special combination of srcset tags is used to make sure no image is
    is loaded by the browser, see https://github.com/aFarkas/lazysizes#modern-transparent-srcset-pattern.
    To minimize reflows when loading the page, we use a technique describes here
    https://github.com/aFarkas/lazysizes#tip-specifying-image-dimensions-minimizing-reflows-and-avoiding-page-jumps
--%>

<m:list-element-status>

<c:set var="ib" value="${imagebean}" />

<c:set var="aboveTheFold" value="${false}" /><%-- Setting this currently leads to loading for more images from srcset than required --%>
<c:set var="useLazyLoading" value="${(empty lazyLoad or lazyLoad) and not aboveTheFold}" />
<c:set var="useJsLazyLoading" value="${(lazyLoadAutoSizes or useLazyLoading) and not caseDynamicListNoscript}" /><%-- This will finally be set after the Bootstrap grid config has been read --%>
<c:set var="isSvg" value="${empty isSvg ? fn:endsWith(ib.vfsUri, '.svg') : isSvg}" />
<c:set var="useSrcSet" value="${(empty srcSet or srcSet) and not isSvg and not caseDynamicListNoscript}" />
<c:set var="useNoScript" value="${(empty noScript or noScript) and not caseDynamicListNoscript and not caseDynamicListAjax}" />
<c:set var="customSizes" value="${not empty sizes}" />

<%-- Enable / disable output for debug purposes if required by setting DEBUG="${true}" --%>
<c:set var="DEBUG" value="${param.imgScrSetDebug eq '1'}" />

<m:print comment="${true}" test="${DEBUG}">
image-srcset parameters:

isSvg: ${isSvg}
customSizes: ${customSizes}
useLazyLoading: ${useLazyLoading}
useJsLazyLoading: ${useJsLazyLoading}
aboveTheFold: ${aboveTheFold}
useSrcSet: ${useSrcSet}
useNoScript: ${useNoScript}
</m:print>

<c:if test="${not isSvg}">

    <m:image-sizes debug="${DEBUG}" lazyLoad="${useLazyLoading}" initBootstrapBean="${not customSizes}">

        <c:set var="useJsLazyLoading" value="${useJsLazyLoading and (lazyLoadAutoSizes or bsLazyLoadJs)}" />
        <c:set var="sizeXsMax" value="${bb.getGridSize(0) - bb.gutter}" />

        <c:if test="${useSrcSet and bbInitialized}">
            <c:set var="srcSetSizes" value="${bbSrcSetSizes}" />
        </c:if>

        <c:choose>
            <c:when test="${not customSizes}">

                <m:print comment="${true}" test="${DEBUG}">
                    image-srcset srcSet base image settings:

                    bbFullWidth: ${bbFullWidth eq true}
                    ib.vfsUri: ${ib.vfsUri}
                    ib.scaler.width: ${ib.scaler.width}
                    ib.scaler.height: ${ib.scaler.height}
                    ib.ratio: ${ib.ratio}
                    ib.scaler.pixelCount: ${ib.scaler.pixelCount}
                    useJsLazyLoading: ${useJsLazyLoading}
                    useSrcSet and bbInitialized: ${useSrcSet and bbInitialized}
                </m:print>

                <c:if test="${ib.scaler.width > maxScaleWidth}">
                    <c:set var="ib" value="${ib.scaleWidth[maxScaleWidth]}" />
                </c:if>

                <c:if test="${useSrcSet and bbInitialized}">

                    <%-- Calculate size based on the current bootstrap grid. --%>
                    <c:if test="${bb.sizeXs > 0}">
                        <c:if test="${maxScaleWidth > (2 * bb.sizeXs)}">
                            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeXs]}" />
                        </c:if>
                        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeXs]}" />
                        <c:set var="largestWidth" value="${bb.sizeXs}" />
                    </c:if>
                    <c:if test="${bb.sizeSm > 0}">
                        <c:if test="${maxScaleWidth > (2 * bb.sizeSm)}">
                            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeSm]}" />
                        </c:if>
                        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeSm]}" />
                        <c:set var="largestWidth" value="${bb.sizeSm}" />
                    </c:if>
                    <c:if test="${bb.sizeMd > 0}">
                        <c:if test="${maxScaleWidth > (2 * bb.sizeMd)}">
                            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeMd]}" />
                        </c:if>
                        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeMd]}" />
                        <c:set var="largestWidth" value="${bb.sizeMd}" />
                    </c:if>
                    <c:if test="${bb.sizeLg > 0}">
                        <c:if test="${maxScaleWidth > (2 * bb.sizeLg)}">
                            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeLg]}" />
                        </c:if>
                        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeLg]}" />
                        <c:set var="largestWidth" value="${bb.sizeLg}" />
                    </c:if>
                    <c:if test="${bb.sizeXl > 0}">
                        <c:if test="${maxScaleWidth > (2 * bb.sizeXl)}">
                            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeXl]}" />
                        </c:if>
                        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeXl]}" />
                        <c:set var="largestWidth" value="${bb.sizeXl}" />
                    </c:if>
                    <c:if test="${bb.sizeXxl > 0}">
                        <c:if test="${maxScaleWidth > (2 * bb.sizeXxl)}">
                            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeXxl]}" />
                        </c:if>
                        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeXxl]}" />
                        <c:set var="largestWidth" value="${bb.sizeXxl}" />
                    </c:if>
                    <c:if test="${bbFullWidth}">
                        <%-- Add size variations to avoid offering only one very large image for full screen backgrounds --%>
                        <c:set var="scaleGapStep" value="${Math.round((ib.scaler.width - largestWidth) / 4)}" />
                        <m:print comment="${true}" test="${DEBUG}">
                            image-srcset optimizing for full width:

                            ib.scaler.width: ${ib.scaler.width}
                            largest width: ${largestWidth}
                            scaleGapStep: ${scaleGapStep}
                        </m:print>
                        <c:if test="${scaleGapStep > 100}">
                            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[largestWidth + scaleGapStep]}" />
                            <c:if test="${maxScaleWidth > 2 * (largestWidth + scaleGapStep)}">
                                <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * (largestWidth + scaleGapStep)]}" />
                            </c:if>
                            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[largestWidth + 2 * scaleGapStep]}" />
                            <c:if test="${maxScaleWidth > 2 * (largestWidth + 2 * scaleGapStep)}">
                                <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[largestWidth + 2 * scaleGapStep]}" />
                            </c:if>
                            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[largestWidth + 3 * scaleGapStep]}" />
                            <c:if test="${maxScaleWidth > 2 * (largestWidth + 3 * scaleGapStep)}">
                                <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[largestWidth + 3 * scaleGapStep]}" />
                            </c:if>
                        </c:if>
                        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[ib.scaler.width]}" />
                    </c:if>
                </c:if>

                <c:if test="${useSrcSet and (useLazyLoading or bbInitialized)}" >
                    <%-- Lazy loading will generate the sizes attribute by JS --%>
                    <%-- Otherwise we get the grid sizes information from the bean --%>
                    <c:if test="${not bbInitialized or (bb.sizeXs >= sizeXsMax)}">
                        <%-- Add size based versions for large images --%>
                        ${ib.addSrcSetWidthVariants(640, maxScaleWidth)}
                    </c:if>
                </c:if>

                <c:if test="${DEBUG}">
                    <c:set var="attrImage">${attrImage} data-grid-classes="${bb.css}" data-grid-size="${bb}"</c:set>
                </c:if>

            </c:when>
            <c:otherwise>

                <c:set var="maxImageWidth" value="${0}" />
                <c:set var="sizeList" value="${fn:split(sizes, ',')}" />
                <m:print comment="${true}" test="${DEBUG}">
                    custom sizes: [${sizes}]
                    ib.width: ${ib.width}
                    ib.height: ${ib.height}
                </m:print>
                <c:forEach var="sizeStr" items="${sizeList}">
                    <c:set var="sizeInt" value="${cms.wrap[sizeStr].toInteger}" />
                    <c:set var="sizeTwice" value="${(sizeInt * 2) > ib.width ?  ib.width : sizeInt * 2}" />
                    <c:set var="sizeOnce" value="${sizeInt > ib.width ?  ib.width : sizeInt}" />
                    <c:set var="scaleTwice" value="${ib.scaleWidth[sizeTwice]}" />
                    <c:set var="scaleOnce" value="${ib.scaleWidth[sizeOnce]}" />
                    <m:print comment="${true}" test="${DEBUG}">
                        adding sizeOnce: ${sizeOnce}
                        adding sizeTwice: ${sizeTwice}
                    </m:print>
                    <c:set target="${ib}" property="srcSets" value="${scaleTwice}" />
                    <c:set target="${ib}" property="srcSets" value="${scaleOnce}" />
                    <c:if test="${sizeOnce > maxImageWidth}">
                        <c:set var="maxImageWidth" value="${sizeOnce}" />
                        <c:set var="maxImage" value="${ib.scaleWidth[maxImageWidth]}" />
                    </c:if>
                </c:forEach>
                <m:print comment="${true}" test="${DEBUG}">
                    using maxImageWidth: ${maxImageWidth}
                </m:print>
            </c:otherwise>
        </c:choose>

        <c:if test="${useSrcSet and (useLazyLoading or customSizes or bbInitialized)}" >
            <%-- Set quality higher for smaller images to avoid blur --%>
            <c:forEach var="vb" items="${ib.srcSetMap.values()}">
                <c:set var="pixels" value="${vb.scaler.width * vb.scaler.height}" />
                <c:choose>
                    <c:when test="${pixels <= 10000}"><%-- 100 x 100 --%>
                        <c:set target="${vb}" property="quality" value="${95}" />
                    </c:when>
                    <c:when test="${pixels <= 40000}"><%-- 200 x 200 --%>
                        <c:set target="${vb}" property="quality" value="${90}" />
                    </c:when>
                    <c:when test="${pixels <= 90000}"><%-- 300 x 300 --%>
                        <c:set target="${vb}" property="quality" value="${85}" />
                    </c:when>
                    <c:when test="${pixels <= 160000}"><%-- 400 x 400 --%>
                        <c:set target="${vb}" property="quality" value="${80}" />
                    </c:when>
                    <%-- Otherwise default quality will be used --%>
                </c:choose>
            </c:forEach>
            <c:choose>
                <c:when test="${ib.srcSetMap.size() == 1}">
                    <c:set var="ib" value="${ib.getSrcSetMaxImage()}" />
                </c:when>
                <c:when test="${ib.srcSetMap.size() > 1}">
                    <%-- We only need a srcSet if we have more then one image variation --%>
                    <c:set var="srcset" value="${ib.srcSet}" />
                </c:when>
            </c:choose>
        </c:if>

    </m:image-sizes>

</c:if>

<c:choose>
    <c:when test="${isSvg}">
        <c:choose>
            <c:when test="${fn:startsWith(ib.resource.rootPath, '/system/modules/alkacon.mercury.theme/icons/')}">
                <c:set var="inlineSvgProp" value="ico-svg ico-img" />
                <c:set var="inlineSvg" value="${true}" />
            </c:when>
            <c:otherwise>
                <c:set var="inlineSvgProp" value="${ib.resource.property['image.svg.inline']}" />
                <c:set var="inlineSvg" value="${not empty inlineSvgProp}" />
            </c:otherwise>
        </c:choose>
        <c:set var="srcurl"><cms:link>${ib.vfsUri}</cms:link></c:set>
        <c:set var="attrImage" value="${inlineSvg ? 'role=\"img\"'.concat(not empty attrImage ? ' '.concat(attrImage) : '') : attrImage}" />
        <m:print comment="${true}" test="${DEBUG}">
            image-srcset SVG handling:

            ib.vfsUri: ${ib.vfsUri}
            inlineSvg: ${inlineSvg}
            inlineSvgProp: [${inlineSvgProp}]
        </m:print>
    </c:when>
    <c:when test="${not empty srcset}">
        <c:set var="srcurl" value="${not empty maxImage ? maxImage.srcUrl : ib.getSrcSetMaxImage().srcUrl}" />
        <c:set var="ib" value="${not empty maxImage ? maxImage : ib}" />
    </c:when>
    <c:otherwise>
        <c:set var="srcurl" value="${ib.srcUrl}" />
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${inlineSvg}">
        <c:set var="cssImage" value="${empty cssImage ? inlineSvgProp : cssImage.concat(' ').concat(inlineSvgProp)}" />
        <m:image-svg-inline
            imagebean="${ib}"
            width="${ib.scaler.width}"
            height="${ib.scaler.height}"
            heightPercentage="${ib.ratioHeightPercentage}"
            alt="${alt}"
            title="${title}"
            copyright="${copyright}"
            cssImage="${cssImage}"
            cssWrapper="${cssWrapper}"
            attrImage="${attrImage}"
            attrWrapper="${attrWrapper}"
            zoomData="${zoomData}"
        />
    </c:when>
    <c:otherwise>
        <m:image-lazyload
            srcUrl="${srcurl}"
            srcSet="${srcset}"
            srcSetSizes="${srcSetSizes}"
            width="${ib.scaler.width}"
            height="${ib.scaler.height}"
            heightPercentage="${ib.ratioHeightPercentage}"
            lazyLoad="${useLazyLoading}"
            lazyLoadJs="${useJsLazyLoading}"
            addPaddingBox="${addPaddingBox}"
            noScript="${useNoScript}"
            alt="${alt}"
            title="${title}"
            copyright="${copyright}"
            cssImage="${cssImage}"
            cssWrapper="${cssWrapper}"
            attrImage="${attrImage}"
            attrWrapper="${attrWrapper}"
            zoomData="${zoomData}"
            debug="${DEBUG}"
        />
    </c:otherwise>
</c:choose>

</m:list-element-status>