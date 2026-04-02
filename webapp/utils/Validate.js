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

sap.ui.define([], function () {
    "use strict";


    return {
        validateGeneralData: function (that) {

            const oAppViewModel = that.getView().getModel("appView");
                oAppViewModel.setProperty("/messages", []);

            var aErrorMessages = [];

            const oValidationModel = that.getView().getModel("validation");
            let isValid = true;
            const fields = [
                { id: "idSalesOrgGDVHID", key: "SalesOrg", errorText: "Please choose a Sales Organization." },
                { id: "idDistChanGDVHID", key: "DistChan", errorText: "Please choose a Distribution Channel." },
                { id: "idPromoPlanTypeID", key: "PromoPlanType", errorText: "Please choose a Promotion Plan Type" },
                { id: "idStatusVHCreateID", key: "Status", errorText: "Please select a Status" },
                { id: "idFundPlanVHID", key: "FundPlan", errorText: "Please select a Fund Plan" },
                { id: "idSalesAreaGDVHID", key: "SalesArea", errorText: "Please select a Sales Area" }

            ];

            fields.forEach(field => {
                const tokens = that.byId(field.id).getTokens();
                const path = "/" + field.key;

                if (tokens.length === 0) {
                    oValidationModel.setProperty(path + "/state", "Error");
                    oValidationModel.setProperty(path + "/text", field.errorText);
                    isValid = false;
                    aErrorMessages.push({
                        type: 'Error',
                        message: 'Error',
                        additionalText:field.errorText,
                        group: "General",
                        description: field.errorText +" in General Section"
                        	
                    });
                } else {
                    oValidationModel.setProperty(path + "/state", "None");
                    oValidationModel.setProperty(path + "/text", "");
                }
            });

            var sPromoDesc = that.byId("idPromoDesc").getValue();


            if (sPromoDesc === "") {
                oValidationModel.setProperty("/PromoDesc/state", "Error");
                oValidationModel.setProperty("/PromoDesc/text", "Please enter Promo Description");
                isValid = false;
                aErrorMessages.push({
                    type: 'Error',
                    
                     message: 'Error',
                        additionalText:"Please enter Promo Description",
                        group: "General",
                    description: "Please enter Promo Description in General Section"
                });
            }
            else {
                oValidationModel.setProperty("/PromoDesc/state", "None");
                oValidationModel.setProperty("/PromoDesc/text", "");

            }

            if (isValid) {
                oAppViewModel.setProperty("/messages", []);
            }
            else {
                oAppViewModel.setProperty("/messages", aErrorMessages);
            }

            return isValid;

        },

        validateSalesAndDisChan: function (that) {

            const oValidationModel = that.getView().getModel("validation");
            let isValid = true;

            const fields = [
                { id: "idSalesOrgGDVHID", key: "SalesOrg", errorText: "Please select at least one Sales Organization." },
                { id: "idDistChanGDVHID", key: "DistChan", errorText: "Please choose a Distribution Channel." }
            ];

            fields.forEach(field => {
                const tokens = that.byId(field.id).getTokens();
                const path = "/" + field.key;

                if (tokens.length === 0) {
                    oValidationModel.setProperty(path + "/state", "Error");
                    oValidationModel.setProperty(path + "/text", field.errorText);
                    isValid = false;
                } else {

                    oValidationModel.setProperty(path + "/state", "None");
                    oValidationModel.setProperty(path + "/text", "");
                }
            });



            return isValid;

        },
        validatePlanHeaderData: function (that) {
            const oAppViewModel = that.getView().getModel("appView");

            var aErrorMessages = [];
            const oValidationModel = that.getView().getModel("validation");


            var bDateRangeValid = this.validateDateRangeChange(oValidationModel, that);

            var oCustomer = that.getView().byId("idPHCustomerHeirarchy");
            var isCustomerValid = oCustomer.getValue() ? true : false;

            // Update validation model
            if (!isCustomerValid) {
                oValidationModel.setProperty("/Customer/state", "Error");
                oValidationModel.setProperty("/Customer/text", "Please select Customer");
                aErrorMessages.push({
                        type: 'Error',
                        message: 'Error',
                        additionalText:"Please select Customer",
                        group: "General",
                        description: "Please select Customer in Plan Header Section"
                     
                });
            }

            const aProdTokens = that.byId("idProductSelectionID").getTokens();

            var isValid = false;

            if (aProdTokens.length === 0) {
                oValidationModel.setProperty("/ProductSelection/state", "Error");
                oValidationModel.setProperty("/ProductSelection/text", "Please select a Product");
                isValid = false;
                aErrorMessages.push({
                     type: 'Error',
                        message: 'Error',
                        additionalText:"Please select Product",
                        group: "General",
                        description: "Please select Product in Plan Header Section"
                   
                });
            } else {
                oValidationModel.setProperty("/ProductSelection/state", "None");
                oValidationModel.setProperty("/ProductSelection/text", "");
                isValid = true;
            }

            if (!isValid) {
                var aMessages = oAppViewModel.getProperty("/messages");


                oAppViewModel.setProperty("/messages", [...aMessages, ...aErrorMessages]);
            }


            return bDateRangeValid & isCustomerValid & isValid;

        },
        validateDateRangeChange: function (oValidationModel, that) {
            const oAppViewModel = that.getView().getModel("appView");

            var aErrorMessages = [];
            var oView = that.getView();
            let bValidDateRange = true;

            const aDateRangeConfigs = [

                { id: "idBuyingDateRange", path: "/BuyingDate" },
                { id: "idInStoreRange", path: "/InSoreDate" }
            ];


            aDateRangeConfigs.forEach(config => {
                const oControl = oView.byId(config.id);
                const oDateFrom = oControl.getDateValue();
                const oDateTo = oControl.getSecondDateValue();

                // Default to valid
                let sState = "None";
                let sText = "";

                if (!oDateFrom || !oDateTo) {
                    sState = "Error";
                    sText = "Please select both start and end dates.";
                    bValidDateRange = false;
                    aErrorMessages.push({
                         type: 'Error',
                        message: 'Error',
                        additionalText:sText,
                        group: "Plan Header",
                        description: sText+" in Plan Header Section"
                         
                    });
                } else if (oDateFrom > oDateTo) {
                    bValidDateRange = false;
                    sState = "Error";
                    sText = "Start date must be before end date.";
                    aErrorMessages.push({
                         type: 'Error',
                        message: 'Error',
                        additionalText:sText,
                        group: "Plan Header",
                        description: sText+" in Plan Header Section"
                         
                    });
                } else {

                    // Optional: max range check
                    const iMaxDays = 180;
                    const iDiffDays = Math.floor((oDateTo - oDateFrom) / (1000 * 60 * 60 * 24));
                    if (iDiffDays > iMaxDays) {
                        bValidDateRange = false;
                        sState = "Error";
                        sText = `Date range cannot exceed ${iMaxDays} days.`;

                        aErrorMessages.push({
                            type: 'Error',
                        message: 'Error',
                        additionalText:sText,
                        group: "Plan Header",
                        description: sText+" in Plan Header Section"
                        });
                    }
                }

                // Update validation model
                oValidationModel.setProperty(config.path + "/state", sState);
                oValidationModel.setProperty(config.path + "/text", sText);
            });

            if (!bValidDateRange) {
                var aMessages = oAppViewModel.getProperty("/messages");


                oAppViewModel.setProperty("/messages", [...aMessages, ...aErrorMessages]);
            }
            return bValidDateRange;

        },

        validateOILineItems: function (that) {
            const oTable = that.getView().byId("idPlanningOITable");
            const aRows = oTable.getRows();

            let bHasError = false;

            aRows.forEach(row => {

                // Get the inputs from the row
                const oProductInput = row.getCells()[0];
                const oSellingSKUInput = row.getCells()[1];
                const oBrandInput = row.getCells()[2];

                // Get the data from the row context
                const oContext = row.getBindingContext("PlanHeader");
                if (!oContext) return; // skip unbound rows

                const oData = oContext.getObject();

                // Check if any one of the three is filled
                const bHasSellingSKU = !!oData.Matnr;
                const bHasBrand = !!oData.Brand;
                const bHasProduct = !!oData.Prodh;

                if (!bHasSellingSKU && !bHasBrand && !bHasProduct) {
                    // None selected — show error on all three
                    oSellingSKUInput.setValueState("Error");
                    oSellingSKUInput.setValueStateText("At least one of Selling SKU, Brand, or Product must be selected.");

                    oBrandInput.setValueState("Error");
                    oBrandInput.setValueStateText("At least one of Selling SKU, Brand, or Product must be selected.");

                    oProductInput.setValueState("Error");
                    oProductInput.setValueStateText("At least one of Selling SKU, Brand, or Product must be selected.");

                    bHasError = true;
                } else {
                    // At least one selected — clear all errors
                    oSellingSKUInput.setValueState("None");
                    oSellingSKUInput.setValueStateText("");

                    oBrandInput.setValueState("None");
                    oBrandInput.setValueStateText("");

                    oProductInput.setValueState("None");
                    oProductInput.setValueStateText("");
                }




                // Validate Spend Type MultiInput
                const oSpendTypeInput = row.getCells()[19];
                if (oSpendTypeInput.getTokens().length === 0 || !oData.SpendType1) {
                    oSpendTypeInput.setValueState("Error");
                    oSpendTypeInput.setValueStateText("Please select Spend Type");
                    bHasError = true;
                } else {
                    oSpendTypeInput.setValueState("None");
                    oSpendTypeInput.setValueStateText("");

                }


            }
            );

            if (bHasError) {
                sap.m.MessageToast.show("Please correct the highlighted errors.");
            } else {
                sap.m.MessageToast.show("Line Itemd Validation passed. Submitting data...");
                // Proceed with submission logic
            }
            return bHasError;


        },




    };
});
