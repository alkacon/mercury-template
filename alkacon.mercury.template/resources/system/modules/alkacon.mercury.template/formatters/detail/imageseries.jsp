<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<mercury:init-messages reload="true">

<cms:formatter var="content" val="value">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="imageSeriesCss"         value="${setting.imageSeriesCss.toString}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="titleOption"            value="${setting.titleOption.toString}" />
<c:set var="pageSize"               value="${empty setting.pageSize.toInteger ? 12 : setting.pageSize.toInteger}" />
<c:set var="showImageTitle"         value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageCount"         value="${setting.showImageCount.toBoolean}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="autoLoad"               value="${setting.autoLoad.toBoolean}" />
<c:set var="showTitle"              value="${setting.showTitle.toBoolean}" />

<c:set var="dateFormat"             value="${setting.dateFormat.toString}" />
<c:set var="datePrefix"             value="${fn:substringBefore(dateFormat, '|')}" />
<c:set var="dateFormat"             value="${empty datePrefix ? dateFormat : fn:substringAfter(dateFormat, '|')}" />

<c:set var="id"><mercury:idgen prefix='imgal' uuid='${cms.element.instanceId}' /></c:set>
<c:set var="date">
    <mercury:instancedate date="${value.Date.toInstanceDate}" format="${dateFormat}" />
</c:set>

<c:set var="showDate"               value="${not empty date}" />
<c:set var="ade"                    value="${true}" />
<c:set var="hasImageFile"           value="${value.Image.isSet}" />
<c:set var="hasImageFolder"         value="${value.ImageFolder.isSet}" />
<c:set var="datePrefix"             value="${fn:substringBefore(cms.element.setting.dateFormat, '|')}" />
<c:set var="dateFormat"             value="${empty datePrefix ? cms.element.setting.dateFormat : fn:substringAfter(cms.element.setting.dateFormat, '|')}" />
<c:set var="showPreface"            value="${setting.showPreface.toBoolean}" />
<c:set var="showIntro"              value="${titleOption ne 'none'}" />


<c:set var="text"                   value="${value.Text}" />
<c:set var="showText"               value="${setting.showText.toBoolean}" />
<c:set var="detailPage"             value="${cms.detailRequest}" />

<c:set var="titleMarkup">
    <mercury:intro-headline intro="${showIntro ? value.Intro : null}" headline="${value.Title}" level="${hsize}" ade="${ade}" />
    <mercury:heading text="${value.Preface}" level="${7}" css="sub-header" ade="${ade}" test="${showPreface}" />
</c:set>

<c:set var="template"><%--
--%><div class="square-col ${imageSeriesCss} comein zoom"><%--
    --%><a class="zoom imageseries" href="%(src)" title="%(titleAttr)"><%--
        --%><span class="content"><%--
            --%><span class="zoom-overlay image-src-box" style="padding-bottom: 100%"><%--
                --%><img src="%(squareSrc)" <%--
                    --%>srcset="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" <%--
                    --%>data-srcset="%(tileSrcSet)" <%--
                    --%>data-sizes="auto" <%--
                    --%>alt="%(titleAttr)"<%--
                    --%>class="lazyload"><%--
                --%><span class="zoom-icon"><%--
                    --%><span class="fa fa-search"></span><%--
               --%></span><%--
            --%></span><%--
        --%></span><%--
    --%></a><%--
--%></div>
</c:set>

<%-- ###### Create the list of images to display ###### --%>
<c:set var="imageList" value="${cms:createList()}" />
<c:set var="imageBeans" value="${cms:createList()}" />
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
    <%-- ###### Images from the gallery folder are second ###### --%>
    <c:set var="path" value="${cms.vfs.readResource[content.value.ImageFolder.toString].rootPath}" />
    <c:set var="extraSolrParams">fq=type:"image"&fq=parent-folders:"${path}"&page=1&sort=path asc</c:set>
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

<mercury:nl />
<div class="detail-page type-imageseries ${cssWrapper}"><%----%>
<mercury:nl />

<c:if test="${(not empty titleMarkup) or showDate or showImageCount}">
    <div class="detail-visual piece full"><%----%>
        <div class="heading"><%----%>
            ${titleMarkup}
        </div><%----%>
        <c:if test="${showDate or showImageCount}">
            <div class="visual-info ${not showImageCount ? 'right' : '' }"><%----%>
                <c:if test="${showDate}"><div class="info date"><div>${datePrefix}${date}</div></div></c:if>
                <c:if test="${showImageCount}"><div class="info images"><div><fmt:message key="msg.page.imageseries.count"><fmt:param>${imageList.size()}</fmt:param></fmt:message></div></div></c:if>
            </div><%----%>
        </c:if>
    </div><%----%>
    <mercury:nl />
</c:if>

<c:if test="${showText and text.isSet}">
    <div class="detail-content" ${ade ? text.rdfaAttr : ''}><%----%>
        ${text}
    </div><%----%>
    <mercury:nl />
</c:if>

