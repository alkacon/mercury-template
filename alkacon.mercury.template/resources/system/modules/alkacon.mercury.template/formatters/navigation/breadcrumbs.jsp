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

<mercury:nl />
<div class="type-nav-breadcrumbs ${cssWrapper}${' '}${cssVisibility}"><%----%>
<mercury:nl />

    <mercury:nav-vars params="${param}">
        <mercury:nav-items
            type="${breadcrumbsFromRoot ? 'rootBreadCrumb' : 'breadCrumb'}"
            content="${content}"
            currentPageFolder="${currentPageFolder}"
            currentPageUri="${currentPageUri}" >

            <ul class="nav-breadcrumbs"><%----%>
                <mercury:nl />
                <c:set var="breadCrumbs" value="" />
                <c:set var="currNavPos" value="1" />

                <c:forEach var="navElem" items="${navItems}" varStatus="status">
                    <c:if test="${(breadcrumbsIncludeHidden and (navElem.navPosition > 0)) or (navElem.info != 'ignoreInDefaultNav')}">
                        <c:set var="navText" value="${(empty navElem.navText or fn:startsWith(navElem.navText, '???'))
                            ? navElem.title : navElem.navText}" />
                        <c:if test="${!empty navText}">
                            <c:set var="navLink"><cms:link>${navElem.resourceName}</cms:link></c:set>

                            <c:out value='<li><a href="${navLink}">' escapeXml="false" />
                            <c:out value='${navText}' escapeXml="true" />
                            <c:out value='</a></li>' escapeXml="false" />

                            <c:set var="breadCrumbs"><c:out value="${breadCrumbs}" escapeXml="false" />
                                <c:if test="${not empty breadCrumbs}">,</c:if>{<%--
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
                    <c:set var="navLink"><cms:link>${cms.detailContent.sitePath}?${pageContext.request.queryString}</cms:link></c:set>
                    <c:set var="navText"><mercury:meta-title addIntro="${true}" /></c:set>

                    <c:out value='<li><a href="${navLink}">' escapeXml="false" />
                    <c:out value='${navText}' escapeXml="true" />
                    <c:out value='</a></li>' escapeXml="false" />

                    <c:set var="breadCrumbs"><c:out value="${breadCrumbs}" escapeXml="false" />
                        <c:if test="${not empty breadCrumbs}">,</c:if>{<%--
                        --%>"@type": "ListItem",<%--
                        --%>"position": <c:out value="${currNavPos}" />,<%--
                        --%>"item": { <%-->
                            --%>"@id": "<c:out value="${cms.site.url}" escapeXml="false" /><c:out value="${navLink}" escapeXml="false" />",<%--
                            --%>"name": "<c:out value="${navText}" escapeXml="true" />"<%--
                        --%>}<%--
                    --%>}<%--
                --%></c:set>
                </c:if>

                <c:if test="${(empty breadCrumbs and hidebreadcrumbtitle) or cms.modelGroupPage}">
                    <li><mercury:meta-title addIntro="${true}" /></li><%----%>
                </c:if>
            </ul><%----%>
            <mercury:nl />

            <c:if test="${not empty breadCrumbs}">
                <script type="application/ld+json">{<%--
                    --%>"@context": "http://schema.org",<%--
                    --%>"@type": "BreadcrumbList",<%--
                    --%>"itemListElement": [<%--
                        --%><c:out value="${breadCrumbs}" escapeXml="false" /><%--
                    --%>]<%--
                --%>}<%--
            --%></script><%----%>
                <mercury:nl />
            </c:if>
        </mercury:nav-items>
    </mercury:nav-vars>

</div><%----%>
<mercury:nl />

</cms:formatter>
</mercury:init-messages>