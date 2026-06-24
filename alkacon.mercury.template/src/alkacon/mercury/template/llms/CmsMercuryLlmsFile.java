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
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.file.types.CmsResourceTypeXmlContent;
import org.opencms.main.CmsException;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsStringUtil;
import org.opencms.util.CmsUUID;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

/**
 * Bean for the Mercury llms.txt configuration file.<p>
 */
public class CmsMercuryLlmsFile {

    /** Cached page result. */
    public static class Result {

        /** Container page path. */
        private String m_containerPage;

        /** Result text. */
        private String m_resultText;

        /**
         * Creates a result.<p>
         *
         * @param containerPage the container page path
         * @param resultText the result text
         */
        public Result(String containerPage, String resultText) {

            m_containerPage = containerPage;
            m_resultText = resultText;
        }

        /**
         * Returns the container page path.<p>
         *
         * @return the container page path
         */
        public String containerPage() {

            return m_containerPage;
        }

        /**
         * Returns the result text.<p>
         *
         * @return the result text
         */
        public String resultText() {

            return m_resultText;
        }

        /**
         * Sets the result text.<p>
         *
         * @param resultText the result text
         */
        public void setResultText(String resultText) {

            m_resultText = resultText;
        }
    }

    /** Section configuration. */
    public static class Section {

        /** The section id. */
        private String m_id;

        /** The section name. */
        private String m_name;

        /**
         * Creates a section.<p>
         *
         * @param id the id
         * @param name the name
         */
        public Section(String id, String name) {

            m_id = id;
            m_name = name;
        }

        /**
         * Returns the id.<p>
         *
         * @return the id
         */
        public String id() {

            return m_id;
        }

        /**
         * Returns the name.<p>
         *
         * @return the name
         */
        public String name() {

            return m_name;
        }
    }

    /** Resource type name. */
    public static final String TYPE_NAME = "m-llmstxt";

    /** Locale used by the llms.txt configuration. */
    public static final Locale LOCALE = Locale.ENGLISH;

    /** Node name. */
    public static final String NODE_CONTAINERPAGE = "ContainerPage";

    /** Node name. */
    public static final String NODE_DATE = "Date";

    /** Node name. */
    public static final String NODE_GALLERYTITLE = "GalleryTitle";

    /** Node name. */
    public static final String NODE_ID = "Id";

    /** Node name. */
    public static final String NODE_INTROTEXT = "IntroText";

    /** Node name. */
    public static final String NODE_NAME = "Name";

    /** Node name. */
    public static final String NODE_OUTROTEXT = "OutroText";

    /** Node name. */
    public static final String NODE_RESULT = "Result";

    /** Node name. */
    public static final String NODE_RESULTTEXT = "ResultText";

    /** Node name. */
    public static final String NODE_SECTION = "Section";

    /** Node name. */
    public static final String NODE_TITLE = "Title";

    /** Last generation date. */
    private long m_date;

    /** Gallery title. */
    private String m_galleryTitle;

    /** Intro text. */
    private String m_introText;

    /** Outro text. */
    private String m_outroText;

    /** Cached result entries. */
    private List<Result> m_results = new ArrayList<Result>();

    /** Cached result entries by page structure id. */
    private Map<CmsUUID, Result> m_resultsById = new LinkedHashMap<CmsUUID, Result>();

    /** Sections. */
    private List<Section> m_sections = new ArrayList<Section>();

    /** Title. */
    private String m_title;

