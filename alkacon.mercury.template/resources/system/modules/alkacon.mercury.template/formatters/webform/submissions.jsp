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
            <a class="acco-toggle collapsed" data-bs-toggle="collapse" data-bs-parent="#${parentId}" href="#${itemId}"><%----%>
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
                    <c:if test="${bean.cancelled}">
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

        <div id="${itemId}" class="acco-body collapse" data-bs-parent="#${parentId}"><%----%>
            <div class="submission-actions">
                <c:if test="${not submissionsDialogDeclared}">
                <script>
                    class SubmissionsDialog {
                        constructor(action, itemId, uuid) {
                            const button = document.getElementById(action + "_button_" + itemId);
                            const dialog = document.getElementById(action + "_dialog_" + itemId);
                            const params = new URLSearchParams(location.search);
                            const formmanage = params.get("formmanage");
                            button.addEventListener("click", () =>  { dialog.showModal(); });
                            dialog.addEventListener("close", () => {
                                if (dialog.returnValue == "confirm") {
                                    location.href = "?formmanage=" + formmanage + "&action=" + action + "&uuid=" + uuid;
                                }
                            });
                        }
                    }
                </script>
                </c:if>
                <c:set var="submissionsDialogDeclared" value="${true}" scope="request" />
                <c:if test="${not bean.cancelled}">
                    <button id="cancel_button_${itemId}" class="btn oct-meta-info btn-xs"><%----%>
                        <fmt:message key="msg.page.form.submission.action.cancel" />
                    </button><%----%>
                    <dialog id="cancel_dialog_${itemId}"><%----%>
                        <form method="dialog"><%----%>
                            <h3><fmt:message key="msg.page.form.submission.ask.cancel" /></h3><%----%>
                            <div class="buttons"><%----%>
                                <button value="cancel" class="btn"><%----%>
                                    <fmt:message key="msg.page.form.submission.dialog.cancel" />
                                </button><%----%>
                                <button value="confirm" class="btn"><%----%>
                                    <fmt:message key="msg.page.form.submission.confirm.cancel" />
                                </button><%----%>
                            </div><%----%>
                        </form><%----%>
                    </dialog><%----%>
                    <script>new SubmissionsDialog("cancel", "${itemId}", "${content.id}")</script><%----%>
                </c:if>
                <c:if test="${not bean.cancelled and bean.waitlist and param.fullyBooked eq 'false'}">
                    <button id="add_button_${itemId}" class="btn oct-meta-info btn-xs"><%----%>
                        <fmt:message key="msg.page.form.submission.action.add" />
                    </button><%----%>
                    <dialog id="add_dialog_${itemId}"><%----%>
                        <form method="dialog"><%----%>
                            <h3><fmt:message key="msg.page.form.submission.ask.add" /></h3><%----%>
                            <div class="buttons"><%----%>
                                <button value="cancel" class="btn"><%----%>
                                    <fmt:message key="msg.page.form.submission.dialog.cancel" />
                                </button><%----%>
                                <button value="confirm" class="btn"><%----%>
                                    <fmt:message key="msg.page.form.submission.confirm.add" />
                                </button><%----%>
                            </div><%----%>
                        </form><%----%>
                    </dialog><%----%>
                    <script>new SubmissionsDialog("add", "${itemId}", "${content.id}")</script><%----%>
                </c:if>
            </div><%----%>
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
