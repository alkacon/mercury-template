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
<mercury:init-messages>

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<mercury:setting-defaults>

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="visualOption"           value="${setting.visualOption.toString}" />
<c:set var="firstOpen"              value="${setting.firstOpen.toBoolean}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />
<c:set var="itemsSmall"             value="${setting.itemsSmall.toInteger}" />
<c:set var="itemsLarge"             value="${setting.itemsLarge.toInteger}" />
<c:set var="rowWrapper"             value="${setting.rowWrapper.toString}" />
<c:set var="showButton"             value="${setting.showButton.toBoolean}" />
<c:set var="showBorder"             value="${setting.showBorder.toBoolean}" />

<c:set var="tileImageRatio"         value="${setting.imageRatio.toString}" />
<c:set var="tileFullOverlay"        value="${setting.fullOverlay.toString}" />
<c:set var="tileTextOption"         value="${setting.textOption.toString}" />
<c:set var="tileShowImageCopyright" value="${setting.showImageCopyright.toString}" />
<c:set var="tileTextAlignment"      value="${setting.textAlignment.useDefault('pal').toString}" />
<c:set var="tileEffect"             value="${setting.effect.toString}" />

<c:set var="ade"                    value="${cms.isEditMode}" />

<c:set var="parentId"><mercury:idgen prefix="a" uuid="${cms.element.instanceId}" /></c:set>

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

<mercury:nl />
<div class="element type-tab variant-tile-accordion${showButton ? ' show-button' : ' hide-button'}${showBorder ? ' show-border' : ''}${setCssWrapper123}"><%----%>
<mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading pivot" />

    <mercury:alert test="${cms.isEditMode and content.valueList.TabEntry.size() > 12}" type="warning">
        <jsp:attribute name="head">
            <fmt:message key="msg.error.tab.itemcount.head" />
        </jsp:attribute>
        <jsp:attribute name="text">
            <fmt:message key="msg.error.tab.itemcount.text">
                <fmt:param>${content.valueList.TabEntry.size()}</fmt:param>
            </fmt:message>
        </jsp:attribute>
    </mercury:alert>

    <div class="tile-accordion collapse-parent row ${rowWrapper}" id="${parentId}"><%----%>

        <c:forEach var="tabEntry" items="${content.valueList.TabEntry}" varStatus="status">

            <c:set var="open"               value="${firstOpen and status.first}" />
            <c:set var="itemId"             value="${parentId}_${fn:replace(tabEntry.value.Id, 'tab-', '')}" />

            <mercury:nl />

            <span class="collapse-trigger ${triggerColCss}${open ? '':' collapsed'}" <%--
                --%>data-bs-toggle="collapse" type="button" <%--
                --%>aria-expanded="${open}" <%--
                --%>aria-controls="${itemId}"<%--
                --%>data-bs-target="#${itemId}"><%----%>
                <c:if test="${cms.isEditMode}">
                    <a href="#${itemId}" class="hash-link"><%----%>
                        <span class="badge oct-meta-info"><%----%>
                            <mercury:icon icon="hashtag" tag="span" />
                        </span><%----%>
                    </a><%----%>
                </c:if>
                <mercury:container
                    title="${tabEntry.value.Label}"
                    css="collapse-trigger-container"
                    name="${tabEntry.value.Id}-tile"
                    hideName="${true}"
                    hideParentType="${true}"
                    type="tab-tile"
                    maxElements="${2}"
                    value="${triggerMap}"
                    settings="${{
                        'cssWrapper':           'collapse-trigger-item',
                        'cssWrapper2':          '',
                        'cssWrapper3':          '',
                        'cssVisibility':        'always',
                        'hsize':                '7',
                        'textOption':           'none',
                        'linkOption':           'hide',
                        'disableAde':           'true',
                        'effect':               tileEffect,
                        'imageRatio':           tileImageRatio,
                        'fullOverlay':          tileFullOverlay,
                        'textAlignment':        tileTextAlignment,
                        'showImageCopyright':   tileShowImageCopyright
                    }}"
                />
            </span><%----%>

            <div id="${itemId}" class="collapse-target acco-body collapse ${targetColCss}${' '}${open ? 'show' : ''}" data-bs-parent="#${parentId}"><%----%>
                <mercury:container
                    title="${msg}"
                    css="collapse-container"
                    name="${tabEntry.value.Id}"
                    hideName="${true}"
                    hideParentType="${true}"
                    type="${containerType}"
                />
            </div><%----%>

            <mercury:nl />

        </c:forEach>

    </div><%----%>

</div><%----%>
<mercury:nl />

</mercury:setting-defaults>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
