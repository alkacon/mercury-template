<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:formatter var="content">

    <mercury:webform
        webform="${content}"
        bookingInfo="${cms.element.setting.bookingInfo.toString}"
        formId="${cms.element.setting.formId.toString}"
        include="${false}"
    />

</cms:formatter>

