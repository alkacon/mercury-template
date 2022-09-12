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

<mercury:setting-defaults>

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />

<c:set var="justOneSlide"           value="${content.valueList.Image.size() < 2}" />

<c:set var="rotationTime"           value="${setting.rotationTime.isSet ? setting.rotationTime.toInteger : 0}" />
<c:set var="autoPlay"               value="${rotationTime > 0}" />
<c:set var="transition"             value="${setting.transition.validate(['swipe','direct','parallax','scale'],'direct').toString}" />
<c:set var="transitionSpeed"        value="${setting.transitionSpeed.toInteger}" />
<c:set var="marginClass"            value="${' '}${setting.marginClass.toString}" />
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

<c:set var="sliderType"             value="${setting.sliderType.value}" />
<c:set var="ade"                    value="${cms.isEditMode}" />

<c:choose>
    <c:when test="${sliderType eq 'logo'}">
    <%-- Logo slider --%>
        <c:set var="visibleSlideList" value="${fn:split(visibleSlideSetting, '-')}" />
        <c:set var="visibleSlideConfig" value="${[0, 0, 0, 0, 0, 0]}" />
        <c:forEach var="sC"             items="${visibleSlideList}" varStatus="status">
            <c:set var="slideCount"     value="${cms.wrap[sC].toInteger}" />
            <c:set var="visibleSlides"  value="${slideCount > 0 ? slideCount : (status.index > 0 ? visibleSlideConfig[status.index - 1] : 1)}" />
            <c:set var="ignore"         value="${visibleSlideConfig.set(status.index, visibleSlides)}" />
        </c:forEach>
        <c:set var="logoRows" value="" />
        <c:choose>
            <c:when test="${visibleSlideConfig[0] > 0}">
                <c:set var="Breakpoints" value="${['', '-sm', '-md', '-lg', '-xl', '-xxl']}" />
                <c:forEach var="slideConfig" items="${visibleSlideConfig}" varStatus="status">
                    <c:if test="${visibleSlideConfig[status.index] > 0}">
                        <c:set var="logoRows" value="${logoRows}${' '}row-cols${Breakpoints[status.index]}-${visibleSlideConfig[status.index]}" />
                    </c:if>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <c:set var="logoRows" value=" row-cols-2 row-cols-lg-4" />
                <c:set var="cssgridCols" value="col-xs-6 col-lg-3" />
            </c:otherwise>
        </c:choose>
        <c:set var="isHeroSlider" value="${false}" />
        <c:set var="marginClass" value=" lm-10" />
        <c:set var="transition" value="swipe" />
        <c:set var="cssgutter" value="20" />
        <c:set var="showDots" value="${false}" />
        <c:set var="pauseOnHover" value="${false}" />
        <c:set var="adoptRatioToScreen" value="${false}" />
        <c:set var="animationTrigger" value="${empty setEffect ? '' : ' '.concat(setEffect)}" />
        <c:set var="animationTarget" value="${empty setEffect ? '' : ' effect-box'}" />
    </c:when>
    <c:otherwise>

    <%-- Hero slider (default) --%>
        <c:set var="isHeroSlider" value="${true}" />
        <c:set var="marginClass" value="${' tr-'.concat(transition)}" />
        <c:if test="${transition eq 'direct'}">
            <c:set var="transitionSpeed" value="${100}" />
        </c:if>
        <%-- note: only transitions 'scale' and 'parallax' currently use the param --%>
        <c:set var="transitionParam" value="${transition eq 'parallax' ? 0.75 : 2.0}" />
        <c:set var="visibleSlidesXL" value="${1}" />
        <c:set var="visibleSlidesXS" value="${1}" />
        <c:set var="adoptRatioToScreen" value="${not (imageRatioXL eq imageRatioXS)}" />
    </c:otherwise>
</c:choose>