<c:choose>
    <c:when test="${imageList.size() > 0}">

        <div id="${id}" class="subelement series" <%--
        --%>data-imageseries='{<%--
            --%>"showtitle":"${showImageTitle}", <%--
            --%>"showcopyright":"${showImageCopyright}", <%--
            --%>"path":"${path}", <%--
            --%>"autoload":"${autoLoad}", <%--
            --%>"count":"${pageSize}", <%--
            --%>"template":"${cms:encode(template)}"<%--
        --%>}'><mercury:nl />

            <div class="images square-m-2 clearfix"></div><%----%>

            <div class="spinner"><%----%>
                <div class="spinnerInnerBox"><i class="fa fa-spinner"></i></div><%----%>
            </div><%----%>

            <button class="btn btn-block more blur-focus"><%----%>
                <fmt:message key="msg.page.imageseries.moreButton" />
            </button><%----%>

            <div class="imagedata"><%----%>
                <ul><mercury:nl />

                    <c:forEach var="image" items="${imageBeans}" varStatus="status">

                        <mercury:image-vars image="${image}" escapeCopyright="${true}">
                            <c:if test="${not empty imageBean}">

                                <c:set var="title" value="${showImageTitle ? imageTitle : ''}" />
                                <c:set var="copyright" value="${showImageCopyright ? imageCopyright : ''}" />

                                <%-- Caption shown in series can contain HTML markup for formatting --%>
                                <c:set var="caption">
                                    <c:if test="${not empty title}"><div class="title">${title}</div></c:if>
                                    <c:if test="${not empty copyright}"><div class="copyright">${imageCopyrightHtml}</div></c:if>
                                </c:set>

                                <%-- Title attribute for a href tag can not contain any HTML markup--%>
                                <c:set var="titleAttr">
                                    <c:if test="${not empty title}">${title}</c:if>
                                    <c:if test="${not empty title || not empty copyright}"> </c:if>
                                    <c:if test="${not empty copyright}">${copyright}</c:if>
                                </c:set>

                                <c:set var="maxWidth" value="${1200}" />

                                ${imageBean.setQuality(80)}
                                <%-- Make sure the full image is not to large --%>
                                <c:if test="${imageBean.scaler.width > maxWidth}">
                                    <c:set var="imageBean" value="${imageBean.scaleWidth[maxWidth]}" />
                                </c:if>

                                <%-- Calculate the square tile image --%>
                                <c:set var="squareImage" value="${imageBean.scaleRatio['1-1']}" />

                                <%-- Generate the srcSet - make sure the requested image size can actually be generated --%>
                                <c:set var="tileSrcSet">
                                    <c:forEach var="w" begin="200" end="800" step="200" varStatus="status">
                                        <c:set var="currentSrc" value="${squareImage.scaleWidth[w].srcUrl}"/>
                                        <c:if test="${not empty currentSrc and not status.first}">, </c:if>
                                        <c:if test="${not empty currentSrc}">${currentSrc}${' '}${w}w</c:if>
                                    </c:forEach>
                                </c:set>
                                <c:if test="${empty tileSrcSet}">
                                    <c:set var="tileSrcSet">${squareImage.srcUrl}</c:set>
                                </c:if>

                                <%-- Finally generate the output for the image list element --%>
                                <li data-image='{<%--
                                    --%>"src": "${imageBean.srcUrl}", <%--
                                    --%>"squareSrc": "${squareImage.srcUrl}", <%--
                                    --%>"tileSrcSet": "${tileSrcSet}", <%--
                                    --%>"size": "w:${imageBean.scaler.width},h:${imageBean.scaler.height}", <%--
                                    --%>"caption": "${cms:encode(caption)}", <%--
                                    --%>"titleAttr": "${cms:encode(titleAttr)}"<%--
                                --%>}'></li><%----%>
                                <mercury:nl />
                            </c:if>
                        </mercury:image-vars>

                    </c:forEach>
                </ul><%----%>
            </div><%----%>
        </div><%----%>
        <mercury:nl />
        <mercury:alert-online showJsWarning="${true}" >
            <jsp:attribute name="text">
                <fmt:message key="msg.page.imageseries.noscript" />
            </jsp:attribute>
        </mercury:alert-online>
    </c:when>

    <c:when test="${cms.isEditMode}">
        <%-- No images have been found --%>
        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <mercury:alert type="warning">
                <jsp:attribute name="head">
                    <fmt:message key="msg.page.imageseries.noSource" />
                </jsp:attribute>
                <jsp:attribute name="text">
                    <fmt:message key="msg.page.imageseries.noSource.hint" />
                </jsp:attribute>
            </mercury:alert>
        </cms:bundle>
    </c:when>

    <c:otherwise>
        <mercury:alert-online>
            <jsp:attribute name="head">
                <fmt:message key="msg.page.imageseries.noSource" />
            </jsp:attribute>
        </mercury:alert-online>
    </c:otherwise>

</c:choose>

<mercury:container-attachment content="${content}" name="attachments" />

</div><%----%>
<mercury:nl />

</cms:bundle>
</cms:formatter>
</mercury:init-messages>