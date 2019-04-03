/*
 * This program is part of the OpenCms Mercury Template.
 *
 * Copyright (c) Alkacon Software GmbH & Co. KG (http://www.alkacon.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package alkacon.mercury.xtensions.imgur;

import org.opencms.file.CmsObject;
import org.opencms.widgets.dataview.CmsDataViewColumn;
import org.opencms.widgets.dataview.CmsDataViewFilter;
import org.opencms.widgets.dataview.CmsDataViewQuery;
import org.opencms.widgets.dataview.CmsDataViewResult;
import org.opencms.widgets.dataview.I_CmsDataView;
import org.opencms.widgets.dataview.I_CmsDataViewItem;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Class for the imgur view.<p>
 */
public class CmsImgurDataView implements I_CmsDataView {

    /**section.*/
    private String m_section = "hot";

    /**viral.*/
    private boolean m_viral = true;

    /**imgur id.*/
    private String m_imgurID;

    /**list of items.*/
    private ArrayList<I_CmsDataViewItem> m_allItems;

    /**
     * Gets columns.<p>
     *
     * @return  list of columns
     */
    public List<CmsDataViewColumn> getColumns() {

        List<CmsDataViewColumn> cols = new ArrayList<CmsDataViewColumn>();
        cols.add(
            new CmsDataViewColumn(
                "image",
                org.opencms.widgets.dataview.CmsDataViewColumn.Type.imageType,
                "Image",
                false,
                200));
        cols.add(
            new CmsDataViewColumn(
                "description",
                org.opencms.widgets.dataview.CmsDataViewColumn.Type.textType,
                "Description",
                true,
                300));
        return cols;

    }

    /**
     * Returns filter.<p>
     *
     * @return list of filter
     */
    public List<CmsDataViewFilter> getFilters() {

        List<CmsDataViewFilter> res = new ArrayList<CmsDataViewFilter>();
        return res;
    }

    /**
     * Reads item by id.<p>
     *
     * @param id to search for
     * @return Item
     */
    public I_CmsDataViewItem getItemById(String id) {

        if (m_allItems != null) {
            for (I_CmsDataViewItem item : m_allItems) {
                if (item.getId().equals(id)) {
                    return item;
                }
            }
        } else {
            //Call from CmsVfsService to fetch thumbnail. Only image in needed, id holds link to image
            return new CmsImgurDataItem("", id, "", "", false, "");
        }
        return null;
    }

    /**
     * Returns page size.<p>
     *
     * @return int
     */
    public int getPageSize() {

        return 10;
    }

