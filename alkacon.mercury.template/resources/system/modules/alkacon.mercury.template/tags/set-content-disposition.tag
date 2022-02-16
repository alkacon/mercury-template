<%@ tag pageEncoding="UTF-8"
    display-name="set-content-disposition"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Sets the response 'Content-Disposition' header." %>


<%@ attribute name="name" type="java.lang.String" required="true"
    description="The filename to set.
    Will be translated according to the OpenCms filename transltation rules.
    All dots '.' will be removed."%>

<%@ attribute name="suffix" type="java.lang.String" required="true"
    description="The suffix to append to the filename.
    Will not be translated or otherwise modified."%>

<%@ attribute name="setFilenameOnly" type="java.lang.Boolean" required="false"
    description="If this is 'true', then the header is not set but the filename is returned in the variable 'contentDispositionFilename'."%>


<%@ variable name-given="contentDispositionFilename" scope="AT_END" declare="true" variable-class="java.lang.String"
    description="The filename set for the content disposition." %>

<%

    String name = (String)getJspContext().getAttribute("name");
    String suffix = (String)getJspContext().getAttribute("suffix");
    Boolean setFilenameOnly = (Boolean)getJspContext().getAttribute("setFilenameOnly");
    boolean setHeader = (setFilenameOnly != null) ? !setFilenameOnly.booleanValue() : true;

    if (name.length() > 0) {
        name = name.replaceAll("[.]","");
        name = org.opencms.main.OpenCms.getResourceManager().getFileTranslator().translateResource(name);
    }

    String fileName = "" + name + suffix;
    if (setHeader) {
        response.setHeader("Content-Disposition","attachment; filename=" + fileName);
    }
    getJspContext().setAttribute("contentDispositionFilename", fileName);
%>