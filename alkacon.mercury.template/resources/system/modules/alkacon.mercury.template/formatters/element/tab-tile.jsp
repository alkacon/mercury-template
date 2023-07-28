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
<c:set var="itemsLarge"             value="${setting.itemsLarge.toInteger}" />
<c:set var="rowWrapper"             value="${setting.rowWrapper.toString}" />
<c:set var="showButton"             value="${setting.showButton.toBoolean}" />

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
<div class="element type-tab variant-tile-accordion${showButton ? ' show-button' : ' hide-button'}${setCssWrapperAll}"><%----%>
<mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading pivot" />

    <div class="tile-accordion collapse-parent row ${rowWrapper}" id="${parentId}"><%----%>

        <c:forEach var="tabEntry" items="${content.valueList.TabEntry}" varStatus="status">

            <c:set var="open"               value="${firstOpen and status.first}" />
            <c:set var="itemId"             value="${parentId}_${fn:replace(tabEntry.value.Id, 'tab-', '')}" />
            <c:set var="itemHsize"          value="${hsize > 0 ? hsize + 1 : 2}" />

            <mercury:nl />

            <span class="ta-trigger ${triggerColCss}${open ? '':' collapsed'}" <%--
                --%>data-bs-toggle="collapse" type="button" <%--
                --%>aria-expanded="${open}" <%--
                --%>aria-controls="${itemId}"<%--
                --%>data-bs-target="#${itemId}"><%----%>
                <mercury:container
                    title="Kachel ${status.count}"
                    css="ta-container"
                    name="${tabEntry.value.Id}-tile"
                    hideName="${true}"
                    hideParentType="${true}"
                    type="tile"
                    maxElements="${2}"
                    value="${triggerMap}"
                    settings="${{
                        'cssWrapper':       'ta-trigger-item',
                        'cssWrapper2':      '',
                        'cssWrapper3':      '',
                        'linkOption':       'hide',
                        'disableAde':       'true'
                    }}"
                />
            </span><%----%>

            <div id="${itemId}" class="ta-target collapse ${targetColCss}${' '}${open ? 'show' : ''}" data-bs-parent="#${parentId}"><%----%>
                <mercury:container
                    title="${msg}"
                    css="ta-container"
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
