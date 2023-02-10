<%@ tag pageEncoding="UTF-8"
    display-name="out"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Alternative to c:out with support for special chars." %>

<%@ attribute name="value" type="java.lang.String" required="true"
    description="The String to outout." %>

<%@ attribute name="escapeXml" type="java.lang.Boolean" required="false"
    description="Similar to c:out escapeXml.
    Default is 'true'.
    If this is 'false' then this tag is identical to c:out." %>

<%@ attribute name="lenientEscaping" type="java.lang.Boolean" required="false"
    description="If this is 'true', then escapeXml is NOT enforced if the sitemap attribute 'template.lenient.escaping' is set to 'true'." %>

<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%!
//
public String replaceHtmlCodes(String text) {
    String result = text;
    if (result != null) {
        result = result.replace("&shy;", "\u00ad");
    }
    return result;
}
%>

<c:set var="lenientEscaping" value="${lenientEscaping ? cms.sitemapConfig.attribute['template.lenient.escaping'].toBoolean : false}" />
<c:set var="escapeXml" value="${empty escapeXml or escapeXml ? not lenientEscaping : false}" />
<%
   String value = (String)getJspContext().getAttribute("value");
   Boolean escapeXml = (Boolean)getJspContext().getAttribute("escapeXml");
   String outText = value;
   if (escapeXml.booleanValue()) {
       outText = replaceHtmlCodes(value);
   }
   getJspContext().setAttribute("outText", outText);
%>
<c:out value="${outText}" escapeXml="${escapeXml}" />


