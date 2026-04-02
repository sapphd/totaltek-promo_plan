/************************************************************************
 *-----------------------------------------------------------------------
 * Project               : Promo Plan
 * Process               : TPM
 * Task Code             : 
 * Functional Document   : 
 * Technical Document    :
 *  ---------------------------------------------------------------------
 * File       : controller/Dashboard.js
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
    "com/kcc/promoplan/controller/BaseController",
    'sap/ui/model/json/JSONModel',
    "sap/m/MessageToast",
    "sap/m/MessageBox",
    "sap/ui/core/Fragment",
    "com/kcc/promoplan/utils/FragmentHelper",
    "com/kcc/promoplan/utils/ExcelDownload",
    'sap/m/p13n/Engine',
    'sap/ui/core/library',
    'sap/m/p13n/MetadataHelper',
    'sap/m/p13n/SelectionController',
    'sap/m/p13n/SortController',
    'sap/m/p13n/GroupController',
    'sap/ui/model/Sorter',
    'sap/m/table/ColumnWidthController',
    "com/kcc/promoplan/model/formatter"
], (BaseController, JSONModel, MessageToast, MessageBox, Fragment, FragmentHelper, ExcelDownload, Engine, CoreLibrary, MetadataHelper,
    SelectionController, SortController, GroupController, Sorter, ColumnWidthController, formatter) => {
    "use strict";

    return BaseController.extend("com.kcc.promoplan.controller.Dashboard", {
        formatter: formatter,
        onInit() {


            var oRouter = this.getOwnerComponent().getRouter();
            oRouter.getRoute("Dashboard").attachPatternMatched(this._onObjectMatched, this);

            this._registerForP13n();

        },
        _registerForP13n: function () {
            const oTable = this.byId("idPromoPlanTable");

            this.oMetadataHelper = new MetadataHelper([{
                key: "PlanId_col",
                label: "Plan ID",
                path: "PlanId"
            },
            {
                key: "status_col",
                label: "Status",
                path: "Status"
            },
            {
                key: "eventType_col",
                label: "Event Type",
                path: "PlanType"
            },
            {
                key: "customer_col",
                label: "Customer",
                path: "PlanCustomer"
            }
            ]);

            this._mIntialWidth = {
                "PlanId_col": "11rem",
                "status_col": "11rem",
                "eventType_col": "11rem",
                "customer_col": "11rem"
            };

            Engine.getInstance().register(oTable, {
                helper: this.oMetadataHelper,
                controller: {
                    Columns: new SelectionController({
                        targetAggregation: "columns",
                        control: oTable
                    }),
                    Sorter: new SortController({
                        control: oTable
                    }),
                    Groups: new GroupController({
                        control: oTable
                    }),
                    ColumnWidth: new ColumnWidthController({
                        control: oTable
                    })
                }
            });



            // IMPORTANT: bind handler with controller context!
            Engine.getInstance().attachStateChange(this.handleStateChange, this);

            // Optional: log state to verify it fires
            Engine.getInstance().attachStateChange(function (evt) {
                // eslint-disable-next-line no-console
                console.log("[P13n] stateChange:", evt.getParameter("state"));
            }, this);

        },
        onColumnHeaderItemPress: function (oEvt) {
            const oTable = this.byId("idPromoPlanTable");
            const sPanel = oEvt.getSource().getIcon().indexOf("sort") >= 0 ? "Sorter" : "Columns";

            Engine.getInstance().show(oTable, [sPanel], {
                contentHeight: "35rem",
                contentWidth: "32rem",
                source: oTable
            });
        },



        handleStateChange: function (oEvt) {

            const oTable = this.byId("idPromoPlanTable"); // <<< use same ID
            const oState = oEvt.getParameter("state");
            if (!oTable || !oState) {
                return;
            }


            oTable.getColumns().forEach(function (oColumn) {

                const sKey = this._getKey(oColumn);
                const sColumnWidth = oState.ColumnWidth[sKey];

                oColumn.setWidth(sColumnWidth || this._mIntialWidth[sKey]);

                oColumn.setVisible(false);
                oColumn.setSortOrder(CoreLibrary.SortOrder.None);
            }.bind(this));

            oState.Columns.forEach(function (oProp, iIndex) {
                const oCol = this.byId("idPromoPlanTable").getColumns().find((oColumn) => oColumn.data("p13nKey") === oProp.key);
                oCol.setVisible(true);

                oTable.removeColumn(oCol);
                oTable.insertColumn(oCol, iIndex);
            }.bind(this));

            const aSorter = [];
            oState.Sorter.forEach(function (oSorter) {
                const oColumn = this.byId("persoTable").getColumns().find((oColumn) => oColumn.data("p13nKey") === oSorter.key);
                /** @deprecated As of version 1.120 */
                oColumn.setSorted(true);
                oColumn.setSortOrder(oSorter.descending ? CoreLibrary.SortOrder.Descending : CoreLibrary.SortOrder.Ascending);
                aSorter.push(new Sorter(this.oMetadataHelper.getProperty(oSorter.key).path, oSorter.descending));
            }.bind(this));
            oTable.getBinding("rows").sort(aSorter);
        },
        _getKey: function (oControl) {
            return oControl.data("p13nKey");
        },

        openPersoDialog: function (oEvent) {
            const oTable = this.byId("idPromoPlanTable");

            Engine.getInstance().show(oTable, ["Columns", "Sorter"], {
                contentHeight: "35rem",
                contentWidth: "32rem",
                source: oEvent.getSource()
            });
        },

        _onObjectMatched: function (oEvent) {
            var oTable = this.getView().byId("idPromoPlanTable");
            var oBinding = oTable.getBinding("rows");
            if (oBinding) {
                oBinding.refresh(true);
            }
            this.hideBusyIndicator();
        },

        onPromoVH: function () {

            FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.PromoIDVH", "idPromotionVH", "D");
        },
        onSpendTypeVH: function () {

            FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.SpendVH", "idSpendTypeID", "D");
        },
        onPromoPlanTypeVH: function () {

            FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.PromoPlanTypeVH", "idPrPlanTypeFilterID", "D");
        },
        onStatusVH: function () {

            FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.StatusVH", "idStatusVHFilterID", "D");
        },
        onSalesOrgVH: function () {

            FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.SalesOrgVH", "idSalesOrgDBVHID", "D");
        },
        onBrandVH: function () {

            FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.BrandVH", "idBrandVH", "D");
        },
        onSubBrandVH: function () {

            FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.SubBrandVH", "idSubbrandVH", "D");
        },

        onFilterClear: function () {
            const oView = this.getView();

            // Controls with tokens + value
            const aMultiInputIds = [
                "idPromotionVH",
                "idStatusVHFilterID",
                "idPrPlanTypeFilterID",
                "idSpendTypeID",
                "idSalesOrgDBVHID",
                "idBrandVH",
                "idSubbrandVH"
            ];

            aMultiInputIds.forEach(id => {
                const oControl = oView.byId(id);
                if (oControl) {
                    oControl.removeAllTokens();
                    oControl.setValue("");
                }
            });

            // Controls with only value
            const aInputIds = [
                "idBuyingDateF",
                "idInstoreDateF",
                "idPlanCustomerF",
                "idProductHeirarchyF"
            ];

            aInputIds.forEach(id => {
                const oControl = oView.byId(id);
                if (oControl) {
                    oControl.setValue("");
                }
            });
        },


        handlePromoPlanPress: function (oEvent) {

            const sAction = oEvent.getSource().data("action");

            const oRouter = this.getRouter();


            this.showBusyIndicator();
            if (sAction === "create") {
                this.setPromoPlanMode("new");

                oRouter.navTo("PromoPlanCreate");
            }
            else {
                const sPlanId = oEvent.getSource().getParent().getBindingContext().getObject().PlanId;
                this.setPromoPlanMode(sAction === "edit" ? "edit" : "view");
                oRouter.navTo("PromoPlanDetail", { id: sPlanId });

            }
        },
        //below function needs to be removed
        onPromoPlanRowPressRemove: function (oEvent) {
            this.showBusyIndicator();
            const oTable = oEvent.getSource();


            const iSelectedIndex = oTable.getSelectedIndex();

            // Exit if no row is selected
            if (iSelectedIndex < 0) return;

            const sId = oTable.getContextByIndex(iSelectedIndex)?.getObject()?.PlanId;

            if (sId) {
                this.setPromoPlanMode("view");
                this.getRouter().navTo("PromoPlanDetail", { id: sId });
            } else {
                MessageBox.Error("PlanId not found for selected row.");
            }


        },

        onSearch: function (oEvent) {
            var oTable = this.byId("idPromoPlanTable");

            var aFilters = [];


            const sTriggeredId = oEvent.getParameter("id") || "";

            // Helper to process MultiInput filters
            const addMultiInputFilters = (controlId, fieldName) => {

                const oControl = this.byId(controlId);
                const aTokens = oControl.getTokens();

                if (aTokens.length > 0) {
                    aTokens.forEach(oToken => {
                        aFilters.push(
                            new sap.ui.model.Filter(
                                fieldName,
                                sap.ui.model.FilterOperator.EQ,
                                oToken.getKey().toUpperCase()
                            )
                        );
                    });
                } else {
                    const sValue = oControl.getValue();
                    if (sValue) {
                        aFilters.push(
                            new sap.ui.model.Filter(
                                fieldName,
                                sap.ui.model.FilterOperator.EQ,
                                sValue.toUpperCase()
                            )
                        );
                    }
                }

            };

            // MultiInput fields
            addMultiInputFilters("idPromotionVH", "PlanId");
            addMultiInputFilters("idStatusVHFilterID", "Status");
            addMultiInputFilters("idPrPlanTypeFilterID", "PlanType");
            addMultiInputFilters("idSpendTypeID", "SpendType");
            addMultiInputFilters("idSalesOrgDBVHID", "Vkorg");
            addMultiInputFilters("idBrandVH", "Brand");
            addMultiInputFilters("idSubbrandVH", "Subbrand");


            // Plan Customer (Custom Control)
            const sCustomer = this.byId("idPlanCustomerF")?.getValue();
            if (sCustomer) {
                aFilters.push(new sap.ui.model.Filter("PlanCustomer", sap.ui.model.FilterOperator.EQ, sCustomer));
            }

            // DateRangeSelection helper
            const addDateRangeFilters = (controlId, fieldFrom, fieldTo) => {
                const oControl = this.byId(controlId);
                const oStart = oControl?.getDateValue();
                const oEnd = oControl?.getSecondDateValue();
                var oDateFormat = sap.ui.core.format.DateFormat.getDateInstance({
                    pattern: "yyyyMMdd"
                });

                var sFormatteStartdDate = oDateFormat.format(oStart);
                var sFormatteEnddDate = oDateFormat.format(oEnd);



                if (oStart && oEnd) {
                    aFilters.push(new sap.ui.model.Filter(fieldFrom, sap.ui.model.FilterOperator.LE, sFormatteEnddDate));
                    aFilters.push(new sap.ui.model.Filter(fieldTo, sap.ui.model.FilterOperator.GE, sFormatteStartdDate));
                }
            };

            // Date fields
            addDateRangeFilters("idBuyingDateF", "BuyingDateF", "BuyingDateT");
            addDateRangeFilters("idInstoreDateF", "InstoreDateF", "InstoreDateT");



            // Product Hierarchy (Custom Control)
            const sProdHierarchy = this.byId("idProductHeirarchyF")?.getValue?.();
            if (sProdHierarchy) {
                aFilters.push(new sap.ui.model.Filter("Prodh", sap.ui.model.FilterOperator.EQ, sProdHierarchy));
            }

            oTable.setFirstVisibleRow(0);
            oTable.bindRows({
                path: "/Plan_HeaderSet",
                filters: aFilters,
                parameters: {
                    operationMode: "Client"
                }
            });
        },

        onCopyConfirmPress: function () {
            var oTable = this.byId("idPromoPlanTable");
            var aSelectedIndices = oTable.getSelectedIndices();

            if (!aSelectedIndices || aSelectedIndices.length === 0) {
                sap.m.MessageBox.warning("Please select at least one row to copy.");
                return;
            }
            var that = this;
            MessageBox.confirm("Are you sure? You want to copy the selected Promo's?", {
                actions: [MessageBox.Action.OK, MessageBox.Action.CANCEL],
                emphasizedAction: MessageBox.Action.OK,
                onClose: function (sAction) {
                    if (sAction === "OK") {
                        that.onCopyPress();

                    }
                },
                dependentOn: this.getView()
            });
        },
        onCopyPress: function () {
            var oTable = this.byId("idPromoPlanTable");
            var aSelectedIndices = oTable.getSelectedIndices();

            if (!aSelectedIndices || aSelectedIndices.length === 0) {
                sap.m.MessageBox.warning("Please select at least one row to copy.");
                return;
            }
            var aPlanIds = [];

            aSelectedIndices.forEach(function (iIndex) {
                var oContext = oTable.getContextByIndex(iIndex);
                if (oContext) {
                    var sPlanId = oContext.getProperty("PlanId"); // property name from your entity
                    aPlanIds.push({ PlanID: sPlanId, PlanIDCopy: "" });
                }
            });

            var oCopyPlanIDs = {

                "Simulate": false,

                "CopyPlanID": aPlanIds

            };

            var that = this;
            const oODataModel = this.getView().getModel("PromoCopy");
            oODataModel.create("/Plan_HeaderSet", oCopyPlanIDs, {
                success: (oData) => {
                    that.hideBusyIndicator();



                    var successList = [];
                    var failedList = [];

                    oData.CopyPlanID.results.forEach(function (item) {
                        if (item.Success) {
                            successList.push(item.PlanID + " copied to " + item.PlanIDCopy);
                        } else {
                            failedList.push(item.PlanID);
                        }
                    });

                    var message = "";

                    if (successList.length > 0) {
                        message += "Plan ID copied successfully:\n" + successList.join("\n");
                    }

                    if (failedList.length > 0) {
                        if (message !== "") {
                            message += "\n\n";
                        }
                        message += "Plan ID copy failed for following IDs:\n" + failedList.join("\n");
                    }


                    MessageBox.show(message, {
                        title: "Information"
                    });
                    oTable.clearSelection();
                },
                error: (oError) => {
                    that.hideBusyIndicator();


                    that.showMessageBox("Error", "Error Copying Promo Plan ID's", "Error");
                }
            });

        },
        onAfterRendering: function () {
            // this.getView().byId("idPromoPlanTable").getModel().refresh(true);
        }





    });
});