class ZOCL_TP4_PROMO_PLAN_MPC_EXT definition
  public
  inheriting from ZOCL_TP4_PROMO_PLAN_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZOCL_TP4_PROMO_PLAN_MPC_EXT IMPLEMENTATION.


  METHOD define.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   DEFINE                                           *
* Description: This method is used to update data model entity  *
*              and entity set names for all CDS View Entities   *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 29-07-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    super->define( ).

    DATA: lob_entity_type TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
          lob_entity_set  TYPE REF TO /iwbep/if_mgw_odata_entity_set,
          lob_property    TYPE REF TO /iwbep/if_mgw_odata_property.


    "Promo Plan: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_PromoPlanType').
    IF  lob_entity_type IS NOT INITIAL.
      lob_entity_type->set_name( iv_name = 'PromoPlan' ).

      "Set Properties
      lob_property = lob_entity_type->get_property('Vkorg').
      IF lob_property IS NOT INITIAL.
*        lob_property->set_nullable( abap_false ).
*        lob_property->set_updatable( abap_true ).
        lob_property->set_filterable( abap_true ).
        lob_property->set_sortable( abap_true ).
      ENDIF.
    ENDIF.
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_PromoPlan').
    lob_entity_set->set_name( iv_name = 'PromoPlanSet' ).



    "Tactics: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_TACTICSType').
    lob_entity_type->set_name( iv_name = 'Tactics' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_TACTICS').
    lob_entity_set->set_name( iv_name = 'TacticsSet' ).

    "Objective: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_OBJECTIVEType').
    lob_entity_type->set_name( iv_name = 'Objective' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_OBJECTIVE').
    lob_entity_set->set_name( iv_name = 'ObjectiveSet' ).

    "Spend: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_SPENDType').
    lob_entity_type->set_name( iv_name = 'Spend' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_SPEND').
    lob_entity_set->set_name( iv_name = 'SpendSet' ).

    "Status: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_STATUSType').
    lob_entity_type->set_name( iv_name = 'Status' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_STATUS').
    lob_entity_set->set_name( iv_name = 'StatusSet' ).

    "Sales Organization: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_SALES_ORGType').
    lob_entity_type->set_name( iv_name = 'SalesOrg' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_SALES_ORG').
    lob_entity_set->set_name( iv_name = 'SalesOrgSet' ).

    "Distribution Channel: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_DISTRIBUTION_CHANNELType').
    lob_entity_type->set_name( iv_name = 'DistCh' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_DISTRIBUTION_CHANNEL').
    lob_entity_set->set_name( iv_name = 'DistChSet' ).

    "Fund Plan: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_FUNDS_PLANType').
    lob_entity_type->set_name( iv_name = 'FundPlan' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_FUNDS_PLAN').
    lob_entity_set->set_name( iv_name = 'FundPlanSet' ).

    "Sales Area: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_SALES_AREAType').
    lob_entity_type->set_name( iv_name = 'SalesArea' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_SALES_AREA').
    lob_entity_set->set_name( iv_name = 'SalesAreaSet' ).

    "Selling SKU: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_SKUType').
    lob_entity_type->set_name( iv_name = 'SellingSKU' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_SKU').
    lob_entity_set->set_name( iv_name = 'SellingSKUSet' ).

    "Sub-brand: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_SUBBRANDType').
    lob_entity_type->set_name( iv_name = 'Subbrand' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_SUBBRAND').
    lob_entity_set->set_name( iv_name = 'SubbrandSet' ).

    "Brand: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_BRANDType').
    lob_entity_type->set_name( iv_name = 'Brand' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_BRAND').
    lob_entity_set->set_name( iv_name = 'BrandSet' ).

    "Currency: Set Entity Type and Entity Set name
    lob_entity_type = model->get_entity_type( 'ZCDS_TP4_CURRType').
    lob_entity_type->set_name( iv_name = 'Currency' ).
    lob_entity_set = model->get_entity_set( 'ZCDS_TP4_CURR').
    lob_entity_set->set_name( iv_name = 'CurrSet' ).

  ENDMETHOD.
ENDCLASS.