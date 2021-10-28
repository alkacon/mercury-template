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

<cms:formatter var="content" val="value">

<c:set var="variant"            value="${value.Variant}" />
<c:set var="setting"            value="${cms.element.setting}" />
<c:set var="detailContainer"    value="${setting.detailContainer.toString}" />
<c:set var="cssWrapper"         value="${setting.cssWrapper.isSet ? ' '.concat(setting.cssWrapper.toString) : ''}" />
<c:set var="reverseOrder"       value="${setting.containerOrder.toString eq 'reversed'}" />

<jsp:useBean id="valueMap"      class="java.util.HashMap" />

<mercury:container-box label="${value.Title}" boxType="model-start" />

<mercury:nl />
<c:choose>
    <c:when test="${variant eq '12'}">
        <%-- lr_00001 --%>
        <c:set target="${valueMap}" property="Type"             value="element"/>
        <c:set target="${valueMap}" property="Name"             value="maincol"/>
        <c:set target="${valueMap}" property="Css"              value="row-12${cssWrapper}" />
        <c:set target="${valueMap}" property="Parameters"       value="${{'cssgrid': 'col-xs-12'}}" />
        <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'maincol'}" />
    </c:when>
    <c:when test="${variant eq '3-9'}">
        <%-- lr_00002 --%>
        <c:set var="colCss"             value="${cms.element.setting.useFlex.toBoolean ? ' flex-col' : ''}" />
        <div class="row${cssWrapper}"><%----%>
            <c:set target="${valueMap}" property="Type"         value="element"/>
            <c:set target="${valueMap}" property="Name"         value="maincol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-9${colCss}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'maincol'}" />
            <c:set target="${valueMap}" property="Name"         value="sidecol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-3 col-side ${colCss}${reverseOrder ? ' order-first' : ' order-lg-first'}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'sidecol'}" />
            <mercury:nl />
        </div><%----%>
    </c:when>
    <c:when test="${variant eq '4-8'}">
        <%-- lr_00003 --%>
        <c:set var="colCss"             value="${cms.element.setting.useFlex.toBoolean ? ' flex-col' : ''}" />
        <div class="row${cssWrapper}"><%----%>
            <c:set target="${valueMap}" property="Type"         value="element"/>
            <c:set target="${valueMap}" property="Name"         value="maincol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-8${colCss}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'maincol'}" />
            <c:set target="${valueMap}" property="Name"         value="sidecol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-4 col-side ${colCss}${reverseOrder ? ' order-first' : ' order-lg-first'}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'sidecol'}" />
            <mercury:nl />
        </div><%----%>
    </c:when>
    <c:when test="${variant eq '6-6'}">
        <%-- lr_00004 --%>
        <c:set var="colCss"             value="${cms.element.setting.useFlex.toBoolean ? ' flex-col' : ''}" />
        <div class="row${cssWrapper}"><%----%>
            <c:set target="${valueMap}" property="Type"         value="element"/>
            <c:set target="${valueMap}" property="Name"         value="maincol"/>
            <c:set target="${valueMap}" property="Css"          value="col-6${colCss}" />
            <mercury:container value="${valueMap}" title="${value.Title}" />
            <c:set target="${valueMap}" property="Name"         value="sidecol"/>
            <mercury:container value="${valueMap}" title="${value.Title}"/>
            <mercury:nl />
        </div><%----%>
    </c:when>
    <c:when test="${variant eq '6-6-sm'}">
        <%-- lr_00005 --%>
        <c:set var="colCss"            value="${cms.element.setting.useFlex.toBoolean ? ' flex-col' : ''}" />
        <div class="row${cssWrapper}"><%----%>
            <c:set target="${valueMap}" property="Type"         value="element"/>
            <c:set target="${valueMap}" property="Name"         value="maincol"/>
            <c:set target="${valueMap}" property="Css"          value="col-md-6${colCss}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'maincol'}" />
            <c:set target="${valueMap}" property="Name"         value="sidecol"/>
            <c:set target="${valueMap}" property="Css"          value="col-md-6${colCss}${reverseOrder ? ' order-first order-md-last' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'sidecol'}" />
            <mercury:nl />
        </div><%----%>
    </c:when>
    <c:when test="${variant eq '6-6-md'}">
        <%-- lr_00006 --%>
        <c:set var="colCss"            value="${cms.element.setting.useFlex.toBoolean ? ' flex-col' : ''}" />
        <div class="row${cssWrapper}"><%----%>
            <c:set target="${valueMap}" property="Type"         value="element"/>
            <c:set target="${valueMap}" property="Name"         value="maincol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-6${colCss}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'maincol'}" />
            <c:set target="${valueMap}" property="Name"         value="sidecol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-6${colCss}${reverseOrder ? ' order-first order-lg-last' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'sidecol'}" />
            <mercury:nl />
        </div><%----%>
    </c:when>
    <c:when test="${variant eq '9-3'}">
        <%-- lr_00007 --%>
        <c:set var="colCss"             value="${cms.element.setting.useFlex.toBoolean ? ' flex-col' : ''}" />
        <div class="row${cssWrapper}"><%----%>
            <c:set target="${valueMap}" property="Type"         value="element"/>
            <c:set target="${valueMap}" property="Name"         value="maincol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-9${colCss}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'maincol'}" />
            <c:set target="${valueMap}" property="Name"         value="sidecol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-3 col-side${colCss}${reverseOrder ? ' order-first order-lg-last' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'sidecol'}" />
            <mercury:nl />
        </div><%----%>
    </c:when>
    <c:when test="${variant eq '8-4'}">
        <%-- lr_00008 --%>
        <c:set var="colCss"             value="${cms.element.setting.useFlex.toBoolean ? ' flex-col' : ''}" />
        <div class="row${cssWrapper}">
            <mercury:nl />
            <c:set target="${valueMap}" property="Type"         value="element"/>
            <c:set target="${valueMap}" property="Name"         value="maincol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-8${colCss}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'maincol'}" />
            <c:set target="${valueMap}" property="Name"         value="sidecol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-4 col-side${colCss}${reverseOrder ? ' order-first order-lg-last' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'sidecol'}" />
            <mercury:nl />
        </div>
    </c:when>
    <c:when test="${variant eq '4-4-4'}">
        <%-- lr_00009 --%>
        <c:set var="colCss"            value="${cms.element.setting.useFlex.toBoolean ? ' flex-col' : ''}" />
        <div class="row${cssWrapper}"><%----%>
            <c:set target="${valueMap}" property="Type"         value="element"/>
            <c:set target="${valueMap}" property="Name"         value="maincol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-4${colCss}${reverseOrder ? ' order-last order-lg-first' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'maincol'}" />
            <c:set target="${valueMap}" property="Name"         value="sidecol"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-4${colCss}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'sidecol'}" />
            <c:set target="${valueMap}" property="Name"         value="addcol1"/>
            <c:set target="${valueMap}" property="Css"          value="col-lg-4${colCss}${reverseOrder ? ' order-first order-lg-last' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'addcol1'}" />
            <mercury:nl />
        </div><%----%>
    </c:when>
    <c:when test="${variant eq '3-3-3-3'}">
        <%-- lr_00010 --%>
        <c:set var="colCss"             value="${cms.element.setting.useFlex.toBoolean ? ' flex-col' : ''}" />
        <div class="row${cssWrapper}"><%----%>
            <c:set target="${valueMap}" property="Type"         value="element"/>
            <c:set target="${valueMap}" property="Name"         value="maincol"/>
            <c:set target="${valueMap}" property="Css"          value="col-md-6 col-lg-3${colCss}${reverseOrder ? ' order-4 order-md-3 order-lg-1' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'maincol'}" />
            <c:set target="${valueMap}" property="Name"         value="sidecol"/>
            <c:set target="${valueMap}" property="Css"          value="col-md-6 col-lg-3${colCss}${reverseOrder ? ' order-3 order-md-4 order-lg-2' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'sidecol'}" />
            <c:set target="${valueMap}" property="Name"         value="addcol1"/>
            <c:set target="${valueMap}" property="Css"          value="col-md-6 col-lg-3${colCss}${reverseOrder ? ' order-2 order-md-1 order-lg-3' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'addcol1'}" />
            <c:set target="${valueMap}" property="Name"         value="addcol2"/>
            <c:set target="${valueMap}" property="Css"          value="col-md-6 col-lg-3${colCss}${reverseOrder ? ' order-1 order-md-2 order-lg-4' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'addcol2'}" />
            <mercury:nl />
        </div><%----%>
    </c:when>
    <c:when test="${variant eq '2-2-2-2-2-2'}">
        <%-- lr_00011 --%>
        <c:set var="colCss"             value="${cms.element.setting.useFlex.toBoolean ? ' flex-col' : ''}" />
        <div class="row${cssWrapper}"><%----%>
            <c:set target="${valueMap}" property="Type"         value="element"/>
            <c:set target="${valueMap}" property="Name"         value="maincol"/>
            <c:set target="${valueMap}" property="Css"          value="col-6 col-md-4 col-xl-2${colCss}${reverseOrder ? ' order-5 order-md-4 order-xl-1' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'maincol'}" />
            <c:set target="${valueMap}" property="Name"         value="sidecol"/>
            <c:set target="${valueMap}" property="Css"          value="col-6 col-md-4 col-xl-2${colCss}${reverseOrder ? ' order-6 order-md-5 order-xl-2' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'sidecol'}" />
            <c:set target="${valueMap}" property="Name"         value="addcol1"/>
            <c:set target="${valueMap}" property="Css"          value="col-6 col-md-4 col-xl-2${colCss}${reverseOrder ? ' order-3 order-md-6 order-xl-3' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'addcol1'}" />
            <c:set target="${valueMap}" property="Name"         value="addcol2"/>
            <c:set target="${valueMap}" property="Css"          value="col-6 col-md-4 col-xl-2${colCss}${reverseOrder ? ' order-4 order-md-1 order-xl-4' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'addcol2'}" />
            <c:set target="${valueMap}" property="Name"         value="addcol3"/>
            <c:set target="${valueMap}" property="Css"          value="col-6 col-md-4 col-xl-2${colCss}${reverseOrder ? ' order-1 order-md-2 order-xl-5' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'addcol3'}" />
            <c:set target="${valueMap}" property="Name"         value="addcol4"/>
            <c:set target="${valueMap}" property="Css"          value="col-6 col-md-4 col-xl-2${colCss}${reverseOrder ? ' order-2 order-md-3 order-xl-6' : ''}" />
            <mercury:container value="${valueMap}" title="${value.Title}" detailView="${detailContainer eq 'addcol4'}" />
            <mercury:nl />
        </div><%----%>
    </c:when>
    <c:when test="${variant eq 'tile-row'}">
        <%-- lr_00012 - special row for tiles --%>
        <c:set var="useSquare"                                  value="${cms.element.settings.tileCss eq 'square'}" />
        <c:set var="useTile"                                    value="${not useSquare and not (cms.element.settings.tileCss eq 'none')}" />
        <c:set var="params"                                     value="${{'cssgrid': 'col-xs-12'}}" />
        <c:choose>
            <c:when test="${useTile or useSquare}">
                <%-- Generate tile row --%>
                <c:set var="tileCss"                            value="${cms.element.settings.tileCss}" />
                <c:set var="tileMargin"                         value="${cms.element.settings.tileMargin}" />
                <c:set target="${valueMap}" property="Type"     value="tile"/>
                <c:set target="${valueMap}" property="Css"      value="${useTile ? 'row-tile ' : 'row-square '}${tileMargin}${cssWrapper}" />
                <c:set target="${params}"   property="tilegrid" value="${tileCss}" />
            </c:when>
            <c:otherwise>
                <%-- Generate default row --%>
                <c:set target="${valueMap}" property="Type"     value="element"/>
                <c:set target="${valueMap}" property="Css"      value="row-12${cssWrapper}" />
            </c:otherwise>
        </c:choose>
        <c:set target="${valueMap}" property="Name"             value="maincol"/>
        <c:set target="${valueMap}" property="Parameters"       value="${params}" />
        <mercury:container value="${valueMap}" title="${value.Title}" detailView="${false}" />
    </c:when>
    <c:when test="${variant eq 'area-one-row'}">
        <%-- la_00001 --%>
        <c:set var="bgImage" value="${cms.element.setting.bgImage.toLink}" />
        <c:set var="bgSpacing" value="${cms.element.setting.bgSpacing.isSetNotNone ? cms.element.setting.bgSpacing.toString : null}" />
        <c:set var="bgColor" value="${cms.element.setting.bgColor.isSetNotNone ? cms.element.setting.bgColor.toString : null}" />

        <c:if test="${not empty bgImage}">
             <c:set var="styleAttr">background-image: url('${bgImage}');</c:set>
             <c:set var="cssWrapper">${cssWrapper}${' '}colored-row effect-parallax-bg</c:set>
        </c:if>
        <c:if test="${not empty bgSpacing}">
             <c:set var="cssWrapper">${cssWrapper}${' '}${bgSpacing}</c:set>
        </c:if>
        <c:if test="${not empty bgColor}">
            <c:choose>
                <c:when test="${fn:startsWith(bgColor, '#')}">
                    <c:set var="styleAttr">${styleAttr}${' '}background-color: ${bgColor};</c:set>
                    <c:set var="cssWrapper">${cssWrapper}${' '}colored-row</c:set>
                </c:when>
                <c:otherwise>
                    <c:set var="cssWrapper">${cssWrapper}${' '}colored-row${' '}${bgColor}</c:set>
                </c:otherwise>
            </c:choose>
        </c:if>
        <c:if test="${not empty styleAttr}">
              <c:set var="styleAttr"> style="${styleAttr}"</c:set>
        </c:if>
        <main class="area-content ${variant}${empty cssWrapper ? '' : ' '.concat(cssWrapper)}"${styleAttr}>
            <%-- Since the cssWrapper has been manipulated, it is required to add the ' ' prefix again. --%>
            <c:set target="${valueMap}" property="Type"             value="row" />
            <c:set target="${valueMap}" property="Name"             value="main" />
            <c:set target="${valueMap}" property="Tag"              value="div" />
            <c:set target="${valueMap}" property="Css"              value="container area-wide" />
            <mercury:container value="${valueMap}" title="${value.Title}" />
        </main>
    </c:when>
    <c:when test="${(variant eq 'area-side-main') or (variant eq 'area-main-side')}">
        <%-- la_00002 / la_00003 --%>
        <c:set var="asideFirst"                 value="${variant eq 'area-side-main'}" />
        <c:set var="asideWide"                  value="${'true' eq cms.vfs.readResource[cms.requestContext.uri].propertySearch['mercury.side.wide']}" />
        <c:set var="asideOnTop"                 value="${cms.element.setting.asideOnTop.toBoolean}" />
        <main class="area-content ${variant}${cssWrapper}"><%----%>
            <div class="container"><%----%>
                <div class="row"><%----%>
                    <c:set target="${valueMap}" property="Type"             value="row" />
                    <c:set target="${valueMap}" property="Name"             value="main" />
                    <c:set target="${valueMap}" property="Tag"              value="div" />
                    <c:set target="${valueMap}" property="Css"              value="col-lg-${asideWide ? '8' : '9'}${asideOnTop ? ' order-last' : ''}${asideFirst ? ' order-lg-last ' : ' '}area-wide" />
                    <mercury:container value="${valueMap}" title="${value.Title}" />
                    <c:set target="${valueMap}" property="Type"             value="element, side-group"/>
                    <c:set target="${valueMap}" property="Name"             value="aside"/>
                    <c:set target="${valueMap}" property="Tag"              value="aside" />
                    <c:set target="${valueMap}" property="Css"              value="col-lg-${asideWide ? '4' : '3'}${asideOnTop ? ' order-first' : ''}${asideFirst ? ' order-lg-first ' : ' '}area-narrow" />
                    <mercury:container value="${valueMap}" title="${value.Title}" />
                    <mercury:nl />
                </div><%----%>
            </div><%----%>
        </main><%----%>
    </c:when>
    <c:when test="${variant eq 'area-full-row'}">
        <%-- la_00004 --%>
        <c:set target="${valueMap}" property="Type"             value="element" />
        <c:set target="${valueMap}" property="Name"             value="main" />
        <c:set target="${valueMap}" property="Tag"              value="div" />
        <c:set target="${valueMap}" property="Css"              value="area-content area-wide ${variant}${cssWrapper}" />
        <c:set target="${valueMap}" property="Parameters"       value="${{'cssgrid': 'fullwidth'}}" />
        <mercury:container value="${valueMap}" title="${value.Title}" />
    </c:when>
    <c:otherwise>
        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <mercury:alert type="error">
                <jsp:attribute name="head">
                    <fmt:message key="msg.error.layout.selection">
                        <fmt:param>${variant}</fmt:param>
                        <fmt:param>${value.Title}</fmt:param>
                    </fmt:message>
                </jsp:attribute>
                <jsp:attribute name="text">
                    <c:out value="${content.filename}" />
                </jsp:attribute>
            </mercury:alert>
        </cms:bundle>
    </c:otherwise>
</c:choose>
<mercury:nl />

<mercury:container-box label="${value.Title}" boxType="model-end" />

</cms:formatter>
