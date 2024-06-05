<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<cms:formatter var="content" val="value">
<c:set var="hasScript" value="${cms.isEditMode and fn:contains(fn:toLowerCase(value.Code), 'script')}" />
<m:init-messages reload="${value.RequireReload.toBoolean or hasScript}">

<m:setting-defaults>

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="cssVisibility"          value="${value.RequireCookies.toBoolean ? null : setCssVisibility}" />

<m:nl />
<div class="element type-flexible pivot${setCssWrapper123}${cssVisibility}"><%----%>
<m:nl />

    <m:heading level="${hsize}" text="${value.Title}" css="heading" />

    <m:onclick-activation
        data="${value.OnclickActivation}"
        requireExternalCookies="${value.RequireCookies.toBoolean}"
        requireReload="${value.RequireReload.toBoolean}">

        ${value.Code}

    </m:onclick-activation>

</div><%----%>
<m:nl />

</m:setting-defaults>

</m:init-messages>
</cms:formatter>
