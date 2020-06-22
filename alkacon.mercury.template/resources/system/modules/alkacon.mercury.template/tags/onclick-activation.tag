<%@ tag pageEncoding="UTF-8"
    display-name="onclick-activation"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Reveals an element after the user clicks on a preview." %>


<%@ attribute name="data" type=" org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="true"
    description="Onclick activation data to use.
    If this is empty no onclick activation will be required." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' atttribute to set on the generated preview HTML." %>

<%@ attribute name="requireExternalCookies" type="java.lang.Boolean" required="false"
    description="If 'true' consent to external cookies is required to activate this element.
    In this case a modal dialog will be displayed, asking the user to confirm the use of external cookies." %>

<%@ attribute name="cookieMessage" type="java.lang.String" required="false"
    description="The message to show in the 'activate cookies' modal dialog." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<jsp:doBody var="template" />

<c:choose>
    <c:when test="${not empty data}">

        <c:set var="heading"    value="${data.value.Heading}" />
        <c:set var="notice"     value="${data.value.Notice}" />
        <c:set var="icon"       value="${data.value.Icon}" />
        <c:set var="ratio"      value="${data.value.Ratio}" />
        <c:set var="image"      value="${data.value.Image}" />
        <c:set var="bgColor"    value="${data.value.BgColor}" />

        <c:choose>
            <c:when test="${not empty ratio and ratio ne 'none'}">
                <c:set var="width" value="${cms:toNumber(fn:substringBefore(ratio, '-'), 16)}" />
                <c:set var="height" value="${cms:toNumber(fn:substringAfter(ratio, '-'), 9)}" />
                <c:set var="bottomPadding" value="${cms:mathRound((height / width) * 10000000) / 100000}" />
            </c:when>
            <c:when test="${not empty image}">
                <mercury:image-vars image="${image}">
                    <c:set var="width" value="${imageWidth}" />
                    <c:set var="height" value="${imageHeight}" />
                </mercury:image-vars>
            </c:when>
        </c:choose>

        <c:set var="displayType" value="${empty image and (empty ratio or ratio eq 'none') ? 'compact' : 'presized'}" />
        <c:set var="cssWrapper"  value="${empty cssWrapper ? displayType : cssWrapper.concat(' ').concat(displayType)}" />
        <c:set var="cssWrapper"  value="${cssWrapper.concat(empty image ? ' no-image' : ' has-image')}" />
        <c:set var="cssWrapper"  value="${cssWrapper.concat(empty icon ? ' no-icon' : ' has-icon')}" />

        <c:if test="${empty image}">
            <c:set var="cssStyle">
                <c:if test="${not empty bgColor}">background-color: ${bgColor}; </c:if>
                <c:if test="${not empty bottomPadding}">padding-bottom: ${bottomPadding}%;</c:if>
            </c:set>
        </c:if>

        <mercury:nl />
        <div <%--
        --%>class="onclick-activation ${cssWrapper}" <%--
        --%><c:if test="${not empty cssStyle}">style="${cssStyle}" </c:if><%--
        --%>data-preview='{"template":"${cms:encode(template)}"}'<%--
        --%><c:if test="${requireExternalCookies}"><mercury:data-external-cookies modal="${true}" message="${cookieMessage}" /></c:if><%--
        --%>><%----%>
            <c:if test="${not empty image}">
                <cms:addparams>
                    <cms:param name="cssgrid" value="col-xs-12" />
                    <mercury:image-animated
                        image="${image}"
                        ratio="${ratio}"
                        title="${not empty heading ? heading : (not empty notice ? notice : null)}"
                        ade="false"
                         />
                </cms:addparams>
            </c:if>
            <c:if test="${not empty heading}">
                <div class="oa-heading"><c:out value="${heading}" escapeXml="true" /></div><%----%>
            </c:if>
            <c:if test="${not empty icon and icon ne 'none'}">
                <div class="oa-icon centered"><%----%>
                    <span class="fa fa-${icon}"></span><%----%>
                    <mercury:alert-online showJsWarning="${true}" addNoscriptTags="${true}" />
                </div><%----%>
            </c:if>
            <c:if test="${not empty notice}">
                <div class="oa-notice"><c:out value="${notice}" escapeXml="true" /></div><%----%>
            </c:if>
        </div><%----%>
        <mercury:nl />
    </c:when>

    <c:when test="${!cms.isEditMode and requireExternalCookies}">
        <mercury:nl />
        <div <%--
            --%>class="onclick-activation ensure-external-cookies ${cssWrapper}" <%--
            --%>data-preview='{"template":"${cms:encode(template)}"}'<%--
            --%><mercury:data-external-cookies modal="${false}" message="${cookieMessage}" /><%--
        --%>></div><%----%>
        <mercury:nl />
    </c:when>

    <c:otherwise>
        <%-- ####### JSP body inserted here ######## --%>
        ${template}
        <%-- ####### /JSP body inserted here ######## --%>
    </c:otherwise>
</c:choose>
