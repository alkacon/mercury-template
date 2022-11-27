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
<c:set var="multipleOpen"           value="${setting.multipleOpen.toBoolean}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />

<c:set var="ade"                    value="${cms.isEditMode}" />

<c:set var="parentId"><mercury:idgen prefix="a" uuid="${cms.element.instanceId}" /></c:set>
<c:set var="param_parts"        value="${fn:split(cms.container.param, '#')}" />
<c:set var="parent_role"        value="${param_parts[0]}" />
<c:set var="parent_classes"     value="${param_parts[1]}" />



<c:choose>
    <c:when test="${containerType eq 'row'}">
        <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.row"/></c:set>
    </c:when>
    <c:otherwise>
        <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.element"/></c:set>
    </c:otherwise>
</c:choose>

<mercury:nl />
<div class="element type-tab variant-accordion${setCssWrapperAll}"><%----%>
<mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading pivot" />

    <div class="accordion-items" id="${parentId}"><%----%>

        <c:forEach var="tabEntry" items="${content.valueList.TabEntry}" varStatus="status">

            <c:set var="tabLabel"           value="${tabEntry.value.Label}" />
            <c:set var="tabContainerName"   value="${tabEntry.value.Id}" />
            <c:set var="open"               value="${firstOpen and status.first}" />
            <c:set var="itemId"             value="${parentId}_${fn:replace(tabEntry.value.Id, 'tab-', '')}" />
            <c:set var="itemHsize"          value="${hsize > 0 ? hsize + 1 : 2}" />

            <mercury:nl />
            <article class="accordion ${cssWrapper}"><%----%>
                ${'<h'}${itemHsize} class="acco-header pivot"${'>'}

                    <button class="acco-toggle ${open ? '':'collapsed'}" <%--
                    --%>data-bs-toggle="collapse" type="button" <%--
                    --%>aria-expanded="${open}" <%--
                    --%>aria-controls="${itemId}"<%--
                    --%>data-bs-target="#${itemId}"><%----%>
                        <c:out value="${tabLabel}"></c:out>
                    </button><%----%>

                    <c:if test="${cms.isEditMode}">
                        <a href="#${itemId}" class="hash-link"><%----%>
                            <span class="badge oct-meta-info"><%----%>
                                <mercury:icon icon="hashtag" tag="span" inline="${false}" />
                            </span><%----%>
                        </a><%----%>
                    </c:if>

                ${'</h'}${itemHsize}${'>'}


                <div id="${itemId}" class="acco-body collapse ${open ? 'show' : ''}"${multipleOpen ? '' : ' data-bs-parent=\"#'.concat(parentId).concat('\"')}><%----%>

                        <mercury:container
                            title="${msg}"
                            name="${tabEntry.value.Id}"
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

</mercury:setting-defaults>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
