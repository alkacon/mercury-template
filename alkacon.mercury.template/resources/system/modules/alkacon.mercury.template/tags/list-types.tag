<%@ tag pageEncoding="UTF-8"
    display-name="list-types"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    import="org.opencms.file.*, org.opencms.jsp.util.*,java.util.*,org.opencms.util.*"
    description="Generates the list of types for which the list-messages tag should be called from the configured types of a list." %>

<%@ attribute name="types" type="java.util.List" required="true" %>
<%@ attribute name="uploadFolder" type="java.lang.String" required="true" %>
<%@ attribute name="var" type="java.lang.String" required="true" rtexprvalue="false" %>
<%@ variable alias="output" name-from-attribute="var" scope="AT_END" declare="true"  %>

<%
List<CmsJspContentAccessValueWrapper> types = (List<CmsJspContentAccessValueWrapper>)getJspContext().getAttribute("types");
List<String> output = new ArrayList<>();
boolean uploadAdded = false; 
for (CmsJspContentAccessValueWrapper typeElem: types) { 
    String value = typeElem.toString().replaceFirst(":.*$", "");
    if (Arrays.asList("binary", "plain", "image").contains(value)) {
        if (!uploadAdded && !CmsStringUtil.isEmptyOrWhitespaceOnly((String) (getJspContext().getAttribute("uploadFolder")))) {
            output.add("binary");
            uploadAdded = true;
        }
    } else {
        output.add(value);
    }
}
getJspContext().setAttribute("output", output);
%>
