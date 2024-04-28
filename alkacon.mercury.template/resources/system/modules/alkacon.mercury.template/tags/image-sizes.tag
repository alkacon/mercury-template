<%@ tag pageEncoding="UTF-8"
    display-name="image-sizes"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Sets the image sizes for the Bootstrap grid." %>

<%@ attribute name="initBootstrapBean" type="java.lang.Boolean" required="false"
    description="Initialize the bootstrap bean. Default is 'false' if not provided." %>

<%@ attribute name="gridWrapper" type="java.lang.String" required="false"
    description="Optional Bootstrap wrapper CSS that will be included in the calculated grid." %>

<%@ attribute name="gutter" type="java.lang.Integer" required="false"
    description="Bootstrap grid gutter to use. If not provided use the configured default, usually 30." %>

<%@ attribute name="srcSet" type="java.lang.Boolean" required="false"
    description="Generate image source set data or not? Default is 'true' if not provided." %>

<%@ attribute name="lazyLoad" type="java.lang.Boolean" required="false"
    description="Use lazy loading or not? Default is 'false'."%>

<%@ attribute name="debug" type="java.lang.Boolean" required="false"
    description="Enables debug output. Default is 'false' if not provided." %>


<%@ variable name-given="bsGutter" declare="true" %>
<%@ variable name-given="maxScaleWidth" declare="true" %>
<%@ variable name-given="bsLazyLoadJs" declare="true" %>
<%@ variable name-given="bsBpXs" declare="true" %>
<%@ variable name-given="bsBpSm" declare="true" %>
<%@ variable name-given="bsBpMd" declare="true" %>
<%@ variable name-given="bsBpLg" declare="true" %>
<%@ variable name-given="bsBpXl" declare="true" %>
<%@ variable name-given="bsBpXxl" declare="true" %>
<%@ variable name-given="bsMwXs" declare="true" %>
<%@ variable name-given="bsMwSm" declare="true" %>
<%@ variable name-given="bsMwMd" declare="true" %>
<%@ variable name-given="bsMwLg" declare="true" %>
<%@ variable name-given="bsMwXl" declare="true" %>
<%@ variable name-given="bsMwXxl" declare="true" %>

<%@ variable name-given="bb" declare="true" variable-class="alkacon.mercury.template.CmsJspBootstrapBean" %>
<%@ variable name-given="bbInitialized" declare="true" variable-class="java.lang.Boolean" %>
<%@ variable name-given="bbFullWidth" declare="true" variable-class="java.lang.Boolean" %>
<%@ variable name-given="bbSrcSetSizes" declare="true" %>


<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<%-- ###### Enable / disable output for debug purposes if required by setting DEBUG="${true}" ###### --%>
<c:set var="DEBUG" value="${false or debug}" />

<c:set var="bootstrapGrid"          value="${cms.sitemapConfig.attribute['template.bootstrap.grid'].toString}" />
<c:set var="bootstrapGridEmpty"     value="${empty bootstrapGrid}" />
<c:set var="srcSet"                 value="${empty srcSet ? true : srcSet}" />
<c:set var="bootstrapGrid"          value="${bootstrapGridEmpty ? 'template.bootstrap.grid.default' : bootstrapGrid}" />
<c:set var="forceClearCache"        value="${DEBUG and true}" />
<c:set var="clearCache"             value="${forceClearCache or cms.sitemapConfig.attribute['template.clearCache'].toBoolean}" />


<c:if test="${empty applicationScope.bootstrapCache or clearCache}">
   <c:set var="bootstrapCache" value="${cms:jsonToMap(leer)}" scope="application" />
   <mercury:print comment="${true}" test="${DEBUG and forceClearCache}">
        image-sizes FORCED clearCache!
    </mercury:print>
</c:if>

<c:set var="bootstrapGridData" value="${applicationScope.bootstrapCache[bootstrapGrid]}" />