    /**
     * Gets result.<p>
     *
     * @param query string
     * @param offset int
     * @param count int
     * @return result
     */
    public CmsDataViewResult getResults(CmsDataViewQuery query, int offset, int count) {

        List<String> titles = new ArrayList<>();
        List<String> descriptions = new ArrayList<>();
        List<String> links = new ArrayList<>();
        List<Boolean> album = new ArrayList<>();
        List<String> idData = new ArrayList<>();
        String imgurQuery = "";

        if ("".equals(query.getFullTextQuery())) {

            imgurQuery = "https://api.imgur.com/3/gallery/" + m_section + "/viral/0?showViral=" + m_viral;

            if (CmsImgurCache.itemLists.containsKey(imgurQuery)
                && !(CmsImgurCache.itemListTime.get(imgurQuery) < (System.currentTimeMillis() - (30 * 60 * 1000)))) {
                m_allItems = CmsImgurCache.itemLists.get(imgurQuery);

                for (int i = 0; i < m_allItems.size(); i++) {
                    titles.add(m_allItems.get(i).getTitle());
                    descriptions.add(m_allItems.get(i).getDescription());
                    links.add(m_allItems.get(i).getImage());
                    album.add(((CmsImgurDataItem)m_allItems.get(i)).isAlbum());
                    idData.add(((CmsImgurDataItem)m_allItems.get(i)).getAlbumID());
                }
            } else {
                try {
                    URL imgURL = new URL(imgurQuery);
                    HttpURLConnection conn = (HttpURLConnection)imgURL.openConnection();
                    conn.setRequestMethod("GET");
                    conn.setRequestProperty("Authorization", "Client-ID " + m_imgurID);
                    BufferedReader bin = null;
                    bin = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                    JSONObject obj = new JSONObject(bin.readLine().toString());
                    JSONArray data = obj.getJSONArray("data");

                    //Looping throw results from Imgur
                    if (data.length() < (offset + count)) {
                        count = data.length() - offset;
                    }

                    for (int i = 0; i < data.length(); i++) {
                        Object o = data.getJSONObject(i).get("title");
                        Object o2 = data.getJSONObject(i).get("description");
                        String de;

                        if (o2 != null) {
                            de = o2.toString();
                        } else {
                            de = "";
                        }
                        if (!de.equals("null")) {
                            descriptions.add(de);
                        } else {
                            descriptions.add("");
                        }
                        String title;

                        if (o != null) {
                            title = o.toString();
                        } else {
                            title = "";
                        }
                        if (!title.equals("null")) {
                            titles.add(title);
                        } else {
                            titles.add("No title");
                        }

                        album.add(data.getJSONObject(i).getBoolean("is_album"));
                        links.add(data.getJSONObject(i).getString("link"));
                        idData.add(data.getJSONObject(i).getString("id"));
                    }
                } catch (MalformedURLException e) {
                    //
                } catch (IOException e) {
                    //
                }

            }

        } else {
            imgurQuery = "https://api.imgur.com/3/gallery/t/" + query.getFullTextQuery();

            if (CmsImgurCache.itemLists.containsKey(imgurQuery)) {
                m_allItems = CmsImgurCache.itemLists.get(imgurQuery);

                for (int i = 0; i < m_allItems.size(); i++) {
                    titles.add(m_allItems.get(i).getTitle());
                    descriptions.add(m_allItems.get(i).getDescription());
                    links.add(m_allItems.get(i).getImage());
                    album.add(((CmsImgurDataItem)m_allItems.get(i)).isAlbum());
                    idData.add(((CmsImgurDataItem)m_allItems.get(i)).getAlbumID());
                }
            } else {
                try {
                    URL imgURL = new URL(imgurQuery);
                    HttpURLConnection conn = (HttpURLConnection)imgURL.openConnection();
                    conn.setRequestMethod("GET");
                    conn.setRequestProperty("Authorization", "Client-ID " + m_imgurID);
                    BufferedReader bin = null;
                    JSONObject obj = null;
                    JSONArray data = null;
                    if (conn.getResponseCode() > 250) {
                        //ToDo: Fehlermeldung nichts gefunden
                    } else {
                        bin = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                        obj = new JSONObject(bin.readLine().toString());
                        data = obj.getJSONObject("data").getJSONArray("items");

                        for (int i = 0; i < data.length(); i++) {
                            Object o = data.getJSONObject(i).get("title");
                            Object o2 = data.getJSONObject(i).get("description");
                            String de;

                            if (o2 != null) {
                                de = o2.toString();
                            } else {
                                de = "";
                            }
                            if (!de.equals("null")) {
                                descriptions.add(de);
                            } else {
                                descriptions.add("");
                            }
                            String title;

                            if (o != null) {
                                title = o.toString();
                            } else {
                                title = "";
                            }
                            if (!title.equals("null")) {
                                titles.add(title);
                            } else {
                                titles.add("No title");
                            }

                            album.add(data.getJSONObject(i).getBoolean("is_album"));
                            links.add(data.getJSONObject(i).getString("link"));
                            idData.add(data.getJSONObject(i).getString("id"));
                        }
                    }
                } catch (MalformedURLException e) {
                    //
                } catch (IOException e) {
                    //
                }
            }

        }
        if (album.size() > 0) {
            //Only look closer at alblums which are displayed
            for (

            int j = offset; j < (offset + count); j++) {
                if (album.get(j)) {
                    if (!CmsImgurCache.albumImages.containsKey(idData.get(j))) {
                        URL imgURL2;
                        try {
                            imgURL2 = new URL("https://api.imgur.com/3/gallery/album/" + idData.get(j));

                            HttpURLConnection conn2 = (HttpURLConnection)imgURL2.openConnection();
                            conn2.setRequestMethod("GET");
                            conn2.setRequestProperty("Authorization", "Client-ID " + m_imgurID);
                            BufferedReader bin2 = null;
                            bin2 = new BufferedReader(new InputStreamReader(conn2.getInputStream()));
                            JSONObject obj2 = new JSONObject(bin2.readLine().toString());
                            JSONObject data2 = obj2.getJSONObject("data");
                            links.set(j, data2.getJSONArray("images").getJSONObject(0).getString("link"));
                            Object o = data2.getJSONArray("images").getJSONObject(0).get("description");
                            String des = "";
                            if (o.toString() == null) {
                                des = titles.get(j);
                            } else {
                                des = o.toString();
                            }
                            descriptions.set(j, des);
                            CmsImgurCache.albumImages.put(
                                idData.get(j),
                                data2.getJSONArray("images").getJSONObject(0).getString("link"));
                            CmsImgurCache.albumDescription.put(idData.get(j), des);
                        } catch (MalformedURLException e) {
                            e.printStackTrace();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    } else {
                        links.set(j, CmsImgurCache.albumImages.get(idData.get(j)));
                        descriptions.set(j, CmsImgurCache.albumDescription.get(idData.get(j)));
                    }
                }
            }
        }
        m_allItems = new ArrayList<I_CmsDataViewItem>();

        for (

        int i = 0; i < links.size(); i++) {
            m_allItems.add(
                new CmsImgurDataItem(
                    links.get(i),
                    links.get(i),
                    descriptions.get(i),
                    titles.get(i),
                    album.get(i),
                    idData.get(i)));
        }
        if (m_allItems.size() > 0) {
            CmsImgurCache.itemLists.put(imgurQuery, m_allItems);
            CmsImgurCache.itemListTime.put(imgurQuery, System.currentTimeMillis());
        }
        if (m_allItems.size() > offset) {
            return new CmsDataViewResult(m_allItems.subList(offset, offset + count), 60);
        } else {
            return new CmsDataViewResult(m_allItems, 60);
        }
    }

    /**
     * initializes view.<p>
     *
     * @param cms CmsObject
     * @param configData data
     * @param locale locale
     */
    public void initialize(CmsObject cms, String configData, Locale locale) {

        this.m_imgurID = configData;
    }

    /**
     * Update filter.<p>
     *
     * @param prevFilters filter
     * @return list of filter
     */
    public List<CmsDataViewFilter> updateFilters(List<CmsDataViewFilter> prevFilters) {

        return prevFilters;
    }

}
