<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:formatter var="content" val="value">

<c:set var="disabledMessage"    value="${fn:replace(cms:stripHtml(value.DisabledMessage), '\"', '')}" />
<c:set var="ignore"             value="${cms.requestContext.setUri(param.path)} }" />

<c:set var="cookieDays"         value="${value.CookieExpirationDays.isSet ? value.CookieExpirationDays.toInteger : 0}" />
<c:if test="${cookieDays > 0}">
    <c:set var="acceptData">data-days="${cookieDays}"</c:set>
</c:if>

<c:set var="bannerHtml">
    <mercury:nl />
    <!DOCTYPE html><%----%>
    <html><%----%>
    <body><%----%>

    <div><%-- Outer DIV required otherwise JavaScript does not work --%>
    <div class="banner"><%----%>
        <div class="container"><%----%>
            <div class="title">${value.Title}</div><%----%>
            <div class="buttons"><%----%>
                <c:if test="${value.DeclineButtonText.isSet}"><%--
                --%><a class="btn btn-decline">${value.DeclineButtonText}</a><%--
            --%></c:if><%--
            --%><a class="btn btn-accept" ${acceptData}>${value.AcceptButtonText}</a><%----%>
            </div><%----%>
            <div class="message"><%----%>
                <div>${value.PolicyText}</div><%----%>
            </div><%----%>
        </div><%----%>
    </div><%----%>
    </div><%----%>

    </body><%----%>
    </html><%----%>
    <mercury:nl />
</c:set>

<cms:jsonobject var="bannerData">
    <cms:jsonvalue key="content" value="${content.json}" mode="object" />
    <cms:jsonvalue key="html" value="${bannerHtml}" />
</cms:jsonobject>

<%----%>${bannerData.verbose}<%----%>

</cms:formatter>