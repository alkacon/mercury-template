<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<m:init-messages reload="true">

<cms:formatter var="content" val="value">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:setting-defaults>

<c:set var="imageSeriesCss"         value="${setting.imageSeriesCss.toString}" />
<c:set var="imageSeriesSortOrder"   value="${setting.imageSeriesSortOrder.toString}" />
<c:set var="imageSeriesDisplay"     value="${setting.imageSeriesDisplay.toString}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="titleOption"            value="${setting.titleOption.toString}" />
<c:set var="pageSize"               value="${setting.pageSize.useDefault('12').toInteger}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />
<c:set var="showImageTitle"         value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageCount"         value="${setting.showImageCount.toBoolean}" />
<c:set var="showImageZoomCopyright" value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showImageListCopyright" value="${setting.showImageSeriesListCopyright.toBoolean}" />
<c:set var="autoLoad"               value="${setting.autoLoad.toBoolean}" />
<c:set var="showTitle"              value="${setting.showTitle.toBoolean}" />

<c:set var="dateFormat"             value="${setting.dateFormat.toString}" />
<c:set var="datePrefix"             value="${fn:substringBefore(dateFormat, '|')}" />
<c:set var="dateFormat"             value="${empty datePrefix ? dateFormat : fn:substringAfter(dateFormat, '|')}" />

<c:set var="id"><m:idgen prefix='imgser' uuid='${cms.element.instanceId}' /></c:set>
<c:set var="date">
    <m:instancedate date="${value.Date.toInstanceDate}" format="${dateFormat}" />
</c:set>

<c:set var="showDate"               value="${not empty date}" />
<c:set var="ade"                    value="${cms.isEditMode}" />
<c:set var="hasImageFile"           value="${value.Image.isSet}" />
<c:set var="hasImageFolder"         value="${value.ImageFolder.isSet}" />
<c:set var="datePrefix"             value="${fn:substringBefore(cms.element.setting.dateFormat, '|')}" />
<c:set var="dateFormat"             value="${empty datePrefix ? cms.element.setting.dateFormat : fn:substringAfter(cms.element.setting.dateFormat, '|')}" />
<c:set var="showPreface"            value="${setting.showPreface.toBoolean}" />
<c:set var="showIntro"              value="${titleOption ne 'none'}" />

<c:set var="text"                   value="${value.Text}" />
<c:set var="showText"               value="${setting.showText.toBoolean and text.isSet}" />
<c:set var="detailPage"             value="${cms.detailRequest}" />

<c:set var="useBrowserLazyLoad"     value="${true}" />

<c:set var="titleMarkup">
    <m:intro-headline intro="${showIntro ? value.Intro : null}" headline="${value.Title}" level="${hsize}" ade="${ade}" />
    <m:heading text="${value.Preface}" level="${7}" css="sub-header" ade="${ade}" test="${showPreface}" />
</c:set>

<c:set var="showVisual"             value="${(not empty titleMarkup) or showDate or showImageCount}" />

<c:choose>
    <c:when test="${imageSeriesDisplay eq 'slide'}">
        <c:set var="elementCss"             value=" slide-list" />
        <c:set var="rowCss"                 value="" />
        <c:set var="addBorderWrapper"       value="${true}" />
        <c:set var="tileAttrs">class="image-col square-col ${imageSeriesCss} comein zoom"</c:set>
        <c:set var="overlayAttrs">class="zoom-overlay"</c:set>
    </c:when>
    <c:when test="${imageSeriesDisplay eq 'masonry'}">
        <c:set var="showMasonryList"        value="${false}" /><%-- Experimental feature to display landscape images larger, works as exected, however results are poor --%>
        <c:set var="elementCss"             value=" masonry-list" />
        <c:set var="rowCss"                 value=" row tile-margin-2" />
        <c:set var="imageSeriesCss"         value="${fn:replace(imageSeriesCss, 'square-xs-', 'col-')}" />
        <c:set var="imageSeriesCss"         value="${fn:replace(imageSeriesCss, 'square-', 'col-')}" />
        <c:set var="imageSeriesCssOriginal" value="${imageSeriesCss}" />
        <c:set var="imageSeriesCssEnlarged" value="${fn:replace(fn:replace(fn:replace(fn:replace(imageSeriesCss, '-6', '-12'), '-4', '-6'), '-3', '-6'), '-2', '-4')}" />
        <c:set var="tileAttrs">class="image-col tile-col ${imageSeriesCss} zoom"</c:set>
        <c:set var="overlayAttrs">class="zoom-overlay image-src-box presized" style="padding-bottom: %(heightPercentage)%"</c:set>
    </c:when>
    <c:otherwise>
        <c:set var="elementCss"             value=" square-list" />
        <c:set var="rowCss"                 value="" />
        <c:set var="squareImagesOnly"       value="${true}" />
        <c:set var="tileAttrs">class="image-col square-col ${imageSeriesCss} comein zoom"</c:set>
        <c:set var="overlayAttrs">class="zoom-overlay image-src-box" style="padding-bottom: 100%"</c:set>
    </c:otherwise>
