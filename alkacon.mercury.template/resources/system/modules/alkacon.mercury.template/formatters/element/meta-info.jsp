<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${cms.isEditMode}">

    <cms:secureparams />
    <m:init-messages>
    <cms:formatter var="content" val="value">

        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">

        <m:alert-meta icon="share-alt">
            <jsp:attribute name="text">
                <fmt:message key="${value.SearchBoost.isSetNotNone ? 'msg.page.metainfo.marker.search' : 'msg.page.metainfo.marker'}" />
            </jsp:attribute>
        </m:alert-meta>

        </cms:bundle>

    </cms:formatter>
    </m:init-messages>

</c:if>
