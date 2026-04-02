/************************************************************************
 *-----------------------------------------------------------------------
 * Project               : Promo Plan
 * Process               : TPM
 * Task Code             : 
 * Functional Document   : 
 * Technical Document    :
 *  ---------------------------------------------------------------------
 * File       : controller/PromoPlan.js
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
	'sap/ui/comp/library',
	'sap/ui/model/type/String',
	'sap/m/ColumnListItem',
	'sap/m/Label',
	'sap/m/SearchField',
	'sap/m/Token',
	'sap/ui/model/Filter',
	'sap/ui/model/FilterOperator',
	'sap/ui/model/odata/v2/ODataModel',
	'sap/ui/table/Column',
	'sap/m/Column',
	'sap/m/Text',
	"sap/ui/core/Fragment",
	"com/kcc/promoplan/utils/FragmentHelper",
	"com/kcc/promoplan/utils/Validate",
	"com/kcc/promoplan/utils/CreateHelper",
	"com/kcc/promoplan/utils/ItemOIHelper",
	"com/kcc/promoplan/model/formatter",
	"sap/m/Input",
	"com/kcc/promoplan/utils/SummaryRow",
	'sap/viz/ui5/format/ChartFormatter',
	'sap/viz/ui5/api/env/Format'

], (BaseController, JSONModel, MessageToast, MessageBox, compLibrary,
	TypeString, ColumnListItem, Label, SearchField, Token, Filter,
	FilterOperator, ODataModel, UIColumn, MColumn, Text, Fragment,
	FragmentHelper, Validate, Helper, ItemOIHelper, formatter, Input, SummaryRow, ChartFormatter, Format) => {
	"use strict";

	return BaseController.extend("com.kcc.promoplan.controller.PromoPlan", {
		_oCommentsModel: {},
		onInit() {
			Format.numericFormatter(ChartFormatter.getInstance());
			var formatPattern = ChartFormatter.DefaultPattern;



			var oVizFrame = this.getView().byId("idVizFrame");
			oVizFrame.setVizProperties({
				plotArea: {
					dataLabel: {
						formatString: formatPattern.SHORTFLOAT_MFD2,
						visible: true
					},
					dataShape: {
						primaryAxis: ["line", "bar", "bar"]
					},
					colorPalette: [
						"#e9730c",    // ROI - Orange
						"#7cc4ff",   // Uplift - Light Blue
						"#0a6ed1"   // Baseline - Blue

					]
				},
				valueAxis: {
					label: {
						formatString: formatPattern.SHORTFLOAT
					},
					title: {
						visible: true
					}
				},
				categoryAxis: {
					title: {
						visible: true
					}
				},
				title: {
					text: "Weekly Revenue vs Cost",
					visible: true
				}
			});

			var oPopOver = this.getView().byId("idPopOver");
			oPopOver.connect(oVizFrame.getVizUid());
			oPopOver.setFormatString(formatPattern.STANDARDFLOAT);


			this._oCommentsModel = this.getOwnerComponent().getModel("Comments");









			// Initialize spend column set count
			this._iSpendOIColumnSetCount = 1;

			// Cache PromoPlan model
			this.oPromoPlanModel = this.getOwnerComponent().getModel("PromoPlan");

			// Attach route handlers
			const oRouter = this.getRouter();
			oRouter.getRoute("PromoPlanDetail").attachPatternMatched(this._onEditRouteMatched, this);
			oRouter.getRoute("PromoPlanCreate").attachPatternMatched(this._onCreateRouteMatched, this);

			var oChangeLogTable = this.getView().byId("changeDocumentsTable");
			oChangeLogTable.setModel(
				this.getOwnerComponent().getModel("ChangeDocuments")
			);

			// Setup volume table columns
			this._volumeTableFixedColumns();
			this.readDishChannel();
			this.readSalesArea();


		},

		loadChangeDocuments: function (sBusinessObjectInstanceID) {
			var oChangeLogTable = this.byId("changeDocumentsTable");
			oChangeLogTable.rebindTable();
		},


		onBeforeChangeDocRebindTable: function (oEvent) {
			var oBindingParams = oEvent.getParameter("bindingParams");
			var aFilters = [];
			aFilters.push();
			oBindingParams.filters.push(new Filter("ChangeDocObjectClass", FilterOperator.EQ, 'ZCOTP4_PROMOPLA'));
			var PromoPlanID = this.getOwnerComponent().getRouter().oHashChanger.hash.split('/')[1].padStart(10, "0");
			oBindingParams.filters.push(new Filter("ChangeDocObject", FilterOperator.EQ, PromoPlanID));

		},

		onPostComments: function (oEvent) {

			var sText = oEvent.getParameter("value") || oEvent.getParameter("text"); // UI5 versions differ
			if (!sText || !sText.trim()) {
				MessageToast.show("Please enter a comment.");
				return;
			}

			const oPlanHeader = this.getView().getModel("PlanHeader").getData();

			this._oCommentsModel.callFunction("/PostComment", {
				method: "POST",
				urlParameters: {
					BusinessObjectInstanceID: oPlanHeader.PlanId,
					TextObject: 'ZTP4PROMO',
					CommentText: sText
				},
				success: function (oData, oResponse) {
					var msg = 'Comments posted successfully';
					MessageToast.show(msg);
					var oFeedList = this.byId("idCommentsList");
					oFeedList.getBinding("items").refresh();
				}.bind(this),
				error: function (oError) {

				}

			})
		},

		loadComments: function (sBusinessObjectInstanceID) {


			var aFilters = [];
			aFilters.push(new Filter("TextObject", FilterOperator.EQ, 'ZTP4PROMO'));
			if (sBusinessObjectInstanceID !== undefined && sBusinessObjectInstanceID !== '') {
				aFilters.push(new Filter("BusinessObjectInstanceID", FilterOperator.EQ, sBusinessObjectInstanceID));
			}
			else {
				aFilters.push(new Filter("BusinessObjectInstanceID", FilterOperator.EQ, this.getOwnerComponent().getRouter().oHashChanger.hash.split('/')[1]));
			}

			var oFeedList = this.byId("idCommentsList");
			var oBindingFeedList = oFeedList.getBinding("items");
			oBindingFeedList.filter(aFilters);
		},
		onContractIDChange: function (oEvent) {

			const oInput = oEvent.getSource();
			const value = (oInput.getValue() || "").trim();

			// Validate length: allow empty (0) up to 10
			const isValid = value.length <= 50;

			if (!isValid) {
				oInput.setValueState(sap.ui.core.ValueState.Error);
				oInput.setValueStateText("Contract ID must be at most 50 characters.");
			} else {
				oInput.setValueState(sap.ui.core.ValueState.None);
				oInput.setValueStateText("");
			}

		},
		_insertSummaryRow: function (aItems) {
			//var totalSpend = aItems.reduce((sum, item) => sum + parseFloat(item.SpendPlanned || 0), 0);
			aItems.unshift({
				"PlanId": "",
				"IsSummary": true,
				"ItemNo": "000000",
				"RecordType": "",
				"Prodh": "",
				"Matnr": "",
				"Brand": "",
				"Subbrand": "",
				"Tactic1": "",
				"Tactic2": "",
				"Tactic3": "",
				"Tactic4": "",
				"Tactic5": "",
				"TacticDesc1": "",
				"TacticDesc2": "",
				"TacticDesc3": "",
				"TacticDesc4": "",
				"TacticDesc5": "",
				"SpendAlloc1": "",
				"SpendAlloc2": "",
				"SpendAlloc3": "",
				"SpendAlloc4": "",
				"SpendAlloc5": "",
				"SpendTypeClass1": "",
				"SpendTypeClass2": "",
				"SpendTypeClass3": "",
				"SpendTypeClass4": "",
				"SpendTypeClass5": "",
				"VolumePlanned": "0",
				"Uplift": "0",
				"Baseline": "0",
				"DiscountEdlp": "0",
				"SpendMethod1": "",
				"DiscountAmt1": "0",
				"Discount1": "0",
				"SpendType1": "",
				"SpendType1Desc": "",
				"SpendMethod2": "",
				"DiscountAmt2": "0",
				"Discount2": "0",
				"SpendType2": "",
				"SpendType2Desc": "",
				"SpendMethod3": "",
				"DiscountAmt3": "0",
				"Discount3": "0",
				"SpendType3": "",
				"SpendType3Desc": "",
				"SpendMethod4": "",
				"DiscountAmt4": "0",
				"Discount4": "0",
				"SpendType4": "",
				"SpendType4Desc": "",
				"SpendMethod5": "",
				"DiscountAmt5": "0",
				"Discount5": "0",
				"SpendType5": "",
				"SpendType5Desc": "",
				"ListPrice": "0",
				"RetailPrice": "0",
				"RegularPrice": "0",
				"Uom": "",
				"Ppc": "",
				"NetCost": "0",
				"Tax": "0",
				"Cogs": "0",
				"Trade": "0",
				"RetailMargin": "0",
				"RetailMarginPrc": "0",
				"Fund": "",
				"Waers": "",
				"CcmNum": "",
				"Knumh": "",
				"SpendPlanned": "0",
				"SalesPlanned": "0",
				"SpendPlannedOi": "0",
				"SpendPlannedBb": "0",
				"SpendPlannedLs": "0",
				"LogisticDefCost": "0",
				"FinancialOiCost": "0",
				"LogisticOiCost": "0",
				"FinancialDefCost": "0",
				"OtherOiCost": "0",
				"OtherDefCost": "0",
				"Dcost": "0"

			});
		},
		handleStateChange: function (oEvent) {
			alert("muthu")
		},
		_insertSummaryRowEdit: function (aItems) {
			//var totalSpend = aItems.reduce((sum, item) => sum + parseFloat(item.SpendPlanned || 0), 0);
			aItems[0].IsSummary = true;






			// Initialize SpendMethod, SpendType, DiscountAmt, Discount, Tactic fields
			for (let i = 1; i <= 5; i++) {
				aItems[0][`TacticDesc${i}`] = "";
				aItems[0][`SpendAlloc${i}`] = "";
			}

			return aItems;

		},
		onDiscountChange: function (oEvent) {
			const sValue = oEvent.getSource().getValue();
			const oPlanHeaderModel = this.getView().getModel("PlanHeader");
			const sPath = oEvent.getSource().getBinding("value").getPath();

			const aItems = oPlanHeaderModel.getProperty("/To_Item/results");

			// Extract the field name (e.g., Discount1, Discount2, etc.)
			const fieldMatch = sPath.match(/Discount(\d)/);
			if (!fieldMatch) return;

			const fieldName = "Discount" + fieldMatch[1];
			var sBindingPath = oEvent.getSource().getBindingContext("PlanHeader").getPath() + "/" + fieldName;

			// Check if the change is from the summary row (index 0)
			if (sBindingPath.includes("/To_Item/results/0/" + fieldName)) {
				// Copy value to all line items
				for (let i = 1; i < aItems.length; i++) {
					aItems[i][fieldName] = sValue;
				}
			} else {

				aItems[0][fieldName] = "0";

			}

			// Update the model
			oPlanHeaderModel.setProperty("/To_Item/results", aItems);
			this.updateSummaryRow();
		},

		onDiscountAmountChange: function (oEvent) {
			const sValue = parseFloat(oEvent.getSource().getValue()) || 0;
			const oPlanHeaderModel = this.getView().getModel("PlanHeader");
			const sPath = oEvent.getSource().getBinding("value").getPath();
			const aItems = oPlanHeaderModel.getProperty("/To_Item/results");
			const normalizeValue = function (num) {
				let value = parseFloat(num); // Convert to number
				if (value === 0) return 0;   // If zero, return 0
				return parseFloat(value.toString()); // Remove trailing zeros
			}



			// Match field name like DiscountAmt1 to DiscountAmt5
			const fieldMatch = sPath.match(/DiscountAmt(\d)/);
			if (!fieldMatch) return;

			const index = fieldMatch[1]; // 1 to 5
			const fieldName = "DiscountAmt" + index;
			const spendMethodField = "SpendMethod" + index;
			const spendAllocField = "SpendAlloc" + index;

			var sBindingPath = oEvent.getSource().getBindingContext("PlanHeader").getPath() + "/" + fieldName;

			const isSummaryRow = sBindingPath.includes("/To_Item/results/0/" + fieldName);

			if (isSummaryRow) {
				const summarySpendAlloc = aItems[0][spendAllocField];

				const totalSales = aItems[0].SalesPlanned || 0;
				const itemCount = aItems.length - 1; // Exclude summary row


				for (let i = 1; i < aItems.length; i++) {
					const itemSpendMethod = aItems[i][spendMethodField];

					if (itemSpendMethod === "$") {
						// Copy header amount to item
						aItems[i][fieldName] = normalizeValue(sValue.toFixed(2));
					} else if (itemSpendMethod === "F" && summarySpendAlloc === "S") {
						// Distribute based on sales proportion
						const proportion = totalSales ? (aItems[i].SalesPlanned || 0) / totalSales : 0;
						aItems[i][fieldName] = normalizeValue((sValue * proportion).toFixed(2));
					} else if (itemSpendMethod === "F" && summarySpendAlloc === "E") {
						// Distribute equally among items
						const equalShare = itemCount > 0 ? sValue / itemCount : 0;
						aItems[i][fieldName] = normalizeValue(equalShare.toFixed(2));
					} else {
						aItems[i][fieldName] = "";
					}

				}

			} else {
				const itemSpendMethod = aItems[0][spendMethodField];
				if (itemSpendMethod === "$") {
					aItems[0][fieldName] = 0;
				}
				else {

					let totalDiscount = 0;

					for (let i = 1; i < aItems.length; i++) { // Skip summary row
						const val = parseFloat(aItems[i][fieldName]) || 0;
						totalDiscount += val;
					}

					// Update summary row with total
					aItems[0][fieldName] = normalizeValue(totalDiscount.toFixed(2));
				}


			}

			// Update the model
			oPlanHeaderModel.setProperty("/To_Item/results", aItems);
			this.updateSummaryRow();
		},
		onCustomerFlagChange: function (oEvent) {


			const sSelectedIndex = oEvent.getParameter("selectedIndex");
			const aValues = ["E", "D"]; // Map indexes to values
			const sValue = aValues[sSelectedIndex] || ""; // Default to empty if index is out of range

			this.getView().getModel("appView").setProperty("/Flag", sValue);

		},

		updateSummaryRow: function () {
			SummaryRow.calculateSummaryRow(this);

		},

		_loadCalendarSet: async function (sFrom, sTo) {
			// Create a filter for the specific date
			return new Promise((resolve, reject) => {
				const oPlanHeaderData = this.getView().getModel("PlanHeader");
				const sVkorg = oPlanHeaderData.getProperty("/Vkorg");
				const sVtweg = oPlanHeaderData.getProperty("/Vtweg");

				// Create filters
				const aFilters = [
					new Filter("Vkorg", FilterOperator.EQ, sVkorg),
					new Filter("Vtweg", FilterOperator.EQ, sVtweg),
					new Filter("StartDay", FilterOperator.GE, sFrom),
					new Filter("StartDay", FilterOperator.LE, sTo)
				];

				const oCombinedDateFilter = new Filter(aFilters, true);
				const sUrl = "/Plan_CalendarSet";


				this.getOwnerComponent().getModel().read(sUrl, { // Path to a specific entity
					filters: [oCombinedDateFilter],
					success: function (oData) {
						this._toggleWeekColumnsVisibility(oData.results);
						var aWeeks = oData.results.map(function (item) {
							return {
								week: "Week" + item.ScreenCol,
								Yearweek: item.Yearweek
							};
						});

						// Add All option
						aWeeks.unshift({
							week: "All",
							Yearweek: "All"
						});

						this.getView().getModel("appView").setProperty("/VolumeWeeks", aWeeks);
						this.getView().getModel("appView").setProperty("/CalendarData", oData.results);
						resolve(oData); // ✅ important
					}.bind(this),
					error: function (oError) {
						reject(oError);

					}
				});
			});

		},

		_toggleWeekColumnsVisibility: function (aCalendarData) {

			const oTableEdit = this.getView().byId("idVolumePerWeek");
			const oTableDisplay = this.getView().byId("idVolumePerWeekDisplay");

			// Hide all week columns from index 5 to 69
			for (let i = 6; i <= 69; i++) {
				oTableEdit.getColumns()[i].setVisible(false);
				oTableDisplay.getColumns()[i].setVisible(false);
			}

			// Show only the columns present in CalendarData
			aCalendarData.forEach(({ ScreenCol }) => {
				const colIndex = parseInt(ScreenCol) + 5;
				oTableEdit.getColumns()[colIndex].setVisible(true);
				oTableDisplay.getColumns()[colIndex].setVisible(true);
			});


		},


		onSuggestionItemSelected: function (oEvent) {
			ItemOIHelper.onSuggestionItemSelected(oEvent, this)

		},
		onOIVHTokenUpdate: function (oEvent) {
			ItemOIHelper.onOIVHTokenUpdate(oEvent, this);


		},
		onOIValueHelp: function (oEvent) {

			ItemOIHelper.onOIValueHelpRequest(oEvent, this);

		},


		onEditPress: function () {
			this.setPromoPlanMode("edit");

		},

		onCancelPress: function () {

			var that = this;
			MessageBox.confirm("Are you sure? You want to cancel the changes?", {
				actions: [MessageBox.Action.OK, MessageBox.Action.CANCEL],
				emphasizedAction: MessageBox.Action.OK,
				onClose: function (sAction) {
					if (sAction === "OK") {
						that._cancelTheChanges();

					}
				},
				dependentOn: this.getView()
			});




		},
		_cancelTheChanges: function (oEvent) {

			const oAppViewModel = this.getView().getModel("appView");
			const oPlanHeaderModel = this.getView().getModel("PlanHeader");


			// Navigate to home if it's a new promo plan
			if (oAppViewModel.getProperty("/isNewMode")) {
				this.handleNavigationToHomePage();
			}
			else {
				var sId = oPlanHeaderModel.getData().PlanId;

				this.loadComments(sId);
				// Initialize promo plan context in edit mode
				this.initializePromoPlanContext(true);

				// Initialize DeletedPlanningOI model
				const oDeletedModel = new JSONModel([]);
				this.getOwnerComponent().setModel(oDeletedModel, "DeletedPlanningOI");
				const oVolumeModel = new JSONModel([]);
				this.getView().setModel(oVolumeModel, "VolumeModel");
				this.getView().getModel("appView").setProperty("/PlanItems", []);
				this.getView().getModel("appView").setProperty("/VolumeWeeks", []);
				this.getView().getModel("appView").setProperty("/PromoPNL", []);

				this.getView().getModel("appView").setProperty("/PromoROI", []);




				// Load promo plan data by ID
				this._loadPromoPlanById(sId);

				// Navigate to General Data section
				this._navigateToSection("idGeneralDataSection", this);
			}

			// Show cancellation message and switch to view mode
			MessageBox.show("Promo Changes Cancelled successfully");
			this.setPromoPlanMode("view");

		},

		initializePromoPlanContext: function (isEditMode) {
			Helper.resetCreatePromoModel(this);

			Helper.onClearData(this);

			if (isEditMode) {
				Helper.resetEditValidationModel(this);
			} else {
				Helper.resetValidationModel(this);
			}
		},

		_onCreateRouteMatched: function () {


			// Initialize column set counter
			this._iSpendOIColumnSetCount = 1;

			// Set mode to 'new'
			this.setPromoPlanMode("new");

			// Initialize VolumeModel
			const oVolumeModel = new JSONModel([]);
			this.getView().setModel(oVolumeModel, "VolumeModel");

			// Initialize promo plan context
			this.initializePromoPlanContext(false);


			// Initialize DeletedPlanningOI model
			const oDeletedModel = new JSONModel([]);
			this.getOwnerComponent().setModel(oDeletedModel, "DeletedPlanningOI");

			// Load status data
			this._loadStatus();

			// Reset SpendType flags
			const oAppViewModel = this.getView().getModel("appView");
			["SpendType2", "SpendType3", "SpendType4", "SpendType5"].forEach(type => {
				oAppViewModel.setProperty(`/${type}`, false);
			});

			// Navigate to General Data section
			this._navigateToSection("idGeneralDataSection", this);


		},


		_onEditRouteMatched: function (oEvent) {

			const sId = oEvent.getParameter("arguments").id;
			this.loadComments(sId);
			this.loadChangeDocuments();
			// Initialize promo plan context in edit mode
			this.initializePromoPlanContext(true);

			// Initialize DeletedPlanningOI model
			const oDeletedModel = new JSONModel([]);
			this.getOwnerComponent().setModel(oDeletedModel, "DeletedPlanningOI");
			const oVolumeModel = new JSONModel([]);
			this.getView().setModel(oVolumeModel, "VolumeModel");
			this.getView().getModel("appView").setProperty("/PlanItems", []);
			this.getView().getModel("appView").setProperty("/VolumeWeeks", []);
			this.getView().getModel("appView").setProperty("/PromoPNL", []);

			this.getView().getModel("appView").setProperty("/PromoROI", []);




			// Load promo plan data by ID
			this._loadPromoPlanById(sId);

			// Navigate to General Data section
			this._navigateToSection("idGeneralDataSection", this);

		},



		_loadStatus: async function () {
			try {
				const oData = await this.readModelData("PromoPlan", "/StatusSet", {});
				const aStatusSet = oData.results || [];
				const oDefaultItem = aStatusSet.find(item => item.Initialstatus === true);

				if (oDefaultItem) {
					const oMultiInput = this.byId("idStatusVHCreateID");
					oMultiInput.removeAllTokens();

					const oToken = new sap.m.Token({
						key: oDefaultItem.Status,
						text: oDefaultItem.Description
					});

					const oPlanHeaderModel = this.getView().getModel("PlanHeader");
					oPlanHeaderModel.setProperty("/Status", oDefaultItem.Status);
					oPlanHeaderModel.setProperty("/StatusDesc", oDefaultItem.Description);


					oMultiInput.addToken(oToken);
					oMultiInput.setValueState("None");
					oMultiInput.setValueStateText("");
				}

			} catch (oError) {
				console.error("Failed to read StatusSet", oError);
			} finally {
				this.hideBusyIndicator();
			}
		},


		_tokenMappings: async function (oData) {


			if (!oData || Object.keys(oData).length === 0) {
				this.showMessageBox("Error", "Input object is empty. Cannot add tokens.", "Error");

				return;
			}
			var sUrl = "/PromoPlanSet(Vkorg='" + oData.Vkorg + "',Vtweg='" + oData.Vtweg + "',PlanType='" + oData.PlanType + "')";
			const oPlanType = await this.readModelData("PromoPlan", sUrl, {});

			const oAppViewModel = this.getView().getModel("appView");

			if (oPlanType && oPlanType.MaxTactics !== undefined && oPlanType.MaxTactics !== null) {
				oAppViewModel.setProperty("/MaxTactics", oPlanType.MaxTactics);
			} else {
				oAppViewModel.setProperty("/MaxTactics", 0);
			}
			var that = this;
			var tokenMappings = [
				{ id: "idSalesOrgGDVHID", key: "Vkorg", text: "VkorgDesc" },
				{ id: "idDistChanGDVHID", key: "Vtweg", text: "VtwegDesc" },
				{ id: "idSalesAreaGDVHID", key: "Sa_Id", text: "SaName" },
				{ id: "idPromoPlanTypeID", key: "PlanType", text: "PlanTypeDesc" },
				{ id: "idStatusVHCreateID", key: "Status", text: "StatusDesc" },
				{ id: "idFundPlanVHID", key: "FundPlan", text: "FundPlanDesc" },
				{ id: "idObjectiveID", key: "ObjectiveId", text: "ObjectiveDesc" },
				{ id: "idProductSelectionID", key: "ProductSelection" }
			];

			// Map for ProductSelection text
			var productSelectionMap = {
				"PRODH": "Product Hierarchy",
				"MATNR": "Product",
				"BRAND": "Brand",
				"SBRAN": "Sub Brand"
			};

			// Generic token addition logic
			tokenMappings.forEach(function (mapping) {
				var value = oData[mapping.key];
				if (value) {
					var oMultiInput = that.getView().byId(mapping.id);
					
					if (oMultiInput) {
						oMultiInput.removeAllTokens();
						var tokenText;

						if (mapping.id === "idProductSelectionID") {
							tokenText = productSelectionMap[value] || value;
						} else {
							tokenText = oData[mapping.text] || value;
						}

						oMultiInput.addToken(new sap.m.Token({
							key: value,
							text: tokenText
						}));
					}
				}
			});


		},

		onPlanningOITblDspRowUpdated: function (oEvent) {

			//const oAppViewModel = this.getView().getModel("appView");

			var that = this;
			var rows = oEvent.getSource().getRows();


			if (rows.length > 0) {
				var context = rows[1].getBindingContext("PlanHeader");

				if (context !== null) {

					var oFirstRowData = context.getObject();


					const oAppViewModel = this.getView().getModel("appView");
					var aSpendTypeArray = this.getView().getModel("appView").getData().Tactics;


					const oPlanHeaderModel = this.getView().getModel("PlanHeader");
					const aItems = oPlanHeaderModel.getProperty("/To_Item/results");

					// Loop through SpendMethod1 to SpendMethod5
					for (let i = 1; i <= 5; i++) {

						const spendMethod = oFirstRowData[`SpendMethod${i}`];
						aItems[0][`SpendMethod${i}`] = spendMethod;
						const spendTypeKey = `SpendType${i}`;
						const spendTypeValue = oFirstRowData[spendTypeKey];
						aItems[0][`SpendType${i}`] = spendTypeValue;
						aItems[0][`SpendType${i}Desc`] = oFirstRowData[`SpendType${i}Desc`];
						aItems[0][`Tactic${i}`] = oFirstRowData[`Tactic${i}`];
						const tacticDescKey = `TacticDesc${i}`;
						const tacticId = oFirstRowData[`Tactic${i}`];
						const SpendTypeClassKey = `SpendTypeClass${i}`;

						let sTacticDesc = "";
						let SpendTypeClass = "";

						for (let j = 0; j < aSpendTypeArray.length; j++) {
							const aChildren = aSpendTypeArray[j].children || [];
							for (let k = 0; k < aChildren.length; k++) {
								const child = aChildren[k];
								if (child.SpendType === spendTypeValue && tacticId === child.TacticId) {
									sTacticDesc = child.TDesc;
									SpendTypeClass = child.SpendTypeClass;
									break;
								}
							}

						}



						aItems.forEach(function (item) {

							item[tacticDescKey] = sTacticDesc;
							item[SpendTypeClassKey] = SpendTypeClass;
						});

						// Enable Discount if SpendMethod is "%"
						const enableDiscount = spendMethod === "%";
						oAppViewModel.setProperty(`/Discount${i}`, enableDiscount);

						// Enable DiscountAmt if SpendMethod is "$", "F", or "P"
						const enableDiscountAmt = ["$", "F", "P"].includes(spendMethod);
						oAppViewModel.setProperty(`/DiscountAmt${i}`, enableDiscountAmt);
					}
					oPlanHeaderModel.setProperty("/To_Item/results", aItems);
					const spendTypes = ['SpendType2', 'SpendType3', 'SpendType4', 'SpendType5'];


					for (let i = 0; i < spendTypes.length; i++) {
						const type = spendTypes[i];
						var bSpendType = oAppViewModel.getProperty("/" + type);
						if (oFirstRowData[type] && bSpendType !== true) {
							that.onPlanningOIAddColumn(); // Add column one by one
						}
					}


				}

			}


		},
		onPlanningOITblRowUpdated: function (oEvent) {

			//const oAppViewModel = this.getView().getModel("appView");
			const oPlanningTable = this.getView().byId("idPlanningOITable");
			const aRows = oPlanningTable.getRows();

			if (aRows.length === 0) {
				return;
			}

			const oFirstContext = aRows[1].getBindingContext("PlanHeader");

			if (oFirstContext) {

				const oFirstRowData = oFirstContext.getObject();

				const oAppViewModel = this.getView().getModel("appView");

				// Loop through SpendMethod1 to SpendMethod5
				for (let i = 1; i <= 5; i++) {
					const spendMethod = oFirstRowData[`SpendMethod${i}`];

					// Enable Discount if SpendMethod is "%"
					const enableDiscount = spendMethod === "%";
					oAppViewModel.setProperty(`/Discount${i}`, enableDiscount);

					// Enable DiscountAmt if SpendMethod is "$", "F", or "P"
					const enableDiscountAmt = ["$", "F", "P"].includes(spendMethod);
					oAppViewModel.setProperty(`/DiscountAmt${i}`, enableDiscountAmt);
				}

				const spendTypes = ['SpendType2', 'SpendType3', 'SpendType4', 'SpendType5'];

				spendTypes.forEach(type => {
					const bSpendType = oAppViewModel.getProperty(`/${type}`);
					if (oFirstRowData[type] && !bSpendType) {
						this.onPlanningOIAddColumn(); // Add column one by one
					}
				});
			}

			const oModel = this.getView().getModel("appView");
			const bBrand = oModel.getProperty("/Brand");
			const bProduct = oModel.getProperty("/Product");
			const bSubBrand = oModel.getProperty("/SubBrand");

			//const bProductHierarchy = oModel.getProperty("/ProductHierarchy");

			aRows.forEach(row => {
				const oContext = row.getBindingContext("PlanHeader");
				if (!oContext) return;

				const oData = oContext.getObject();
				const aCells = row.getCells();
				if (bProduct) {
					this.addTokenIfValid(aCells[0], oData.Matnr, oData.MatnrDesc);
				}
				else if (bBrand && !bSubBrand) {
					this.addTokenIfValid(aCells[0], oData.Brand, oData.BrandDesc);
					//this.addTokenIfValid(aCells[1], oData.Subbrand, oData.SubbrandDesc);

				}

				else if (bSubBrand) {
					this.addTokenIfValid(aCells[0], oData.Brand, oData.BrandDesc);
					this.addTokenIfValid(aCells[1], oData.Subbrand, oData.SubbrandDesc);

				}


			});
			const oRowContext = aRows[1].getBindingContext("PlanHeader");
			if (oRowContext) {
				const aRowCells = aRows[0].getCells();
				const oRowData = oRowContext.getObject();
				var aSpendTypeArray = this.getView().getModel("appView").getData().Tactics;

				if (Array.isArray(aSpendTypeArray) && aSpendTypeArray.length > 0) {
					const oPlanHeaderModel = this.getView().getModel("PlanHeader");
					const aItems = oPlanHeaderModel.getProperty("/To_Item/results");

					const oModel = this.getView().getModel("appView");
					const bBrand = oModel.getProperty("/Brand");
					const bProduct = oModel.getProperty("/Product");
					const bSubBrand = oModel.getProperty("/SubBrand");

					const bProductHierarchy = oModel.getProperty("/ProductHierarchy");

					//const nLineLength = aItems.length;

					for (let i = 0; i < 5; i++) {

						const spendTypeKey = `SpendType${i + 1}`;
						const tacticDescKey = `TacticDesc${i + 1}`;
						const tacticId = oRowData[`Tactic${i + 1}`];

						const spendTypeValue = oRowData[spendTypeKey];
						let spendTypeDesc = "";
						let sTacticDesc = "";

						// Loop through the array and its children
						for (let j = 0; j < aSpendTypeArray.length; j++) {
							const aChildren = aSpendTypeArray[j].children || [];
							for (let k = 0; k < aChildren.length; k++) {
								const child = aChildren[k];
								if (child.SpendType === spendTypeValue && tacticId === child.TacticId) {
									spendTypeDesc = child.Description;
									sTacticDesc = child.TDesc;
									break;
								}
							}
							if (spendTypeDesc) break; // Exit outer loop if found
						}




						aItems.forEach(function (item) {
							item[tacticDescKey] = sTacticDesc;
						});



						// Calculate offset based on condition
						let offset;
						if (bSubBrand) {
							offset = 10 + i * 4;
						} else if (bProduct || bProductHierarchy || bBrand) {
							offset = 9 + i * 4;
						}


						if (aRowCells[offset].getItems) {
							this.addTokenIfValid(aRowCells[offset].getItems()[0], spendTypeValue, spendTypeDesc);
						}

					}

					oPlanHeaderModel.setProperty("/To_Item/results", aItems);
				}
			}


		},

		isDiscountAmountVisible: function (spendMethod1) {
			const spendType1 = this.getView().getModel("appView").getProperty("/SpendType1");
			return spendType1 && (spendMethod1 === "F" || spendMethod1 === "$");
		},
		isDiscountVisible: function (spendMethod1) {
			const spendType1 = this.getView().getModel("appView").getProperty("/SpendType1");
			return spendType1 && (spendMethod1 === "%");
		},

		addTokenIfValid: function (oCell, sKey, sText) {
			if (sKey && sText && oCell instanceof sap.m.MultiInput) {
				oCell.removeAllTokens();
				oCell.addToken(new Token({ key: sKey, text: sText }));
			}
		},



		cleanItemData: function (arr) {
			const normalizeValue = function (num) {
				let value = parseFloat(num); // Convert to number
				if (value === 0) return 0;   // If zero, return 0
				return parseFloat(value.toString()); // Remove trailing zeros
			}
			var oAppViewModel = this.getView().getModel("appView");

			// Step 1: Reset all flags to false
			["ProductHierarchy", "Brand", "Product", "SubBrand"].forEach(function (sProp) {
				oAppViewModel.setProperty("/" + sProp, false);
			});


			if (arr.length > 0) {
				var firstItem = arr[1];

				if (firstItem.Matnr) {
					oAppViewModel.setProperty("/Product", true);
				} else if (firstItem.Brand) {
					if (firstItem.Subbrand) {
						oAppViewModel.setProperty("/SubBrand", true);

					}
					oAppViewModel.setProperty("/Brand", true);
				} else if (firstItem.Prodh) {
					oAppViewModel.setProperty("/ProductHierarchy", true);
				}


			}

			// Properties to normalize
			const numericProps = [
				"ListPrice", "SalesPlanned", "SpendPlanned", "Niv", "SpendPlannedOi", "Sales",
				"LtaDef", "SpendPlannedBb", "SpendPlannedLs", "Nsv", "Cogs", "LogisticOiCost",
				"FinancialOiCost", "OtherOiCost", "LogisticDefCost", "FinancialDefCost",
				"OtherDefCost", "Dcost", "Baseline", "Uplift", "VolumePlanned", "NetCost", "RetailPrice", "RegularPrice",
				"Discount1", "Discount2", "Discount3", "Discount4", "Discount5", "DiscountAmt1", "DiscountAmt2", "DiscountAmt3",
				"DiscountAmt4", "DiscountAmt5", "Tax", "Profit", "Ppc"
			];

			arr[0].Uom = arr[1].Uom;

			for (let i = 1; i <= 5; i++) {
				arr[0][`SpendType${i}`] = arr[1][`SpendType${i}`];
				arr[0][`Tactic${i}`] = arr[1][`Tactic${i}`];
				arr[0][`SpendMethod${i}`] = arr[1][`SpendMethod${i}`];
			}

			arr.sort((a, b) => parseInt(a.itemNo, 10) - parseInt(b.itemNo, 10));

			arr = arr.map(item => {
				delete item.__metadata;
				item.IsSummary = false;

				// Reset allocations and tactics
				for (let i = 1; i <= 5; i++) {
					item[`SpendAlloc${i}`] = "";
					item[`TacticDesc${i}`] = "";
					item[`SpendTypeClass${i}`] = "";

				}
				item.IsSummary = false;

				// Normalize numeric properties
				numericProps.forEach(prop => {
					item[prop] = normalizeValue(item[prop]);
				});
				return item;
			});
			arr = this.updateDiscountSummary(arr);
			return arr;
		},


		updateDiscountSummary: function (items) {
			if (!Array.isArray(items) || items.length === 0) return items;

			const header = items[0];
			const discountFields = ["Discount1", "Discount2", "Discount3", "Discount4", "Discount5"];
			const discountAmountFields = ["DiscountAmt1", "DiscountAmt2", "DiscountAmt3", "DiscountAmt4", "DiscountAmt5"];
			const lineItems = items.slice(1); // exclude header

			// Value normalizer: treats empty/undefined/NaN as 0
			const normalizeValue = (num) => {
				if (num === null || num === undefined || num === "") return 0;
				const v = parseFloat(num);
				return Number.isFinite(v) ? v : 0;
			};

			for (const field of discountFields) {
				const values = lineItems.map(it => normalizeValue(it[field]));

				if (values.length === 0) {
					// No line items → header discount is 0
					header[field] = 0;
					continue;
				}

				const first = values[0];
				const allEqual = values.every(v => v === first);

				if (allEqual) {
					// SUM of all line items' DiscountN
					const sum = values.reduce((acc, v) => acc + v, 0);
					header[field] = sum;
				} else {
					header[field] = 0;
				}
			}


			// ---- Rule 2: DiscountAmt1..5 → always sum ----
			for (const field of discountAmountFields) {
				const sum = lineItems.reduce((acc, it) => acc + normalizeValue(it[field]), 0);
				header[field] = sum;
			}


			return items;
		},


		_volumeTableFixedColumns: function () {
			var oTable = this.getView().byId("idVolumePerWeek");
			var oTableDis = this.getView().byId("idVolumePerWeekDisplay");


			//  fixed column metadata
			var aFixedColumns = [
				{ key: "Brand", label: "Brand", type: "text" },
				{ key: "Subbrand", label: "Sub Brand", type: "text" },
				{ key: "Matnr", label: "Selling SKU", type: "text" },
				{ key: "Prodh", label: "Product Hierarchy", type: "text" },
				{ key: "VolType", label: "Type", type: "text" }
			];

			// Create columns dynamically
			aFixedColumns.forEach(function (col) {

				var bVisible = (col.key === "VolType" || col.key === "Total");

				var oColumn = new UIColumn({
					hAlign: (col.key === "Total") ? "End" : "Begin",
					visible: bVisible,
					label: new Label({ text: col.label }),
					template: col.type === "input"
						? new Input({
							textAlign: "End",
							value: "{VolumeModel>" + col.key + "}",
							type: "Number",
							editable: {
								parts: [
									{ path: "VolumeModel>VolType" }
								],
								formatter: function (sVolType) {
									return sVolType !== "P";
								}
							}
						})
						:
						new Label({
							textAlign: "End",
							customData: [
								new sap.ui.core.CustomData({
									key: "colour",
									value: {
										path: "VolumeModel>VolType",
										formatter: function (sVolType) {
											return sVolType === "P" && col.key === "VolType" ? "highlightBlueLabel" : "";
										}
									},
									writeToDom: true
								})
							],
							design: {
								path: "VolumeModel>" + col.key,
								formatter: function (sVolType) {
									if (col.key === "VolType") {
										switch (sVolType) {
											case "B": return "Standard";
											case "U": return "Standard";
											case "P": return "Bold";
											default: return "Standard";
										}
									}
									return "Standard";
								}
							},
							text: {
								path: "VolumeModel>" + col.key,
								formatter: function (sVolType) {
									if (col.key === "VolType") {
										switch (sVolType) {
											case "B": return "Baseline";
											case "U": return "Uplift";
											case "P": return "Total Volume";
											default: return sVolType;
										}
									}
									return sVolType;
								}
							}
						})

				});

				var oColumnDis = new UIColumn({
					hAlign: (col.key === "Total") ? "End" : "Begin",
					visible: bVisible,
					label: new Label({ text: col.label }),
					template:
						new Label({
							textAlign: "End",
							customData: [
								new sap.ui.core.CustomData({
									key: "colour",
									value: {
										path: "VolumeModel>VolType",
										formatter: function (sVolType) {
											return sVolType === "P" && col.key === "VolType" ? "highlightBlueLabel" : "";
										}
									},
									writeToDom: true
								})
							],

							design: {
								path: "VolumeModel>" + col.key,
								formatter: function (sVolType) {
									if (col.key === "VolType") {
										switch (sVolType) {
											case "B": return "Standard";
											case "U": return "Standard";
											case "P": return "Bold";
											default: return "Standard";
										}
									}
									return "Standard";
								}
							},
							text: {
								path: "VolumeModel>" + col.key,
								formatter: function (sVolType) {
									if (col.key === "VolType") {
										switch (sVolType) {
											case "B": return "Baseline";
											case "U": return "Uplift";
											case "P": return "Total Volume";
											default: return sVolType;
										}
									}
									return sVolType;
								}
							}
						})

				});

				oTable.addColumn(oColumn);
				oTableDis.addColumn(oColumnDis);
			});


			var oTotalColumn = new UIColumn({
				hAlign: "End",
				visible: true,
				label: new Label({ text: "Total" }),
				template: new sap.m.HBox({
					width: "100%",
					alignItems: "End",
					justifyContent: "End",
					items: [
						// Label visible only when VolType === 'P'
						new Label({
							testAlign: "End",
							customData: [
								new sap.ui.core.CustomData({
									key: "colour",
									value: {
										path: "VolumeModel>VolType",
										formatter: function (sVolType) {
											return sVolType === "P" ? "highlightBlueLabel" : "";
										}
									},
									writeToDom: true
								})
							],
							design: "Bold",

							text: "{VolumeModel>Total}",
							visible: "{= ${VolumeModel>VolType} === 'P' }"
						}).addStyleClass("sapUiTinyMarginEnd"),
						// Input visible only when VolType !== 'P'
						new Input({
							textAlign: "End",
							value: "{VolumeModel>Total}",
							type: "Number",
							editable: true,
							visible: "{= ${VolumeModel>VolType} !== 'P' }",
							change: this._onTotalChange.bind(this)
						})
					]
				})





			});

			oTable.addColumn(oTotalColumn);


			var oTotalColumnDis = new UIColumn({
				hAlign: "End",
				label: new Label({ text: "Total" }),
				template: new Label({
					textAlign: "End",
					customData: [

						new sap.ui.core.CustomData({
							key: "colour",
							value: {
								path: "VolumeModel>VolType",
								formatter: function (sVolType) {
									return sVolType === "P" ? "highlightBlueLabel" : "";
								}
							},
							writeToDom: true
						})
					],
					design: {
						path: "VolumeModel>VolType",
						formatter: function (sVolType) {

							switch (sVolType) {
								case "B": return "Standard";
								case "U": return "Standard";
								case "P": return "Bold";
								default: return "Standard";

							}

						}
					},
					text: "{VolumeModel>Total}"
				})
			});


			oTableDis.addColumn(oTotalColumnDis);


			for (var i = 1; i <= 65; i++) {

				var sWeekKey = "WeekVol" + i;


				oTable.addColumn(new UIColumn({
					hAlign: "End",
					visible: false,
					label: new Label({ text: "Week " + i }),
					template: new sap.m.HBox({
						width: "100%",
						alignItems: "End",
						justifyContent: "End",
						items: [
							// Label visible only when VolType === 'P'
							new Label({
								textAlign: "End",

								customData: [
									new sap.ui.core.CustomData({
										key: "colour",
										value: {
											path: "VolumeModel>VolType",
											formatter: function (sVolType) {
												return sVolType === "P" ? "highlightBlueLabel" : "";
											}
										},
										writeToDom: true
									})
								],
								design: "Bold",

								text: "{VolumeModel>" + sWeekKey + "}",
								visible: "{= ${VolumeModel>VolType} === 'P' }"
							}).addStyleClass("sapUiTinyMarginEnd"),
							// Input visible only when VolType !== 'P'
							new Input({
								textAlign: "End",
								value: "{VolumeModel>" + sWeekKey + "}",
								type: "Number",
								editable: true,
								visible: "{= ${VolumeModel>VolType} !== 'P' }",
								change: this._onWeekChange.bind(this)
							})
						]
					})
				}));

				oTableDis.addColumn(new UIColumn({
					hAlign: "End",
					visible: false,
					label: new Label({ text: "Week " + i }),
					template: new Label({
						textAlign: "End",
						customData: [
							new sap.ui.core.CustomData({
								key: "colour",
								value: {
									path: "VolumeModel>VolType",
									formatter: function (sVolType) {
										return sVolType === "P" ? "highlightBlueLabel" : "";
									}
								},
								writeToDom: true
							})
						],
						design: {
							path: "VolumeModel>VolType",
							formatter: function (sVolType) {

								switch (sVolType) {
									case "B": return "Standard";
									case "U": return "Standard";
									case "P": return "Bold";
									default: return "Standard";

								}

							}
						},

						text: "{VolumeModel>" + sWeekKey + "}"
					})
				}));

			}
		},


		_onTotalChange: function (oEvent) {
			const oInput = oEvent.getSource();
			const value = oInput.getValue();
			const oContext = oInput.getBindingContext("VolumeModel");
			const oData = oContext.getObject();

			const aCalendarData = this.getView().getModel("appView").getProperty("/CalendarData");
			const aVisibleWeeks = [...new Set(aCalendarData.map(d => parseInt(d.ScreenCol)))];

			// Validate integer input
			if (!/^-?\d+$/.test(value)) {
				oInput.setValueState("Error");
				oInput.setValueStateText("Please enter a valid integer.");
				aVisibleWeeks.forEach(function (weekIndex) {
					const sWeekKey = "WeekVol" + weekIndex;
					oContext.getModel().setProperty(oContext.getPath() + "/" + sWeekKey, "0");
				});
				return;
			}

			const iTotal = parseInt(value, 10);
			if (isNaN(iTotal)) return;

			const iWeekCount = aVisibleWeeks.length;
			if (iWeekCount === 0) return;

			let iBaseValue, iRemaining;

			if (iTotal % iWeekCount === 0) {
				// Evenly divisible
				iBaseValue = Math.floor(iTotal / iWeekCount);
				iRemaining = 0;

				aVisibleWeeks.forEach(function (weekIndex) {
					const sWeekKey = "WeekVol" + weekIndex;
					oContext.getModel().setProperty(oContext.getPath() + "/" + sWeekKey, iBaseValue.toString());
				});
			} else {
				var nOfWeeks = 0;
				const iBaseValue = Math.ceil(iTotal / iWeekCount); // ensures last week is smaller
				const iTotalBeforeLast = iBaseValue * (iWeekCount - 1);
				var iLastWeekValue = iTotal - iTotalBeforeLast;
				if (iLastWeekValue < 0) {
					iLastWeekValue = 0;
				}
				//if(iLastWeekValue===0){
				nOfWeeks = Math.ceil(iTotal / iBaseValue);
				//}
				aVisibleWeeks.forEach(function (weekIndex, idx) {
					const sWeekKey = "WeekVol" + weekIndex;
					var iWeekValue = 0;
					if (nOfWeeks >= (idx + 1)) {
						iWeekValue = (idx === iWeekCount - 1) ? iLastWeekValue : iBaseValue;
					}
					oContext.getModel().setProperty(oContext.getPath() + "/" + sWeekKey, iWeekValue.toString());
				});

			}

			// Clear error state
			oInput.setValueState("None");
			oInput.setValueStateText("");
			this._updatePlanningTable(oData.ItemNo, iTotal, oData.VolType);
			this._updatePTypeVerticalTotals(oData.ItemNo);
		},


		_updatePlanningTable: function (sItemNo, iTotal, sVolType) {
			const oPlanHeaderModel = this.getOwnerComponent().getModel("PlanHeader");
			const aData = oPlanHeaderModel.getProperty("/To_Item/results") || [];

			aData.forEach(function (row) {
				if (row.ItemNo === sItemNo) {
					switch (sVolType) {
						case "B":
							if (row.Baseline !== iTotal) {
								row.Baseline = iTotal.toString();
							}
							break;
						case "U":
							if (row.Uplift !== iTotal) {
								row.Uplift = iTotal.toString();

							}
							break;
						case "P":
							if (row.VolumePlanned !== iTotal) {
								row.VolumePlanned = iTotal.toString();
							}
							break;
					}
				}
			});
			oPlanHeaderModel.setProperty("/To_Item/results", aData);

			//oPlanHeaderModel.refresh(true);
			this.updateSummaryRow();

		},


		_onWeekChange: function (oEvent) {
			const oInput = oEvent.getSource();
			const oContext = oInput.getBindingContext("VolumeModel");
			const oData = oContext.getObject();

			let iTotal = 0;
			for (let i = 1; i <= 65; i++) {
				const sWeekKey = "WeekVol" + i;
				const iWeekVal = parseFloat(oData[sWeekKey]);
				if (!isNaN(iWeekVal)) {
					iTotal += iWeekVal;
				}
			}

			oContext.getModel().setProperty(oContext.getPath() + "/Total", iTotal.toString());
			this._updatePlanningTable(oData.ItemNo, iTotal.toString(), oData.VolType);
			this._updatePTypeVerticalTotals(oData.ItemNo);

		},

		_updatePTypeVerticalTotals: function (ItemNo) {
			const oModel = this.getView().getModel("VolumeModel");
			const aData = oModel.getProperty("/");
			const aCalendarData = this.getView().getModel("appView").getProperty("/CalendarData");

			// Extract unique ScreenCol values
			const aVisibleWeeks = [...new Set(aCalendarData.map(d => parseInt(d.ScreenCol)))];

			for (let i = 0; i < aCalendarData.length; i++) {
				const sWeekKey = "WeekVol" + aCalendarData[i].ScreenCol;

				// Sum B and U types
				let iSum = 0;
				let iTotal = 0;
				aData.forEach(row => {
					if ((row.VolType === "B" || row.VolType === "U") && row.ItemNo === ItemNo) {
						const val = parseFloat(row[sWeekKey]);
						if (!isNaN(val)) {
							iSum += val;
						}

						const iTotalVal = parseFloat(row.Total);
						if (!isNaN(iTotalVal)) {
							iTotal += iTotalVal;
						}
					}
				});
				var that = this;
				// Update P-type rows
				aData.forEach(row => {
					if (row.VolType === "P" && row.ItemNo === ItemNo) {
						row[sWeekKey] = iSum.toString();
						that._updatePlanningTable(ItemNo, row[sWeekKey], row.VolType);
						row.Total = iTotal.toString();

						that._updatePlanningTable(ItemNo, row.Total, row.VolType);



					}
				});
			}

			oModel.refresh(true);
		},
_volumeTableDynamicColumns: function (oVolume) {
    let sLabelText1 = "";
    let sLabelText2 = "";

    if (oVolume.Brand) {
        sLabelText1 = "Brand";

        if (oVolume.Subbrand) {
            sLabelText2 = "Sub Brand";
        }
    } else if (oVolume.Matnr) {
        sLabelText1 = "Selling SKU";
    } else if (oVolume.Prodh) {
        sLabelText1 = "Product Hierarchy";
    }

    this._toggleVolumeTableColumnsByLabel(sLabelText1, sLabelText2);
},
		_volumeTableDynamicColumns1: function (oVolume) {
			let sLabelText = "";
			if (oVolume.Brand) {
				sLabelText = "Brand";
			} else if (oVolume.Matnr) {
				sLabelText = "Selling SKU";
			} else if (oVolume.Prodh) {
				sLabelText = "Product Hierarchy";
			}

			this._toggleVolumeTableColumnsByLabel(sLabelText);


		},

		_volumeModel: function (aItems) {

			// Flatten To_Volume from all To_Item entries
			var aVolumeData = [];
			aItems.forEach(function (item) {
				if (item.ItemNo !== "000000") {
					if (item.To_Volume && item.To_Volume.results) {
						item.To_Volume.results.forEach(function (volume) {
							if (volume.VolType === "B") {
								volume.Total = parseInt(item.Baseline, 10) || 0;
							}
							else if (volume.VolType === "U") {
								volume.Total = parseInt(item.Uplift, 10) || 0;
							}
							else if (volume.VolType === "P") {
								volume.Total = parseInt(item.VolumePlanned, 10) || 0;
							}

							// Parse all 65 week volume fields as integers
							for (let i = 1; i <= 65; i++) {
								const weekKey = "WeekVol" + i;
								volume[weekKey] = parseInt(volume[weekKey], 10) || 0;
							}

							aVolumeData.push(volume);
						});
					}
				}
			});

			var oVolumeModel = new JSONModel(aVolumeData);
			this.getView().setModel(oVolumeModel, "VolumeModel");



		},
		_getVolumeData: function (that, sFieldType, value, ItemNo, subbrand) {

			return ItemOIHelper._getVolumeData(that, sFieldType, value, ItemNo, subbrand);

		},

		_toggleVolumeTableColumnsByLabel: function (aLabelText1, aLabelText2) {
    const oTable = this.getView().byId("idVolumePerWeek");
    const oTableDis = this.getView().byId("idVolumePerWeekDisplay");

    // Build array dynamically
    let aLabelTexts = [aLabelText1];

    if (aLabelText2) {  // only add if not empty / null / undefined
        aLabelTexts.push(aLabelText2);
    }

    const toggleColumns = (aColumns) => {
        aColumns.slice(0, 5).forEach(col => {
            const label = col.getLabel();
            const sText = label?.getText?.();
            col.setVisible(aLabelTexts.includes(sText));
        });
    };

    toggleColumns(oTable.getColumns());
    toggleColumns(oTableDis.getColumns());
},

		_toggleVolumeTableColumnsByLabel1: function (sLabelText) {
			const oTable = this.getView().byId("idVolumePerWeek");
			const oTableDis = this.getView().byId("idVolumePerWeekDisplay");

			const toggleColumns = (aColumns) => {
				aColumns.slice(0, 4).forEach(col => {
					const label = col.getLabel();
					col.setVisible(label?.getText?.() === sLabelText);
				});
			};

			toggleColumns(oTable.getColumns());
			toggleColumns(oTableDis.getColumns());
		},

		onProductValueSelected: async function (oEvent) {

			const oSelectedProduct = oEvent.getParameter("selectedItem");
			this._toggleVolumeTableColumnsByLabel("Product Hierarchy");
			await ItemOIHelper._getVolumeData(this, "Prodh", oSelectedProduct?.Prodh, oSelectedProduct.ItemNo, "");


		},

		onCustomerValueSelected: async function (oEvent) {
			const sCustomerName = oEvent.getParameter("selectedItem")?.NameOrg1;
			if (sCustomerName) {
				const oPlanHeaderModel = this.getView().getModel("PlanHeader");
				oPlanHeaderModel.setProperty("/CustomerName", sCustomerName);
			}

			await Validate.validateGeneralData(this);


			await Validate.validatePlanHeaderData(this);
		},


		parseDateOnlyToLocalMidnight: function (input) {
			if (!input || typeof input !== "string") return "";

			// Accept "YYYY-MM-DD" or "YYYY/MM/DD"
			const parts = input.includes("-") ? input.split("-") : input.split("/");
			if (parts.length !== 3) return null;

			const [y, m, d] = parts.map(Number);

			// Basic validation
			if (!Number.isInteger(y) || !Number.isInteger(m) || !Number.isInteger(d)) return null;
			if (m < 1 || m > 12 || d < 1 || d > 31) return null;

			// Construct at local midnight (month is 0-based)
			const date = new Date(y, m - 1, d);
			date.setHours(0, 0, 0, 0);
			return date;
		},




		_loadPromoPlanById: async function (sPlanId) {

			try {

				this.getOwnerComponent().getModel().read("/Plan_HeaderSet(PlanId='" + sPlanId + "')", { // Path to a specific entity
					urlParameters: {
						"$expand": "To_Item,To_Item/To_Volume"// Multiple navigation properties can be expanded, separated by commas
					},
					success: function (oData) {



						const oPlanHeaderModel = this.getOwnerComponent().getModel("PlanHeader");

						const oAppViewModel = this.getView().getModel("appView");
						let givenDate = new Date(oData.BuyingDateF);

						// Get today's date (without time for fair comparison)
						let today = new Date();
						today.setHours(0, 0, 0, 0);

						// Compare
						if (givenDate > today) {
							oAppViewModel.setProperty("/bSTEButton", true);

						}
						// Token mapping
						this._tokenMappings(oData);

						// Proceed only if To_Item and its results exist
						const aItems = oData?.To_Item?.results;
						if (Array.isArray(aItems) && aItems.length > 0) {
							if (aItems.length > 1) {
								var aPlanItems = aItems.slice(1);
								const result = aPlanItems
									.map(i => ({
										PlanId: i.PlanId,
										ItemNo: i.ItemNo,
										PlanItem: i.Matnr || i.Prodh || i.Brand,
										PlanItemDesc: i.MatnrDesc || i.ProdhDesc || i.BrandDesc
									}))
									.filter(i => i.PlanItem);

								// Add All option at first position
								result.unshift({
									PlanId: "",
									ItemNo: "All",
									PlanItem: "All",
									PlanItemDesc: "All"
								});


								oAppViewModel.setProperty("/PlanItems", result);
								const aVolumes = aItems[1]?.To_Volume?.results;
								if (Array.isArray(aVolumes) && aVolumes.length > 0) {
									this._volumeTableDynamicColumns(aVolumes[0]);
									this._volumeModel(aItems);
								}
							}










							oData.OrderDateF = this.parseDateOnlyToLocalMidnight(oData.OrderDateF);
							oData.OrderDateT = this.parseDateOnlyToLocalMidnight(oData.OrderDateT);
							oData.BuyingDateF = this.parseDateOnlyToLocalMidnight(oData.BuyingDateF);
							oData.BuyingDateT = this.parseDateOnlyToLocalMidnight(oData.BuyingDateT);
							oData.InstoreDateF = this.parseDateOnlyToLocalMidnight(oData.InstoreDateF);
							oData.InstoreDateT = this.parseDateOnlyToLocalMidnight(oData.InstoreDateT);
							if (aItems.length > 1) {
								oData.To_Item.results = this.cleanItemData(aItems);
							}
							oData.To_Item.results = this._insertSummaryRowEdit(oData.To_Item.results);
							oPlanHeaderModel.setData(oData);
							oPlanHeaderModel.refresh(true);
							// Load calendar
							const oToDate = formatter._getDateTimeInstance(oData.BuyingDateT);
							const oMonday = formatter._getDateTimeInstance(this.getMondayOfWeek(oData.BuyingDateF));
							this._loadCalendarSet(oMonday, oToDate);
							this.readSpendTactics(sPlanId);
							oPlanHeaderModel.refresh(true);
							this.updateSummaryRow();
							this.readPromoPNL(oPlanHeaderModel);


						}




					}.bind(this),
					error: function (oError) {
						// Handle error

					}
				});



			} catch (oError) {
				console.error("Failed to read Plan Header Set", oError);
			} finally {
				this.hideBusyIndicator();
			}
		},


		_validateSections: function (oController) {
			const isValidGenData = Validate.validateGeneralData(oController);
			const isValidPlanHeaderData = Validate.validatePlanHeaderData(oController);

			if (!isValidGenData && !isValidPlanHeaderData) {
				MessageBox.error("Mandatory fields are missing in both General Data and Plan Header sections.");
				oController._navigateToSection("idGeneralDataSection", oController);
				return false;
			} else if (!isValidGenData) {
				MessageBox.error("Mandatory fields are missing in the General Data section.");
				oController._navigateToSection("idGeneralDataSection", oController);
				return false;
			} else if (!isValidPlanHeaderData) {
				MessageBox.error("Mandatory fields are missing in the Plan Header section.");
				oController._navigateToSection("idPlanHeaderSection", oController);
				return false;
			}
			return true;
		},


		onPromoSectionChange: function (oEvent) {
			var oView = this.getView();
			const sTitle = oEvent.getParameter("section").getProperty("title");
			if (sTitle === "Planning") {
				if (oView.getModel("appView").getProperty("/EditMode") === true) {
					this._validateSections(this);

				}
				this.readFilteredSellingSKU();

				this.readSpendTactics();

			}

		},





		onOKSpendSetDialog: function (oEvent) {

			var oTreeTable = oEvent.getSource().getParent().getContent()[0];

			var aSelectedIndices = oTreeTable.getSelectedIndices();
			// If a row was deselected, there's nothing to do.
			if (aSelectedIndices.length === 0) {
				return;
			}

			var iSelectedIndex = aSelectedIndices[0];
			var oSelectedContext = oTreeTable.getContextByIndex(iSelectedIndex);
			var oSelectedObject = oSelectedContext.getObject();

			this._oSpendTacticMultiInput.removeAllTokens();

			const sKey = oSelectedObject.SpendType;
			const sText = oSelectedObject.Description;

			const oToken = new sap.m.Token({ key: sKey, text: sText });
			this._oSpendTacticMultiInput.addToken(oToken);

			var sFieldType = this._oSpendTacticMultiInput.data("valuehelp");

			const fieldMap = {
				SpendType1: { SpendTypeDesc: "SpendType1Desc", SpendTypeClass: "SpendTypeClass1", field: "SpendType1", tacticField: "Tactic1", spendAllocField: "SpendAlloc1", tacticDescField: "TacticDesc1", methodField: "SpendMethod1", discount: "/Discount1", discountAmount: "/DiscountAmt1" },
				SpendType2: { SpendTypeDesc: "SpendType2Desc", SpendTypeClass: "SpendTypeClass2", field: "SpendType2", tacticField: "Tactic2", spendAllocField: "SpendAlloc2", tacticDescField: "TacticDesc2", methodField: "SpendMethod2", discount: "/Discount2", discountAmount: "/DiscountAmt2" },
				SpendType3: { SpendTypeDesc: "SpendType3Desc", SpendTypeClass: "SpendTypeClass3", field: "SpendType3", tacticField: "Tactic3", spendAllocField: "SpendAlloc3", tacticDescField: "TacticDesc3", methodField: "SpendMethod3", discount: "/Discount3", discountAmount: "/DiscountAmt3" },
				SpendType4: { SpendTypeDesc: "SpendType4Desc", SpendTypeClass: "SpendTypeClass4", field: "SpendType4", tacticField: "Tactic4", spendAllocField: "SpendAlloc4", tacticDescField: "TacticDesc4", methodField: "SpendMethod4", discount: "/Discount4", discountAmount: "/DiscountAmt4" },
				SpendType5: { SpendTypeDesc: "SpendType5Desc", SpendTypeClass: "SpendTypeClass5", field: "SpendType5", tacticField: "Tactic5", spendAllocField: "SpendAlloc5", tacticDescField: "TacticDesc5", methodField: "SpendMethod5", discount: "/Discount5", discountAmount: "/DiscountAmt5" }
			};

			const config = fieldMap[sFieldType];

			const sPath = this._oSpendTacticMultiInput.getBindingContext("PlanHeader").getPath();



			const oAppViewModel = this.getView().getModel("appView");

			// Enable Discount1 if SpendType1 is "%"
			const enableDiscount = oSelectedObject.SpendMethod === "%";
			oAppViewModel.setProperty(config.discount, enableDiscount);

			// Enable DiscountAmt if SpendType1 is "$", "F", or "P"
			const enableDiscountAmt = ["$", "F", "P"].includes(oSelectedObject.SpendMethod);
			oAppViewModel.setProperty(config.discountAmount, enableDiscountAmt);


			const oPlanHeaderModel = this.getView().getModel("PlanHeader");
			const aItems = oPlanHeaderModel.getProperty("/To_Item/results");
			const nLineLength = aItems.length;



			for (let i = 0; i < nLineLength; i++) {
				const basePath = `/To_Item/results/${i}`;

				oPlanHeaderModel.setProperty(`${basePath}/${config.field}`, oSelectedObject.SpendType);

				oPlanHeaderModel.setProperty(`${basePath}/${config.methodField}`, oSelectedObject.SpendMethod);
				oPlanHeaderModel.setProperty(`${basePath}/${config.tacticField}`, oSelectedObject.TacticId);
				oPlanHeaderModel.setProperty(`${basePath}/${config.tacticDescField}`, oSelectedObject.TDesc);
				oPlanHeaderModel.setProperty(`${basePath}/${config.spendAllocField}`, oSelectedObject.SpendAlloc);
				oPlanHeaderModel.setProperty(`${basePath}/${config.SpendTypeClass}`, oSelectedObject.SpendTypeClass);
				oPlanHeaderModel.setProperty(`${basePath}/${config.SpendTypeDesc}`, oSelectedObject.Description);







			}
			oPlanHeaderModel.refresh(true);


			if (this._oValueHelpDialog) {
				this._oValueHelpDialog.then(function (oDialog) {
					oDialog.close();
				});
			}
			//that._oRowContext = this._oSpendTacticMultiInput.getBindingContext("PromoPlan");



		},
		onRowSpendSelectionChange: function (oEvent) {
			var oTreeTable = oEvent.getSource();
			var aSelectedIndices = oTreeTable.getSelectedIndices();

			// If a row was deselected, there's nothing to do.
			if (aSelectedIndices.length === 0) {
				return;
			}

			var iSelectedIndex = aSelectedIndices[0];
			var oSelectedContext = oTreeTable.getContextByIndex(iSelectedIndex);
			var oSelectedObject = oSelectedContext.getObject();


			if (!oSelectedObject.isLeaf) {
				// Deselect the row immediately
				oTreeTable.removeSelectionInterval(iSelectedIndex, iSelectedIndex);
				// Optional: Provide feedback to the user
				sap.m.MessageToast.show("Only child items can be selected.");
			}
		},
		onCloseSpendSetDialog: function (oEvent) {

			if (this._oValueHelpDialog) {
				this._oValueHelpDialog.then(function (oDialog) {
					oDialog.close();
				});
			}

		},
		onOISpendValueHelp: function (oEvent) {

			this._oSpendTacticMultiInput = oEvent.getSource();


			if (!this._oValueHelpDialog) {
				this._oValueHelpDialog = sap.ui.core.Fragment.load({
					id: this.getView().getId(),
					name: "com.kcc.promoplan.fragments.Valuehelp.SpendTacticsVH",
					controller: this
				}).then(function (oDialog) {
					this.getView().addDependent(oDialog);
					oDialog.open();
					return oDialog;
				}.bind(this));
			} else {
				this._oValueHelpDialog.then(function (oDialog) {
					oDialog.open();
				});
			}

		},

		sumByPromoted: function (promotedValue, data) {
			const filtered = data.filter(item => item.Promoted === promotedValue);
			const result = {};

			filtered.forEach(item => {
				for (const key in item) {
					if (["Promoted", "Yearweek", "ItemNo", "PlanId", "Week"].includes(key)) continue;
					if (isNaN(Number(item[key]))) continue;

					result[key] = (result[key] || 0) + Number(item[key]);
				}
			});

			return result;

		},

		onSelectionChange: function (oEvent) {

			var oPlanHeaderModel = this.getView().getModel("PlanHeader");




			var oMCB = oEvent.getSource();
			var sKey = oEvent.getParameter("changedItem").getKey();
			var bSelected = oEvent.getParameter("selected");

			// If "All" item changed
			if (sKey === "All") {

				if (bSelected) {
					// Select all items
					var aAllKeys = oMCB.getItems().map(function (oItem) {
						return oItem.getKey();
					});
					oMCB.setSelectedKeys(aAllKeys);
				} else {
					// Unselect all
					oMCB.setSelectedKeys([]);
				}

			} else {

				var aKeys = oMCB.getSelectedKeys().filter(function (k) {
					return k !== "All";
				});
				oMCB.setSelectedKeys(aKeys);

			}

			this.readPromoPNL(oPlanHeaderModel);

		},

		readPromoPNL: function (oPlanHeaderModel) {

			var oView = this.getView();
			var oModel = oView.getModel("PromoPlan"); // OData model

			var sPlanId = oView.getModel("PlanHeader").getProperty("/PlanId");

			var aItemKeys = this.byId("planItemCombo").getSelectedKeys();
			var aWeekKeys = this.byId("weekCombo").getSelectedKeys();




			if (aItemKeys.length === 0 && aWeekKeys.length === 0) {
				sap.m.MessageBox.warning("Plan Item and Week should be selected");
				return;
			}

			if (aItemKeys.length === 0) {
				sap.m.MessageBox.warning("Please select Plan Item");
				return;
			}

			if (aWeekKeys.length === 0) {
				sap.m.MessageBox.warning("Please select Week");
				return;
			}

			var aFilters = [];

			// Always add PlanId
			aFilters.push(
				new sap.ui.model.Filter(
					"PlanId",
					sap.ui.model.FilterOperator.EQ,
					sPlanId
				)
			);


			// Item filters
			if (aItemKeys && !aItemKeys.includes("All")) {

				var aItemFilters = [];

				aItemKeys.forEach(function (sItem) {
					aItemFilters.push(
						new sap.ui.model.Filter(
							"ItemNo",
							sap.ui.model.FilterOperator.EQ,
							sItem
						)
					);
				});

				aFilters.push(new sap.ui.model.Filter({
					filters: aItemFilters,
					and: false   // OR condition
				}));
			}
			if (aWeekKeys && !aWeekKeys.includes("All")) {

				var aWeekFilters = [];

				aWeekKeys.forEach(function (sWeek) {
					aWeekFilters.push(
						new sap.ui.model.Filter(
							"Yearweek",
							sap.ui.model.FilterOperator.EQ,
							sWeek
						)
					);
				});

				aFilters.push(new sap.ui.model.Filter({
					filters: aWeekFilters,
					and: false   // OR condition
				}));
			}

			var that = this;

			// -------- PROMO PNL --------
			oModel.read("/ZCDS_TP4_PROMOPNL", {
				filters: aFilters,
				success: function (oData) {




					// Aggregate sums
					const sumN = that.sumByPromoted("N", oData.results); // Non-Promoted
					const sumY = that.sumByPromoted("Y", oData.results); // Promoted

					// Map of field descriptions
					const fieldDescriptions = {
						Volume: "Volume",
						Uom: "UOM",
						Price: "List Price",
						GrossSales: "Basic Gross Sales",						
						EdlpDiscount: "EDLP Discount",						
						TpDiscoOi: "TP OI Discount",
						CpDiscOi: "CP OI Discount",
						LogisticDiscOi: "Logistic OI Discount",
						FinancialDiscOi: "Financial OI Discount",
						OthersOi: "Other OI Discount",
						Niv: "NIV",
						LtaDiscDef: "LTA Deffered Discount",
						TpDiscDef: "TP Deffered Discount",
						CpDiscDef: "CP Deffered Discount",
						LogisticDiscDef: "Logistic Deffered discount",
						FinancialDiscDef: "Financial deffered discount",
						OthersDef: "Other Deffered",
						NetSales: "Net Sales",
						Cogs: "COGS",
						Distribution: "DISTRIBUTION",
						GrossProfit: "Gross Profit",
						Profit: "Profit",
						TradeSpend: "Trade Spend",   
						RetailPrice: "Retailer Price",
						RetailSales: "Retailer Sales",
						RetailInvestment: "Retail Investment",
						RetailMargin: "Retail Margin $",
						RetailMarginPrc: "Retail Margin %"

					};

				 

					const finalArray = Object.keys(fieldDescriptions).map(field => {

						if (field !== "Uom") {
							const N = sumN[field] || 0;
							const Y = sumY[field] || 0;
							const D = Y - N;

							return {
								name: fieldDescriptions[field] || "",
								N: N,
								Y: Y,
								D: (D % 1 !== 0) ? Number(D).toFixed(2) : Number(D).toFixed(0)
							};
						}
						else {

							return {
								name: fieldDescriptions[field] || "",
								N: sumN[field],
								Y: sumY[field],
								D: sumY[field]
							};

						}
					});

 
					// Helper to get D value by name
const getDValue = (label) => {
    const item = finalArray.find(obj => obj.name === label);
    return item ? parseFloat(item.D) || 0 : 0;
};

// Calculate ROI using D values from finalArray
const grossProfitD = getDValue("Gross Profit");

const denominatorD =
    getDValue("TP OI Discount") +
    getDValue("CP OI Discount") +
    getDValue("TP Deffered Discount") +
    getDValue("CP Deffered Discount");

const roiD = grossProfitD / denominatorD;

// ROI object
const roiRow = {
    name: "ROI",
    N: "",
    Y: "",
    D: isFinite(roiD) ? roiD.toFixed(2) : "0"
};

// 👉 Find index of "Retailer Price"
const insertIndex = finalArray.findIndex(item => item.name === "Retailer Price");

// 👉 Insert ROI before it
if (insertIndex !== -1) {
    finalArray.splice(insertIndex, 0, roiRow);
} else {
    // fallback if not found
    finalArray.push(roiRow);
}

					that.getView()
						.getModel("appView")
						.setProperty("/PromoPNL", finalArray);

				},
				error: function (oError) {

				}
			});

			// -------- PROMO ROI --------
			oModel.read("/ZCDS_TP4_PROMOROI", {
				filters: aFilters,
				success: function (oData) {

					const result = Object.values(
						oData.results.reduce((acc, item) => {
							const weekNo = parseInt(item.Yearweek.slice(-2));

							if (!acc[weekNo]) {
								acc[weekNo] = {
									Week: `Week ${weekNo}`,
									ROI: 0,
									Uplift: 0,
									Baseline: 0
								};
							}

							acc[weekNo].ROI += Number(item.Roi || 0);
							acc[weekNo].Uplift += Number(item.Uplift || 0);
							acc[weekNo].Baseline += Number(item.Baseline || 0);

							return acc;
						}, {})
					);




					that.getView()
						.getModel("appView")
						.setProperty("/PromoROI", result);

				},
				error: function (oError) {
					console.error("ROI read failed", oError);
				}
			});

		},


		readSpendTactics: function (sPlanId) {
			const oView = this.getView();
			const oModel = oView.getModel("PromoPlan");
			const sVkorg = oView.getModel("PlanHeader").getProperty("/Vkorg");
			const sVtweg = oView.getModel("PlanHeader").getProperty("/Vtweg");
			const sPlanType = oView.getModel("PlanHeader").getProperty("/PlanType");
			const aFilters = [
				new sap.ui.model.Filter("Vkorg", "EQ", sVkorg),
				new sap.ui.model.Filter("Vtweg", "EQ", sVtweg),
				new sap.ui.model.Filter("PlanType", "EQ", sPlanType)
			];
			var that = this;
			oModel.read("/SpendSet", {
				filters: aFilters,
				success: function (oData) {

					// Group by TacticId
					var treeData = [];
					var tacticMap = {};

					oData.results.forEach(function (item) {
						if (!tacticMap[item.TacticId]) {
							tacticMap[item.TacticId] = {
								TacticDesc: item.TacticId + " - " + item.TacticsDesc,
								isLeaf: false,
								children: []
							};
							treeData.push(tacticMap[item.TacticId]);
						}
						tacticMap[item.TacticId].children.push({
							SpendType: item.SpendType,
							isLeaf: true,
							SpendAlloc: item.SpendAlloc,
							SpendTypeClass: item.SpendTypeClass,
							TacticId: item.TacticId,
							TDesc: item.TacticsDesc,
							SpendMethod: item.SpendMethod,
							Description: item.Description
						});
					});


					oView.getModel("appView").setProperty("/Tactics", treeData);
					if (treeData.length > 0 && sPlanId) {
						const oPlanHeaderModel = oView.getModel("PlanHeader");
						const aItems = oPlanHeaderModel.getProperty("/To_Item/results");
						var oFirstRowData = aItems[0];

						for (let i = 1; i <= 5; i++) {


							const spendTypeValue = oFirstRowData[`SpendType${i}`];

							const tacticId = oFirstRowData[`Tactic${i}`];

							const SpendTypeClassKey = `SpendTypeClass${i}`;


							let SpendTypeClass = "";

							for (let j = 0; j < treeData.length; j++) {
								const aChildren = treeData[j].children || [];
								for (let k = 0; k < aChildren.length; k++) {
									const child = aChildren[k];
									if (child.SpendType === spendTypeValue && child.TacticId === tacticId) {

										SpendTypeClass = child.SpendTypeClass;
										break;
									}
								}

							}



							aItems.forEach(function (item) {


								item[SpendTypeClassKey] = SpendTypeClass;
							});
						}

						oPlanHeaderModel.setProperty("/To_Item/results", aItems);
						that.updateSummaryRow();
					}


				},
				error: function (oError) {
					console.error("Failed to read SpenSet:", oError);
				}
			});
		},


		readFilteredSellingSKU: function () {
			const oView = this.getView();
			const oModel = oView.getModel("PromoPlan");

			const sVkorg = oView.getModel("PlanHeader").getProperty("/Vkorg");
			const sVtweg = oView.getModel("PlanHeader").getProperty("/Vtweg");

			const aFilters = [
				new sap.ui.model.Filter("Vkorg", "EQ", sVkorg),
				new sap.ui.model.Filter("Vtweg", "EQ", sVtweg)
			];

			oModel.read("/SellingSKUSet", {
				filters: aFilters,
				success: function (oData) {
					const oFilteredModel = new JSONModel({ SellingSKUSet: oData.results });
					oFilteredModel.setSizeLimit(oData.results.length);
					oView.setModel(oFilteredModel, "FilteredSellingSKU");
				},
				error: function (oError) {
					console.error("Failed to read SellingSKUSet:", oError);
				}
			});
		},

		readSalesArea: function () {

			const oView = this.getView();
			const oModel = this.getOwnerComponent().getModel("PromoPlan");


			const aFilters = [
				new sap.ui.model.Filter("f4_ind", "EQ", "C")
			];

			oModel.read("/SalesAreaSet", {
				filters: aFilters,
				success: function (oData) {
					const oSalesAreaModel = new JSONModel({ SalesAreaSet: oData.results });
					oSalesAreaModel.setSizeLimit(oData.results.length);
					oView.setModel(oSalesAreaModel, "SalesArea");
				},
				error: function (oError) {
					console.error("Failed to read SalesArea:", oError);
				}
			});

		},
		readDishChannel: function () {

			const oView = this.getView();
			const oModel = this.getOwnerComponent().getModel("PromoPlan");


			const aFilters = [
				new sap.ui.model.Filter("f4_ind", "EQ", "C")
			];

			oModel.read("/DistChSet", {
				filters: aFilters,
				success: function (oData) {
					const oDishChanModel = new JSONModel({ DistChSet: oData.results });
					oDishChanModel.setSizeLimit(oData.results.length);
					oView.setModel(oDishChanModel, "DistChan");
				},
				error: function (oError) {
					console.error("Failed to read DistChSet:", oError);
				}
			});

		},

		_getMessagePopover: function () {
			return this.loadFragment({
				name: "com.kcc.promoplan.fragments.ErrorMessagePopOver"
			});
		},

		handleMessageViewPress: async function (oEvent) {
			const oSourceControl = oEvent.getSource();
			const oMessagePopover = await this._getMessagePopover();
			oMessagePopover.openBy(oSourceControl);
		},
		onStopEarlyPress: function (oEvent) {
			this._handleStatusUpdate("SREQ");

		},

		onCancelRequested: function (oEvent) {
			this._handleStatusUpdate("CREQ");

		},

		onClosePress: function (oEvent) {
			this._handleStatusUpdate("CLOS");

		},
		_handleStatusUpdate: function (sStatus) {
			this.showBusyIndicator();

			const oPlanHeaderModel = this.getView().getModel("PlanHeader");

			var sPlanId = oPlanHeaderModel.getData().PlanId;

			var that = this;

			const oODataModel = this.getView().getModel();
			var oURLParameters = {
				"PlanId": sPlanId,
				"Status": sStatus
			};


			oODataModel.callFunction("/Promo_Button", {
				method: "POST",
				urlParameters: oURLParameters,
				success: function (oData, response) {
					that.hideBusyIndicator();
					that.setPromoPlanMode("view");
					that._loadPromoPlanById(sPlanId);
					console.log("Function import successful", oData);
					that.getRouter().navTo("PromoPlanDetail", { id: sPlanId }, true);
					that._navigateToSection("idGeneralDataSection", this);

				}.bind(this),
				error: function (oError) {
					that.hideBusyIndicator();
					try {
						const oResponse = JSON.parse(oError.responseText);
						sErrorMessage = oResponse?.error?.message?.value || sErrorMessage;
					} catch (e) {
						sErrorMessage = oError.message || sErrorMessage;
					}

					that.showMessageBox("Error", sErrorMessage, "Error");


				}
			});
		},

		onRelAccuralPress: function (oEvent) {
			this._handlePlanHeader("update", "SREQ");

		},
		onSavePress: function () {
			if (this._validateSections(this)) {
				this._handlePlanHeader("update");
			}
			else {
				this.getView().getModel("appView").setProperty("/ErrorBtnVisible", true);
			}
		},

		onSubmitPress: function () {
			if (this._validateSections(this)) {
				this._handlePlanHeader("create");
			}
			else {
				this.getView().getModel("appView").setProperty("/ErrorBtnVisible", true);

			}
		},

		_handlePlanHeader: function (mode, sStatus) {
			this.showBusyIndicator();

			const oPlanHeaderModel = this.getView().getModel("PlanHeader");
			const oVolumeModel = this.getView().getModel("VolumeModel");
			const oDeletedOIModel = this.getOwnerComponent().getModel("DeletedPlanningOI");
			const oPlanHeaderData = oPlanHeaderModel.getData();
			const oVolumeModelData = oVolumeModel.getData();
			const aActiveItems = oPlanHeaderData.To_Item.results;

			//const aActiveItems = oPlanHeaderData?.To_Item?.results?.slice(1) || [];
			const aDeletedItems = oDeletedOIModel?.getData() || [];

			// Clean up data

			// Fields to convert dynamically
			const fieldsToConvert = [
				'VolumePlanned', 'Uplift', 'Baseline', 'DiscountEdlp', 'Niv', 'Cogs', 'Tax', 'Ppc', 'Nsv',
				'RetailMargin', 'RetailMarginPrc', 'Sales', 'SalesPlanned', 'Trade', 'Profit', 'ListPrice',
				'DiscountAmt1', 'DiscountAmt2', 'DiscountAmt3', 'DiscountAmt4', 'DiscountAmt5',
				'Discount1', 'Discount2', 'Discount3', 'Discount4', 'Discount5', 'Dcost',
				'FinancialDefCost', 'FinancialOiCost', 'LogisticDefCost', 'LogisticOiCost',
				'OtherDefCost', 'OtherOiCost', 'LtaDef', 'NetCost', 'RegularPrice', 'RetailPrice',
				'SpendPlanned', 'SpendPlannedBb', 'SpendPlannedLs', 'SpendPlannedOi'
			];
const discountFields = [
    'DiscountAmt1', 'DiscountAmt2', 'DiscountAmt3', 'DiscountAmt4', 'DiscountAmt5',
    'Discount1', 'Discount2', 'Discount3', 'Discount4', 'Discount5'
];
			const aItemData = [...aActiveItems, ...aDeletedItems].map(item => {
				const { IsSummary, SpendAlloc1, SpendAlloc2, SpendAlloc3, SpendAlloc4, SpendAlloc5, SpendTypeClass1, SpendTypeClass2, SpendTypeClass3, SpendTypeClass4, SpendTypeClass5,
					TacticDesc1, TacticDesc2, TacticDesc3, TacticDesc4, TacticDesc5, To_Volume, ...cleanedItem } = item;

				// Convert all specified fields to string if they exist
				fieldsToConvert.forEach(field => {
					  let value = cleanedItem[field];

        // Handle discount fields: "" → "0"
        if (discountFields.includes(field)) {
            if (value === "" || value === null || value === undefined) {
                cleanedItem[field] = "0";
                return;
            }
        }
					if (cleanedItem[field] !== undefined && cleanedItem[field] !== null) {
						cleanedItem[field] = cleanedItem[field].toString();
					}
				});

				return cleanedItem;
			});


			// Ensure 0th row values are set
			if (aItemData?.[0]) {
				aItemData[0].Ppc = '0';
				aItemData[0].LtaDef = '0';
			}



			const aCleanedVolumeData = oVolumeModelData.map(vol => {
				const { Total, ...cleanedVol } = vol;

				// Convert WeekVol1 to WeekVol65 to string if they exist
				for (let week = 1; week <= 65; week++) {
					const key = `WeekVol${week}`;
					if (cleanedVol[key] !== undefined && cleanedVol[key] !== null) {
						cleanedVol[key] = cleanedVol[key].toString();
					}
				}

				return cleanedVol;
			});

			const oMultiInputValues = Helper.getMultiInputValues(this);
			const oDateValues = Helper.getDateRangeValues(this);
			if (sStatus) {
				oMultiInputValues.Status = sStatus;
			}
			const oHeaderBase = {
				PlanCustomer: oPlanHeaderData.PlanCustomer,
				Description: oPlanHeaderData.Description,
				ContractId: oPlanHeaderData.ContractId,
				PlanClass: oPlanHeaderData.PlanClass,
				ProductSelection: oPlanHeaderData.ProductSelection,
				Prodh: oPlanHeaderData.Prodh,
				Brand: oPlanHeaderData.Brand,
				Subbrand: oPlanHeaderData.Subbrand,
				To_Item: aItemData,
				To_Volume: aCleanedVolumeData
			};

			if (mode === "update") {
				oHeaderBase.PlanId = oPlanHeaderData.PlanId;
			}

			const oPayload = {
				...oHeaderBase,
				...oMultiInputValues,
				...oDateValues
			};
			var that = this;
			const oODataModel = this.getView().getModel();
			oODataModel.create("/Plan_HeaderSet", oPayload, {
				success: (oData) => {
					that.hideBusyIndicator();
					that.setPromoPlanMode("view");
					that._loadPromoPlanById(oData.PlanId);
					const sMessage = mode === "create"
						? `Plan created successfully with ID: ${oData.PlanId}`
						: "Plan Header updated successfully";

					MessageBox.success(sMessage, {
						title: "Success",
						onClose: () => {

							const sId = mode === "create" ? oData.PlanId : oPlanHeaderData.PlanId;
							that.getRouter().navTo("PromoPlanDetail", { id: sId }, true);
							that._navigateToSection("idGeneralDataSection", this);
						}
					});
				},
				error: (oError) => {
					that.hideBusyIndicator();
					let sErrorMessage = mode === "create"
						? "Error creating Plan Header."
						: "Error updating Plan Header.";

					try {
						const oResponse = JSON.parse(oError.responseText);
						sErrorMessage = oResponse?.error?.message?.value || sErrorMessage;
					} catch (e) {
						sErrorMessage = oError.message || sErrorMessage;
					}

					that.showMessageBox("Error", sErrorMessage, "Error");
				}
			});
		},

		_validateDecimals: function (oEvent, nDigit, nDecimal) {


			var oInput = oEvent.getSource();
			var s = oEvent.getParameter("value") || "";

			// Keep only digits and dots
			s = s.replace(/[^0-9.]/g, "");

			// Keep only the first dot
			var firstDot = s.indexOf(".");
			if (firstDot !== -1) {
				s = s.slice(0, firstDot + 1) + s.slice(firstDot + 1).replace(/\./g, "");
			}

			// Split and trim
			var parts = s.split(".");
			var intPart = parts[0] || "";
			var decPart = parts[1] || "";

			intPart = intPart.slice(0, 11); // <= 11 digits before dot
			decPart = decPart.slice(0, 2);  // <= 2 digits after dot

			var newVal = (firstDot !== -1) ? (intPart + "." + decPart) : intPart;

			oInput.setValue(newVal);

			// Soft validation during typing
			var ok = newVal === "" || /^\d{0,11}(?:\.\d{0,2})?$/.test(newVal);
			oInput.setValueState(ok ? sap.ui.core.ValueState.None : sap.ui.core.ValueState.Warning);
			oInput.setValueStateText(ok ? "" : "Up to 11 digits before the dot and up to 2 decimals.");
		},

		onDecChange_11BeforeDot: function (oEvent) {
			var oInput = oEvent.getSource();
			var v = (oInput.getValue() || "").trim();

			if (v.startsWith(".")) v = "0" + v; // normalize .5 -> 0.5

			var finalRegex = /^\d{1,11}(?:\.\d{1,2})?$/;
			var valid = v === "" ? true : finalRegex.test(v);

			if (!valid) {
				oInput.setValueState(sap.ui.core.ValueState.Error);
				oInput.setValueStateText("Enter up to 11 digits before the dot and up to 2 decimals.");
			} else {
				oInput.setValueState(sap.ui.core.ValueState.None);
				oInput.setValue(v);
			}


			return valid;


		},
		onUpliftChange: function (oEvent) {
			var bValid = this._validateDecimals(oEvent);
			var oInput = oEvent.getSource();
			var sValue = oEvent.getParameter("value");


			if (!/^-?\d+$/.test(sValue)) {

				oInput.setValueState("Error");

				oInput.setValueStateText("Please enter a valid integer.");

			} else {
				oInput.setValueState("None");
				oInput.setValueStateText("");

				var oContext = oInput.getBindingContext("PlanHeader");
				var oModel = oContext.getModel();
				var oPath = oContext.getPath();
				var itemNo = oContext.getObject().ItemNo;


				var baseline = parseFloat(oModel.getProperty(oPath + "/Baseline")) || 0;
				var uplift = parseFloat(oModel.getProperty(oPath + "/Uplift")) || 0;

				var volumePlanned = baseline + uplift;

				// Split values across weeks
				//this._splitVolumeAcrossWeeks("B", itemNo, baseline);
				this._splitVolumeAcrossWeeks("U", itemNo, uplift);
				this._splitVolumeAcrossWeeks("P", itemNo, volumePlanned);

				oModel.setProperty(oPath + "/VolumePlanned", volumePlanned.toString());

				var nNetCost = parseFloat(oModel.getProperty(oPath + "/NetCost")) || 0;

				var nTotalSales = nNetCost * volumePlanned;
				oModel.setProperty(oPath + "/SalesPlanned", nTotalSales.toString());


			}

			this.updateSummaryRow();

		},

		onBaselineChange: function (oEvent) {
			var bValid = this._validateDecimals(oEvent);
			var oInput = oEvent.getSource();
			var sValue = oEvent.getParameter("value");


			if (!/^-?\d+$/.test(sValue)) {

				oInput.setValueState("Error");

				oInput.setValueStateText("Please enter a valid integer.");

			} else {
				oInput.setValueState("None");
				oInput.setValueStateText("");

				var oContext = oInput.getBindingContext("PlanHeader");
				var oModel = oContext.getModel();
				var oPath = oContext.getPath();
				var itemNo = oContext.getObject().ItemNo;


				var baseline = parseFloat(oModel.getProperty(oPath + "/Baseline")) || 0;
				var uplift = parseFloat(oModel.getProperty(oPath + "/Uplift")) || 0;

				var volumePlanned = baseline + uplift;

				// Split values across weeks
				this._splitVolumeAcrossWeeks("B", itemNo, baseline);
				//this._splitVolumeAcrossWeeks("U", itemNo, uplift);
				this._splitVolumeAcrossWeeks("P", itemNo, volumePlanned);

				oModel.setProperty(oPath + "/VolumePlanned", volumePlanned.toString());

				var nNetCost = parseFloat(oModel.getProperty(oPath + "/NetCost")) || 0;

				var nTotalSales = nNetCost * volumePlanned;
				oModel.setProperty(oPath + "/SalesPlanned", nTotalSales.toString());


			}

			this.updateSummaryRow();

		},

		_splitVolumeAcrossWeeks: function (volType, itemNo, totalValue) {
			const oModel = this.getView().getModel("VolumeModel");
			const aData = oModel.getProperty("/");
			const aCalendarData = this.getView().getModel("appView").getProperty("/CalendarData");

			const aVisibleWeeks = [...new Set(aCalendarData.map(d => parseInt(d.ScreenCol)))].sort((a, b) => a - b);

			const iTotal = parseInt(totalValue, 10);
			if (isNaN(iTotal) || aVisibleWeeks.length === 0) return;

			const iWeekCount = aVisibleWeeks.length;
			const iBaseValue = Math.ceil(iTotal / iWeekCount); // ensures last week is smaller
			var iLastWeekValue = iTotal - iBaseValue * (iWeekCount - 1);

			// ✅ Ensure last week value is not negative
			if (iLastWeekValue < 0) {
				iLastWeekValue = 0;
			}

			var nOfWeeks = Math.ceil(iTotal / iBaseValue);

			aData.forEach(row => {
				if (row.VolType === volType && row.ItemNo === itemNo) {
					aVisibleWeeks.forEach((weekIndex, idx) => {
						const sWeekKey = "WeekVol" + weekIndex;
						var iWeekValue = 0;
						if (nOfWeeks >= (idx + 1)) {
							iWeekValue = (idx === iWeekCount - 1) ? iLastWeekValue : iBaseValue;
						}
						row[sWeekKey] = iWeekValue.toString();
					});

					row.Total = iTotal.toString();
				}
			});

			oModel.refresh(true);
		},

		onListPriceOrVolumeChange: function (oEvent) {
			var oInput = oEvent.getSource();
			var sValue = oEvent.getParameter("value");

			// Regex to allow numbers with up to two decimal places
			var regex = /^\d+(\.\d{0,2})?$/;

			if (!regex.test(sValue)) {
				oInput.setValueState("Error");
			} else {
				oInput.setValueState("None");


				var oContext = oInput.getBindingContext("PlanHeader");
				var oModel = oContext.getModel();
				var oPath = oContext.getPath();

				var listPrice = parseFloat(oModel.getProperty(oPath + "/ListPrice")) || 0;
				//var volumePlanned = parseFloat(oModel.getProperty(oPath + "/VolumePlanned")) || 0;
				var nNetCost = parseFloat(oModel.getProperty(oPath + "/NetCost")) || 0;

				//var salesPlanned = listPrice * volumePlanned;
				//oModel.setProperty(oPath + "/SalesPlanned", salesPlanned.toString());

				var edlpDiscount = listPrice - nNetCost;
				oModel.setProperty(oPath + "/DiscountEdlp", edlpDiscount.toString());


			}
			this.updateSummaryRow();
		},

		onSalesCostChange: function (oEvent) {
			var oInput = oEvent.getSource();
			var sValue = oEvent.getParameter("value");

			// Regex to allow numbers with up to two decimal places
			var regex = /^\d+(\.\d{0,2})?$/;

			if (!regex.test(sValue)) {
				oInput.setValueState("Error");
			} else {
				oInput.setValueState("None");


				var oContext = oInput.getBindingContext("PlanHeader");
				var oModel = oContext.getModel();
				var oPath = oContext.getPath();

				var listPrice = parseFloat(oModel.getProperty(oPath + "/ListPrice")) || 0;
				var nNetCost = parseFloat(oModel.getProperty(oPath + "/NetCost")) || 0;
				var nVolumePlanned = parseFloat(oModel.getProperty(oPath + "/VolumePlanned")) || 0;



				var edlpDiscount = listPrice - nNetCost;
				var nTotalSales = nNetCost * nVolumePlanned;
				oModel.setProperty(oPath + "/DiscountEdlp", edlpDiscount.toString());
				oModel.setProperty(oPath + "/SalesPlanned", nTotalSales.toString());



			}
			this.updateSummaryRow();

		},


		onObectiveVH: function () {

			FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.ObjectiveVH", "idObjectiveID", "C");
		},

		onProductSelectionVH: function () {

			FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.ProductSelection", "idProductSelectionID", "C");
		},


		onSellingSKUVH: function () {

			FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.TacticsVH", "idTacticsID", "C");
		},

		onMultiOneTokenRestrictPlanType: function (oEvent) {
			const isValid = Validate.validateSalesAndDisChan(this);
			if (isValid) {
				var oMultiInput = oEvent.getSource();
				var aTokens = oMultiInput.getTokens();

				if (aTokens.length >= 1) {
					oMultiInput.setValue(""); // Prevent typing
				}
			}
			else {
				oEvent.getSource().removeAllTokens();
				var oPromoPlanType = oEvent.getSource();
				oPromoPlanType.setValue("");
				var sMessage = "Please select both Sales Organization and Distribution Channel before choosing a Promotion Plan Type.";
				this.showMessageBox("error", sMessage, "Error");
				oPromoPlanType.setValueState("Error");
				oPromoPlanType.setValueStateText(sMessage);

			}
		},

		onPromoPlanTypeVH: function (oEvent) {
			oEvent.getSource().setSelectedItem(null);
			const isValid = Validate.validateSalesAndDisChan(this);
			if (isValid) {
				FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.PromoPlanTypeGDVH", "idPromoPlanTypeID", "C");
			}
			else {

				var oPromoPlanType = this.byId("idPromoPlanTypeID");
				var sMessage = "Please select both Sales Organization and Distribution Channel before choosing a Promotion Plan Type.";
				this.showMessageBox("error", sMessage, "Error");
				oPromoPlanType.setValueState("Error");
				oPromoPlanType.setValueStateText(sMessage);

			}
		},
		onStatusGDVH: function (oEvent) {
			//oEvent.getSource().setSelectedItem(null);
			FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.StatusGDVH", "idStatusVHCreateID", "C");
		},
		onSalesAreaGDVH: function (oEvent) {

			oEvent.getSource().setSelectedItem(null);
			FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.SalesAreaGDVH", "idSalesAreaGDVHID", "C");
		},
		onSalesOrgGDVH: function (oEvent) {
			oEvent.getSource().setSelectedItem(null);

			FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.SalesOrgGDVH", "idSalesOrgGDVHID", "C");
		},

		onDistChanGDVH: function (oEvent) {
			oEvent.getSource().setSelectedItem(null);
			FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.DistributionChannelVH", "idDistChanGDVHID", "C");
		},
		onFundPlanVH: function (oEvent) {

			FragmentHelper.openValueHelpDialog(this, "com.kcc.promoplan.fragments.Valuehelp.FundPlanVH", "idFundPlanVHID", "C");
		},

		generalDataVHValidation: async function (oEvent) {
			const sType = oEvent.getParameter("type");
			const oMultiInput = oEvent.getSource();
			const sId = oMultiInput.getId();
			const oPlanHeaderModel = this.getView().getModel("PlanHeader");

			const fieldMap = {
				"idSalesOrgGDVHID": { key: "/Vkorg", text: "/VkorgDesc" },
				"idDistChanGDVHID": { key: "/Vtweg", text: "/VtwegDesc" },
				"idPromoPlanTypeID": { key: "/PlanType", text: "/PlanTypeDesc" },
				"idStatusVHCreateID": { key: "/Status", text: "/StatusDesc" },
				"idFundPlanVHID": { key: "/FundPlan", text: "/FundPlanDesc" },
				"idSalesAreaGDVHID": { key: "/Sa_Id", text: "/SaName" }
			};

			// Find matching field config
			const matchedKey = Object.keys(fieldMap).find(key => sId.includes(key));
			const fieldConfig = fieldMap[matchedKey];

			if (!fieldConfig) {
				console.warn("No matching field config found for:", sId);
				return;
			}

			if (sType === "removed") {
				const aRemovedTokens = oEvent.getParameter("removedTokens");
				aRemovedTokens.forEach(oToken => oMultiInput.removeToken(oToken));
				if (matchedKey === "idPromoPlanTypeID") {
					oPlanHeaderModel.setProperty("/PlanClass", "");

				}

				if (oMultiInput.getTokens().length === 0) {
					oPlanHeaderModel.setProperty(fieldConfig.key, "");
					oPlanHeaderModel.setProperty(fieldConfig.text, "");
				}
			} else {
				const aTokens = oMultiInput.getTokens();

				const targetId = oEvent.getSource().getSelectedItem();
				var aItems = oEvent.getSource().getSuggestionItems();


				const foundItem = aItems.find(item => item.sId === targetId);



				if (aTokens.length > 0) {
					if (matchedKey === "idPromoPlanTypeID") {
						oPlanHeaderModel.setProperty("/PlanClass", foundItem.getBindingContext("PromoPlan").getObject().PlanClass);

					}
					oPlanHeaderModel.setProperty(fieldConfig.key, aTokens[0].getKey());
					oPlanHeaderModel.setProperty(fieldConfig.text, foundItem.getAdditionalText());
				}
			}

			await Validate.validateGeneralData(this);
			await Validate.validatePlanHeaderData(this);
		},

		generalDataInputValidation: async function (oEvent) {


			await Validate.validateGeneralData(this);
			await Validate.validatePlanHeaderData(this);


		},

		planHeaderDataVHValidation: function (oEvent) {
			const sType = oEvent.getParameter("type");
			const oMultiInput = oEvent.getSource();
			const sId = oMultiInput.getId();
			const oPlanHeaderModel = this.getView().getModel("PlanHeader");

			const fieldMap = {
				"idObjectiveID": { key: "/ObjectiveId", text: "/ObjectiveDesc" },
				"idProductSelectionID": { key: "/key", text: "/name" }

			};

			const matchedKey = Object.keys(fieldMap).find(key => sId.includes(key));
			const fieldConfig = fieldMap[matchedKey];

			if (!fieldConfig) {
				console.warn("No matching field config found for:", sId);
				return;
			}

			if (sType === "removed") {
				const aRemovedTokens = oEvent.getParameter("removedTokens");
				aRemovedTokens.forEach(oToken => oMultiInput.removeToken(oToken));

				if (matchedKey === "idProductSelectionID") {

					var oAppViewModel = this.getView().getModel("appView");


					oPlanHeaderModel.setProperty("/ProductSelection", "");

					// Set all to false, then true for the selected one
					["ProductHierarchy", "Brand", "Product", "SubBrand"].forEach(function (sProp) {
						oAppViewModel.setProperty("/" + sProp, false);
					});


				}

				if (oMultiInput.getTokens().length === 0) {
					oPlanHeaderModel.setProperty(fieldConfig.key, "");
					oPlanHeaderModel.setProperty(fieldConfig.text, "");
				}
			} else {
				const aTokens = oMultiInput.getTokens();

				if (aTokens.length > 0) {
					if (matchedKey === "idProductSelectionID") {
						oPlanHeaderModel.setProperty("/ProductSelection", aTokens[0].getKey());

					}
					oPlanHeaderModel.setProperty(fieldConfig.key, aTokens[0].getKey());
					oPlanHeaderModel.setProperty(fieldConfig.text, aTokens[0].getText());
				}
			}

			Validate.validatePlanHeaderData(this);
		},
		planHeaderBuyingDateValidation: async function (oEvent) {
			var oFromDate = oEvent.getParameter("from");
			var that = this;
			var oToDate = formatter._getDateTimeInstance(oEvent.getParameter("to"));
			var oMonday = formatter._getDateTimeInstance(this.getMondayOfWeek(oFromDate));
			await this._loadCalendarSet(oMonday, oToDate);
			await Validate.validateGeneralData(this);
			await Validate.validatePlanHeaderData(this);
			const oVolumeModel = this.getView().getModel("VolumeModel");
			oVolumeModel.setData([]);


			var oHeaderData = this.getView().getModel("PlanHeader").getData();


			var aItems = oHeaderData.To_Item.results;
			var sMatchField = oHeaderData.ProductSelection;
			for (let i = 0; i < aItems.length; i++) {
				const oItem = aItems[i];

				if (oItem.ItemNo === "000000") {
					continue;
				}

				let sFieldType, sValue;
				var subbrand = "";
				// Map ProductSelection → correct field
				switch (sMatchField) {
					case "BRAND":
						sFieldType = "Brand";
						sValue = oItem.Brand;

						break;
					case "SBRAN":
						sFieldType = "SubBrand";
						sValue = oItem.Brand;

						subbrand = oItem.Subbrand;

						break;
					case "PRODH":
						sFieldType = "Prodh";
						sValue = oItem.Prodh;
						break;
					case "MATNR":
						sFieldType = "Matnr";
						sValue = oItem.Matnr;
						break;
					default:
						sValue = null;
				}

				await that._getVolumeData(that, sFieldType, sValue, oItem.ItemNo, subbrand);
			}


			//this.updateVolumeData();
		},
		updateVolumeData: function () {
			const oPlanHeaderModel = this.getView().getModel("PlanHeader");
			const aItems = oPlanHeaderModel.getProperty("/To_Item/results");

			for (let i = 0; i < aItems.length; i++) {
				const oItem = aItems[i];

				if (oItem.ItemNo === "000000") {
					continue;
				}


				this._splitVolumeAcrossWeeks("B", oItem.ItemNo, oItem.Baseline);
				this._splitVolumeAcrossWeeks("U", oItem.ItemNo, oItem.Uplift);
				this._splitVolumeAcrossWeeks("P", oItem.ItemNo, oItem.VolumePlanned);


			}
		},

		getMondayOfWeek: function (fromDate) {
			// Clone the date to avoid modifying the original
			var monday = new Date(fromDate.getTime());

			// Get the day of the week (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
			var day = monday.getDay();

			// Calculate difference to Monday
			var diff = (day === 0 ? -6 : 1) - day;

			// Adjust date to Monday
			monday.setDate(monday.getDate() + diff);

			return monday;
		},
		planHeaderDataValidation: async function (oEvent) {
			await Validate.validateGeneralData(this);


			await Validate.validatePlanHeaderData(this);



		},

		onPlanningOIAddRow: function () {
			if (this._validateSections(this)) {

				const oPlanHeaderModel = this.getOwnerComponent().getModel("PlanHeader");
				const aData = oPlanHeaderModel.getProperty("/To_Item/results") || [];
				var oPlanningRow = this.getView().byId("idPlanningOITable").getRows();

				if (aData.length === 0) {
					this._insertSummaryRow(aData);


					const oModel = this.getView().getModel("appView");
					const bBrand = oModel.getProperty("/Brand");
					const bProduct = oModel.getProperty("/Product");
					const bProductHierarchy = oModel.getProperty("/ProductHierarchy");
					const bSubBrand = oModel.getProperty("/SubBrand");



					// Assuming oPlanningRow[0] is your target row
					if (bSubBrand) {
						if (oPlanningRow[0].getCells()[10] !== undefined) {
							const items = oPlanningRow[0].getCells()[10].getItems();
							if (items.length > 0 && items[0].removeAllTokens) {
								items[0].removeAllTokens();
							}
						}
					} else if (bProduct || bProductHierarchy || bBrand) {
						if (oPlanningRow[0].getCells()[9] !== undefined) {
							const items = oPlanningRow[0].getCells()[9].getItems();
							if (items.length > 0 && items[0].removeAllTokens) {
								items[0].removeAllTokens();
							}
						}
					}



				}
				// Step 1: Collect existing ItemNos as numbers
				const aExistingItemNos = aData
					.map(row => parseInt(row.ItemNo, 10))
					.filter(num => !isNaN(num))
					.sort((a, b) => a - b);

				// Step 2: Find the smallest missing ItemNo
				let newIdNum = 0;
				for (let i = 0; i < aExistingItemNos.length; i++) {
					if (aExistingItemNos[i] !== newIdNum) {
						break;
					}
					newIdNum++;
				}

				const newId = newIdNum.toString().padStart(6, "0");


				const oNewRow = {
					"PlanId": "",
					"IsSummary": false,
					"SpendNro": "",
					"ItemNo": newId,
					"RecordType": "",
					"Prodh": "",
					"Matnr": "",
					"Brand": "",
					"Subbrand": "",
					"VolumePlanned": "0",
					"Uplift": "0",
					"Baseline": "0",
					"DiscountEdlp": "0",
					"SpendMethod1": "",
					"DiscountAmt1": "0",
					"Tactic1": "",
					"Tactic2": "",
					"Tactic3": "",
					"Tactic4": "",
					"Tactic5": "",

					"TacticDesc1": "",
					"TacticDesc2": "",
					"TacticDesc3": "",
					"TacticDesc4": "",
					"TacticDesc5": "",
					"SpendAlloc1": "",
					"SpendAlloc2": "",
					"SpendAlloc3": "",
					"SpendAlloc4": "",
					"SpendAlloc5": "",
					"SpendTypeClass1": "",
					"SpendTypeClass2": "",
					"SpendTypeClass3": "",
					"SpendTypeClass4": "",
					"SpendTypeClass5": "",
					"Discount1": "0",
					"SpendType1": "",
					"SpendType1Desc": "",
					"SpendMethod2": "",
					"DiscountAmt2": "0",
					"Discount2": "0",
					"SpendType2": "",
					"SpendType2Desc": "",
					"SpendMethod3": "",
					"DiscountAmt3": "0",
					"Discount3": "0",
					"SpendType3": "",
					"SpendType3Desc": "",
					"SpendMethod4": "",
					"DiscountAmt4": "0",
					"Discount4": "0",
					"SpendType4": "",
					"SpendType4Desc": "",
					"SpendMethod5": "",
					"DiscountAmt5": "0",
					"Discount5": "0",
					"SpendType5": "",
					"SpendType5Desc": "",
					"ListPrice": "0",
					"RetailPrice": "0",
					"RegularPrice": "0",
					"Uom": "",
					"Ppc": "1",
					"NetCost": "0",
					"Tax": "0",
					"Trade": "0",
					"RetailMargin": "0",
					"RetailMarginPrc": "0",
					"Fund": "",
					"Waers": "",
					"CcmNum": "",
					"Knumh": "",
					"SpendPlanned": "0",
					"SalesPlanned": "0",
					"Cogs": "0",
					"Niv": "0",
					"LtaDef": "0",
					"Nsv": "0",
					"Sales": "0",
					"Profit": "0",
					"SpendPlannedOi": "0",
					"SpendPlannedBb": "0",
					"SpendPlannedLs": "0",
					"LogisticDefCost": "0",
					"FinancialOiCost": "0",
					"LogisticOiCost": "0",
					"FinancialDefCost": "0",
					"OtherOiCost": "0",
					"OtherDefCost": "0",
					"Dcost": "0"

				};


				// Copy values from first row if available
				if (aData.length > 0) {
					for (let i = 1; i <= 5; i++) {
						oNewRow[`SpendMethod${i}`] = aData[0][`SpendMethod${i}`] || "";
						oNewRow[`SpendType${i}`] = aData[0][`SpendType${i}`] || "";
						oNewRow[`Tactic${i}`] = aData[0][`Tactic${i}`] || "";
						oNewRow[`TacticDesc${i}`] = aData[0][`TacticDesc${i}`] || "";
						oNewRow[`SpendAlloc${i}`] = aData[0][`SpendAlloc${i}`] || "";
						oNewRow[`SpendType${i}Desc`] = aData[0][`SpendType${i}Desc`] || "";
						oNewRow[`SpendTypeClass${i}`] = aData[0][`SpendTypeClass${i}`] || "";


					}
				}



				aData.push(oNewRow);
				oPlanHeaderModel.setProperty("/To_Item/results", aData);
				var iRow = aData.length - 1;


				const oModel = this.getView().getModel("appView");
				const bBrand = oModel.getProperty("/Brand");
				const bProduct = oModel.getProperty("/Product");
				const bProductHierarchy = oModel.getProperty("/ProductHierarchy");
				const bSubBrand = oModel.getProperty("/SubBrand");

				// Assume oPlanningRow[iRow] is your row object
				if (bSubBrand) {
					// Clear cells 0 and 1
					[0, 1].forEach(i => {
						oPlanningRow[iRow].getCells()[i].removeAllTokens();
					});
				} else if (bProduct || bProductHierarchy || bBrand) {
					// Clear only cell 0
					[0].forEach(i => {
						oPlanningRow[iRow].getCells()[i].removeAllTokens();
					});
				}




				this.getView().getModel("PlanHeader").refresh(true);
				this.getView().getModel("appView").refresh(true);
				this.getView().updateBindings(true);
			}



		},



		_deleteVolumeRowsByItemNo: function (aItemNosToDelete) {
			const oVolumeModel = this.getView().getModel("VolumeModel");
			const aData = oVolumeModel.getProperty("/") || [];

			// Filter out rows whose ItemNo is in the deletion set
			const aFilteredData = aData.filter(row => !aItemNosToDelete.has(row.ItemNo));

			// Only update if something was removed
			if (aFilteredData.length !== aData.length) {
				oVolumeModel.setProperty("/", aFilteredData);
				oVolumeModel.refresh(true);
			}
		},

		onPlanningOIDeleteRow: function () {
			const oTable = this.byId("idPlanningOITable");
			const oPlanHeaderModel = this.getOwnerComponent().getModel("PlanHeader");
			const aData = oPlanHeaderModel.getProperty("/To_Item/results") || [];
			const oDeletedModel = this.getOwnerComponent().getModel("DeletedPlanningOI");
			const aDeletedItems = oDeletedModel.getData();
			const aSelectedIndices = oTable.getSelectedIndices();
			var that = this;
			if (aSelectedIndices.length === 0) {
				MessageToast.show("Please select row(s) to delete.");
				return;
			}


			// Optional: prevent deletion of both 0 and 1
			if (aSelectedIndices.includes(0)) {
				MessageToast.show("Cannot delete summary row.");
				return;
			}


			const aItemNosToDelete = new Set();

			const oModel = this.getView().getModel("appView");
			const bBrand = oModel.getProperty("/Brand");
			const bProduct = oModel.getProperty("/Product");
			const bProductHierarchy = oModel.getProperty("/ProductHierarchy");
			const bSubBrand = oModel.getProperty("/SubBrand");

			// Sort descending to avoid index shift while deleting

			aSelectedIndices.sort((a, b) => b - a).forEach(index => {
				if (bSubBrand) {
					oTable.getRows()[index].getCells()[0].removeAllTokens();
					oTable.getRows()[index].getCells()[1].removeAllTokens();
				} else if (bProduct || bProductHierarchy || bBrand) {
					oTable.getRows()[index].getCells()[0].removeAllTokens();
				}



				const oRow = aData[index];
				aItemNosToDelete.add(oRow.ItemNo); // inside loop

				if (oRow.ItemNo && oRow.PlanId) {
					oRow.Delete = "X";
					aDeletedItems.push(oRow); // Capture for deletion
				}

				aData.splice(index, 1);
			});
			that._deleteVolumeRowsByItemNo(aItemNosToDelete); // Replace with actual ItemNo
			oPlanHeaderModel.setProperty("/To_Item/results", aData);

			oDeletedModel.setData(aDeletedItems);
			this.getOwnerComponent().setModel(oDeletedModel, "DeletedPlanningOI");

			oTable.clearSelection();

		},


		onPlanningOIAddColumn: async function () {



			if (this._validateSections(this)) {

				const oAppViewModel = this.getView().getModel("appView");

				var nMaxTactics = oAppViewModel.getProperty("/MaxTactics");

				const oPlanHeaderModel = this.getOwnerComponent().getModel("PlanHeader");
				const aData = oPlanHeaderModel.getProperty("/To_Item/results") || [];

				if (aData.length < 1) {

					sap.m.MessageToast.show("Please add row to add Spendtype");
					return;

				}


				if (this._iSpendOIColumnSetCount >= nMaxTactics) {
					sap.m.MessageToast.show("Maximum of " + nMaxTactics + " Spend Type/Method columns can be added.");
					return;
				}
				this._iSpendOIColumnSetCount++;

				var iSet = this._iSpendOIColumnSetCount;
				oAppViewModel.setProperty("/SpendType" + iSet, true);





			}




		},


		onPlanningOIRemoveColumns: function () {

			var oPlanningRow = this.getView().byId("idPlanningOITable").getRows();
			if (this._iSpendOIColumnSetCount > 1) {
				var iSet = this._iSpendOIColumnSetCount;

				const oModel = this.getView().getModel("appView");
				const bBrand = oModel.getProperty("/Brand");
				const bProduct = oModel.getProperty("/Product");
				const bProductHierarchy = oModel.getProperty("/ProductHierarchy");
				const bSubBrand = oModel.getProperty("/SubBrand");
				if (bSubBrand) {
					var offset = 10 + (iSet - 1) * 4;
					if (oPlanningRow[0].getCells()[offset] !== undefined) {
						const items = oPlanningRow[0].getCells()[offset].getItems();
						if (items.length > 0 && items[0].removeAllTokens) {
							items[0].removeAllTokens();
						}
					}
				} else if (bProduct || bProductHierarchy || bBrand) {
					var offset = 9 + (iSet - 1) * 4;
					if (oPlanningRow[0].getCells()[offset] !== undefined) {
						const items = oPlanningRow[0].getCells()[offset].getItems();
						if (items.length > 0 && items[0].removeAllTokens) {
							items[0].removeAllTokens();
						}
					}
				}

				const oAppViewModel = this.getView().getModel("appView");
				oAppViewModel.setProperty("/SpendType" + iSet, false);
				const oPlanHeaderModel = this.getView().getModel("PlanHeader");


				const aItems = oPlanHeaderModel.getProperty("/To_Item/results");

				if (aItems.length > 0) {
					var k = this._iSpendOIColumnSetCount;

					aItems.forEach(function (item) {
						item[`SpendMethod${k}`] = "";
						item[`SpendType${k}`] = "";
						item[`SpendType${k}Desc`] = "";
						item[`Tactic${k}`] = "";
						item[`TacticDesc${k}`] = "";
						item[`SpendTypeClass${k}`] = "";
						item[`SpendAlloc${k}`] = "";
						item[`DiscountAmt${k}`] = "";
						item[`Discount${k}`] = "";
					});
					oPlanHeaderModel.setProperty("/To_Item/results", aItems);
				}
				this._iSpendOIColumnSetCount--;
			}

		},





		onAfterRendering: function () {
			this.hideBusyIndicator();

		}



	});
});