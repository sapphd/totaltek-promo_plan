/************************************************************************
 *-----------------------------------------------------------------------
 * Project               : Promo Plan
 * Process               : TPM
 * Task Code             : 
 * Functional Document   : 
 * Technical Document    :
 *  ---------------------------------------------------------------------
 * File       : controller/BaseController.js
 * Author     : R73163
 * Company    : KCC
 * Created On : 2025-07-27
 * Description: 
 * ----------------------------------------------------------------------
 * Moddification no :
 * Project          :            
 * Author           :  
 * ----------------------------------------------------------------------
 * Moddification Date :
 * Transport Order    :            
 * Change Request     :  
 * Description
 *-----------------------------------------------------------------------
 ************************************************************************/


sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageBox",
    "sap/m/MessageToast",
    "com/kcc/promoplan/model/formatter",
    "com/kcc/promoplan/utils/FragmentHelper",
    'sap/ui/core/BusyIndicator'
], function (Controller, MessageBox, MessageToast, formatter, FragmentHelper, BusyIndicator) {
    "use strict";

    return Controller.extend("com.kcc.promoplan.controller.BaseController", {
        formatter: formatter,

        setPromoPlanMode: function (sMode) {
            const oAppView = this.getOwnerComponent().getModel("appView");

            switch (sMode) {
                case "edit":
                    oAppView.setProperty("/isEditMode", true);
                    oAppView.setProperty("/isNewMode", false);
                    oAppView.setProperty("/showFooter", true);

                    break;
                case "new":
                    oAppView.setProperty("/isEditMode", false);
                    oAppView.setProperty("/isNewMode", true);
                    oAppView.setProperty("/showFooter", true);

                    break;
                default: // view mode
                    oAppView.setProperty("/isEditMode", false);
                    oAppView.setProperty("/isNewMode", false);
                    oAppView.setProperty("/showFooter", false);

                    break;
            }
        },

        readModelData: function (sModelName, sPath, mParameters) {
            return new Promise((resolve, reject) => {

                var oModel;
                if (sModelName) {
                    oModel = this.getOwnerComponent().getModel(sModelName);
                }
                else {
                    oModel = this.getOwnerComponent().getModel();
                }
                oModel.read(sPath, {

                    success: resolve,
                    error: reject
                });
            });
        },


        hideBusyIndicator: function () {
            BusyIndicator.hide();
        },

        showBusyIndicator: function () {
            BusyIndicator.show(0);

        },


        onMultiOneTokenRestrict: function (oEvent) {
            var oMultiInput = oEvent.getSource();
            var aTokens = oMultiInput.getTokens();

            if (aTokens.length >= 1) {
                oMultiInput.setValue(""); // Prevent typing
            }
        },

        showMessageBox: function (sType, sMessage, sTitle) {
            switch (sType) {
                case "error":
                    MessageBox.error(sMessage, { title: sTitle || "Error" });
                    break;
                case "warning":
                    MessageBox.warning(sMessage, { title: sTitle || "Warning" });
                    break;
                case "info":
                    MessageBox.information(sMessage, { title: sTitle || "Information" });
                    break;
                case "success":

                    MessageBox.success(sMessage, { title: sTitle || "Success" });
                    break;
                default:
                    MessageBox.show(sMessage, { title: sTitle || "Message" });
            }
        },

        showMessageToast: function (sMessage, iDuration) {
            MessageToast.show(sMessage, {
                duration: iDuration || 3000
            });
        },
        _navigateToSection: function (id, that) {
            var oObjectPageLayout = that.byId("idCreatePromoPlanOPL");
            var oItemsSection = that.byId(id); // Get the target section by its ID
            if (oObjectPageLayout && oItemsSection) {
                oObjectPageLayout.scrollToSection(oItemsSection.getId());
            }
        },
        // In your controller
        onNavBack: function () {
            var oHistory = sap.ui.core.routing.History.getInstance();
            var sPreviousHash = oHistory.getPreviousHash();

            if (sPreviousHash !== undefined) {
                window.history.go(-1); // Navigate back in browser history
            } else {
                // If no previous hash, navigate to a default route (e.g., "overview")
                this.getOwnerComponent().getRouter().navTo("Dashboard", {}, true);
            }
        },
        handleVHConfirm: function (oEvent) {
            FragmentHelper.handleVHConfirm(this, oEvent);

        },
        handleNavigationToHomePage: function () {
            this.getOwnerComponent().getRouter().navTo("Dashboard", {}, true);

        },
        handleVHSearch: function (oEvent) {
            FragmentHelper.handleVHSearch(this, oEvent);
        },
        
        handleVHCancel: function (oEvent) {
            FragmentHelper.handleVHCancel(this, oEvent);
        },
        /**
         * Get the router instance
         */
        getRouter: function () {
            return this.getOwnerComponent().getRouter();
        },

        /**
         * Show a toast message
         */
        showToast: function (sMessage) {
            MessageToast.show(sMessage);
        },

        /**
         * Get the model by name
         */
        getModel: function (sName) {
            return this.getView().getModel(sName);
        },

        /**
         * Set the model to the view
         */
        setModel: function (oModel, sName) {
            return this.getView().setModel(oModel, sName);
        }
    });
});
