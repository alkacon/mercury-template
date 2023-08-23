<%@ tag pageEncoding="UTF-8"
    display-name="nav-items"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Loads navigation items based on a XML content configuration." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The navigation XML content configuration."%>

<%@ attribute name="currentPageUri" type="java.lang.String" required="true"
    description="The requested page URI."%>

<%@ attribute name="currentPageFolder" type="java.lang.String" required="true"
    description="The requested page folder URI."%>

<%@ attribute name="type" type="java.lang.String" required="true"
    description="The type of navigation to create. Valid values are 'forSite', 'forFolder' and 'breadCrumb'."%>


<%@ variable name-given="navStartLevel" declare="true"
    description="The start folder level for the navigation." %>

<%@ variable name-given="navDepth" declare="true"
    description="The depth of the navigation." %>

<%@ variable name-given="navStartFolder" declare="true"
    description="The start folder of the navigation." %>

<%@ variable name-given="navItems" declare="true"
    description="The calculated navigation items." %>

<%@ variable name-given="nl" declare="true"
    description="A variable holding a newline / line break to use in JSP for output formatting." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="nl" value="<%= \"\n\" %>" />

<c:set var="navStartLevel" value="${not content.value.Root.value.NavStartLevel.isSet ? 0 : content.value.Root.value.NavStartLevel.toInteger}" />
<c:set var="navDepth" value="${(!content.value.NavDepth.isSet or content.value.NavDepth.toInteger < 0) ? 4 : content.value.NavDepth.toInteger}" />
<c:set var="endLevel" value="${navStartLevel + navDepth - 1}" />

<c:choose>
<c:when test="${not content.value.Root.value.NavCollection.isSet}">
<%-- This is NOT a collection of different navigation start folders --%>

<c:set var="navStartFolder" value="/" />
<c:if test="${content.value.Root.value.NavFolder.isSet}" >
    <c:set var="navStartFolder" value="${content.value.Root.value.NavFolder.toString}" />
    <c:choose>
        <c:when test="${cms.vfs.existsResource[navStartFolder]}">
            <c:set var="pathparts" value="${fn:split(navStartFolder, '/')}" />
            <c:set var="navStartLevel">${fn:length(pathparts)}</c:set>
            <c:set var="endLevel" value="${navStartLevel + navDepth - 1}" />
            <c:if test="${type eq 'forSite'}">
                <c:set var="currentPageFolder">/</c:set>
            </c:if>
        </c:when>
        <c:otherwise>
            <c:set var="navStartFolder" value="INVALID" />
        </c:otherwise>
    </c:choose>
</c:if>

<c:if test="${type eq 'breadCrumb'}">
    <c:set var="navStartLevel" value="${navStartLevel + 1}" />
</c:if>

<c:if test="${type eq 'rootBreadCrumb'}">
    <c:set var="navStartLevel" value="${navStartLevel}" />
    <c:set var="type" value="breadCrumb" />
</c:if>

<c:if test="${navStartFolder ne 'INVALID'}">

    <c:choose>
        <c:when test="${type eq 'forSite'}">
            <c:set var="pathparts" value="${fn:split(currentPageFolder, '/')}" />
            <c:forEach var="folderName" items="${pathparts}" varStatus="status">
                <c:if test="${status.count <= navStartLevel}">0
                    <c:set var="navStartFolder">${navStartFolder}${folderName}/</c:set>
                </c:if>
            </c:forEach>
        </c:when>
        <c:when test="${type eq 'breadCrumb'}">
            <c:set var="endLevel" value="-1" />
            <c:set var="navStartFolder" value="${currentPageFolder}" />
        </c:when>
    </c:choose>

    <c:set var="navBean" value="" />
    <cms:navigation
        type="${type}"
        resource="${navStartFolder}"
        startLevel="${navStartLevel}"
        endLevel="${endLevel}"
        locale="${cms.locale}"
        param="true"
        var="navBean" />
    <c:set var="navItems" value="${navBean.items}" />

</c:if>

