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
<c:set var="showSingleTab"          value="${setting.showSingleTab.useDefault('true').toBoolean}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />

<c:set var="ade"                    value="${cms.isEditMode}" />
<c:set var="showTabs"               value="${showSingleTab or (content.valueList.TabEntry.size() ne 1)}" />

<c:set var="itemId"><mercury:idgen prefix="t" uuid="${cms.element.instanceId}" /></c:set>

<c:choose>
    <c:when test="${containerType eq 'row'}">
        <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.row"/></c:set>
    </c:when>
    <c:otherwise>
        <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.element"/></c:set>
    </c:otherwise>
</c:choose>

<mercury:nl />
<div class="element type-tab${showTabs ? ' variant-tabs' : ' variant-hidden-tabs'}${setCssWrapperAll}"><%----%>
<mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading pivot" />

    <c:choose>
        <c:when test="${showTabs}">

            <div class="tabs-parent" id="${itemId}"><%----%>

                <mercury:nl />
                <ul class="tab-list nav pivot" role="tablist"><%----%>
                    <c:set var="tabIds" value="${[]}" />
                    <c:forEach var="tabEntry" items="${content.valueList.TabEntry}" varStatus="status">
                        <c:set var="tabLabel" value="${tabEntry.value.Label}" />
                        <c:set var="tabId" value="${itemId}_${fn:replace(tabEntry.value.Id, 'tab-', '')}" />
                        <c:set var="ignore" value="${tabIds.add(tabId)}" />
                        <mercury:nl />
                        <li role="presentation"><%----%>

                            <button <%--
                            --%>id="b_${tabId}" <%--
                            --%>class="tab-toggle${status.first ? ' active' : ''}" <%--
                            --%>type="button" <%--
                            --%>role="tab" <%--
                            --%>aria-controls="${tabId}" <%--
                            --%>data-bs-target="#${tabId}" <%--
                            --%>data-bs-toggle="tab"><%----%>
                                <mercury:out value="${tabLabel}" lenientEscaping="${true}" />
                            </button><%----%>

                            <c:if test="${cms.isEditMode}">
                                <a href="#${tabId}" class="hash-link"><%----%>
                                    <span class="badge oct-meta-info"><%----%>
                                        <mercury:icon icon="hashtag" tag="span" />
                                    </span><%----%>
                                </a><%----%>
                            </c:if>

                        </li><%----%>
                    </c:forEach>

                <mercury:nl />
                </ul><%----%>
                <mercury:nl />

                <div class="tab-content"><%----%>
                <mercury:nl />

                    <c:forEach var="tabEntry" items="${content.valueList.TabEntry}" varStatus="status">

                        <mercury:nl />
                        <div <%--
                        --%>id="${tabIds[status.index]}" <%--
                        --%>aria-labelledby="b_${tabIds[status.index]}" <%--
                        --%>class="tab-pane fade ${status.first? 'show active':''}" ><%----%>
                            <mercury:nl />
                            <mercury:container
                                title="${msg}"
                                name="${tabEntry.value.Id}"
                                hideName="${true}"
                                hideParentType="${true}"
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
                hideParentType="${true}"
                type="${containerType}"
            />
            <mercury:nl />

        </c:otherwise>
    </c:choose>



</div><%----%>
<mercury:nl />

</mercury:setting-defaults>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
