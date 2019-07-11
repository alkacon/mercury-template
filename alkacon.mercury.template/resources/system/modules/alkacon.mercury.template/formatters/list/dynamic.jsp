<%@page import="org.opencms.file.CmsObject"%>
<%@page import="org.opencms.file.CmsResource"%>
<%@page import="org.opencms.ade.containerpage.CmsDetailOnlyContainerUtil"%>
<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.Map, java.util.HashMap, org.opencms.util.CmsRequestUtil" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<%-- Add parameters to AJAX request, specially the containerpage id and the element instance id to restore settings --%>
<%-- NOTE: Scriptlet is not allowed inside mercury:init-messages - thus do the conversion here. --%>
<c:set var="settings" value="${cms.element.settings}" />
<c:set var="wrappedSettings" value="${cms.element.setting}" />
<%-- Get the id of the container page the list is on. --%>
<c:choose>
<c:when test="${cms.element.inMemoryOnly or cms.edited}">
    <c:set var="pageId" value="${null}" />
</c:when>
<c:when test="${cms.container.detailOnly}">
    <%-- Get the detail only page when the list is in a detail only container. --%>
    <c:set var="detailResource" value="${cms.detailContent}" />
    <c:set var="cmsObject" value="${cms.vfs.cmsObject}" />
    <c:set var="locale">${cms.locale}</c:set>
    <c:set var="pageId"><%=CmsDetailOnlyContainerUtil.getDetailOnlyPage((CmsObject)pageContext.getAttribute("cmsObject"), (CmsResource)pageContext.getAttribute("detailResource"), (String)pageContext.getAttribute("locale")).get().getStructureId()%></c:set>
</c:when>
<c:otherwise><c:set var="pageId">${cms.pageResource.structureId}</c:set></c:otherwise>
</c:choose>
<c:set var="elementId">${cms.element.instanceId}</c:set>
<%
    Map<String, String[]> settingsParameterMap = new HashMap<String, String[]>();
    String[] gridParameterMap = pageContext.getRequest().getParameterValues("cssgrid");
    if (gridParameterMap != null) {
        settingsParameterMap.put("cssgrid", gridParameterMap);
    }
    String pid = (String)pageContext.getAttribute("pageId");
    if (null != pid) {
        settingsParameterMap.put("pid", new String[]{(String)pageContext.getAttribute("pageId")});
        settingsParameterMap.put("eid", new String[]{(String)pageContext.getAttribute("elementId")});
    }
%>
<%-- The ajax link to use with the parameters containing the settings. --%>
<c:set var="ajaxlink"><%= CmsRequestUtil.appendParameters("/system/modules/alkacon.mercury.template/elements/list-ajax.jsp", settingsParameterMap, true) %></c:set>

<mercury:init-messages reload="true">

