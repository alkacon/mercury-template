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

<c:set var="ade"                    value="${true}" />

<c:set var="itemId"><mercury:idgen prefix="acco" uuid="${cms.element.instanceId}" /></c:set>
<c:set var="param_parts"        value="${fn:split(cms.container.param, '#')}" />
<c:set var="parent_role"        value="${param_parts[0]}" />
<c:set var="parent_classes"     value="${param_parts[1]}" />

<mercury:nl />
<div class="element type-tab variant-tabs ${cssWrapper}"><%----%>
<mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading" />

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

                    <fmt:setLocale value="${cms.workplaceLocale}" />
                    <cms:bundle basename="alkacon.mercury.template.messages">
                        <cms:container
                            name="${tabContainerName}"
                            type="row"
                            param="role.EDITOR#${parent_classes}"
                            maxElements="50">
                                <c:set var="msg"><fmt:message key="msg.page.tab.emptycontainer.text"/></c:set>
                                <mercury:container-box
                                    label="${msg}"
                                    boxType="container-box"
                                    role="role.EDITOR"
                                    type="row"
                                />
                        </cms:container>
                    </cms:bundle>

                    <mercury:nl />
                </div><%----%>
                <mercury:nl />

            </c:forEach>

        </div><%----%>
        <mercury:nl />

    </div><%----%>

</div><%----%>
<mercury:nl />

</cms:formatter>

</mercury:init-messages>
