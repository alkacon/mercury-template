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


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<cms:formatter var="content" val="value">

<mercury:layout-group
    content="${content}"
    useAdditionalVariant="${value.Variant eq 'head-flex-bc'}">

    <jsp:attribute name="additionalVariant">

        <c:set var="showBreadcrumbs"            value="${setting.showBreadcrumbs.useDefault(true).toBoolean}" />
        <c:set var="addBottomMargin"            value="${setting.addBottomMargin.useDefault(true).toBoolean}" />

        <c:set var="showConfigElement"          value="${cms.isEditMode and ((cms.element.modelGroup and cms.modelGroupElement) or (not cms.element.modelGroup))}" />
        <c:set var="configElement">
            <c:if test="${showConfigElement}">
                <mercury:container type="header-config" name="header-config" title="${value.Title}" />
            </c:if>
        </c:set>

        <c:set var="headerConfigElementBeans"   value="${cms.elementBeansInContainers['header-config']}" />

        <c:choose>
            <c:when test="${not empty headerConfigElementBeans}">

                <c:set var="config"             value="${headerConfigElementBeans.get(0)}" />

                <c:set var="addCssWrapper"      value="${config.setting.cssWrapper.toString}" />

                <c:set var="logoAlignment"      value="${config.setting.logoAlignment.validate(['lp-l','lp-r','none'],'lp-l').toString}" />
                <c:set var="logoHidden"         value="${logoAlignment eq 'none'}" />

                <c:set var="showTitle"          value="${config.setting.showTitle.validate(['show-title','ac-title','hide-title'],'show-title').toString}" />
                <c:set var="titleAlignment"     value="${config.setting.titleAlignment.useDefault('title-right').toString}" />
                <c:set var="titleAlignment"     value="${logoHidden
                                                        ? (titleAlignment eq 'title-left' ? titleAlignment : 'title-right' )
                                                        : (titleAlignment ne 'default'    ? titleAlignment : 'title-default' )}" />

                <c:set var="logoAlignment"      value="${logoHidden ? (titleAlignment eq 'title-right' ? 'lp-l' : 'lp-r') : logoAlignment}" />
                <c:set var="logoPosLeft"        value="${logoAlignment eq 'lp-l'}" />
                <c:set var="logoSize"           value="${logoHidden ? 'ls-0' : config.setting.logoSize.useDefault('ls-4').toString}" />
                <c:set var="logoFullSize"       value="${logoSize eq 'ls-12'}" />
                <c:set var="logoCols"           value="${fn:substringAfter(logoSize, 'ls-')}" />
                <c:set var="alignDefault"       value="${logoPosLeft ? 'left' : 'right'}" />

                <c:set var="showMeta"           value="${config.setting.metaDisplay.toString ne 'hide-meta'}" />
                <c:set var="metaAlignment"      value="${config.setting.metaAlignment.validate(['default','meta-left','meta-right'],'default').toString}" />
                <c:set var="metaAlignment"      value="${metaAlignment eq 'default' ? 'meta-'.concat(alignDefault) : metaAlignment}" />
                <c:set var="metaPosition"       value="meta-above" />

                <c:set var="bcDisplay"          value="${config.setting.bcDisplay.useDefault('bc-show').toString}" />
                <c:set var="bcAlignment"        value="${config.setting.bcAlignment.useDefault('bc-left').toString}" />
                <c:set var="showBreadcrumbs"    value="${showBreadcrumbs and (bcDisplay eq 'bc-show')}" />
                <c:set var="bcAlignment"        value="${not showBreadcrumbs ? 'bc-hide' : bcAlignment}" />
                <c:set var="bcIncludeHidden"    value="${config.setting.breadcrumbsIncludeHidden.toBoolean}" />
                <c:set var="bcFromRoot"         value="${config.setting.breadcrumbsFromRoot.toBoolean}" />

                <c:set var="acDisplay"          value="${config.setting.acDisplay.useDefault('none').toString}" />
                <c:set var="acPosition"         value="${config.setting.acPosition.validate(['ac-above-logo','ac-below-logo'],'ac-below-logo').toString}" />
                <c:set var="showAddContainer"   value="${acDisplay ne 'none'}" />
                <c:set var="acHasPageSize"      value="${showAddContainer and (acDisplay.contains('ac-page-size'))}" />

                <c:set var="navFixType"         value="${config.setting.headerPosition.validate(['css','upscroll','static'],'css').toString}" />
                <c:choose>
                    <c:when test="${navFixType eq 'upscroll'}" >
                        <c:set var="fixHeader" value="sticky upscroll" />
                    </c:when>
                    <c:otherwise>
                        <c:set var="fixHeader" value="sticky csssetting" />
                    </c:otherwise>
                </c:choose>
                <c:set var="navFixDisplay"      value="${navFixType ne 'static' ? config.setting.navFixDisplay.validate(['fix-lg','fix-md','fix-sm','fix-xs'],'fix-lg').toString : 'fix-never'}" />

                <%--
                    Attention: The order in which the containers are created here
                    MUST match the order in which they are displayed below!
                    The Flex cache will output the containers correctly only in the order they have been created.
                    This is why the logoElement is duplicated before / after the meta link element.
                --%>

                <c:set var="metaLinkElement">
                    <c:if test="${showMeta}">
                        <div class="h-meta"><%----%>
                            <mercury:container
                                type="linksequence-header"
                                name="header-linksequence"
                                css="container"
                                title="${value.Title}"
                                settings="${{
                                    'cssWrapper':       'header-links',
                                    'linksequenceType': 'ls-row',
                                    'hsize' :           '0'
                                }}"
                            />
                        </div><%----%>
                    </c:if>
                </c:set>

                <c:set var="logoElement">
                    <mercury:container
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

                <c:if test="${showTitle ne 'hide-title'}">
                    <c:set var="imageElements" value="${cms.elementsInContainers['header-image']}" />
                    <c:if test="${not empty imageElements}">

                        <c:set var="imageContent" value="${imageElements.get(0).toXml}" />

                        <c:set var="pageTitle" value="${imageContent.value.Title.resolveMacros}" />
                        <c:choose>
                            <c:when test="${fn:contains(pageTitle, '%(cms.title)')}">
                                <c:choose>
                                   <c:when test="${cms.detailRequest and not empty cms.meta.ogTitle}">
                                        <c:set var="rval" value="${cms.meta.ogTitle}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="rval" value="${cms.title}" />
                                    </c:otherwise>
                                </c:choose>
                                <c:set var="pageTitle" value="${fn:replace(pageTitle, '%(cms.title)', rval)}" />
                            </c:when>
                            <c:when test="${fn:contains(pageTitle, '%(cms.subSiteTitle)')}">
                                <c:set var="cS"        value="${cms.vfs.readSubsiteFor(cms.requestContext.uri)}" />
                                <c:set var="cSP"       value="${cms.vfs.readProperties[cS]}" />
                                <c:set var="rval"      value="${not empty cSP['mercury.sitename'] ? cSP['mercury.sitename'] : cSP['Title'] }" />
                                <c:set var="pageTitle" value="${fn:replace(pageTitle, '%(cms.subSiteTitle)', rval)}" />
                            </c:when>
                            <c:when test="${fn:contains(pageTitle, '%(cms.siteTitle)')}">
                                <c:set var="cS"        value="${cms.vfs.readSubsiteFor('/')}" />
                                <c:set var="cSP"       value="${cms.vfs.readProperties[cS]}" />
                                <c:set var="rval"      value="${not empty cSP['mercury.sitename'] ? cSP['mercury.sitename'] : cSP['Title'] }" />
                                <c:set var="pageTitle" value="${fn:replace(pageTitle, '%(cms.siteTitle)', rval)}" />
                            </c:when>
                        </c:choose>

                        <mercury:image-vars image="${imageContent.value.Image}">
                            <c:if test="${not empty imageHeight}">
                                <c:set var="ir" value="${imageHeight / imageWidth}" />
                                <c:choose>
                                    <c:when test="${ir > 1.2}">
                                        <c:set var="logoSizeRatio" value="lsr-12" />
                                    </c:when>
                                    <c:when test="${ir > 0.8}">
                                        <c:set var="logoSizeRatio" value="lsr-08" />
                                    </c:when>
                                    <c:when test="${ir > 0.4}">
                                        <c:set var="logoSizeRatio" value="lsr-04" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="logoSizeRatio" value="lsr-wide" />
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </mercury:image-vars>
                    </c:if>
                    <c:if test="${not empty pageTitle}">
                        <c:set var="titleElement">
                            <mercury:heading level="${7}" ade="false" text="${pageTitle}" css="h-title" />
                        </c:set>
                    </c:if>
                </c:if>

                <c:if test="${showAddContainer}">
                    <c:set var="addContainerElement">
                        <div class="h-ac hidden-fixed"><%----%>
                            <div class="h-ac-co ${acHasPageSize ? 'container p-xs-12' : ''}"><%----%>
                                <c:if test="${(showTitle eq 'ac-title') and not empty pageTitle}">
                                    <mercury:heading level="${7}" ade="false" text="${pageTitle}" css="h-ac-title container" />
                                </c:if>
                                <mercury:container
                                    type="row"
                                    name="header-container"
                                    css="h-ac-element"
                                    title="${value.Title}" />
                            </div><%----%>
                        </div><%----%>
                    </c:set>
                </c:if>

                <c:set var="breadcrumbElement">
                    <c:set var="navgationElements" value="${cms.elementsInContainers['header-nav-main']}" />
                    <c:if test="${showBreadcrumbs and not empty navgationElements}">
                        <div class="h-bc"><%----%>
                            <c:set var="navContentPath" value="${navgationElements.get(0).sitePath}" />
                            <div class="container"><%----%>
                                <mercury:display
                                    file="${navContentPath}"
                                    formatter="%(link.weak:/system/modules/alkacon.mercury.template/formatters/navigation/breadcrumbs.xml:944e72a0-4e06-11e9-bf9f-0242ac11002b)"
                                    settings="${{
                                        'cssWrapper':               '',
                                        'breadcrumbsIncludeHidden': bcIncludeHidden,
                                        'breadcrumbsFromRoot':      bcFromRoot
                                    }}"
                                />
                            </div>
                        </div><%----%>
                        <mercury:nl />
                    </c:if>
                </c:set>

                <c:set var="navElement">
                    <mercury:nl />
                    <div class="h-nav" id="nav-toggle-group"><%----%>
                        <mercury:container
                            type="nav-main"
                            name="header-nav-main"
                            css="nav-main-container"
                            title="${value.Title}"
                            settings="${{
                                'cssWrapper':       logoHidden ? 'no-image' : '',
                                'showSearch':       'false',
                                'configVariant':    'burger'
                            }}"
                        />
                        <mercury:nl />
                        <div class="head-overlay"></div><%----%>
                        <mercury:nl />
                    </div><%----%>
                    <mercury:nl />
                </c:set>

                <mercury:nl />
                <header class="area-header bh header-notfixed <%----%>
                    ${logoAlignment}${' '}
                    ${logoSize}${' '}
                    ${logoSizeRatio}${' '}
                    ${logoFullSize ? '' : 'ls-col '}
                    ${showTitle}${' '}
                    ${showTitle ne 'hide-title' ? titleAlignment.concat(' ') : ''}
                    ${showMeta ? metaPosition.concat(' ').concat(metaAlignment.concat(' ')) : ''}
                    ${navDisplay}${' '}
                    ${not empty navFixDisplay ? navFixDisplay.concat(' ') : ''}
                    ${showAddContainer ? acDisplay.concat(' ').concat(acPosition.concat(' ')) : ''}
                    ${bcAlignment}
                    ${addBottomMargin ? ' has-margin' : ' no-margin'}
                    ${cssWrapper}
                    ${not empty addCssWrapper ? ' '.concat(addCssWrapper) : ''}"><%----%>
                    <mercury:nl />

                    ${configElement}

                    <div class="header-group ${fixHeader}"><%----%>

                        <div class="head notfixed"><%----%>

                            <mercury:nl />

                            <%--
                                Attention: The order in which the containers have been created above
                                MUST match the order in which they are displayed here!
                                The Flex cache will output the containers correctly only in the order they have been created.
                            --%>

                            ${metaLinkElement}

                            <div class="h-logo-row container"><%----%>

                                <div class="h-logo-col"><%----%>
                                    ${logoElement}
                                </div><%----%>

                                <c:if test="${not empty titleElement}">
                                    <div class="h-title-col"><%----%>
                                        ${titleElement}
                                    </div><%----%>
                                </c:if>

                                <div class="h-toggle-col"><%----%>
                                    <span id="nav-toggle-label-open" class="nav-toggle-label"><%----%>
                                        <button class="nav-toggle" aria-expanded="false" aria-controls="nav-toggle-group"><%----%>
                                            <span><fmt:message key="msg.page.navigation.toggle" /></span><%----%>
                                        </button><%----%>
                                    </span><%----%>
                                </div><%----%>

                            </div><%----%>

                            <c:if test="${(not empty titleElement) and (showTitle eq 'show-title')}">
                                <div class="h-title-row"><%----%>
                                    <div class="container">
                                        ${titleElement}
                                    </div>
                                </div><%----%>
                            </c:if>

                            <c:if test="${showAddContainer}">
                                ${addContainerElement}
                            </c:if>

                        </div><%----%>

                    </div><%----%>
                    <mercury:nl />

                    ${breadcrumbElement}

                    ${navElement}

                </header><%----%>
                <mercury:nl />

            </c:when>

            <c:when test="${showConfigElement}">
                <fmt:setLocale value="${cms.workplaceLocale}" />
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
                <fmt:setLocale value="${cms.workplaceLocale}" />
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

    </jsp:attribute>

</mercury:layout-group>

</cms:formatter>
</cms:bundle>