/*
 * This program is part of the Alkacon OpenCms Mercury Template.
 *
 * Copyright (c) Alkacon Software GmbH & Co. KG (http://www.alkacon.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 */

package alkacon.mercury.template.llms;

import org.opencms.file.CmsObject;
import org.opencms.file.CmsRequestContext;
import org.opencms.file.CmsResource;
import org.opencms.main.CmsLog;
import org.opencms.widgets.CmsSelectWidget;
import org.opencms.widgets.CmsSelectWidgetOption;
import org.opencms.widgets.I_CmsWidget;
import org.opencms.widgets.I_CmsWidgetDialog;
import org.opencms.widgets.I_CmsWidgetParameter;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;

/**
 * Select widget that reads section options from the nearest Mercury llms.txt file.<p>
 */
public class CmsMercuryLlmsSectionSelectWidget extends CmsSelectWidget {

    /** Logger. */
    private static final Log LOG = CmsLog.getLog(CmsMercuryLlmsSectionSelectWidget.class);

    /**
     * Creates a widget.<p>
     */
    public CmsMercuryLlmsSectionSelectWidget() {

        super();
    }

    /**
     * Creates a widget.<p>
     *
     * @param configuration the configuration
     */
    public CmsMercuryLlmsSectionSelectWidget(String configuration) {

        super(configuration);
    }

    /**
     * @see org.opencms.widgets.I_CmsWidget#newInstance()
     */
    @Override
    public I_CmsWidget newInstance() {

        return new CmsMercuryLlmsSectionSelectWidget(getConfiguration());
    }

    /**
     * @see org.opencms.widgets.A_CmsSelectWidget#parseSelectOptions(org.opencms.file.CmsObject, org.opencms.widgets.I_CmsWidgetDialog, org.opencms.widgets.I_CmsWidgetParameter)
     */
    @Override
    protected List<CmsSelectWidgetOption> parseSelectOptions(
        CmsObject cms,
        I_CmsWidgetDialog widgetDialog,
        I_CmsWidgetParameter param) {

        String resourcePath = getResourcePath(cms, widgetDialog);
        String pageRootPath = (String)cms.getRequestContext().getAttribute(
            CmsRequestContext.ATTRIBUTE_ADE_CONTEXT_PATH);
        LOG.debug("Page root path for looking up select options: " + pageRootPath);

        if (pageRootPath != null && cms.existsResource(cms.getRequestContext().removeSiteRoot(pageRootPath))) {
            resourcePath = cms.getRequestContext().removeSiteRoot(pageRootPath);
        } else {
            LOG.debug("Fallback to path: " + resourcePath);
        }
        try {
            CmsResource resource = cms.readResource(resourcePath);
            return getOptions(cms, resource);
        } catch (Exception e) {
            return new ArrayList<CmsSelectWidgetOption>();
        }
    }

    /**
     * Gets the section options for a resource.<p>
     *
     * @param cms the CMS context
     * @param resource the resource
     *
     * @return the options
     */
    private List<CmsSelectWidgetOption> getOptions(CmsObject cms, CmsResource resource) {

        List<CmsSelectWidgetOption> result = new ArrayList<CmsSelectWidgetOption>();
        CmsResource llmsFileRes = CmsMercuryLlmsGenerator.findNearestLlmsFile(cms, resource);
        if (llmsFileRes != null) {
            LOG.debug("Loading llms.txt section options for resource " + cms.getSitePath(llmsFileRes));
            try {
                CmsMercuryLlmsFile llmsFile = CmsMercuryLlmsFile.read(cms, llmsFileRes);
                for (CmsMercuryLlmsFile.Section section : llmsFile.getSections()) {
                    result.add(new CmsSelectWidgetOption(section.id(), false, section.name()));
                }
            } catch (Exception e) {
                // Return an empty option list if the configuration can not be read.
            }
        }
        return result;
    }
}
