<%@ tag
    pageEncoding="UTF-8"
    display-name="teaser-settings"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Collects the common teaser settings." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content element that is formatted." %>

<%@ variable name-given="setting"           declare="true" variable-class="java.util.Map" %>
<%@ variable name-given="inList"            declare="true" variable-class="java.lang.Boolean" %>
<%@ variable name-given="setCssWrapper"     declare="true" %>
<%@ variable name-given="setEffect"         declare="true" %>
<%@ variable name-given="setDateFormat"     declare="true" %>
<%@ variable name-given="setRatio"          declare="true" %>
<%@ variable name-given="setTextLength"     declare="true" variable-class="java.lang.Integer" %>
<%@ variable name-given="setHsize"          declare="true" variable-class="java.lang.Integer" %>
<%@ variable name-given="setButtonText"     declare="true" %>
<%@ variable name-given="setShowIntro"      declare="true" variable-class="java.lang.Boolean" %>
<%@ variable name-given="setShowCalendar"   declare="true" variable-class="java.lang.Boolean" %>
<%@ variable name-given="setPieceLayout"    declare="true" %>
<%@ variable name-given="setSizeDesktop"    declare="true" %>
<%@ variable name-given="setSizeMobile"     declare="true" %>
<%@ variable name-given="setShowVisual"     declare="true" %>
<%@ variable name-given="pageUri"           declare="true" %>
<%@ variable name-given="displayType"       declare="true" %>

<%@ variable name-given="paragraph"         declare="true" %>
<%@ variable name-given="linkToDetail"      declare="true" %>

<c:set var="setting"                        value="${cms.element.setting}" />
<c:set var="inList"                         value="${setting.nglist.toBoolean}" />
<c:set var="setCssWrapper"                  value="${inList ? null : setting.cssWrapper.toString}" />
<c:set var="setEffect"                      value="${setting.effect.isSetNotNone ? setting.effect.toString : null}" />
<c:set var="setDateFormat"                  value="${setting.dateFormat.toString}" />
<c:set var="setRatio"                       value="${setting.imageRatio.toString}"/>
<c:set var="setTextLength"                  value="${setting.textLength.toInteger}" />
<c:set var="setHsize"                       value="${setting.hsize.toInteger}"/>
<c:set var="setButtonText"                  value="${setting.buttonText.toString}" />
<c:set var="setShowCalendar"                value="${setting.showCalendar.toBoolean}" />
<c:set var="setPieceLayout"                 value="${inList ? setting.pieceLayoutList.toInteger : setting.pieceLayout.toInteger}" />
<c:set var="setSizeDesktop"                 value="${setting.pieceSizeDesktop.toInteger}" />
<c:set var="setSizeMobile"                  value="${setting.pieceSizeMobile.toInteger}" />
<c:set var="setShowVisual"                  value="${setting.visualOption.toString ne 'none'}" />

<c:set var="pageUri"                        value="${setting.pageUri.toString}" />
<c:set var="requiredCssWrapper"             value="${setting.requiredCssWrapper.toString}" />
<c:set var="listEntryWrapper"               value="${setting.listEntryWrapper.toString}" />

<c:set var="displayType"                    value="${setting.displayType.toString}" />

<c:choose>
    <c:when test="${not setting.titleOption.isSet}">
    </c:when>
    <c:when test="${setting.titleOption.toString eq 'showIntro'}">
        <c:set var="setShowIntro"           value="${true}" />
    </c:when>
</c:choose>

<c:set var="paragraph"                      value="${content.valueList.Paragraph['0']}" />

<c:set var="linkToDetail"><cms:link baseUri="${pageUri}">${content.filename}</cms:link></c:set>

<c:if test="${not empty requiredCssWrapper}">
    <c:set var="setCssWrapper">${setCssWrapper}${' '}${requiredCssWrapper}</c:set>
</c:if>

<c:if test="${setting.dateFormatAddTime.toBoolean and fn:startsWith(setDateFormat, 'fmt-') and not fn:endsWith(setDateFormat, '-TIME')}">
    <c:set var="setDateFormat" value="${setDateFormat}-TIME" />
</c:if>

<c:if test="${not inList and not empty param.tilegrid}">
    <%-- Required if 'tile' list elements are used directly on the page in special 'tile' rows --%>
    ${'<div class=\"'}teaser-tile ${param.tilegrid}${'\" />'}
</c:if>

<jsp:doBody/>

<c:if test="${not inList and not empty param.tilegrid}">
    ${'</div>'}
</c:if>