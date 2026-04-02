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

], function () {
	"use strict";

	return {


		calculateSummaryRow: function (that) {
			const oModel = that.getView().getModel("PlanHeader");
			const oHeaderData = oModel.getData();
			const aItems = oModel.getProperty("/To_Item/results");

			const oPNLModel = that.getView().getModel("PNL");

			const aPNLItems = oPNLModel.getProperty("/");


			if (!Array.isArray(aItems) || aItems.length === 0) return;

			// Initialize totals
			let totalSales = 0;
			let oiCost = 0;
			let niv = 0;
			let ltaDefCost = 0;
			let variableDeferredCost = 0;
			let lumpsumCost = 0;
			let nsv = 0;
			let baseline = 0;
			let volumeplanned = 0;
			let uplift = 0;
			let grosssales = 0;
			let cogs = 0;
			let spendplannedoi = 0;
			let nlistPrice = 0;
			let logisticOiCost = 0;
			let financialOiCost = 0;
			let otherOiCost = 0;
			let logisticDefCost = 0;
			let financialDefCost = 0;
			let otherDefCost = 0;
			let dcost = 0;
			let edlp = 0;
			let nRetailPrice = 0;
			let nRegularPrice = 0;
			let netcost = 0;
			let nppc = 0;
			var nFinalTotalSales = 0;
			let nbaselinecogs = 0;
			let npromotedcogs = 0;
			let nbaselinedcost = 0;
			let npromoteddcost = 0;
			let nbaselinegrosssales = 0;
			let npromotedgrosssales = 0;



			// ✅ Helper: Safe division
			const safeDivide = (numerator, denominator) => denominator ? (numerator / denominator).toFixed(2) : 0;





			const normalizeValue = num => {
				const value = parseFloat(num);
				if (isNaN(value) || value === 0) return 0;
				return Number.isInteger(value) ? value : parseFloat(value.toFixed(2));
			};



			for (let k = 1; k < aItems.length; k++) {
				const oItem = aItems[k];
				nFinalTotalSales += (oItem.NetCost || 0) * (oItem.VolumePlanned || 0);
			}
			nFinalTotalSales = normalizeValue(nFinalTotalSales);

			// Loop through all items except the summary row
			for (let i = 1; i < aItems.length; i++) {
				const item = aItems[i];

				// Apply formulas to line item
				item.DiscountEdlp = normalizeValue((item.ListPrice || 0) - (item.NetCost || 0));


				item.SalesPlanned = normalizeValue((item.NetCost || 0) * (item.VolumePlanned || 0));


				// ✅ Spend calculations
				let totalOiSpend = 0, totalBbSpend = 0, totalLsSpend = 0;

				for (let j = 1; j <= 5; j++) {
					const spendType = item[`SpendTypeClass${j}`];
					const spendMethod = item[`SpendMethod${j}`];
					const discountPercent = item[`Discount${j}`] || 0;
					const discountAmount = item[`DiscountAmt${j}`] || 0;

					switch (spendType) {
						case "OI":
							//totalOiSpend += spendMethod === "%" ? discountPercent * item.SalesPlanned : discountAmount * item.VolumePlanned;
							totalOiSpend += spendMethod === "%" ? (discountPercent / 100) * item.SalesPlanned : discountAmount * item.VolumePlanned;

							break;
						case "BB":
							//totalBbSpend += spendMethod === "%" ? discountPercent * item.SalesPlanned : discountAmount * item.VolumePlanned;
							totalBbSpend += spendMethod === "%" ? (discountPercent / 100) * item.SalesPlanned : discountAmount * item.VolumePlanned;

							break;
						case "LS":
							if (spendMethod === "F") totalLsSpend += parseFloat(discountAmount);
							break;
					}
				}



				// ✅ Assign summarized spends
				item.SpendPlannedOi = normalizeValue(totalOiSpend);
				// if(item.SpendMethod1==="%"){
				// item.SpendPlannedOi = item.SpendPlannedOi / 100;
				// }
				// else{
				// 	item.SpendPlannedOi = item.SpendPlannedOi;
				// }
				item.SpendPlannedBb = normalizeValue(totalBbSpend);
				item.SpendPlannedLs = normalizeValue(totalLsSpend);

				// Assign summarized OI spend to the item
				//item.SpendPlannedOi = normalizeValue(parseFloat(totalOiSpend).toFixed(2));
				//item.SpendPlannedBb = normalizeValue(parseFloat(totalBbSpend).toFixed(2));
				//item.SpendPlannedLs = normalizeValue(parseFloat(totalLsSpend).toFixed(2));


				const vol = item.VolumePlanned || 0;

				item.Niv = normalizeValue(
					vol * ((item.ListPrice || 0) - (item.DiscountEdlp || 0) - (item.LogisticOiCost || 0) - (item.FinancialOiCost || 0) - (item.OtherOiCost || 0))
					- (item.SpendPlannedOi || 0)
				);


				// Calculate total deferred costs multiplied by VolumePlanned
				//const totalDeferredCost = (item.LtaDef || 0)
				//+ (item.LogisticDefCost || 0)
				//+ (item.FinancialDefCost || 0)
				//+ (item.OtherDefCost || 0);


				// Apply new NSV formula
				item.Nsv = normalizeValue(
					parseFloat(item.Niv || 0)
					- ((item.VolumePlanned || 0) * ((parseFloat(item.LtaDef || 0))
						+ parseFloat((item.LogisticDefCost || 0))
						+ parseFloat((item.FinancialDefCost || 0))
						+ parseFloat((item.OtherDefCost || 0))))
					- parseFloat((item.SpendPlannedBb || 0))
					- parseFloat((item.SpendPlannedLs || 0))
				);


				// item.Nsv = normalizeValue(item.Niv - (item.LtaDef || 0) - (item.SpendPlannedBb || 0) - (item.SpendPlannedLs || 0) - (item.LogisticDefCost || 0) - (item.FinancialDefCost || 0) - (item.OtherDefCost || 0));
				//item.Trade = normalizeValue(safeDivide(parseFloat(item.SpendPlannedBb) || 0, parseFloat(item.SalesPlanned) || 1, "Trade %") * 100);

				const ntotalSales = parseFloat(item.SalesPlanned) || 1; // Avoid division by zero
				const totalTradeSpend = (parseFloat(item.SpendPlannedOi) || 0)
					+ (parseFloat(item.SpendPlannedBb) || 0)
					+ (parseFloat(item.SpendPlannedLs) || 0);

				item.Trade = normalizeValue(
					safeDivide(totalTradeSpend, ntotalSales, "Trade %") * 100
				);


				//item.Sales = normalizeValue((item.Nsv || 0) - (item.Cogs || 0) - (item.Dcost || 0));


				const nvolumePlanned = item.VolumePlanned || 0;
				const nnsv = item.Nsv || 0;
				const ncogs = item.Cogs || 0;
				const ndcost = item.Dcost || 0;


				// Apply new Sales formula
				item.Sales = normalizeValue(
					nnsv - (nvolumePlanned * ncogs) - (nvolumePlanned * ndcost)
				);




				item.Profit = normalizeValue(safeDivide(item.Sales || 0, item.Nsv || 1, "Profit"));




				const retailPrice = parseFloat(item.RetailPrice || 0);


				item.RetailMargin = normalizeValue(((retailPrice || 0) * (item.VolumePlanned || 0)) - safeDivide((item.Nsv || 0), (item.Ppc || 1)));


				item.RetailMarginPrc = normalizeValue(safeDivide((item.RetailMargin), (((retailPrice || 0) * (item.VolumePlanned || 0)) || 1), "Retail Margin %"));

				totalSales += parseFloat(item.SalesPlanned || 0);

				// Aggregate values

				nlistPrice += parseFloat(safeDivide(((parseFloat(item.ListPrice) || 0) * (parseFloat(item.SalesPlanned) || 0)), (parseFloat(nFinalTotalSales) || 1), "Weighted Avg ListPrice"));
				oiCost += parseFloat(item.SpendPlanned || 0);
				baseline += parseFloat(item.Baseline || 0);
				uplift += parseFloat(item.Uplift || 0);
				volumeplanned += parseFloat(item.VolumePlanned || 0);

				grosssales += parseFloat(item.Sales || 0);
				spendplannedoi += parseFloat(item.SpendPlannedOi || 0);
				niv += parseFloat(item.Niv || 0);
				ltaDefCost += parseFloat(item.LtaDef || 0);
				variableDeferredCost += parseFloat(item.SpendPlannedBb || 0);
				nsv += parseFloat(item.Nsv || 0);
				lumpsumCost += parseFloat(item.SpendPlannedLs || 0);
				nbaselinecogs += ((parseFloat(item.Cogs) || 0) * parseFloat(item.Baseline || 0));
				npromotedcogs += ((parseFloat(item.Cogs) || 0) * parseFloat(item.VolumePlanned || 0));

				cogs += safeDivide(((parseFloat(item.Cogs) || 0) * (parseFloat(item.SalesPlanned) || 0)), (parseFloat(nFinalTotalSales) || 1), "Cogs");

				//cogs += parseFloat(item.Cogs || 0);
				edlp += parseFloat(safeDivide(((parseFloat(item.DiscountEdlp) || 0) * (parseFloat(item.SalesPlanned) || 0)), (parseFloat(nFinalTotalSales) || 1), "Edlp"));

				netcost += parseFloat(safeDivide(((parseFloat(item.NetCost) || 0) * (parseFloat(item.SalesPlanned) || 0)), (parseFloat(nFinalTotalSales) || 1), "NetCost"));
				nppc += parseFloat(safeDivide(((parseFloat(item.Ppc) || 0) * (parseFloat(item.SalesPlanned) || 0)), (parseFloat(nFinalTotalSales) || 1), "PPC"));

				logisticOiCost += parseFloat(item.LogisticOiCost || 0);
				financialOiCost += parseFloat(item.FinancialOiCost || 0);
				otherOiCost += parseFloat(item.OtherOiCost || 0);
				logisticDefCost += parseFloat(item.LogisticDefCost || 0);
				financialDefCost += parseFloat(item.FinancialDefCost || 0);
				otherDefCost += parseFloat(item.OtherDefCost || 0);
				nbaselinedcost += ((parseFloat(item.Dcost) || 0) * parseFloat(item.Baseline || 0));
				npromoteddcost += ((parseFloat(item.Dcost) || 0) * parseFloat(item.VolumePlanned || 0));

				dcost += parseFloat(item.Dcost || 0);

				nbaselinegrosssales += ((parseFloat(item.ListPrice) || 0) * parseFloat(item.Baseline || 0));
				npromotedgrosssales += parseFloat(item.SalesPlanned || 0);


				nRegularPrice += parseFloat(safeDivide(((parseFloat(item.RegularPrice) || 0) * (parseFloat(item.SalesPlanned) || 0)), (parseFloat(nFinalTotalSales) || 1), "RegularPrice"));
				nRetailPrice += parseFloat(safeDivide(((parseFloat(item.RetailPrice) || 0) * (parseFloat(item.SalesPlanned) || 0)), (parseFloat(nFinalTotalSales) || 1), "RetailPrice"));

				item.Baseline = normalizeValue(item.Baseline);
				item.Uplift = normalizeValue(item.Uplift);
				item.VolumePlanned = normalizeValue(item.VolumePlanned);



			}

			// Update summary row (index 0)
			const summary = aItems[0];
			summary.ListPrice = normalizeValue(nlistPrice).toString();
			summary.DiscountEdlp = normalizeValue(edlp).toString();
			summary.NetCost = normalizeValue(netcost).toString();
			summary.RegularPrice = normalizeValue(nRegularPrice).toString();
			summary.RetailPrice = normalizeValue(nRetailPrice).toString();
			summary.SalesPlanned = normalizeValue(totalSales).toString();
			summary.SpendPlanned = normalizeValue(oiCost).toString();
			summary.Niv = normalizeValue(niv).toString();
			summary.SpendPlannedOi = normalizeValue(spendplannedoi).toString();
			summary.Sales = normalizeValue(grosssales).toString();
			summary.LtaDef = normalizeValue(ltaDefCost).toString();
			summary.SpendPlannedBb = normalizeValue(variableDeferredCost).toString();
			summary.SpendPlannedLs = normalizeValue(lumpsumCost).toString();
			summary.Nsv = normalizeValue(nsv).toString();
			summary.Baseline = normalizeValue(baseline).toString();
			summary.Uplift = normalizeValue(uplift).toString();
			summary.VolumePlanned = normalizeValue(volumeplanned).toString();
			summary.Cogs = normalizeValue(cogs).toString();
			summary.LogisticOiCost = normalizeValue(logisticOiCost).toString();
			summary.FinancialOiCost = normalizeValue(financialOiCost).toString();
			summary.OtherOiCost = normalizeValue(otherOiCost).toString();
			summary.LogisticDefCost = normalizeValue(logisticDefCost).toString();
			summary.FinancialDefCost = normalizeValue(financialDefCost).toString();
			summary.OtherDefCost = normalizeValue(otherDefCost).toString();
			summary.Dcost = normalizeValue(dcost).toString();
			summary.Ppc = normalizeValue(nppc).toString();


			// Update summary rows
			aPNLItems.find(r => r.name === "Volume (CU)").Baseline = normalizeValue(baseline * nppc);
			aPNLItems.find(r => r.name === "Volume (CU)").Promoted = normalizeValue(volumeplanned * nppc);
			aPNLItems.find(r => r.name === "Volume (CU)").Delta = normalizeValue((volumeplanned - baseline) * nppc);

			aPNLItems.find(r => r.name === "Volume (CS)").Baseline = normalizeValue(baseline);
			aPNLItems.find(r => r.name === "Volume (CS)").Promoted = normalizeValue(volumeplanned);
			aPNLItems.find(r => r.name === "Volume (CS)").Delta = normalizeValue(volumeplanned - baseline);
			var sUomValue = (aItems[1] && aItems[1].Uom) ? aItems[1].Uom : "";
			aPNLItems.find(r => r.name === "Uom (EA/CS)").Baseline = sUomValue;
			aPNLItems.find(r => r.name === "Uom (EA/CS)").Promoted = sUomValue;
			aPNLItems.find(r => r.name === "Uom (EA/CS)").Delta = sUomValue;

			aPNLItems.find(r => r.name === "CU").Baseline = normalizeValue(nppc);
			aPNLItems.find(r => r.name === "CU").Promoted = normalizeValue(nppc);
			aPNLItems.find(r => r.name === "CU").Delta = normalizeValue(nppc);


			aPNLItems.find(r => r.name === "List Price").Baseline = normalizeValue(nlistPrice);
			aPNLItems.find(r => r.name === "List Price").Promoted = normalizeValue(nlistPrice);
			aPNLItems.find(r => r.name === "List Price").Delta = normalizeValue(nlistPrice);



			aPNLItems.find(r => r.name === "Basic Gross Sales").Baseline = normalizeValue(nbaselinegrosssales);
			aPNLItems.find(r => r.name === "Basic Gross Sales").Promoted = normalizeValue(npromotedgrosssales);
			aPNLItems.find(r => r.name === "Basic Gross Sales").Delta = normalizeValue((npromotedgrosssales - nbaselinegrosssales));


			aPNLItems.find(r => r.name === "EDLP").Baseline = normalizeValue(edlp * baseline);
			aPNLItems.find(r => r.name === "EDLP").Promoted = normalizeValue(edlp * volumeplanned);
			aPNLItems.find(r => r.name === "EDLP").Delta = normalizeValue((edlp * volumeplanned) - (edlp * baseline));

			aPNLItems.find(r => r.name === "Logistic OI Discount").Baseline = normalizeValue(logisticOiCost * baseline);
			aPNLItems.find(r => r.name === "Logistic OI Discount").Promoted = normalizeValue(logisticOiCost * volumeplanned);
			aPNLItems.find(r => r.name === "Logistic OI Discount").Delta = normalizeValue((logisticOiCost * volumeplanned) - (logisticOiCost * baseline));

			aPNLItems.find(r => r.name === "Financial OI Discount").Baseline = normalizeValue(financialOiCost * baseline);
			aPNLItems.find(r => r.name === "Financial OI Discount").Promoted = normalizeValue(financialOiCost * volumeplanned);
			aPNLItems.find(r => r.name === "Financial OI Discount").Delta = normalizeValue((financialOiCost * volumeplanned) - (financialOiCost * baseline));

			aPNLItems.find(r => r.name === "Other OI Discount").Baseline = normalizeValue(otherOiCost * baseline);
			aPNLItems.find(r => r.name === "Other OI Discount").Promoted = normalizeValue(otherOiCost * volumeplanned);
			aPNLItems.find(r => r.name === "Other OI Discount").Delta = normalizeValue((otherOiCost * volumeplanned) - (otherOiCost * baseline));



			aPNLItems.find(r => r.name === "NIV").Baseline = normalizeValue(baseline * (nlistPrice - edlp - logisticOiCost - financialOiCost - otherOiCost));
			aPNLItems.find(r => r.name === "NIV").Promoted = normalizeValue((volumeplanned * (nlistPrice - edlp - logisticOiCost - financialOiCost - otherOiCost)) - spendplannedoi);
			aPNLItems.find(r => r.name === "NIV").Delta = normalizeValue(aPNLItems.find(r => r.name === "NIV").Promoted - aPNLItems.find(r => r.name === "NIV").Baseline);


			aPNLItems.find(r => r.name === "LTA Deferred Discount").Baseline = normalizeValue(ltaDefCost * baseline);
			aPNLItems.find(r => r.name === "LTA Deferred Discount").Promoted = normalizeValue(ltaDefCost * volumeplanned);
			aPNLItems.find(r => r.name === "LTA Deferred Discount").Delta = normalizeValue((ltaDefCost * volumeplanned) - (ltaDefCost * baseline));


			// Logistic Deferred Discount
			aPNLItems.find(r => r.name === "Logistic Deferred Discount").Baseline = normalizeValue(logisticDefCost * baseline);
			aPNLItems.find(r => r.name === "Logistic Deferred Discount").Promoted = normalizeValue(logisticDefCost * volumeplanned);
			aPNLItems.find(r => r.name === "Logistic Deferred Discount").Delta = normalizeValue((logisticDefCost * volumeplanned) - (logisticDefCost * baseline));

			// Financial Deferred Discount
			aPNLItems.find(r => r.name === "Financial Deferred Discount").Baseline = normalizeValue(financialDefCost * baseline);
			aPNLItems.find(r => r.name === "Financial Deferred Discount").Promoted = normalizeValue(financialDefCost * volumeplanned);
			aPNLItems.find(r => r.name === "Financial Deferred Discount").Delta = normalizeValue((financialDefCost * volumeplanned) - (financialDefCost * baseline));

			// Other Deferred
			aPNLItems.find(r => r.name === "Other Deferred").Baseline = normalizeValue(otherDefCost * baseline);
			aPNLItems.find(r => r.name === "Other Deferred").Promoted = normalizeValue(otherDefCost * volumeplanned);
			aPNLItems.find(r => r.name === "Other Deferred").Delta = normalizeValue((otherDefCost * volumeplanned) - (otherDefCost * baseline));


			// Net Sales
			aPNLItems.find(r => r.name === "Net Sales").Baseline = normalizeValue(aPNLItems.find(r => r.name === "NIV").Baseline - (baseline * (ltaDefCost - logisticDefCost - financialDefCost - otherDefCost)));
			aPNLItems.find(r => r.name === "Net Sales").Promoted = normalizeValue(aPNLItems.find(r => r.name === "NIV").Promoted - (volumeplanned * (ltaDefCost - logisticDefCost - financialDefCost - otherDefCost)) - variableDeferredCost - lumpsumCost);
			aPNLItems.find(r => r.name === "Net Sales").Delta = normalizeValue(aPNLItems.find(r => r.name === "Net Sales").Promoted - aPNLItems.find(r => r.name === "Net Sales").Baseline);

			// COGS
			aPNLItems.find(r => r.name === "COGS").Baseline = normalizeValue(nbaselinecogs);
			aPNLItems.find(r => r.name === "COGS").Promoted = normalizeValue(npromotedcogs);
			aPNLItems.find(r => r.name === "COGS").Delta = normalizeValue(npromotedcogs - nbaselinecogs);

			// DISTRIBUTION
			aPNLItems.find(r => r.name === "DISTRIBUTION").Baseline = normalizeValue(nbaselinedcost);
			aPNLItems.find(r => r.name === "DISTRIBUTION").Promoted = normalizeValue(npromoteddcost);
			aPNLItems.find(r => r.name === "DISTRIBUTION").Delta = normalizeValue(npromoteddcost - nbaselinedcost);

			// Gross Profit
			aPNLItems.find(r => r.name === "Gross Profit").Baseline = normalizeValue(aPNLItems.find(r => r.name === "Net Sales").Baseline - (nbaselinecogs + nbaselinedcost));
			aPNLItems.find(r => r.name === "Gross Profit").Promoted = normalizeValue(aPNLItems.find(r => r.name === "Net Sales").Promoted - (npromotedcogs + npromoteddcost));
			aPNLItems.find(r => r.name === "Gross Profit").Delta = normalizeValue(aPNLItems.find(r => r.name === "Gross Profit").Promoted - aPNLItems.find(r => r.name === "Gross Profit").Baseline);


			// Profit
			aPNLItems.find(r => r.name === "Profit").Baseline = normalizeValue((aPNLItems.find(r => r.name === "Gross Profit").Baseline / aPNLItems.find(r => r.name === "Net Sales").Baseline) * 100);
			aPNLItems.find(r => r.name === "Profit").Promoted = normalizeValue((aPNLItems.find(r => r.name === "Gross Profit").Promoted / aPNLItems.find(r => r.name === "Net Sales").Promoted) * 100);
			aPNLItems.find(r => r.name === "Profit").Delta = normalizeValue(aPNLItems.find(r => r.name === "Profit").Promoted - aPNLItems.find(r => r.name === "Profit").Baseline);
			if (oHeaderData.PlanClass === "TP") {

				aPNLItems.find(r => r.name === "TP OI Discount").Baseline = ""
				aPNLItems.find(r => r.name === "TP OI Discount").Promoted = normalizeValue(spendplannedoi);
				aPNLItems.find(r => r.name === "TP OI Discount").Delta = normalizeValue(spendplannedoi);

				aPNLItems.find(r => r.name === "TP Deferred Discount").Baseline = ""
				aPNLItems.find(r => r.name === "TP Deferred Discount").Promoted = normalizeValue(variableDeferredCost + lumpsumCost);
				aPNLItems.find(r => r.name === "TP Deferred Discount").Delta = normalizeValue(variableDeferredCost + lumpsumCost);


			}
			if (oHeaderData.PlanClass === "CP") {

				aPNLItems.find(r => r.name === "CP OI Discount").Baseline = ""
				aPNLItems.find(r => r.name === "CP OI Discount").Promoted = normalizeValue(spendplannedoi);
				aPNLItems.find(r => r.name === "CP OI Discount").Delta = normalizeValue(spendplannedoi);

				aPNLItems.find(r => r.name === "CP Deferred Discount").Baseline = ""
				aPNLItems.find(r => r.name === "CP Deferred Discount").Promoted = normalizeValue(variableDeferredCost + lumpsumCost);
				aPNLItems.find(r => r.name === "CP Deferred Discount").Delta = normalizeValue(variableDeferredCost + lumpsumCost);


			}


			const tpOiPromoted = aPNLItems.find(r => r.name === "TP OI Discount").Promoted || 0;
			const cpOiPromoted = aPNLItems.find(r => r.name === "CP OI Discount").Promoted || 0;
			const tpDefPromoted = aPNLItems.find(r => r.name === "TP Deferred Discount").Promoted || 0;
			const cpDefPromoted = aPNLItems.find(r => r.name === "CP Deferred Discount").Promoted || 0;

			aPNLItems.find(r => r.name === "Trade Spend").Baseline = "";
			aPNLItems.find(r => r.name === "Trade Spend").Promoted = normalizeValue(tpOiPromoted + cpOiPromoted + tpDefPromoted + cpDefPromoted);
			aPNLItems.find(r => r.name === "Trade Spend").Delta = normalizeValue(aPNLItems.find(r => r.name === "Trade Spend").Promoted);

			// ROI
			const grossProfitDelta = aPNLItems.find(r => r.name === "Gross Profit").Delta;


			const tpOiDelta = aPNLItems.find(r => r.name === "TP OI Discount").Delta || 0;
			const cpOiDelta = aPNLItems.find(r => r.name === "CP OI Discount").Delta || 0;
			const tpDefDelta = aPNLItems.find(r => r.name === "TP Deferred Discount").Delta || 0;
			const cpDefDelta = aPNLItems.find(r => r.name === "CP Deferred Discount").Delta || 0;

			aPNLItems.find(r => r.name === "ROI").Baseline = "";
			aPNLItems.find(r => r.name === "ROI").Promoted = "";
			aPNLItems.find(r => r.name === "ROI").Delta = normalizeValue(safeDivide(grossProfitDelta, (tpOiDelta + cpOiDelta + tpDefDelta + cpDefDelta), "ROI") * 100);



			aPNLItems.find(r => r.name === "Price").Baseline = normalizeValue(nRegularPrice);
			aPNLItems.find(r => r.name === "Price").Promoted = normalizeValue(nRetailPrice);
			aPNLItems.find(r => r.name === "Price").Delta = normalizeValue(nRetailPrice - nRegularPrice);


			aPNLItems.find(r => r.name === "Retailer Sales").Baseline = normalizeValue(nRegularPrice * baseline);
			aPNLItems.find(r => r.name === "Retailer Sales").Promoted = normalizeValue(nRetailPrice * volumeplanned);
			aPNLItems.find(r => r.name === "Retailer Sales").Delta = normalizeValue((nRetailPrice * volumeplanned) - (nRegularPrice * baseline));

			aPNLItems.find(r => r.name === "Retail Investment").Baseline = "";
			aPNLItems.find(r => r.name === "Retail Investment").Promoted = normalizeValue((nRegularPrice - nRetailPrice) * volumeplanned);
			aPNLItems.find(r => r.name === "Retail Investment").Delta = normalizeValue((nRegularPrice - nRetailPrice) * volumeplanned);

			aPNLItems.find(r => r.name === "Retail Margin $").Baseline = normalizeValue(aPNLItems.find(r => r.name === "Retailer Sales").Baseline - aPNLItems.find(r => r.name === "Net Sales").Baseline);
			aPNLItems.find(r => r.name === "Retail Margin $").Promoted = normalizeValue(aPNLItems.find(r => r.name === "Retailer Sales").Promoted - aPNLItems.find(r => r.name === "Net Sales").Promoted);
			aPNLItems.find(r => r.name === "Retail Margin $").Delta = normalizeValue(aPNLItems.find(r => r.name === "Retail Margin $").Promoted - aPNLItems.find(r => r.name === "Retail Margin $").Baseline);

			aPNLItems.find(r => r.name === "Retail Margin %").Baseline = normalizeValue(safeDivide(aPNLItems.find(r => r.name === "Retail Margin $").Baseline || 0, ((baseline * nRegularPrice) || 1), "Retail Margin$") * 100);
			aPNLItems.find(r => r.name === "Retail Margin %").Promoted = normalizeValue(safeDivide(aPNLItems.find(r => r.name === "Retail Margin $").Promoted || 0, ((volumeplanned * nRetailPrice) || 1), "Retail Margin$") * 100);
			aPNLItems.find(r => r.name === "Retail Margin %").Delta = normalizeValue(aPNLItems.find(r => r.name === "Retail Margin %").Promoted - aPNLItems.find(r => r.name === "Retail Margin %").Baseline);

			aPNLItems.find(r => r.name === "Retailer ROI").Baseline = "";
			aPNLItems.find(r => r.name === "Retailer ROI").Promoted = "";
			aPNLItems.find(r => r.name === "Retailer ROI").Delta = normalizeValue(safeDivide(aPNLItems.find(r => r.name === "Retail Margin $").Delta || 0, aPNLItems.find(r => r.name === "Retail Investment").Delta || 1, "Retail ROI") * 100);
			// Continue for Net Sales, Gross Profit, ROI, Retailer metrics...

			//oPNLModel.setProperty("/SummaryRows", aPNLItems);



			// Update model
			oModel.setProperty("/To_Item/results", aItems);
		}

	};
});