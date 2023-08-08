<%@page pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"
    import="alkacon.mercury.webform.*" %>


<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:init-messages>
<cms:secureparams replaceInvalid="bad_param" />

<cms:formatter var="content">

<mercury:setting-defaults>

<div class="element type-webform${setCssWrapperAll} pivot">

    <c:set var="formId" value="${cms.element.id.stringValue}" />
    <c:set var="fid" value="${formId.hashCode()}" />

    <c:choose>
    <%-- ###### Manage form entries ###### --%>
    <c:when test="${(not empty param.formmanage) and (param.formmanage eq fid)}">
        <mercury:webform-booking-manage
            webform="${content}"
            bookingInfo="${cms.element.setting.bookingInfo}"
        />
    </c:when>
    <c:otherwise>
        <%-- ###### Display form for submission ###### --%>
        <mercury:webform
            webform="${content}"
            bookingInfo="${cms.element.setting.bookingInfo}"
            formCssWrapper="${cms.element.setting.formCssWrapper}"
            formId="${formId}"
        />
    </c:otherwise>
    </c:choose>

</div>

</mercury:setting-defaults>
</cms:formatter>

</mercury:init-messages>

