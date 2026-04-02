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
    "sap/ui/core/Fragment",
    'sap/m/Token'
], function (Fragment, Token) {
    "use strict";

    return {

        formatDateToBackend: function (sDateValueFromControl) {
            var oDate = new Date(sDateValueFromControl); // Get date from UI control
             //oDate.setHours(0, 0, 0, 0);
            var oDateFormat = sap.ui.core.format.DateFormat.getDateTimeInstance({
                pattern: "yyyy-MM-dd",

                //pattern: "yyyy-MM-ddTHH:mm:ss",
                UTC: false
            });
            var sFormattedDate = oDateFormat.format(oDate);
            return sFormattedDate;
            //return oDate ? oDate.toISOString().split("T")[0] + "T00:00:00" : null;
        },

        getDateRangeValues: function (that) {
            const oView = that.getView();
            const format = this.formatDateToBackend;

            return {
                OrderDateF: format(oView.byId("idOrderDateRange").getDateValue()),
                OrderDateT: format(oView.byId("idOrderDateRange").getSecondDateValue()),
                BuyingDateF: format(oView.byId("idBuyingDateRange").getDateValue()),
                BuyingDateT: format(oView.byId("idBuyingDateRange").getSecondDateValue()),
                InstoreDateF: format(oView.byId("idInStoreRange").getDateValue()),
                InstoreDateT: format(oView.byId("idInStoreRange").getSecondDateValue())
            };
        },

        getMultiInputValues: function (that) {
            const oView = that.getView();
            const aFields = [
                { id: "idSalesOrgGDVHID", key: "Vkorg" },
                { id: "idDistChanGDVHID", key: "Vtweg" },
                { id: "idPromoPlanTypeID", key: "PlanType" },
                { id: "idObjectiveID", key: "ObjectiveId" },
                { id: "idTacticsID", key: "TacticId" },
                { id: "idSalesAreaGDVHID", key: "Sa_Id" },
                { id: "idStatusVHCreateID", key: "Status" },
                { id: "idFundPlanVHID", key: "FundPlan" }
            ];

            const oValues = {};
            aFields.forEach(({ id, key }) => {

                const oControl = oView.byId(id);
                const aTokens = oControl?.getTokens?.() || [];

                // If tokens exist, get the key of the first token; else set empty string
                oValues[key] = aTokens.length > 0 ? aTokens[0].getKey() : "";

            });

            return oValues;
        },
        onClearData: function (that) {
            const oView = that.getView();

            const aFields = [
                { id: "idSalesOrgGDVHID" },
                { id: "idDistChanGDVHID" },
                { id: "idPromoPlanTypeID" },
                { id: "idStatusVHCreateID" },
                { id: "idFundPlanVHID" },
                { id: "idSalesAreaGDVHID" },
                { id: "idTacticsID" },
                { id: "idObjectiveID" },
                { id: "idProductSelectionID" }
            ];

            aFields.forEach(({ id }) => {
                const oControl = oView.byId(id);
                if (oControl && oControl.removeAllTokens) {
                    oControl.removeAllTokens();

                }
            });


            oView.byId("idBuyingDateRange").setDateValue(null);
            oView.byId("idBuyingDateRange").setSecondDateValue(null);

            oView.byId("idInStoreRange").setDateValue(null);
            oView.byId("idInStoreRange").setSecondDateValue(null);



        },
        resetEditValidationModel: function (that) {


            const oModel = that.getOwnerComponent().getModel("validation"); // Replace with your model name
            oModel.setData({

                "SalesOrg": { "state": "None", "text": "" },
                "DistChan": { "state": "None", "text": "" },
                "PromoPlanType": { "state": "None", "text": "" },
                "PromoDesc": { "state": "None", "text": "" },
                "Status": { "state": "None", "text": "" },
                "FundPlan": { "state": "None", "text": "" },
                "SalesArea": { "state": "None", "text": "" },
                "InSoreDate": { "state": "None", "text": "" },
                "BuyingDate": { "state": "None", "text": "" },
                "Customer": { "state": "None", "text": "" },
                "ProductSelection": { "state": "None", "text": "" }


            }

            );

        },
        resetValidationModel: function (that) {


            const oModel = that.getOwnerComponent().getModel("validation"); // Replace with your model name
            oModel.setData({

                "SalesOrg": { "state": "Error", "text": "Please choose a Sales Organization" },
                "DistChan": { "state": "Error", "text": "Please choose a Distribution Channel" },
                "PromoPlanType": { "state": "Error", "text": "Please choose a Promotion Plan Type" },
                "PromoDesc": { "state": "Error", "text": "Please Enter Promotion Description" },
                "Status": { "state": "Error", "text": "Please select a Status" },
                "FundPlan": { "state": "Error", "text": "Please select a Fund Plan" },
                "SalesArea": { "state": "Error", "text": "Please select a Sales Area" },
                "InSoreDate": { "state": "Error", "text": "Please select both start and end dates" },
                "BuyingDate": { "state": "Error", "text": "Please select both start and end dates" },
                "Customer": { "state": "Error", "text": "Please select Customer" },
                "ProductSelection": { "state": "Error", "text": "Please select a Product" }




            }

            );

        },
        resetCreatePromoModel: function (that) {


            const oModel = that.getOwnerComponent().getModel("PlanHeader"); // Replace with your model name
            oModel.setData({
                "PlanId": "",
                "Vkorg": "",
                "Currency": "",
                "VkorgDesc": "",
                "Vtweg": "",
                "VtwegDesc": "",
                "Sa_Id": "",
                "SaName": "",
                "PlanType": "",
                "PlanTypeDesc": "",
                "PlanCustomer": "",
                "OrderDateF": "",
                "OrderDateT": "",
                "BuyingDateF": "",
                "BuyingDateT": "",
                "InstoreDateF": "",
                "InstoreDateT": "",
                "Status": "",
                "StatusDesc": "",
                "Description": "",
                "ObjectiveId": "",
                "ObjectiveDesc": "",
                "TacticId": "",
                "TacticDesc": "",
                "ContractId": "",
                "FundPlan": "",
                "FundPlanDesc": "",
                "PlanClass": "",
                "ProductSelection": "",
                "Prodh": "",
                "Brand": "",
                "Subbrand": "",
                "To_Item": { "results": [] },
                "PlanningOI": [],
                "PlanningBB": [],
                "PlanningFreeGoods": [],
                "PlanningDetail": [],
                "VolumeWeekDetail": []
            }
            );

        },



    };
});