</c:choose>

<m:nl />
<div class="detail-page type-imageseries${showVisual or showText ? '' : ' only-series'}${elementCss}${setCssWrapper123}"><%----%>
<m:nl />

<m:image-sizes
    initBootstrapBean="${true}"
    gridWrapper="${imageSeriesCss}"
    gutter="${0}"
    debug="${false}">
    <%-- useGutter 0 will make source set images larger,
         this is not 100% precise but the bootstrrap bean can not deal corretly with the reduced tile margin gutter in the series --%>
    <c:choose>
        <c:when test="${not bsLazyLoadJs}">
            <c:set var="template"><%--
            --%><div ${showMasonryList ? '%(tileAttrs)' : tileAttrs}><%--
                --%><a class="zoom imageseries" href="%(src)" title="%(titleAttr)"><%--
                    --%><span class="content"><%--
                        --%><c:if test="${addBorderWrapper}"><span class="wrapper"></c:if><%--
                            --%><span ${overlayAttrs}><%--
                                --%><img src="%(squareSrc)" <%--
                                    --%>srcset="%(tileSrcSet)" <%--
                                    --%>sizes="${bbSrcSetSizes}" <%--
                                    --%>loading="lazy" <%--
                                    --%>alt="%(alt)"><%--
                                --%><span class="zoom-icon"><%--
                                    --%><m:icon icon="search" tag="span" /></span><%--
                                --%></span><%--
                                --%><c:if test="${showImageListCopyright}"><%--
                                    --%><span class="copyright">%(copyright)</span><%--
                                --%></c:if><%--
                            --%></span><%--
                        --%><c:if test="${addBorderWrapper}"></span></c:if><%--
                    --%></span><%--
                --%></a><%--
            --%></div>
            </c:set>
        </c:when>
        <c:otherwise>
            <c:set var="template"><%--
            --%><div ${showMasonryList ? '%(tileAttrs)' : tileAttrs}><%--
                --%><a class="zoom imageseries" href="%(src)" title="%(titleAttr)"><%--
                    --%><span class="content"><%--
                        --%><c:if test="${addBorderWrapper}"><span class="wrapper"></c:if><%--
                            --%><span ${overlayAttrs}><%--
                                --%><img src="%(squareSrc)" <%--
                                    --%>srcset="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" <%--
                                    --%>data-srcset="%(tileSrcSet)" <%--
                                    --%>data-sizes="auto" <%--
                                    --%>alt="%(alt)"<%--
                                    --%>class="lazyload"><%--
                                --%><span class="zoom-icon"><%--
                                    --%><m:icon icon="search" tag="span" /></span><%--
                                --%></span><%--
                                --%><c:if test="${showImageListCopyright}"><%--
                                    --%><span class="copyright">%(copyright)</span><%--
                                --%></c:if><%--
                            --%></span><%--
                        --%><c:if test="${addBorderWrapper}"></span></c:if><%--
                    --%></span><%--
                --%></a><%--
            --%></div>
            </c:set>
        </c:otherwise>
</c:choose>
</m:image-sizes>

<%-- ###### Create the list of images to display ###### --%>
<jsp:useBean id="imageList" class="java.util.ArrayList" />
<jsp:useBean id="imageBeans" class="java.util.ArrayList" />
<c:if test="${hasImageFile}">
    <%-- ###### Manually added images are first ###### --%>
    <c:forEach var="image" items="${content.valueList.Image}" varStatus="status">
        <c:if test="${image.value.Image.isSet}">
            <c:set var="iBean" value="${image.value.Image.toImage}" />
            <c:set var="ignore" value="${imageList.add(iBean.vfsUri)}" />
            <c:set var="ignore" value="${imageBeans.add(image)}" />
        </c:if>
    </c:forEach>
