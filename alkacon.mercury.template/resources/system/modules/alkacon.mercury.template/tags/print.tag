<%@ tag pageEncoding="UTF-8"
    display-name="div"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Print text to the page with optimized white spaces." %>


<%@ attribute name="comment" type="java.lang.Boolean" required="false"
    description="If true, treat the body as HTML comment. Add comment markers before / after the text output and use a default delimiter of '\n'. " %>

<%@ attribute name="script" type="java.lang.Boolean" required="false"
    description="If true, treat the body as JavaScript. Set a default delimiter of ''. " %>

<%@ attribute name="delimiter" type="java.lang.String" required="false"
    description="Line breaks in the output will be replaced by this delimiter. Default is '\n'." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="Output the text in the body or not?" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<%!
public boolean getBoolean(String attr, boolean def) {
    Boolean av = (Boolean)getJspContext().getAttribute(attr);
    return (null == av) ? def : av.booleanValue();
}
public String getString(String attr, String def) {
    String sv = (String)getJspContext().getAttribute(attr);
    return (null == sv) ? def : sv;
}
%>

<%
boolean test = getBoolean("test", true);

if (test) {

    boolean isComment = getBoolean("comment", false);
    boolean isJs = getBoolean("script", false);
    String del = getString("delimiter", isJs ? "" : "\n");
    boolean compact = !"\n".equals(del);

    %><jsp:doBody var="body" /><%

    String bodyStr = String.valueOf(getJspContext().getAttribute("body"));
    java.util.List<String> lines = org.opencms.util.CmsStringUtil.splitAsList(bodyStr, '\n', true);
    String output = "";
    for (String line: lines) {
        line = line.trim();
        if (!compact || (line.length() > 0)) {
            output = output.concat(line).concat(del);
        }
    }
    output = output.trim();
    if (isComment && (output.length() > 0)) {
        output = "\n<!--\n".concat(output).concat("\n-->");
    }
    getJspContext().getOut().println(output);
}
%>

<%--
            if (
            (!compact || (line.length() > 0)) &&
            !((i == lines.size() && (line.length() == 0)))
        ) {
            output = output.concat(line).concat(del);
        }
    --%>