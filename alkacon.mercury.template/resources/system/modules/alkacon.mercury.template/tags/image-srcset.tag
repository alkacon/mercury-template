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
    description="Copyright information to display as an image overlay.
    If this is emtpy, no copyright overlay will be displayed." %>

<%@ attribute name="srcSet" type="java.lang.Boolean" required="false"
    description="Generate image source set data or not?"%>

<%@ attribute name="sizes" type="java.lang.String" required="false"
    description="Container sizes to create image variations for.
    This must be a comma separated list e.g. '100,200,400,800'." %>

<%@ attribute name="lazyLoad" type="java.lang.Boolean" required="false"
    description="Use lazy loading or not?"%>

<%@ attribute name="noScript" type="java.lang.Boolean" required="false"
    description="Generate noscript tags for lazy loading images or not?
    Default is 'true'." %>

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
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<%--
Supported techniques and variations:

SrcSet support
    Using a special "Boostrap Bean", we keep track of the size of the current space (width) for the image.
    We calculate a pixel with for all 5 BS grid sizes and also 2x for retina displays.
    For the smallest size XS, images will often occupy the whole space (100vw).
    For this case we generate a set of size reduced version based on the width from the original image.
    We also keep track if "hidden-xs" BS classes are used.
Lazy loading support
    Support for lazy loading of images based on the great 'Lazysizes' script.
    See https://github.com/aFarkas/lazysizes.
    Obviously this requires JavaScript to be enabled.
Noscript support
    Support for generating <noscript> tags in case lazy loading is active.
    This will add a <noscript> element with a standed im tag.
    Keep in mind that in the <noscript> case, the first img tag is still visible, so we need to hide this by CSS.
    Moreover, because the dynamic list generates a <noscript> version of the whole list,
    we must never create <noscript> tags for images already in the <noscript> list.
SVG placeholder image, background image and image sizing
    In case lazy loading is active, a special combination of srcset tags is used to make sure no image is
    is loaded by the browser, see https://github.com/aFarkas/lazysizes#modern-transparent-srcset-pattern.
    To minimize refows when loading the page, we use a technique describes here
    https://github.com/aFarkas/lazysizes#tip-specifying-image-dimensions-minimizing-reflows-and-avoiding-page-jumps
--%>

<mercury:list-element-status>

<c:set var="ib" value="${imagebean}" />

<c:set var="useLazyLoading" value="${(empty lazyLoad or lazyLoad) and not caseDynamicListNoscript}" />
<c:set var="isSvg" value="${fn:endsWith(ib.vfsUri, '.svg')}" />
<c:set var="useSrcSet" value="${(empty srcSet or srcSet) and not caseDynamicListNoscript and not isSvg}" />
<c:set var="useNoScript" value="${(empty noScript or noScript) and not caseDynamicListNoscript and not caseDynamicListAjax}" />
<c:set var="useSizes" value="${not empty sizes}" />

<%-- ###### Enable / disable output for debug purposes if required by setting DEBUG="${true}" ###### --%>
<c:set var="DEBUG" value="${false}" />

<c:if test="${DEBUG}">
<!--
image-srcset parameters:

isSvg=${isSvg}
useSizes=${useSizes}
useLazyLoading=${useLazyLoading}
useSrcSet=${useSrcSet}
useNoScript=${useNoScript}
-->
</c:if>

<c:if test="${not isSvg}">

<mercury:image-sizes debug="${DEBUG}">

<c:choose>
<c:when test="${not useSizes}">
    <jsp:useBean id="bb" class="alkacon.mercury.template.CmsJspBootstrapBean">

    <c:forEach var="grid" items="${paramValues.cssgrid}">
        <c:if test="${fn:contains(grid, 'fullwidth')}">
            <c:set var="fullwidth" value="${true}" />
        </c:if>
    </c:forEach>

    <c:choose>
        <c:when test="${fullwidth}">
            <%-- ###### Assume all images are full screen ###### --%>
            ${bb.setGutter(0)}
            ${bb.setGridSize(0, bsBpSm)}
            ${bb.setGridSize(1, bsBpMd)}
            ${bb.setGridSize(2, bsBpLg)}
            ${bb.setGridSize(3, bsBpXl)}
            ${bb.setGridSize(4, maxScaleWidth)}
        </c:when>
        <c:otherwise>
            <%-- ###### Calculate image size based on column width ###### --%>
            <c:set var="gutter" value="${param.cssgutter}" />
            <c:set var="gutterAdjust" value="${0}" />
            <c:set var="gutterInt" value="${bsGutter}" />
            <c:if test="${not empty gutter and gutter ne '#'}">
                <%-- ###### A custom gutter has been set, adjust  gutter in bean ###### --%>
                <c:set var="gutterInt" value="${cms:toNumber(gutter, gutterInt)}" />
                ${bb.setGutter(gutterInt)}
                <c:if test="${gutter ne param.cssgutterbase}">
                    <%-- ###### Special case: Gutter has been changed in template (e.g. logo slider does this).
                                Adjust size of total width accordingly otherwise calulation is incorrect. ###### --%>
                    <c:set var="gutterBaseInt" value="${cms:toNumber(param.cssgutterbase, -1)}" />
                    <c:if test="${gutterBaseInt >= 0}">
                        <c:set var="gutterAdjust" value="${gutterBaseInt - gutterInt}" />
                    </c:if>
                </c:if>
                <c:if test="${DEBUG}">
