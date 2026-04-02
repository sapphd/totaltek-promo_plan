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

        formatDateToBackend: function (oDate) {
            return oDate ? oDate.toISOString().split("T")[0] + "T00:00:00" : null;
        },

        _vhConfigurations: function (sFieldType) {


            const configMap = {
                Brand: {
                    setPath: "/BrandSet",
                    keyField: "Domname",
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
                    textField: "Matnr",
                    
                    i18n: {
                        title: "sellingSKUTitle",
                        noData: "sellingSKUNoDataText",
                        placeholder: "sellingSKUSrchPlaceHolder",
                        column1: "Material",
                        column2: "Material"
                    }
                },
                  Spend: {
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
                }
            };

            return configMap[sFieldType];


        },


        onOIValueHelpRequest: function (oEvent, that) {

            that._oMultiInput = oEvent.getSource();
            that._oRowContext = that._oMultiInput.getBindingContext("PromoPlan");

            const sFieldType = that._oMultiInput.data("valuehelp");


            const config = this._vhConfigurations(sFieldType);
            this._sTargetProperty = config.targetProperty;
            this._sKeyField = config.keyField;
            this._sTextField = config.textField;
            this.onValueHelpRequest(config,that);

        },


        onValueHelpRequest: function (config,that) {

            if (!that._oVHDialog) {
                that._oVHDialog = new sap.m.TableSelectDialog("valueHelpDialog", {
                    contentWidth: "30%",
                    multiSelect: false,
                    showClearButton: true,
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

            const oItemTemplate = new sap.m.ColumnListItem({
                cells: [
                    new sap.m.Text({ text: "{PromoPlan>" + config.keyField + "}" }),
                    new sap.m.Text({ text: "{PromoPlan>" + config.textField + "}" })
                ]
            });

            that._oVHDialog.bindAggregation("items", {
                path: "PromoPlan>" + config.setPath,
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
                const aCells = oSelectedItem.getCells();
                const sKey = aCells[0].getText();
                const sText = aCells[1].getText();

                const oToken = new sap.m.Token({ key: sKey, text: sKey });
                this._oMultiInput.addToken(oToken);

              //  const aTokens = this._oMultiInput.getTokens().map(token => ({
                   // [this._sKeyField]: token.getKey(),
                   // [this._sTextField]: token.getKey()
                    //[this._sTextField]: token.getText()
              //  }));

                //this.getView().getModel("PromoPlan").setProperty(this._oRowContext.getPath() + "/" + this._sTargetProperty, aTokens);
            }
        },

        onOIVHTokenUpdate: function (oEvent) {
            const oMultiInput = oEvent.getSource();
            const oContext = oMultiInput.getBindingContext("PromoPlan");
            const sFieldType = oMultiInput.data("valuehelp");

            const configMap = {
                Brand: { keyField: "Domvalue", textField: "Description", targetProperty: "SelectedBrands" },
                SubBrand: { keyField: "subbrand", textField: "Description", targetProperty: "SelectedSubBrands" },
                SalesArea: { keyField: "salesid", textField: "salesarea", targetProperty: "SelectedSalesAreas" }
            };

            const config = configMap[sFieldType];

            const aTokens = oMultiInput.getTokens().map(token => ({
                [config.keyField]: token.getKey(),
                [config.textField]: token.getText()
            }));

            this.getView().getModel("PromoPlan").setProperty(oContext.getPath() + "/" + config.targetProperty, aTokens);
        },



        

        handleOIVHSearch: function (oEvent) {
              var sValue = oEvent.getParameter("value");
            var sFieldType = this._oMultiInput.getCustomData()[0].getValue();

            var aFilter = [];
            if (sFieldType = "SellingSKU") {
                aFilter.push(new Filter("Matnr", FilterOperator.Contains, sValue));

            }

            if (sFieldType = "Brand") {
                aFilter.push(new Filter("Domvalue", FilterOperator.Contains, sValue));

            }



            var oBinding = oEvent.getSource().getBinding("items");
            oBinding.filter([oFilter]);

        }





    };
});