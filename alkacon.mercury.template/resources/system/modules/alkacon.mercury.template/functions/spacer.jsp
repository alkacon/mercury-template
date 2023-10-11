<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<mercury:init-messages>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="setting"            value="${cms.element.setting}" />

<c:set var="spaceMobile"        value="${setting.spaceMobile.toString}" />
<c:set var="spaceDesktop"       value="${setting.spaceDesktop.toString}" />
<c:set var="spaceColor"         value="${setting.spaceColor.toString}" />

<c:if test="${cms.isEditMode}">
    <c:set var="editStyle"      value=' style="min-height: 0 !important"' />
    <c:set var="ds"             value="${spaceDesktop eq 'mobile' ? spaceMobile : spaceDesktop}" />
    <c:if test="${(ds eq 'xs') or (ds eq 'sm') or (ds eq 'none')}">
        <c:set var="editClass"  value=' oc-point-T-10_L-25' />
    </c:if>
</c:if>

<div class="type-spacer pivot ${spaceMobile ne 'none' ? ' space-'.concat(spaceMobile) : '' }${spaceDesktop ne 'mobile' ? ' space-lg-'.concat(spaceDesktop) : '' }${not empty spaceColor ? ' '.concat(spaceColor) : ''}${editClass}"${editStyle}><%----%>
</div><%----%>
<mercury:nl />

</cms:bundle>
</mercury:init-messages>
