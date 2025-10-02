<%@ tag pageEncoding="UTF-8"
    display-name="read-user-preference"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Reads a value from the user preference settings." %>

<%@ tag import="java.lang.*, java.util.*, org.opencms.file.*, org.opencms.jsp.*, org.opencms.jsp.util.*, org.opencms.db.*" %>

<%@ attribute name="value" type="java.lang.String" required="true"
    description="The user setting preference to read." %>

<%@ attribute name="useDefault" type="java.lang.String" required="false"
    description="Default value in case the setting is not available." %>

<%@ attribute name="var" required="true" rtexprvalue="false"
    description="The name of the variable to store the value read from the user settings in." %>

<%@ variable alias="result" name-from-attribute="var" scope="AT_END" declare="true" %>

<%
    String value = (String)getJspContext().getAttribute("value");
    CmsObject cms =  ((CmsJspStandardContextBean)getJspContext().findAttribute("cms")).getVfs().getCmsObject();
    String result = org.opencms.db.CmsUserSettings.getAdditionalPreference(cms, value, true);
    if (result == null || (result.length() < 1)) {
        result = (String)getJspContext().getAttribute("useDefault");
    }
    getJspContext().setAttribute("result", result);
%>
