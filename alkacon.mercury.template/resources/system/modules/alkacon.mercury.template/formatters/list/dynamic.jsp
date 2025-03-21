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
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<%-- Add parameters to AJAX request, specially the containerpage id and the element instance id to restore settings --%>
<%-- NOTE: Scriptlet is not allowed inside m:init-messages - thus do the conversion here. --%>
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
<c:set var="elementId" value="${cms.element.instanceId}" />
<c:set var="siteRoot" value="${cms.requestContext.siteRoot}" />
<%
    Map<String, String[]> settingsParameterMap = new HashMap<String, String[]>();
    settingsParameterMap.put("siteroot", new String[]{(String)pageContext.getAttribute("siteRoot")});
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
<%-- The ajax link to use for facet count adjustment. --%>
<c:set var="ajaxFacetCountLink">/system/modules/alkacon.mercury.template/elements/list-facet-ajax.jsp?siteRoot=${cms:encode(siteRoot)}</c:set>

<m:init-messages reload="true">

<cms:formatter var="content" val="value" locale="en">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="listCompatibilityMarkup">
    <%-- Check if list formatters are compatible. --%>
    <m:list-compatibility
        settings="${settings}"
        types="${content.valueList.TypesToCollect}"
        listType="dynamic"
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
    (settings.appendSwitch ne 'disable' ? settings.listPaginationPosition : 'pagination-disabled'),
    (cms.isEditMode ? 'oc-point-T-25_L15' : '')
]}" />
<div class="element type-dynamic-list list-content${wrappers}"><m:nl />

    <c:if test="${not isCompatible}">
        ${listCompatibilityMarkup}
    </c:if>

    <c:if test="${isCompatible}">

        <cms:enable-list-add
            types="${content.valueList.TypesToCollect}"
            postCreateHandler="org.opencms.file.collectors.CmsAddCategoriesPostCreateHandler|${content.value.Category}"
            uploadFolder="${cms.getBinaryUploadFolder(content)}" />

        <m:heading level="${wrappedSettings.listHsize.toInteger}" text="${value.Title}" css="heading pivot" />

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
        <c:set var="ajaxFacetCountLink"><cms:link>${ajaxFacetCountLink}</cms:link></c:set>
        <c:set var="instanceId"><m:idgen prefix="li" uuid="${cms.element.instanceId}" /></c:set>
        <c:set var="elementId"><m:idgen prefix="le" uuid="${cms.element.id}" /></c:set>
        <c:set var="isLoadAll" value="${wrappedSettings.loadAll.toBoolean}" />

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
        <c:if test="${not isLoadAll and not empty param['page']}">
            <c:set var="initPage">${param['page']}</c:set>
            <c:if test="${not empty initPage}">
                <c:catch>
                    <fmt:parseNumber value="${initPage}" integerOnly="true" var="pageNum"/>
                    <c:if test="${pageNum > 0}"><c:set var="initparams" value="${initparams}&page=${pageNum}"/></c:if>
                </c:catch>
            </c:if>
        </c:if>
        <c:if test="${not empty param['facet_calendarday']}">
            <c:set var="initparams" value="${initparams}&facet_calendarday=${param['facet_calendarday']}" />
        </c:if>
        <c:if test="${not empty param['coordinates']}">
            <c:set var="initparams" value="${initparams}&coordinates=${param['coordinates']}" />
        </c:if>
        <c:if test="${not empty param['radius']}">
            <c:set var="initparams" value="${initparams}&radius=${param['radius']}" />
        </c:if>
        <c:if test="${not empty param['geodist']}">
            <c:set var="initparams" value="${initparams}&geodist=${param['geodist']}" />
        </c:if>
        <c:if test="${not empty initparams}">
            <c:set var="initparams">${initparams.replace("'","&#39;")}</c:set>
            <c:set var="initparams" value="reloaded${initparams}" />
        </c:if>

        <cms:jsonobject var="listData">
            <cms:jsonvalue key="ajax" value="${ajaxlink}" />
            <cms:jsonvalue key="ajaxCount" value="${ajaxFacetCountLink}" />
            <cms:jsonvalue key="loadAll" value="${isLoadAll}" />
            <cms:jsonvalue key="teaser" value="${settings.teaserlength}" />
            <cms:jsonvalue key="path" value="${cms.element.sitePath}" />
            <cms:jsonvalue key="sitepath" value="${cms.requestContext.folderUri}" />
            <cms:jsonvalue key="subsite" value="${cms.requestContext.siteRoot}${cms.subSitePath}" />
            <cms:jsonvalue key="appendSwitch" value="${settings.appendSwitch}" />
            <cms:jsonvalue key="appendOption" value="${settings.appendOption}" />
            <cms:jsonvalue key="locale" value="${cms.locale}" />
            <c:if test="${not empty initparams}">
                <cms:jsonvalue key="initparams" value="${initparams}" />
            </c:if>
            <c:if test="${isLoadAll}">
                <cms:jsonvalue key="itemsPerPage" value="${settings.itemsPerPage}" />
                <cms:jsonobject key="paginationInfo">
                    <cms:jsonobject key="messages">
                        <%-- set messages for pagination, only required in loadAll case --%>
                        <c:choose>
                            <c:when test="${not empty settings.listButtonText}">
                                <c:set var="la"><c:out value="${settings.listButtonText}" /></c:set>
                                <c:set var="la">${la.replace("'","&quot;").replace('"',"&qquot;")}</c:set>
                            </c:when>
                            <c:otherwise>
                                <c:set var="la"><fmt:message key="msg.page.list.pagination.more" /></c:set>
                            </c:otherwise>
                        </c:choose>
                        <cms:jsonvalue key="la" value="${la}" />
                        <cms:jsonvalue key="tfp"><fmt:message key="msg.page.list.pagination.first.title"/></cms:jsonvalue>
                        <cms:jsonvalue key="tpp"><fmt:message key="msg.page.list.pagination.previous.title"/></cms:jsonvalue>
                        <cms:jsonvalue key="lp">{{p}}</cms:jsonvalue>
                        <cms:jsonvalue key="tp"><fmt:message key="msg.page.list.pagination.page.title"><fmt:param>{{p}}</fmt:param></fmt:message></cms:jsonvalue>
                        <cms:jsonvalue key="tnp"><fmt:message key="msg.page.list.pagination.next.title"/></cms:jsonvalue>
                        <cms:jsonvalue key="tlp"><fmt:message key="msg.page.list.pagination.last.title"/></cms:jsonvalue>
                    </cms:jsonobject>
            </cms:jsonobject>
            </c:if>
        </cms:jsonobject>

        <%-- ####### The list content will be inserted here with AJAX ####### --%>
        <div class="list-box list-dynamic list-paginate ${settings.listBoxWrapper}" <%--
            --%>id="${instanceId}" <%--
            --%>data-id="${elementId}" <%--
            --%>data-list='${listData}'<%--
        --%>><m:nl />

            <c:if test="${not cms.isOnlineProject}">
                <m:list-search
                    config="${content}"
                    subsite="${cms.requestContext.siteRoot}${cms.subSitePath}"
                    count="0"
                    addContentInfo="${true}"
                    noFacets="${true}"
                />
            </c:if>

            <c:set var="listWrapper" value="${settings.listWrapper}" />
            <c:set var="listWrapper" value="${fn:replace(listWrapper, 'row-tile', 'row')}" />
            ${'<'}${listTag} class="list-entries ${listWrapper}" ${minHeightCss}${'>'}
                <m:list-main
                    elementId="${elementId}"
                    instanceId="${instanceId}"
                    config="${content}"
                    count="${count}"
                    locale="${cms.locale}"
                    settings="${settings}"
                    ajaxCall="${false}"
                    noscriptCall="${false}"
                    pageUri="${cms.requestContext.folderUri}"
                    subsite="${cms.requestContext.siteRoot}${cms.subSitePath}"
                    noFacets="${true}"
                />
            ${'</'}${listTag}${'>'}
            <m:nl />

            <%-- ####### Animated list spinner ######## --%>
            <div class="list-spinner hide-noscript"><%----%>
                <div class="spinnerInnerBox"><%----%>
                    <m:icon icon="spinner" tag="span" cssWrapper="spinner-icon" />
                </div><%----%>
            </div><%----%>
            <m:nl />

            <%-- ####### List pagination ######## --%>
            <c:if test="${settings.appendSwitch != 'disable'}">
                <div class="list-pagination pivot ${settings.listPaginationWrapper}"><%----%>
                    <noscript><%----%>
                        <m:list-pagination
                            search="${search}"
                            singleStep="false"
                            onclickAction=""
                        />
                    </noscript><%----%>
                </div><%----%>
                <m:nl />
            </c:if>

            <%-- ####### Displays notice in case of empty list result ######## --%>
            <m:list-messages
                search="${search}"
                types="${content.valueList.TypesToCollect}"
                uploadFolder="${cms.getBinaryUploadFolder(content)}"
                dynamic="${true}"
                reloaded="${not empty param.reloaded}"
            />
        </div><%----%>
        <m:nl />
    </c:if>

</div><%----%>
<m:nl />

</cms:bundle>
</cms:formatter>

</m:init-messages>
