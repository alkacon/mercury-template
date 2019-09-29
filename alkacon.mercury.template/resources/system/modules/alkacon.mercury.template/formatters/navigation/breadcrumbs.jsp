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

<mercury:init-messages>

<cms:formatter var="content" val="value">

<c:set var="setting"                    value="${cms.element.setting}" />
<c:set var="cssWrapper"                 value="${setting.cssWrapper}" />
<c:set var="cssVisibility"              value="${setting.cssVisibility.toString != 'always' ? setting.cssVisibility.toString : ''}" />
<c:set var="breadcrumbsIncludeHidden"   value="${setting.breadcrumbsIncludeHidden.toBoolean}" />
<c:set var="breadcrumbsFromRoot"        value="${setting.breadcrumbsFromRoot.toBoolean}" />

<%-- Check for List URI and use this if it exists --%>
<c:set var="sitepath"                   value="${param.sitepath}" />
<c:if test="${not empty sitepath}">
    <c:set var="sitepathRes"            value="${not cms.vfs.exists[sitepath] ? null : cms.vfs.resource[sitepath]}" />
    <c:set var="sitepathRes"            value="${not empty sitepathRes ? (sitepathRes.propertySearch['mercury.nav.sitepath'] eq 'true' ? sitepathRes : null) : null}" />
</c:if>

<mercury:nl />
<div class="type-nav-breadcrumbs ${cssWrapper}${' '}${cssVisibility}"><%----%>
<mercury:nl />

        <mercury:nav-items
            type="${breadcrumbsFromRoot ? 'rootBreadCrumb' : 'breadCrumb'}"
            content="${content}"
            currentPageFolder="${empty sitepathRes ? cms.requestContext.folderUri : cms.vfs.getParentFolder(sitepathRes)}"
            currentPageUri="${empty sitepathRes ? cms.requestContext.uri : sitepath}"
            var="nav">

            <ul class="nav-breadcrumbs"><%----%>
                <mercury:nl />
                <c:set var="navItems" value="" />
                <c:set var="currNavPos" value="1" />

                <c:forEach items="${nav.items}" var="navElem" varStatus="status">
                    <c:if test="${(breadcrumbsIncludeHidden and (navElem.navPosition > 0)) or (navElem.info != 'ignoreInDefaultNav')}">
                        <c:set var="navText" value="${(empty navElem.navText or fn:startsWith(navElem.navText, '???'))
                            ? navElem.title : navElem.navText}" />
                        <c:if test="${!empty navText}">
                            <c:set var="navLink"><cms:link>${navElem.resourceName}</cms:link></c:set>

                            <c:out value='<li><a href="${navLink}">' escapeXml="false" />
                            <c:out value='${navText}' escapeXml="true" />
                            <c:out value='</a></li>' escapeXml="false" />

                            <c:set var="navItems"><c:out value="${navItems}" escapeXml="false" />
                                <c:if test="${not empty navItems}">,</c:if>{<%--
                                --%>"@type": "ListItem",<%--
                                --%>"position": <c:out value="${currNavPos}" />,<%--
                                --%>"item": { <%-->
                                    --%>"@id": "<c:out value="${cms.site.url}" escapeXml="false" /><c:out value="${navLink}" escapeXml="false" />",<%--
                                    --%>"name": "<c:out value="${navText}" escapeXml="true" />"<%--
                                --%>}<%--
                            --%>}<%--
                        --%></c:set>
                            <c:set var="currNavPos" value="${currNavPos + 1}" />
                        </c:if>
                    </c:if>
                </c:forEach>

                <c:if test="${cms.detailRequest}">
                    <c:set var="navLink"><cms:link>${cms.sitePath[cms.detailContent.rootPath]}?${pageContext.request.queryString}</cms:link></c:set>
                    <c:set var="navText"><mercury:meta-title addIntro="${true}" /></c:set>

                    <c:out value='<li><a href="${navLink}">' escapeXml="false" />
                    <c:out value='${navText}' escapeXml="true" />
                    <c:out value='</a></li>' escapeXml="false" />

                    <c:set var="navItems"><c:out value="${navItems}" escapeXml="false" />
                        <c:if test="${not empty navItems}">,</c:if>{<%--
                        --%>"@type": "ListItem",<%--
                        --%>"position": <c:out value="${currNavPos}" />,<%--
                        --%>"item": { <%-->
                            --%>"@id": "<c:out value="${cms.site.url}" escapeXml="false" /><c:out value="${navLink}" escapeXml="false" />",<%--
                            --%>"name": "<c:out value="${navText}" escapeXml="true" />"<%--
                        --%>}<%--
                    --%>}<%--
                --%></c:set>
                </c:if>

                <c:if test="${(empty navItems and hidebreadcrumbtitle) or cms.modelGroupPage}">
                    <li><mercury:meta-title addIntro="${true}" /></li><%----%>
                </c:if>
            </ul><%----%>
            <mercury:nl />

            <c:if test="${not empty navItems}">
                <script type="application/ld+json">{<%--
                    --%>"@context": "http://schema.org",<%--
                    --%>"@type": "BreadcrumbList",<%--
                    --%>"itemListElement": [<%--
                        --%><c:out value="${navItems}" escapeXml="false" /><%--
                    --%>]<%--
                --%>}<%--
            --%></script><%----%>
                <mercury:nl />
            </c:if>
        </mercury:nav-items>

</div><%----%>
<mercury:nl />

</cms:formatter>
</mercury:init-messages>