<div class="element type-slider${justOneSlide ? ' just-one-slide' : ' use-embla-slider'}${isHeroSlider ? ' hero-slider ' : ' logo-slider '}pivot pivot-full${setCssWrapper123}${' '}${textDisplay}" <%--
--%>id="<mercury:idgen prefix='sl' uuid='${cms.element.id}' />"<%--
--%>><mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" css="heading" ade="${ade}" />

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

    <c:set var="customVars" value="" />
    <c:if test="${value.TextBackgroundColor.isSet}">
        <c:set var="rgbVal"><mercury:parseColor value="${value.TextBackgroundColor}" /></c:set>
        <c:if test="${not rgbVal}">
            <c:set var="customVars">--my-slider-bg:${rgbVal};</c:set>
        </c:if>
    </c:if>
    <c:if test="${value.TextColor.isSet}">
        <c:set var="rgbVal"><mercury:parseColor value="${value.TextColor}" /></c:set>
        <c:if test="${not empty rgbVal}">
            <%-- text color must nor be RGB, we use this as check for valid values --%>
            <c:set var="customVars">${customVars}--my-slider-fg:${value.TextColor};</c:set>
        </c:if>
    </c:if>
    <c:if test="${not empty bgColorHead}">
        <c:set var="customClass" value=" custom" />
        <c:set var="rgbVal"><mercury:parseColor value="${bgColorHead}" /></c:set>
        <c:if test="${not empty rgbVal}">
            <c:set var="customVars">${customVars}--my-slider-caption-top:${rgbVal};</c:set>
        </c:if>
    </c:if>
    <c:if test="${not empty bgColorSub}">
        <c:set var="customClass" value=" custom" />
        <c:set var="rgbVal"><mercury:parseColor value="${bgColorSub}" /></c:set>
        <c:if test="${not empty rgbVal}">
            <c:set var="customVars">${customVars}--my-slider-caption-sub:${rgbVal};</c:set>
        </c:if>
    </c:if>
    <c:if test="${not empty customVars}">
        <c:set var="customVars">${' '}style="${customVars}"</c:set>
    </c:if>

    <c:if test="${not justOneSlide}">
        <c:set var="sliderData">${' '}<%--
        --%>data-slider='{<%--
            --%>"type": "${sliderType}", <%--
            --%>"arrows": ${showArrows}, <%--
            --%>"dots": ${showDots}, <%--
            --%>"autoplay": ${autoPlay}, <%--
            --%>"transition": "${transition}", <%--
            --%>"param": "${transitionParam}", <%--
            --%>"delay": ${rotationTime}, <%--
            --%>"speed": ${transitionSpeed}, <%--
            --%>"pause": ${pauseOnHover}<%--
        --%>}'<%--
    --%></c:set>
    </c:if>

    <div class="slider-box${customClass}${marginClass}"${customVars}${sliderData}><mercury:nl/>
    <div class="slide-definitions${logoRows}"><mercury:nl/>

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

        <c:set var="slideLink" value="" />
        <c:if test="${image.value.Link.isSet}">
            <c:set var="slideLink"><mercury:link-opencms targetLink="${image.value.Link.toLink}" /></c:set>
        </c:if>

        <mercury:nl />

        <div class="slide-wrapper${isHeroSlider ? '' : ' col'}${isHiddenSlide ? ' hide-noscript rs_skip' : ' slide-active'}${animationTrigger}"><%----%>
        <div class="slide-container"><%----%>
            <div class="visual${animationTarget}"><mercury:nl/>

                ${not empty slideLink ?
                    '<a href="'
                        .concat(slideLink)
                        .concat('" rel="noopener"')
                        .concat(image.value.NewWin.toBoolean ? ' target="_blank"' : '')
                        .concat(' class="slides">')
                    : '<span class="slides">'}

                    <cms:addparams>
                        <cms:param name="cssgrid">${adoptRatioToScreen ? 'col-xs-12 hidden-sm hidden-md hidden-lg hidden-xl hidden-xxl' : cssgridCols}</cms:param>
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
                            <cms:param name="cssgrid">hidden-xxl hidden-xl hidden-lg hidden-md hidden-xs</cms:param>
                            <div class="slide-sm visible-sm"><%----%>
                                <mercury:image-simple
                                    image="${image}"
                                    ratio="${imageRatioSM}"
                                    title="${image.value.SuperTitle.toString()}" />
                            </div><mercury:nl/>
                        </cms:addparams>

                        <cms:addparams>
                            <cms:param name="cssgrid">hidden-xxl hidden-xl hidden-lg hidden-sm hidden-xs</cms:param>
                            <div class="slide-md visible-md"><%----%>
                                <mercury:image-simple
                                    image="${image}"
                                    ratio="${imageRatioMD}"
                                    title="${image.value.SuperTitle.toString()}" />
                            </div><mercury:nl/>
                        </cms:addparams>

                        <cms:addparams>
                            <cms:param name="cssgrid">hidden-xxl hidden-xl hidden-xs hidden-sm hidden-md</cms:param>
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

                ${not empty slideLink ? '</a>':'</span>'}

                <c:if test="${showImageCopyright and (not empty copyright)}">
                    <div class="copyright rs_skip" aria-hidden="true">${copyright}</div><mercury:nl/>
                </c:if>
            </div><mercury:nl/>

            <c:if test="${not (sliderType eq 'logo')
                and (image.value.SuperTitle.isSet || image.value.TitleLine1.isSet || image.value.TitleLine2.isSet)}">

                ${not empty slideLink ?
                    '<a href="'
                        .concat(slideLink)
                        .concat('" rel="noopener"')
                        .concat(image.value.NewWin.toBoolean ? ' target="_blank"' : '')
                        .concat(' class="captions">')
                    : '<span class="captions">'}

                <div class="caption ${posTop}${' '}${posLeft}"><%----%>
                    <c:if test="${image.value.SuperTitle.isSet}">
                        <strong ${textStyle}>${image.value.SuperTitle}</strong><%----%>
                    </c:if>
                    <c:if test="${image.value.TitleLine1.isSet or image.value.TitleLine2.isSet}">
                        <div class="subcaption"><%----%>
                            <c:if test="${image.value.TitleLine1.isSet}">
                                <small ${textStyle}>${image.value.TitleLine1}</small><%----%>
                            </c:if>
                            <c:if test="${image.value.TitleLine2.isSet}">
                                <%-- br needed here for "custom" CSS setting when subcaption has different color --%>
                                <br><small ${textStyle}>${image.value.TitleLine2}</small><%----%>
                            </c:if>
                        </div><%----%>
                    </c:if>
                </div><%----%>

                ${not empty slideLink ? '</a>':'</span>'}

                <mercury:nl />
            </c:if>
        </div><%----%>
        </div><%----%>
        <mercury:nl />

        <c:set var="isHiddenSlide" value="${isHeroSlider && (status.count >= 1)}" />
    </c:forEach>
    </div><%----%>

    <c:if test="${not justOneSlide}">
        <c:if test="${showArrows}">
            <button class="slider-nav-btn prev-btn" aria-label="<fmt:message key='msg.page.list.pagination.previous.title' />" type="button"><%----%>
                <fmt:message key='msg.page.list.pagination.previous.title' /><%----%>
            </button><%----%>
            <button class="slider-nav-btn next-btn" aria-label="<fmt:message key='msg.page.list.pagination.next.title' />" type="button"><%----%>
                <fmt:message key='msg.page.list.pagination.next.title' /><%----%>
            </button><%----%>
        </c:if>
        <c:if test="${showDots}">
            <ul class="slider-dots" role="tablist"><%----%>
                <li type="button" role="presentation"><%----%>
                    <button type="button" class="dot-btn" role="tab" aria-selected="false" tabindex="-1"><fmt:message key='msg.page.slider.pagination.dots' /></button><%----%>
                </li><%----%>
            </ul><%----%>
        </c:if>
    </c:if>
    </div><%----%>

</div><%----%>
<mercury:nl />

</mercury:setting-defaults>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
