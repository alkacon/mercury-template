<%@ tag pageEncoding="UTF-8"
    display-name="parse-multipart"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    import="
        java.util.*,
        javax.servlet.http.*,
        org.opencms.file.*,
        org.opencms.util.*,
        org.opencms.jsp.util.*,
        org.apache.commons.fileupload.*
    "
    description="Parses multipart request data." %>


<%@ variable name-given="paramMap" variable-class="java.util.Map" declare="true"
    description="The parameters read from the multipart request.
    If this is no mutlipart request, then the standard parameter map is returned." %>


<%!

// This was written to check parameters before processing a webform.
// However, once the multipart request is parsed, it can not be parsed again.
// See https://commons.apache.org/proper/commons-fileupload/faq.html#empty-parse
// So unfortunately this cannot be used in combination with a webform,
// because the webform will then get an empty parse.

public Map<String, String[]> getMultiPartParameters(HttpServletRequest request, String encoding) {

    Map<String, String[]> result;
    List<FileItem> fileItems = CmsRequestUtil.readMultipartFileItems(request);
    if (fileItems != null) {
        result = CmsRequestUtil.readParameterMapFromMultiPart(encoding, fileItems);
    } else {
        result = new HashMap<String, String[]>();
        result.putAll(request.getParameterMap());
    }
    return result;
}

%><%

PageContext pageContext = (PageContext)getJspContext();
HttpServletRequest req = (HttpServletRequest)pageContext.getRequest();
CmsObject cms = ((CmsJspStandardContextBean)getJspContext().findAttribute("cms")).getVfs().getCmsObject();
String enc = cms.getRequestContext().getEncoding();

Map<String, String[]> paramMap = getMultiPartParameters(req, enc);
pageContext.setAttribute("paramMap", paramMap);

%>
<jsp:doBody/>
