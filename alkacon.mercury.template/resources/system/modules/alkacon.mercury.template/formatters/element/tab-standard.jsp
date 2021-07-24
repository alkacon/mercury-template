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

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="showSingleTab"          value="${setting.showSingleTab.useDefault('true').toBoolean}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />

<c:set var="ade"                    value="${cms.isEditMode}" />
<c:set var="showTabs"               value="${showSingleTab or (content.valueList.TabEntry.size() ne 1)}" />

<c:set var="itemId"><mercury:idgen prefix="acco" uuid="${cms.element.instanceId}" /></c:set>
<c:set var="param_parts"            value="${fn:split(cms.container.param, '#')}" />
<c:set var="parent_role"            value="${param_parts[0]}" />
<c:set var="parent_classes"         value="${param_parts[1]}" />


<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:choose>
    <c:when test="${containerType eq 'row'}">
        <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.row"/></c:set>
    </c:when>
    <c:otherwise>
        <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.element"/></c:set>
    </c:otherwise>
</c:choose>

<mercury:nl />
<div class="element type-tab ${showTabs ? 'variant-tabs ' : 'variant-hidden-tabs '}${cssWrapper}"><%----%>
<mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading" />

    <c:choose>
        <c:when test="${showTabs}">

            <div class="tabs-parent"><%----%>

                <mercury:nl />
                <ul class="tab-list nav"><%----%>

                    <c:forEach var="tabEntry" items="${content.valueList.TabEntry}" varStatus="status">
                        <c:set var="tabLabel" value="${tabEntry.value.Label}" />
                        <mercury:nl />
                        <li><%----%>
                            <a href="#${itemId}_${status.count}" ${status.first ? ' class="active"' : ''} data-toggle="tab">${tabLabel}</a><%----%>
                        </li><%----%>
                    </c:forEach>

                <mercury:nl />
                </ul><%----%>
                <mercury:nl />

                <div class="tab-content"><%----%>
                <mercury:nl />

                    <c:forEach var="tabEntry" items="${content.valueList.TabEntry}" varStatus="status">
                        <c:set var="tabContainerName" value="${tabEntry.value.Id}" />

                        <mercury:nl />
                        <div id="${itemId}_${status.count}" class="tab-pane fade ${status.first? 'active show':''}" ><%----%>
                            <mercury:nl />
                            <mercury:nl />

                            <mercury:container
                                title="${msg}"
                                name="${tabContainerName}"
                                hideName="${true}"
                                type="${containerType}"
                            />

                            <mercury:nl />
                        </div><%----%>
                        <mercury:nl />

                    </c:forEach>

                </div><%----%>
                <mercury:nl />

            </div><%----%>

        </c:when>
        <c:otherwise>

            <mercury:container
                title="${msg}"
                name="${content.valueList.TabEntry[0].value.Id}"
                hideName="${true}"
                type="${containerType}"
            />
            <mercury:nl />

        </c:otherwise>
    </c:choose>



</div><%----%>
<mercury:nl />

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
