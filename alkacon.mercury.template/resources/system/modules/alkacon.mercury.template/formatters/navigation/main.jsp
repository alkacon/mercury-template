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

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<cms:formatter var="content" val="value">

<c:set var="logoElements" value="${cms.elementsInContainers['header-image']}" />
<c:if test="${not empty logoElements}">
    <c:set var="logoContent" value="${logoElements.get(0).toXml}" />
    <c:set var="logoImage" value="${logoContent.value.Image}" />
</c:if>

<nav class="nav-main-group ${logoImage.value.Image.isSet ? 'has-sidelogo' : ''}"><%----%>

    <mercury:nav-items
        type="forSite"
        content="${content}"
        currentPageFolder="${cms.requestContext.folderUri}"
        currentPageUri="${cms.requestContext.uri}"
        var="nav"><%----%>

        <c:if test="${not empty logoImage}">
            <div class="nav-main-mobile-logo"><%----%>
                <mercury:image-vars image="${logoImage}">
                    <img src="${imageLink.toLink}" alt="${imageTitleCopyright}" class="img-responsive"><%----%>
                </mercury:image-vars>
            </div><%----%>
        </c:if>

        <mercury:nl />
        <ul class="nav-main-items ${not empty sidelogohtml ? 'hassidelogo' : ''}"><%----%>
        <mercury:nl />

        <c:set var="linkElements" value="${cms.elementsInContainers['header-linksequence']}" />
        <c:if test="${not empty linkElements}">
            <c:set var="linksequence" value="${linkElements.get(0).toXml}" />
            <li id="nav-main-addition" aria-expanded="false"  class="hidden-lg hidden-xl"><%----%>
                <a href="#" title="Search" aria-controls="nav_nav-main-addition" id="label_nav-main-addition">${linksequence.value.Title}</a><%----%>
                <ul class="nav-menu" id="nav_nav-main-addition" aria-labelledby="label_nav-main-addition"><%----%>
                    <mercury:nl />
                    <c:forEach var="link" items="${linksequence.valueList.LinkEntry}" varStatus="status">
                        <c:set var="linkText" value="${link.value.Text}" />
                        <c:if test="${fn:startsWith(linkText, 'icon:')}">
                            <c:set var="linkText"><span class="fa fa-${fn:substringAfter(linkText, 'icon:')}"></span></c:set>
                        </c:if>
                        <li><mercury:link link="${link}">${linkText}</mercury:link></li><mercury:nl />
                    </c:forEach>
                </ul><%----%>
            </li><%----%>
        </c:if>

        <c:set var="navLength" value="${fn:length(nav.items) - 1}" />
        <c:forEach var="i" begin="0" end="${navLength}" >

            <c:set var="navElem" value="${nav.items[i]}" />
            <c:set var="nextLevel" value="${i < navLength ? nav.items[i+1].navTreeLevel : navStartLevel}" />
            <c:set var="startSubMenu" value="${nextLevel > navElem.navTreeLevel}" />
            <c:set var="isTopLevel" value="${navElem.navTreeLevel eq navStartLevel}" />
            <c:set var="nextIsTopLevel" value="${nextLevel eq navStartLevel}" />
            <c:set var="navTarget" value="${fn:trim(navElem.info)eq 'extern' ? ' target=\"_blank\"' : ''}" />

            <c:set var="isCurrentPage" value="${navElem.navigationLevel ?
                (navElem.navTreeLevel > navStartLevel) and fn:startsWith(cms.requestContext.uri, navElem.parentFolderName) :
                fn:startsWith(cms.requestContext.uri, navElem.resourceName)}" />

            <c:set var="menuType">
                ${isCurrentPage ? ' active' : ''}
            </c:set>

            <c:if test="${navElem.navigationLevel}">
                <c:set var="lastNavLevel" value="${navElem}" />
            </c:if>

            <%-- ###### Check for mega menu ######--%>
            <c:set var="megaMenu" value="" />
            <c:if test="${isTopLevel}">
                <c:set var="megaMenuVfsPath" value="${navElem.resourceName}mega.menu" />
                <c:if test="${navElem.navigationLevel}">
                    <%-- ###### Path correction needed if navLevel ###### --%>
                    <c:set var="megaMenuVfsPath" value="${fn:replace(megaMenuVfsPath, navElem.fileName, '')}" />
                </c:if>
                <c:if test="${cms.vfs.existsXml[megaMenuVfsPath]}">
                    <c:set var="megaMenuLink"><cms:link>${megaMenuVfsPath}</cms:link></c:set>
                    <c:set var="megaMenu" value=' data-megamenu="${megaMenuLink}"' />
                    <c:set var="menuType" value="${menuType} mega" />
                </c:if>
            </c:if>

            <c:choose>
                <c:when test="${(not empty lastNavLevel) and fn:startsWith(navElem.info, '#')}">
                    <c:set var="navLink"><cms:link>${lastNavLevel.resourceName}${navElem.info}</cms:link></c:set>
                </c:when>
                <c:otherwise>
                    <c:set var="navLink"><cms:link>${navElem.resourceName}</cms:link></c:set>
                </c:otherwise>
            </c:choose>

            <c:if test="${startSubMenu}">
                <c:set var="instanceId"><mercury:idgen prefix="" uuid="${cms.element.instanceId}" /></c:set>
                <c:set var="parentLabelId">label${instanceId}_${i}</c:set>
                <c:set var="targetMenuId">nav${instanceId}_${i}</c:set>
            </c:if>

            <c:set var="menuType" value="${empty menuType ? '' : ' class=\"'.concat(menuType).concat('\"')}" />
            <c:set var="menuType" value="${startSubMenu ? menuType.concat(' aria-expanded=\"false\"') : menuType}" />

            <c:out value='<li${menuType}${megaMenu}>${empty menuType ? "" : nl}' escapeXml="false" />

            <c:set var="navText" value="${(empty navElem.navText or fn:startsWith(navElem.navText, '???'))
                ? navElem.title : navElem.navText}" />

            <c:choose>
                <c:when test="${startSubMenu and navElem.navigationLevel}">
                    <%-- Navigation item with sub-menu but without direct child pages --%>
                    <a href="${navLink}"${navTarget}${' '}<%--
                    --%>id="${parentLabelId}"${' '}<%--
                    --%>aria-controls="${targetMenuId}">${navText}</a><%--
            --%></c:when>

                <c:when test="${startSubMenu}">
                    <%-- Navigation item with sub-menu and direct child pages --%>
                    <a href="${navLink}"${navTarget} class="nav-label" id="${parentLabelId}">${navText}</a><%--
                --%><a href="${navLink}"${navTarget} aria-controls="${targetMenuId}">&nbsp;</a><%--
            --%></c:when>

                <c:otherwise>
                    <%--Navigation item without sub-menu --%>
                    <a href="${navLink}"${navTarget}>${navText}</a><%--
            --%></c:otherwise>
            </c:choose>

            <c:if test="${startSubMenu}">
               <c:out value='${nl}<ul class="nav-menu" id="${targetMenuId}" aria-labelledby="${parentLabelId}">${nl}' escapeXml="false" />
            </c:if>

            <c:if test="${nextLevel < navElem.navTreeLevel}">
                <c:forEach begin="1" end="${navElem.navTreeLevel - nextLevel}" >
                    <c:out value='</li>${nl}</ul>${nl}' escapeXml="false" />
                </c:forEach>
            </c:if>

            <c:if test="${not startSubMenu}"><c:out value='</li>${nl}' escapeXml="false" /></c:if>

        </c:forEach>

        <c:set var="searchPageUrl" value="${cms.functionDetail['Search page']}" />
        <c:set var="hidesearch" value="${fn:startsWith(searchPageUrl,'[')}" />

        <c:if test="${not hidesearch}">
            <li id="nav-main-search" aria-expanded="false"><%----%>
                <a href="#" title="Search" aria-controls="nav_nav-main-search" id="label_nav-main-search"><%----%>
                    <span class="search search-btn fa fa-search"></span><%----%>
                </a><%----%>
                <ul class="nav-menu" id="nav_nav-main-search" aria-labelledby="label_nav-main-search"><%----%>
                    <li><%----%>
                        <div class="styled-form search-form"><%----%>
                            <form action="${searchPageUrl}" method="post"><%----%>
                                <div class="input button"><%----%>
                                    <label for="searchNavQuery" class="sr-only">Search</label><%----%>
                                    <input id="searchNavQuery" name="q" type="text" class="blur-focus" autocomplete="off" placeholder='<fmt:message key="msg.page.search.enterquery" />' /><%----%>
                                    <button class="btn" type="button" onclick="this.form.submit(); return false;"><fmt:message key="msg.page.search.submit" /></button><%----%>
                                </div><%----%>
                            </form><%----%>
                        </div><%----%>
                    </li><%----%>
                </ul><%----%>
            </li><%----%>
        </c:if>

        <mercury:nl />
        </ul><%----%>
        <mercury:nl />

    </mercury:nav-items>

</nav><%----%>

</cms:formatter>
</cms:bundle>
</mercury:init-messages>