</c:if>
<c:if test="${hasImageFolder}">
    <c:choose>
        <c:when test="${fn:startsWith(imageSeriesSortOrder, 'title.')}">
            <c:set var="sortField" value="disptitle_sort" />
            <%-- Alternative SOLR option: Title_dprop --%>
        </c:when>
        <c:when test="${fn:startsWith(imageSeriesSortOrder, 'date.')}">
            <c:set var="sortField" value="lastmodified" />
            <%-- Alternative SOLR option: instancedate_dt --%>
        </c:when>
        <c:otherwise>
            <c:set var="sortField" value="path" />
        </c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${fn:endsWith(imageSeriesSortOrder, '.desc')}">
            <c:set var="sortOrder" value=" desc" />
        </c:when>
        <c:otherwise>
            <c:set var="sortOrder" value=" asc" />
        </c:otherwise>
    </c:choose>
    <%-- ###### Images from the gallery folder are second ###### --%>
    <c:set var="path" value="${cms.vfs.readResource[content.value.ImageFolder.toString].rootPath}" />
    <c:set var="extraSolrParams">fq=type:"image"&fq=parent-folders:"${path}"&page=1&sort=${sortField}${sortOrder}</c:set>
    <c:set var="searchconfig">
        {
            "ignorequery" : true,
            "extrasolrparams" : "${fn:replace(extraSolrParams,'"','\\"')}",
            "pagesize" : 500
        }
    </c:set>
    <cms:search configString="${searchconfig}" var="search">
        <c:if test="${search.numFound > 0 }">
            <c:forEach var="result" items="${search.searchResults}" varStatus="status">
                <c:set var="imagePath">${cms.vfs.readResource[result.searchResource].sitePath}</c:set>
                <c:if test="${not imageList.contains(imagePath)}">
                    <cms:scaleImage var="rBean" src="${imagePath}"/>
                    <c:if test="${not empty rBean}">
                        <c:set var="ignore" value="${imageList.add(rBean.vfsUri)}" />
                        <c:set var="ignore" value="${imageBeans.add(rBean)}" />
                    </c:if>
                </c:if>
            </c:forEach>
        </c:if>
    </cms:search>
</c:if>

<c:if test="${showVisual}">
    <div class="detail-visual pivot${showDate or showImageCount ? '' : ' no-info'}${setCssWrapperKeyPiece}"><%----%>
        <div class="heading"><%----%>
            ${titleMarkup}
        </div><%----%>
        <c:if test="${showDate or showImageCount}">
            <div class="visual-info ${not showImageCount ? 'right' : '' }"><%----%>
                <c:if test="${showDate}">
                    <div class="info date"><%----%>
                        <span class="sr-only"><fmt:message key="msg.page.sr.date" /></span><%----%>
                        <div>${datePrefix}${date}</div><%----%>
                    </div><%----%>
                </c:if>
                <c:if test="${showImageCount}">
                    <div class="info images"><%----%>
                        <div><fmt:message key="msg.page.imageseries.count"><fmt:param>${imageList.size()}</fmt:param></fmt:message></div><%----%>
                    </div><%----%>
                </c:if>
            </div><%----%>
        </c:if>
    </div><%----%>
    <m:nl />
</c:if>

<c:if test="${showText}">
    <div class="detail-content pivot${setCssWrapperParagraphs}" ${ade ? text.rdfaAttr : ''}><%----%>
        ${text}
    </div><%----%>
    <m:nl />
</c:if>

