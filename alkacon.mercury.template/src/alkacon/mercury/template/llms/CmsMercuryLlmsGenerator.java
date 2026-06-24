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

import org.opencms.file.CmsFile;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsPropertyDefinition;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.file.types.CmsResourceTypeXmlContainerPage;
import org.opencms.file.types.I_CmsResourceType;
import org.opencms.lock.CmsLock;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.relations.CmsRelation;
import org.opencms.relations.CmsRelationFilter;
import org.opencms.security.I_CmsSecretStore;
import org.opencms.util.CmsStringUtil;
import org.opencms.util.CmsUUID;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;

import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

import dev.langchain4j.data.message.SystemMessage;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.model.chat.ChatModel;
import dev.langchain4j.model.chat.request.ChatRequest;
import dev.langchain4j.model.openai.OpenAiChatModel;

/**
 * Generates and renders Mercury llms.txt files.<p>
 */
public class CmsMercuryLlmsGenerator {

    /** Current llms.txt candidate. */
    public static class Candidate {

        /** Container page. */
        private CmsResource m_page;

        /** Meta info resource. */
        private CmsResource m_metaInfo;

        /** Section id. */
        private String m_section;

        /** Individual llms.txt description. */
        private String m_llmsDescription;

        /** Shared meta info description. */
        private String m_sharedDescription;

        /** Page title. */
        private String m_title;

        /** Page URL. */
        private String m_url;

        /**
         * Creates a candidate.<p>
         *
         * @param page the page
         * @param metaInfo the meta info resource
         * @param section the section id
         * @param llmsDescription the individual llms.txt description
         * @param sharedDescription the shared description
         * @param title the title
         * @param url the URL
         */
        public Candidate(
            CmsResource page,
            CmsResource metaInfo,
            String section,
            String llmsDescription,
            String sharedDescription,
            String title,
            String url) {

            m_page = page;
            m_metaInfo = metaInfo;
            m_section = section;
            m_llmsDescription = llmsDescription;
            m_sharedDescription = sharedDescription;
            m_title = title;
            m_url = url;
        }

        /** @return the individual llms.txt description */
        public String llmsDescription() {

            return m_llmsDescription;
        }

        /** @return the meta info resource */
        public CmsResource metaInfo() {

            return m_metaInfo;
        }

        /** @return the container page */
        public CmsResource page() {

            return m_page;
        }

        /** @return the section id */
        public String section() {

            return m_section;
        }

        /** @return the shared description */
        public String sharedDescription() {

            return m_sharedDescription;
        }

        /** @return the title */
        public String title() {

            return m_title;
        }

        /** @return the URL */
        public String url() {

            return m_url;
        }
    }

    /** Node name in m-metainfo. */
    public static final String NODE_DESCRIPTION = "Description";

    /** Node name in m-metainfo. */
    public static final String NODE_TITLE = "Title";

    /** Node name in m-metainfo. */
    public static final String NODE_LLMS_DESCRIPTION = "LlmsTxtSettings/Description";

    /** Node name in m-metainfo. */
    public static final String NODE_LLMS_INCLUDE = "LlmsTxtSettings/Include";

    /** Node name in m-metainfo. */
    public static final String NODE_LLMS_SECTION = "LlmsTxtSettings/Section";

    /** Type name for meta info elements. */
    public static final String TYPE_METAINFO = "m-metainfo";

    /** Logger. */
    private static final Log LOG = CmsLog.getLog(CmsMercuryLlmsGenerator.class);

    /** Object mapper. */
    private static final ObjectMapper MAPPER = new ObjectMapper();

    /** Query timeout in minutes. */
    private static final int QUERY_TIMEOUT = 5;

    /** Render connect timeout. */
    private static final int RENDER_CONNECT_TIMEOUT = 10000;

    /** Render read timeout. */
    private static final int RENDER_READ_TIMEOUT = 30000;

    /** Secret store key. */
    private static final String SECRET_APIKEY = "seo.llms.apikey";

    /** Secret store key. */
    private static final String SECRET_BASEURL = "seo.llms.baseurl";

    /** Secret store key. */
    private static final String SECRET_MODEL = "seo.llms.model";

