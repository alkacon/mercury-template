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
<c:set var="visualOption"           value="${setting.visualOption.toString}" />
<c:set var="firstOpen"              value="${setting.firstOpen.toBoolean}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />

<c:set var="ade"                    value="${cms.isEditMode}" />

<c:set var="parentId"><mercury:idgen prefix="acco" uuid="${cms.element.instanceId}" /></c:set>
<c:set var="param_parts"        value="${fn:split(cms.container.param, '#')}" />
<c:set var="parent_role"        value="${param_parts[0]}" />
<c:set var="parent_classes"     value="${param_parts[1]}" />


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
<div class="element type-tab variant-accordion ${cssWrapper}"><%----%>
<mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading" />

    <div class="accordion-items" id="${parentId}"><%----%>

        <c:forEach var="tabEntry" items="${content.valueList.TabEntry}" varStatus="status">

            <c:set var="tabLabel"           value="${tabEntry.value.Label}" />
            <c:set var="tabContainerName"   value="${tabEntry.value.Id}" />
            <c:set var="open"               value="${firstOpen and status.first}" />
            <c:set var="itemId"             value="${parentId}_${status.count}" />
            <c:set var="itemHsize"          value="${hsize > 0 ? hsize + 1 : 2}" />

            <mercury:nl />
            <article class="accordion ${cssWrapper}"><%----%>
                ${'<h'}${itemHsize} class="acco-header"${'>'}
                    <a class="acco-toggle ${open ? '':'collapsed'}"<%--
                    --%>data-toggle="collapse" <%--
                    --%>data-target="#${itemId}" <%--
                    --%>href="#${itemId}"><%----%>
                        <c:out value="${tabLabel}"></c:out>
                    </a><%----%>
                ${'</h'}${itemHsize}${'>'}

                <div id="${itemId}" class="acco-body collapse ${open ? 'show' : ''}" data-parent="#${parentId}"><%----%>

                        <mercury:container
                            title="${msg}"
                            name="${tabContainerName}"
                            hideName="${true}"
                            hideParentType="${true}"
                            type="${containerType}"
                        />

                </div><%----%>
            </article><%----%>
            <mercury:nl />

        </c:forEach>

    </div><%----%>

</div><%----%>
<mercury:nl />

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
