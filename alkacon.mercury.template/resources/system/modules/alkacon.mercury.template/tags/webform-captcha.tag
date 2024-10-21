<%@ tag pageEncoding="UTF-8"
    display-name="webform-captcha"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Checks the presence of a captcha." %>

<%@ attribute name="webform" type="java.lang.Object" required="true"
    description="The object to initialze the form with.
    This can be an XML content or a CmsResource representing a form, or a path to a form XML configuration." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:choose>
    <c:when test="${webform['class'].simpleName eq 'CmsJspContentAccessBean'}">
        <c:set var="formXml" value="${webform}" />
    </c:when>
    <c:otherwise>
        <c:set var="formXml" value="${cms.vfs.readXml[webform]}" />
    </c:otherwise>
</c:choose>

<%-- Check if form captcha is required from site attribute or property --%>
<c:choose>
    <c:when test="${cms.readAttributeOrProperty[cms.requestContext.uri]['captcha.required'] eq 'true'}">
        <c:set var="showCaptchaWarning" value="${not formXml.value.FormCaptcha.isSet ? true : false}" />
    </c:when>
    <c:otherwise>
        <c:set var="showCaptchaWarning" value="false" />
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${showCaptchaWarning}">
        <fmt:setLocale value="${cms.locale}"/>
		<cms:bundle basename="alkacon.mercury.template.messages">
	        <c:choose>
	        	<c:when test="${cms.isEditMode}">
	        	    <m:alert type="warning">
		                <jsp:attribute name="head">
		                    <fmt:message key="msg.page.form.captcha.required.headline.offline" />
		                </jsp:attribute>
		                <jsp:attribute name="text">
		                    <fmt:message key="msg.page.form.captcha.required.text.offline" />
		                </jsp:attribute>
		            </m:alert>
	        	</c:when>
	        	<c:otherwise>
		         	<m:alert-online>
		                <jsp:attribute name="head">
		                    <fmt:message key="msg.page.form.captcha.required.headline.online" />
		               	</jsp:attribute>
		                <jsp:attribute name="text">
		                    <fmt:message key="msg.page.form.captcha.required.text.online" />
		                </jsp:attribute>
		            </m:alert-online>
	        	</c:otherwise>
	        </c:choose>
        </cms:bundle>
    </c:when>
    <c:otherwise>
		<jsp:doBody/>
    </c:otherwise>
</c:choose>