    /**
     * Reads the bean from an XML content resource.<p>
     *
     * @param cms the CMS context
     * @param resource the llms.txt resource
     *
     * @return the file bean
     *
     * @throws CmsException if reading fails
     */
    public static CmsMercuryLlmsFile read(CmsObject cms, CmsResource resource) throws CmsException {

        CmsXmlContent content = CmsXmlContentFactory.unmarshal(cms, cms.readFile(resource));
        CmsMercuryLlmsFile result = new CmsMercuryLlmsFile();
        result.m_title = getString(content, cms, NODE_TITLE);
        result.m_introText = getString(content, cms, NODE_INTROTEXT);
        result.m_outroText = getString(content, cms, NODE_OUTROTEXT);
        result.m_galleryTitle = getString(content, cms, NODE_GALLERYTITLE);
        String date = getString(content, cms, NODE_DATE);
        result.m_date = CmsStringUtil.isNotEmptyOrWhitespaceOnly(date) ? Long.parseLong(date) : 0;
        for (I_CmsXmlContentValue sectionValue : content.getValues(NODE_SECTION, LOCALE)) {
            String prefix = sectionValue.getPath() + "/";
            String id = getString(content, cms, prefix + NODE_ID);
            String name = getString(content, cms, prefix + NODE_NAME);
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(id)) {
                result.m_sections.add(new Section(id, name));
            }
        }
        for (I_CmsXmlContentValue resultValue : content.getValues(NODE_RESULT, LOCALE)) {
            String prefix = resultValue.getPath() + "/";
            String page = getString(content, cms, prefix + NODE_CONTAINERPAGE);
            String text = getString(content, cms, prefix + NODE_RESULTTEXT);
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(page)) {
                Result resultEntry = new Result(page, text);
                result.m_results.add(resultEntry);
                try {
                    CmsResource pageRes = cms.readResource(page, CmsResourceFilter.ALL);
                    result.m_resultsById.put(pageRes.getStructureId(), resultEntry);
                } catch (CmsException e) {
                    // Keep stale cache entries even if their page can no longer be read.
                }
            }
        }
        return result;
    }

    /**
     * Gets a string value.<p>
     *
     * @param content the XML content
     * @param cms the CMS context
     * @param path the value path
     *
     * @return the string value
     */
    private static String getString(CmsXmlContent content, CmsObject cms, String path) {

        if (content.hasValue(path, LOCALE)) {
            return content.getStringValue(cms, path, LOCALE);
        }
        return "";
    }

    /**
     * Sets an optional string value.<p>
     *
     * @param content the XML content
     * @param cms the CMS context
     * @param path the value path
     * @param value the value
     *
     * @throws CmsException if setting fails
     */
    private static void setOptionalString(CmsXmlContent content, CmsObject cms, String path, String value)
    throws CmsException {

        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(value)) {
            if (!content.hasValue(path, LOCALE)) {
                content.addValue(cms, path, LOCALE, 0);
            }
            setString(content, cms, path, value);
        }
    }

    /**
     * Sets a string value.<p>
     *
     * @param content the XML content
     * @param cms the CMS context
     * @param path the value path
     * @param value the value
     */
    private static void setString(CmsXmlContent content, CmsObject cms, String path, String value) {

        content.getValue(path, LOCALE).setStringValue(cms, value != null ? value : "");
    }

    /**
     * Returns the last generated date.<p>
     *
     * @return the date
     */
    public long getDate() {

        return m_date;
    }

    /**
     * Returns the intro text.<p>
     *
     * @return the intro text
     */
    public String getIntroText() {

        return m_introText;
    }

    /**
     * Returns the outro text.<p>
     *
     * @return the outro text
     */
    public String getOutroText() {

        return m_outroText;
    }

    /**
     * Returns the result for a page.<p>
     *
     * @param page the container page
     *
     * @return the cached result, or null
     */
    public Result getResult(CmsResource page) {

        return m_resultsById.get(page.getStructureId());
    }

    /**
     * Returns the results.<p>
     *
     * @return the results
     */
    public List<Result> getResults() {

        return m_results;
    }

    /**
     * Returns the sections.<p>
     *
     * @return the sections
     */
    public List<Section> getSections() {

        return m_sections;
    }

    /**
     * Returns the title.<p>
     *
     * @return the title
     */
    public String getTitle() {

        return m_title;
    }

    /**
     * Removes cached results which do not belong to the given current pages.<p>
     *
     * @param cms the CMS context
     * @param pages the current pages
     *
     * @return true if cached results have been removed
     */
    public boolean retainResultsForPages(CmsObject cms, List<CmsResource> pages) {

        Set<String> pagePaths = new HashSet<String>();
        for (CmsResource page : pages) {
            pagePaths.add(cms.getSitePath(page));
        }
        boolean changed = false;
        List<Result> retainedResults = new ArrayList<Result>();
        Map<CmsUUID, Result> retainedResultsById = new LinkedHashMap<CmsUUID, Result>();
        for (Result result : m_results) {
            if (pagePaths.contains(result.containerPage())) {
                retainedResults.add(result);
                try {
                    CmsResource page = cms.readResource(result.containerPage(), CmsResourceFilter.ALL);
                    retainedResultsById.put(page.getStructureId(), result);
                } catch (CmsException e) {
                    // Ignore stale lookup failures while keeping matching path entries.
                }
            } else {
                changed = true;
            }
        }
        if (changed) {
            m_results = retainedResults;
            m_resultsById = retainedResultsById;
        }
        return changed;
    }

    /**
     * Sets the generated date.<p>
     *
     * @param date the date
     */
    public void setDate(long date) {

        m_date = date;
    }

    /**
     * Updates or adds a cached result.<p>
     *
     * @param page the container page
     * @param pagePath the page path to store
     * @param text the result text
     */
    public void setResult(CmsResource page, String pagePath, String text) {

        Result existing = m_resultsById.get(page.getStructureId());
        if (existing != null) {
            existing.setResultText(text);
        } else {
            Result result = new Result(pagePath, text);
            m_results.add(result);
            m_resultsById.put(page.getStructureId(), result);
        }
    }

    /**
     * Converts this bean into XML content.<p>
     *
     * @param cms the CMS context
     *
     * @return the XML content
     *
     * @throws CmsException if XML creation fails
     */
    public CmsXmlContent toXmlContent(CmsObject cms) throws CmsException {

        CmsXmlContent content = CmsXmlContentFactory.createDocument(
            cms,
            LOCALE,
            (CmsResourceTypeXmlContent)OpenCms.getResourceManager().getResourceType(TYPE_NAME));
        setString(content, cms, NODE_TITLE, m_title);
        setOptionalString(content, cms, NODE_INTROTEXT, m_introText);
        setOptionalString(content, cms, NODE_OUTROTEXT, m_outroText);
        setString(content, cms, NODE_DATE, String.valueOf(m_date));
        int index = 0;
        for (Section section : m_sections) {
            I_CmsXmlContentValue value = content.addValue(cms, NODE_SECTION, LOCALE, index);
            String prefix = value.getPath() + "/";
            setString(content, cms, prefix + NODE_ID, section.id());
            setString(content, cms, prefix + NODE_NAME, section.name());
            index++;
        }
        index = 0;
        for (Result result : m_results) {
            I_CmsXmlContentValue value = content.addValue(cms, NODE_RESULT, LOCALE, index);
            String prefix = value.getPath() + "/";
            setString(content, cms, prefix + NODE_CONTAINERPAGE, result.containerPage());
            setString(content, cms, prefix + NODE_RESULTTEXT, result.resultText());
            index++;
        }
        setOptionalString(content, cms, NODE_GALLERYTITLE, m_galleryTitle);
        return content;
    }
}
