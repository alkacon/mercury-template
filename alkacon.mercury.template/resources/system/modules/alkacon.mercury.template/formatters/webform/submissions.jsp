<%@page pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"
    import="alkacon.mercury.webform.*" %>


<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:formatter var="content">
    <c:set var="rawContent" value="${content.rawContent}" />
    <c:set var="bean" value='<%=new alkacon.mercury.webform.CmsFormDataBean((org.opencms.xml.I_CmsXmlDocument) pageContext.getAttribute("rawContent")) %>' />

    <fmt:setLocale value="${cms.locale}"/>
    <cms:bundle basename="alkacon.mercury.template.messages">

    <div class="accordion"><%----%>
        <div class="acco-header"><%----%>
            <c:set var="parentId" value="${cms.element.settings.id}" />
            <c:set var="itemId" value="${parentId}_${cms.element.settings.index}" />
            <a class="acco-toggle collapsed" data-toggle="collapse" data-parent="#${parentId}" href="#${itemId}"><%----%>
                <div class="h3"><%----%>
                    <c:choose>
                        <c:when test="${empty bean.titleProperty}">
                            <fmt:message key="msg.page.form.submission.title.default.1">
                                <fmt:param>
                                    <fmt:formatDate value="${cms:convertDate(content.file.dateCreated)}" type="both" dateStyle="short" timeStyle="short" />
                                </fmt:param>
                            </fmt:message>
                        </c:when>
                        <c:otherwise>${bean.titleProperty}</c:otherwise>
                    </c:choose>
                </div><%----%>
                <div class="book-info"><%----%>
                    <c:if test="${bean.changed}">
                        <span class="oct-meta-info severe"><fmt:message key="msg.page.form.status.submission.changed" /></span><%----%>
                    </c:if>
                    <c:if test="${ean.cancelled}">
                        <span class="oct-meta-info"><fmt:message key="msg.page.form.status.submission.cancelled" /></span><%----%>
                    </c:if>
                    <c:if test="${bean.waitlist}">
                        <span class="oct-meta-info"><fmt:message key="msg.page.form.status.submission.waitlist" /></span><%----%>
                    </c:if>
                    <c:if test="${bean.confirmationMailSent}">
                        <span class="oct-meta-info"><fmt:message key="msg.page.form.status.submission.confirmed" /></span><%----%>
                    </c:if>
                    <%--
                    <c:if test="${bean.registrationMailSent}">
                        <span class="oct-meta-info"><fmt:message key="msg.page.form.status.submission.mailed" /></span>
                    </c:if>
                    --%>
                </div><%----%>
            </a><%----%>
        </div><%----%>
        <mercury:nl />

        <div id="${itemId}" class="acco-body collapse" data-parent="#${parentId}"><%----%>
            <table class="submissions"><%----%>
                <c:forEach var="data" items="${bean.data}">
                    <tr><%----%>
                        <td>${data.key}:</td><%----%>
                        <td>${data.value}</td><%----%>
                    </tr><%----%>
                </c:forEach>
                <tr class="emphasize"><%----%>
                    <td><fmt:message key="msg.page.form.submission.date" /></td><%----%>
                    <td><fmt:formatDate type="both" dateStyle="long" timeStyle="long" value="${cms:convertDate(content.file.dateCreated)}" /></td><%----%>
                </tr><%----%>
            </table><%----%>
        </div><%----%>
        <mercury:nl />

    </div><%----%>
    <mercury:nl />

    </cms:bundle>

</cms:formatter>
