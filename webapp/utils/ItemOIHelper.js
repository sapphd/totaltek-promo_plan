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
    "com/kcc/promoplan/model/formatter",
    "com/kcc/promoplan/utils/ItemOIHelper",
    'sap/ui/model/Filter',
    'sap/ui/model/FilterOperator'
], function (Fragment, Token, formatter, ItemOIHelper, Filter, FilterOperator) {
    "use strict";

    return {

        formatDateToBackend: function (oDate) {
            return oDate ? oDate.toISOString().split("T")[0] + "T00:00:00" : null;
        },

        _vhConfigurations: function (sFieldType) {


            const spendTypeConfig = {
                setPath: "/SpendSet",
                keyField: "SpendType",
                textField: "Description",
                i18n: {
                    title: "spendTypeTitle",
                    noData: "spendTypeNoDataText",
                    placeholder: "spendTypeSrchPlaceHolder",
                    column1: "spendType",
                    column2: "description"
                }
            };

            const configMap = {
                Brand: {
                    setPath: "/BrandSet",
                    keyField: "Domvalue",
                    textField: "Description",

                    i18n: {
                        title: "brandTitle",
                        noData: "brandNoDataText",
                        placeholder: "brandSrchPlaceHolder",
                        column1: "brand",
                        column2: "description"
                    }
                },

                SubBrand: {
                    setPath: "/SubbrandSet",
                    keyField: "Subrand",
                    textField: "Subdesc",

                    i18n: {
                        title: "subBrandTitle",
                        noData: "subBrandNoDataText",
                        placeholder: "subBrandSrchPlaceHolder",
                        column1: "subBrand",
                        column2: "description"
                    }
                },
                SellingSKU: {
                    setPath: "/SellingSKUSet",
                    keyField: "Matnr",
                    textField: "matnr_desc",

                    i18n: {
                        title: "sellingSKUTitle",
                        noData: "sellingSKUNoDataText",
                        placeholder: "sellingSKUSrchPlaceHolder",
                        column1: "Material",
                        column2: "Description"
                    }
                },

                SpendType1: spendTypeConfig,
                SpendType2: spendTypeConfig,
                SpendType3: spendTypeConfig,
                SpendType4: spendTypeConfig,
                SpendType5: spendTypeConfig

            };

            return configMap[sFieldType];


        },


        onOIValueHelpRequest: function (oEvent, that) {

            that._oMultiInput = oEvent.getSource();
            that._oRowContext = that._oMultiInput.getBindingContext("PromoPlan");

            const sFieldType = that._oMultiInput.data("valuehelp");


            const config = this._vhConfigurations(sFieldType);
            this.onValueHelpRequest(config, that);

        },


        onValueHelpRequest: function (config, that) {

            if (!that._oVHDialog) {
                that._oVHDialog = new sap.m.TableSelectDialog("valueHelpDialog", {
                    contentWidth: "30%",
                    multiSelect: false,
                    showClearButton: true,
                    liveChange:this.handleOIVHSearch.bind(that),
                    search: this.handleOIVHSearch.bind(that),
                    confirm: this.handleOIVHConfirm.bind(that),
                    cancel: this.handleOIVHCancel.bind(that),
                    columns: [
                        new sap.m.Column({
                            header: new sap.m.Text({ text: "{i18n>" + config.i18n.column1 + "}" })
                        }),
                        new sap.m.Column({
                            header: new sap.m.Text({ text: "{i18n>" + config.i18n.column2 + "}" }),

                            minScreenWidth: "Tablet",
                            demandPopin: true
                        })
                    ]
                });
                that.getView().addDependent(that._oVHDialog);
            }

            that._oVHDialog.setTitle(that.getView().getModel("i18n").getResourceBundle().getText(config.i18n.title));
            that._oVHDialog.setNoDataText(that.getView().getModel("i18n").getResourceBundle().getText(config.i18n.noData));
            that._oVHDialog.setSearchPlaceholder(that.getView().getModel("i18n").getResourceBundle().getText(config.i18n.placeholder));

            var oColumns = that._oVHDialog.getColumns();
            oColumns[0].getHeader().setText(that.getModel("i18n").getProperty(config.i18n.column1));
            oColumns[1].getHeader().setText(that.getModel("i18n").getProperty(config.i18n.column2));
            var aFilters = [];

            var sModelPath = "PromoPlan>";
            if (config.keyField === "Matnr") {

                sModelPath = "FilteredSellingSKU>";

            }

         
            const oItemTemplate = new sap.m.ColumnListItem({
                cells: [
                    new sap.m.Text({ text: "{" + sModelPath + config.keyField + "}" }),
                    new sap.m.Text({ text: "{" + sModelPath + config.textField + "}" })
                ]
            });

            that._oVHDialog.bindAggregation("items", {
                filters: aFilters,
                path: sModelPath + config.setPath,
                template: oItemTemplate
            });

            that._oVHDialog.open();

        },

        handleOIVHCancel: function (oEvent) {
            var oBinding = oEvent.getSource().getBinding("items");
            oBinding.filter([]);
        },

        handleOIVHConfirm: function (oEvent) {
            var oBinding = oEvent.getSource().getBinding("items");
            oBinding.filter([]);
            const oSelectedItem = oEvent.getParameter("selectedItem");
            if (oSelectedItem) {
                var oTable = this.getView().byId("idVolumePerWeek");
                var aColumns = oTable.getColumns();

                var oTableDis = this.getView().byId("idVolumePerWeekDisplay");

                var aDisColumns = oTableDis.getColumns();
                var sPreviousTokenKey = "";
                var aTokens = this._oMultiInput.getTokens();
                if (aTokens.length > 0) {

                    sPreviousTokenKey = aTokens[0].getKey();

                }
                this._oMultiInput.removeAllTokens();
                const aCells = oSelectedItem.getCells();
                const sKey = aCells[0].getText();
                const sText = aCells[1].getText();

                const oToken = new sap.m.Token({ key: sKey, text: sText });
                this._oMultiInput.addToken(oToken);

                 var sProductSelection = this.getView().getModel("PlanHeader").getData().ProductSelection;

                const sFieldType = this._oMultiInput.data("valuehelp");
                if (sProductSelection === "MATNR" || sProductSelection === "BRAND" || sProductSelection === "SBRAN") {

                    var fieldMaps = {
    MATNR: "Matnr",
    BRAND: "Brand",
    SBRAN: "Subbrand"
};

var sMatchField = fieldMaps[sProductSelection] || "";

var labelMap = {
    MATNR: "Selling SKU",
    BRAND: "Brand",
    SBRAN: "Sub Brand"
};

var sLabelText = labelMap[sProductSelection] || "";

                   // var sMatchField = sFieldType === "SellingSKU" ? "Matnr" : "Brand";

                    //var sLabelText = sMatchField === "Matnr" ? "Selling SKU" : "Brand";
                   

                    var oLineItem = this._oMultiInput.getParent().getBindingContext("PlanHeader").getObject();

                    for (var i = 0; i < 3 && i < aColumns.length; i++) {
                        var col = aColumns[i];
                        var label = col.getLabel();
                        
                        if (label && label.getText && label.getText() === sLabelText) {
                            col.setVisible(true);
                        } else if(sProductSelection==="SBRAN"&&label && label.getText && label.getText()==="Brand" ){
                            col.setVisible(true);


                        } else {
                            col.setVisible(false);
                        }
                    }

                    for (var i = 0; i < 3 && i < aDisColumns.length; i++) {
                        var col = aDisColumns[i];
                        var label = col.getLabel();
                        if (label && label.getText && label.getText() === sLabelText) {
                            col.setVisible(true);
                        } else if(sProductSelection==="SBRAN"&&label && label.getText && label.getText()==="Brand" ){
                            col.setVisible(true);


                        } else {
                            col.setVisible(false);
                        }
                    }


                    // if (sPreviousTokenKey) {


                    //     var oModel = this.getView().getModel("VolumeModel");
                    //     var aVolumeData = oModel.getData();

                    //     // Filter out entries where sFieldType matches the removed key
                    //     var aUpdatedData = aVolumeData.filter(function (item) {
                    //         return item[sMatchField] !== sPreviousTokenKey;
                    //     });

                    //     // Update the model
                    //     oModel.setData(aUpdatedData);
                    // }
                    if (sFieldType !== "SubBrand") {

                        if ((sProductSelection === "SBRAN" && oLineItem.Subbrand && sFieldType === "Brand") || (sFieldType === "Brand" && sProductSelection === "BRAND") || sFieldType === "SellingSKU") {
                            var sItemNo = this._oMultiInput.getParent().getBindingContext("PlanHeader").getObject().ItemNo;
                            this._getVolumeData(this, sMatchField, sKey, sItemNo, oLineItem.Subbrand);
                        }
                    }


                    else {
                        if ((sProductSelection === "SBRAN" && oLineItem.Brand && sFieldType === "SubBrand")) {
                            var sItemNo = this._oMultiInput.getParent().getBindingContext("PlanHeader").getObject().ItemNo;
                            this._getVolumeData(this, sMatchField, oLineItem.Brand, sItemNo, sKey);
                        }

                    }


                }


                const sPath = this._oMultiInput.getBindingContext("PlanHeader").getPath();

                //  const oRowObject = this._oMultiInput.getBindingContext("PlanHeader").getObject();


                const fieldMap = {
                    SellingSKU: { field: "Matnr" },
                    SubBrand: { field: "Subbrand" },
                    Brand: { field: "Brand" },
                    SpendType1: { field: "SpendType1", methodField: "SpendMethod1" },
                    SpendType2: { field: "SpendType2", methodField: "SpendMethod2" },
                    SpendType3: { field: "SpendType3", methodField: "SpendMethod3" },
                    SpendType4: { field: "SpendType4", methodField: "SpendMethod4" },
                    SpendType5: { field: "SpendType5", methodField: "SpendMethod5" }

                };

                const config = fieldMap[sFieldType];
                if (config) {
                    // if (config.field === "Matnr" || config.field === "Brand") {

                    //     var aFilters = [
                    //         new sap.ui.model.Filter(config.field, sap.ui.model.FilterOperator.EQ, sKey)
                    //     ];

                    //     this.getOwnerComponent().getModel().read("/Plan_Item_OISet", { // Path to a specific entity
                    //         filters: aFilters,
                    //         urlParameters: {
                    //             "$expand": "To_Volume"// Multiple navigation properties can be expanded, separated by commas
                    //         },
                    //         success: function (oData, oResponse) {

                    //             console.log(oData);

                    //         },
                    //         error: function (oError) {
                    //             // Handle error
                    //             console.log(oError);
                    //         }
                    //     });

                    // }
                    if (config.field === "Matnr" || config.field === "Brand" || config.field === "Subbrand") {
                        this.getView().getModel("PlanHeader").setProperty(`${sPath}/${config.field}Desc`, sText);
                    }
                    this.getView().getModel("PlanHeader").setProperty(`${sPath}/${config.field}`, sKey);
                    if (config.methodField) {
                        const oPromoPlanContext = oSelectedItem.getBindingContext("PromoPlan");
                        if (oPromoPlanContext) {

                            this.getView().getModel("PlanHeader").setProperty(`${sPath}/${config.methodField}`, oPromoPlanContext.getObject().SpendMethod);
                        }
                    }
                }


            }
        },
        _getVolumeData: function (that, sFieldType, value, ItemNo, subbrand) {
            return new Promise((resolve, reject) => {
                that.getView().setBusy(true);

                const oPlanHeaderData = that.getView().getModel("PlanHeader");
                var sVtweg = oPlanHeaderData.getProperty("/Vtweg");
                var sVkorg = oPlanHeaderData.getProperty("/Vkorg");
                var sPlanCustomer = oPlanHeaderData.getProperty("/PlanCustomer");
                var sProductSelection = oPlanHeaderData.getProperty("/ProductSelection");

                var sBuyingDateF = formatter._getDateTimeInstance(oPlanHeaderData.getProperty("/BuyingDateF"));
                var sBuyingDateT = formatter._getDateTimeInstance(oPlanHeaderData.getProperty("/BuyingDateT"));


                var aFilters = [
                  
                    new sap.ui.model.Filter("Vtweg", sap.ui.model.FilterOperator.EQ, sVtweg),
                    new sap.ui.model.Filter("Vkorg", sap.ui.model.FilterOperator.EQ, sVkorg),
                    new sap.ui.model.Filter("PlanCustomer", sap.ui.model.FilterOperator.EQ, sPlanCustomer),
                    new sap.ui.model.Filter("BuyingDateF", sap.ui.model.FilterOperator.EQ, sBuyingDateF),
                    new sap.ui.model.Filter("BuyingDateT", sap.ui.model.FilterOperator.EQ, sBuyingDateT),
                    new sap.ui.model.Filter("ProductSelection", sap.ui.model.FilterOperator.EQ, sProductSelection)


                ];
                if (sProductSelection === "SBRAN") {
                    aFilters.push(new sap.ui.model.Filter("Subbrand", sap.ui.model.FilterOperator.EQ, subbrand));
                     aFilters.push(new sap.ui.model.Filter("Brand", sap.ui.model.FilterOperator.EQ, value));
                }

                else{
                      aFilters.push(new sap.ui.model.Filter(sFieldType, sap.ui.model.FilterOperator.EQ, value));
                }

                var oVolumeModel = that.getView().getModel("VolumeModel");
                const aCalendarData = that.getView().getModel("appView").getProperty("/CalendarData");

                // Get visible week keys like WeekVol1, WeekVol2, etc.
                const aVisibleWeekKeys = [...new Set(aCalendarData.map(d => "WeekVol" + parseInt(d.ScreenCol)))];

                var aVolumeModelData = oVolumeModel.getData();
                //var sUrl = "/Plan_ProductsSet?$expand=To_Product_Volume&$filter=" + sFieldType + " eq '" + value + "' and Vtweg eq '" + sVtweg + "' and Vkorg eq '" + sVkorg + "' and PlanCustomer eq '" + sPlanCustomer + "' and BuyingDateF eq datetime'" + sBuyingDateF + "' and BuyingDateT eq datetime'" + sBuyingDateT + "'";


                that.getOwnerComponent().getModel().read("/Plan_ProductsSet", { // Path to a specific entity
                    filters: aFilters,
                    urlParameters: {
                        "$expand": "To_Product_Volume"
                    },


                    success: function (oData, oResponse) {

                        that.getView().setBusy(false);
                        if (oData.results.length > 0) {

                            var productVolumes = oData.results[0].To_Product_Volume.results;
                            let baselineTotal = 0;
                            let upliftTotal = 0;
                            let plannedTotal = 0;
                            for (var i = 0; i < productVolumes.length; i++) {

                                productVolumes[i].ItemNo = ItemNo;
                                var total = 0;
                                aVisibleWeekKeys.forEach(weekKey => {

                                    const val = parseInt(productVolumes[i][weekKey], 10) || 0;
                                    productVolumes[i][weekKey] = val;
                                    total += val;
                                    if (productVolumes[i].VolType === "B") {
                                        baselineTotal += val;
                                    } else if (productVolumes[i].VolType === "U") {
                                        upliftTotal += val;
                                    } else if (productVolumes[i].VolType === "P") {
                                        plannedTotal += val;
                                    }
                                });

                                productVolumes[i].Total = total;


                            }

                            productVolumes.forEach(newItem => {

                                const index = aVolumeModelData.findIndex(item =>
                                    item.ItemNo === newItem.ItemNo &&
                                    item.VolType === newItem.VolType
                                );

                                if (index !== -1) {
                                    // 🔹 Replace entire object
                                    aVolumeModelData[index] = newItem;
                                } else {
                                    // 🔹 Add new
                                    aVolumeModelData.push(newItem);
                                }
                            });

                            // 🔹 Update model
                            oVolumeModel.setData(aVolumeModelData);

                            //var aMergedData = aVolumeModelData.concat(productVolumes);
                            // oVolumeModel.setData(aMergedData);
                            // Update PlanHeader model
                            const oPlanHeaderModel = that.getView().getModel("PlanHeader");
                            const aPlanItems = oPlanHeaderModel.getProperty("/To_Item/results");
                            const normalizeValue = function (num) {
                                let value = parseFloat(num); // Convert to number
                                if (value === 0) return 0;   // If zero, return 0
                                return parseFloat(value.toString()); // Remove trailing zeros
                            }
                            aPlanItems.forEach(row => {
                                if (row.ItemNo === ItemNo) {
                                    if (sFieldType === "Matnr") {


                                        row.Tax = normalizeValue(oData.results[0].Tax);
                                        row.NetCost = normalizeValue(oData.results[0].NetCost);

                                    }

                                    row.Ppc = normalizeValue(oData.results[0].Ppc);
                                    row.Uom = oData.results[0].Uom;
                                    row.ListPrice = normalizeValue(oData.results[0].ListPrice);
                                    row.RetailPrice = normalizeValue(oData.results[0].RetailPrice);
                                    row.RegularPrice = normalizeValue(oData.results[0].RegularPrice);
                                    row.LogisticOiCost = normalizeValue(oData.results[0].LogisticOiCost);
                                    row.OtherOiCost = normalizeValue(oData.results[0].OtherOiCost);
                                    row.FinancialOiCost = normalizeValue(oData.results[0].FinancialOiCost);
                                    row.FinancialDefCost = normalizeValue(oData.results[0].FinancialDefCost);
                                    row.LogisticDefCost = normalizeValue(oData.results[0].LogisticDefCost);
                                    row.OtherDefCost = normalizeValue(oData.results[0].OtherDefCost);
                                    row.Cogs = normalizeValue(oData.results[0].Cogs);
                                    row.Dcost = normalizeValue(oData.results[0].Dcost);



                                    row.Baseline = normalizeValue(baselineTotal);
                                    row.Uplift = normalizeValue(upliftTotal);
                                    row.VolumePlanned = normalizeValue(plannedTotal);

                                    that._splitVolumeAcrossWeeks("B", row.ItemNo, row.Baseline);
                                    that._splitVolumeAcrossWeeks("U", row.ItemNo, row.Uplift);
                                    that._splitVolumeAcrossWeeks("P", row.ItemNo, row.VolumePlanned);
                                }
                            });

                            oPlanHeaderModel.setProperty("/To_Item/results", aPlanItems);
                            oPlanHeaderModel.refresh(true);
                            that.getView().getController().updateSummaryRow();
                        }
                        resolve();

                    },
                    error: function (oError) {
                        that.getView().setBusy(false);
                        // Handle error
                        console.log(oError);
                        reject(oError);
                    }
                });

            });

        },
        onOIVHTokenUpdate: function (oEvent, that) {
            const oMultiInput = oEvent.getSource();
            //const oContext = oMultiInput.getBindingContext("PromoPlan");
            const sFieldType = oMultiInput.data("valuehelp");
            const sType = oEvent.getParameter("type");
            const sPath = oMultiInput.getBindingContext("PlanHeader").getPath();
            const fieldMap = {
                SellingSKU: { field: "Matnr" },
                SubBrand: { field: "Subbrand" },
                Brand: { field: "Brand" },
                SpendType1: { field: "SpendType1", methodField: "SpendMethod1" },
                SpendType2: { field: "SpendType2", methodField: "SpendMethod2" },
                SpendType3: { field: "SpendType3", methodField: "SpendMethod3" },
                SpendType4: { field: "SpendType4", methodField: "SpendMethod4" },
                SpendType5: { field: "SpendType5", methodField: "SpendMethod5" }

            };
            const config = fieldMap[sFieldType];
            var oTable = that.getView().byId("idVolumePerWeek");
            var aColumns = oTable.getColumns();

            var oTableDis = that.getView().byId("idVolumePerWeekDisplay");

            var aDisColumns = oTableDis.getColumns();

            if (sType === "removed") {

                if (sFieldType === "SellingSKU" || sFieldType === "Brand" || sFieldType === "SubBrand") {

                    var sMatchField = "";

                    if (sFieldType === "SubBrand") {
                        sMatchField = "Subbrand";
                    }
                    else {
                        sMatchField = sFieldType === "SellingSKU" ? "Matnr" : "Brand";
                    }


                    // First three columns assumed to be Brand, Selling SKU, Prodh
                    for (var i = 0; i < 4; i++) {
                        if (aColumns[i]) {
                            aColumns[i].setVisible(false);
                        }
                    }

                    // First three columns assumed to be Brand, Selling SKU, Prodh
                    for (var i = 0; i < 4; i++) {
                        if (aDisColumns[i]) {
                            aDisColumns[i].setVisible(false);
                        }
                    }
                    var sRemovedKey = oEvent.getParameter("removedTokens")[0].getKey();
                    var oModel = that.getView().getModel("VolumeModel");
                    var aVolumeData = oModel.getData();

                    // Filter out entries where sFieldType matches the removed key
                    var aUpdatedData = aVolumeData.filter(function (item) {
                        return item[sMatchField] !== sRemovedKey;
                    });

                    // Update the model
                    oModel.setData(aUpdatedData);
                }


                that.getView().getModel("PlanHeader").setProperty(`${sPath}/${config.field}`, "");
                if (config.methodField) {

                    that.getView().getModel("PlanHeader").setProperty(`${sPath}/${config.methodField}`, "");

                }

            }
            else if (sType === "added") {
                if (config.field === "Matnr" || config.field === "Brand" || config.field === "Subbrand") {




                    var sField = config.field;
                    var sLabelText = "";
                    if (sField === "Subbrand") {
                        sLabelText = "Sub Brand";
                    }
                    else {
                        sLabelText = sField === "Matnr" ? "Material" : "Brand";
                    }

                    for (var i = 0; i < 3 && i < aColumns.length; i++) {
                        var col = aColumns[i];
                        var label = col.getLabel();
                        if (label && label.getText && label.getText() === sLabelText) {
                            col.setVisible(true);
                        } else {
                            col.setVisible(false);
                        }
                    }

                    for (var i = 0; i < 3 && i < aDisColumns.length; i++) {
                        var col = aDisColumns[i];
                        var label = col.getLabel();
                        if (label && label.getText && label.getText() === sLabelText) {
                            col.setVisible(true);
                        } else {
                            col.setVisible(false);
                        }
                    }




                    var sItemNo = that.getView().getModel("PlanHeader").getProperty(`${sPath}`).ItemNo


                    this._getVolumeData(that, config.field, oMultiInput.getTokens()[0].getKey(), sItemNo, "");
                }

                const aSuggestionItems = oMultiInput.getSuggestionItems();
                const oSelectedItem = aSuggestionItems.find(item => item.getKey() === oMultiInput.getTokens()[0].getKey());


                that.getView().getModel("PlanHeader").setProperty(`${sPath}/${config.field}`, oMultiInput.getTokens()[0].getKey());
                if (config.methodField) {

                    that.getView().getModel("PlanHeader").setProperty(`${sPath}/${config.methodField}`, oSelectedItem.getBindingContext("PromoPlan").getObject().SpendMethod);

                }

            }


        },

        handleOIVHSearch: function (oEvent) {

            var oBinding = oEvent.getSource().getBinding("items");
            var sValue = oEvent.getParameter("value").toUpperCase();
            var sFieldType = this._oMultiInput.getCustomData()[0].getValue();

            var aFilter = [];
            if (sFieldType === "SellingSKU") {
                oBinding.filter([]);
                aFilter.push(new Filter({
                    filters: [
                        new Filter("Matnr", FilterOperator.Contains, sValue),
                        new Filter("matnr_desc", FilterOperator.Contains, sValue)
                    ],
                    and: false   // OR condition
                }));
                //aFilter.push(new Filter("Matnr", FilterOperator.Contains, sValue));
                //aFilter.push(new Filter("matnr_desc", FilterOperator.Contains, sValue));

            }

            if (sFieldType === "Brand") {

 
               
    aFilter.push(new Filter("Domvalue", FilterOperator.Contains, sValue));
                aFilter.push(new Filter("Description", FilterOperator.Contains, sValue));
            }

            if (sFieldType === "SubBrand") {
  

               aFilter.push(new Filter("Subrand", FilterOperator.Contains, sValue));
                aFilter.push(new Filter("Subdesc", FilterOperator.Contains, sValue));


            }





            oBinding.filter(aFilter);



        }










    };
});