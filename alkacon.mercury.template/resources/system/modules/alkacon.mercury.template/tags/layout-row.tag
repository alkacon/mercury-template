<%@ tag pageEncoding="UTF-8"
    display-name="layout-row"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates default layout rows and areas." %>


<%@ attribute name="rowVariant" type="java.lang.Integer" required="true"
    description="The row variant to create." %>

<%@ attribute name="title" type="java.lang.String" required="true"
    description="The row title." %>

<%@ attribute name="sideColSize" type="java.lang.Integer" required="false"
    description="The size of the aside container." %>

<%@ attribute name="showSideLast" type="java.lang.Boolean" required="false"
    description="Controls if in a 2 column layout the smaller 'side' container is shown before or after the 'main' container on desktop devices." %>

<%@ attribute name="mainType" type="java.lang.String" required="false"
    description="The type for the larger 'main' container." %>

<%@ attribute name="sideType" type="java.lang.String" required="false"
    description="The type for the smaller 'side' container. Will default to 'element' if not set."  %>

<%@ attribute name="subType" type="java.lang.String" required="false"
    description="The sub type assigned to the container, which will control optional default settings." %>

<%@ attribute name="detailContainer" type="java.lang.String" required="false"
    description="Controls which container is used as detail container." %>

<%@ attribute name="useAsideTag" type="java.lang.Boolean" required="false"
    description="Controls if in a 2 column layout the smaller 'side' container uses the 'aside' tag instead of 'div'." %>

<%@ attribute name="breakpoint" type="java.lang.String" required="false"
    description="The breakpoint from which the containers are shown 'side by side'. Will default to 'lg' if not set." %>

<%@ attribute name="colCount" type="java.lang.Integer" required="false"
    description="Number of columns to create (only for special rowVariant 5 / 'flex-cols')." %>

<%@ attribute name="reverseMobileOrder" type="java.lang.Boolean" required="false"
    description="Controls the column order is reversed on mobile devices." %>

<%@ attribute name="conCss" type="java.lang.String" required="false"
    description="If not empty a nested 2 div container structure is added around the row. The outer div will have this css selector(s) and the inner will have the css selector 'container'." %>

<%@ attribute name="areaCss" type="java.lang.String" required="false"
    description="CSS added to the generated area." %>

<%@ attribute name="rowCss" type="java.lang.String" required="false"
    description="CSS added to the generated row." %>

<%@ attribute name="colCss" type="java.lang.String" required="false"
    description="CSS added to the generated cols." %>

<%@ attribute name="setting" type="java.util.Map" required="false"
    description="Element settings, only used for 'areas' and other special grid elements." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<jsp:useBean id="valueMap"              class="java.util.HashMap" />

<c:set var="addContainer"               value="${not empty conCss}" />
<c:set var="sideType"                   value="${empty sideType ? 'element' : sideType}" />

<c:if test="${(rowVariant eq 2) or (rowVariant eq 3) or (rowVariant eq 5)}">
    <c:choose>
        <c:when test="${empty breakpoint}">
            <c:set var="breakpoint"     value="-lg-" />
        </c:when>
        <c:otherwise>
            <c:set var="breakpoints"    value="${{'xs':'-', 'sm':'-sm-', 'md':'-md-', 'lg':'-lg-', 'xl':'-xl-', 'xxl':'-xxl-', '6-6':'-', '6-6-sm':'-md-', '6-6-lg':'-lg-'}}" />
            <c:set var="breakpoint"     value="${breakpoints[breakpoint]}" />
            <c:set var="breakpoint"     value="${empty breakpoint ? '-lg-' : breakpoint}" />
        </c:otherwise>
    </c:choose>
</c:if>

<c:if test="${(rowVariant lt 30)}">
    <c:set var="rowCss"                 value="${(not empty rowCss) and (not fn:startsWith(rowCss, ' ')) ? ' '+=rowCss : rowCss}" />
    <c:if test="${rowVariant gt 1}">
        <c:set var="colCss"             value="${(not empty colCss) and (not fn:startsWith(colCss, ' ')) ? ' '+=colCss : colCss}" />
    </c:if>
