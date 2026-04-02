CLASS zocl_tp4_plan_hdr_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zocl_tp4_plan_hdr_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    "Define deep entity type
    TYPES:
      BEGIN OF gty_deep,
        plan_id           TYPE zde_plan_id,
        vkorg             TYPE vkorg,
        vkorg_desc        TYPE vtxtk,
        vtweg             TYPE vtweg,
        vtweg_desc        TYPE vtxtk,
        plan_type         TYPE zde_plantype,
        plan_type_desc    TYPE zde_promo_description,
        plan_customer     TYPE zde_plan_customer,
        customer_name     TYPE name1_gp,
        order_date_f      TYPE zde_order_date_f,
        order_date_t      TYPE zde_order_date_t,
        buying_date_f     TYPE zde_buying_date_f,
        buying_date_t     TYPE zde_buying_date_t,
        instore_date_f    TYPE zde_instore_date_f,
        instore_date_t    TYPE zde_instore_date_t,
        status            TYPE zde_tp_status,
        status_desc       TYPE zde_tp_status_desc,
        description       TYPE zde_promo_description,
        objective_id      TYPE zde_objective,
        objective_desc    TYPE zde_obj_desc,
        tactic_id         TYPE zde_tactic,
        tactic_desc       TYPE zde_tactic_desc,
        contract_id       TYPE zde_agreement_id,
        fund_plan         TYPE zde_fund_plan_id,
        fund_plan_desc    TYPE zde_fund_plan_desc,
        status_group      TYPE zde_tp_status_grp,
        sa_id             TYPE zde_responsability_area,
        sa_name           TYPE text40,
        currency          TYPE waers,
        createdon         TYPE timestamp,
        createdby         TYPE ernam,
        changedon         TYPE timestamp,
        changedby         TYPE aenam,
        resp_user         TYPE syuname,
        resp_user_name    TYPE char80,
        linked_promo      TYPE zde_plan_id,
        ccm_int	          TYPE zde_ccm_int,
        fund_int          TYPE   zde_fund_int,
        plan_class        TYPE zde_plan_class,
        product_selection	TYPE zde_prod_sel,
        op_ind            TYPE char1,
        rls               TYPE char1,
        cls               TYPE char1,
        can               TYPE char1,
        ste               TYPE char1,
        to_item           TYPE TABLE OF ts_plan_item_oi WITH DEFAULT KEY,
        to_itemfg         TYPE TABLE OF ts_plan_item_fg WITH DEFAULT KEY,
        to_itemtotal      TYPE TABLE OF ts_plan_item_total WITH DEFAULT KEY,
        to_total          TYPE TABLE OF ts_plan_total WITH DEFAULT KEY,
        to_volume         TYPE TABLE OF ts_plan_volume WITH DEFAULT KEY,
      END OF gty_deep.

    "Products Deep entity
    TYPES:
      BEGIN OF gty_deep_products,
        vkorg             TYPE vkorg,
        vtweg             TYPE vtweg,
        plan_customer     TYPE zde_plan_customer,
        matnr             TYPE matnr,
        prodh	            TYPE prodh_d,
        brand             TYPE zde_zzbrand,
        subrand           TYPE zde_zzsubrand,
        buying_date_f     TYPE zde_buying_date_f,
        buying_date_t     TYPE zde_buying_date_t,
        uom               TYPE kmein,
        ppc               TYPE umren,
        to_product_volume TYPE TABLE OF ts_plan_volume WITH DEFAULT KEY,
      END OF gty_deep_products.

    METHODS define
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZOCL_TP4_PLAN_HDR_MPC_EXT IMPLEMENTATION.


  METHOD define.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   DEFINE                                           *
* Description: This method is used to update data model         *
*              for plan header service                          *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 30-07-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************


    DATA: lob_property    TYPE REF TO /iwbep/if_mgw_odata_property,
          lob_entity_type TYPE REF TO /iwbep/if_mgw_odata_entity_typ.


    super->define( ).

    lob_entity_type = model->get_entity_type('Plan_Header').
    "Add Product hierarchy field as we need it for filtering
    lob_property = lob_entity_type->create_property( iv_property_name = 'Prodh' iv_abap_fieldname = 'PRODH' ). "#EC NOTEXT
    lob_property->set_type_edm_string( ).
    lob_property->bind_data_element( 'PRODH_D' ).
    lob_property->set_filterable( abap_true ).

    "Add Brand field as we need it for filtering
    lob_property = lob_entity_type->create_property( iv_property_name = 'Brand' iv_abap_fieldname = 'BRAND' ). "#EC NOTEXT
    lob_property->set_type_edm_string( ).
    lob_property->bind_data_element( 'ZDE_ZZBRAND' ).
    lob_property->set_filterable( abap_true ).

    "Add Subbrand field as we need it for filtering
    lob_property = lob_entity_type->create_property( iv_property_name = 'Subbrand' iv_abap_fieldname = 'SUBBRAND' ). "#EC NOTEXT
    lob_property->set_type_edm_string( ).
    lob_property->bind_data_element( 'ZDE_ZZSUBRAND' ).
    lob_property->set_filterable( abap_true ).

    "Add deep structure
    lob_entity_type->bind_structure( iv_structure_name =
    'ZOCL_TP4_PLAN_HDR_MPC_EXT=>GTY_DEEP' ).

  ENDMETHOD.
ENDCLASS.