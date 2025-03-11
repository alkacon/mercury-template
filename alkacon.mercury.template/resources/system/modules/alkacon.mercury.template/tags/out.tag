<%@ tag pageEncoding="UTF-8"
    display-name="out"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Alternative to c:out with support for special chars." %>

<%@ attribute name="value" type="java.lang.String" required="true"
    description="The String to output." %>

<%@ attribute name="escapeXml" type="java.lang.Boolean" required="false"
    description="Similar to c:out escapeXml, the difference being that even if 'true' (the default), the char '&' is NOT escaped to '&amp;'.
    This effectivly allows to use HTML entities like '&nbsp;' in the input.
    Otherwise this is identical to c:out." %>

<%@ attribute name="lenientEscaping" type="java.lang.Boolean" required="false"
    description="If this is 'true', then escapeXml is NOT enforced if the sitemap attribute 'template.lenient.escaping' is set to 'true'." %>

<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%!

// see: https://github.com/apache/tomcat/blob/main/java/org/apache/jasper/tagplugins/jstl/Util.java

public static final int HIGHEST_SPECIAL = '>';
public static char[][] specialCharactersRepresentation = new char[HIGHEST_SPECIAL + 1][];
static {
    // specialCharactersRepresentation['&'] = "&amp;".toCharArray();
    specialCharactersRepresentation['<'] = "&lt;".toCharArray();
    specialCharactersRepresentation['>'] = "&gt;".toCharArray();
    specialCharactersRepresentation['"'] = "&#034;".toCharArray();
    specialCharactersRepresentation['\''] = "&#039;".toCharArray();
}

public static String doEscapeXml(String buffer) {
    int start = 0;
    int length = buffer.length();
    char[] arrayBuffer = buffer.toCharArray();
    StringBuffer escapedBuffer = null;

    for (int i = 0; i < length; i++) {
        char c = arrayBuffer[i];
        if (c <= HIGHEST_SPECIAL) {
            char[] escaped = specialCharactersRepresentation[c];
            if (escaped != null) {
                // create StringBuffer to hold escaped xml string
                if (start == 0) {
                    escapedBuffer = new StringBuffer(length + 5);
                }
                // add unescaped portion
                if (start < i) {
                    escapedBuffer.append(arrayBuffer,start,i-start);
                }
                start = i + 1;
                // add escaped xml
                escapedBuffer.append(escaped);
            }
        }
    }
    // no xml escaping was necessary
    if (start == 0) {
        return buffer;
    }
    // add rest of unescaped portion
    if (start < length) {
        escapedBuffer.append(arrayBuffer,start,length-start);
    }
    return escapedBuffer.toString();
}
%>

<c:set var="lenientEscaping" value="${lenientEscaping ? cms.sitemapConfig.attribute['template.lenient.escaping'].toBoolean : false}" />
<c:set var="escapeXml" value="${empty escapeXml or escapeXml ? not lenientEscaping : false}" />
<%
   String value = (String)getJspContext().getAttribute("value");
   Boolean escapeXml = (Boolean)getJspContext().getAttribute("escapeXml");
   String outText = escapeXml.booleanValue() ? doEscapeXml(value) : value;
   getJspContext().setAttribute("outText", outText);
%>
<c:out value="${outText}" escapeXml="${false}" />