<c:choose>
    <c:when test="${imageList.size() > 0}">

        <cms:jsonobject var="dataSeries">
            <cms:jsonvalue key="showtitle" value="${showImageTitle}" />
            <cms:jsonvalue key="showcopyright" value="${showcopyright}" />
            <cms:jsonvalue key="path" value="${path}" />
            <cms:jsonvalue key="autoload" value="${autoLoad}" />
            <cms:jsonvalue key="count" value="${pageSize}" />
            <cms:jsonvalue key="template" value="${cms:encode(template)}" />
        </cms:jsonobject>
        <div id="${id}" class="series${setCssWrapperExtra}" data-imageseries='${dataSeries.compact}'><%----%>
        <m:nl />

            <div class="images clearfix${rowCss}"></div><%----%>

            <div class="spinner"><%----%>
                <div class="spinnerInnerBox"><%----%>
                    <m:icon icon="spinner" tag="i" cssWrapper="spinner-icon" />
                </div><%----%>
            </div><%----%>

            <button class="btn btn-append more blur-focus"><%----%>
                <fmt:message key="msg.page.imageseries.moreButton" />
            </button><%----%>

            <div class="imagedata"><%----%>
                <ul><m:nl />

                    <c:forEach var="image" items="${imageBeans}" varStatus="status">

                        <m:image-vars image="${image}" escapeCopyright="${true}">
                            <c:if test="${not empty imageBean}">

                                <c:set var="title" value="${showImageTitle ? imageTitle : ''}" />
                                <c:set var="zoomCopyright" value="${showImageZoomCopyright ? imageCopyright : ''}" />
                                <c:set var="listCopyright" value="${showImageListCopyright ? imageCopyrightHtml : ''}" />

                                <%-- Caption shown in series can contain HTML markup for formatting --%>
                                <c:set var="caption">
                                    <c:if test="${not empty title}"><div class="title">${title}</div></c:if>
                                    <c:if test="${not empty zoomCopyright}"><div class="copyright">${imageCopyrightHtml}</div></c:if>
                                </c:set>

                                <%-- Title attribute for a href tag --%>
                                <c:set var="titleAttr" value="${empty title ? '' : title}${showImageListCopyright ? '' : ' '.concat(zoomCopyright)}" />
                                <c:set var="titleAttr">${fn:replace(titleAttr, '"', '\'')}</c:set>

                                <%-- Alt attribute for img tag --%>
                                <c:set var="altAttr" value="${empty imageDescription ? imageTitle : imageDescription}" />

                                <c:set var="maxWidth" value="${1200}" />

                                ${imageBean.setQuality(80)}
                                <%-- Make sure the full image is not to large --%>
                                <c:if test="${imageBean.scaler.width > maxWidth}">
                                    <c:set var="imageBean" value="${imageBean.scaleWidth[maxWidth]}" />
                                </c:if>

                                <c:choose>
                                    <c:when test="${squareImagesOnly}">
                                        <c:set var="outputImage" value="${imageBean.scaleRatio['1-1']}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="outputImage" value="${imageBean}" />
                                        <c:set var="heightPercentage" value="${outputImage.ratioHeightPercentage}" />
                                    </c:otherwise>
                                </c:choose>

                                <%-- Generate the srcSet - make sure the requested image size can actually be generated --%>
                                <c:set var="tileSrcSet">
                                    <c:forEach var="w" begin="200" end="800" step="200" varStatus="status">
                                        <c:set var="currentSrc" value="${outputImage.scaleWidth[w].srcUrl}"/>
                                        <c:if test="${not empty currentSrc and not status.first}">, </c:if>
                                        <c:if test="${not empty currentSrc}">${currentSrc}${' '}${w}w</c:if>
                                    </c:forEach>
                                </c:set>
                                <c:if test="${empty tileSrcSet}">
                                    <c:set var="tileSrcSet">${outputImage.srcUrl}</c:set>
                                </c:if>

                                <%-- Finally generate the output for the image list element --%>
                                <cms:jsonobject var="dataImage">
                                    <cms:jsonvalue key="src" value="${imageBean.srcUrl}" />
                                    <cms:jsonvalue key="squareSrc" value="${outputImage.srcUrl}" />
                                    <cms:jsonvalue key="tileSrcSet" value="${tileSrcSet}" />
                                    <cms:jsonvalue key="size" value="w:${imageBean.scaler.width},h:${imageBean.scaler.height}" />
                                    <cms:jsonvalue key="caption" value="${caption}" />
                                    <cms:jsonvalue key="copyright" value="${listCopyright}" />
                                    <cms:jsonvalue key="titleAttr" value="${titleAttr}" />
                                    <cms:jsonvalue key="alt" value="${altAttr}" />
                                    <cms:jsonvalue key="heightPercentage" value="${fn:replace(heightPercentage, '%', '')}" />
                                    <c:if test="${showMasonryList}">
                                        <c:choose>
                                            <c:when test="${imageBean.scaler.width > (imageBean.scaler.height * 1.1)}">
                                                <c:set var="imageSeriesCss" value="${imageSeriesCssEnlarged}" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="imageSeriesCss" value="${imageSeriesCssOriginal}" />
                                            </c:otherwise>
                                        </c:choose>
                                        <cms:jsonvalue key="tileAttrs" value="class=\"image-col tile-col ${imageSeriesCss} zoom\"" />
                                    </c:if>
                                </cms:jsonobject>
                                <li data-image='${dataImage.compact}'></li><%----%>
                                <m:nl />
                            </c:if>
                        </m:image-vars>

                    </c:forEach>
                </ul><%----%>
            </div><%----%>
        </div><%----%>
        <m:nl />
        <m:alert-online showJsWarning="${true}" >
            <jsp:attribute name="text">
                <fmt:message key="msg.page.noscript.imageseries" />
            </jsp:attribute>
        </m:alert-online>
    </c:when>

    <c:when test="${cms.isEditMode}">
        <%-- No images have been found --%>
        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <m:alert type="warning">
                <jsp:attribute name="head">
                    <fmt:message key="msg.page.imageseries.noSource" />
                </jsp:attribute>
                <jsp:attribute name="text">
                    <fmt:message key="msg.page.imageseries.noSource.hint" />
                </jsp:attribute>
            </m:alert>
        </cms:bundle>
    </c:when>

    <c:otherwise>
        <m:alert-online>
            <jsp:attribute name="head">
                <fmt:message key="msg.page.imageseries.noSource" />
            </jsp:attribute>
        </m:alert-online>
    </c:otherwise>

</c:choose>

<m:container-attachment content="${content}" name="attachments" type="${containerType}" />

</div><%----%>
<m:nl />

</m:setting-defaults>

</cms:bundle>
</cms:formatter>
</m:init-messages>