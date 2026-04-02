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
    'sap/m/Token',
    "com/kcc/promoplan/utils/Validate"

], function (Fragment, Token, Validate) {
    "use strict";

    return {
        openValueHelpDialog: function (that, sFragmentName, sInputId, sIndicator) {
            var oView = that.getView();

            var sFragmentId = oView.getId() + "-" + sFragmentName;

            if (!that._pDialogs) {
                that._pDialogs = {};
            }



            if (!that._pDialogs[sFragmentId]) {
                that._pDialogs[sFragmentId] = Fragment.load({
                    id: sFragmentId,
                    name: sFragmentName,
                    controller: that
                }).then(function (oDialog) {
                    oView.addDependent(oDialog);
                    return oDialog;
                });
            }


            that._pDialogs[sFragmentId].then(function (oDialog) {
                that._currentInputId = sInputId; // Store input ID for use in close handler
                var oPlanHeaderModel = that.getView().getModel("PlanHeader");
                var oBinding = oDialog.getBinding("items")
                var aFilters = [];
                if (sInputId === "idPromoPlanTypeID") {


                    aFilters.push(new sap.ui.model.Filter("Vkorg", sap.ui.model.FilterOperator.EQ, oPlanHeaderModel.getProperty("/Vkorg")));
                    aFilters.push(new sap.ui.model.Filter("Vtweg", sap.ui.model.FilterOperator.EQ, oPlanHeaderModel.getProperty("/Vtweg")));

                }
                else if (sInputId === "idFundPlanVHID") {

                    aFilters.push(new sap.ui.model.Filter("Salesorg", sap.ui.model.FilterOperator.EQ, oPlanHeaderModel.getProperty("/Vkorg")));
                    aFilters.push(new sap.ui.model.Filter("Status", sap.ui.model.FilterOperator.EQ, "APPR"));


                }
                else if (sInputId === "idObjectiveID") {

                    aFilters.push(new sap.ui.model.Filter("Vkorg", sap.ui.model.FilterOperator.EQ, oPlanHeaderModel.getProperty("/Vkorg")));
                    aFilters.push(new sap.ui.model.Filter("PlanType", sap.ui.model.FilterOperator.EQ, oPlanHeaderModel.getProperty("/PlanType")));


                }

                // Predefine the IDs that should add the indicator filter
                const INDICATOR_IDS = new Set([
                    "idSalesOrgDBVHID",
                    "idStatusVHFilterID",
                    "idStatusVHCreateID",
                    "idSalesAreaGDVHID",
                    "idSalesOrgGDVHID",
                   // "idDistChanGDVHID",
                ]);

                // Usage
                if (INDICATOR_IDS.has(sInputId)) {

                    aFilters.push(new sap.ui.model.Filter("f4_ind", sap.ui.model.FilterOperator.EQ, sIndicator));
                }
                if(sInputId!=="idDistChanGDVHID"||sInputId!=="idSalesAreaGDVHID"){
                oBinding.filter(aFilters);
                }

                oDialog.open();
            });



        },

        handleVHConfirm: function (that, oEvent) {
            var aSelectedItems = oEvent.getParameter("selectedItems");
            var oMultiInput = that.byId(that._currentInputId); // Use stored input ID
            oMultiInput.removeAllTokens();
            const oPlanHeaderModel = that.getView().getModel("PlanHeader");
            var oAppViewModel = that.getView().getModel("appView");

            const fieldMap = {
                "idSalesOrgGDVHID": { key: "/Vkorg", text: "/VkorgDesc" },
                "idDistChanGDVHID": { key: "/Vtweg", text: "/VtwegDesc" },
                "idPromoPlanTypeID": { key: "/PlanType", text: "/PlanTypeDesc" },
                "idStatusVHCreateID": { key: "/Status", text: "/StatusDesc" },
                "idFundPlanVHID": { key: "/FundPlan", text: "/FundPlanDesc" },
                "idSalesAreaGDVHID": { key: "/Sa_Id", text: "/SaName" },
                "idObjectiveID": { key: "/ObjectiveId", text: "/ObjectiveDesc" },
                "idProductSelectionID": { key: "/ProductSelection", text: "/ProductSelectionDesc" }

            };

            // Find matching field config
            //const matchedKey = Object.keys(fieldMap).find(key => sId.includes(key));
            const fieldConfig = fieldMap[that._currentInputId];

            if (aSelectedItems && aSelectedItems.length > 0) {

                aSelectedItems.forEach(function (oItem) {
                    if (that._currentInputId === "idPromoPlanTypeID") {

                        var oPromoPlanType = oItem.getBindingContext("PromoPlan").getObject();

                        oAppViewModel.setProperty("/MaxTactics", oPromoPlanType.MaxTactics);
                    }
                    if (that._currentInputId === "idSpendTypeID") {

                        var sKey = oItem.getCells()[2].getText();
                        var sText = oItem.getCells()[3].getText();
                    }
                    else {
                        var sKey = oItem.getCells()[0].getText();
                        var sText = oItem.getCells()[1].getText();
                    }
                    if (that._currentInputId === "idProductSelectionID") {

                        for (var i = 1; i <= that._iSpendOIColumnSetCount; i++) {
                            that.onPlanningOIRemoveColumns();
                        }

                        //oAppViewModel.setProperty("/MaxTactics", 0);
                        that.getView().getModel("PlanHeader").setProperty("/ProductSelection", sKey);
                        that.getView().getModel("VolumeModel").setData([]);
                        that.getView().getModel("PlanHeader").getData().To_Item.results = [];



                        // Normalize sKey to match property names
                        var sNormalizedKey = sText.replace(/\s+/g, "");

                        ["ProductHierarchy", "Brand", "Product", "SubBrand"].forEach(function (sProp) {
                            oAppViewModel.setProperty("/" + sProp, sProp === sNormalizedKey);
                        });


                    }

                    if (that._currentInputId === "idPromoPlanTypeID") {


                        that.getView().getModel("PlanHeader").setProperty("/PlanClass", oItem.getBindingContext("PromoPlan").getObject().PlanClass);

                    }

                    if (that._currentInputId === "idProductSelectionID") {
                        oMultiInput.addToken(new Token({
                            key: sKey,
                            text: sText

                        }));
                        if (sKey === "SubBrand") {
                            oPlanHeaderModel.setProperty(fieldConfig.key, "SBRAN");
                        }
                        else {
                            oPlanHeaderModel.setProperty(fieldConfig.key, sKey);
                        }

                        oPlanHeaderModel.setProperty(fieldConfig.text, sText);

                    }
                    else if (typeof fieldConfig === "object") {
                        oMultiInput.addToken(new Token({
                            key: sKey,
                            text: sKey


                        }));
                        oPlanHeaderModel.setProperty(fieldConfig.key, sKey);

                        oPlanHeaderModel.setProperty(fieldConfig.text, sText);
                    }
                    else {
                        oMultiInput.addToken(new Token({
                            key: sKey,
                            text: sText

                        }));

                    }

                    Validate.validateGeneralData(that);
                    Validate.validatePlanHeaderData(that);
                });
                //oMultiInput.fireTokenUpdate();
            }
            var oBinding = oEvent.getSource().getBinding("items");
            oBinding.filter([]);

        },
        handleVHSearch: function (that, oEvent) {
            var sValue = oEvent.getParameter("value").toUpperCase();
            var oPlanHeaderModel = that.getView().getModel("PlanHeader");
            var aFilter = [];

            if (that._currentInputId === "idPromotionVH" && sValue) {

                aFilter.push(new sap.ui.model.Filter("PlanId", sap.ui.model.FilterOperator.Contains, sValue));


            }
            if (that._currentInputId === "idSalesOrgGDVHID" && sValue) {
                aFilter.push(new sap.ui.model.Filter("f4_ind", sap.ui.model.FilterOperator.EQ, "C"));

                if (sValue) {

                    aFilter.push(new sap.ui.model.Filter("SalesOrg", sap.ui.model.FilterOperator.Contains, sValue));
                }
            }
            if (that._currentInputId === "idDistChanGDVHID" && sValue) {
                aFilter.push(new sap.ui.model.Filter("f4_ind", sap.ui.model.FilterOperator.EQ, "C"));
                if (sValue) {

                    aFilter.push(new sap.ui.model.Filter("DistCh", sap.ui.model.FilterOperator.Contains, sValue));
                }
            }
            if (that._currentInputId === "idSalesAreaGDVHID" && sValue) {
               aFilter.push(new sap.ui.model.Filter("f4_ind", sap.ui.model.FilterOperator.EQ, "C"));

                if (sValue) {

                    aFilter.push(new sap.ui.model.Filter("SaId", sap.ui.model.FilterOperator.Contains, sValue));
                    
                }
            }
            if (that._currentInputId === "idPromoPlanTypeID" && sValue) {


                aFilter.push(new sap.ui.model.Filter("Vkorg", sap.ui.model.FilterOperator.Contains, oPlanHeaderModel.getProperty("/Vkorg")));
                aFilter.push(new sap.ui.model.Filter("Vtweg", sap.ui.model.FilterOperator.Contains, oPlanHeaderModel.getProperty("/Vtweg")));
                if (sValue) {
                    aFilter.push(new sap.ui.model.Filter("PlanType", sap.ui.model.FilterOperator.Contains, sValue));
                }

            }
            if (that._currentInputId === "idStatusVHFilterID" && sValue) {
                aFilter.push(new sap.ui.model.Filter("f4_ind", sap.ui.model.FilterOperator.EQ, "D"));
                if (sValue) {
                    aFilter.push(new sap.ui.model.Filter("Status", sap.ui.model.FilterOperator.Contains, sValue));
                }
            }
            if (that._currentInputId === "idPrPlanTypeFilterID" && sValue) {
                if (sValue) {
                    aFilter.push(new sap.ui.model.Filter("PlanType", sap.ui.model.FilterOperator.Contains, sValue));
                }
            }

            if (that._currentInputId === "idSpendTypeID" && sValue) {
                //aFilter.push(new sap.ui.model.Filter("f4_ind", sap.ui.model.FilterOperator.EQ, "D"));

                if (sValue) {


                    aFilter.push(new sap.ui.model.Filter("SpendType", sap.ui.model.FilterOperator.Contains, sValue));
                    aFilter.push(new sap.ui.model.Filter("TacticId", sap.ui.model.FilterOperator.Contains, sValue));
                    aFilter.push(new sap.ui.model.Filter("TacticsDesc", sap.ui.model.FilterOperator.Contains, sValue));
                    aFilter.push(new sap.ui.model.Filter("Description", sap.ui.model.FilterOperator.Contains, sValue))


                }
            }
            if (that._currentInputId === "idSalesOrgDBVHID" && sValue) {
                aFilter.push(new sap.ui.model.Filter("f4_ind", sap.ui.model.FilterOperator.EQ, "D"));
                if (sValue) {

                    aFilter.push(new sap.ui.model.Filter("SalesOrg", sap.ui.model.FilterOperator.Contains, sValue));
                }
            }


            if (that._currentInputId === "idBrandVH" && sValue) {
                if (sValue) {

                    aFilter.push(new sap.ui.model.Filter("Domvalue", sap.ui.model.FilterOperator.Contains, sValue));
                }
            }

            if (that._currentInputId === "idSubbrandVH" && sValue) {

                if (sValue) {

                    aFilter.push(new sap.ui.model.Filter("Subrand", sap.ui.model.FilterOperator.Contains, sValue));
                }
            }

            if (that._currentInputId === "idStatusVHCreateID") {

                aFilter.push(new sap.ui.model.Filter("f4_ind", sap.ui.model.FilterOperator.EQ, "C"));
                if (sValue) {

                    aFilter.push(new sap.ui.model.Filter("Status", sap.ui.model.FilterOperator.Contains, sValue));
                }
            }
            if (that._currentInputId === "idFundPlanVHID" && sValue) {

                aFilter.push(new sap.ui.model.Filter("Salesorg", sap.ui.model.FilterOperator.EQ, oPlanHeaderModel.getProperty("/Vkorg")));


                if (sValue) {
                    aFilter.push(new sap.ui.model.Filter("Fundplanid", sap.ui.model.FilterOperator.Contains, sValue.toUpperCase()));
                }
                aFilter.push(new sap.ui.model.Filter("Status", sap.ui.model.FilterOperator.Contains, "APPR"));
            }
            if (that._currentInputId === "idObjectiveID" && sValue) {
                aFilter.push(new sap.ui.model.Filter("f4_ind", sap.ui.model.FilterOperator.EQ, "C"));

                if (sValue) {

                    aFilter.push(new sap.ui.model.Filter("ObjectiveId", sap.ui.model.FilterOperator.Contains, sValue));
                }
            }


            var oBinding = oEvent.getSource().getBinding("items");
            oBinding.filter(aFilter);
        },
        handleVHCancel: function (that, oEvent) {


            var oBinding = oEvent.getSource().getBinding("items");
            oBinding.filter([]);



        }

    };
});
