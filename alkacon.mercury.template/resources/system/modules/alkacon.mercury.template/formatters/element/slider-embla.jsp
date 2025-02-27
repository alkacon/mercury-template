<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<m:init-messages reload="true">

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:setting-defaults>

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />

<c:set var="justOneSlide"           value="${content.valueList.Image.size() < 2}" />

<c:set var="rotationTime"           value="${setting.rotationTime.isSet ? setting.rotationTime.toInteger : 0}" />
<c:set var="rotationTime"           value="${rotationTime < 0 ? 0 : rotationTime}" />
<c:set var="autoPlay"               value="${rotationTime > 0}" />
<c:set var="transition"             value="${setting.transition.validate(['swipe','fade','direct','parallax','scale'],'direct').toString}" />
<c:set var="transitionSpeed"        value="${setting.transitionSpeed.toInteger}" />
<c:set var="marginClass"            value="${' '}${setting.marginClass.toString}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="imageRatioXS"           value="${setting.imageRatioSmall.toString}" />
<c:set var="imageRatioXL"           value="${setting.imageRatioLarge.toString}" />
<c:set var="showArrows"             value="${setting.showArrows.toBoolean}" />
<c:set var="pauseOnHover"           value="${setting.pauseOnHover.toBoolean}" />
<c:set var="showDots"               value="${setting.showDots.toBoolean}" />
<c:set var="isDraggable"            value="${setting.isDraggable.useDefault('true').toBoolean}" />
<c:set var="visibleSlideSetting"    value="${setting.visibleSlides.toString}" />
<c:set var="textDisplay"            value="${setting.textDisplay.toString}" />

<c:set var="bgColorHead"            value="${setting.textColorHead.isSet and not (setting.textColorHead eq 'css') ? setting.textColorHead.toString : ''}" />
<c:set var="bgColorSub"             value="${setting.textColorSub.isSet and not (setting.textColorSub eq 'css') ? setting.textColorSub.toString : ''}" />

<c:set var="sliderType"             value="${setting.sliderType.toString}" />
<c:set var="sliderType"             value="${not autoPlay and sliderType eq 'timed' ? 'hero' : sliderType}" />
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
        <c:set var="transition" value="logo" />
        <c:set var="cssgutter" value="20" />
        <c:set var="showDots" value="${false}" />
        <c:set var="pauseOnHover" value="${false}" />
        <c:set var="adoptRatioToScreen" value="${false}" />
        <c:set var="animationTrigger" value="${empty setEffect ? '' : ' '.concat(setEffect)}" />
        <c:set var="animationTarget" value="${empty setEffect ? '' : ' effect-box'}" />
    </c:when>
    <c:when test="${sliderType eq 'timed'}">
    <%-- Time depending hero slider --%>
        <c:set var="isHeroSlider" value="${true}" />
        <c:set var="marginClass" value=" tr-timed" />
        <c:set var="transition" value="timed" />
        <c:set var="autoPlay" value="${false}" />
        <c:set var="rotationTime" value="${rotationTime < 500 ? 500 : rotationTime}" />
        <c:set var="rotationTime" value="${rotationTime * 60}" />
        <c:set var="transitionSpeedClass" value="" />
        <c:set var="transitionSpeed" value="${100}" />
        <c:set var="transitionParam" value="${content.resource.dateReleased eq 0 ? content.resource.dateLastModified : content.resource.dateReleased}" />
        <c:set var="visibleSlidesXL" value="${1}" />
        <c:set var="visibleSlidesXS" value="${1}" />
        <c:set var="adoptRatioToScreen" value="${not (imageRatioXL eq imageRatioXS)}" />
    </c:when>
    <c:otherwise>
    <%-- Hero slider (default) --%>
        <c:set var="isHeroSlider" value="${true}" />
        <c:set var="marginClass" value="${marginClass}${' tr-'.concat(transition)}" />
        <c:set var="transitionSpeedClass" value="${transitionSpeed <  4 ? ' sp-slow' : ' sp-medium'}" />
        <c:set var="transitionSpeedClass" value="${transitionSpeed <  8 ? transitionSpeedClass : ' sp-fast'}" />
        <c:if test="${transition eq 'direct'}">
            <c:set var="transitionSpeed" value="${100}" />
        </c:if>
        <c:set var="transitionParam" value="${transition eq 'parallax' ? 0.75 : 2.0}" />
        <c:set var="visibleSlidesXL" value="${1}" />
        <c:set var="visibleSlidesXS" value="${1}" />
        <c:set var="adoptRatioToScreen" value="${not (imageRatioXL eq imageRatioXS)}" />
    </c:otherwise>
</c:choose>