<!--
image-srcset gutter adjust:

param.cssgutter: [${param.cssgutter}]
bsGutter: ${bsGutter}
gutterInt: ${gutterInt}
bb.gutter: ${bb.gutter}
gutterAdjust: ${gutterAdjust}
-->
                </c:if>
            </c:if>
            ${bb.setGutter(gutterInt)}
            ${bb.setGridSize(0, bsMwXs - gutterAdjust)}
            ${bb.setGridSize(1, bsMwSm - gutterAdjust)}
            ${bb.setGridSize(2, bsMwMd - gutterAdjust)}
            ${bb.setGridSize(3, bsMwLg - gutterAdjust)}
            ${bb.setGridSize(4, bsMwXl - gutterAdjust)}
        </c:otherwise>
    </c:choose>

    <c:set var="sizeXsMax" value="${bb.getGridSize(0) - bb.gutter}" />
    <jsp:setProperty name="bb" property="cssArray" value="${paramValues.cssgrid}" />

    <c:if test="${DEBUG}">
<!--
image-srcset calculated grid values::

fullwidth: ${fullwidth eq true}
ib.scaler.width: ${ib.scaler.width}

Gutter: ${bb.gutter}
Max scale width: ${maxScaleWidth}

Max width XS: ${bb.getGridSize(0)}
Max width SM: ${bb.getGridSize(1)}
Max width MD: ${bb.getGridSize(2)}
Max width LG: ${bb.getGridSize(3)}
Max width XL: ${bb.getGridSize(4)}
<mercury:nl />
<c:forEach var="grid" items="${paramValues.cssgrid}">
grid: ${grid}
</c:forEach>
 -->
    </c:if>

    <c:if test="${ib.scaler.width > maxScaleWidth}">
        <c:set var="ib" value="${ib.scaleWidth[maxScaleWidth]}" />
    </c:if>

    <c:if test="${useSrcSet and bb.isInitialized}">

        <c:if test="${not useLazyLoading}">
            <%-- ###### Calculate the sizes (if we are lazy loading the script will do this for us) ###### --%>
            <c:set var="srcSetSizes"><%--
            --%>(min-width: ${bsMwXl}px) ${bb.sizeXl}px, <%--
            --%>(min-width: ${bsMwLg}px) ${bb.sizeLg}px, <%--
            --%>(min-width: ${bsMwMd}px) ${bb.sizeMd}px, <%--
            --%>(min-width: ${bsMwSm}px) ${bb.sizeSm}px, <%--
            --%>100vw</c:set>
        </c:if>

        <%-- ###### Calculate size based on the current bootstrap grid. ###### --%>
        <c:if test="${bb.sizeXs > -1}">
            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeXs]}" />
            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeXs]}" />
        </c:if>
        <c:if test="${bb.sizeSm > -1}">
            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeSm]}" />
            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeSm]}" />
        </c:if>
        <c:if test="${bb.sizeMd > -1}">
            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeMd]}" />
            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeMd]}" />
        </c:if>
        <c:if test="${bb.sizeLg > -1}">
            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeLg]}" />
            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeLg]}" />
        </c:if>
        <c:if test="${bb.sizeXl > -1}">
            <c:if test="${fullwidth}">
                <%-- Add size variations to avoid offering only one very large image for full screen backgrounds --%>
                <c:set var="scaleGapStep" value="${Math.round((ib.scaler.width - bsBpXl) / 4)}" />
                <c:if test="${DEBUG}">
<!--
image-srcset optimizing for full width:

