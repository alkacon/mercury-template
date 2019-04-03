<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="org.opencms.xml.containerpage.CmsContainerElementBean"%>
<%@page import="org.opencms.xml.containerpage.CmsXmlContainerPage"%>
<%@page import="org.opencms.file.CmsResource"%>
<%@page import="org.opencms.file.CmsObject"%>
<%@page import="org.opencms.xml.containerpage.CmsXmlContainerPageFactory"%>
<%@page import="org.opencms.util.CmsUUID"%>
<%@page import="org.opencms.xml.containerpage.CmsContainerPageBean"%>
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

<fmt:setLocale value="${param.loc}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<!DOCTYPE html>
<html>
<body>

<c:set var="conf" value="${cms.vfs.readXml[param.contentpath]}" />
<c:if test="${not empty conf}">

    <%-- restore settings reading them from the containerpage --%>
    <c:set var="cmsObject" value="${cms.vfs.cmsObject}" />

    <%
        CmsObject cmsObject = (CmsObject)pageContext.getAttribute("cmsObject");
        Map<String, String[]> parameters = request.getParameterMap();
        Map<String, String> settings = new HashMap<String, String>();
        String instanceId = parameters.get("eid")[0];
        String sortBarInstanceId = null != parameters.get("sid") && null != parameters.get("sid")[0] ? parameters.get("sid")[0] : "";
        CmsResource pageResource = cmsObject.readResource(CmsUUID.valueOf(parameters.get("pid")[0]));
        CmsXmlContainerPage pageXml = CmsXmlContainerPageFactory.unmarshal(cmsObject, pageResource);
        CmsContainerPageBean pageBean = pageXml.getContainerPage(cmsObject);
        for (CmsContainerElementBean element : pageBean.getElements()) {
            if(element.getInstanceId().equals(instanceId) || element.getInstanceId().equals(sortBarInstanceId)) {
               settings.putAll(element.getSettings());
            }
        }
        pageContext.setAttribute("settings", settings);
    %>

    <div class="element type-dynamic-list list-content ${settings.listCssWrapper}">
    <c:set var="listTag" value="${empty settings.listTag ? 'ul' : settings.listTag}" />
    <c:set var="count">${settings.itemsPerPage}</c:set>

    ${'<'}${listTag} class="list-entries ${settings.listWrapper}${'\">'}
    <%-- ####### List entries ######## --%>
    <mercury:list-main
        elementId="${param.elementId}"
        instanceId="${param.instanceId}"
        config="${conf}"
        count="${not empty count ? count : 5}"
        locale="${param.loc}"
        settings="${settings}"
        ajaxCall="true"
        noscriptCall="false"

        pageUri="${param.sitepath}"
        subsite="${param.subsite}"
    />
    ${'</'}${listTag}${'>'}

    <%-- ####### Load pagination ######## --%>
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
