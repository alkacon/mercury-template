<%@ tag pageEncoding="UTF-8"
    display-name="webform"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a Mercury Webform." %>
<%@ tag import="alkacon.mercury.webform.CmsFormMailSettings" %>

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
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}"/>
<cms:bundle basename="alkacon.mercury.template.messages">
<m:webform-vars
    webform="${webform}"
    bookingInfo="${bookingInfo}"
    formId="${formId}">
    <m:webform-captcha webform="${formXml}">

	    <c:if test="${isContactForm and not empty contactEmail}">
	        <div class="subelement type-webform-contactform pivot"><%----%>
	            <p><%----%>
	                <fmt:message key="msg.page.contact.form.head">
	                    <fmt:param>${contactName}</fmt:param>
	                </fmt:message>
	            </p><%----%>
	        </div><%----%>
	    </c:if>
	    <c:if test="${isContactForm and empty contactEmail and not cms.isEditMode}">
	        <m:alert-online>
	            <jsp:attribute name="head">
	                <fmt:message key="msg.page.contact.notfound.exception.head"/>
	            </jsp:attribute>
	            <jsp:attribute name="text">
	                <fmt:message key="msg.page.contact.notfound.exception.text"/>
	            </jsp:attribute>
	        </m:alert-online>
	    </c:if>

	    <c:if test="${not isContactForm or not empty contactEmail or cms.isEditMode}">
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
	                        <m:alert-online>
	                            <jsp:attribute name="head">
	                                <fmt:message key="msg.page.form.bookingstatus.registrationClosed.headline" />
	                            </jsp:attribute>
	                            <jsp:attribute name="text">
	                                <fmt:message key="msg.page.form.bookingstatus.registrationClosed.text" />
	                            </jsp:attribute>
	                        </m:alert-online>
	                    </c:when>
	                    <c:when test="${cms.wrap[formXml.file].propertySearch['mercury.form.disabled'] eq 'true'}">
	                        <m:alert-online>
	                            <jsp:attribute name="head">
	                                <fmt:message key="msg.page.form.disabled.headline" />
	                            </jsp:attribute>
	                            <jsp:attribute name="text">
	                                <fmt:message key="msg.page.form.disabled.text" />
	                            </jsp:attribute>
	                        </m:alert-online>
	                    </c:when>
	                    <c:otherwise>
	                        <c:if test="${not empty formCssWrapper}">
	                            ${form.addExtraConfig("formCssWrapper", formCssWrapper)}
	                        </c:if>
	                        <c:if test="${not empty formBookingXml}">
	                            <m:icalendar-vars content="${formBookingXml}">
	                            ${formHandler.setICalInfo(iCalLink, iCalFileName, iCalLabel)}
	                            </m:icalendar-vars>
	                            ${formHandler.setEventConfiguration(formBookingXml.filename)}
	                        </c:if>
	                        <c:set var="formMailSettings" value="${CmsFormMailSettings.getInstance()}"/>
	                        <c:set var="useDkimMailHost" value="${formMailSettings.useDkimMailHost(formHandler.cmsObject, formXml.file)}"/>
	                        <c:set var="validDkimDomains" value="${formMailSettings.validDkimDomains(formHandler.cmsObject)}"/>
	                        <c:set var="dkimDomains" value="${formMailSettings.getAttributeDkimDomains(formHandler.cmsObject)}"/>
	                        <c:set var="validDkimMailFrom" value="${formMailSettings.validDkimMailFrom(formHandler.cmsObject)}"/>
	                        <c:set var="dkimMailFrom" value="${formMailSettings.getAttributeDkimMailFrom(formHandler.cmsObject)}"/>
	                        <c:set var="validMailHost" value="${formMailSettings.validMailHost(formHandler.cmsObject, formXml.file)}"/>
	                        <c:choose>
	                            <c:when test="${validMailHost}">
	                                ${formHandler.createForm()}
	                            </c:when>
	                            <c:otherwise>
	                                <m:alert-online>
	                                    <jsp:attribute name="text">
	                                        <p><fmt:message key="msg.page.form.mailconfigerror.online" /></p>
	                                    </jsp:attribute>
	                                </m:alert-online>
	                                <m:alert type="error" test="${cms.isEditMode}">
	                                    <jsp:attribute name="head">
	                                        <fmt:message key="msg.page.form.mailconfigerror.headline" />
	                                    </jsp:attribute>
	                                    <jsp:attribute name="text">
	                                        <c:choose>
	                                            <c:when test="${useDkimMailHost and not validDkimDomains}">
	                                                <fmt:message key="msg.page.form.mailconfigerror.dkimdomains" />
	                                            </c:when>
	                                            <c:when test="${useDkimMailHost and not validDkimMailFrom}">
	                                                <fmt:message key="msg.page.form.mailconfigerror.dkimmailfrom">
	                                                    <fmt:param>${dkimMailFrom}</fmt:param>
	                                                    <fmt:param>${dkimDomains}</fmt:param>
	                                                </fmt:message>
	                                            </c:when>
	                                            <c:otherwise>
	                                                <fmt:message key="msg.page.form.mailconfigerror.mailhost" />
	                                            </c:otherwise>
	                                        </c:choose>
	                                    </jsp:attribute>
	                                </m:alert>
	                            </c:otherwise>
	                        </c:choose>
	                    </c:otherwise>
	                </c:choose>
	            </c:otherwise>
	        </c:choose>
	    </c:if>
	</m:webform-captcha>
</m:webform-vars>
</cms:bundle>