ib.scaler.width: ${ib.scaler.width}
bsBpXl: ${bsBpXl}
scaleGapStep: ${scaleGapStep}
-->
                </c:if>
                <c:if test="${scaleGapStep > 100}">
                    <c:if test="${maxScaleWidth > 2 * (bsBpXl + scaleGapStep)}">
                        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * (bsBpXl + scaleGapStep)]}" />
                    </c:if>
                    <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bsBpXl + scaleGapStep]}" />
                    <c:if test="${maxScaleWidth > 2 * (bsBpXl + 2 * scaleGapStep)}">
                        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bsBpXl + 2 * scaleGapStep]}" />
                    </c:if>
                    <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bsBpXl + 2 * scaleGapStep]}" />
                    <c:if test="${maxScaleWidth > 2 * (bsBpXl + 3 * scaleGapStep)}">
                        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bsBpXl + 3 * scaleGapStep]}" />
                    </c:if>
                    <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bsBpXl + 3 * scaleGapStep]}" />
                </c:if>
            </c:if>
            <c:if test="${maxScaleWidth > (2 * bb.sizeXl)}">
                <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[2 * bb.sizeXl]}" />
            </c:if>
            <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[bb.sizeXl]}" />
        </c:if>
    </c:if>

    <c:set var="bbInitialized" value="${bb.isInitialized}" />

    <c:if test="${useSrcSet and (useLazyLoading or bbInitialized)}" >
        <%-- ###### Lazy loading will generate the sizes attribute by JS ###### --%>
        <%-- ###### Otherwise we get the grid sizes information from the bean ###### --%>
        <c:if test="${not bbInitialized or (bb.sizeXs >= sizeXsMax)}">
            <%-- ###### Add size based versions for large images ###### --%>
            ${ib.addSrcSetWidthVariants(640, maxScaleWidth)}
        </c:if>
    </c:if>

    <c:if test="${DEBUG}">
        <c:set var="attrImage">${attrImage} data-grid-classes="${bb.css}" data-grid-size="${bb}"</c:set>
    </c:if>

    </jsp:useBean>

</c:when>
<c:otherwise>

    <c:set var="maxSize" value="${0}" />
    <c:set var="sizeList" value="${fn:split(sizes, ',')}" />
    <c:if test="${DEBUG}">
        <!-- sizes:[${sizes}] ib.width:${ib.width} -->
    </c:if>
    <c:forEach var="sizeStr" items="${sizeList}">
        <c:set var="sizeInt" value="${cms.wrap[sizeStr].toInteger}" />
        <c:if test="${DEBUG}">
            <!-- adding sizeInt:${sizeInt} sizeIntx2:${sizeInt * 2} -->
        </c:if>
        <c:set var="sizeTwice" value="${(sizeInt * 2) > ib.width ?  ib.width : sizeInt * 2}" />
        <c:set var="sizeOnce" value="${sizeInt > ib.width ?  ib.width : sizeInt}" />
        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[sizeTwice]}" />
        <c:set target="${ib}" property="srcSets" value="${ib.scaleWidth[sizeOnce]}" />
        <c:if test="${sizeOnce > maxSize}">
            <c:set var="maxSize" value="${sizeOnce}" />
            <c:set var="maxImage" value="${ib.scaleWidth[maxSize]}" />
            <c:if test="${DEBUG}">
                <!-- using maxImage:${maxSize} -->
            </c:if>
        </c:if>
    </c:forEach>

</c:otherwise>
</c:choose>

</mercury:image-sizes>


<c:if test="${useSrcSet and (useLazyLoading or useSizes or bbInitialized)}" >
    <%-- ###### Set quality higher for smaller images to avoid blur ###### --%>
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
            <%-- ###### We only need a srcSet if we have more then one image variation ###### --%>
            <c:set var="srcset" value="${ib.srcSet}" />
        </c:when>
    </c:choose>
</c:if>

</c:if>

<c:choose>
    <c:when test="${isSvg}">
        <c:set var="srcurl"><cms:link>${ib.vfsUri}</cms:link></c:set>
    </c:when>
    <c:when test="${not empty srcset}">
        <c:set var="srcurl" value="${not empty maxImage ? maxImage.srcUrl : ib.getSrcSetMaxImage().srcUrl}" />
        <c:set var="ib" value="${not empty maxImage ? maxImage : ib}" />
    </c:when>
    <c:otherwise>
        <c:set var="srcurl" value="${ib.srcUrl}" />
    </c:otherwise>
</c:choose>

<mercury:image-lazyload
    srcUrl="${srcurl}"
    srcSet="${srcset}"
    srcSetSizes="${srcSetSizes}"
    width="${ib.scaler.width}"
    height="${ib.scaler.height}"
    heightPercentage="${ib.ratioHeightPercentage}"
    lazyLoad="${useLazyLoading}"
    noScript="${useNoScript}"
    alt="${alt}"
    title="${title}"
    copyright="${copyright}"
    cssImage="${cssImage}"
    cssWrapper="${cssWrapper}"
    attrImage="${attrImage}"
    attrWrapper="${attrWrapper}"
    zoomData="${zoomData}"
/>

</mercury:list-element-status>
