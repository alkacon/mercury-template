<%@page pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"
    import="alkacon.mercury.template.llms.CmsMercuryLlmsGenerator, org.opencms.jsp.CmsJspActionElement" %><%

response.setContentType("text/plain; charset=UTF-8");
CmsJspActionElement cms = new CmsJspActionElement(pageContext, request, response);
out.print(new CmsMercuryLlmsGenerator(cms.getCmsObject()).render());
%>
