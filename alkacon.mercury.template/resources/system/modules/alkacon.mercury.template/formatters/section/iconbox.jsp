<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<mercury:init-messages>
<cms:formatter var="content" val="value">

<mercury:setting-defaults>

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="iconClass"              value="${setting.iconClass.isSet ? setting.iconClass.toString : 'warning'}" />

<c:set var="hasLink"                value="${value.Link.isSet and value.Link.value.URI.isSet}"/>
<c:set var="ade"                    value="${not hasLink and cms.isEditMode}"/>

<mercury:nl />
<div class="element type-iconbox pivot${setCssWrapperAll}"><%----%>

    <mercury:link link="${value.Link}" setTitle="${true}" css="icon-link">
        <mercury:heading level="${hsize}" text="${value.Title}" css="icon-title" ade="${ade}" />
        <c:if test="${iconClass ne 'none'}">
            <mercury:icon icon="${iconClass}" tag="div" cssWrapper="icon-image" inline="${true}" />
            <mercury:nl />
        </c:if>
        <c:choose>
            <c:when test="${value.Text.isSet and fn:contains(value.Text.toString, 'href')}">
                <div class="icon-text">${cms:stripHtml(value.Text)}</div><%----%>
            </c:when>
            <c:when test="${value.Text.isSet}">
                <div class="icon-text" ${ade ? content.rdfa.Text : ''}>${value.Text}</div><%----%>
            </c:when>
        </c:choose>
    </mercury:link>

</div><%----%>
<mercury:nl />

</mercury:setting-defaults>

</cms:formatter>
</mercury:init-messages>