<c:choose>
    <c:when test="${not empty bootstrapGridData}">
        <mercury:print comment="${true}" test="${DEBUG}">
            image-sizes using cached data:

            ${bootstrapGridData}
        </mercury:print>

        <c:set var="bsGutter" value="${bootstrapGridData['bsGutter']}" />
        <c:set var="maxScaleWidth"  value="${bootstrapGridData['maxScaleWidth']}" />
        <c:set var="bsLazyLoadJs"  value="${bootstrapGridData['bsLazyLoadJs']}" />
        <c:set var="bsBpXs"  value="${bootstrapGridData['bsBpXs']}" />
        <c:set var="bsBpSm"  value="${bootstrapGridData['bsBpSm']}" />
        <c:set var="bsBpMd"  value="${bootstrapGridData['bsBpMd']}" />
        <c:set var="bsBpLg"  value="${bootstrapGridData['bsBpLg']}" />
        <c:set var="bsBpXl"  value="${bootstrapGridData['bsBpXl']}" />
        <c:set var="bsBpXxl" value="${bootstrapGridData['bsBpXxl']}" />
        <c:set var="bsMwXs"  value="${bootstrapGridData['bsMwXs']}" />
        <c:set var="bsMwSm"  value="${bootstrapGridData['bsMwSm']}" />
        <c:set var="bsMwMd"  value="${bootstrapGridData['bsMwMd']}" />
        <c:set var="bsMwLg"  value="${bootstrapGridData['bsMwLg']}" />
        <c:set var="bsMwXl"  value="${bootstrapGridData['bsMwXl']}" />
        <c:set var="bsMwXxl" value="${bootstrapGridData['bsMwXxl']}" />

    </c:when>
    <c:otherwise>
        <c:if test="${not bootstrapGridEmpty}">
            <c:catch var="jsonException">
                <c:set var="bsGrid" value="${cms:parseJson(bootstrapGrid)}" />
                <c:set var="bsGutter" value="${bsGrid.getInt('gutter')}" />
                <c:set var="maxScaleWidth" value="${bsGrid.getInt('max-scale')}" />
                <c:set var="bsLazyLoadJs" value="${bsGrid.getBoolean('bsLazyLoadJs')}" />
                <c:set var="bsBpXs"  value="${bsGrid.getInt('bp-xs')}" />
                <c:set var="bsBpSm"  value="${bsGrid.getInt('bp-sm')}" />
                <c:set var="bsBpMd"  value="${bsGrid.getInt('bp-md')}" />
                <c:set var="bsBpLg"  value="${bsGrid.getInt('bp-lg')}" />
                <c:set var="bsBpXl"  value="${bsGrid.getInt('bp-xl')}" />
                <c:set var="bsBpXxl" value="${bsGrid.getInt('bp-xxl')}" />
                <c:set var="bsMwXs"  value="${bsGrid.getInt('mw-xs')}" />
                <c:set var="bsMwSm"  value="${bsGrid.getInt('mw-sm')}" />
                <c:set var="bsMwMd"  value="${bsGrid.getInt('mw-md')}" />
                <c:set var="bsMwLg"  value="${bsGrid.getInt('mw-lg')}" />
                <c:set var="bsMwXl"  value="${bsGrid.getInt('mw-xl')}" />
                <c:set var="bsMwXxl" value="${bsGrid.getInt('mw-xxl')}" />
                <c:set var="bsStatus">Source: JSON</c:set>
            </c:catch>
            <c:choose>
                <c:when test="${empty jsonException}">
                    <mercury:print comment="${true}" test="${DEBUG}">
                        image-sizes parsing sitemap attribute data:
                        ${bootstrapGrid}

                        image-sizes parsed JSON:
                        ${bsGrid}
                    </mercury:print>
                </c:when>
                <c:otherwise>
                    <mercury:log message="image-sizes: Error processing \'${bootstrapGrid}\' - \'${jsonException.message}\'" channel="error" />
                    <mercury:print comment="${true}" test="${DEBUG}">
                        <c:set var="bsStatus">Error: ${jsonException.message}</c:set>
                        Exception parsing bootstrap sitemap attribute data - using default values!:
                        ${jsonException.message}
                    </mercury:print>
                </c:otherwise>
            </c:choose>
        </c:if>

        <%-- Note that the defaults in case 'bootstrapGridEmpty eq true' are also set here --%>
        <c:set var="bsGutter" value="${empty bsGutter ? 30 : bsGutter}" />
        <c:set var="bsBpXs"  value="${empty bsBpXs ? 0     : bsBpXs}" />
        <c:set var="bsBpSm"  value="${empty bsBpSm ? 552   : bsBpSm}" />
        <c:set var="bsBpMd"  value="${empty bsBpMd ? 764   : bsBpMd}" />
        <c:set var="bsBpLg"  value="${empty bsBpLg ? 1014  : bsBpLg}" />
        <c:set var="bsBpXl"  value="${empty bsBpXl ? 1200  : bsBpXl}" />
        <c:set var="bsBpXxl" value="${empty bsBpXxl ? 1400 : bsBpXxl}" />
        <c:set var="bsMwXs"  value="${empty bsMwXs ? 375   : bsMwXs}" />
        <c:set var="bsMwSm"  value="${empty bsMwSm ? 540   : bsMwSm}" />
        <c:set var="bsMwMd"  value="${empty bsMwMd ? 744   : bsMwMd}" />
        <c:set var="bsMwLg"  value="${empty bsMwLg ? 992   : bsMwLg}" />
        <c:set var="bsMwXl"  value="${empty bsMwXl ? 1170  : bsMwXl}" />
        <c:set var="bsMwXxl" value="${empty bsMwXxl ? 1320 : bsMwXxl}" />
        <c:set var="bsLazyLoadJs" value="${empty bsLazyLoadJs ? false : bsLazyLoadJs}" />
        <c:set var="maxScaleWidth"  value="${empty maxScaleWidth ? 2500 : maxScaleWidth}" />
        <c:set var="maxScaleWidth"  value="${maxScaleWidth < bsBpXxl ? bsBpXxl : maxScaleWidth}" />
        <c:set var="bsStatus"  value="${empty bsStatus ? 'Source: Defaults' : bsStatus}" />

        <c:set var="dataMap" value="${{
            'bsGutter': bsGutter,
            'maxScaleWidth': maxScaleWidth,
            'bsLazyLoadJs': bsLazyLoadJs,
            'bsBpXs': bsBpXs,
            'bsBpSm': bsBpSm,
            'bsBpMd': bsBpMd,
            'bsBpLg': bsBpLg,
            'bsBpXl': bsBpXl,
            'bsBpXxl': bsBpXxl,
            'bsMwXs': bsMwXs,
            'bsMwSm': bsMwSm,
            'bsMwMd': bsMwMd,
            'bsMwLg': bsMwLg,
            'bsMwXl': bsMwXl,
            'bsMwXxl': bsMwXxl,
            'status': bsStatus
        }}" />

        <c:set target="${applicationScope.bootstrapCache}" property="${bootstrapGrid}" value="${dataMap}" />

        <mercury:print comment="${true}" test="${DEBUG}">
            image-sizes writing data to cache:

            ${dataMap}
        </mercury:print>

    </c:otherwise>
