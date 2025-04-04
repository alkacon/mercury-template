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
<m:init-messages>

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:setting-defaults>

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="visualOption"           value="${setting.visualOption.toString}" />
<c:set var="firstOpen"              value="${setting.firstOpen.toBoolean}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />
<c:set var="itemsSmall"             value="${setting.itemsSmall.toInteger}" />
<c:set var="itemsLarge"             value="${setting.itemsLarge.toInteger}" />
<c:set var="rowWrapper"             value="${setting.rowWrapper.toString}" />
<c:set var="showButton"             value="${setting.showButton.toBoolean}" />
<c:set var="showBorder"             value="${setting.showBorder.toBoolean}" />

<c:set var="tileTextBgColor"        value="${setting.textBgColor.toString}" />
<c:set var="tileBtnBgColor"         value="${setting.btnBgColor.toString}" />
<c:set var="tileImageRatio"         value="${setting.imageRatio.toString}" />
<c:set var="tileFullOverlay"        value="${setting.fullOverlay.toString}" />
<c:set var="tileTextOption"         value="${setting.textOption.toString}" />
<c:set var="tileShowImageCopyright" value="${setting.showImageCopyright.toString}" />
<c:set var="tileTextAlignment"      value="${setting.textAlignment.useDefault('pal').toString}" />
<c:set var="tileEffect"             value="${setting.effect.toString}" />

<c:set var="ade"                    value="${cms.isEditMode}" />

<c:set var="parentId"><m:idgen prefix="a" uuid="${cms.element.instanceId}" /></c:set>

<c:choose>
    <c:when test="${itemsLarge eq 2}">
        <c:set var="triggerColCss"          value="col-${itemsSmall} col-md-4 col-lg-2" />
        <c:set var="targetColCss"           value="col-12${itemsSmall eq 6 ? ' target-6' : ''} target-md-4 target-lg-2" />
    </c:when>
    <c:otherwise>
        <c:set var="triggerColCss"          value="col-${itemsSmall} col-md-${itemsLarge}" />
        <c:set var="targetColCss"           value="col-12${itemsSmall eq 6 ? ' target-6' : ''} target-md-${itemsLarge}" />
    </c:otherwise>
</c:choose>

<c:if test="${rowWrapper eq 'tile-margin-0'}">
    <c:set var="showBorder"           value="${false}" />
</c:if>

<c:choose>
    <c:when test="${tileFullOverlay eq 'top'}">
        <c:set var="overlayWrapper"     value="full-overlay boxbg-overlay" />
    </c:when>
    <c:when test="${tileFullOverlay eq 'bottom'}">
        <c:set var="overlayWrapper"     value="text-overlay" />
    </c:when>
    <c:otherwise>
        <%-- tileFullOverlay should be 'below' --%>
        <c:set var="overlayWrapper"     value="text-overlay" />
        <c:set var="textBelow"          value="${true}" />
    </c:otherwise>
</c:choose>

<jsp:useBean id="triggerMap"        class="java.util.HashMap" />

<c:set target="${triggerMap}" property="Parameters"  value="${{'cssgrid': triggerColCss}}" />

<c:choose>
    <c:when test="${containerType eq 'row'}">
        <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.row"/></c:set>
    </c:when>
    <c:otherwise>
        <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.element"/></c:set>
    </c:otherwise>
</c:choose>

<m:nl />
<div class="element type-tab variant-tile-accordion${showButton ? ' show-button' : ' hide-button'}${showBorder ? ' show-border' : ''}${textBelow ? ' text-below' : ''}${setCssWrapper123}"><%----%>
<m:nl />

    <m:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading pivot" />

    <m:alert test="${cms.isEditMode and content.valueList.TabEntry.size() > 12}" type="warning">
        <jsp:attribute name="head">
            <fmt:message key="msg.error.tab.itemcount.head" />
        </jsp:attribute>
        <jsp:attribute name="text">
            <fmt:message key="msg.error.tab.itemcount.text">
                <fmt:param>${content.valueList.TabEntry.size()}</fmt:param>
            </fmt:message>
        </jsp:attribute>
    </m:alert>

    <div class="tile-accordion collapse-parent row ${rowWrapper}" id="${parentId}"><%----%>

        <c:forEach var="tabEntry" items="${content.valueList.TabEntry}" varStatus="status">

            <c:set var="open"               value="${firstOpen and status.first}" />
            <c:set var="itemId"             value="${parentId}_${fn:replace(tabEntry.value.Id, 'tab-', '')}" />

            <m:nl />

            <span class="collapse-trigger ${tileBtnBgColor}${' '}${triggerColCss}${open ? '':' collapsed'}" <%--
                --%>data-bs-toggle="collapse" type="button" role="button" <%--
                --%>aria-expanded="${open}" <%--
                --%>aria-controls="${itemId}"<%--
                --%>data-bs-target="#${itemId}"><%----%>
                <c:if test="${cms.isEditMode}">
                    <a href="#${itemId}" class="hash-link"><%----%>
                        <span class="badge oct-meta-info"><%----%>
                            <m:icon icon="hashtag" tag="span" />
                        </span><%----%>
                    </a><%----%>
                </c:if>

                <m:tile-col
                    tileWrapper="trigger-item tile-col col-12 freefloat"
                    boxWrapper="${tileEffect}"
                    overlayWrapper="${overlayWrapper}${' '}${tileTextBgColor}"
                    heading="${tabEntry.value.Label}"
                    hsize="${7}"
                    image="${tabEntry.value.Image}"
                    imageRatio="${tileImageRatio}"
                    textAlignment="${tileTextAlignment}"
                    showImageCopyright="${tileShowImageCopyright}"
                    textOption="none"
                    linkOption="hide"
                    ade="${false}"
                />

            </span><%----%>

            <div id="${itemId}" class="collapse-target acco-body collapse ${targetColCss}${' '}${open ? 'show' : ''}" data-bs-parent="#${parentId}"><%----%>
                <m:container
                    title="${msg}"
                    css="collapse-container"
                    name="${tabEntry.value.Id}"
                    hideName="${true}"
                    hideParentType="${true}"
                    type="${containerType}"
                />
            </div><%----%>

            <m:nl />

        </c:forEach>

    </div><%----%>

</div><%----%>
<m:nl />

</m:setting-defaults>

</cms:bundle>
</cms:formatter>

</m:init-messages>