    /** System prompt. */
    private static final String SYSTEM_PROMPT_SUMMARY = """
    # Page Summary Generator for llms.txt

    Generate a concise summary of 1-2 sentences for the given page, suitable for inclusion in an llms.txt file.
    Use only the information from the title and excerpt. Write in the same language as the input.
    Output only the summary text, no preamble, links, headers, or code blocks.""";

    /** Chat model. */
    private ChatModel m_chatModel;

    /** CMS context. */
    private CmsObject m_cms;

    /** The llms.txt resource. */
    private CmsResource m_llmsResource;

    /**
     * Creates a generator.<p>
     *
     * @param cms the CMS context
     *
     * @throws CmsException if reading the current resource fails
     */
    public CmsMercuryLlmsGenerator(CmsObject cms)
    throws CmsException {

        this(cms, cms.readResource(cms.getRequestContext().getUri()));
    }

    /**
     * Creates a generator.<p>
     *
     * @param cms the CMS context
     * @param llmsResource the llms.txt resource
     */
    public CmsMercuryLlmsGenerator(CmsObject cms, CmsResource llmsResource) {

        m_cms = cms;
        m_llmsResource = llmsResource;
    }

    /**
     * Finds the nearest llms.txt configuration for a resource.<p>
     *
     * @param cms the CMS context
     * @param resource the resource to start from
     *
     * @return the nearest configuration, or null
     */
    public static CmsResource findNearestLlmsFile(CmsObject cms, CmsResource resource) {

        try {
            CmsResource start = resolveContainerPage(cms, resource);
            String folder = CmsResource.getParentFolder(cms.getSitePath(start));
            I_CmsResourceType type = OpenCms.getResourceManager().getResourceType(CmsMercuryLlmsFile.TYPE_NAME);
            while (CmsStringUtil.isNotEmptyOrWhitespaceOnly(folder)) {
                List<CmsResource> files = cms.readResources(
                    folder,
                    CmsResourceFilter.DEFAULT_FILES.addRequireType(type),
                    false);
                if (!files.isEmpty()) {
                    return files.get(0);
                }
                if ("/".equals(folder)) {
                    break;
                }
                folder = CmsResource.getParentFolder(folder);
            }
        } catch (Exception e) {
            LOG.debug("Failed to find nearest Mercury llms.txt file for " + resource.getRootPath(), e);
        }
        return null;
    }

    /**
     * Resolves the container page for a resource.<p>
     *
     * @param cms the CMS context
     * @param resource the resource
     *
     * @return the container page or the original resource
     */
    private static CmsResource resolveContainerPage(CmsObject cms, CmsResource resource) {

        if (CmsResourceTypeXmlContainerPage.isContainerPage(resource)) {
            return resource;
        }
        try {
            List<CmsRelation> relations = cms.getRelationsForResource(resource, CmsRelationFilter.TARGETS);
            for (CmsRelation relation : relations) {
                CmsResource source = relation.getSource(cms, CmsResourceFilter.DEFAULT);
                if (CmsResourceTypeXmlContainerPage.isContainerPage(source)) {
                    return source;
                }
            }
        } catch (CmsException e) {
            LOG.debug("Failed to resolve container page for " + resource.getRootPath(), e);
        }
        return resource;
    }

    /**
     * Renders the llms.txt file.<p>
     *
     * @return the rendered text
     *
     * @throws Exception if rendering fails
     */
    public String render() throws Exception {

        if (!m_cms.getRequestContext().getCurrentProject().isOnlineProject()) {
            updateLlmsFile();
        }
        CmsMercuryLlmsFile llmsFile = CmsMercuryLlmsFile.read(m_cms, m_llmsResource);
        List<Candidate> candidates = resolveEligiblePages();
        return render(llmsFile, candidates);
    }

