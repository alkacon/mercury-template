<%@ tag pageEncoding="UTF-8"
    display-name="div"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Outputs an optional HTML comment." %>

<%@ attribute name="test" type="java.lang.Boolean" required="true"
    description="Output the comment in the body or not?" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<%
Boolean testParam = (Boolean)(getJspContext().getAttribute("test"));
boolean test = (testParam != null) && testParam.booleanValue();
if (test) {
%>
<jsp:doBody var="body" />
<%
    String bodyStr = String.valueOf(getJspContext().getAttribute("body"));
    java.util.List<String> lines = org.opencms.util.CmsStringUtil.splitAsList(bodyStr, '\n', true);
    String comment = "";
    int i = 1;
    for (String line: lines) {
        if (!((i == lines.size() && (line.length() == 0)))) {
            comment = comment.concat(line).concat("\n");
        }
        i++;
    }
%>
<%= "\n<!--\n" %>
<%= comment %>
<%= "-->\n" %>
<% } %>