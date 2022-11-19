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

<c:set var="setting"                    value="${cms.element.setting}" />
<c:set var="cssWrapper"                 value="${setting.cssWrapper}" />
<c:set var="showSearch"                 value="${setting.showSearch.useDefault(true).toBoolean}" />
<c:set var="textDisplay"                value="${setting.textDisplay.useDefault('cap-css').toString}" />
<c:set var="metaLinks"                  value="${setting.metaLinks.useDefault('top').toString}" />
<c:set var="showImageLink"              value="${setting.showImageLink.toBoolean}" />


<c:if test="${showSearch}">
    <c:set var="searchPageUri" value="${cms.functionDetailPageExact['Search page']}" />
</c:if>

<c:set var="logoElements" value="${cms.elementsInContainers['header-image']}" />
<c:if test="${not empty logoElements}">
    <c:set var="logoContent" value="${logoElements.get(0).toXml}" />
    <c:set var="logoImage" value="${logoContent.value.Image}" />
</c:if>

<nav class="nav-main-group ${logoImage.value.Image.isSet ? 'has-sidelogo ' : ''}${cssWrapper}"><%----%>

    <mercury:nav-vars params="${param}">
    <mercury:nav-items
        type="forSite"
        content="${content}"
        currentPageFolder="${currentPageFolder}"
        currentPageUri="${currentPageUri}">

        <c:set var="mobileHeaderPlugins" value="${cms.plugins['nav-mobile-header']}" />
        <c:choose>
            <c:when test="${not empty mobileHeaderPlugins}">
                <c:set var="mobileHeaderPlugin" value="${mobileHeaderPlugins.get(0)}" />
                <c:set var="reqScopeLogoContent" value="${logoContent}" scope="request" />
                <c:set var="reqScopeSetting" value="${setting}" scope="request" />
                <cms:include file="${mobileHeaderPlugin.path}" cacheable="false" />
            </c:when>
            <c:otherwise>
                <div class="nav-main-mobile-logo"><%----%>
                    <c:if test="${(cssWrapper ne 'no-image') and (not empty logoImage)}">
                        <mercury:link
                            link="${logoContent.value.Link}"
                            test="${showImageLink}"
                            testFailTag="div"
                            setTitle="${true}"
                            css="mobile-logolink" >
                            <mercury:image-simple
                                image="${logoImage}"
                                sizes="100,200,400,800"
                                cssWrapper="img-responsive"
                            />
                        </mercury:link>
                    </c:if>
                </div><%----%>
                <mercury:nl />
            </c:otherwise>
        </c:choose>

        <c:if test="${metaLinks ne 'none'}">
            <c:set var="metaLinkElements" value="${cms.elementsInContainers['header-linksequence']}" />
            <c:if test="${not empty metaLinkElements}">
                <c:set var="metaLinksHtml">
                    <c:set var="metaLinksContent" value="${metaLinkElements.get(0).toXml}" />
                    <c:set var="metaLinksPlugins" value="${cms.plugins['nav-meta-links']}" />
                    <c:choose>
                        <c:when test="${not empty metaLinksPlugins}">
                            <c:set var="metaLinksPlugin" value="${metaLinksPlugins.get(0)}" />
                            <c:set var="reqScopeMetaLinksContent" value="${metaLinksContent}" scope="request" />
                            <c:set var="reqScopeSetting" value="${setting}" scope="request" />
                            <cms:include file="${metaLinksPlugin.path}" cacheable="false" />
                        </c:when>
                        <c:otherwise>
                            <li id="nav-main-addition" class="expand hidden-lg-up"><%----%>
                                <a href="#" aria-controls="nav_nav-main-addition" id="label_nav-main-addition">${metaLinksContent.value.Title}</a><%----%>
                                <ul class="nav-menu" id="nav_nav-main-addition" aria-labelledby="label_nav-main-addition"><%----%>
                                    <mercury:nl />
                                    <c:forEach var="link" items="${metaLinksContent.valueList.LinkEntry}" varStatus="status">
                                         <li><mercury:link-icon link="${link}" /></li><mercury:nl />
                                    </c:forEach>
                                </ul><%----%>
                            </li><%----%>
                        </c:otherwise>
                    </c:choose>
                </c:set>
            </c:if>
        </c:if>

        <c:set var="navPluginHtml">
            <mercury:load-plugins group="nav-main-additions" type="jsp-nocache" />
        </c:set>

        <mercury:nl />
        <ul class="nav-main-items ${textDisplay}${' '}${not empty sidelogohtml ? 'hassidelogo ' : ''}${showSearch ? 'has-search' : 'no-search'}"><%----%>
        <mercury:nl />

        <c:if test="${not empty metaLinksHtml and (metaLinks ne 'bottom')}">
            ${metaLinksHtml}
        </c:if>

        <c:set var="navLength" value="${empty navItems ? 0 : fn:length(navItems) - 1}" />
        <c:forEach var="i" begin="0" end="${navLength}" >

            <c:set var="navElem" value="${navItems[i]}" />
            <c:set var="nextLevel" value="${i < navLength ? navItems[i+1].navTreeLevel : navStartLevel}" />
            <c:set var="startSubMenu" value="${nextLevel > navElem.navTreeLevel}" />
            <c:set var="isTopLevel" value="${navElem.navTreeLevel eq navStartLevel}" />
            <c:set var="nextIsTopLevel" value="${nextLevel eq navStartLevel}" />
            <c:set var="navTarget" value="${fn:trim(navElem.info) eq 'extern' ? ' target=\"_blank\"' : ''}" />

            <c:set var="isCurrentPage" value="${fn:startsWith(currentPageUri, cms.sitePath[navElem.resource.rootPath])}" />
            <c:set var="isFinalCurrentPage" value="${isCurrentPage and currentPageFolder eq cms.sitePath[navElem.resource.rootPath]}" />

            <c:set var="menuType" value="${isCurrentPage ? 'active ' : ''}" />
            <c:set var="menuType" value="${isFinalCurrentPage ? menuType.concat('final ') : menuType}" />
            <c:set var="menuType" value="${i == 0 ? menuType.concat('nav-first ') : menuType}" />
            <c:set var="menuType" value="${i == navLength ? menuType.concat('nav-last ') : menuType}" />

            <%-- ###### Check for mega menu ######--%>
            <c:set var="megaMenu" value="" />
            <c:if test="${isTopLevel}">

                <c:if test="${empty navTarget and not fn:startsWith(navElem.info, '#')}">
                    <mercury:set-content-disposition name="${fn:toLowerCase(fn:trim(navElem.info))}" suffix="" setFilenameOnly="${true}"/>
                    <c:set var="menuType" value="${menuType.concat(contentDispositionFilename)}" />
                </c:if>

                <c:set var="megaMenuVfsPath" value="${navElem.resourceName}mega.menu" />
                <c:if test="${navElem.navigationLevel}">
                    <%-- ###### Path correction needed if navLevel ###### --%>
                    <c:set var="megaMenuVfsPath" value="${fn:replace(megaMenuVfsPath, navElem.fileName, '')}" />
                </c:if>
                <c:set var="megaMenuRes" value="${cms.vfs.xml[megaMenuVfsPath]}" />
                <c:if test="${not empty megaMenuRes}">
                    <c:set var="megaMenu" value=' data-megamenu="${megaMenuRes.resource.link}"' />
                    <c:set var="menuType" value="${menuType.concat(' ').concat('mega')}" />
                    <c:choose>
                        <c:when test="${megaMenuRes.resource.property['mercury.mega.display'] eq 'mobile'}">
                            <c:set var="menuType" value="${menuType.concat(' mega-mobile')}" />
                        </c:when>
                        <c:when test="${not startSubMenu}">
                            <c:set var="menuType" value="${menuType.concat(' mega-only')}" />
                        </c:when>
                    </c:choose>
                </c:if>
            </c:if>
            <c:set var="hasMegaMenu" value="${not empty megaMenu}" />

            <c:if test="${startSubMenu or hasMegaMenu}">
                <c:set var="instanceId"><mercury:idgen prefix="" uuid="${cms.element.instanceId}" /></c:set>
                <c:set var="parentLabelId">label${instanceId}_${i}</c:set>
                <c:set var="targetMenuId">nav${instanceId}_${i}</c:set>
                <c:if test="${startSubMenu}">
                    <c:set var="lastNavLevel" value="${navElem}" />
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

            <c:set var="menuType" value="${startSubMenu or hasMegaMenu ? menuType.concat(' expand') : menuType}" />

            <c:out value='<li class="${menuType}"${megaMenu}>${empty menuType ? "" : nl}' escapeXml="false" />

            <c:set var="navText"><c:out value="${(empty navElem.navText or fn:startsWith(navElem.navText, '???'))
                ? navElem.title : navElem.navText}" /></c:set>


            <c:choose>

                <c:when test="${startSubMenu and not navElem.navigationLevel}">
                    <%-- Navigation item with sub-menu and direct child pages --%>
                    <a href="${navLink}"${navTarget}${' '}<%--
                    --%>id="${parentLabelId}"${' '}<%--
                    --%>class="nav-label"${' '}<%--
                    --%>title="<fmt:message key="msg.page.navigation.showpage" />"<%--
                    --%>${'>'}${navText}</a><%----%>

                    <a href="${navLink}"${navTarget}${' '}<%--
                    --%>role="button"${' '}<%--
                    --%>aria-expanded="false"${' '}<%--
                    --%>aria-controls="${targetMenuId}"${' '}<%--
                    --%>aria-labelledby="${parentLabelId}"<%--
                    --%>title="<fmt:message key="msg.page.navigation.sublevel" />"<%--
                    --%>${'>'}&nbsp;</a><%----%>
                </c:when>

                <c:when test="${startSubMenu}">
                    <%-- Navigation item with sub-menu but without direct child pages --%>
                    <a href="${navLink}"${navTarget}${' '}<%--
                    --%>id="${parentLabelId}"${' '}<%--
                    --%>role="button"${' '}<%--
                    --%>aria-expanded="false"${' '}<%--
                    --%>aria-controls="${targetMenuId}"${' '}<%--
                    --%>title="<fmt:message key="msg.page.navigation.sublevel" />"<%--
                    --%>${'>'}${navText}</a><%----%>
                </c:when>

                <c:otherwise>
                    <%--Navigation item without sub-menu --%>
                    <a href="${navLink}"${navTarget}${' '}<%----%>
                    <c:if test="${hasMegaMenu}">
                        <%-- mega menu requires aria-controls - will be removed by JavaScript if mega menu is not displayed in mobile --%>
                        aria-controls="${targetMenuId}"${' '}<%----%>
                    </c:if>
                    <%----%>title="<fmt:message key="msg.page.navigation.showpage" />"<%--
                    --%>${'>'}${navText}</a><%----%>
                </c:otherwise>
            </c:choose>

            <c:choose>
                <c:when test="${startSubMenu}">
                   <c:out value='${nl}<ul class="nav-menu" id="${targetMenuId}" aria-labelledby="${parentLabelId}">${nl}' escapeXml="false" />
                </c:when>
                <c:when test="${hasMegaMenu}">
                   <c:out value='${nl}<ul class="nav-menu" id="${targetMenuId}" aria-labelledby="${parentLabelId}"></ul>' escapeXml="false" />
                </c:when>
            </c:choose>

            <c:if test="${nextLevel < navElem.navTreeLevel}">
                <c:forEach begin="1" end="${navElem.navTreeLevel - nextLevel}" >
                    <c:out value='</li>${nl}</ul>${nl}' escapeXml="false" />
                </c:forEach>
            </c:if>

            <c:if test="${not startSubMenu}"><c:out value='</li>${nl}' escapeXml="false" /></c:if>

        </c:forEach>

        <c:if test="${not empty metaLinksHtml and (metaLinks eq 'bottom')}">
            ${metaLinksHtml}
        </c:if>

        <c:if test="${not empty searchPageUri}">
            <li id="nav-main-search" class="expand"><%----%>
                <a href="${searchPageUri}" title="<fmt:message key="msg.page.search" />" role="button" aria-controls="nav_nav-main-search" aria-expanded="false" id="label_nav-main-search" class="click-direct"><%----%>
                    <mercury:icon-display icon="search" tag="span" cssWrapper="search search-btn" use="nav-main" />
                </a><%----%>
                <ul class="nav-menu" id="nav_nav-main-search" aria-labelledby="label_nav-main-search"><%----%>
                    <li><%----%>
                        <div class="styled-form search-form"><%----%>
                            <form action="${searchPageUri}" method="post"><%----%>
                                <div class="input button"><%----%>
                                    <label for="searchNavQuery" class="sr-only"><fmt:message key="msg.page.search" /></label><%----%>
                                    <input id="searchNavQuery" name="q" type="text" autocomplete="off" placeholder='<fmt:message key="msg.page.search.enterquery" />' /><%----%>
                                    <button class="btn" type="button" title="<fmt:message key="msg.page.search" />" onclick="this.form.submit(); return false;"><%----%>
                                        <fmt:message key="msg.page.search.submit" /><%----%>
                                    </button><%----%>
                                </div><%----%>
                            </form><%----%>
                        </div><%----%>
                    </li><%----%>
                </ul><%----%>
            </li><%----%>
        </c:if>

        <c:if test="${not empty navPluginHtml}">
            ${navPluginHtml}
        </c:if>

        <mercury:nl />
        </ul><%----%>
        <mercury:nl />

    </mercury:nav-items>
    </mercury:nav-vars>

</nav><%----%>

</cms:formatter>
</cms:bundle>
</mercury:init-messages>