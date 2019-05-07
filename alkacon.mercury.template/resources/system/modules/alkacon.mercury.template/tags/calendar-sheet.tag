<%@tag
    pageEncoding="UTF-8"
    display-name="nl"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Outputs a new line in the source code." %>

<%@ attribute name="date" type="java.util.Date" required="true"
    description="The date shown in the calendar sheet." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the generated div tag" %>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="Can be used to scale the calendar sheet in a specific ratio.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="hideDay" type="java.lang.Boolean" required="false"
    description="Controls if the day is hidden in the calendar sheet." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<fmt:setLocale value="${cms.locale}" />

<mercury:nl />
<div class="effect-box ${css}"><%----%>
    <mercury:padding-box cssWrapper="image-src-box" ratio="${ratio}" defaultRatio="${hideDay ? '1-1' : '1200-1416'}">
        <div class="calendar-sheet animated"><%----%>
            <c:if test="${not hideDay}">
                <span class="day-name"><fmt:formatDate value="${date}" pattern="EEEE" type="date" /></span><%----%>
            </c:if>
            <span class="day-number"><fmt:formatDate value="${date}" pattern="d" type="date" /></span><%----%>
            <span class="month-year"><fmt:formatDate value="${date}" pattern="MMM yyyy" type="date" /></span><%----%>
        </div><%----%>
    </mercury:padding-box>
</div><%----%>
<mercury:nl />