</c:when>
<c:when test="${content.value.Root.value.NavCollection.isSet and type eq 'forSite'}">
<%-- This IS a collation of different navigation start folders --%>
<%-- Only the "forSite" type is supported here --%>

    <c:set var="navStartLevel" value="${0}" />
    <jsp:useBean id="navItems"  class="java.util.ArrayList" />
    <jsp:useBean id="addItems" class="java.util.ArrayList" />
    <c:forEach var="navCollectionFolder" items="${content.value.Root.value.NavCollection.valueList.NavCollectionFolder}">

        <c:set var="navTopFolder" value="${navCollectionFolder.toResource}" />
        <c:if test="${not empty navTopFolder}">
            <c:set var="pathparts" value="${fn:split(navTopFolder.sitePath, '/')}" />
            <c:set var="startLevel">${fn:length(pathparts)}</c:set>
            <c:set var="endLevel" value="${startLevel + navDepth - 1}" />

            <%-- Generate site navigation for the folder --%>
            <cms:navigation
                type="forSite"
                resource="${navTopFolder.sitePath}"
                startLevel="${startLevel}"
                endLevel="${endLevel}"
                locale="${cms.locale}"
                param="true"
                var="navBean" />

            <c:set var="addNavTopItem" value="${navTopFolder.navigation}" />
            <c:set var="addNavSubItems" value="${navBean.items}" />
            <c:set var="addLevel" value="${-1}" />

            <c:if test="${(not empty addNavTopItem.info) and cms.exists(addNavTopItem.info)}">
                <%-- An insertion point is set in the navInfo property of the navTopFolder, check if it exits in the collected result list --%>
                <c:set var="checkInsertRes" value="${cms.readResource(addNavTopItem.info)}" />
                <c:forEach var="checkNavItem" items="${navItems}" varStatus="status">
                    <c:if test="${checkNavItem.resource.rootPath eq checkInsertRes.rootPath}">
                        <%-- Insertion point exists, insert items of the folder after the insertion point --%>
                        <c:set var="addLevel" value="${checkNavItem.navTreeLevel}" />
                        <c:set var="addPosition" value="${status.count}" />
                    </c:if>
                </c:forEach>
            </c:if>

            <c:if test="${addLevel == -1}">
                <%-- No insertion point set or found, insert items at the end of the navigation --%>
                <c:set var="addLevel" value="${navStartLevel}" />
                <c:set var="addPosition" value="${navItems.size()}" />
            </c:if>

            <%-- Collect additional nav items in a temporary list --%>
            <c:set var="ignore" value="${addItems.clear()}" />
            <%-- Add the top level item itself --%>
            <c:set var="ignore" value="${addNavTopItem.setNavTreeLevel(addLevel)}" />
            <c:set var="ignore" value="${addItems.add(addNavTopItem)}" />
            <c:if test="${not empty addNavSubItems}">
                <%-- Add all sub items of the top level item --%>
                <c:set var="navTreeLevelOffset" value="${addNavSubItems[0].navTreeLevel - (addLevel + 1)}" />
                <c:forEach var="addNavItem" items="${addNavSubItems}">
                    <c:set var="ignore" value="${addNavItem.setNavTreeLevel(addNavItem.navTreeLevel - navTreeLevelOffset)}" />
                    <c:set var="ignore" value="${addItems.add(addNavItem)}" />
                </c:forEach>
            </c:if>
            <%-- Add collected additional nav items to the final result list --%>
            <c:set var="ignore" value="${navItems.addAll(addPosition, addItems)}" />
        </c:if>
    </c:forEach>

</c:when>
</c:choose>

<c:choose>

    <c:when test="${(navStartFolder ne 'INVALID') and not empty navItems}">
        <%-- Only output the tag body in case we have found some navigation items --%>
        <jsp:doBody />
    </c:when>

    <c:otherwise>
        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <%-- Output HTML debug comment --%>
            <!-- <fmt:message key="msg.page.navigation.empty" /> -->
            <c:if test="${not (type eq 'breadCrumb') and cms.isEditMode}">
                <!--
                type="${type}"
                currentPageFolder="${currentPageFolder}"
                currentPageUri="${currentPageUri}"
                navStartFolder="${navStartFolder}"
                navStartLevel="${navStartLevel}"
                endLevel="${endLevel}"
                navDepth="${navDepth}"
                locale="${cms.locale}"
                -->
                <mercury:alert-meta icon="warning">
                    <jsp:attribute name="text">
                        <fmt:message key="msg.page.navigation.empty" />
                    </jsp:attribute>
                </mercury:alert-meta>
            </c:if>
        </cms:bundle>
    </c:otherwise>

</c:choose>