    /**
     * Resolves currently eligible pages.<p>
     *
     * @return the candidates
     *
     * @throws CmsException if resolving fails
     */
    public List<Candidate> resolveEligiblePages() throws CmsException {

        List<Candidate> result = new ArrayList<Candidate>();
        String baseFolder = CmsResource.getParentFolder(m_cms.getSitePath(m_llmsResource));
        if (!baseFolder.equals("/")) {
            // this assures that all meta info elements are found for a multi language structure
            baseFolder = CmsResource.getParentFolder(baseFolder);
        }
        I_CmsResourceType type = OpenCms.getResourceManager().getResourceType(TYPE_METAINFO);
        List<CmsResource> metaInfos = m_cms.readResources(
            baseFolder,
            CmsResourceFilter.DEFAULT_FILES.addRequireType(type),
            true);
        if (LOG.isDebugEnabled()) {
            LOG.debug(
                "Resolving Mercury llms.txt candidates for "
                    + m_cms.getSitePath(m_llmsResource)
                    + " below "
                    + baseFolder
                    + ": found "
                    + metaInfos.size()
                    + " m-metainfo resources.");
        }
        Map<CmsUUID, Candidate> byPage = new LinkedHashMap<CmsUUID, Candidate>();
        for (CmsResource metaInfo : metaInfos) {
            CmsXmlContent content = CmsXmlContentFactory.unmarshal(m_cms, m_cms.readFile(metaInfo));
            for (Locale locale : content.getLocales()) {
                if (!content.hasValue(NODE_LLMS_INCLUDE, locale)) {
                    if (LOG.isDebugEnabled()) {
                        LOG.debug(
                            "Skipping m-metainfo "
                                + m_cms.getSitePath(metaInfo)
                                + " for locale "
                                + locale
                                + ": no "
                                + NODE_LLMS_INCLUDE
                                + " value.");
                    }
                    continue;
                }
                if (!Boolean.parseBoolean(content.getStringValue(m_cms, NODE_LLMS_INCLUDE, locale))) {
                    if (LOG.isDebugEnabled()) {
                        LOG.debug(
                            "Skipping m-metainfo "
                                + m_cms.getSitePath(metaInfo)
                                + " for locale "
                                + locale
                                + ": llms.txt include is not enabled.");
                    }
                    continue;
                }
                CmsResource page = getContainerPageForMetaInfo(metaInfo, locale);
                if (page == null) {
                    if (LOG.isDebugEnabled()) {
                        LOG.debug(
                            "Skipping m-metainfo "
                                + m_cms.getSitePath(metaInfo)
                                + " for locale "
                                + locale
                                + ": no related container page with matching locale found.");
                    }
                    continue;
                }
                String section = content.hasValue(NODE_LLMS_SECTION, locale)
                ? content.getStringValue(m_cms, NODE_LLMS_SECTION, locale)
                : "";
                String llmsDescription = content.hasValue(NODE_LLMS_DESCRIPTION, locale)
                ? content.getStringValue(m_cms, NODE_LLMS_DESCRIPTION, locale)
                : "";
                String sharedDescription = content.hasValue(NODE_DESCRIPTION, locale)
                ? content.getStringValue(m_cms, NODE_DESCRIPTION, locale)
                : "";
                if (LOG.isDebugEnabled()) {
                    LOG.debug(
                        "Adding Mercury llms.txt candidate page "
                            + m_cms.getSitePath(page)
                            + " from "
                            + m_cms.getSitePath(metaInfo)
                            + " locale "
                            + locale
                            + " section '"
                            + section
                            + "'.");
                    if (byPage.containsKey(page.getStructureId())) {
                        LOG.debug(
                            "Replacing previous Mercury llms.txt candidate for page "
                                + m_cms.getSitePath(page)
                                + " because the same structure id was resolved again.");
                    }
                }
                byPage.put(
                    page.getStructureId(),
                    new Candidate(
                        page,
                        metaInfo,
                        section,
                        llmsDescription,
                        sharedDescription,
                        getTitle(page, content, locale),
                        getUrl(page)));
            }
        }
        result.addAll(byPage.values());
        if (LOG.isDebugEnabled()) {
            LOG.debug(
                "Resolved "
                    + result.size()
                    + " Mercury llms.txt candidates for "
                    + m_cms.getSitePath(m_llmsResource)
                    + ".");
        }
        return result;
    }

