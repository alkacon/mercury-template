<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<cms:formatter var="content" val="value">
<c:set var="hasScript" value="${cms.isEditMode and fn:contains(fn:toLowerCase(value.Code), 'script')}" />
<mercury:init-messages reload="${value.RequireReload.toBoolean or hasScript}">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />

<mercury:nl />
<div class="element type-flexible pivot ${cssWrapper}"><%----%>
<mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" css="heading" />

    <mercury:onclick-activation
        data="${value.OnclickActivation}"
        requireExternalCookies="${value.RequireCookies.toBoolean}">

        ${value.Code}

    </mercury:onclick-activation>

</div><%----%>
<mercury:nl />

</mercury:init-messages>
</cms:formatter>
