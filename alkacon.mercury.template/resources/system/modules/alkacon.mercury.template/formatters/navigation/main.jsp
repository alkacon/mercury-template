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

<m:nav-vars params="${param}">
<m:nav-items
    type="forSite"
    content="${content}"
    currentPageFolder="${currentPageFolder}"
    currentPageUri="${currentPageUri}">

    <nav class="nav-main-group ${logoImage.value.Image.isSet ? 'has-sidelogo ' : ''}${cssWrapper}"><%----%>
        <m:nl />

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
                        <m:link
                            link="${logoContent.value.Link}"
                            test="${showImageLink}"
                            testFailTag="div"
                            setTitle="${true}"
                            css="mobile-logolink" >
                            <m:image-simple
                                image="${logoImage}"
                                sizes="100,200,400,800"
                                cssWrapper="img-responsive"
                            />
                        </m:link>
                    </c:if>
                </div><%----%>
                <m:nl />
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
                                    <m:nl />
                                    <c:forEach var="link" items="${metaLinksContent.valueList.LinkEntry}" varStatus="status">
                                         <li><m:link-icon link="${link}" /></li><m:nl />
                                    </c:forEach>
                                </ul><%----%>
                            </li><%----%>
                        </c:otherwise>
                    </c:choose>
                </c:set>
            </c:if>
        </c:if>

        <c:set var="navPluginHtml">
            <m:load-plugins group="nav-main-additions" type="jsp-nocache" />
        </c:set>

        <c:set var="navLinksPlugin" value="${empty cms.plugins['nav-links'] ? null : cms.plugins['nav-links'].get(0)}" />
        <c:set var="navLength" value="${empty navItems ? 0 : fn:length(navItems) - 1}" />

        <ul class="nav-main-items ${textDisplay}${' '}${not empty sidelogohtml ? 'hassidelogo ' : ''}${showSearch ? 'has-search' : 'no-search'}"><%----%>
            <m:nl />

            <c:if test="${not empty metaLinksHtml and (metaLinks ne 'bottom')}">
                ${metaLinksHtml}
            </c:if>

            <c:forEach var="i" begin="0" end="${navLength}" >

                <c:set var="navElem" value="${navItems[i]}" />
                <c:set var="nextLevel" value="${i lt navLength ? navItems[i+1].navTreeLevel : navStartLevel}" />
                <c:set var="startSubMenu" value="${nextLevel gt navElem.navTreeLevel}" />
                <c:set var="isTopLevel" value="${navElem.navTreeLevel eq navStartLevel}" />
                <c:set var="nextIsTopLevel" value="${nextLevel eq navStartLevel}" />
                <c:set var="navTarget" value="${fn:trim(navElem.info) eq 'extern' ? ' target=\"_blank\"' : ''}" />

                <c:set var="isCurrentPage" value="${fn:startsWith(currentPageUri, cms.sitePath[navElem.resource.rootPath])}" />
                <c:set var="isFinalCurrentPage" value="${isCurrentPage and currentPageFolder eq cms.sitePath[navElem.resource.rootPath]}" />

                <m:concat var="menuType" strings="${[
                    isCurrentPage ? 'active' : '',
                    isFinalCurrentPage ? 'final' : '',
                    i == 0 ? 'nav-first' : '',
                    i == navLength ? 'nav-last' : ''
                ]}" leadSpace="${false}" />

                <%-- ###### Check for mega menu ######--%>
                <c:set var="megaMenu" value="" />
                <c:if test="${isTopLevel}">

                    <c:if test="${empty navTarget and not empty navElem.info and not fn:startsWith(navElem.info, '#') and not fn:startsWith(navElem.info, '/')}">
                        <%-- Append navInfo as CSS class, make sure this contains no invalid characters by running it through c:out --%>
                        <c:set var="menuTypeCss"><c:out value="${fn:trim(navElem.info)}" /></c:set>
                        <m:concat var="menuType" strings="${[menuType, menuTypeCss]}" leadSpace="${false}" />
                    </c:if>

                    <c:set var="megaMenuFile" value="${cms.sitemapConfig.attribute['template.mega.menu.filename'].isSetNotNone ? cms.sitemapConfig.attribute['template.mega.menu.filename'] : 'mega.menu'}" />
                    <c:choose>
                        <c:when test="${navElem.navigationLevel}">
                            <c:set var="megaMenuVfsPath" value="${cms.wrap(navElem.resource).toResource.getFolder().sitePath}${megaMenuFile}" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="megaMenuVfsPath" value="${navElem.resourceName}${megaMenuFile}" />
                        </c:otherwise>
                    </c:choose>
                    <c:set var="megaMenuRes" value="${cms.vfs.xml[megaMenuVfsPath]}" />
                    <c:if test="${not empty megaMenuRes}">
                        <c:set var="megaMenu" value=' data-megamenu="${megaMenuRes.resource.link}"' />
                        <m:concat var="menuType" strings="${[menuType, 'mega']}" leadSpace="${false}" />
                        <c:choose>
                            <c:when test="${megaMenuRes.resource.property['mercury.mega.display'] eq 'mobile'}">
                                <m:concat var="menuType" strings="${[menuType, 'mega-mobile']}" leadSpace="${false}" />
                            </c:when>
                            <c:when test="${not startSubMenu}">
                                <m:concat var="menuType" strings="${[menuType, 'mega-only']}" leadSpace="${false}" />
                            </c:when>
                        </c:choose>
                    </c:if>
                </c:if>
                <c:set var="hasMegaMenu" value="${not empty megaMenu}" />

                <c:if test="${startSubMenu or hasMegaMenu}">
                    <c:set var="instanceId"><m:idgen prefix="" uuid="${cms.element.instanceId}" /></c:set>
                    <c:set var="parentLabelId">label${instanceId}_${i}</c:set>
                    <c:set var="targetMenuId">nav${instanceId}_${i}</c:set>
                    <c:if test="${startSubMenu}">
                        <c:set var="lastNavLevel" value="${navElem}" />
                    </c:if>
                </c:if>

                <c:if test="${not empty navLinksPlugin}">
                    <%-- Call plugin that can manipulate the navLink or navText --%>
                    <c:set var="reqScopeNavElem" value="${navElem}" scope="request" />
                    <cms:include file="${navLinksPlugin.path}" cacheable="false" />
                </c:if>

                <c:choose>
                    <c:when test="${(navElem.resource.typeId eq 15) and (not empty lastNavLevel) and fn:startsWith(navElem.info, '#')}">
                        <%-- Navigation resource is a redirect. This is interpreted as an anchor link to the parent page (which is stored in lastNavLevel). --%>
                        <c:set var="navLink"><cms:link>${lastNavLevel.resourceName}${navElem.info}</cms:link></c:set>
                    </c:when>
                    <c:otherwise>
                        <c:set var="navLink"><cms:link>${navElem.resourceName}</cms:link></c:set>
                    </c:otherwise>
                </c:choose>

                <m:concat var="menuType" strings="${[menuType, startSubMenu or hasMegaMenu ? 'expand' : '']}" leadSpace="${false}" />

                <c:out value="<li${not empty menuType ? ' class=\"'.concat(menuType).concat('\"') : ''}${megaMenu}>${empty menuType ? '' : nl}" escapeXml="false" />

                <c:set var="navText"><c:out value="${(empty navElem.navText or fn:startsWith(navElem.navText, '???'))
                    ? navElem.title : navElem.navText}" /></c:set>

                <c:choose>

                    <c:when test="${startSubMenu and not navElem.navigationLevel}">
                        <%-- Navigation item with sub-menu and direct child pages --%>
                        <a href="${navLink}"${navTarget}${' '}<%--
                        --%>id="${parentLabelId}"${' '}<%--
                        --%>class="nav-label"${' '}<%--
                        --%>${'>'}${navText}</a><%----%>

                        <a href="${navLink}"${navTarget}${' '}<%--
                        --%>role="button"${' '}<%--
                        --%>aria-expanded="false"${' '}<%--
                        --%>aria-controls="${targetMenuId}"${' '}<%--
                        --%>aria-label="<fmt:message key="msg.page.navigation.sublevel.further"><fmt:param>${navText}</fmt:param></fmt:message>"<%--
                        --%>${'>'}&nbsp;</a><%----%>
                    </c:when>

                    <c:when test="${startSubMenu}">
                        <%-- Navigation item with sub-menu but without direct child pages --%>
                        <a href="${navLink}"${navTarget}${' '}<%--
                        --%>id="${parentLabelId}"${' '}<%--
                        --%>role="button"${' '}<%--
                        --%>aria-expanded="false"${' '}<%--
                        --%>aria-controls="${targetMenuId}"${' '}<%--
                        --%>aria-label="<fmt:message key="msg.page.navigation.sublevel.toggle"><fmt:param>${navText}</fmt:param></fmt:message>"<%--
                        --%>${'>'}${navText}</a><%----%>
                    </c:when>

                    <c:otherwise>
                        <%--Navigation item without sub-menu --%>
                        <a href="${navLink}"${navTarget}${' '}<%----%>
                        <c:if test="${hasMegaMenu}">
                            <%-- mega menu requires aria-controls - will be removed by JavaScript if mega menu is not displayed in mobile --%>
                            aria-controls="${targetMenuId}"${' '}<%----%>
                        </c:if>
                        <%----%>${'>'}${navText}</a><%----%>
                    </c:otherwise>
                </c:choose>

                <c:choose>
                    <c:when test="${startSubMenu}">
                    <c:out value='${nl}<ul class="nav-menu" id="${targetMenuId}" aria-label="${navText}">${nl}' escapeXml="false" />
                    </c:when>
                    <c:when test="${hasMegaMenu}">
                    <c:out value='${nl}<ul class="nav-menu" id="${targetMenuId}" aria-label="${navText}"></ul>' escapeXml="false" />
                    </c:when>
                </c:choose>

                <c:if test="${nextLevel lt navElem.navTreeLevel}">
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

            <c:if test="${not empty metaLinksHtml and (metaLinks eq 'bottom')}">
                ${metaLinksHtml}
            </c:if>

            <c:if test="${not empty searchPageUri}">
                <li id="nav-main-search" class="expand"><%----%>
                    <a href="${searchPageUri}" title="<fmt:message key="msg.page.search" />" role="button" aria-controls="nav_nav-main-search" aria-expanded="false" id="label_nav-main-search" class="click-direct"><%----%>
                        <m:icon icon="search" tag="span" cssWrapper="search search-btn" />
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

            <m:nl />
        </ul><%----%>
        <m:nl />

    </nav><%----%>

</m:nav-items>
</m:nav-vars>

<m:nl />

</cms:formatter>
</cms:bundle>
</m:init-messages>