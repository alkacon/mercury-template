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

<mercury:setting-defaults>

<c:set var="breadcrumbsIncludeHidden"   value="${setting.breadcrumbsIncludeHidden.toBoolean}" />
<c:set var="breadcrumbsFullPath"        value="${setting.breadcrumbsFullPath.toBoolean}" />
<c:set var="breadcrumbsFromRoot"        value="${setting.breadcrumbsFromRoot.toBoolean}" />

<mercury:nl />
<div class="element type-nav-breadcrumbs${setCssWrapperAll}"><%----%>
<mercury:nl />

    <mercury:nav-vars params="${param}">
        <mercury:nav-items
            type="${breadcrumbsFromRoot ? 'rootBreadCrumb' : 'breadCrumb'}"
            content="${content}"
            currentPageFolder="${currentPageFolder}"
            currentPageUri="${currentPageUri}" >

            <ul class="nav-breadcrumbs"><%----%>
                <mercury:nl />
                <c:set var="currNavPos" value="1" />

                <cms:jsonarray var="breadCrumbJson">

                    <c:forEach var="navElem" items="${navItems}" varStatus="status">
                        <c:if test="${
                            ((breadcrumbsIncludeHidden or (status.last and not cms.detailRequest)) and (navElem.navPosition > 0))
                            or (navElem.info ne 'ignoreInDefaultNav')}">
                            <c:set var="navImage" value="${navElem.navImage}" />
                            <c:set var="navText" value="${(empty navElem.navText or fn:startsWith(navElem.navText, '???'))
                                ? (empty navImage ? navElem.title : null) : navElem.navText}" />
                            <c:if test="${(not empty navText) or (not empty navImage)}">
                                <c:set var="navLink"><cms:link>${navElem.resourceName}</cms:link></c:set>
                                <c:if test="${breadcrumbsFullPath or (navLink ne lastNavLink)}">
                                    <c:set var="lastNavLink" value="${navLink}" />
                                    <c:out value='<li><a href=\"${navLink}\">' escapeXml="false" />
                                    <c:if test="${not empty navImage}">
                                        <c:set var="navTitle" value="${empty navText ? navElem.title : null}" />
                                        <c:set var="navImageMarkup">
                                            <c:choose>
                                                <c:when test="${fn:startsWith(navImage, '/')}">
                                                    <img src="<cms:link>${navImage}</cms:link>" height="12" width="12"<%--
                                                    --%><c:if test="${not empty navTitle}">
                                                            <c:out value=" title=\"${navTitle}\"" escapeXml="false" />
                                                        </c:if><%--
                                                    --%>/><%----%>
                                                </c:when>
                                                <c:otherwise>
                                                    <mercury:icon icon="${navImage}" tag="i" inline="${false}" />
                                                </c:otherwise>
                                            </c:choose>
                                        </c:set>
                                    </c:if>
                                    <c:choose>
                                        <c:when test="${empty navImage}">
                                            <c:out value='${navText}' escapeXml="true" />
                                        </c:when>
                                        <c:when test="${empty navText}">
                                            ${navImageMarkup}
                                        </c:when>
                                        <c:otherwise>
                                            ${navImageMarkup}
                                            <span><c:out value='${navText}' escapeXml="true" /></span>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:out value='</a></li>' escapeXml="false" />
                                    <mercury:nl />

                                    <cms:jsonobject>
                                        <cms:jsonvalue key="@type" value="ListItem" />
                                        <cms:jsonvalue key="position" value="${currNavPos}" />
                                        <cms:jsonvalue key="name" value="${empty navText ? navElem.title : navText}" />
                                        <cms:jsonvalue key="item" value="${cms.site.url}${navLink}" />
                                    </cms:jsonobject>

                                    <c:set var="currNavPos" value="${currNavPos + 1}" />
                                </c:if>
                            </c:if>
                        </c:if>
                    </c:forEach>

                    <c:if test="${cms.detailRequest}">
                        <c:set var="navLink"><cms:link>${cms.detailContent.sitePath}?${pageContext.request.queryString}</cms:link></c:set>
                        <c:set var="navText"><mercury:meta-title addIntro="${false}" /></c:set>

                        <c:out value='<li><a href="${navLink}">' escapeXml="false" />
                        <c:out value='${navText}' escapeXml="true" />
                        <c:out value='</a></li>' escapeXml="false" />

                        <cms:jsonobject>
                            <cms:jsonvalue key="@type" value="ListItem" />
                            <cms:jsonvalue key="position" value="${currNavPos}" />
                            <cms:jsonobject key="item">
                                <cms:jsonvalue key="@id" value="${cms.site.url}${navLink}" />
                                <cms:jsonvalue key="name" value="${navText}" />
                            </cms:jsonobject>
                        </cms:jsonobject>

                    </c:if>

                </cms:jsonarray>

                <c:if test="${(empty breadCrumbJson) or cms.modelGroupPage}">
                    <li><mercury:meta-title addIntro="${false}" /></li><%----%>
                </c:if>
            </ul><%----%>
            <mercury:nl />

            <c:if test="${not empty breadCrumbJson}">
                <cms:jsonobject var="jsonLd">
                    <cms:jsonvalue key="@context" value="http://schema.org" />
                    <cms:jsonvalue key="@type" value="BreadcrumbList" />
                    <cms:jsonvalue key="itemListElement" value="${breadCrumbJson.json}" />
                </cms:jsonobject>
                <script type="application/ld+json"><%----%>
                    ${cms.isOnlineProject ? jsonLd.compact : jsonLd.pretty}
                </script><%----%>
                <mercury:nl />
            </c:if>

        </mercury:nav-items>
    </mercury:nav-vars>

</div><%----%>
<mercury:nl />

</mercury:setting-defaults>
</cms:formatter>
</mercury:init-messages>