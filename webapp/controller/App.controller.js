/************************************************************************
 *-----------------------------------------------------------------------
 * Project               : Promo Plan
 * Process               : TPM
 * Task Code             : 
 * Functional Document   : 
 * Technical Document    :
 *  ---------------------------------------------------------------------
 * File       : controller/App.js
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
    "com/kcc/promoplan/controller/BaseController"
], (BaseController) => {
    "use strict";

    return BaseController.extend("com.kcc.promoplan.controller.App", {
        onInit() {
            this.oOwnerComponent = this.getOwnerComponent();
			this.oRouter = this.oOwnerComponent.getRouter();
			this.oRouter.attachRouteMatched(this.onRouteMatched, this);
        },
        	onRouteMatched: function (oEvent) {
			var sRouteName = oEvent.getParameter("name"),
				oArguments = oEvent.getParameter("arguments");

			// Save the current route name
			this.currentRouteName = sRouteName;
			this.currentProduct = oArguments.product;
			this.currentSupplier = oArguments.supplier;
		},
        	onStateChanged: function (oEvent) {
			var bIsNavigationArrow = oEvent.getParameter("isNavigationArrow"),
				sLayout = oEvent.getParameter("layout");

			// Replace the URL with the new layout if a navigation arrow was used
			if (bIsNavigationArrow) {
				this.oRouter.navTo(this.currentRouteName, {layout: sLayout, product: this.currentProduct, supplier: this.currentSupplier}, true);
			}
		},

		onExit: function () {
			this.oRouter.detachRouteMatched(this.onRouteMatched, this);
		}
    });
});