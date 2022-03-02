<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />

<mercury:set-siteroot siteRoot="${param.siteroot}" sitePath="${param.sitepath}" />

<fmt:setLocale value="${param.loc}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<!DOCTYPE html>
<html>
<body>

<c:set var="conf" value="${cms.vfs.readXml[param.contentpath]}" />

<c:if test="${not empty conf}">

    <%-- make sure the 'en' locale is used to read the values of the list configuration --%>
    <c:set var="ignore" value="${conf.init(conf.cmsObject, cms.wrap['en'].toLocale, conf.rawContent, conf.file)}" />

    <%-- restore settings reading them from the containerpage --%>
    <jsp:useBean id="settings" class="java.util.HashMap" />
    <c:if test="${not empty param.pid}">
        <c:set var="pageBean" value="${cms.getPage(param.pid, param.loc)}" />
        <c:set var="sortBarInstanceId">${param.sid}</c:set>
        <c:set var="instanceId">${param.eid}</c:set>
        <c:forEach var="element" items="${pageBean.elements}">
            <c:if test="${element.instanceId eq instanceId or element.instanceId eq sortBarInstanceId}">
                ${settings.putAll(element.settings)}
            </c:if>
        </c:forEach>
    </c:if>

    <div class="element type-dynamic-list list-content ${settings.listCssWrapper}">
    <c:set var="listTag" value="${empty settings.listTag ? 'ul' : settings.listTag}" />
    <c:set var="count">${settings.itemsPerPage}</c:set>
    <c:set var="loadAll" value="${settings.loadAll eq 'true'}" />
    <c:set var="multiDay" value="${settings.multiDay eq 'true'}" />

    ${'<'}${listTag} class="list-entries ${settings.listWrapper}${'\">'}
        <%-- ####### List entries ######## --%>
        <mercury:list-main
            elementId="${param.elementId}"
            instanceId="${param.instanceId}"
            config="${conf}"
            count="${loadAll ? 400 : (not empty count ? count : 5)}"
            locale="${param.loc}"
            settings="${settings}"
            ajaxCall="true"
            noscriptCall="false"
            pageUri="${param.sitepath}"
            subsite="${param.subsite}"
            multiDayRangeFacet="${multiDay}"
        />
    ${'</'}${listTag}${'>'}

    <%-- ####### Load pagination ######## --%>
    <c:if test="${not loadAll}">
        <c:choose>
            <c:when test="${param.option eq 'append'}">
                <c:set var="label">
                    <c:choose>
                        <c:when test="${not empty settings.listButtonText}">
                            <c:out value="${settings.listButtonText}" />
                        </c:when>
                        <c:otherwise>
                            <fmt:message key="msg.page.list.pagination.more" />
                        </c:otherwise>
                    </c:choose>
                </c:set>
                <mercury:list-loadbutton
                    search="${search}"
                    label="${label}"
                    onclickAction='DynamicList.update("${param.instanceId}", "$(LINK)", "false")'
                />
            </c:when>
            <c:otherwise>
                <mercury:list-pagination
                    search="${search}"
                    singleStep="true"
                    onclickAction='DynamicList.update("${param.instanceId}", "$(LINK)", "true")'
                />
            </c:otherwise>
        </c:choose>
    </c:if>

    <%-- ####### Provide information about search result for JavaScript ######## --%>
    <div id="resultdata" data-result='{<%--
    --%>"reloaded":"${param.reloaded ne null}", <%--
    --%>"currentPage":"${search.controller.pagination.state.currentPage}", <%--
    --%>"pages":"${search.numPages}", <%--
    --%>"found":"${search.numFound}", <%--
    --%>"start":"${search.start}", <%--
    --%>"end":"${search.end}"<%--
--%>}'></div>

    </div>
</c:if>

</body>
</html>

</cms:bundle>
