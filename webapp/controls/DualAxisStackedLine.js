sap.ui.define([
    "sap/viz/ui5/controls/VizFrame"

], function (VizFrame) {
    "use strict";

    return VizFrame.extend("com.kcc.promoplan.controls.DualAxisStackedLine", {
        metadata: {
            renderer: {},

            properties: {
                chartTitle: { type: "string", defaultValue: "Promo ROI" }
            }

        },

        init: function () {
            //MultiInput.prototype.init.call(this);

            VizFrame.prototype.init.apply(this, arguments);

            this.setVizType("dual_stacked_column");
            this.setVizProperties({
                title: { text: this.getChartTitle() },
                plotArea: {
                    dataLabel: { visible: true },
                    colorPalette: [["lightblue", "darkblue"], "#ff7f0e", "#2ca02c"], // Custom colors

                    series: {
                        "Baseline": { type: "column" },
                        "Uplift": { type: "column" },
                        "ROI": { type: "line" } // ✅ Line on secondary axis
                    },
                    seriesType: "column",
                    drawingEffect: "glossy"
                },
                legend: { visible: true },
                interaction: { selectability: { mode: "single" } }
            });

        },
        renderer: function (oRm, oInput) {
            sap.viz.ui5.controls.VizFrameRenderer.render(oRm, oInput);

        },

        setChartData: function (oData) {
            const oDataset = new sap.viz.ui5.data.FlattenedDataset({
                dimensions: [{ name: "Weeks", value: "{Week}" }],
                measures: [
                   
                    { name: "Uplift", value: "{Uplift}" },
                     { name: "Baseline", value: "{Baseline}" },
                    { name: "ROI%", value: "{ROI}" }
                ],
                data: { path: "/" }
            });

            this.setDataset(oDataset);
            this.setModel(new sap.ui.model.json.JSONModel(oData));

            // Feeds
            this.removeAllFeeds();
            this.addFeed(new sap.viz.ui5.controls.common.feeds.FeedItem({
                uid: "categoryAxis",
                type: "Dimension",
                values: ["Weeks"]
            }));
            this.addFeed(new sap.viz.ui5.controls.common.feeds.FeedItem({
                uid: "valueAxis",
                type: "Measure",

                values: ["Uplift"]
            }));
            this.addFeed(new sap.viz.ui5.controls.common.feeds.FeedItem({
                uid: "valueAxis",
                type: "Measure",

                values: ["Baseline"]
            }));
            
            this.addFeed(new sap.viz.ui5.controls.common.feeds.FeedItem({
                uid: "valueAxis2",
                type: "Measure",
                values: ["ROI%"]
            }));
        }






    });
});
