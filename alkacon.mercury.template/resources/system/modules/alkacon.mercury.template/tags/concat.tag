<%@ tag pageEncoding="UTF-8"
    display-name="alert"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Concats a list of string with white spaces." %>

<%@ tag import="java.lang.*,java.util.*" %>

<%@ attribute name="strings" type="java.util.List" required="true"
    description="The list of strings to concat." %>

<%@ attribute name="leadSpace" type="java.lang.Boolean" required="false"
    description="if 'true' (default), the result will start with a leading space in case there is at least one non empty string in strings." %>

<%@ attribute name="var" required="true" rtexprvalue="false"
    description="The name of the variable to store the generated string in." %>

<%@ variable alias="result" name-from-attribute="var" scope="AT_END" declare="true" %>

<%
    List strings = (List)getJspContext().getAttribute("strings");
    StringBuffer result = new StringBuffer(64);
    if (strings != null) {
        Boolean ls = (Boolean)getJspContext().getAttribute("leadSpace");
        boolean leadSpace = (ls == null) || ls.booleanValue();
        for (Object o : strings) {
            String str = (o != null ? o.toString() : "").trim();
            if (str.length() > 0) {
                if (leadSpace || (result.length() > 0)) result.append(" ");
                result.append(str);
            }
        }
    }
    getJspContext().setAttribute("result", result.toString());
%>