<div class="element type-slider${justOneSlide ? ' just-one-slide' : ' use-embla-slider'}${isHeroSlider ? ' hero-slider ' : ' logo-slider '}pivot pivot-full${setCssWrapper123}${setCssVisibility}${' '}${textDisplay}" <%--
--%>id="<m:idgen prefix='sl' uuid='${cms.element.id}' />"<%--
--%>><m:nl />

    <m:heading level="${hsize}" text="${value.Title}" css="heading" ade="${ade}" />

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
        <c:set var="rgbVal" value="${cms.color.toRgb(value.TextBackgroundColor)}" />
        <c:if test="${not empty rgbVal}">
            <c:set var="customVars">--my-slider-bg:${rgbVal};</c:set>
        </c:if>
    </c:if>
    <c:if test="${value.TextColor.isSet}">
        <c:set var="rgbVal" value="${cms.color.toRgb(value.TextColor)}" />
        <c:if test="${not empty rgbVal}">
            <%-- text color must nor be RGB, we use this as check for valid values --%>
            <c:set var="customVars">${customVars}--my-slider-fg:${value.TextColor};</c:set>
        </c:if>
    </c:if>
    <c:if test="${not empty bgColorHead}">
        <c:set var="customClass" value=" custom" />
        <c:set var="rgbVal" value="${cms.color.toRgb(bgColorHead)}" />
        <c:if test="${not empty rgbVal}">
            <c:set var="customVars">${customVars}--my-slider-caption-top:${rgbVal};</c:set>
        </c:if>
    </c:if>
    <c:if test="${not empty bgColorSub}">
        <c:set var="customClass" value=" custom" />
        <c:set var="rgbVal" value="${cms.color.toRgb(bgColorSub)}" />
        <c:if test="${not empty rgbVal}">
            <c:set var="customVars">${customVars}--my-slider-caption-sub:${rgbVal};</c:set>
        </c:if>
    </c:if>
    <c:if test="${not empty customVars}">
        <c:set var="customVars">${' '}style="${customVars}"</c:set>
    </c:if>

    <c:if test="${not justOneSlide}">
        <c:set var="sliderData">data-slider='{<%--
            --%>"transition": "${transition}", <%--
            --%>"autoplay": ${autoPlay}, <%--
            --%>"delay": ${rotationTime}, <%--
            --%>"param": "${transitionParam}", <%--
            --%>"speed": ${transitionSpeed}, <%--
            --%>"draggable": ${isDraggable}, <%--
            --%>"arrows": ${showArrows}, <%--
            --%>"dots": ${showDots}, <%--
            --%>"pause": ${pauseOnHover}<%--
        --%>}'<%--
    --%></c:set>
    </c:if>

    <div class="slider-box${customClass}${marginClass}${transitionSpeedClass}"${customVars}${not empty sliderData ? ' '.concat(sliderData) : ''}><m:nl/>
    <div class="slide-definitions${logoRows}"><m:nl/>

    <c:forEach var="image" items="${content.valueList.Image}" varStatus="status">

        <c:set var="lazyLoad" value="${true}" />
        <%-- Tests show that if the first slide is NOT lazy loaded then there are multiple size versions of the slider image requested --%>

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
            <c:set var="slideLink"><m:link-opencms targetLink="${image.value.Link.toLink}" /></c:set>
        </c:if>

        <c:set var="dateRelease" value="${image.value.Availability.value.Release.isSet ? image.value.Availability.value.Release.toString : null}" />
        <c:set var="dateExpiration" value="${image.value.Availability.value.Expiration.isSet ? image.value.Availability.value.Expiration.toString : null}" />
        <c:set var="validRange" value="" />
        <c:if test="${not empty dateRelease or not empty dateExpiration}">
             <c:set var="validRange">
                <c:if test="${not empty dateRelease}">${' '}data-release="${dateRelease}"</c:if>
                <c:if test="${not empty dateExpiration}">${' '}data-expiration="${dateExpiration}"</c:if>
             </c:set>
        </c:if>

        <m:nl />

        <div class="slide-wrapper${isHeroSlider ? '' : ' col'}${isHiddenSlide ? ' hide-noscript rs_skip' : ' slide-active'}${' '}${animationTrigger}"${not empty validRange ? ' '.concat(validRange) : '' }><%----%>
            <div class="slide-container"><%----%>
                <div class="visual${animationTarget}"><m:nl/>

                    ${not empty slideLink ?
                        '<a href="'
                            .concat(slideLink)
                            .concat('" rel="noopener"')
                            .concat(image.value.NewWin.toBoolean ? ' target="_blank"' : '')
                            .concat(' class="slides">')
                        : '<div class="slides">'}

                        <cms:addparams>
                            <cms:param name="cssgrid">${adoptRatioToScreen ? 'col-xs-12 hidden-sm hidden-md hidden-lg hidden-xl hidden-xxl' : cssgridCols}</cms:param>
                            <cms:param name="cssgutter">${not empty cssgutter ? cssgutter : '#'}</cms:param>
                            <div class="slide-xs ${adoptRatioToScreen ? 'visible-xs' : ''}"><%----%>
                                <m:image-simple
                                    image="${image}"
                                    lazyLoad="${lazyLoad}"
                                    ratio="${imageRatioXS}"
                                    externalCopyright="${showImageCopyright}"
                                    title="${image.value.SuperTitle.toString()}">
                                        <c:set var="copyright" value="${imageCopyrightHtml}" />
                                </m:image-simple>
                            </div><m:nl/>
                        </cms:addparams>

                        <c:if test="${adoptRatioToScreen}">

                            <m:image-vars image="${image}" ratio="${imageRatioXL}">
                                <c:set var="ibLg" value="${imageBean}" />
                            </m:image-vars>

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
                                    <m:image-simple
                                        image="${image}"
                                        lazyLoad="${lazyLoad}"
                                        ratio="${imageRatioSM}"
                                        externalCopyright="${showImageCopyright}"
                                        title="${image.value.SuperTitle.toString()}" />
                                </div><m:nl/>
                            </cms:addparams>

                            <cms:addparams>
                                <cms:param name="cssgrid">hidden-xxl hidden-xl hidden-lg hidden-sm hidden-xs</cms:param>
                                <div class="slide-md visible-md"><%----%>
                                    <m:image-simple
                                        image="${image}"
                                        lazyLoad="${lazyLoad}"
                                        ratio="${imageRatioMD}"
                                        externalCopyright="${showImageCopyright}"
                                        title="${image.value.SuperTitle.toString()}" />
                                </div><m:nl/>
                            </cms:addparams>

                            <cms:addparams>
                                <cms:param name="cssgrid">hidden-xxl hidden-xl hidden-xs hidden-sm hidden-md</cms:param>
                                <div class="slide-lg visible-lg"><%----%>
                                    <m:image-simple
                                        image="${image}"
                                        lazyLoad="${lazyLoad}"
                                        ratio="${imageRatioLG}"
                                        externalCopyright="${showImageCopyright}"
                                        title="${image.value.SuperTitle.toString()}" />
                                </div><m:nl/>
                            </cms:addparams>

                            <cms:addparams>
                                <cms:param name="cssgrid">hidden-lg hidden-xs hidden-sm hidden-md</cms:param>
                                <div class="slide-xl visible-xl"><%----%>
                                    <m:image-simple
                                        image="${image}"
                                        lazyLoad="${lazyLoad}"
                                        ratio="${imageRatioXL}"
                                        externalCopyright="${showImageCopyright}"
                                        title="${image.value.SuperTitle.toString()}" />
                                </div><m:nl/>
                            </cms:addparams>

                        </c:if>

                    ${not empty slideLink ? '</a>':'</div>'}

                    <c:if test="${showImageCopyright and (not empty copyright)}">
                        <div class="copyright rs_skip" aria-hidden="true">${copyright}</div><m:nl/>
                    </c:if>
                </div><m:nl/>

                <c:if test="${not (sliderType eq 'logo')
                    and (image.value.SuperTitle.isSet || image.value.TitleLine1.isSet || image.value.TitleLine2.isSet)}">

                    ${not empty slideLink ?
                        '<a href="'
                            .concat(slideLink)
                            .concat('" rel="noopener"')
                            .concat(image.value.NewWin.toBoolean ? ' target="_blank"' : '')
                            .concat(' class="captions">')
                        : '<div class="captions">'}

                    <div class="caption ${posTop}${' '}${posLeft}"><%----%>
                        <c:if test="${image.value.SuperTitle.isSet}">
                            <strong ${textStyle}><m:out value="${image.value.SuperTitle}" lenientEscaping="${true}" /></strong><%----%>
                        </c:if>
                        <c:if test="${image.value.TitleLine1.isSet or image.value.TitleLine2.isSet}">
                            <div class="subcaption"><%----%>
                                <c:if test="${image.value.TitleLine1.isSet}">
                                    <small ${textStyle}><m:out value="${image.value.TitleLine1}" lenientEscaping="${true}" /></small><%----%>
                                </c:if>
                                <c:if test="${image.value.TitleLine2.isSet}">
                                    <%-- br needed here for "custom" CSS setting when subcaption has different color --%>
                                    <br><small ${textStyle}><m:out value="${image.value.TitleLine2}" lenientEscaping="${true}" /></small><%----%>
                                </c:if>
                            </div><%----%>
                        </c:if>
                    </div><%----%>

                    ${not empty slideLink ? '</a>':'</div>'}

                    <m:nl />
                </c:if>
            </div><%----%>
        </div><%----%>
        <m:nl />

        <c:set var="isHiddenSlide" value="${isHeroSlider}" />
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
                <li><%----%>
                    <button type="button" class="dot-btn" role="tab" aria-selected="false" tabindex="-1"><fmt:message key='msg.page.slider.pagination.dots' /></button><%----%>
                </li><%----%>
            </ul><%----%>
        </c:if>
    </c:if>
    </div><%----%>

</div><%----%>
<m:nl />

</m:setting-defaults>

</cms:bundle>
</cms:formatter>

</m:init-messages>
