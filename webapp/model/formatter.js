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

        productSelectionText: function (Product) {


            if (Product === "MATNR") {
                return "Product";
            } else if (Product === "BRAND") {
                return "Brand";
            } else if (Product === "PRODH") {
                return "Product Hierarchy";
            } else if (Product === "SBRAN") {
                return "Sub Brand";
            } else {
                return ""; // or "Not Defined"
            }


        },
        formatPNLColor: function (name) {

            if (name === 'Net Sales') {
                this.addStyleClass("pnlBoldText");

            }

            return name;

        },
         showDisplayButton: function (sOpInd) {
            if (!sOpInd) {
                return false;
            }

            var sValue = sOpInd.toUpperCase();
            return sValue === "D" || sValue === "E";
        },
        showEditButton: function (sOpInd) {
           if (!sOpInd) {
        return false;
    }

    return sOpInd.toUpperCase() === "E";
        },
        getROIState: function (name, promotedValue) {
            if (promotedValue === 0 || promotedValue === "") {
                return "None";
            }
            if (name === "ROI" || name === "Retailer ROI") {

                return promotedValue < 0 ? "Error" : "Success";
            }
            return "None"; // Default for other items
        },
        getROIIcon: function (name, promotedValue) {
            if (promotedValue === 0 || promotedValue === "") {
                return "";
            }
            if (name === "ROI" || name === "Retailer ROI") {
                return promotedValue < 0 ? "sap-icon://error" : "sap-icon://accept";
            }
            return "";
        },


        _convertDateToLocal: function (oData) {

            // var oDate = new Date(sDateValueFromControl); // This is in UTC
            var oDateFormat = sap.ui.core.format.DateFormat.getDateTimeInstance({
                pattern: "yyyy-MM-dd HH:mm:ss", // Local date-time format
                UTC: false // Important: use local time
            });
            oData.BuyingDateF = oDateFormat.format(oData.BuyingDateF);
            oData.BuyingDateT = oDateFormat.format(oData.BuyingDateT);
            oData.InstoreDateF = oDateFormat.format(oData.InstoreDateF);
            oData.InstoreDateT = oDateFormat.format(oData.InstoreDateT);
            oData.OrderDateF = oDateFormat.format(oData.OrderDateF);
            oData.OrderDateT = oDateFormat.format(oData.OrderDateT);
            return oData;


        },
        _getDateTimeInstance: function (oDate) {

            //var oDate = new Date("2025-01-15"); // or any Date object
            var oDateFormat = sap.ui.core.format.DateFormat.getDateTimeInstance({
                                pattern: "yyyy-MM-dd"

               //pattern: "yyyy-MM-dd'T'HH:mm:ss"
            });
            var sFormattedDate = oDateFormat.format(oDate);

            return sFormattedDate;
        },
        formatToken: function (sSKU) {
            if (!sSKU) return [];
            return [new Token({ key: sSKU, text: sSKU })];
        },

        formatDateRange: function (dateFrom, dateTo) {
            if (!dateFrom || !dateTo) return "";

            var dFrom = new Date(dateFrom);
            var dTo = new Date(dateTo);
            if (dFrom.getFullYear() < 1970 || dTo.getFullYear() < 1970) return "";

            const oDateFormat = sap.ui.core.format.DateFormat.getDateInstance({ pattern: "dd/MM/yyyy" });

            return oDateFormat.format(dFrom) + " - " + oDateFormat.format(dTo);
        },


        /**
         * Format a date to DD-MM-YYYY
         */
        formatDate: function (date) {
            if (!date) return "";

            const [year, month, day] = date.split('-');
            const formatted = `${day}/${month}/${year}`

            return formatted;
            //return date.toDateString();
            //const oDate = new Date(date);
            //return oDate.toLocaleDateString("en-GB"); // DD/MM/YYYY
        },

        /**
         * Format currency with symbol
         */
        formatCurrency: function (value, currency) {
            if (!value || !currency) return "";
            return `${currency} ${parseFloat(value).toFixed(2)}`;
        },

        /**
         * Format boolean to Yes/No
         */
        formatBoolean: function (bValue) {
            return bValue ? "Yes" : "No";
        }
    };
});