</c:choose>

<mercury:print comment="${true}" test="${DEBUG}">
image-sizes result:

Gutter: ${bsGutter}
Max scale width: ${maxScaleWidth}
Lazy load with JS: ${bsLazyLoadJs}

Breakpoint XS: ${bsBpXs}
Breakpoint SM: ${bsBpSm}
Breakpoint MD: ${bsBpMd}
Breakpoint LG: ${bsBpLg}
Breakpoint XL: ${bsBpXl}
Breakpoint XXL: ${bsBpXxl}

Max width XS: ${bsMwXs}
Max width SM: ${bsMwSm}
Max width MD: ${bsMwMd}
Max width LG: ${bsMwLg}
Max width XL: ${bsMwXl}
Max width XXL: ${bsMwXxl}
</mercury:print>

<c:choose>
    <c:when test="${initBootstrapBean}">

        <jsp:useBean id="bb" class="alkacon.mercury.template.CmsJspBootstrapBean">

            <c:forEach var="grid" items="${paramValues.cssgrid}">
                <c:if test="${fn:contains(grid, 'fullwidth')}">
                    <c:set var="bbFullWidth" value="${true}" />
                </c:if>
            </c:forEach>

            <c:choose>

                <c:when test="${bbFullWidth}">
                    <%-- ###### Assume all images are full screen ###### --%>
                    <mercury:print comment="${true}" test="${DEBUG}">
                        image-sizes using fullwidth!
                    </mercury:print>
                    ${bb.setGutter(0)}
                    ${bb.setGridSize(0, bsMwXs)}
                    ${bb.setGridSize(1, bsMwSm)}
                    ${bb.setGridSize(2, bsMwMd)}
                    ${bb.setGridSize(3, bsMwLg)}
                    ${bb.setGridSize(4, bsBpXl)}
                    ${bb.setGridSize(5, bsBpXxl)}
                </c:when>

                <c:otherwise>
                    <%-- ###### Calculate image size based on column width ###### --%>
                    <c:set var="gutterParam" value="${param.cssgutter}" />
                    <c:set var="gutterAdjust" value="${0}" />

                    <c:choose>
                        <c:when test="${not empty gutterParam and gutterParam ne '#'}">
                            <%-- ###### A custom gutter has been set, adjust gutter in bean ###### --%>
                            <c:set var="bsGutter" value="${cms:toNumber(gutterParam, bsGutter)}" />
                            <c:if test="${gutterParam ne param.cssgutterbase}">
                                <%-- ###### Special case: Gutter has been changed in template (e.g. logo slider does this).
                                            Adjust size of total width accordingly otherwise calulation is incorrect. ###### --%>
                                <c:set var="gutterBaseInt" value="${cms:toNumber(param.cssgutterbase, -1)}" />
                                <c:if test="${gutterBaseInt gt 0}">
                                    <c:set var="gutterAdjust" value="${gutterBaseInt - bsGutter}" />
                                </c:if>
                            </c:if>
                            <mercury:print comment="${true}" test="${DEBUG}">
                                image-sizes gutter adjust:

                                param.cssgutter: [${param.cssgutter}]
                                bsGutter: ${bsGutter}
                                gutterAdjust: ${gutterAdjust}
                            </mercury:print>
                        </c:when>
                        <c:when test="${not empty gutter}">
                            <c:set var="bsGutter" value="${gutter}" />
                            <mercury:print comment="${true}" test="${DEBUG}">
                                image-sizes gutter adjust:

                                bsGutter: ${bsGutter}
                                gutterAdjust: ${gutterAdjust}
                            </mercury:print>
                        </c:when>
                    </c:choose>

                    ${bb.setGutter(bsGutter)}
                    ${bb.setGridSize(0, bsMwXs - gutterAdjust)}
                    ${bb.setGridSize(1, bsMwSm - gutterAdjust)}
                    ${bb.setGridSize(2, bsMwMd - gutterAdjust)}
                    ${bb.setGridSize(3, bsMwLg - gutterAdjust)}
                    ${bb.setGridSize(4, bsMwXl - gutterAdjust)}
                    ${bb.setGridSize(5, bsMwXxl - gutterAdjust)}

                </c:otherwise>
            </c:choose>

            ${bb.setCssArray(paramValues.cssgrid)}
            <c:set var="ignore" value="${not empty gridWrapper ? bb.addLayer(gridWrapper) : ''}" />
            <c:set var="bbInitialized" value="${bb.isInitialized}" />

            <mercury:print comment="${true}" test="${DEBUG}">
                image-sizes calculated grid values::

                Gutter: ${bb.gutter}
                Max width XS: ${bb.getGridSize(0)} - Size XS: ${bb.sizeXs}
                Max width SM: ${bb.getGridSize(1)} - Size SM: ${bb.sizeSm}
                Max width MD: ${bb.getGridSize(2)} - Size MD: ${bb.sizeMd}
                Max width LG: ${bb.getGridSize(3)} - Size LG: ${bb.sizeLg}
                Max width XL: ${bb.getGridSize(4)} - Size XL: ${bb.sizeXl}
                Max width XXL: ${bb.getGridSize(5)} - Size XXL: ${bb.sizeXxl}
                <mercury:nl />
                <c:forEach var="grid" items="${paramValues.cssgrid}">
                grid: ${grid}
                </c:forEach>
                gridWrapper: ${gridWrapper}
                bbInitialized: ${bbInitialized}
            </mercury:print>

            <c:if test="${srcSet and bbInitialized}">
                <%-- ###### Calculate the source set sizes ###### --%>
                <c:set var="bbSrcSetSizes"><%--
                --%><c:if test="${lazyLoad and not bsLazyLoadJs}">auto, </c:if><%--
                --%><c:if test="${bb.sizeXxl gt 0}">(min-width: ${bsMwXxl}px) ${bb.sizeXxl}px, </c:if><%--
                --%><c:if test="${bb.sizeXl gt 0}">(min-width: ${bsMwXl}px) ${bb.sizeXl}px, </c:if><%--
                --%><c:if test="${bb.sizeLg gt 0}">(min-width: ${bsMwLg}px) ${bb.sizeLg}px, </c:if><%--
                --%><c:if test="${bb.sizeMd gt 0}">(min-width: ${bsMwMd}px) ${bb.sizeMd}px, </c:if><%--
                --%><c:if test="${bb.sizeSm gt 0}">(min-width: ${bsMwSm}px) ${bb.sizeSm}px, </c:if><%--
                --%>100vw</c:set>
                <mercury:print comment="${true}" test="${DEBUG}">
                    image-sizes calculated grid sizes:

                    bbSrcSetSizes: ${bbSrcSetSizes}
                </mercury:print>
            </c:if>

            <jsp:doBody/>
        </jsp:useBean>

    </c:when>
    <c:otherwise>
        <jsp:doBody/>
    </c:otherwise>
</c:choose>

