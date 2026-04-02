sap.ui.define([
  "sap/m/MultiInput",
  "sap/ui/model/odata/v2/ODataModel",
  "sap/ui/table/TreeTable",
  "sap/m/Dialog",
  "sap/m/Button",
  "sap/m/MessageToast"
], function (MultiInput, ODataModel, TreeTable, Dialog, Button, MessageToast) {
  "use strict";

  return MultiInput.extend("com.kcc.promoplan.controls.ProductHierarchy", {
    metadata: {
      renderer: {},
      properties: {
        valueHelpEnabled: { type: "boolean", defaultValue: true },
        serviceUrl: { type: "string" },
        
        saId: {
          type: "string",
          defaultValue: ""
        }
      },
      events: {
        valueSelected: {
          parameters: {
            selectedItem: { type: "object" }
          }
        }
      }
    },

    init: function () {
      MultiInput.prototype.init.call(this);
      this.attachValueHelpRequest(this._onValueHelpRequest.bind(this));
    },
    renderer: function (oRm, oInput) {
      sap.m.MultiInputRenderer.render(oRm, oInput);

    },
     
 
    setSaId: function (sValue) {
      this.setProperty("saId", sValue, true);
      return this;
    },

    getSaId: function () {
      return this.getProperty("saId");
    },

    _onValueHelpRequest: function (oEvent) {
      var that = this;
      var oMultiInput = oEvent.getSource();


      

 




      const oTreeTable = new TreeTable({
        selectionMode: "Single",
        columns: [

          new sap.ui.table.Column({
            label: new sap.m.Label({ text: "Product" }),
            template: new sap.m.Text({ text: "{Prodh}" })
          }),
          new sap.ui.table.Column({
            label: new sap.m.Label({ text: "Description" }),
            template: new sap.m.Text({ text: "{Vtext}" })
          })

        ],


        rows: { path: '/nodes/', parameters: { arrayNames: ['prodcuts'] } }


      });

      const oJsonModel = new sap.ui.model.json.JSONModel();

 

      let aFilters = [];

      if (oMultiInput.getProperty("saId")) {
        aFilters.push(new sap.ui.model.Filter("SaId", "EQ", oMultiInput.getProperty("saId")));
      }

      this.oODataModel = new ODataModel("/sap/opu/odata/sap/ZPRTP4_PROD_HIERARCHY_F4_SRV/");
       // Fetch and transform data
      this.oODataModel.read("/ProdHierSet", {
        filters: aFilters,
        success: function (oData) {

          // Step 1: Create a lookup map
          const lookup = {};
          oData.results.forEach(item => {
            lookup[item.Prodh] = { ...item, prodcuts: [] };
          });
          // oTreeTable.setModel(oModel);

          const oDialog = new Dialog({
            title: "Select Product",
            contentWidth: "50%",
            content: [oTreeTable],
            beginButton: new Button({
              text: "OK",
              press: () => {
                const selectedContext = oTreeTable.getSelectedIndex();
                if (selectedContext !== -1) {
                  const selectedData = oTreeTable.getContextByIndex(selectedContext).getObject();

                  if (!selectedData || Object.keys(selectedData).length === 0) {
                    sap.m.MessageToast.show("Please select a product");
                    return;
                  }
                  oMultiInput.setValue(selectedData.Prodh);

                selectedData.ItemNo= oEvent.getSource().getBindingContext("PlanHeader").getObject().ItemNo;

                  that.fireValueSelected({ selectedItem: selectedData });
                  oDialog.close();
                }
                else {
                  sap.m.MessageToast.show("Please select a Product");
                }
              }
            }),
            endButton: new Button({
              text: "Cancel",
              press: () => oDialog.close()
            })
          });

          // Step 2: Build the nested structure
          const nestedData = [];
          oData.results.forEach(item => {
            if (item.ProdhPrev) {
              const parent = lookup[item.ProdhPrev];
              if (parent) {
                parent.prodcuts.push(lookup[item.Prodh]);
              }
            } else {
              nestedData.push(lookup[item.Prodh]);

            }
          });

          // Step 3: Wrap in catalog structure for TreeTable binding
          const catalogModelData = {
            nodes: nestedData
          };

          oJsonModel.setData(catalogModelData); // transformedData from OData response
          oTreeTable.setModel(oJsonModel);
          oDialog.open();

        },
        error: function () {
          MessageToast.show("Failed to load hierarchy data.");
        }
      });





    }
  });
});
