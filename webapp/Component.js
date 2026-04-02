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
    "sap/ui/core/UIComponent",
    "com/kcc/promoplan/model/models",
    'sap/ui/model/json/JSONModel'
], (UIComponent, models, JSONModel) => {
    "use strict";

    return UIComponent.extend("com.kcc.promoplan.Component", {
        metadata: {
            manifest: "json",
            interfaces: [
                "sap.ui.core.IAsyncContentCreation"
            ]
        },

        init() {
            // call the base component's init function
            UIComponent.prototype.init.apply(this, arguments);

            // set the device model
            this.setModel(models.createDeviceModel(), "device");

            var sUserId;
            if (sap.ushell && sap.ushell.Container && sap.ushell.Container.getService("UserInfo")) {
                var userInfoService = sap.ushell.Container.getService("UserInfo");
                sUserId = userInfoService.getId();
                console.log(sUserId);
                // Other details: userInfoService.getEmail(), userInfoService.getFirstName(), etc.
            }
            //var oDateFormat = sap.ui.getCore().getConfiguration().getFormatSettings().getDatePattern("medium");
            // enable routing
            this.getRouter().initialize();
        }
    });
});