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

<mercury:setting-defaults>

<c:set var="variant"            value="${value.Variant}" />
<c:set var="detailContainer"    value="${setting.detailContainer.toString}" />
<c:set var="reverseMobileOrder" value="${setting.containerOrder.toString eq 'reversed'}" />

<c:set var="customContainer"    value="${detailContainer eq 'maincust'}" />
<c:set var="mainType"           value="${customContainer ? 'special' : 'element'}" />
<c:set var="detailContainer"    value="${customContainer ? 'maincol' : detailContainer}" />

<c:set var="cssWrapper"         value="${setCssWrapperAll}" />

<mercury:container-box label="${value.Title}" boxType="model-start" />
<mercury:nl />

<c:choose>

    <c:when test="${variant eq '12'}">
        <%-- lr_00001 --%>
        <mercury:layout-row
            rowVariant="${1}"
            title="${value.Title}"
            detailContainer="${detailContainer}"
            colCss="row-12${cssWrapper}${cms.isEditMode ? ' oc-point-T0_L10' : ''}"
            mainType="${mainType}"
        />
    </c:when>

    <c:when test="${(variant eq '3-9') or (variant eq '9-3') or (variant eq '4-8') or (variant eq '8-4')}">
        <%-- lr_00002 (3-9) - lr_00003 (4-8) - lr_00007 (9-3) - lr_00008 (8-4) --%>
        <mercury:layout-row
            rowVariant="${2}"
            title="${value.Title}"
            sideColSize="${fn:contains(variant, '3') ? 3 : 4}"
            showSideLast="${fn:startsWith(variant, '8') or fn:startsWith(variant, '9')}"
            detailContainer="${detailContainer}"
            rowCss="${cssWrapper}"
            colCss="${setting.useFlex.toBoolean ? ' flex-col' : null}"
            mainType="${mainType}"
            reverseMobileOrder="${reverseMobileOrder}"
        />
    </c:when>

    <c:when test="${(variant eq '6-6') or (variant eq '6-6-sm') or (variant eq '6-6-md')}">
        <%-- lr_00004 (6-6) - lr_00005 (6-6-sm) - lr_00006 (6-6-md) --%>
        <mercury:layout-row
            rowVariant="${2}"
            title="${value.Title}"
            sideColSize="${6}"
            showSideLast="${true}"
            breakpoint="${variant}"
            detailContainer="${detailContainer}"
            rowCss="${cssWrapper}"
            colCss="${setting.useFlex.toBoolean ? ' flex-col' : null}"
            mainType="${mainType}"
            reverseMobileOrder="${reverseMobileOrder}"
        />
    </c:when>

    <c:when test="${variant eq '4-4-4'}">
        <%-- lr_00009 --%>
        <mercury:layout-row
            rowVariant="${3}"
            title="${value.Title}"
            detailContainer="${detailContainer}"
            rowCss="${cssWrapper}"
            colCss="${setting.useFlex.toBoolean ? ' flex-col' : null}"
            mainType="${mainType}"
            reverseMobileOrder="${reverseMobileOrder}"
        />
    </c:when>

    <c:when test="${variant eq '3-3-3-3'}">
        <%-- lr_00010 --%>
        <mercury:layout-row
            rowVariant="${4}"
            title="${value.Title}"
            sideColSize="${setting.xsCols.toInteger}"
            detailContainer="${detailContainer}"
            rowCss="${cssWrapper}"
            colCss="${setting.useFlex.toBoolean ? ' flex-col' : null}"
            mainType="${mainType}"
            reverseMobileOrder="${reverseMobileOrder}"
        />
    </c:when>

    <c:when test="${variant eq '2-2-2-2-2-2'}">
        <%-- lr_00011 --%>
        <mercury:layout-row
            rowVariant="${6}"
            title="${value.Title}"
            sideColSize="${setting.xsCols.toInteger}"
            detailContainer="${detailContainer}"
            rowCss="${cssWrapper}"
            colCss="${setting.useFlex.toBoolean ? ' flex-col' : null}"
            mainType="${mainType}"
            reverseMobileOrder="${reverseMobileOrder}"
        />
    </c:when>

    <c:when test="${variant eq 'area-one-row'}">
        <%-- la_00001 --%>
        <mercury:layout-row
            rowVariant="${30}"
            title="${value.Title}"
            areaCss="${variant}${cssWrapper}"
            setting="${setting}"
        />
    </c:when>

    <c:when test="${(variant eq 'area-side-main') or (variant eq 'area-main-side')}">
        <%-- la_00002 / la_00003 --%>
        <mercury:layout-row
            rowVariant="${40}"
            title="${value.Title}"
            showSideLast="${variant eq 'area-main-side'}"
            areaCss="${variant}${cssWrapper}"
            setting="${setting}"
        />
    </c:when>

    <c:when test="${variant eq 'area-full-row'}">
        <%-- la_00004 --%>
        <mercury:layout-row
            rowVariant="${50}"
            title="${value.Title}"
            areaCss="area-content area-wide ${variant}${cssWrapper}"
        />
    </c:when>

    <c:when test="${variant eq 'tile-row'}">
        <%-- lr_00012 - special row for tiles --%>
        <mercury:layout-row
            rowVariant="${12}"
            title="${value.Title}"
            rowCss="${cssWrapper}"
            mainType="${mainType}"
            setting="${setting}"
        />
    </c:when>

    <c:when test="${variant eq 'adjust'}">
        <%-- lr_00013 - adjustable with 1 column row --%>
        <c:set var="colWidth" value="${setting.colWidth.validate(['6','7','8','9','10','11','12'],'10').toInteger}" />
        <mercury:layout-row
            rowVariant="${13}"
            sideColSize="${colWidth}"
            title="${value.Title}"
            detailContainer="${detailContainer}"
            rowCss="justify-content-lg-center${cssWrapper}"
            mainType="${mainType}"
        />
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

</mercury:setting-defaults>

</cms:formatter>
