<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<m:init-messages reload="true">

<cms:formatter var="content" val="value" locale="en">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="settings" value="${cms.element.settings}" />
<c:set var="wrappedSettings" value="${cms.element.setting}" />

<c:set var="listCompatibilityMarkup">
    <%-- Check if list formatters are compatible. --%>
    <m:list-compatibility
        settings="${settings}"
        types="${content.valueList.TypesToCollect}"
        listType="static"
        listTitle="${value.Title}"
    />
</c:set>

<m:nl />
<m:concat var="wrappers" strings="${[
    settings.listCssWrapper,
    settings.listDisplay,
    settings.cssWrapper,
    settings.cssWrapperListOption,
    (not empty listDisplayType ? 'list-'.concat(listDisplayType) : ''),
    (cms.isEditMode ? 'oc-point-T-25_L15' : '')
]}" />
<div class="element type-static-list list-content${wrappers}"><m:nl />

    <c:if test="${not isCompatible}">
        ${listCompatibilityMarkup}
    </c:if>

    <c:if test="${isCompatible}">

        <m:heading level="${wrappedSettings.listHsize.toInteger}" text="${value.Title}" css="heading pivot" />

        <c:set var="listWrapper" value="${settings.listWrapper}${' '}${settings.requiredListWrapper}" />
        <c:set var="listWrapper" value="${fn:replace(listWrapper, 'row-tile', 'row')}" />
        <c:set var="listTag" value="${wrappedSettings.listTag.isSet ? wrappedSettings.listTag : 'ul' }" />
        <c:set var="instanceId"><m:idgen prefix="li" uuid="${cms.element.instanceId}" /></c:set>

        <div class="list-box ${settings.listBoxWrapper}"><%----%>
        <m:nl />

            <%-- ####### List entries ######## --%>
            ${'<'}${listTag} class="list-entries ${listWrapper}" id="${instanceId}"${'>'}
                <m:list-main
                    instanceId="${instanceId}"
                    config="${content}"
                    count="${wrappedSettings.itemsPerPage.isEmpty ? 5 : wrappedSettings.itemsPerPage.toInteger}"
                    settings="${settings}"
                    locale="${cms.locale}"
                    ajaxCall="${false}"
                    noscriptCall="${false}"
                    addContentInfo="${true}"
                />
            ${'</'}${listTag}${'>'}

            <%-- ####### Displays notice in case of empty list result ######## --%>
            <m:list-messages
                search="${search}"
                types="${content.valueList.TypesToCollect}"
                uploadFolder="${cms.getBinaryUploadFolder(content)}" />

        </div><%----%>
        <m:nl />

    </c:if>
</div><%----%>
<m:nl />

</cms:bundle>
</cms:formatter>

</m:init-messages>
