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

<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<cms:formatter var="content" val="value">

<c:set var="variant"            value="${value.Variant}" />
<c:set var="setting"            value="${cms.element.setting}" />
<c:set var="cssWrapper"         value="${cms.element.setting.cssWrapper.toString}" />

<jsp:useBean id="valueMap"      class="java.util.HashMap" />
<jsp:useBean id="params"        class="java.util.HashMap" />
<jsp:useBean id="settings"      class="java.util.HashMap" />

<c:set var="isSideGroup"        value="${variant eq 'side-group'}" />
<c:set var="isSideContainer"    value="${fn:contains(cms.container.type, 'side-group')}" />

<c:if test="${(isSideGroup and isSideContainer) or (not isSideGroup and not isSideContainer)}">

<mercury:container-box label="${value.Title}" boxType="model-start" />

<c:choose>

    <c:when test="${variant eq 'head-flex-bc'}">

        <c:set var="showBreadcrumbs"            value="${setting.showBreadcrumbs.useDefault(true).toBoolean}" />
        <c:set var="addBottomMargin"            value="${setting.addBottomMargin.useDefault(true).toBoolean}" />

        <c:set var="showConfigElement"          value="${cms.isEditMode and ((cms.element.modelGroup and cms.modelGroupElement) or (not cms.element.modelGroup))}" />
        <c:set var="configElement">
            <c:if test="${showConfigElement}">
                <mercury:container type="header-config" name="header-config" title="${value.Title}" />
            </c:if>
        </c:set>

        <c:set var="headerConfigElementBeans" value="${cms.elementBeansInContainers['header-config']}" />

        <c:choose>
            <c:when test="${not empty headerConfigElementBeans}">

                <c:set var="config"             value="${headerConfigElementBeans.get(0)}" />
                <c:set var="addCssWrapper"      value="${config.setting.cssWrapper.toString}" />
                <c:set var="logoAlignment"      value="${config.setting.logoAlignment.useDefault('lp-left').toString}" />
                <c:set var="logoSize"           value="${config.setting.logoSize.useDefault('ls-4').toString}" />
                <c:set var="logoFullSize"       value="${logoSize eq 'ls-12'}" />
                <c:set var="logoPosCenter"      value="${logoFullSize or (logoAlignment eq 'lp-c')}" />
                <c:set var="logoPosLeft"        value="${logoPosCenter ? false : (logoAlignment eq 'lp-l')}" />
                <c:set var="logoAlignment"      value="${logoPosCenter ? 'lp-c' : logoAlignment}" />
                <c:set var="logoCols"           value="${fn:substringAfter(logoSize, 'ls-')}" />
                <c:set var="alignDefault"       value="${logoPosCenter ? 'center' : (logoPosLeft ? 'right' : 'left')}" />
                <c:set var="logoPadding"        value="${config.setting.logoPadding.useDefault('padding-sm').toString}" />
                <c:set var="showMeta"           value="${config.setting.metaDisplay.toString ne 'hide-meta'}" />
                <c:set var="metaAlignment"      value="${config.setting.metaAlignment.useDefault('meta-right').toString}" />
                <c:set var="metaAlignment"      value="${metaAlignment eq 'default' ? 'meta-'.concat(alignDefault) : metaAlignment}" />
                <c:set var="metaPosition"       value="${logoPosCenter ? 'meta-above' : config.setting.metaPosition.useDefault('meta-aside').toString}" />
                <c:set var="showTitle"          value="${config.setting.showTitle.toString ne 'hide-title'}" />
                <c:set var="titleAlignment"     value="${config.setting.titleAlignment.useDefault('title-right').toString}" />
                <c:set var="titleAlignment"     value="${titleAlignment eq 'default' ? 'title-'.concat(alignDefault) : titleAlignment}" />
                <c:set var="titlePosition"      value="${config.setting.titlePosition.useDefault('title-middle').toString}" />
                <c:set var="navAlignment"       value="${config.setting.navAlignment.useDefault('nav-right').toString}" />
                <c:set var="navAlignment"       value="${navAlignment eq 'default' ? 'nav-'.concat(alignDefault) : navAlignment}" />
                <c:set var="navPosition"        value="${logoPosCenter ? 'nav-below' : config.setting.navPosition.useDefault('nav-aside').toString}" />
                <c:set var="navDisplay"         value="${config.setting.navDisplay.useDefault('nav-disp-default').toString}" />
                <c:set var="navPullUp"          value="${config.setting.navPullUp.useDefault('np-never').toString}" />
                <c:set var="navFixType"         value="${config.setting.headerPosition.useDefault('css').toString}" />
                <c:set var="navFixDisplay"      value="${config.setting.navFixDisplay.useDefault('fix-compact').toString}" />
                <c:set var="navFixDisplay"      value="${logoPosCenter ? ((navFixDisplay eq 'fix-overlay') ? 'fix-complete' : navFixDisplay) : navFixDisplay}" />
                <c:set var="acDisplay"          value="${config.setting.acDisplay.useDefault('none').toString}" />
                <c:set var="acPosition"         value="${config.setting.acPosition.useDefault('ac-below-logo').toString}" />
                <c:set var="bcDisplay"          value="${config.setting.bcDisplay.useDefault('bc-show').toString}" />
                <c:set var="bcAlignment"        value="${config.setting.bcAlignment.useDefault('bc-left').toString}" />
                <c:set var="showBreadcrumbs"    value="${showBreadcrumbs and (bcDisplay eq 'bc-show')}" />

                <c:set var="showNavAside"       value="${not logoPosCenter and (navPosition ne 'nav-below')}" />
                <c:set var="showMetaAside"      value="${not logoPosCenter and showMeta and (metaPosition ne 'meta-above')}" />
                <c:set var="showOnlyNavAside"   value="${showNavAside and not showMetaAside and not showTitle}" />
                <c:set var="needInfoCol"        value="${not logoPosCenter}" />
                <c:set var="needNavPull"        value="${not showNavAside and (navPullUp ne 'np-never')}" />
                <c:set var="needTitlePosition"  value="${showTitle and (titlePosition ne 'title-center')}" />
                <c:set var="showTitleAside"     value="${not logoPosCenter}" />
                <c:set var="showAddContainer"   value="${acDisplay ne 'none'}" />
                <c:set var="acHasPageSize"      value="${showAddContainer and (acDisplay eq 'ac-page-size')}" />

                <c:choose>
                    <c:when test="${navFixType eq 'css'}" >
                        <c:set var="fixHeader" value="sticky csssetting" />
                    </c:when>
                    <c:when test="${navFixType eq 'upscroll'}" >
                        <c:set var="fixHeader" value="sticky upscroll" />
                    </c:when>
                    <c:when test="${navFixType eq 'fixed'}" >
                        <c:set var="fixHeader" value="sticky always" />
                    </c:when>
                </c:choose>

                <c:set var="navToggleElement">
                    <input type="checkbox" id="nav-toggle-check"><%-- Must be here so it works even when JavaScript is disabled --%>
                    <div id="nav-toggle-group"><%----%>
                        <label for="nav-toggle-check" id="nav-toggle-label"><%----%>
                            <span class="nav-toggle"><%----%>
                                <span><fmt:message key="msg.page.navigation.toggle" /></span><%----%>
                            </span><%----%>
                        </label><%----%>
                        <div class="head-overlay"></div><%----%>
                    </div><%----%>
                    <mercury:nl />
                </c:set>

                <%--
                    Attention: The order in which the containers are created here
                    MUST match the order in which they are displayed below!
                    The Flex cache will output the containers correctly only in the order they have been created.
                    This is why the logoElement is duplicated before / after the meta link element.
                --%>

                <c:if test="${showMetaAside}">
                    <c:set var="logoElement">
                        <c:set target="${settings}" property="cssWrapper"         value="header-image" />
                        <c:set target="${settings}" property="showImageLink"      value="true" />
                        <mercury:container type="image-minimal" name="header-image" css="h-logo p-xs-12 p-lg-${logoCols}" title="${value.Title}" settings="${settings}" />
                    </c:set>
                </c:if>

                <c:set var="metaLinkElement">
                    <c:if test="${showMeta}">
                        <c:set target="${settings}" property="cssWrapper"       value="header-links" />
                        <c:set target="${settings}" property="linksequenceType" value="ls-row" />
                        <c:set target="${settings}" property="hsize"            value="0" />
                        <mercury:div css="h-meta" test="${not showMetaAside}">
                            <mercury:container type="linksequence-header" name="header-linksequence" css="${not showMetaAside ? 'co-lg-xl' : 'h-meta'}" title="${value.Title}" settings="${settings}" />
                        </mercury:div>
                    </c:if>
                </c:set>

                <c:if test="${not showMetaAside}">
                    <c:set var="logoElement">
                        <c:set target="${settings}" property="cssWrapper"         value="header-image" />
                        <c:set target="${settings}" property="showImageLink"      value="true" />
                        <mercury:container type="image-minimal" name="header-image" css="h-logo p-xs-12 p-lg-${logoCols}" title="${value.Title}" settings="${settings}" />
                    </c:set>
                </c:if>

                <c:set var="titleElement">
                    <c:if test="${showTitle}">
                        <c:set var="imageElements" value="${cms.elementsInContainers['header-image']}" />
                        <c:if test="${not empty imageElements}">
                            <c:set var="imagecontent" value="${imageElements.get(0).toXml}" />
                            <c:choose>
                                <c:when test="${cms.detailRequest and not empty cms.meta.ogTitle}">
                                    <c:set var="pagetitle" value="${cms.meta.ogTitle}" />
                                </c:when>
                                <c:otherwise>
                                    <c:set var="pagetitle" value="${cms.title}" />
                                </c:otherwise>
                            </c:choose>
                            <c:set var="pageTitle" value="${fn:replace(imagecontent.value.Title.resolveMacros, '%(cms.title)', pagetitle)}" />
                            <mercury:div css="h-title" test="${not showTitleAside}">
                                <mercury:heading level="${7}" ade="false" text="${pageTitle}" css="${not showTitleAside ? 'co-lg-xl' : 'h-title'}" />
                            </mercury:div>
                        </c:if>
                    </c:if>
                </c:set>

                <c:set var="navBarElement">
                     <div class="h-nav"><%----%>
                        <mercury:div css="co-lg-xl" test="${not showNavAside}">
                            <mercury:container type="nav-main" name="header-nav-main" css="nav-main-container" title="${value.Title}" />
                        </mercury:div>
                    </div><%----%>
                    <mercury:nl />
                </c:set>

                <c:if test="${showAddContainer}">
                    <c:set var="addContainerElement">
                        <mercury:div css="h-ac" test="${acHasPageSize}">
                            <mercury:container type="row" name="header-container" css="${acHasPageSize ? 'co-lg-xl p-xs-12' : 'h-ac'}" title="${value.Title}"  />
                        </mercury:div>
                    </c:set>
                </c:if>

                <c:set var="breadcrumbElement">
                    <c:if test="${showBreadcrumbs and ((not empty cms.elementsInContainers['breadcrumbs']) or cms.modelGroupElement or not cms.element.modelGroup)}">
                        <div class="h-bc"><%----%>
                            <mercury:container type="nav-breadcrumbs" name="header-breadcrumbs" css="container" title="${value.Title}" />
                        </div><%----%>
                        <mercury:nl />
                    </c:if>
                </c:set>

                <mercury:nl />
                <header class="area-header fh <%----%>
                    ${logoAlignment}${' '}
                    ${logoSize}${' '}
                    ${logoPadding}${' '}
                    ${showMeta ? metaPosition.concat(' ').concat(metaAlignment.concat(' ')) : ''}
                    ${showTitle ? titleAlignment.concat(' ') : ''}
                    ${needTitlePosition ? titlePosition.concat(' ') : ''}
                    ${navDisplay}${' '}
                    ${navAlignment}${' '}
                    ${showOnlyNavAside ? 'nav-only ' : ''}
                    ${navPosition}${' '}
                    ${needNavPull ? navPullUp.concat(' ') : ''}
                    ${navFixDisplay}${' '}
                    ${showAddContainer ? acDisplay.concat(' ').concat(acPosition.concat(' ')) : ''}
                    ${bcAlignment}
                    ${not addBottomMargin ? ' no-margin' : ''}
                    ${not empty cssWrapper ? ' '.concat(cssWrapper) : ''}
                    ${not empty addCssWrapper ? ' '.concat(addCssWrapper) : ''}"><%----%>
                    <mercury:nl />

                    ${configElement}

                    ${navToggleElement}

                    <div class="header-group co-sm-md ${fixHeader}"><%----%>

                        <div class="head notfixed"><%----%>
                            <mercury:nl />

                            <%--
                                Attention: The order in which the containers have been created above
                                MUST match the order in which they are displayed here!
                                The Flex cache will output the containers correctly only in the order they have been created.
                            --%>

                            <c:if test="${not showMetaAside}">
                                ${metaLinkElement}
                            </c:if>

                            ${needInfoCol ? '<div class=\"h-group co-lg-xl\">' : ''}

                                ${logoElement}

                                ${needInfoCol ? '<div class=\"h-info\">' : ''}

                                    <c:if test="${showMetaAside}">
                                        ${metaLinkElement}
                                    </c:if>

                                    ${titleElement}

                                    <c:if test="${showNavAside}">
                                        ${navBarElement}
                                    </c:if>

                                ${needInfoCol ? '</div>' : ''}

                            ${needInfoCol ? '</div>' : ''}


                            <c:if test="${not showNavAside}">
                                ${navBarElement}
                            </c:if>

                            <c:if test="${showAddContainer}">
                                ${addContainerElement}
                            </c:if>

                        </div><%----%>
                    </div><%----%>
                    <mercury:nl />

                    ${breadcrumbElement}

                </header><%----%>
                <mercury:nl />

            </c:when>

            <c:when test="${showConfigElement}">
                <mercury:nl />
                <header class="area-header fh title-center">

                    ${configElement}

                    <mercury:alert type="warning">
                        <jsp:attribute name="head">
                            <fmt:message key="msg.page.header.no-config" />
                        </jsp:attribute>
                        <jsp:attribute name="text">
                            <fmt:message key="msg.page.header.no-config.help" />
                        </jsp:attribute>
                    </mercury:alert>

                </header>
                <mercury:nl />
            </c:when>

            <c:when test="${cms.isEditMode}">

                <mercury:alert type="error">
                    <jsp:attribute name="head">
                        ${cms.reloadMarker}
                        <fmt:message key="msg.page.mustReload" />
                    </jsp:attribute>
                    <jsp:attribute name="text">
                        <fmt:message key="msg.page.mustReload.hint2" />
                    </jsp:attribute>
                </mercury:alert>

            </c:when>
        </c:choose>
    </c:when>

    <c:when test="${(variant eq 'head-v1-bc-fh') or (variant eq 'head-v2-bc-fh')}">

        <c:choose>
            <c:when test="${variant eq 'head-v1-bc-fh'}">
                <c:set var="showNavBarFullWith" value="${false}" />
                <c:set var="showTopVisual" value="${false}" />
            </c:when>
            <c:when test="${variant eq 'head-v2-bc-fh'}">
                <c:set var="showNavBarFullWith" value="${true}" />
                <c:set var="showTopVisual" value="${true}" />
            </c:when>
        </c:choose>

        <c:set var="headerPosition"     value="${setting.headerPosition.toString}" />
        <c:set var="showBreadcrumbs"    value="${setting.showBreadcrumbs.toBoolean}" />

        <c:choose>
            <c:when test="${headerPosition eq 'css'}" >
                <c:set var="fixHeader" value="sticky csssetting" />
            </c:when>
            <c:when test="${headerPosition eq 'upscroll'}" >
                <c:set var="fixHeader" value="sticky upscroll" />
            </c:when>
            <c:when test="${headerPosition eq 'fixed'}" >
                <c:set var="fixHeader" value="sticky always" />
            </c:when>
        </c:choose>

        <mercury:nl />
        <header class="area-header logo-left ${cssWrapper}"><%----%>
            <mercury:nl />

            <input type="checkbox" id="nav-toggle-check"><%-- Must be here so it works even when JavaScript is disabled --%>
            <div id="nav-toggle-group"><%----%>
                <label for="nav-toggle-check" id="nav-toggle-label"><%----%>
                    <span class="nav-toggle"><%----%>
                        <span><fmt:message key="msg.page.navigation.toggle" /></span><%----%>
                    </span><%----%>
                </label><%----%>
                <div class="head-overlay"></div><%----%>
            </div><%----%>
            <mercury:nl />

            <div class="header-group ${fixHeader}"><%----%>
                <div class="head notfixed"><%----%>

                    <mercury:nl />
                    <div class="container"><%----%>
                        <div class="row"><%----%>

                            <c:set target="${settings}" property="cssWrapper"         value="header-image" />
                            <c:set target="${settings}" property="showImageLink"      value="true" />
                            <mercury:container type="image-minimal" name="header-image" css="col col-head-logo" title="${value.Title}" settings="${settings}" />

                            <div class="col col-head-info"><%----%>

                                <c:set target="${settings}" property="cssWrapper"       value="header-links" />
                                <c:set target="${settings}" property="linksequenceType" value="ls-row" />
                                <c:set target="${settings}" property="iconClass"        value="none" />
                                <c:set target="${settings}" property="hsize"            value="0" />
                                <mercury:container type="linksequence" name="header-linksequence" css="header-links-bg" title="${value.Title}" settings="${settings}" />

                                <c:set var="imageElements" value="${cms.elementsInContainers['header-image']}" />
                                <c:if test="${not empty imageElements}">
                                    <c:set var="imagecontent" value="${imageElements.get(0).toXml}" />
                                    <c:choose>
                                        <c:when test="${cms.detailRequest and not empty cms.meta.ogTitle}">
                                            <c:set var="pagetitle" value="${cms.meta.ogTitle}" />
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="pagetitle" value="${cms.title}" />
                                        </c:otherwise>
                                    </c:choose>
                                    <c:set var="pageTitle" value="${fn:replace(imagecontent.value.Title.resolveMacros, '%(cms.title)', pagetitle)}" />
                                    <mercury:heading level="${7}" ade="false" text="${pageTitle}" css="header-title hidden-fixed" />
                                </c:if>

                                <c:if test="${not showNavBarFullWith}">
                                    <mercury:container type="nav-main" name="navbar" css="nav-main-container" title="${value.Title}" />
                                </c:if>

                            </div><%----%>
                            <mercury:nl />

                        </div><%----%>
                    </div><%----%>
                    <mercury:nl />

                    <c:if test="${showNavBarFullWith and ((not empty cms.elementsInContainers['header-visual-top']) or cms.modelGroupElement or not cms.element.modelGroup)}">
                        <div class="visual-top-bg"><%----%>
                            <c:set target="${settings}" property="cssWrapper"         value="header-visual no-default-margin" />
                            <c:set target="${settings}" property="showImageLink"      value="false" />
                            <mercury:container type="header-visual" name="header-visual-top" css="container" title="${value.Title}" settings="${settings}" />
                        </div><%----%>
                        <mercury:nl />
                    </c:if>

                    <c:if test="${showTopVisual}">
                        <div class="nav-main-bg pull-up-fixed"><%----%>
                            <div class="container"><%----%>
                                <mercury:container type="nav-main" name="navbar" css="nav-main-container" title="${value.Title}" />
                            </div><%----%>
                        </div><%----%>
                        <mercury:nl />
                    </c:if>

                </div><%----%>
            </div><%----%>
            <mercury:nl />

            <c:if test="${showBreadcrumbs and ((not empty cms.elementsInContainers['breadcrumbs']) or cms.modelGroupElement or not cms.element.modelGroup)}">
                <div class="breadcrumbs-bg">
                    <mercury:container type="nav-breadcrumbs" name="breadcrumbs" css="container" title="${value.Title}" />
                </div>
                <mercury:nl />
            </c:if>

        </header><%----%>
        <mercury:nl />
    </c:when>

    <c:when test="${variant eq 'foot-v1'}">
        <mercury:nl />
        <footer class="area-foot ${cssWrapper}"><%----%>

            <div class="topfoot"><%----%>
                <mercury:container type="row" name="topfoot" css="container" title="${value.Title}" />
            </div><%----%>
            <div class="subfoot no-external"><%----%>
                <mercury:container type="row" name="subfoot" css="container" title="${value.Title}" />
            </div><%----%>

        </footer><%----%>
        <mercury:nl />
    </c:when>

    <c:when test="${variant eq 'foot-v2'}">
        <mercury:nl />
        <footer class="area-foot ${cssWrapper}"><%----%>

            <div class="subfoot no-external"><%----%>
                <mercury:container type="row" name="subfoot" css="container" title="${value.Title}" />
            </div><%----%>

        </footer><%----%>
        <mercury:nl />
    </c:when>

    <c:when test="${variant eq 'side-group'}">
        <mercury:nl />
            <mercury:container type="element" name="side-group" css="side-group" title="${value.Title}" />
        <mercury:nl />
    </c:when>

    <c:otherwise>
        <mercury:alert type="error">
            <jsp:attribute name="head">
                <fmt:message key="msg.page.layout.group.nomatch.title">
                    <fmt:param>${value.Title}</fmt:param>
                </fmt:message>
            </jsp:attribute>
            <jsp:attribute name="text">
                <fmt:message key="msg.page.layout.group.nomatch.text" />
            </jsp:attribute>
        </mercury:alert>
    </c:otherwise>

</c:choose>

<mercury:container-box label="${value.Title}" boxType="model-end" />

</c:if>

</cms:formatter>
</cms:bundle>