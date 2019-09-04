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

<mercury:init-messages reload="true">

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="visualEffect"           value="${setting.effect.toString}" />

<c:set var="useFade"                value="${setting.transition eq 'fade'}" />
<c:set var="animationSpeed"         value="${useFade ? 1000 : 500}" />
<c:set var="justOneSlide"           value="${content.valueList.Image.size() < 2}" />

<c:set var="rotationTime"           value="${setting.rotationTime.isSet ? setting.rotationTime.toInteger : 0}" />
<c:set var="autoPlay"               value="${rotationTime > 0}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="imageRatioXS"           value="${setting.imageRatioSmall.toString}" />
<c:set var="imageRatioXL"           value="${setting.imageRatioLarge.toString}" />
<c:set var="showArrows"             value="${setting.showArrows.toBoolean}" />
<c:set var="pauseOnHover"           value="${setting.pauseOnHover.toBoolean}" />
<c:set var="showDots"               value="${setting.showDots.toBoolean}" />
<c:set var="visibleSlideSetting"    value="${setting.visibleSlides.toString}" />
<c:set var="textDisplay"            value="${setting.textDisplay.toString}" />

<c:set var="bgColorHead"            value="${setting.textColorHead.isSet and not (setting.textColorHead eq 'css') ? setting.textColorHead.toString : ''}" />
<c:set var="bgColorSub"             value="${setting.textColorSub.isSet and not (setting.textColorSub eq 'css') ? setting.textColorSub.toString : ''}" />

<c:set var="slickType"              value="${setting.slickType.value}" />
<c:choose>
    <c:when test="${slickType eq 'logo'}">
    <%-- ###### Logo slider ###### --%>
        <c:set var="visibleSlideList" value="${fn:split(visibleSlideSetting, '-')}" />
        <c:choose>
            <c:when test="${fn:length(visibleSlideList) >= 5}">
                <c:set var="visibleSlidesXS"    value="${cms:toNumber(visibleSlideList[0], 8)}" />
                <c:set var="visibleSlidesSM"    value="${cms:toNumber(visibleSlideList[1], visibleSlidesXS)}" />
                <c:set var="visibleSlidesMD"    value="${cms:toNumber(visibleSlideList[2], visibleSlidesSM)}" />
                <c:set var="visibleSlidesLG"    value="${cms:toNumber(visibleSlideList[3], visibleSlidesMD)}" />
                <c:set var="visibleSlidesXL"    value="${cms:toNumber(visibleSlideList[4], visibleSlidesLG)}" />
            </c:when>
            <c:when test="${fn:length(visibleSlideList) >= 4}">
                <c:set var="visibleSlidesXS"    value="${cms:toNumber(visibleSlideList[0], 8)}" />
                <c:set var="visibleSlidesSM"    value="${cms:toNumber(visibleSlideList[1], visibleSlidesXS)}" />
                <c:set var="visibleSlidesMD"    value="${cms:toNumber(visibleSlideList[2], visibleSlidesSM)}" />
                <c:set var="visibleSlidesLG"    value="${cms:toNumber(visibleSlideList[3], visibleSlidesMD)}" />
                <c:set var="visibleSlidesXL"    value="${visibleSlidesLG}" />
            </c:when>
            <c:when test="${fn:length(visibleSlideList) == 3}">
                <c:set var="visibleSlidesXS"    value="${cms:toNumber(visibleSlideList[0], 8)}" />
                <c:set var="visibleSlidesSM"    value="${cms:toNumber(visibleSlideList[1], visibleSlidesXS)}" />
                <c:set var="visibleSlidesMD"    value="${cms:toNumber(visibleSlideList[2], visibleSlidesSM)}" />
                <c:set var="visibleSlidesLG"    value="${visibleSlidesMD}" />
                <c:set var="visibleSlidesXL"    value="${visibleSlidesMD}" />
            </c:when>
            <c:when test="${fn:length(visibleSlideList) == 2}">
                <c:set var="visibleSlidesXS"    value="${cms:toNumber(visibleSlideList[0], 8)}" />
                <c:set var="visibleSlidesSM"    value="${cms:toNumber(visibleSlideList[1], visibleSlidesXS)}" />
                <c:set var="visibleSlidesMD"    value="${visibleSlidesSM}" />
                <c:set var="visibleSlidesLG"    value="${visibleSlidesSM}" />
                <c:set var="visibleSlidesXL"    value="${visibleSlidesSM}" />
            </c:when>
            <c:otherwise>
                <c:set var="visibleSlidesXS"    value="${cms:toNumber(visibleSlideSetting, 8)}" />
                <c:set var="visibleSlidesXL"    value="${visibleSlidesXS}" />
            </c:otherwise>
        </c:choose>
        <c:set var="cssgridCols" value="col-${cms:mathCeil(12.0 / visibleSlidesXL)}" />
        <c:if test="${not empty visibleSlidesXS}">
            <c:set var="responsiveData"><%--
            --%>"responsive": [<%--
                --%>{"breakpoint": 551, "settings": {"slidesToShow": ${visibleSlidesXS} }},<%--
                --%>{"breakpoint": 763, "settings": {"slidesToShow": ${visibleSlidesSM} }},<%--
                --%>{"breakpoint": 1013, "settings": {"slidesToShow": ${visibleSlidesMD} }},<%--
                --%>{"breakpoint": 1199, "settings": {"slidesToShow": ${visibleSlidesLG} }}<%--
            --%>], <%--
        --%></c:set>
            <c:set var="cssgridCols"><%--
            --%>col-${cms:mathCeil(12.0 / visibleSlidesXS)}${' '}<%--
            --%>col-sm-${cms:mathCeil(12.0 / visibleSlidesSM)}${' '}<%--
            --%>col-md-${cms:mathCeil(12.0 / visibleSlidesMD)}${' '}<%--
            --%>col-lg-${cms:mathCeil(12.0 / visibleSlidesLG)}${' '}<%--
            --%>col-xl-${cms:mathCeil(12.0 / visibleSlidesXL)}<%--
        --%></c:set>
        </c:if>
        <c:set var="sliderClass" value="logo-slider" />
        <c:set var="marginClass" value="lm-10" />
        <c:set var="cssgutter" value="20" />
        <c:set var="showDots" value="${false}" />
        <c:set var="pauseOnHover" value="${false}" />
        <c:set var="adoptRatioToScreen" value="${false}" />
        <c:set var="animationTrigger" value="${visualEffect eq 'none' ? '' : visualEffect}" />
        <c:set var="animationTarget" value="${visualEffect eq 'none' ? '' : 'effect-box'}" />
    </c:when>
    <c:otherwise>
    <%-- ###### Hero slider (default) ###### --%>
        <c:set var="sliderClass" value="hero-slider" />
        <c:set var="visibleSlidesXL" value="${1}" />
        <c:set var="visibleSlidesXS" value="${1}" />
        <c:set var="adoptRatioToScreen" value="${not (imageRatioXL eq imageRatioXS)}" />
        <c:set var="cssgridCols" value="col-12" />
    </c:otherwise>
