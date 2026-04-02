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
    "sap/ui/export/library",
    "sap/ui/export/Spreadsheet",
    "sap/m/MessageToast",
    'sap/m/p13n/Engine',
    'sap/ui/core/library',
    'sap/m/p13n/MetadataHelper',
    'sap/m/p13n/SelectionController',
    'sap/m/p13n/SortController',
    'sap/m/p13n/GroupController',
    'sap/ui/model/Sorter',
    'sap/m/table/ColumnWidthController'
], function (exportLibrary, Spreadsheet, MessageToast, Engine, CoreLibrary, MetadataHelper,
    SelectionController, SortController, GroupController, Sorter, ColumnWidthController) {
    "use strict";
    const EdmType = exportLibrary.EdmType;
    return {
        createColumnConfig: function () {
            const aCols = [];

            aCols.push({
                label: "Plan ID",
                property: "PlanId",
                type: EdmType.String
            });

            aCols.push({
                label: "Sales Organization",
                type: EdmType.String,
                property: "Vkorg"
            });

            aCols.push({
                label: "Event Type",
                property: "PlanType",
                type: EdmType.String
            });

            aCols.push({
                label: "Customer",
                property: "PlanCustomer",
                type: EdmType.String
            });

            aCols.push({
                label: "Buying Date From",
                property: "BuyingDateF",
                type: EdmType.Date
            });

            aCols.push({
                label: "Buying Date To",
                property: "BuyingDateT",
                type: EdmType.Date

            });

            aCols.push({
                label: "Sales Team",
                property: "SaName",
                type: EdmType.String
            });



            return aCols;
        },
        _registerForP13n: function (that) {
            const oTable = that.byId("idPromoPlanTable");

            that.oMetadataHelper = new MetadataHelper([{
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

            that._mIntialWidth = {
                "PlanId_col": "11rem",
                "status_col": "11rem",
                "eventType_col": "11rem",
                "customer_col": "11rem"
            };

            Engine.getInstance().register(oTable, {
                helper: that.oMetadataHelper,
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
      Engine.getInstance().attachStateChange(this.handleStateChange, that);

      // Optional: log state to verify it fires
      Engine.getInstance().attachStateChange(function (evt) {
        // eslint-disable-next-line no-console
        console.log("[P13n] stateChange:", evt.getParameter("state"));
      }, that);

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
                const oCol = this.byId("persoTable").getColumns().find((oColumn) => oColumn.data("p13nKey") === oProp.key);
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
        onExport: function (oController, oEvent) {

            if (!oController._oTable) {
                oController._oTable = oController.byId("idPromoPlanTable");
            }

            const oTable = oController._oTable;
            if (!oTable) {
                MessageToast.show("Promo plan table not found.");
                return;
            }


            // Support both sap.ui.table.* and sap.m.Table
            const oRowBinding = oTable.getBinding("rows");
            if (!oRowBinding || !oRowBinding.getLength || oRowBinding.getLength() === 0) {
                MessageToast.show("No data to export.");
                return;
            }

            const aCols = this.createColumnConfig();
            const oSettings = {
                workbook: {
                    columns: aCols
                },
                dataSource: oRowBinding,
                fileName: "PromoPlan.xlsx",
                worker: false // We need to disable worker because we are using a MockServer as OData Service
            };

            const oSheet = new Spreadsheet(oSettings);
            oSheet.build()
                .then(function () {
                    MessageToast.show("Export completed: PromoPlan.xlsx");
                })
                .catch(function (err) {
                    // Optional: log error details
                    jQuery.sap.log.error("Spreadsheet export failed", err && err.message);
                    MessageToast.show("Export failed. Please try again.");
                })
                .finally(function () {
                    oSheet.destroy();
                });

        },
        _getKey: function (oControl) {
            return oControl.data("p13nKey");
        },
        onPromoPlanSort: function (oController, oEvent) {

            const oTable = oController.byId("persoTable");
            const sAffectedProperty = this._getKey(oEvent.getParameter("column"));
            const sSortOrder = oEvent.getParameter("sortOrder");

            //Apply the state programatically on sorting through the column menu
            //1) Retrieve the current personalization state
            Engine.getInstance().retrieveState(oTable).then(function (oState) {

                //2) Modify the existing personalization state --> clear all sorters before
                oState.Sorter.forEach(function (oSorter) {
                    oSorter.sorted = false;
                });
                oState.Sorter.push({
                    key: sAffectedProperty,
                    descending: sSortOrder === CoreLibrary.SortOrder.Descending
                });

                //3) Apply the modified personalization state to persist it in the VariantManagement
                Engine.getInstance().applyState(oTable, oState);
            });

        },
        openPersoDialog: function (oController, oEvent) {
            const oTable = oController.byId("idPromoPlanTable");

            Engine.getInstance().show(oTable, ["Columns", "Sorter"], {
                contentHeight: "35rem",
                contentWidth: "32rem",
                source: oEvent.getSource()
            });
        }

    };
});
