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
        this.m_dialog = dialog;
        this.m_button = element.querySelector("#" + this.action + "_button_" + this.itemId);
        this.m_button.addEventListener("click", () =>  { this.m_dialog.showModal(); });
        this.m_dialog.addEventListener("close", () => { this.onConfirm() });
    }

    /**
     * Returns the action name.
     */
    get action() {
        return this.m_dialog.dataset.action;
    }

    /**
     * Returns the content id.
     */
    get contentId() {
        return this.m_dialog.dataset.contentId;
    }

    /**
     * Returns the item id.
     */
    get itemId() {
        return this.m_dialog.dataset.itemId;
    }
    
    /**
     * Returns the formmanage request parameter.
     */
    get formmanage() {
        const params = new URLSearchParams(location.search);
        return params.get("formmanage");
    }

    /**
     * On confirm handler.
     */
    onConfirm() {
        if (this.m_dialog.returnValue == "confirm") {
            location.href = "?formmanage=" + this.formmanage + "&action=" + this.action + "&uuid=" + this.contentId;
        }
    }
}

/**
 * Delete submissions dialog.
 */
class SubmissionsDialogDelete {

    /**
     * Creates a new submissions delete dialog.
     * @param element the formdata manage root element
     * @param submissionsSelect the submissions select component
     */
    constructor(element, submissionsSelect) {
        this.m_submissionsSelect = submissionsSelect;
        this.m_button = element.querySelector(".submissions-dialog-delete-button");
        this.m_dialog = element.querySelector(".submissions-dialog-delete");
        if (this.m_dialog) {
            this.m_buttonCancel = this.m_dialog.querySelector(".button-cancel");
            this.m_buttonConfirm = this.m_dialog.querySelector(".button-confirm");
            this.m_messageDeleteAll = this.m_dialog.querySelector(".delete-all");
            this.m_messageDeleteSelected = this.m_dialog.querySelector(".delete-selected");
            this.m_response = this.m_dialog.querySelector(".delete-response");
            const valid = this.m_button && this.m_dialog && this.m_messageDeleteAll && this.m_messageDeleteSelected
                    && this.m_buttonCancel && this.m_buttonConfirm;
            if (valid) {
                this.m_button.addEventListener("click", () =>  { this.onOpen() });
                this.m_buttonCancel.addEventListener("click", () => { this.onCancel() });
                this.m_buttonConfirm.addEventListener("click", () => { this.onConfirm() });
                this.m_messageDeleteSelected.style.display = "none";
            }
        }
    }
    
    get action() {
        return this.m_dialog.dataset.action;
    }
    
    /**
     * Returns the formmanage request parameter.
     */
    get formmanage() {
        const params = new URLSearchParams(location.search);
        return params.get("formmanage");
    }

    /**
     * Creates and configures a HTTP client.
     * @param url the URL to configure the HTTP client for
     */
    createHttpClient(url) {
        const client = new XMLHttpRequest();
        client.open("POST", url, true);
        client.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        return client;
    }

    /**
     * Deletes all formdata items.
     */
    deleteAll() {
        const self = this;
        const client = this.createHttpClient(this.action);
        const requestData = "";
        client.send(requestData);
        client.onload = function() {
            self.m_response.innerHTML = this.responseText;
            location.href = "?reload";
        }
        client.onerror = function() {
            self.m_response.innerHTML = this.responseText;
        }
    }

    /**
     * Deletes the selected formdata items.
     */
    deleteSelected() {
        const self = this;
        const client = this.createHttpClient(this.action);
        const ids = this.m_submissionsSelect.getCheckedItemIds();
        const requestData = ids.length == 0 ? "" : "formdata=" + ids.join(",");
        client.send(requestData);
        client.onload = function() {
            self.m_response.innerHTML = this.responseText;
            location.href = "?reload";
        }
        client.onerror = function() {
            self.m_response.innerHTML = this.responseText;
        }
    }

    /**
     * Cancel handler.
     */
    onCancel() {
        this.m_dialog.close();
    }

    /**
     * Confirm handler.
     */
    onConfirm() {
        this.m_submissionsSelect.isModeSelect() ? this.deleteSelected() : this.deleteAll();
    }

    /**
     * Open handler.
     */
    onOpen() {
        if (this.m_submissionsSelect.isModeSelect()) {
            this.m_messageDeleteAll.style.display = "none";
            this.m_messageDeleteSelected.style.display = "block";
        } else {
            this.m_messageDeleteAll.style.display = "block";
            this.m_messageDeleteSelected.style.display = "none";
        }
        this.m_dialog.showModal();
    }
}

