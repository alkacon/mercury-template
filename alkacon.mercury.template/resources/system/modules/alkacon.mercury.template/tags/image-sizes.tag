<%@ tag pageEncoding="UTF-8"
    display-name="image-sizes"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Sets the image sizes for the Bootstrap grid." %>


<%@ attribute name="debug" type="java.lang.Boolean" required="false"
    description="Enables debug output.
    Default is 'false' if not provided." %>


<%@ variable name-given="bsGutter" declare="true" %>
<%@ variable name-given="maxScaleWidth" declare="true" %>
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


<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<%-- ###### Enable / disable output for debug purposes if required by setting DEBUG="${true}" ###### --%>
<c:set var="DEBUG" value="${debug}" />

<c:set var="bootstrapGrid" value="${cms.sitemapConfig.attribute['template.bootstrap.grid'].toString}" />
<c:set var="bootstrapGridEmpty" value="${empty bootstrapGrid}" />
<c:set var="bootstrapGrid" value="${bootstrapGridEmpty ? 'template.bootstrap.grid.default' : bootstrapGrid}" />
<c:set var="clearCache"    value="${DEBUG or cms.sitemapConfig.attribute['template.clearCache'].toBoolean}" />


<c:if test="${empty applicationScope.bootstrapCache or clearCache}">
   <c:set var="bootstrapCache" value="${cms:jsonToMap(leer)}" scope="application" />
</c:if>

<c:set var="bootstrapGridData" value="${applicationScope.bootstrapCache[bootstrapGrid]}" />

<c:choose>
    <c:when test="${not empty bootstrapGridData}">
        <c:if test="${DEBUG}">
<!--
image-sizes using cached data:

${bootstrapGridData}
-->
        </c:if>

        <c:set var="bsGutter" value="${bootstrapGridData['bsGutter']}" />
        <c:set var="maxScaleWidth"  value="${bootstrapGridData['maxScaleWidth']}" />
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
                <c:set var="maxScaleWidth"  value="${bsGrid.getInt('max-scale')}" />
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
                    <c:if test="${DEBUG}">
<!--
image-sizes parsing sitemap attribute data:
${bootstrapGrid}

image-sizes parsed JSON:
${bsGrid}
-->
                    </c:if>
                </c:when>
                <c:otherwise>
                    <mercury:log message="image-sizes: Error processing \'${bootstrapGrid}\' - \'${jsonException.message}\'" channel="error" />
                    <c:if test="${DEBUG}">
                        <c:set var="bsStatus">Error: ${jsonException.message}</c:set>
<!--
Exception parsing bootstrap sitemap attribute data - using default values!:
${jsonException.message}
-->
                    </c:if>
                </c:otherwise>
            </c:choose>
        </c:if>

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
        <c:set var="maxScaleWidth"  value="${empty maxScaleWidth ? 2500 : maxScaleWidth}" />
        <c:set var="maxScaleWidth"  value="${maxScaleWidth < bsBpXxl ? bsBpXxl : maxScaleWidth}" />
        <c:set var="bsStatus"  value="${empty bsStatus ? 'Source: Defaults' : bsStatus}" />

        <c:set var="dataMap" value="${{
            'bsGutter': bsGutter,
            'maxScaleWidth': maxScaleWidth,
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

        <c:if test="${DEBUG}">
<!--
image-sizes writing data to cache:

${dataMap}
-->
        </c:if>

    </c:otherwise>
</c:choose>

<c:if test="${DEBUG}">
<!--
image-sizes result:

Gutter: ${bsGutter}
Max scale width: ${maxScaleWidth}

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
-->
</c:if>

<jsp:doBody/>