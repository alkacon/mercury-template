<%@ tag
    pageEncoding="UTF-8"
    display-name="checkprincipal"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    import="org.opencms.main.*, org.opencms.file.*, org.opencms.security.*, org.opencms.jsp.util.*, java.util.*"
    description="Checks if the current user matches a given principal." %>


<%@ attribute name="type" type="java.lang.String" required="true"
    description="The principal type to check, can be 'role', 'group' or 'user'." %>

<%@ attribute name="name" type="java.lang.String" required="true"
    description="The name of the principal to check for, that is the role, group or user name." %>

<%!
    @SuppressWarnings("unchecked")
    public boolean checkPrincipal(CmsObject cms, String principalName, String principalType) {
    boolean result=false;
        try{
            if ("role".equals(principalType)){
                result = OpenCms.getRoleManager().hasRoleForResource(cms, CmsRole.valueOfRoleName(principalName), cms.getRequestContext().getUri());
            } else if ("group".equals(principalType)){
                CmsGroup group=cms.readGroup(principalName);
                List<CmsGroup> groups=cms.getGroupsOfUser(cms.getRequestContext().getCurrentUser().getName(), true, true);
                result = groups.contains(group);
            } else if ("user".equals(principalType)){
                result = cms.getRequestContext().getCurrentUser().getName().equals(principalName);
            }
        } catch(Exception e) {
            // ignore
        }
        return result;
    }

%><%

if (checkPrincipal(
    ((CmsJspStandardContextBean)getJspContext().findAttribute("cms")).getVfs().getCmsObject(),
    (String)getJspContext().getAttribute("name"),
    (String)getJspContext().getAttribute("type"))) { %>

    <jsp:doBody/>

<%  } %>

