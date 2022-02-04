<%@ tag pageEncoding="UTF-8"
    display-name="teaser-settings"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Collects default element settings." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content element that is formatted." %>


<%@ variable name-given="setting"           declare="true" variable-class="java.util.Map" %>
<%@ variable name-given="setCssWrapper1"    declare="true" %>
<%@ variable name-given="setCssWrapper2"    declare="true" %>
<%@ variable name-given="setCssWrapper3"    declare="true" %>
<%@ variable name-given="setCssWrapper12"   declare="true" %>
<%@ variable name-given="setCssWrapper123"  declare="true" %>
<%@ variable name-given="setCssWrapperAll"  declare="true" %>
<%@ variable name-given="setEffect"         declare="true" %>


<c:set var="setting"                        value="${cms.element.setting}" />
<c:set var="setCssWrapper1"                 value="${setting.cssWrapper.isSetNotNone ? ' '.concat(setting.cssWrapper.toString) : null}" />
<c:set var="setCssWrapper2"                 value="${setting.cssWrapper2.isSetNotNone ? ' '.concat(setting.cssWrapper2.toString) : null}" />
<c:set var="setCssWrapper3"                 value="${setting.cssWrapper3.isSetNotNone ? ' '.concat(setting.cssWrapper3.toString) : null}" />
<c:set var="setEffect"                      value="${setting.effect.isSetNotNone ? ' '.concat(setting.effect.toString) : null}" />
<c:set var="setCssWrapper12"                value="${setCssWrapper1}${setCssWrapper2}" />
<c:set var="setCssWrapper123"               value="${setCssWrapper12}${setCssWrapper3}" />
<c:set var="setCssWrapperAll"               value="${setCssWrapper123}${setEffect}" />


<jsp:doBody/>
