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

<m:init-messages>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">
<cms:formatter var="content" val="value">

<m:setting-defaults>

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="allOpen"                value="${setting.allOpen.toBoolean}" />
<c:set var="ade"                    value="${cms.isEditMode}" />

<m:nl />

<m:nav-vars params="${param}">
<m:nav-items
    type="forSite"
    content="${content}"
    currentPageFolder="${currentPageFolder}"
    currentPageUri="${currentPageUri}" >

    <%-- If no navigation items are found, no output must be generated online --%>

    <div class="element type-nav-side pivot${setCssWrapperAll}"><%----%>
    <m:nl />

        <m:heading level="${hsize}" text="${value.Title}" css="heading" ade="${ade}" />

        <c:set var="navLength" value="${empty navItems ? 0 : fn:length(navItems) - 1}" />
        <ul class="nav-side"><%----%>
            <m:nl />
            <c:forEach var="i" begin="0" end="${navLength}" >

                <c:set var="navElem" value="${navItems[i]}" />
                <c:set var="nextLevel" value="${i < navLength ? navItems[i+1].navTreeLevel : navStartLevel}" />
                <c:set var="startSubMenu" value="${nextLevel > navElem.navTreeLevel}" />
                <c:set var="isTopLevel" value="${navElem.navTreeLevel eq navStartLevel}" />
                <c:set var="isCurrentPage" value="${fn:startsWith(currentPageUri, cms.sitePath[navElem.resource.rootPath])}" />
                <c:set var="isFinalCurrentPage" value="${isCurrentPage and currentPageFolder eq cms.sitePath[navElem.resource.rootPath]}" />
                <c:set var="navTarget" value="${fn:trim(navElem.info) eq 'extern' ? ' target=\"_blank\"' : ''}" />

                <m:concat var="menuType" strings="${[isCurrentPage ? 'currentpage' : '', isFinalCurrentPage ? 'final' : '']}" leadSpace="${false}" />

                <c:if test="${isTopLevel}">
                    <c:if test="${empty navTarget and not empty navElem.info and not fn:startsWith(navElem.info, '#') and not fn:startsWith(navElem.info, '/')}">
                        <%-- Append navInfo as CSS class, make sure this contains no invalid characters by running it through c:out --%>
                        <c:set var="menuTypeCss"><c:out value="${fn:trim(navElem.info)}" /></c:set>
                        <m:concat var="menuType" strings="${[menuType, menuTypeCss]}" leadSpace="${false}" />
                    </c:if>
                </c:if>

                <c:if test="${startSubMenu}">
                    <c:set var="instanceId"><m:idgen prefix="" uuid="${cms.element.instanceId}" /></c:set>
                    <c:set var="parentLabelId">label${instanceId}_${i}</c:set>
                    <c:set var="targetMenuId">nav${instanceId}_${i}</c:set>
                    <c:set var="lastNavLevel" value="${navElem}" />
                </c:if>

                <c:choose>
                    <c:when test="${(not empty lastNavLevel) and fn:startsWith(navElem.info, '#')}">
                        <c:set var="navLink"><cms:link>${lastNavLevel.resourceName}${navElem.info}</cms:link></c:set>
                    </c:when>
                    <c:otherwise>
                        <c:set var="navLink"><cms:link>${navElem.resourceName}</cms:link></c:set>
                    </c:otherwise>
                </c:choose>

                <c:set var="navText"><c:out value="${(empty navElem.navText or fn:startsWith(navElem.navText, '???')) ? navElem.title : navElem.navText}" /></c:set>

                <c:out value="<li${not empty menuType ? ' class=\"'.concat(menuType).concat('\"') : ''}>" escapeXml="false" />

                <c:choose>
                    <c:when test="${startSubMenu and not navElem.navigationLevel}">
                        <%-- Navigation item with sub-menu and direct child pages --%>
                        <a href="${navLink}"${navTarget}${' '}<%--
                        --%>id="${parentLabelId}"${' '}<%--
                        --%>class="nav-label"${' '}<%--
                        --%>${'>'}${navText}</a><%----%>

                        <c:if test="${not allOpen}">
                            <a href="${navLink}"${navTarget}${' '}<%--
                            --%>role="button"${' '}<%--
                            --%>data-bs-toggle="collapse"${' '}<%--
                            --%>data-bs-target="#${targetMenuId}"${' '}<%--
                            --%>${isCurrentPage ? 'aria-expanded=\"true\" class=\"collapse show\"' : 'aria-expanded=\"false\"'}${' '}<%--
                            --%>aria-controls="${targetMenuId}"${' '}<%--
                            --%>aria-label="<fmt:message key="msg.page.navigation.sublevel.further"><fmt:param>${navText}</fmt:param></fmt:message>"<%--
                            --%>${'>'}&nbsp;</a><%----%>
                        </c:if>
                    </c:when>

                    <c:when test="${startSubMenu}">
                        <%-- Navigation item with sub-menu but without direct child pages --%>
                        <a href="${navLink}"${navTarget}${' '}<%--
                        --%>id="${parentLabelId}"${' '}<%--
                        --%><c:if test="${not allOpen}"><%--
                            --%>role="button"${' '}<%--
                            --%>data-bs-toggle="collapse"${' '}<%--
                            --%>data-bs-target="#${targetMenuId}"${' '}<%--
                            --%>${isCurrentPage ? 'aria-expanded=\"true\" class=\"collapse show\"' : 'aria-expanded=\"false\"'}${' '}<%--
                            --%>aria-controls="${targetMenuId}"${' '}<%--
                            --%>aria-label="<fmt:message key="msg.page.navigation.sublevel.toggle"><fmt:param>${navText}</fmt:param></fmt:message>"<%--
                        --%></c:if><%--
                        --%>${'>'}${navText}</a><%----%>
                    </c:when>

                    <c:otherwise>
                        <%--Navigation item without sub-menu --%>
                        <a href="${navLink}"${navTarget}>${navText}</a><%--
                --%></c:otherwise>
                </c:choose>

                <c:if test="${startSubMenu}">
                   <c:set var="collapseIn" value="${isCurrentPage and not allOpen ? ' show' : ''}" />
                   <m:nl />
                   <c:out value="<ul${allOpen ? ' ' : ' class=\"collapse'.concat(collapseIn).concat('\" ')} id=\"${targetMenuId}\" aria-label=\"${navText}\">" escapeXml="false" />
                </c:if>

                <c:if test="${nextLevel < navElem.navTreeLevel}">
                    <c:forEach begin="1" end="${navElem.navTreeLevel - nextLevel}" >
                        <c:out value='</li></ul>' escapeXml="false" />
                        <m:nl />
                    </c:forEach>
                </c:if>

                <c:if test="${not startSubMenu}">
                    <c:out value='</li>' escapeXml="false" />
                    <m:nl />
                </c:if>

            </c:forEach>
        </ul><%----%>
        <m:nl />

    </div><%----%>

</m:nav-items>
</m:nav-vars>

<m:nl />

</m:setting-defaults>

</cms:formatter>
</cms:bundle>
</m:init-messages>