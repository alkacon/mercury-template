<%@ tag pageEncoding="UTF-8"
    display-name="webform"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a Mercury Webform." %>

<%@ attribute name="webform" type="java.lang.Object" required="true"
    description="The object to initialze the form with.
    This can be an XML content or a CmsResource representing a form, or a path to a form XML configuration." %>

<%@ attribute name="bookingInfo" type="java.lang.Object" required="false"
    description="For booking forms, an object thet points to the additional booking settings.
    This can be an XML content or a path to a XML configuration that contains booking information." %>

<%@ attribute name="formId" type="java.lang.String" required="false"
    description="The optional ID for the form." %>

<%@ attribute name="include" type="java.lang.Boolean" required="false"
    description="If true, the webform will be loaded in a separate included element to avoid caching." %>

<%@ attribute name="formCssWrapper" type="java.lang.String" required="false"
    description="Optional CSS style wrapper for the generated form element." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}"/>
<cms:bundle basename="alkacon.mercury.template.messages">

    <mercury:webform-vars
        webform="${webform}"
        bookingInfo="${bookingInfo}"
        formId="${formId}">

        <c:choose>

            <c:when test="${include}">
                <%-- ###### Include the form from a separate file ###### --%>
                <cms:include file="/system/modules/alkacon.mercury.webform/elements/webform-included.jsp">
                    <cms:param name="content"       value="${formXml.id}" />
                    <cms:param name="bookingInfo"   value="${not empty formBookingXml ? formBookingXml.id : ''}" />
                    <cms:param name="formId"        value="${formId}" />
                </cms:include>
            </c:when>

            <c:otherwise>
                <%-- ###### Generate the form ###### --%>
                <c:if test="${formBookingPossible and form.userCanManage and cms.isEditMode}">
                    <div class="subelement"><%----%>
                        <a class="btn btn-block oct-meta-info" href="<cms:link>${adminLink}?formmanage=${formId.hashCode()}</cms:link>"><%----%>
                            <fmt:message key="msg.page.form.button.submissions.manage" />
                        </a><%----%>
                    </div><%----%>
                </c:if>
                <c:set var="formHandler" value="${form.createFormHandler(pageContext)}" /><%-- The form handler sets the X-Oc-Webform request header to 'YES'. --%>
                <c:choose>
                    <c:when test="${formBookingRegistrationClosed}">
                        <mercury:alert-online>
                            <jsp:attribute name="head">
                                <fmt:message key="msg.page.form.bookingstatus.registrationClosed.headline" />
                            </jsp:attribute>
                            <jsp:attribute name="text">
                                <fmt:message key="msg.page.form.bookingstatus.registrationClosed.text" />
                            </jsp:attribute>
                        </mercury:alert-online>
                    </c:when>
                    <c:when test="${cms.wrap[formXml.file].propertySearch['mercury.form.disabled'] eq 'true'}">
                        <mercury:alert-online>
                            <jsp:attribute name="head">
                                <fmt:message key="msg.page.form.disabled.headline" />
                            </jsp:attribute>
                            <jsp:attribute name="text">
                                <fmt:message key="msg.page.form.disabled.text" />
                            </jsp:attribute>
                        </mercury:alert-online>
                    </c:when>
                    <c:otherwise>
                        <c:if test="${not empty formCssWrapper}">
                            ${form.addExtraConfig("formCssWrapper", formCssWrapper)}
                        </c:if>
                        <mercury:icalendar-vars content="${formBookingXml}">
                        ${formHandler.setICalInfo(iCalLink, iCalFileName, iCalLabel)}
                        </mercury:icalendar-vars>
                        ${formHandler.createForm()}
                    </c:otherwise>
                </c:choose>
            </c:otherwise>

        </c:choose>

    </mercury:webform-vars>

</cms:bundle>
