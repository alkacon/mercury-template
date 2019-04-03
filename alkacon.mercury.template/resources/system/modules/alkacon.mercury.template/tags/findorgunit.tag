<%@ tag
    pageEncoding="UTF-8"
    display-name="findorgunit"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    import="org.opencms.main.*, org.opencms.file.*, org.opencms.security.*, org.opencms.jsp.util.*, java.util.*"
    description="Returns the parent OUs for a VFS URI." %>


<%@ attribute name="uri" type="java.lang.String" required="true"
    description="The VFS URI to find the parent OUs for." %>

<%@ variable name-given="parentOUs" variable-class="java.util.List" declare="true"
    description="The found parent OUs of the VFS URI." %>

<%!
    @SuppressWarnings("unchecked")
    void getOrganizationalUnitsForResource(
        CmsObject cms,
        String resourceRootPath,
        CmsOrganizationalUnit parentOU,
        List<CmsOrganizationalUnit> ous) throws CmsException {

    List<CmsResource> resources= OpenCms.getOrgUnitManager().getResourcesForOrganizationalUnit(cms, parentOU.getName());
    boolean insideOU = false;

    for (CmsResource res : resources) {
        if (resourceRootPath.startsWith(res.getRootPath())) {
            insideOU = true;
            break;
        }
    }
    if (insideOU) {
        for (CmsOrganizationalUnit ou : OpenCms.getOrgUnitManager().getOrganizationalUnits(cms, parentOU.getName(), false)) {
            try {
                getOrganizationalUnitsForResource(cms, resourceRootPath, ou, ous);
            } catch (CmsException e) {
                // ignore
            }
        }
        ous.add(parentOU);
    }
 }

%><%

CmsObject cms = ((CmsJspStandardContextBean)getJspContext().findAttribute("cms")).getVfs().getCmsObject();
String rootPath = (String)getJspContext().getAttribute("uri");
List<CmsOrganizationalUnit> resultOUs = new ArrayList<>();

try {
    CmsOrganizationalUnit rootOU = OpenCms.getOrgUnitManager().readOrganizationalUnit(cms, "/");
    getOrganizationalUnitsForResource(cms, rootPath, rootOU, resultOUs);
} catch (CmsException e) {
    // ignore
}

getJspContext().setAttribute("parentOUs", resultOUs);
%>

<jsp:doBody/>


