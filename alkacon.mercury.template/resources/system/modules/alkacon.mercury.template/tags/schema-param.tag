<%@ tag pageEncoding="UTF-8"
    display-name="schema-param"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    import="org.opencms.file.*, org.opencms.jsp.util.*"
    description="Reads a parameters from the schema-param configuration" %>

<%@ attribute name="param" type="java.lang.String" required="true"
    description="The parameter to read." %>

<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>

<%!
public String readSchemaParam(CmsObject cms,  String paramKey) {
    return org.opencms.configuration.CmsParameterStore.getInstance().getValue(cms, paramKey);
}

%>

<%= readSchemaParam(
        ((CmsJspStandardContextBean)getJspContext().findAttribute("cms")).getVfs().getCmsObject(),
        (String)getJspContext().getAttribute("param")
) %>