    /**
     * Updates cached AI results in offline mode.<p>
     *
     * @return true if the file was updated
     *
     * @throws Exception if updating fails
     */
    public boolean updateLlmsFile() throws Exception {

        if (m_cms.getRequestContext().getCurrentProject().isOnlineProject()) {
            return false;
        }
        CmsFile file = m_cms.readFile(m_llmsResource);
        CmsMercuryLlmsFile llmsFile = CmsMercuryLlmsFile.read(m_cms, m_llmsResource);
        List<Candidate> resolvedCandidates = resolveEligiblePages();
        List<Candidate> candidates = filterCandidatesForConfiguredSections(llmsFile, resolvedCandidates);
        if (LOG.isDebugEnabled()) {
            LOG.debug(
                "Updating Mercury llms.txt summaries for "
                    + m_cms.getSitePath(m_llmsResource)
                    + ": "
                    + resolvedCandidates.size()
                    + " eligible candidates, "
                    + candidates.size()
                    + " candidates matching configured sections, file date "
                    + llmsFile.getDate()
                    + ".");
        }
        boolean changed = llmsFile.retainResultsForPages(m_cms, getPages(candidates));
        if (changed && LOG.isDebugEnabled()) {
            LOG.debug(
                "Removed obsolete Mercury llms.txt cached results from " + m_cms.getSitePath(m_llmsResource) + ".");
        }
        for (Candidate candidate : candidates) {
            CmsMercuryLlmsFile.Result cached = llmsFile.getResult(candidate.page());
            long pageDate = candidate.page().getDateLastModified();
            long metaInfoDate = candidate.metaInfo().getDateLastModified();
            long candidateDate = Math.max(pageDate, metaInfoDate);
            if ((cached == null) || (llmsFile.getDate() < candidateDate)) {
                if (LOG.isDebugEnabled()) {
                    LOG.debug(
                        "Generating Mercury llms.txt summary for "
                            + m_cms.getSitePath(candidate.page())
                            + ": cached="
                            + (cached != null)
                            + ", page last modified="
                            + pageDate
                            + ", meta info last modified="
                            + metaInfoDate
                            + ".");
                }
                String summary = generateSummary(candidate);
                llmsFile.setResult(candidate.page(), m_cms.getSitePath(candidate.page()), summary);
                changed = true;
            } else if (LOG.isDebugEnabled()) {
                LOG.debug(
                    "Keeping cached Mercury llms.txt summary for "
                        + m_cms.getSitePath(candidate.page())
                        + ": cached result is current.");
            }
        }
        if (changed) {
            llmsFile.setDate(new Date().getTime() + 10000);
            file.setContents(llmsFile.toXmlContent(m_cms).marshal());
            write(file);
            if (LOG.isDebugEnabled()) {
                LOG.debug("Updated Mercury llms.txt file " + m_cms.getSitePath(m_llmsResource) + ".");
            }
        } else if (LOG.isDebugEnabled()) {
            LOG.debug("No Mercury llms.txt summary updates required for " + m_cms.getSitePath(m_llmsResource) + ".");
        }
        return changed;
    }

    /**
     * Escapes link text for markdown.<p>
     *
     * @param text the text
     *
     * @return the escaped text
     */
    private String escapeLinkText(String text) {

        return text != null ? text.replace("[", "\\[").replace("]", "\\]") : "";
    }

    /**
     * Filters candidates to the sections configured in this llms.txt file.<p>
     *
     * @param llmsFile the llms file
     * @param candidates the candidates
     *
     * @return the filtered candidates
     */
    private List<Candidate> filterCandidatesForConfiguredSections(
        CmsMercuryLlmsFile llmsFile,
        List<Candidate> candidates) {

        Set<String> sectionIds = new HashSet<String>();
        for (CmsMercuryLlmsFile.Section section : llmsFile.getSections()) {
            sectionIds.add(section.id());
        }
        List<Candidate> result = new ArrayList<Candidate>();
        for (Candidate candidate : candidates) {
            if (sectionIds.contains(candidate.section())) {
                result.add(candidate);
            } else if (LOG.isDebugEnabled()) {
                LOG.debug(
                    "Skipping Mercury llms.txt candidate "
                        + m_cms.getSitePath(candidate.page())
                        + " because section '"
                        + candidate.section()
                        + "' is not configured in "
                        + m_cms.getSitePath(m_llmsResource)
                        + ".");
            }
        }
        return result;
    }