/**
 * Submissions export.
 */
class SubmissionsExport {

    /**
     * Creates a new submissions export.
     * @param element the formdata manage root element
     * @param submissionsSelect the submissions select component
     */
    constructor(element, submissionsSelect) {
        this.m_submissionsSelect = submissionsSelect;
        this.m_buttonExportCsv = element.querySelector(".btn-export-csv");
        this.m_buttonExportExcel = element.querySelector(".btn-export-excel");
        const valid = this.m_buttonExportCsv && this.m_buttonExportExcel;
        if (valid) {
            this.m_buttonExportCsv.addEventListener("click", (event) => this.onExport(event) );
            this.m_buttonExportExcel.addEventListener("click", (event) => this.onExport(event) );
        }
    }

    /**
     * Creates and configures a HTTP client.
     * @param url the URL to configure the HTTP client for
     */
    createHttpClient(url) {
        const client = new XMLHttpRequest();
        client.open("POST", url, true);
        client.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        client.responseType = "arraybuffer";
        return client;
    }

    /**
     * Export handler.
     * @param event the event
     */
    onExport(event) {
        if (this.m_submissionsSelect.isModeSelect()) {
            event.preventDefault();
            const client = this.createHttpClient(event.target.href);
            const requestData = this.m_submissionsSelect.isSelectAll() ? "" : "formdata="
                    + this.m_submissionsSelect.getCheckedItemIds().join(",");
            client.send(requestData);
            client.onload = function() {
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
        this.m_itemSelectStart = element.querySelector(".acco-item-select-start");
        this.m_itemSelectAll = element.querySelector(".acco-item-select-all");
        this.m_itemSelectNone = element.querySelector(".acco-item-select-none");
        this.m_checkbox = element.querySelectorAll(".acco-item-check");
        this.m_modeSelect = false;
        if (this.isValid()) {
            this.m_itemSelectStart.addEventListener("click", (event) => this.onSelectStart(event) );
            this.m_itemSelectAll.style.display = "none";
            this.m_itemSelectNone.style.display = "none";
        }
    }

    /**
     * Returns the IDs of all checked items.
     */
    getCheckedItemIds() {
        const items = [];
        this.m_checkbox.forEach(checkbox => {
            if (checkbox.checked) {
                items.push(checkbox.value);
            }
        });
        return items;
    }

    /**
     * Returns whether we are in select mode.
     */
    isModeSelect() {
        return this.m_modeSelect;
    }

    /**
     * Returns whether all items are selected.
     */
    isSelectAll() {
        return this.m_checkbox.length == this.getCheckedItemIds().length;
    }

    /**
     * Returns whether no item is selected.
     */
    isSelectNone() {
        return getCheckedItemIds().length == 0;
    }

    /**
     * Returns whether the initialization of this component is valid.
     */
    isValid() {
        return  this.m_itemSelectStart && this.m_itemSelectAll && this.m_itemSelectNone;
    }

    /**
     * Select start handler.
     */
    onSelectStart(event) {
        event.preventDefault();
        this.m_itemSelectStart.style.display = "none";
        this.m_itemSelectAll.style.display = "inline-block";
        this.m_itemSelectNone.style.display = "inline-block";
        this.m_checkbox.forEach(checkbox => {
            checkbox.style.display = "inline-block";
        });
        this.m_itemSelectAll.addEventListener("click", (event) => this.onSelectAll(event) );
        this.m_itemSelectNone.addEventListener("click", (event) => this.onSelectNone(event) );
        this.m_modeSelect = true;
    }

    /**
     * Select all handler.
     */
    onSelectAll(event) {
        event.preventDefault();
        this.selectAll(true);
    }

    /**
     * Select none handler.
     */
    onSelectNone(event) {
        event.preventDefault();
        this.selectAll(false);
    }

    /**
     * Checks or unchecks all chechboxes.
     * @param check whether to check or uncheck
     */
    selectAll(check) {
        this.m_checkbox.forEach(checkbox => {
            checkbox.checked = check;
        });
    }
}

/**
 * Initializes all components.
 */
export function init() {

    const formdataManage = document.querySelectorAll(".formdata-manage");
    formdataManage.forEach(element => {
        const submissionsSelect = new SubmissionsSelect(element);
        new SubmissionsExport(element, submissionsSelect);
        new SubmissionsDialogDelete(element, submissionsSelect);
        const dialogs = element.querySelectorAll(".submissions-dialog");
        dialogs.forEach(dialog => {
            new SubmissionsDialog(element, dialog);
        });
    });
}