</c:if>

<c:choose>

    <c:when test="${rowVariant == 1}">
        <%-- '12' - lr_00001 - 1 column row --%>
        <m:div test="${addContainer}" css="${conCss}" css2="container">
            <m:div test="${not empty rowCss}" css="row${rowCss}">
                <c:set target="${valueMap}" property="Type"         value="${mainType}"/>
                <c:set target="${valueMap}" property="subType"      value="${subType}"/>
                <c:set target="${valueMap}" property="Name"         value="maincol"/>
                <c:set target="${valueMap}" property="Css"          value="${colCss}" />
                <c:set target="${valueMap}" property="Parameters"   value="${{'cssgrid': 'col-xs-12'}}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'maincol'}" />
            </m:div>
        </m:div>
    </c:when>


    <c:when test="${rowVariant == 2}">
         <%-- all 2 column row variants like '9-3', '8-4', '6-6' etc. --%>
        <c:set var="showSideLast"       value="${empty showSideLast ? true : showSideLast}" />
        <c:set var="sideColSize"        value="${(sideColSize < 3) or (sideColSize > 6) ? 6 : sideColSize}" />
        <c:set var="mainColSize"        value="${12 - sideColSize}" />

        <m:div test="${addContainer}" css="${conCss}" css2="container">
            <div class="row${rowCss}"><%----%>

                <c:set target="${valueMap}" property="Type"         value="${mainType}"/>
                <c:set target="${valueMap}" property="subType"      value="${subType}"/>
                <c:set target="${valueMap}" property="Name"         value="maincol"/>
                <c:set target="${valueMap}" property="Css"          value="col${breakpoint}${mainColSize}${colCss}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'maincol'}" />

                <c:set var="colOrder" value="${showSideLast ? (reverseMobileOrder ? ' order-first order'.concat(breakpoint eq '-' ? '-lg-' : breakpoint).concat('last') : '') : (reverseMobileOrder ? ' order-first' : ' order'.concat(breakpoint eq '-' ? '-lg-' : breakpoint).concat('first'))}" />
                <c:set target="${valueMap}" property="Type"         value="${sideType}"/>
                <c:set target="${valueMap}" property="Name"         value="sidecol"/>
                <c:set target="${valueMap}" property="Tag"          value="${useAsideTag and (mainColSize ne 6) ? 'aside' : 'div'}" />
                <c:set target="${valueMap}" property="Css"          value="col${breakpoint}${sideColSize}${colCss}${colOrder}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'sidecol'}" />

            <m:nl />
            </div><%----%>
        </m:div>
    </c:when>


    <c:when test="${rowVariant == 3}">
        <%-- '4-4-4' - lr_00009 --%>
        <m:div test="${addContainer}" css="${conCss}" css2="container">
            <div class="row${rowCss}"><%----%>

                <c:set var="colOrder" value="${reverseMobileOrder ? ' order-last order'.concat(breakpoint).concat('first') : ''}" />
                <c:set target="${valueMap}" property="Type"         value="${mainType}"/>
                <c:set target="${valueMap}" property="subType"      value="${subType}"/>
                <c:set target="${valueMap}" property="Name"         value="maincol"/>
                <c:set target="${valueMap}" property="Css"          value="col${breakpoint}4${colCss}${colOrder}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'maincol'}" />

                <c:set target="${valueMap}" property="Type"         value="${sideType}"/>
                <c:set target="${valueMap}" property="Name"         value="sidecol"/>
                <c:set target="${valueMap}" property="Css"          value="col${breakpoint}4${colCss}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'sidecol'}" />

                <c:set var="colOrder" value="${reverseMobileOrder ? ' order-first order'.concat(breakpoint).concat('last') : ''}" />
                <c:set target="${valueMap}" property="Name"         value="addcol1"/>
                <c:set target="${valueMap}" property="Css"          value="col${breakpoint}4${colCss}${colOrder}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'addcol1'}" />

            <m:nl />
            </div><%----%>
        </m:div>
    </c:when>


    <c:when test="${rowVariant == 4}">
        <%-- '3-3-3-3' - lr_00010 --%>
        <c:choose>
            <c:when test="${sideColSize == 6}">
                <c:set var="colCssMod"  value="col-6 col-lg-3${colCss}" />
            </c:when>
            <c:when test="${sideColSize == 12}">
                 <c:set var="colCssMod" value="col-12 col-lg-3${colCss}" />
            </c:when>
            <c:when test="${sideColSize lt 0}">
                <c:set var="colCssMod"  value="${colCss}" />
            </c:when>
            <c:otherwise>
                 <c:set var="colCssMod" value="col-12 col-md-6 col-lg-3${colCss}" />
            </c:otherwise>
        </c:choose>
        <c:set var="twoXsCols"          value="${(sideColSize == 6) or ((sideColSize lt 0) and fn:contains(colCssMod, 'col-6 '))}" />

        <m:div test="${addContainer}" css="${conCss}" css2="container">
            <div class="row${rowCss}"><%----%>

                <c:set target="${valueMap}" property="Type"         value="${mainType}"/>
                <c:set target="${valueMap}" property="subType"      value="${subType}"/>
                <c:set target="${valueMap}" property="Name"         value="maincol"/>
                <c:set target="${valueMap}" property="Css"          value="${colCssMod}${reverseMobileOrder ? (twoXsCols ? ' order-3' :' order-4').concat('order-md-3 order-lg-1') : ''}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'maincol'}" />

                <c:set target="${valueMap}" property="Type"         value="${sideType}"/>
                <c:set target="${valueMap}" property="Name"         value="sidecol"/>
                <c:set target="${valueMap}" property="Css"          value="${colCssMod}${reverseMobileOrder ? (twoXsCols ? ' order-4' :' order-3').concat('order-md-4 order-lg-2') : ''}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'sidecol'}" />

                <c:set target="${valueMap}" property="Name"         value="addcol1"/>
                <c:set target="${valueMap}" property="Css"          value="${colCssMod}${reverseMobileOrder ? (twoXsCols ? ' order-1' :' order-2').concat('order-md-1 order-lg-3') : ''}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'addcol1'}" />

                <c:set target="${valueMap}" property="Name"         value="addcol2"/>
                <c:set target="${valueMap}" property="Css"          value="${colCssMod}${reverseMobileOrder ? (twoXsCols ? ' order-2' :' order-1').concat('order-md-2 order-lg-4') : ''}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'addcol2'}" />

            <m:nl />
            </div><%----%>
        </m:div>
    </c:when>


    <c:when test="${rowVariant == 5}">
        <%-- 'flex-cols' - special row with number of columns defined in settings--%>
        <c:set var="colSize"        value="${['12', '12','6','4','3','2o4','2']}" />
        <c:set var="breakpoint"     value="${breakpoint eq '-' ? '' : breakpoint.concat(colSize[colCount])}" />

        <m:div test="${addContainer}" css="${conCss}" css2="container">
            <div class="row${rowCss} col-count-${colCount}"><%----%>

               <c:forEach begin="1" end="${colCount}" varStatus="status">
                    <c:choose>
                        <c:when test="${status.first}">
                            <c:set var="containerName" value="maincol" />
                            <c:set var="containerType" value="${mainType}" />
                        </c:when>
                        <c:when test="${status.index == 2}">
                            <c:set var="containerName" value="sidecol" />
                            <c:set var="containerType" value="${sideType}" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="containerName" value="addcol${status.count - 2}" />
                            <c:set var="containerType" value="${sideType}" />
                        </c:otherwise>
                    </c:choose>

                    <c:set target="${valueMap}" property="Name"         value="${containerName}"/>
                    <c:set target="${valueMap}" property="Type"         value="${containerType}"/>
                    <c:set target="${valueMap}" property="subType"      value="${subType}"/>
                    <c:set target="${valueMap}" property="Css"          value="col${breakpoint} col-num-${status.count}${colCss}" />

                    <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq containerName}" />

                </c:forEach>

            <m:nl />
            </div><%----%>
        </m:div>
    </c:when>


    <c:when test="${rowVariant == 6}">
        <%-- '2-2-2-2-2-2' - lr_00011 --%>
        <c:choose>
            <c:when test="${sideColSize == 6}">
                <c:set var="colCssMod"  value="col-6 col-md-4 col-xl-2${colCss}" />
            </c:when>
            <c:when test="${sideColSize lt 0}">
                <c:set var="colCssMod"  value="${colCss}" />
            </c:when>
            <c:otherwise>
                 <c:set var="colCssMod" value="col-12 col-md-4 col-xl-2${colCss}" />
            </c:otherwise>
        </c:choose>
        <c:set var="twoXsCols"          value="${(sideColSize == 0) or (sideColSize == 6) or ((sideColSize lt 0) and fn:contains(colCssMod, 'col-6 '))}" />

        <m:div test="${addContainer}" css="${conCss}" css2="container">
            <div class="row${rowCss}"><%----%>

                <c:set target="${valueMap}" property="Type"         value="${mainType}"/>
                <c:set target="${valueMap}" property="subType"      value="${subType}"/>
                <c:set target="${valueMap}" property="Name"         value="maincol"/>
                <c:set target="${valueMap}" property="Css"          value="${colCssMod}${reverseMobileOrder ? (twoXsCols ? ' order-5' : ' order-6').concat(' order-md-4 order-xl-1') : ''}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'maincol'}" />

                <c:set target="${valueMap}" property="Type"         value="${sideType}"/>
                <c:set target="${valueMap}" property="Name"         value="sidecol"/>
                <c:set target="${valueMap}" property="Css"          value="${colCssMod}${reverseMobileOrder ? (twoXsCols ? ' order-6' : ' order-5').concat(' order-md-5 order-xl-2') : ''}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'sidecol'}" />

                <c:set target="${valueMap}" property="Name"         value="addcol1"/>
                <c:set target="${valueMap}" property="Css"          value="${colCssMod}${reverseMobileOrder ? (twoXsCols ? ' order-3' : ' order-4').concat(' order-md-6 order-xl-3') : ''}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'addcol1'}" />

                <c:set target="${valueMap}" property="Name"         value="addcol2"/>
                <c:set target="${valueMap}" property="Css"          value="${colCssMod}${reverseMobileOrder ? (twoXsCols ? ' order-4' : ' order-3').concat(' order-md-1 order-xl-4') : ''}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'addcol2'}" />

                <c:set target="${valueMap}" property="Name"         value="addcol3"/>
                <c:set target="${valueMap}" property="Css"          value="${colCssMod}${reverseMobileOrder ? (twoXsCols ? ' order-1' : ' order-2').concat(' order-md-2 order-xl-5') : ''}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'addcol3'}" />

                <c:set target="${valueMap}" property="Name"         value="addcol4"/>
                <c:set target="${valueMap}" property="Css"          value="${colCssMod}${reverseMobileOrder ? (twoXsCols ? ' order-2' : ' order-1').concat(' order-md-3 order-xl-6') : ''}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'addcol4'}" />

            <m:nl />
            </div><%----%>
        </m:div>
    </c:when>


    <c:when test="${rowVariant == 12}">
        <%-- 'tile-row' - lr_00012 - special row for tiles --%>
        <c:set var="tileCss"            value="${setting.tileCss.toString}" />
        <c:set var="tileMargin"         value="${setting.tileMargin.toString}" />

        <c:set var="useSquare"          value="${tileCss eq 'square'}" />
        <c:set var="useTile"            value="${not useSquare and not (tileCss eq 'none')}" />
        <c:set var="params"             value="${{'cssgrid': 'col-xs-12'}}" />

        <c:choose>
            <c:when test="${useSquare}">
                <%-- Generate square row --%>
                <c:set var="squareMargin"                       value="square-m-${fn:substringAfter(tileMargin, 'tile-margin-')}" />
                <c:set target="${valueMap}" property="Type"     value="square"/>
                <c:set target="${valueMap}" property="Css"      value="${'row-square '}${squareMargin}${rowCss}" />
                <c:set target="${params}"   property="tilegrid" value="" />
            </c:when>

            <c:when test="${useTile}">
                <%-- Generate tile row --%>
                <c:choose>
                    <c:when test="${tileCss eq 'tile-col col-6 col-md-4 col-lg-3 col-xl-2'}">
                        <c:set var="tileMargin" value="row-cols-2 row-cols-md-3 row-cols-lg-4 row-cols-xl-6 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-6 col-md-4 col-xl-2'}">
                        <c:set var="tileMargin" value="row-cols-2 row-cols-md-3 row-cols-xl-6 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-6 col-lg-3'}">
                        <c:set var="tileMargin" value="row-cols-2 row-cols-lg-4 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-6'}">
                        <c:set var="tileMargin" value="row-cols-2 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-md-6 col-lg-3'}">
                        <c:set var="tileMargin" value="row-cols-1 row-cols-md-2 row-cols-lg-4 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-md-6 col-lg-4 col-xl-3'}">
                        <c:set var="tileMargin" value="row-cols-1 row-cols-md-2 row-cols-lg-3 row-cols-xl-4 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-md-6 col-xl-3'}">
                        <c:set var="tileMargin" value="row-cols-1 row-cols-md-2 row-cols-xl-4 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-md-6 col-xl-4'}">
                        <c:set var="tileMargin" value="row-cols-1 row-cols-md-2 row-cols-xl-3 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-lg-4'}">
                        <c:set var="tileMargin" value="row-cols-1 row-cols-lg-3 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-md-6'}">
                        <c:set var="tileMargin" value="row-cols-1 row-cols-md-2 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-lg-6'}">
                        <c:set var="tileMargin" value="row-cols-1 row-cols-lg-2 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                    <c:when test="${tileCss eq 'tile-col col-12'}">
                        <c:set var="tileMargin" value="row-cols-1 ${tileMargin}" />
                        <c:set var="tileCss"    value="tile-col col" />
                    </c:when>
                </c:choose>
                <c:set target="${valueMap}" property="Type"     value="tile"/>
                <c:set target="${valueMap}" property="Css"      value="${'row '}${tileMargin}${rowCss}" />
                <c:set target="${params}"   property="tilegrid" value="${tileCss}" />
            </c:when>

            <c:otherwise>
                <%-- Generate default row --%>
                <c:set target="${valueMap}" property="Type"     value="${mainType}"/>
                <c:set target="${valueMap}" property="Css"      value="row-12${rowCss}" />
            </c:otherwise>
        </c:choose>

        <c:set target="${valueMap}" property="Name"             value="maincol"/>
        <c:set target="${valueMap}" property="Parameters"       value="${params}" />
        <m:container value="${valueMap}" title="${title}" detailView="${false}" />
    </c:when>


    <c:when test="${rowVariant == 13}">
        <%-- 'adjust' - lr_00013 - 1 column row with adjustable with --%>
        <m:div test="${addContainer}" css="${conCss}" css2="container">
            <div class="row${rowCss}"><%----%>
                <c:set target="${valueMap}" property="Type"     value="${mainType}"/>
                <c:set target="${valueMap}" property="Name"     value="maincol"/>
                <c:set target="${valueMap}" property="Css"      value="col-lg-${sideColSize + 1 le 12 ? sideColSize + 1 : 12} col-xl-${sideColSize}" />
                <m:container value="${valueMap}" title="${title}" detailView="${detailContainer eq 'maincol'}" />
            </div><%----%>
        </m:div>
    </c:when>


    <c:when test="${rowVariant == 30}">
        <%-- 'area-one-row' - la_00001 --%>
        <c:set var="bgSpacing"  value="${setting.bgSpacing.isSetNotNone ? setting.bgSpacing.toString : null}" />
        <c:set var="bgColor"    value="${setting.bgColor.isSetNotNone ? setting.bgColor.toString : null}" />

        <c:set var="rowCss"     value="${empty rowCss ? 'container area-wide' : rowCss}" />

        <c:if test="${not empty setting.bgImage.toLink}">
            <c:set var="bgImage"        value="${setting.bgImage.toImage}" />
            <c:set var="maxImgSize"     value="${2600}" />
            <c:if test="${bgImage.width gt maxImgSize}">
                <c:set var="bgImage"    value="${bgImage.scaleWidth[maxImgSize]}" />
            </c:if>
            <c:set var="styleAttr">background-image: url('${bgImage.srcUrl}');</c:set>
            <c:set var="areaCss">${areaCss}${' '}effect-parallax-bg row-has-background</c:set>
        </c:if>
        <c:if test="${not empty bgSpacing}">
             <c:set var="areaCss">${areaCss}${' '}${bgSpacing}</c:set>
        </c:if>
        <c:if test="${not empty bgColor}">
            <c:choose>
                <c:when test="${fn:startsWith(bgColor, '#')}">
                    <c:set var="styleAttr">${styleAttr}${' '}background-color: ${bgColor};</c:set>
                    <c:set var="areaCss">${areaCss}${' '}colored-row row-has-background</c:set>
                </c:when>
                <c:otherwise>
                    <c:set var="areaCss">${areaCss}${' '}colored-row row-has-background${' '}${bgColor}</c:set>
                </c:otherwise>
            </c:choose>
        </c:if>
        <c:if test="${not empty styleAttr}">
              <c:set var="styleAttr">${' '}style="${styleAttr}"</c:set>
        </c:if>

        <main class="area-content ${areaCss}"${styleAttr}><%----%>

            <c:set target="${valueMap}" property="Type"             value="row" />
            <c:set target="${valueMap}" property="Name"             value="main" />
            <c:set target="${valueMap}" property="Tag"              value="div" />
            <c:set target="${valueMap}" property="Css"              value="${rowCss}" />
            <m:container value="${valueMap}" title="${title}" />

            <m:nl />
        </main><%----%>
    </c:when>


    <c:when test="${rowVariant == 40}">
         <%-- 'area-side-main' or 'area-main-side' - la_00002 / la_00003 --%>
        <c:set var="asideFirst"                 value="${not showSideLast}" />
        <c:set var="asideWide"                  value="${'true' eq cms.readAttributeOrProperty[cms.requestContext.uri]['mercury.side.wide']}" />
        <c:set var="asideOnTop"                 value="${setting.asideOnTop.toBoolean}" />

        <main class="area-content ${areaCss}"><%----%>
            <div class="container"><%----%>
                <div class="row"><%----%>
                    <c:set target="${valueMap}" property="Type"             value="row" />
                    <c:set target="${valueMap}" property="Name"             value="main" />
                    <c:set target="${valueMap}" property="Tag"              value="div" />
                    <c:set target="${valueMap}" property="Css"              value="col-lg-${asideWide ? '8' : '9'}${asideOnTop ? ' order-last' : ''}${asideFirst ? ' order-lg-last ' : ' '}area-wide" />
                    <m:container value="${valueMap}" title="${title}" />

                    <c:set target="${valueMap}" property="Type"             value="element, side-group"/>
                    <c:set target="${valueMap}" property="Name"             value="aside"/>
                    <c:set target="${valueMap}" property="Tag"              value="aside" />
                    <c:set target="${valueMap}" property="Css"              value="col-lg-${asideWide ? '4' : '3'}${asideOnTop ? ' order-first'.concat(asideFirst ? '' : ' order-lg-last') : ''}${asideFirst ? ' order-lg-first ' : ' '}area-narrow" />
                    <m:container value="${valueMap}" title="${title}" />

                    <m:nl />
                </div><%----%>
            </div><%----%>
        </main><%----%>
    </c:when>


    <c:when test="${rowVariant == 50}">
        <%-- 'area-full-row' - la_00004 --%>
        <c:set target="${valueMap}" property="Type"             value="element" />
        <c:set target="${valueMap}" property="Name"             value="main" />
        <c:set target="${valueMap}" property="Tag"              value="div" />
        <c:set target="${valueMap}" property="Css"              value="${areaCss}" />
        <c:set target="${valueMap}" property="Parameters"       value="${{'cssgrid': 'fullwidth'}}" />
        <m:container value="${valueMap}" title="${title}" />
    </c:when>

</c:choose>