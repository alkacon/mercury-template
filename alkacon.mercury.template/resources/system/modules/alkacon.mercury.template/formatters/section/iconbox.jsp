<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<mercury:init-messages>
<cms:formatter var="content" val="value">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="iconClass"              value="${setting.iconClass.isSet ? setting.iconClass.toString : 'warning'}" />

<c:set var="ade"                    value="${true}"/>

${nl}
<div class="element type-iconbox ${cssWrapper}">${nl}

    <mercury:link link="${value.Link}" setTitle="${true}" css="icon-link">
        <mercury:heading level="${hsize}" text="${value.Title}" css="icon-title" ade="${ade}" />
        <div class="icon-image fa fa-${iconClass}" aria-hidden="true" role="presentation"></div><%----%>
        <c:if test="${value.Text.isSet}">
            <div class="icon-text" ${ade ? content.rdfa.Text : ''}>${value.Text}</div><%----%>
        </c:if>
    </mercury:link>

</div>${nl}

</cms:formatter>
</mercury:init-messages>