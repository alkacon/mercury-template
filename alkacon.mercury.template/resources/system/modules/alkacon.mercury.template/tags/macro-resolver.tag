<%@ tag pageEncoding="UTF-8"
    display-name="macro-resolver"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Provides an OpenCms macro resolver." %>


<%@ attribute name="cms" type="org.opencms.file.CmsObject"  required="false"
    description="The cms context to use for the macro resolver. If not provided the macro resolver will not have access to macros that require the CmsObject." %>

<%@ attribute name="addBreakpoints" type="java.lang.Boolean" required="false"
    description="If 'true' the configured bootstrap grid breakpoints will be added to the macro resolver. Default is 'false'." %>

<%@ attribute name="var" type="java.lang.String" required="true" rtexprvalue="false"
    description="The name of the variable to store the generated macro resolver in." %>


<%@ variable alias="resolver" name-from-attribute="var" scope="AT_END" declare="true" variable-class="org.opencms.util.CmsMacroResolver" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<%
    org.opencms.file.CmsObject cms = (org.opencms.file.CmsObject)getJspContext().getAttribute("cms");
    org.opencms.util.CmsMacroResolver resolver = org.opencms.util.CmsMacroResolver.newInstance();
    if (cms != null) {
        resolver.setCmsObject(cms);
    }
    resolver.setKeepEmptyMacros(true);
    getJspContext().setAttribute("resolver", resolver);
%>

<c:if test="${addBreakpoints}">
    <m:image-sizes>
        <c:set var="ignore"  value="${resolver.addMacro('xs-up', bsBpXs)}" />
        <c:set var="ignore"  value="${resolver.addMacro('sm-up', bsBpSm)}" />
        <c:set var="ignore"  value="${resolver.addMacro('sm-down', ''.concat(bsBpSm - 1).concat('.8'))}" />
        <c:set var="ignore"  value="${resolver.addMacro('md-up', bsBpMd)}" />
        <c:set var="ignore"  value="${resolver.addMacro('md-down', ''.concat(bsBpMd - 1).concat('.8'))}" />
        <c:set var="ignore"  value="${resolver.addMacro('lg-up', bsBpLg)}" />
        <c:set var="ignore"  value="${resolver.addMacro('lg-down', ''.concat(bsBpLg - 1).concat('.8'))}" />
        <c:set var="ignore"  value="${resolver.addMacro('xl-up', bsBpXl)}" />
        <c:set var="ignore"  value="${resolver.addMacro('xl-down', ''.concat(bsBpXl - 1).concat('.8'))}" />
        <c:set var="ignore"  value="${resolver.addMacro('xxl-up', bsBpXxl)}" />
        <c:set var="ignore"  value="${resolver.addMacro('xxl-down', ''.concat(bsBpXxl - 1).concat('.8'))}" />
    </m:image-sizes>
</c:if>


