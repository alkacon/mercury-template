<%@tag pageEncoding="UTF-8"
    display-name="layout-group"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates markup for the layout group." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The XML content to use for layout group generation."%>

<%@ attribute name="useAdditionalVariant" type="java.lang.Boolean" required="false"
    description="Check that can be performed on the calling page to decide if the addition is rendered." %>

<%@ attribute name="additionalVariant" fragment="true" required="false"
    description="Markup for additional variantes to generate in case 'useAdditionalVariants' is true." %>


<%@ variable name-given="setting" declare="true"
    description="The settings of the current element (cms.element.setting)." %>

<%@ variable name-given="cssWrapper" declare="true"
    description="The string value of the 'cssWrapper' setting of the current element (cms.element.setting.cssWrapper.toString).
    If this is set, an additional white space ' ' will be added automatically as prefix." %>

<%@ variable name-given="noWrapper" declare="true"
    description="A map where only the 'cssWrapper' setting is defined.
    If this is passed to a nested container, the 'cssWrapper' setting will not be shown in the element settings dialog." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="value"              value="${content.value}" />
<c:set var="variant"            value="${value.Variant}" />
<c:set var="setting"            value="${cms.element.setting}" />
<c:set var="cssWrapper"         value="${setting.cssWrapper.isSet ? ' '.concat(cms.element.settings.cssWrapper) : ''}" />

<c:set var="noWrapper"          value="${{'cssWrapper': ''}}" />

<c:set var="isSideGroup"        value="${variant eq 'side-group'}" />
<c:set var="isSideContainer"    value="${fn:contains(cms.container.type, 'side-group')}" />

<c:if test="${(isSideGroup and isSideContainer) or (not isSideGroup and not isSideContainer)}">

<m:container-box label="${value.Title}" boxType="model-start" />

