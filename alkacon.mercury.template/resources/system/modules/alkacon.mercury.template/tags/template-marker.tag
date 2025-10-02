<%@ tag pageEncoding="UTF-8"
    display-name="template-marker"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Template marker for the page editor toolbar." %>


<%@ attribute name="name" type="java.lang.String" required="true"
    description="The name of the template to display."%>

<%@ attribute name="showGrid" type="java.lang.Boolean" required="false"
    description="If 'true', then display bootstrap grid information with the template name. Requires special CSS. Default is 'false'."%>

<%@ attribute name="useDefault" type="java.lang.Boolean" required="false"
    description="Used as default in case the user preference 'showTemplateMarker' is not configured."%>

<%@ attribute name="inlineCss" type="java.lang.Boolean" required="false"
    description="If true, add inline CSS to display the basic marker. For templates where the CSS is not available. Will set 'showGrid' to 'false'."%>

<%@ attribute name="markerColor" type="java.lang.String" required="false"
    description="Hex value of marker color to use. Required only in case 'inlineCss' is 'true'."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${cms.isEditMode}">
    <m:read-user-preference var="showTemplateMarker" value="showTemplateMarker" useDefault="${false || useDefault}" />
    <c:if test="${showTemplateMarker}">
        <c:if test="${inlineCss}">
            <c:set var="showGrid" value="${false}" />
            <m:nl />
            <m:print delimiter="">
                <style>
                    #template-marker {
                        display: flex;
                        visibility: visible !important;
                        align-items: center !important;
                        position: fixed !important;
                        right: 230px !important;
                        top: 10px !important;
                        z-index: 300000 !important;
                        font-family: 'Open Sans', sans-serif !important;
                        font-weight: 400 !important;
                        padding: 0 6px !important;
                        white-space: nowrap !important;
                        border: none !important;
                        border-radius: 3px !important;
                        color: #fff !important;
                        background-color: ${empty markerColor ? '#474747' : markerColor} !important;
                        height: 30px !important;
                        line-height: 1 !important;
                        font-size: 18px !important;
                        cursor: default;
                    }

                    html.opencms-editor-active {
                        #template-marker {
                            display: none;
                        }
                    }
                </style>
            </m:print>
        </c:if>
        <oc-div id="template-marker"${inlineCss ? '' : ' style=\"display: none\"'}><%----%>
            <oc-div class="oc-marker-template">${name}</oc-div><%----%>
            <c:if test="${showGrid}">
                <oc-div class="oc-marker-size"></oc-div><%----%>
            </c:if>
        </oc-div><m:nl />
    </c:if>
</c:if>