</c:choose>

<div class="element type-slider type-slick-slider ${sliderClass}${' '}${cssWrapper}${' '}${textDisplay}" <%--
--%>id="<mercury:idgen prefix='sl' uuid='${cms.element.id}' />"<%--
--%>><mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" css="heading" />

    <c:choose>
        <c:when test="${value.Position.exists}">
            <c:set var="defPosTop">${value.Position.value.Top.isSet ? value.Position.value.Top.toString : 'bottom'}</c:set>
            <c:set var="defPosLeft">${value.Position.value.Left.isSet ? value.Position.value.Left.toString : 'right'}</c:set>
            <c:set var="defPosData" value="${value.Position.value.Data}" />
        </c:when>
        <c:otherwise>
            <c:set var="defPosTop" value="bottom" />
            <c:set var="defPosLeft" value="right" />
        </c:otherwise>
    </c:choose>

    <c:if test="${value.TextBackgroundColor.isSet}">
        <c:set var="captionBgStyle">background-color: ${value.TextBackgroundColor}; background-image: linear-gradient(${value.TextBackgroundColor}, ${value.TextBackgroundColor})</c:set>
        <c:set var="customStyle">style="${captionBgStyle}"</c:set>
    </c:if>
    <c:if test="${not empty bgColorHead}">
        <c:set var="headBgStyle">style="background-color: ${bgColorHead}; background-image: linear-gradient(${bgColorHead}, ${bgColorHead})"</c:set>
        <c:set var="customClass" value="custom" />
    </c:if>
    <c:if test="${not empty bgColorSub}">
        <%-- background-image linear gradient rule is here to trick WCAG audit to ignoring this text --%>
        <c:set var="subBgStyle">style="background-color: ${bgColorSub}; background-image: linear-gradient(${bgColorSub}, ${bgColorSub})"</c:set>
        <c:set var="customClass" value="custom" />
        <c:set var="customStyle">${subBgStyle}</c:set>
    </c:if>
    <c:if test="${value.TextColor.isSet}">
        <c:set var="textStyle">style="color: ${value.TextColor}"</c:set>
    </c:if>

    <c:choose>
        <c:when test="${justOneSlide}">
            <c:set var="sliderAttrs" value='class="slide-definitions just-one-slide"' />
        </c:when>
        <c:otherwise>
            <c:set var="sliderAttrs">
                class="slide-definitions list-of-slides ${slideRowSpace}" data-typeslick='{<%--
                --%>"dots": ${showDots}, <%--
                --%>"arrows": ${showArrows}, <%--
                --%>"autoplaySpeed": ${rotationTime}, <%--
                --%>"animationSpeed": ${animationSpeed}, <%--
                --%>"pauseOnHover": ${pauseOnHover}, <%--
                --%>"pauseOnFocus": ${pauseOnHover}, <%--
                --%>"fade": ${useFade}, <%--
                --%>"slidesToShow": ${visibleSlidesXL}, <%--
                --%>${responsiveData}<%--
                --%>"autoplay": ${autoPlay}, <%--
                --%>"swipeToSlide": true, <%--
                --%>"infinite": true<%--
            --%>}'
            </c:set>
        </c:otherwise>
    </c:choose>

    <div class="slider-box clearfix ${customClass}${' '}${marginClass}"${' '}${customStyle}><mercury:nl/>
    <div ${sliderAttrs}><mercury:nl/>

    <c:forEach var="image" items="${content.valueList.Image}" varStatus="status">

        <c:set var="posLeft" value="${image.value.Position.value.Left.isSet ? image.value.Position.value.Left.toString : defPosLeft}" />
        <c:set var="posTop" value="${image.value.Position.value.Top.isSet ? image.value.Position.value.Top.toString : defPosTop}" />
        <c:set var="posTop" value="${'center' eq posTop ? 'middle' : posTop}" />

        <c:set var="posStyle" value="" />
        <c:if test="${posTop.matches('[0-9]+')}">
            <c:set var="posStyle">${style} top: ${posTop}px;</c:set>
            <c:set var="posTop" value="" />
        </c:if>
        <c:if test="${posLeft.matches('[0-9]+')}">
            <c:set var="posStyle">${posStyle} left: ${posLeft}px;</c:set>
            <c:set var="posLeft" value="" />
        </c:if>
        <c:set var="bgStyle" value="" />
        <c:set var="fgStyle" value="" />
        <c:if test="${(not empty posStyle) or (not empty captionBgStyle)}">
            <c:set var="bgStyle">style="${posStyle} ${captionBgStyle}"</c:set>
        </c:if>
        <c:if test="${not empty posStyle}">
            <c:set var="fgStyle">style="${posStyle}"</c:set>
        </c:if>

        <mercury:nl />
        <div class="slide-wrapper slide-count-${cms:mathFloor(visibleSlidesXS)}${' '}${isHiddenSlide ? 'hide-noscript' : ''}${' '}${animationTrigger}${' '}${customClass}"><%----%>
            <div class="visual ${animationTarget}"><mercury:nl/>

                ${image.value.Link.isSet ?
                    '<a href="'
                        .concat(image.value.Link.toLink)
                        .concat('" rel="noopener"')
                        .concat(image.value.NewWin.toBoolean ? ' target="_blank"' : '')
                        .concat('>')
                    : ''}

                    <cms:addparams>
                        <cms:param name="cssgrid">${adoptRatioToScreen ? 'col-xs-12 hidden-sm hidden-md hidden-lg hidden-xl' : cssgridCols}</cms:param>
                        <cms:param name="cssgutter">${not empty cssgutter ? cssgutter : '#'}</cms:param>
                        <div class="slide-xs ${adoptRatioToScreen ? 'visible-xs' : ''}"><%----%>
                            <mercury:image-simple
                                image="${image}"
                                ratio="${imageRatioXS}"
                                title="${image.value.SuperTitle.toString()}">
                                    <c:set var="copyright" value="${imageCopyrightHtml}" />
                            </mercury:image-simple>
                        </div><mercury:nl/>
                    </cms:addparams>

                    <c:if test="${adoptRatioToScreen}">

                        <mercury:image-vars image="${image}" ratio="${imageRatioXL}">
                            <c:set var="ibLg" value="${imageBean}" />
                        </mercury:image-vars>

                        <c:set var="ibXs" value="${ibLg.scaleRatio[imageRatioXS]}" />
                        <c:set var="w" value="${ibLg.scaler.width}" />
                        <c:set var="h" value="${ibLg.scaler.height}" />
                        <c:set var="hStep" value="${cms:mathRound((ibLg.scaler.height - ibXs.scaler.height) / 4)}" />
                        <c:set var="wStep" value="${cms:mathRound((ibLg.scaler.width- ibXs.scaler.width) / 4)}" />
                        <c:set var="imageRatioSM" value="${w - (3 * wStep)}-${h - (3 * hStep)}" />
                        <c:set var="imageRatioMD" value="${w - (2 * wStep)}-${h - (2 * hStep)}" />
                        <c:set var="imageRatioLG" value="${w - (1 * wStep)}-${h - (1 * hStep)}" />

                        <cms:addparams>
                            <cms:param name="cssgrid">hidden-xl hidden-lg hidden-md hidden-xs</cms:param>
                            <div class="slide-sm visible-sm"><%----%>
                                <mercury:image-simple
                                    image="${image}"
                                    ratio="${imageRatioSM}"
                                    title="${image.value.SuperTitle.toString()}" />
                            </div><mercury:nl/>
                        </cms:addparams>

                        <cms:addparams>
                            <cms:param name="cssgrid">hidden-xl hidden-lg hidden-sm hidden-xs</cms:param>
                            <div class="slide-md visible-md"><%----%>
                                <mercury:image-simple
                                    image="${image}"
                                    ratio="${imageRatioMD}"
                                    title="${image.value.SuperTitle.toString()}" />
                            </div><mercury:nl/>
                        </cms:addparams>

                        <cms:addparams>
                            <cms:param name="cssgrid">hidden-xl hidden-xs hidden-sm hidden-md</cms:param>
                            <div class="slide-lg visible-lg"><%----%>
                                <mercury:image-simple
                                    image="${image}"
                                    ratio="${imageRatioLG}"
                                    title="${image.value.SuperTitle.toString()}" />
                            </div><mercury:nl/>
                        </cms:addparams>

                        <cms:addparams>
                            <cms:param name="cssgrid">hidden-lg hidden-xs hidden-sm hidden-md</cms:param>
                            <div class="slide-xl visible-xl"><%----%>
                                <mercury:image-simple
                                    image="${image}"
                                    ratio="${imageRatioXL}"
                                    title="${image.value.SuperTitle.toString()}" />
                            </div><mercury:nl/>
                        </cms:addparams>

                    </c:if>

                ${image.value.Link.isSet ? '</a>':''}

                <c:if test="${showImageCopyright and (not empty copyright)}">
                    <div class="copyright">${copyright}</div><mercury:nl/>
                </c:if>
            </div><mercury:nl/>

            <c:if test="${not (slickType eq 'logo')
                and (image.value.SuperTitle.isSet || image.value.TitleLine1.isSet || image.value.TitleLine2.isSet)}">

                ${image.value.Link.isSet ?
                    '<a href="'
                        .concat(image.value.Link.toLink)
                        .concat('" rel="noopener"')
                        .concat(image.value.NewWin.toBoolean ? ' target="_blank"' : '')
                        .concat('>')
                    : ''}
                <div class="caption background ${posTop}${' '}${posLeft}" aria-hidden="true" ${bgStyle}><%----%>
                    <c:if test="${image.value.SuperTitle.isSet}">
                        <strong ${headBgStyle} aria-hidden="true">${image.value.SuperTitle}</strong><%----%>
                    </c:if>
                    <c:if test="${image.value.TitleLine1.isSet or image.value.TitleLine2.isSet}">
                        <div class="subcaption"><%----%>
                            <c:if test="${image.value.TitleLine1.isSet}">
                                <small ${subBgStyle} aria-hidden="true">${image.value.TitleLine1}</small><%----%>
                            </c:if>
                            <c:if test="${image.value.TitleLine2.isSet}">
                                <%-- br only needed here for "custom" CSS setting when subcaption has different color --%>
                                <br><small ${subBgStyle} aria-hidden="true">${image.value.TitleLine2}</small><%----%>
                            </c:if>
                        </div><%----%>
                    </c:if>
                </div><%----%>
                <div class="caption foreground ${posTop}${' '}${posLeft}" ${fgStyle}><%----%>
                    <c:if test="${image.value.SuperTitle.isSet}">
                        <strong ${textStyle}>${image.value.SuperTitle}</strong><%----%>
                    </c:if>
                    <c:if test="${image.value.TitleLine1.isSet or image.value.TitleLine2.isSet}">
                        <div class="subcaption"><%----%>
                            <c:if test="${image.value.TitleLine1.isSet}">
                                <small ${textStyle}>${image.value.TitleLine1}</small><%----%>
                            </c:if>
                            <c:if test="${image.value.TitleLine2.isSet}">
                                <br><small ${textStyle}>${image.value.TitleLine2}</small><%----%>
                            </c:if>
                        </div><%----%>
                    </c:if>
                </div><%----%>
                ${image.value.Link.isSet ? '</a>':''}
                <mercury:nl />
            </c:if>
        </div><%----%>
        <mercury:nl />

        <c:set var="isHiddenSlide" value="${status.count >= visibleSlidesXS}" />
    </c:forEach>
    </div><%----%>
    </div><%----%>

</div><%----%>
<mercury:nl />

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