<c:choose>

    <c:when test="${useAdditionalVariant}">
        <jsp:invoke fragment="additionalVariant" />
    </c:when>

    <c:when test="${variant eq 'head-flex-bc'}">

        <c:set var="showBreadcrumbs"            value="${setting.showBreadcrumbs.useDefault(true).toBoolean}" />
        <c:set var="addBottomMargin"            value="${setting.addBottomMargin.useDefault(true).toBoolean}" />

        <c:set var="showConfigElement"          value="${cms.isEditMode and ((cms.element.modelGroup and cms.modelGroupElement) or (not cms.element.modelGroup))}" />
        <c:set var="configElement">
            <c:if test="${showConfigElement}">
                <c:set var="headerConfigTypeName"><fmt:message key="function.header-config" /></c:set>
                <m:container
                    type="header-config"
                    name="header-config"
                    title="${value.Title}"
                />
            </c:if>
        </c:set>

        <c:set var="headerConfigElementBeans" value="${cms.elementBeansInContainers['header-config']}" />

        <c:choose>
            <c:when test="${not empty headerConfigElementBeans}">

                <c:set var="config"             value="${headerConfigElementBeans.get(0)}" />
                <c:set var="addCssWrapper"      value="${config.setting.cssWrapper.toString}" />

                <c:set var="logoAlignment"      value="${config.setting.logoAlignment.validate(['lp-l','lp-c','lp-r','none'],'lp-l').toString}" />
                <c:set var="logoHidden"         value="${logoAlignment eq 'none'}" />
                <c:set var="logoSize"           value="${logoHidden ? 'ls-0' : config.setting.logoSize.useDefault('ls-4').toString}" />
                <c:set var="logoFullSize"       value="${not logoHidden and logoSize eq 'ls-12'}" />
                <c:set var="logoPosCenter"      value="${logoHidden or logoFullSize or (logoAlignment eq 'lp-c')}" />
                <c:set var="logoPosLeft"        value="${logoHidden or logoPosCenter ? false : (logoAlignment eq 'lp-l')}" />
                <c:set var="logoAlignment"      value="${logoHidden or logoPosCenter ? 'lp-c' : logoAlignment}" />
                <c:set var="logoCols"           value="${fn:substringAfter(logoSize, 'ls-')}" />
                <c:set var="alignDefault"       value="${logoPosCenter ? 'center' : (logoPosLeft ? 'right' : 'left')}" />
                <c:set var="logoPadding"        value="${config.setting.logoPadding.useDefault('pad-sm').toString}" />
                <c:set var="showMeta"           value="${config.setting.metaDisplay.toString ne 'hide-meta'}" />
                <c:set var="metaAlignment"      value="${config.setting.metaAlignment.validate(['default','meta-left','meta-center','meta-right'],'default').toString}" />
                <c:set var="metaAlignment"      value="${metaAlignment eq 'default' ? 'meta-'.concat(alignDefault) : metaAlignment}" />
                <c:set var="metaPosition"       value="${logoPosCenter ? 'meta-above' : config.setting.metaPosition.useDefault('meta-aside').toString}" />
                <c:set var="showTitle"          value="${(config.setting.showTitle.toString ne 'hide-title')}" />
                <c:set var="showTitleMobile"    value="${config.setting.showTitle.toString eq 'show-title-mobile'}" />
                <c:set var="titleAlignment"     value="${config.setting.titleAlignment.useDefault('title-right').toString}" />
                <c:set var="titleAlignment"     value="${titleAlignment eq 'default' ? 'title-default' : titleAlignment}" />
                <c:set var="titlePosition"      value="${config.setting.titlePosition.useDefault('title-middle').toString}" />
                <c:set var="navAlignment"       value="${config.setting.navAlignment.useDefault('nav-right').toString}" />
                <c:set var="navAlignment"       value="${navAlignment eq 'default' ? 'nav-'.concat(alignDefault) : navAlignment}" />
                <c:set var="navPosition"        value="${logoPosCenter ? 'nav-below' : config.setting.navPosition.useDefault('nav-aside').toString}" />
                <c:set var="navDisplay"         value="${config.setting.navDisplay.useDefault('nav-disp-default').toString}" />
                <c:set var="navPullUp"          value="${config.setting.navPullUp.useDefault('np-never').toString}" />
                <c:set var="navFixType"         value="${config.setting.headerPosition.useDefault('css').toString}" />
                <c:set var="navFixDisplay"      value="${config.setting.navFixDisplay.validate(['fix-complete fix-ac','fix-complete','fix-compact','fix-overlay'],'fix-compact').toString}" />
                <c:set var="navFixDisplay"      value="${logoPosCenter ? ((navFixDisplay eq 'fix-overlay') ? 'fix-complete' : navFixDisplay) : navFixDisplay}" />
                <c:set var="acDisplay"          value="${config.setting.acDisplay.useDefault('none').toString}" />
                <c:set var="acPosition"         value="${config.setting.acPosition.validate(['ac-above-logo','ac-below-logo','ac-below-nav'],'ac-below-logo').toString}" />
                <c:set var="bcDisplay"          value="${config.setting.bcDisplay.useDefault('bc-show').toString}" />
                <c:set var="bcAlignment"        value="${config.setting.bcAlignment.useDefault('bc-left').toString}" />
                <c:set var="showBreadcrumbs"    value="${showBreadcrumbs and (bcDisplay eq 'bc-show')}" />
                <c:set var="bcAlignment"        value="${not showBreadcrumbs ? 'bc-hide' : bcAlignment}" />

                <c:set var="showNavAside"       value="${not logoPosCenter and (navPosition ne 'nav-below')}" />
                <c:set var="showMetaAside"      value="${not logoPosCenter and showMeta and (metaPosition ne 'meta-above')}" />
                <c:set var="showOnlyNavAside"   value="${showNavAside and not showMetaAside and not showTitle}" />
                <c:set var="needInfoCol"        value="${not logoPosCenter}" />
                <c:set var="needNavPull"        value="${not showNavAside and (navPullUp ne 'np-never')}" />
                <c:set var="needTitlePosition"  value="${showTitle and (titlePosition ne 'title-center')}" />
                <c:set var="showTitleAside"     value="${not logoPosCenter}" />
                <c:set var="showAddContainer"   value="${acDisplay ne 'none'}" />
                <c:set var="acHasPageSize"      value="${showAddContainer and (acDisplay.contains('ac-page-size'))}" />
                <c:set var="acOnMobile"         value="${showAddContainer and (acDisplay.contains('ac-mobile'))}" />

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
                    <div id="nav-toggle-group"><%----%>
                        <span id="nav-toggle-label"><%----%>
                            <button class="nav-toggle-btn" aria-expanded="false" aria-controls="nav-toggle-group"><%----%>
                                <span class="nav-toggle"><%----%>
                                    <span class="nav-burger"><fmt:message key="msg.page.navigation.toggle" /></span><%----%>
                                </span><%----%>
                            </button><%----%>
                        </span><%----%>
                    </div><%----%>
                    <m:nl />
                </c:set>

                <%--
                    Attention: The order in which the containers are created here
                    MUST match the order in which they are displayed below!
                    The Flex cache will output the containers correctly only in the order they have been created.
                    This is why the logoElement is duplicated before / after the meta link element.
                --%>

                <c:if test="${showMetaAside}">
                    <c:set var="logoElement">
                        <c:set var="sectionTypeName"><fmt:message key="type.m-section.name" /></c:set>
                        <m:container
                            type="image-minimal"
                            name="header-image"
                            css="h-logo p-xs-12 p-lg-${logoCols}"
                            title="${value.Title}"
                            settings="${{
                                'cssWrapper':       'header-image',
                                'showImageLink':    'true'
                            }}"
                        />
                    </c:set>
                </c:if>

                <c:set var="metaLinkElement">
                    <c:if test="${showMeta}">
                        <m:div css="h-meta" test="${not showMetaAside}">
                            <c:set var="linksequenceTypeName"><fmt:message key="type.m-linksequence.name" /></c:set>
                            <m:container
                                type="linksequence-header"
                                name="header-linksequence"
                                css="${not showMetaAside ? 'co-lg-xl' : 'h-meta'}"
                                title="${value.Title}"
                                settings="${{
                                    'cssWrapper':       'header-links',
                                    'linksequenceType': 'ls-row',
                                    'hsize' :           '0'
                                }}"
                            />
                        </m:div>
                    </c:if>
                </c:set>

                <c:if test="${not showMetaAside}">
                    <c:set var="logoElement">
                        <c:set var="sectionTypeName"><fmt:message key="type.m-section.name" /></c:set>
                        <m:container
                            type="image-minimal"
                            name="header-image"
                            css="${logoHidden ? 'h-logo' : 'h-logo p-xs-12 p-lg-'.concat(logoCols)}"
                            title="${value.Title}"
                            settings="${{
                                'cssWrapper':       logoHidden ? 'no-image' : 'header-image',
                                'showImageLink':    'true'
                            }}"
                        />
                    </c:set>
                </c:if>

                <c:set var="titleElement">
                    <c:if test="${showTitle}">
                        <c:set var="imageElements" value="${cms.elementsInContainers['header-image']}" />
                        <c:if test="${not empty imageElements}">
                            <c:set var="imageContent" value="${imageElements.get(0).toXml}" />
                            <c:set var="pageTitle" value="${imageContent.value.Title.resolveMacros}" />
                            <c:if test="${fn:contains(pageTitle, '%(cms.title)')}">
                                <c:choose>
                                   <c:when test="${cms.detailRequest and not empty cms.meta.ogTitle}">
                                        <c:set var="rval" value="${cms.meta.ogTitle}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="rval" value="${cms.title}" />
                                    </c:otherwise>
                                </c:choose>
                                <c:set var="pageTitle" value="${fn:replace(pageTitle, '%(cms.title)', rval)}" />
                            </c:if>
                            <c:if test="${fn:contains(pageTitle, '%(cms.subSiteTitle)')}">
                                <c:set var="cS"        value="${cms.vfs.readSubsiteFor(cms.requestContext.uri)}" />
                                <c:set var="cSP"       value="${cms.vfs.readProperties[cS]}" />
                                <c:set var="rval"      value="${not empty cSP['mercury.sitename'] ? cSP['mercury.sitename'] : cSP['Title'] }" />
                                <c:set var="pageTitle" value="${fn:replace(pageTitle, '%(cms.subSiteTitle)', rval)}" />
                            </c:if>
                            <c:if test="${fn:contains(pageTitle, '%(cms.siteTitle)')}">
                                <c:set var="cS"        value="${cms.vfs.readSubsiteFor('/')}" />
                                <c:set var="cSP"       value="${cms.vfs.readProperties[cS]}" />
                                <c:set var="rval"      value="${not empty cSP['mercury.sitename'] ? cSP['mercury.sitename'] : cSP['Title'] }" />
                                <c:set var="pageTitle" value="${fn:replace(pageTitle, '%(cms.siteTitle)', rval)}" />
                            </c:if>
                            <m:div css="h-title" test="${not showTitleAside}">
                                <m:heading level="${7}" text="${pageTitle}" css="${not showTitleAside ? 'co-lg-xl' : 'h-title'}" ade="${false}" decorate="${false}" />
                            </m:div>
                        </c:if>
                    </c:if>
                </c:set>

                <c:set var="navBarElement">
                     <div class="h-nav"><%----%>
                        <m:div css="co-lg-xl" test="${not showNavAside}">
                            <c:set var="navTypeName"><fmt:message key="type.m-navigation.name" /></c:set>
                            <m:container
                                type="nav-main"
                                name="header-nav-main"
                                css="nav-main-container"
                                title="${value.Title}"
                                settings="${{
                                    'cssWrapper':       logoHidden ? 'no-image' : '',
                                    'configVariant':    'default'
                                }}"
                            />
                        </m:div>
                    </div><%----%>
                    <m:nl />
                </c:set>

                <c:if test="${showAddContainer}">
                    <c:set var="addContainerElement">
                        <m:div css="h-ac" test="${acHasPageSize}">
                            <c:if test="${not acHasPageSize}">
                                <c:set var="acParams" value="${{'cssgrid': 'fullwidth'}}" />
                            </c:if>
                            <m:container
                                type="row"
                                name="header-container"
                                parameters="${acParams}"
                                css="${acHasPageSize ? (acOnMobile ? 'container' : 'co-lg-xl p-xs-12') : 'h-ac'}"
                                title="${value.Title}"
                            />
                        </m:div>
                    </c:set>
                </c:if>

                <c:set var="breadcrumbElement">
                    <c:if test="${showBreadcrumbs and ((not empty cms.elementsInContainers['breadcrumbs']) or cms.modelGroupElement or not cms.element.modelGroup)}">
                        <div class="h-bc"><%----%>
                            <c:set var="navTypeName"><fmt:message key="type.m-navigation.name" /></c:set>
                            <m:container
                                type="nav-breadcrumbs"
                                name="header-breadcrumbs"
                                css="container"
                                title="${value.Title}"
                                settings="${noWrapper}"
                            />
                        </div><%----%>
                        <m:nl />
                    </c:if>
                </c:set>

                <m:nl />
                <header class="area-header fh header-notfixed <%----%>
                    ${logoAlignment}${' '}
                    ${logoSize}${' '}
                    ${logoPadding}${' '}
                    ${showMeta ? metaPosition.concat(' ').concat(metaAlignment.concat(' ')) : ''}
                    ${showTitle ? titleAlignment.concat(' ') : ''}
                    ${showTitleMobile ? 'title-mobile ' : ''}
                    ${needTitlePosition ? titlePosition.concat(' ') : ''}
                    ${navDisplay}${' '}
                    ${navAlignment}${' '}
                    ${showOnlyNavAside ? 'nav-only ' : ''}
                    ${navPosition}${' '}
                    ${needNavPull ? navPullUp.concat(' ') : ''}
                    ${navFixDisplay}${' '}
                    ${showAddContainer ? acDisplay.concat(' ').concat(acPosition.concat(' ')) : ''}
                    ${bcAlignment}
                    ${addBottomMargin ? ' has-margin' : ' no-margin'}
                    ${cssWrapper}
                    ${not empty addCssWrapper ? ' '.concat(addCssWrapper) : ''}"><%----%>
                    <m:nl />

                    ${configElement}

                    ${navToggleElement}

                    <div class="header-group co-sm-md ${fixHeader}"><%----%>

                        <div class="head notfixed"><%----%>
                            <div class="head-overlay"></div><%----%>
                            <m:nl />

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
                    <m:nl />

                    ${breadcrumbElement}

                </header><%----%>
                <m:nl />

            </c:when>

            <c:when test="${showConfigElement}">
                <m:nl />
                <header class="area-header fh title-center">

                    ${configElement}

                    <m:alert type="warning">
                        <jsp:attribute name="head">
                            <fmt:message key="msg.page.header.no-config" />
                        </jsp:attribute>
                        <jsp:attribute name="text">
                            <fmt:message key="msg.page.header.no-config.help" />
                        </jsp:attribute>
                    </m:alert>

                </header>
                <m:nl />
            </c:when>

            <c:when test="${cms.isEditMode}">

                <m:alert type="error">
                    <jsp:attribute name="head">
                        ${cms.reloadMarker}
                        <fmt:message key="msg.page.mustReload" />
                    </jsp:attribute>
                    <jsp:attribute name="text">
                        <fmt:message key="msg.page.mustReload.hint2" />
                    </jsp:attribute>
                </m:alert>

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

        <c:set var="headerPosition"     value="${setting.headerPosition.validate(['css','upscroll','fixed','static'],'css').toString}" />
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

        <m:nl />
        <header class="area-header logo-left${cssWrapper}"><%----%>
            <m:nl />

            <div id="nav-toggle-group"><%----%>
                <span id="nav-toggle-label"><%----%>
                    <button class="nav-toggle-btn" aria-expanded="false" aria-controls="nav-toggle-group"><%----%>
                        <span class="nav-toggle"><%----%>
                            <span class="nav-burger"><fmt:message key="msg.page.navigation.toggle" /></span><%----%>
                        </span><%----%>
                    </button><%----%>
                </span><%----%>
                <div class="head-overlay"></div><%----%>
            </div><%----%>
            <m:nl />

            <div class="header-group ${fixHeader}"><%----%>
                <div class="head notfixed"><%----%>

                    <m:nl />
                    <div class="container"><%----%>
                        <div class="row"><%----%>

                            <m:container
                                type="image-minimal"
                                name="header-image"
                                css="col col-head-logo"
                                title="${value.Title}"
                                settings="${{
                                    'cssWrapper':       'header-image',
                                    'showImageLink':    'true'
                                }}"
                            />

                            <div class="col col-head-info"><%----%>
                                <m:container
                                    type="linksequence"
                                    name="header-linksequence"
                                    css="header-links-bg"
                                    title="${value.Title}"
                                    settings="${{
                                        'cssWrapper':       'header-links',
                                        'linksequenceType': 'ls-row',
                                        'iconClass':        'none',
                                        'hsize' :           '0'
                                    }}"
                                />

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
                                    <m:heading level="${7}" text="${pageTitle}" css="header-title hidden-fixed" ade="${false}" decorate="${false}" />
                                </c:if>

                                <c:if test="${not showNavBarFullWith}">
                                    <m:container
                                        type="nav-main"
                                        name="navbar"
                                        css="nav-main-container"
                                        title="${value.Title}"
                                    />
                                </c:if>

                            </div><%----%>
                            <m:nl />

                        </div><%----%>
                    </div><%----%>
                    <m:nl />

                    <c:if test="${showNavBarFullWith and ((not empty cms.elementsInContainers['header-visual-top']) or cms.modelGroupElement or not cms.element.modelGroup)}">
                        <div class="visual-top-bg"><%----%>
                            <m:container
                                type="header-visual"
                                name="header-visual-top"
                                css="container"
                                title="${value.Title}"
                                settings="${{
                                    'cssWrapper':       'header-visual no-default-margin',
                                    'showImageLink':    'false'
                                }}"
                            />
                        </div><%----%>
                        <m:nl />
                    </c:if>

                    <c:if test="${showTopVisual}">
                        <div class="nav-main-bg pull-up-fixed"><%----%>
                            <div class="container"><%----%>
                                <m:container
                                    type="nav-main"
                                    name="navbar"
                                    css="nav-main-container"
                                    title="${value.Title}"
                                />
                            </div><%----%>
                        </div><%----%>
                        <m:nl />
                    </c:if>

                </div><%----%>
            </div><%----%>
            <m:nl />

            <c:if test="${showBreadcrumbs and ((not empty cms.elementsInContainers['breadcrumbs']) or cms.modelGroupElement or not cms.element.modelGroup)}">
                <div class="breadcrumbs-bg">
                    <m:container
                        type="nav-breadcrumbs"
                        name="breadcrumbs"
                        css="container"
                        title="${value.Title}"
                    />
                </div>
                <m:nl />
            </c:if>

        </header><%----%>
        <m:nl />
    </c:when>

    <c:when test="${variant eq 'foot-v1'}">
        <m:nl />
        <footer class="area-foot${cssWrapper}"><%----%>

            <div class="topfoot"><%----%>
                <m:container
                    type="row"
                    name="topfoot"
                    css="container area-wide"
                    title="${value.Title}"
                />
            </div><%----%>
            <div class="subfoot no-external"><%----%>
                <m:container
                    type="row"
                    name="subfoot"
                    css="container area-wide"
                    title="${value.Title}"
                />
            </div><%----%>

        </footer><%----%>
        <m:nl />
    </c:when>

    <c:when test="${variant eq 'foot-v2'}">
        <m:nl />
        <footer class="area-foot${cssWrapper}"><%----%>

            <div class="subfoot no-external"><%----%>
                <m:container
                    type="row"
                    name="subfoot"
                    css="container area-wide"
                    title="${value.Title}"
                />
            </div><%----%>

        </footer><%----%>
        <m:nl />
    </c:when>

    <c:when test="${variant eq 'side-group'}">
        <m:nl />
            <m:container
                type="element"
                name="side-group"
                css="side-group"
                title="${value.Title}"
            />
        <m:nl />
    </c:when>

    <c:otherwise>
        <m:alert type="error">
            <jsp:attribute name="head">
                <fmt:message key="msg.page.layout.group.nomatch.title">
                    <fmt:param>${value.Title}</fmt:param>
                </fmt:message>
            </jsp:attribute>
            <jsp:attribute name="text">
                <fmt:message key="msg.page.layout.group.nomatch.text" />
            </jsp:attribute>
        </m:alert>
    </c:otherwise>

</c:choose>

<m:container-box label="${value.Title}" boxType="model-end" />

</c:if>

</cms:bundle>