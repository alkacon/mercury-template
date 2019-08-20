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

<c:set var="variant"            value="${value.Variant}" />
<c:set var="setting"            value="${cms.element.setting}" />
<c:set var="cssWrapper"         value="${cms.element.settings.cssWrapper}" />

<jsp:useBean id="valueMap"      class="java.util.HashMap" />
<jsp:useBean id="params"        class="java.util.HashMap" />
<jsp:useBean id="settings"      class="java.util.HashMap" />

<c:set var="isSideGroup"        value="${variant eq 'side-group'}" />
<c:set var="isSideContainer"    value="${fn:contains(cms.container.type, 'side-group')}" />

<c:if test="${(isSideGroup and isSideContainer) or (not isSideGroup and not isSideContainer)}">

<mercury:container-box label="${value.Title}" boxType="model-start" />

<c:choose>

    <c:when test="${variant eq 'head-flex-bc-fh'}">

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

        <c:set var="logoPosition"       value="logo-left" />
        <c:set var="logoSize"           value="logo-size-3" />

        <c:set var="navPosition"        value="side" />

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
        <header class="area-header with-logo ${logoPosition}${' '}${logoSize}${' '}${cssWrapper}"><%----%>
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

        <c:set var="logoPosition"       value="logo-left" />
        <c:set var="logoSize"           value="logo-size-3" />

        <c:set var="navPosition"        value="side" />

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
        <header class="area-header with-logo ${logoPosition}${' '}${logoSize}${' '}${cssWrapper}"><%----%>
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