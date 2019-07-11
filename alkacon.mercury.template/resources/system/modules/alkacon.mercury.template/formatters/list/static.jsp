<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<mercury:init-messages reload="true">

<cms:formatter var="content" val="value" locale="en">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="settings" value="${cms.element.settings}" />
<c:set var="wrappedSettings" value="${cms.element.setting}" />

<div class="element type-static-list list-content ${settings.cssWrapper}${' '}${settings.listCssWrapper}${' '}${cms.isEditMode ? 'oc-point-T-25_L15' : ''}">
<%----%>
    <%-- ####### Check if list formatters are compatible ######## --%>
    <mercury:list-compatibility
        settings="${settings}"
        types="${content.valueList.TypesToCollect}"
        listTitle="${value.Title}"
        isStaticList="true"
    />

    <c:if test="${isCompatible}">

        <mercury:heading level="${wrappedSettings.listHsize.toInteger}" text="${value.Title}" css="heading" />

        <c:set var="listWrapper" value="${settings.listWrapper}${' '}${settings.requiredListWrapper}" />
        <c:set var="listTag" value="${wrappedSettings.listTag.isSet ? wrappedSettings.listTag : 'ul' }" />
        <c:set var="instanceId"><mercury:idgen prefix="li" uuid="${cms.element.instanceId}" /></c:set>

        <div class="list-box ${settings.listBoxWrapper}"><%----%>

            <%-- ####### List entries ######## --%>
            ${'<'}${listTag} class="list-entries ${listWrapper}" id="${instanceId}"${'>'}
                <mercury:list-main
                    instanceId="${instanceId}"
                    config="${content}"
                    count="${wrappedSettings.itemsPerPage.isEmpty ? 5 : wrappedSettings.itemsPerPage.toInteger}"
                    settings="${settings}"
                    locale="${cms.locale}"
                    ajaxCall="false"
                    noscriptCall="false"
                />
            ${'</'}${listTag}${'>'}

            <%-- ####### Boxes to create new entries in case of empty result ######## --%>
            <c:if test="${cms.isEditMode and search.numFound == 0}">
                <c:forEach var="type" items="${content.valueList.TypesToCollect}">
                    <c:set var="createType">${fn:substringBefore(type.stringValue, ':')}</c:set>
                    <mercury:list-messages type="${createType}" defaultCats="${content.value.Category}" />
                </c:forEach>
            </c:if>

        </div><%----%>

    </c:if>
</div>
<%----%>
</cms:bundle>
</cms:formatter>

</mercury:init-messages>
