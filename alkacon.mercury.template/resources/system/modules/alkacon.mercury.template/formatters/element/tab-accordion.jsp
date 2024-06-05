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
<c:set var="multipleOpen"           value="${setting.multipleOpen.toBoolean}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />

<c:set var="ade"                    value="${cms.isEditMode}" />

<c:set var="tabHsize"               value="${hsize > 0 ? hsize + 1 : 2}" />
<c:set var="parentId"><m:idgen prefix="a" uuid="${cms.element.instanceId}" /></c:set>

<c:choose>
    <c:when test="${containerType eq 'row'}">
        <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.row"/></c:set>
    </c:when>
    <c:otherwise>
        <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.element"/></c:set>
    </c:otherwise>
</c:choose>

<m:nl />
<div class="element type-tab variant-accordion${setCssWrapperAll}"><%----%>
<m:nl />

    <m:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading pivot" />

    <div class="accordion-items" id="${parentId}"><%----%>

        <c:forEach var="tabEntry" items="${content.valueList.TabEntry}" varStatus="status">

            <m:accordion
                cssWrapper="${cssWrapper}"
                parentId="${parentId}"
                tabId="${parentId}_${fn:replace(tabEntry.value.Id, 'tab-', '')}"
                tabLabel="${tabEntry.value.Label}"
                tabHsize="${tabHsize}"
                open="${firstOpen and status.first}"
                multipleOpen="${multipleOpen}">

                <m:container
                    title="${msg}"
                    name="${tabEntry.value.Id}"
                    hideName="${true}"
                    hideParentType="${true}"
                    type="${containerType}"
                />

            </m:accordion>

        </c:forEach>

    </div><%----%>

</div><%----%>
<m:nl />

</m:setting-defaults>

</cms:bundle>
</cms:formatter>

</m:init-messages>
