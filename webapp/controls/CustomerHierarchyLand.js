sap.ui.define([
  "sap/m/MultiInput",
  "sap/ui/model/odata/v2/ODataModel",
  "sap/ui/table/TreeTable",
  "sap/m/Dialog",
  "sap/m/Button",
  "sap/m/MessageToast"
], function (MultiInput, ODataModel, TreeTable, Dialog, Button, MessageToast) {
  "use strict";

  return MultiInput.extend("com.kcc.promoplan.controls.CustomerHierarchy", {
    metadata: {
      renderer: {},
      properties: {
        valueHelpEnabled: { type: "boolean", defaultValue: true },
        serviceUrl: { type: "string" },
         

         flag: {
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
     

    setFlag: function (sValue) {
      this.setProperty("flag", sValue, true);
      return this;
    },

    getFlag: function () {
      return this.getProperty("flag");
    },

    _onValueHelpRequest: function (oEvent) {
      var that = this;
      var oMultiInput = oEvent.getSource();

 

      // All fields are present
      oMultiInput.setValueState(sap.ui.core.ValueState.None);
      oMultiInput.setValueStateText("");




      const oTreeTable = new TreeTable({
        selectionMode: "Single",
        columns: [

          new sap.ui.table.Column({
            label: new sap.m.Label({ text: "Customer" }),
            template: new sap.m.Text({ text: "{Kunnr}" })
          }),
          new sap.ui.table.Column({
            label: new sap.m.Label({ text: "Name" }),
            template: new sap.m.Text({ text: "{NameOrg1}" })
          })

        ],


        rows: { path: '/nodes/', parameters: { arrayNames: ['customers'] } }


      });

      const oJsonModel = new sap.ui.model.json.JSONModel();
 
      let aFilters = [];

     
      
        aFilters.push(new sap.ui.model.Filter("Hier_flg", "EQ", this.getFlag()));
 

      this.oODataModel = new ODataModel("/sap/opu/odata/sap/ZPRTP4_CUST_HIERARCHY_F4_SRV/");
      var transformedData = [];
      // Fetch and transform data
      this.oODataModel.read("/Cust_hierarchy_F4Set", {
        filters: aFilters,
        success: function (oData) {

          // Step 1: Create a lookup map
          const lookup = {};
          oData.results.forEach(item => {
            lookup[item.Kunnr] = { ...item, customers: [] };
          });
          // oTreeTable.setModel(oModel);

          const oDialog = new Dialog({
            title: "Select Customer",
            contentWidth: "50%",
            content: [oTreeTable],
            beginButton: new Button({
              text: "OK",
              press: () => {
                const selectedContext = oTreeTable.getSelectedIndex();
                if (selectedContext !== -1) {
                  const selectedData = oTreeTable.getContextByIndex(selectedContext).getObject();

                  if (!selectedData || Object.keys(selectedData).length === 0) {
                    sap.m.MessageToast.show("Please select a customer");
                    return;
                  }

                  oMultiInput.setValue(selectedData.Kunnr);
                  that.fireValueSelected({ selectedItem: selectedData });
                  oDialog.close();
                }
                else {
                  sap.m.MessageToast.show("Please select a customer");
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
            if (item.Hkunnr) {
              const parent = lookup[item.Hkunnr];
              if (parent) {
                parent.customers.push(lookup[item.Kunnr]);
              }
            } else {
              nestedData.push(lookup[item.Kunnr]);

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
