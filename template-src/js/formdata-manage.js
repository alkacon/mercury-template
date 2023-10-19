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

/**
 * Submissions dialog.
 */
class SubmissionsDialog {

    /**
     * Creates a new submissions dialog.
     * @param element the formdata manage root element
     * @param dialog the dialog element
     */
    constructor(element, dialog) {
        const action = dialog.dataset.action;
        const itemId = dialog.dataset.itemId;
        const uuid = dialog.dataset.contentId;
        const button = element.querySelector("#" + action + "_button_" + itemId);
        const params = new URLSearchParams(location.search);
        const formmanage = params.get("formmanage");
        button.addEventListener("click", () =>  { dialog.showModal(); });
        dialog.addEventListener("close", () => {
            if (dialog.returnValue == "confirm") {
                location.href = "?formmanage=" + formmanage + "&action=" + action + "&uuid=" + uuid;
            }
        });
    }
}

/**
 * Submissions select.
 */
class SubmissionsSelect {

    /**
     * Creates a new submissions select.
     * @param element the formdata manage root element
     */
    constructor(element) {
        this.m_buttonExportCsv = element.querySelector(".btn-export-csv");
        this.m_buttonExportExcel = element.querySelector(".btn-export-excel");
        this.m_checkAll = element.querySelector(".acco-item-check-all");
        this.m_checkbox = element.querySelectorAll(".acco-item-check");
        const valid = this.m_buttonExportCsv && this.m_buttonExportExcel && this.m_checkAll && this.m_checkbox;
        if (valid) {
            this.m_buttonExportCsv.addEventListener("click", (event) => this.onExport(event) );
            this.m_buttonExportExcel.addEventListener("click", (event) => this.onExport(event) );
            this.m_checkAll.addEventListener("change", (event) => this.onCheckAll(event) );
        }
    }

    /**
     * Checks or unchecks all chechboxes.
     * @param check whether to check or uncheck
     */
    checkAll(check) {
        this.m_checkbox.forEach(checkbox => {
            checkbox.checked = check;
        });
    }
    
    createHttpRequest(url) {
        const httpRequest = new XMLHttpRequest();
        httpRequest.open("POST", url, true);
        httpRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        httpRequest.responseType = "arraybuffer";
        return httpRequest;
    }

    /**
     * Returns the IDs of all checked items.
     */
    getCheckedItemIds() {
        let items = [];
        this.m_checkbox.forEach(checkbox => {
            if (checkbox.checked) {
                items.push(checkbox.value);
            }
        });
        return items;
    }

    /**
     * Check all handler.
     * @param event the event
     */
    onCheckAll(event) {
        this.checkAll(event.target.checked);
    }

    /**
     * Export handler.
     * @param event the event
     */
    onExport(event) {
        event.preventDefault();
        const ids = this.getCheckedItemIds();
        const httpRequest = this.createHttpRequest(event.target.href);
        const requestData = this.m_checkbox.length == ids.length ? "" : "formdata=" + ids.join(",");
        httpRequest.send(requestData);
        httpRequest.onload = function onload() {
            const type = this.getResponseHeader("Content-Type");
            const disp = this.getResponseHeader("Content-Disposition");
            let name = "download";
            if (disp.includes("filename=")) {
                name = disp.substring(disp.indexOf("filename=") + "filename=".length);
            }
            const data = this.response;
            const blob = new Blob([data], { type });
            blob.name = name;
            const reader = new FileReader();
            reader.onload = e => {
                const anchor = document.createElement('a');
                anchor.style.display = 'none';
                anchor.href = e.target.result;
                anchor.download = name;
                anchor.click();
            };
            reader.readAsDataURL(blob);
        }
    }
}

/**
 * Initializes all components.
 */
export function init() {

    const formdataManage = document.querySelectorAll(".formdata-manage");
    formdataManage.forEach(element => {
        new SubmissionsSelect(element);
        const dialogs = element.querySelectorAll(".submissions-dialog");
        dialogs.forEach(dialog => {
            new SubmissionsDialog(element, dialog);
        });
    });
}
