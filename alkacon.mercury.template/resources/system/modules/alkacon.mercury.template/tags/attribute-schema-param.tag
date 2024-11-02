<%@ tag pageEncoding="UTF-8"
    display-name="schema-param"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    import="org.opencms.file.*, org.opencms.jsp.util.*"
    description="Reads a value from the sitemap configuration attributes, using the schema-param configuration as fallback" %>

<%@ attribute name="param" type="java.lang.String" required="true"
    description="The parameter to read." %>

<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>

<%!
public String getParamValue() {
    CmsJspStandardContextBean contextBean = (CmsJspStandardContextBean)getJspContext().findAttribute("cms");
    String param = (String)getJspContext().getAttribute("param");

    // check sitemap attributes first
    // NOTE: if you just want to read from the sitemap attributes but do NOT need the fallback the the schema-param attributes,
    // use the EL expression ${cms.sitemapConfig.attribute['param']} directly, not this tag!
    CmsJspObjectValueWrapper value = contextBean.getSitemapConfig().getAttribute().get(param);

    String result;
    if (value.getIsSet()) {
        result = value.getToString();
    } else {
        // sitemap attribute is not set, use schema-params
        result =  org.opencms.configuration.CmsParameterStore.getInstance().getValue(contextBean.getVfs().getCmsObject(), param);
    }

    return result;
}
%>

<%= getParamValue() %>