<cms:formatter var="content" val="value" locale="en">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<mercury:nl />
<div class="element type-dynamic-list list-content ${settings.cssWrapper}${' '}${settings.listCssWrapper}${' '}${settings.listPaginationPosition}${' '}${cms.isEditMode ? 'oc-point-T-25_L15' : ''}"><%----%>
<mercury:nl />

    <%-- ####### Check if list formatters are compatible ######## --%>
    <mercury:list-compatibility
        settings="${settings}"
        types="${content.valueList.TypesToCollect}"
        listTitle="${value.Title}"
    />

    <c:if test="${isCompatible}">

        <mercury:heading level="${wrappedSettings.listHsize.toInteger}" text="${value.Title}" css="heading" />

        <c:set var="count" value="${wrappedSettings.itemsPerPage.isSet ? wrappedSettings.itemsPerPage : 5}" />
        <c:set var="listTag" value="${wrappedSettings.listTag.isSet ? wrappedSettings.listTag : 'ul' }" />
        <c:if test="${wrappedSettings.listEntryMinHeight.isSet}" >
            <c:set var="minHeightSet" value="${wrappedSettings.listEntryMinHeight}" />
            <c:choose>
                <c:when test="${fn:indexOf(minHeightSet.toString, '-total') > 0}">
                    <c:set var="minHeight" value="${fn:substringBefore(minHeightSet.toString, '-total')}" />
                </c:when>
                <c:otherwise>
                    <c:set var="countFirstPage" value="${wrappedSettings.itemsPerPage.isSet ? wrappedSettings.itemsPerPage.toInteger(5) : 5}" />
                    <c:set var="minHeight" value="${minHeightSet.toInteger(125) * countFirstPage}" />
                </c:otherwise>
            </c:choose>
            <c:set var="minHeightCss">style="min-height: ${minHeight}px;" data-mh="${minHeight}"</c:set>
        </c:if>

        <c:set var="ajaxlink"><cms:link>${ajaxlink}</cms:link></c:set>
        <c:set var="instanceId"><mercury:idgen prefix="li" uuid="${cms.element.instanceId}" /></c:set>
        <c:set var="elementId"><mercury:idgen prefix="le" uuid="${cms.element.id}" /></c:set>

        <c:set var="initparams" value="" />
        <c:if test="${not empty param.facet_category_exact}">
            <c:set var="initparams" value="&facet_category_exact=${param.facet_category_exact}" />
           </c:if>
        <c:if test="${not empty param.q}">
            <c:set var="initparams" value="${initparams}&q=${param.q}" />
           </c:if>
        <c:if test="${not empty param.facet_instancedate}">
            <c:set var="initparams" value="${initparams}&facet_instancedate=${param.facet_instancedate}" />
           </c:if>
        <c:if test="${not empty param['facet_parent-folders']}">
            <c:set var="initparams" value="${initparams}&facet_parent-folders=${param['facet_parent-folders']}" />
           </c:if>
        <c:if test="${not empty initparams}">
            <c:set var="initparams" value="reloaded${initparams}" />
        </c:if>

        <%-- ####### The list content will be inserted here with AJAX ####### --%>
        <div class="list-box list-dynamic list-paginate ${settings.listBoxWrapper}" <%--
        --%>id="${instanceId}" <%--
        --%>data-id="${elementId}" <%--
        --%>data-list='{<%--
            --%>"ajax":"${ajaxlink}", <%--
            --%>"teaser":"${settings.teaserlength}", <%--
            --%>"path":"${cms.element.sitePath}", <%--
            --%>"sitepath":"${cms.requestContext.folderUri}", <%--
            --%>"subsite":"${cms.requestContext.siteRoot}${cms.subSitePath}", <%--
            --%>"appendSwitch":"${settings.appendSwitch}", <%--
            --%>"appendOption":"${settings.appendOption}", <%--
            --%>"locale":"${cms.locale}"<%--
            --%><c:if test="${not empty initparams}">, "initparams":"${initparams}"</c:if><%--
        --%>}'><%----%>
            <mercury:nl />

            ${'<'}${listTag} class="list-entries ${settings.listWrapper}" ${minHeightCss}${'>'}
                <%-- ###### Add noscript for initial page load ###### --%>
                <noscript><%----%>
                    <div class="list-entries"><%-- Required by tiling lists, otherwise <noscript> breaks layout --%>
                    <mercury:list-main
                        elementId="${elementId}"
                        instanceId="${instanceId}"

                        config="${content}"
                        count="${count}"
                        locale="${cms.locale}"
                        settings="${settings}"
                        ajaxCall="false"
                        noscriptCall="true"
                        pageUri="${cms.requestContext.folderUri}"
                        subsite="${cms.requestContext.siteRoot}${cms.subSitePath}"
                    />
                    </div><%----%>
                </noscript><%----%>
            ${'</'}${listTag}${'>'}
            <mercury:nl />

            <%-- ####### Animated list spinner ######## --%>
            <div class="list-spinner hide-noscript"><%----%>
                <div class="spinnerInnerBox"><span class="fa fa-spinner"></span></div><%----%>
            </div><%----%>
            <mercury:nl />

            <%-- ####### List pagination ######## --%>
            <c:if test="${settings.appendSwitch != 'disable'}">
                <div class="list-pagination ${settings.listPaginationWrapper}"><%----%>
                    <noscript><%----%>
                        <mercury:list-pagination
                            search="${search}"
                            singleStep="false"
                            onclickAction=""
                        />
                    </noscript><%----%>
                </div><%----%>
                <mercury:nl />
            </c:if>

            <%-- ####### Boxes to create new entries in case of empty result ######## --%>
            <c:if test="${cms.isEditMode}">
                <c:forEach var="type" items="${content.valueList.TypesToCollect}">
                    <c:set var="createType">${fn:substringBefore(type.stringValue, ':')}</c:set>
                    <div class="list-editbox" style="display: none;" ><%----%>
                        <mercury:list-messages type="${createType}" defaultCats="${content.value.Category}" />
                    </div><%----%>
                    <mercury:nl />
                </c:forEach>
            </c:if>

        </div><%----%>
        <mercury:nl />
    </c:if>
</div><%----%>
<mercury:nl />

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
