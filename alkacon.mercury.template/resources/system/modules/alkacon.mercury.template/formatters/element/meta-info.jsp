<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${cms.isEditMode}">

    <cms:secureparams />
    <mercury:init-messages>
    <cms:formatter var="content" val="value">

        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">

        <mercury:alert-meta icon="share-alt">
            <jsp:attribute name="text">
                <fmt:message key="msg.page.metainfo.marker" />
            </jsp:attribute>
        </mercury:alert-meta>

        </cms:bundle>

    </cms:formatter>
    </mercury:init-messages>

</c:if>
