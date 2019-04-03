<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:init-messages reload="true">
<cms:formatter var="content" val="value">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper.toString}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}"/>

<div class="element type-complex-slider ${cssWrapper}"
        data-sid="${content.file.structureId}"
        data-delay="${value.Delay}"
        data-height="${value.ImageHeight}"
        data-heightsm="${value.ImageHeightSM.isSet ? value.ImageHeightSM : ''}"
        data-arrows="${value.ShowNavButtons.toBoolean}"
        data-navbutton="${value.ShowNumbers.toBoolean}"
        data-navtype="bottom"
        data-onhoverstop="${value.PauseOnHover.exists && value.PauseOnHover.toBoolean ? 'on' : 'off'}"
        data-noprogressbar="${value.ShowTimer.toBoolean ? 'off' : 'on'}"
        data-responsive="${value.Responsive.toBoolean}"
        data-init="false"
        data-ext="<cms:link>/system/modules/alkacon.mercury.xtensions/revolution-slider/extensions/</cms:link>" >

    <mercury:heading level="${hsize}" text="${value.Title}" css="head" ade="${false}" />

    <div class="fullwidthbanner-container">

        <div class="rev_slider slider ${value.Responsive.toBoolean ? 'rev-sl-responsive' : ''}" style="display:none;" id="rev-slider-${content.file.structureId}" data-version="5.4.0">
            <c:set var="slTransition">${value.SlideTransition.isSet ? value.SlideTransition : "fade"}</c:set>
            <ul>
                <c:forEach var="slide" items="${content.valueList.Slide}" varStatus="status">

                    <li data-transition="${slide.value.Transition.isSet ? slide.value.Transition : slTransition}" <%--
                    --%><c:if test="${slide.value.Link.isSet}"> data-link="<cms:link>${slide.value.Link}</cms:link>"${(slide.value.NewWin.isSet and slide.value.NewWin eq 'true')?' data-target="_blank"':''}</c:if>>

                        <mercury:image-vars image="${slide}">
                            <img src="<cms:link>/system/modules/alkacon.mercury.xtensions/revolution-slider/assets/coloredbg.png</cms:link>" <%--
                            --%>data-lazyload="<cms:link>${imageLink}</cms:link>" <%--
                            --%>alt="${imageTitle}" <%--
                            --%>title="${imageTitle}"<%--
                            --%>/>
                        </mercury:image-vars>

                        <c:forEach var="item" items="${slide.valueList.Layer}" varStatus="statusCaption">
                            <c:choose>
                                <c:when test="${item.value.Image.isSet}">
                                    <c:set var="layerType" value="image" />
                                    <c:set var="layer" value="${item.value.Image}" />
                                </c:when>
                                <c:otherwise>
                                    <c:set var="layerType" value="text" />
                                    <c:set var="layer" value="${item.value.Text}" />
                                </c:otherwise>
                            </c:choose>
                            <c:set var="x">${layer.value.PosX}</c:set>
                            <c:set var="configAttrs">${layer.value.Configuration}</c:set>
                            <c:set var="autoValues">${x},${(970 / 1170) * x},${(750 / 1170) * x},${(750 / 1170) * x},${(570 / 1170) * x}</c:set>
                               <c:set var="layerConfig">
                                   <c:choose>
                                    <c:when test="${not fn:contains(configAttrs, 'data-x') and value.Responsive.toBoolean}">
                                        ${' '}data-x="[${autoValues}]"
                                    </c:when>
                                    <c:when test="${fn:contains(configAttrs, 'data-x') and value.Responsive.toBoolean}">
                                        <c:set var="newConfigAttrs">${fn:substringBefore(configAttrs, 'data-x')}</c:set>
                                        <c:set var="xValues">${fn:substringAfter(configAttrs, 'data-x')}</c:set>
                                        <c:set var="xValues">${fn:substringAfter(xValues, '[')}</c:set>
                                        <c:set var="newConfigAttrs">${newConfigAttrs}${' '}${fn:substringAfter(xValues, ']"')}</c:set>
                                        <c:set var="xValues">${fn:substringBefore(xValues, ']')}</c:set>
                                        <c:if test="${fn:contains(xValues, '#')}">
                                            <c:set var="configAttrs">${newConfigAttrs}</c:set>
                                            <c:set var="xList" value="${fn:split(xValues, ',')}" />
                                            <c:set var="autoList" value="${fn:split(autoValues, ',')}" /><%--
                                        --%>${' '}data-x="[<%--
                                        --%><c:forEach var="currX" items="${xList}" varStatus="xStatus">
                                                <c:choose>
                                                    <c:when test="${fn:contains(currX, '#')}">'${autoList[xStatus.index]}'</c:when>
                                                    <c:otherwise>
                                                        <c:if test="${not fn:contains(currX, '\\'')}">'</c:if><%--
                                                         --%>${fn:trim(currX)}<%--
                                                     --%><c:if test="${not fn:contains(currX, '\\'')}">'</c:if>
                                                    </c:otherwise>
                                                </c:choose>
                                                <c:if test="${not xStatus.last}">,</c:if>
                                            </c:forEach><%--
                                         --%>]"<%--
                                    --%></c:if>
                                    </c:when>
                                    <c:when test="${not fn:contains(configAttrs, 'data-x') and not value.Responsive.toBoolean}">
                                        ${' '}data-x="[${x}]"
                                    </c:when>
                                </c:choose>
                                <c:if test="${not fn:contains(configAttrs, 'data-y')}">${' '}data-y="${layer.value.PosY}"</c:if>
                                <c:if test="${not fn:contains(configAttrs, 'data-width')}">${' '}data-width="auto"</c:if>
                                <c:if test="${not fn:contains(configAttrs, 'data-height')}">${' '}data-height="auto"</c:if>
                                <c:if test="${not fn:contains(configAttrs, 'data-whitespace')}">${' '}data-whitespace="nowrap"</c:if>
                                <c:if test="${not fn:contains(configAttrs, 'data-frames')}">${' '}data-frames="[{'delay':0,'speed':300,'frame':'0','from':'opacity:0;','to':'o:1;','ease':'Power3.easeInOut'},{'delay':'wait','speed':300,'frame':'999','to':'auto:auto;','ease':'Power3.easeInOut'}]"</c:if>
                                ${' '}${configAttrs}
                            </c:set>
                            <c:set var="tagtype" value="${layer.value.Tag.isEmptyOrWhitespaceOnly ? 'div' : layer.value.Tag}" />
                            <${tagtype} class="caption tp-caption ${layer.value.Class}" ${layerConfig}><%--
                            --%><c:if test="${layerType == 'image'}"><img src="<cms:link>${layer.value.Image}</cms:link>" alt="" /></c:if><%--
                            --%><c:if test="${layerType == 'text'}">${layer.value.Text}</c:if><%--
                         --%></${tagtype}>
                        </c:forEach>

                        <mercury:image-vars image="${slide}" escapeCopyright="${false}">
                            <c:if test="${showImageCopyright and not empty imageCopyrightHtml}">
                                <div class="tp-caption caption copyright" <%--
                                --%>data-x="left" <%--
                                --%>data-y="bottom" <%--
                                --%>data-basealign="slide" <%--
                                --%>data-width="auto" <%--
                                --%>data-whitespace="nowrap" <%--
                                --%>data-frames='[{ "delay": 100, "speed": 800, "from": "opacity: 0", "to": "opacity: 0.9"}, { "delay": "wait", "speed": 800, "to": "opacity: 0"}]'><%--
                                    --%>${imageCopyrightHtml}<%--
                            --%></div>
                            </c:if>
                        </mercury:image-vars>

                    </li>
                </c:forEach>
            </ul>
        </div>
    </div>

</div>

</cms:formatter>

</mercury:init-messages>