    /**
     * Generates an AI summary for a candidate.<p>
     *
     * @param candidate the candidate
     *
     * @return the summary
     */
    private String generateSummary(Candidate candidate) {

        String excerpt = getRenderedText(candidate);
        if (CmsStringUtil.isEmptyOrWhitespaceOnly(excerpt)) {
            excerpt = candidate.sharedDescription();
        }
        if (CmsStringUtil.isEmptyOrWhitespaceOnly(excerpt)) {
            excerpt = candidate.title();
        }
        try {
            ChatRequest request = ChatRequest.builder().messages(
                SystemMessage.from(SYSTEM_PROMPT_SUMMARY),
                UserMessage.from(getUserQuerySummary(candidate, excerpt))).build();
            String result = getChatModel().chat(request).aiMessage().text();
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(result)) {
                return result;
            }
            LOG.warn("AI returned an empty llms.txt summary for " + candidate.url() + ".");
        } catch (Exception e) {
            LOG.error("Failed to generate llms.txt summary for " + candidate.url() + ": " + e.getMessage(), e);
        }
        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(candidate.sharedDescription())) {
            return candidate.sharedDescription();
        }
        return CmsStringUtil.trimToSize(excerpt, 250, "");
    }

    /**
     * Returns the charset for a content type.<p>
     *
     * @param contentType the content type
     *
     * @return the charset
     */
    private Charset getCharset(String contentType) {

        if (contentType != null) {
            for (String part : contentType.split(";")) {
                String trimmed = part.trim();
                if (trimmed.toLowerCase(Locale.ROOT).startsWith("charset=")) {
                    try {
                        return Charset.forName(trimmed.substring("charset=".length()).trim());
                    } catch (Exception e) {
                        LOG.debug("Ignoring unsupported charset " + trimmed, e);
                    }
                }
            }
        }
        return StandardCharsets.UTF_8;
    }

    /**
     * Returns the configured chat model.<p>
     *
     * @return the chat model
     */
    private ChatModel getChatModel() {

        if (m_chatModel == null) {
            I_CmsSecretStore secrets = OpenCms.getSecretStore();
            String apiKey = secrets.getSecret(SECRET_APIKEY);
            String baseUrl = secrets.getSecret(SECRET_BASEURL);
            String model = secrets.getSecret(SECRET_MODEL);
            if (CmsStringUtil.isEmptyOrWhitespaceOnly(apiKey)
                || CmsStringUtil.isEmptyOrWhitespaceOnly(baseUrl)
                || CmsStringUtil.isEmptyOrWhitespaceOnly(model)) {
                throw new IllegalStateException("Missing llms.txt AI configuration in the secret store.");
            }
            m_chatModel = OpenAiChatModel.builder().apiKey(apiKey).baseUrl(baseUrl).modelName(model).timeout(
                Duration.ofMinutes(QUERY_TIMEOUT)).build();
        }
        return m_chatModel;
    }

    /**
     * Resolves the container page that references a meta info element.<p>
     *
     * @param metaInfo the meta info resource
     * @param locale the locale to match
     *
     * @return the container page, or null
     */
    private CmsResource getContainerPageForMetaInfo(CmsResource metaInfo, Locale locale) {

        try {
            List<CmsRelation> relations = m_cms.getRelationsForResource(metaInfo, CmsRelationFilter.SOURCES);
            if (LOG.isDebugEnabled()) {
                LOG.debug(
                    "Resolving container pages that reference m-metainfo "
                        + m_cms.getSitePath(metaInfo)
                        + " locale "
                        + locale
                        + ": found "
                        + relations.size()
                        + " relations.");
            }
            for (CmsRelation relation : relations) {
                CmsResource source = relation.getSource(m_cms, CmsResourceFilter.DEFAULT);
                if (CmsResourceTypeXmlContainerPage.isContainerPage(source)) {
                    Locale pageLocale = OpenCms.getLocaleManager().getDefaultLocale(m_cms, source);
                    if (LOG.isDebugEnabled()) {
                        LOG.debug(
                            "Relation source "
                                + m_cms.getSitePath(source)
                                + " is a container page with locale "
                                + pageLocale
                                + ".");
                    }
                    if (locale.equals(pageLocale)) {
                        return source;
                    }
                } else if (LOG.isDebugEnabled()) {
                    LOG.debug(
                        "Relation source "
                            + m_cms.getSitePath(source)
                            + " is not a container page; ignoring for Mercury llms.txt.");
                }
            }
        } catch (CmsException e) {
            LOG.debug("Failed to resolve container page for meta info " + metaInfo.getRootPath(), e);
        }
        return null;
    }

    /**
     * Gets the rendered description according to the configured priority.<p>
     *
     * @param llmsFile the llms file
     * @param candidate the candidate
     *
     * @return the description
     */
    private String getDescription(CmsMercuryLlmsFile llmsFile, Candidate candidate) {

        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(candidate.llmsDescription())) {
            return candidate.llmsDescription();
        }
        CmsMercuryLlmsFile.Result cached = llmsFile.getResult(candidate.page());
        if ((cached != null) && CmsStringUtil.isNotEmptyOrWhitespaceOnly(cached.resultText())) {
            return cached.resultText();
        }
        return candidate.sharedDescription();
    }

    /**
     * Gets the pages from candidates.<p>
     *
     * @param candidates the candidates
     *
     * @return the pages
     */
    private List<CmsResource> getPages(List<Candidate> candidates) {

        List<CmsResource> result = new ArrayList<CmsResource>();
        for (Candidate candidate : candidates) {
            result.add(candidate.page());
        }
        return result;
    }

    /**
     * Gets the rendered text for a page.<p>
     *
     * @param candidate the candidate
     *
     * @return the rendered text
     */
    private String getRenderedText(Candidate candidate) {

        HttpURLConnection connection = null;
        try {
            connection = (HttpURLConnection)(new URL(candidate.url())).openConnection();
            connection.setConnectTimeout(RENDER_CONNECT_TIMEOUT);
            connection.setReadTimeout(RENDER_READ_TIMEOUT);
            connection.setInstanceFollowRedirects(true);
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Accept", "text/html,application/xhtml+xml");
            int responseCode = connection.getResponseCode();
            if ((responseCode < 200) || (responseCode >= 300)) {
                return "";
            }
            String html = new String(
                connection.getInputStream().readAllBytes(),
                getCharset(connection.getContentType()));
            Document doc = Jsoup.parse(html, candidate.url());
            doc.select(
                "script,style,noscript,template,header,footer,nav,aside,form,[hidden],[aria-hidden=true],[class*=slider],[class*=hide]").remove();
            Element content = doc.selectFirst("main");
            if (content == null) {
                content = doc.selectFirst("[role=main]");
            }
            if (content == null) {
                content = doc.selectFirst("article");
            }
            if (content == null) {
                content = doc.body();
            }
            return normalize(content != null ? content.text() : doc.text());
        } catch (Exception e) {
            LOG.debug("Failed to load rendered page text for " + candidate.url(), e);
            return "";
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    /**
     * Gets a page title.<p>
     *
     * @param page the page
     * @param metaInfoContent the meta info content
     * @param locale the meta info locale
     *
     * @return the title
     */
    private String getTitle(CmsResource page, CmsXmlContent metaInfoContent, Locale locale) {

        if (metaInfoContent.hasValue(NODE_TITLE, locale)) {
            String metaInfoTitle = metaInfoContent.getStringValue(m_cms, NODE_TITLE, locale);
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(metaInfoTitle)) {
                return metaInfoTitle;
            }
        }
        try {
            String title = m_cms.readPropertyObject(page, CmsPropertyDefinition.PROPERTY_TITLE, true).getValue("");
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(title)) {
                return title;
            }
        } catch (CmsException e) {
            LOG.debug("Failed to read title for " + page.getRootPath(), e);
        }
        return page.getName();
    }

    /**
     * Gets the online URL for a page.<p>
     *
     * @param page the page
     *
     * @return the URL
     */
    private String getUrl(CmsResource page) {

        return OpenCms.getLinkManager().getOnlineLink(m_cms, m_cms.getSitePath(page));
    }

    /**
     * Builds the AI user query.<p>
     *
     * @param candidate the candidate
     * @param excerpt the excerpt
     *
     * @return the JSON query
     *
     * @throws Exception if JSON generation fails
     */
    private String getUserQuerySummary(Candidate candidate, String excerpt) throws Exception {

        ObjectNode query = MAPPER.createObjectNode();
        query.put("url", candidate.url());
        query.put("title", candidate.title());
        query.put("excerpt", excerpt);
        query.put("question", "Please generate a summary for this title and excerpt usable in an llms.txt file.");
        return query.toString();
    }

    /**
     * Normalizes text.<p>
     *
     * @param text the text
     *
     * @return the normalized text
     */
    private String normalize(String text) {

        return text != null ? text.replaceAll("\\s+", " ").trim() : "";
    }

    /**
     * Renders the file from current candidates and cached data.<p>
     *
     * @param llmsFile the llms file
     * @param candidates the current candidates
     *
     * @return the rendered text
     */
    private String render(CmsMercuryLlmsFile llmsFile, List<Candidate> candidates) {

        candidates = filterCandidatesForConfiguredSections(llmsFile, candidates);
        Map<String, List<Candidate>> bySection = new LinkedHashMap<String, List<Candidate>>();
        for (CmsMercuryLlmsFile.Section section : llmsFile.getSections()) {
            bySection.put(section.id(), new ArrayList<Candidate>());
        }
        for (Candidate candidate : candidates) {
            List<Candidate> sectionCandidates = bySection.get(candidate.section());
            if (sectionCandidates != null) {
                sectionCandidates.add(candidate);
            }
        }
        if (LOG.isDebugEnabled()) {
            LOG.debug(
                "Rendering Mercury llms.txt file "
                    + m_cms.getSitePath(m_llmsResource)
                    + " with "
                    + candidates.size()
                    + " candidates and "
                    + llmsFile.getSections().size()
                    + " configured sections.");
        }
        StringBuilder result = new StringBuilder();
        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(llmsFile.getTitle())) {
            result.append("# ").append(llmsFile.getTitle()).append("\n\n");
        }
        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(llmsFile.getIntroText())) {
            result.append(llmsFile.getIntroText()).append("\n\n");
        }
        for (CmsMercuryLlmsFile.Section section : llmsFile.getSections()) {
            List<Candidate> sectionCandidates = bySection.get(section.id());
            if ((sectionCandidates == null) || sectionCandidates.isEmpty()) {
                continue;
            }
            result.append("## ").append(section.name()).append("\n\n");
            for (Candidate candidate : sectionCandidates) {
                result.append("- [").append(escapeLinkText(candidate.title())).append("](").append(
                    candidate.url()).append(")");
                String description = getDescription(llmsFile, candidate);
                if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(description)) {
                    result.append(": ").append(description);
                }
                result.append("\n");
            }
            result.append("\n");
        }
        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(llmsFile.getOutroText())) {
            result.append(llmsFile.getOutroText()).append("\n");
        }
        return result.toString();
    }

    /**
     * Writes an updated file with locking.<p>
     *
     * @param file the file
     *
     * @throws CmsException if writing fails
     */
    private void write(CmsFile file) throws CmsException {

        CmsLock lock = m_cms.getLock(file);
        boolean locked = false;
        if (lock.isUnlocked() && lock.isLockableBy(m_cms.getRequestContext().getCurrentUser())) {
            m_cms.lockResource(file);
            locked = true;
        } else if (!lock.isOwnedBy(m_cms.getRequestContext().getCurrentUser()) && !lock.isInherited()) {
            m_cms.changeLock(file);
            locked = true;
        }
        if (m_cms.getLock(file).isOwnedBy(m_cms.getRequestContext().getCurrentUser())) {
            m_cms.writeFile(file);
            if (locked) {
                m_cms.unlockResource(file);
            }
        }
    }
}
