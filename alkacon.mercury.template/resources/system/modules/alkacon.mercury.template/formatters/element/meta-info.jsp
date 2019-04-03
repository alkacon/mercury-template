<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<mercury:init-messages>
<cms:formatter var="content" val="value">

<c:if test="${cms.isEditMode}">
    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">

    <mercury:nl />
    <div class="oct-meta"><%----%>
        <div class="marker"><%----%>
            <fmt:message key="msg.page.metainfo.marker" />
        </div><%----%>
    </div>
<%----%>

    </cms:bundle>
</c:if>

</cms:formatter>
</mercury:init-messages>