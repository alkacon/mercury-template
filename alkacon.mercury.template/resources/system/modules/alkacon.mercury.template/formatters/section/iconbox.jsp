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

<mercury:setting-defaults>

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="iconClass"              value="${setting.iconClass.isSet ? setting.iconClass.toString : 'warning'}" />

<c:set var="ade"                    value="${cms.isEditMode}"/>

<mercury:nl />
<div class="element type-iconbox pivot${setCssWrapperAll}><%----%>
<mercury:nl />

    <mercury:link link="${value.Link}" setTitle="${true}" css="icon-link">
        <mercury:heading level="${hsize}" text="${value.Title}" css="icon-title" ade="${ade}" />
        <c:if test="${iconClass ne 'none'}">
            <div class="icon-image fa fa-${iconClass}" aria-hidden="true" role="presentation"></div><%----%>
        </c:if>
        <c:if test="${value.Text.isSet}">
            <div class="icon-text" ${ade ? content.rdfa.Text : ''}>${value.Text}</div><%----%>
        </c:if>
    </mercury:link>

</div><%----%>
<mercury:nl />

</mercury:setting-defaults>

</cms:formatter>
</mercury:init-messages>