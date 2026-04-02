class ZOCL_TP4_PROMO_PLAN_DPC_EXT definition
  public
  inheriting from ZOCL_TP4_PROMO_PLAN_DPC
  create public .

public section.
protected section.

  methods I_SALESORGANIZAT_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_BRAND_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_CURR_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_DISTRIB_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_FUNDS_P_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_OBJECTI_GET_ENTITY
    redefinition .
  methods ZCDS_TP4_OBJECTI_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_PROMOPL_GET_ENTITY
    redefinition .
  methods ZCDS_TP4_PROMOPL_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_SALES01_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_SALES_A_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_SKU_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_SPEND_GET_ENTITY
    redefinition .
  methods ZCDS_TP4_SPEND_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_STATUS_GET_ENTITY
    redefinition .
  methods ZCDS_TP4_STATUS_GET_ENTITYSET
    redefinition .
  methods ZCDS_TP4_SUBBRAN_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZOCL_TP4_PROMO_PLAN_DPC_EXT IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->I_SALESORGANIZAT_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_I_SALESORGANIZATIONTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD i_salesorganizat_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   I_SALESORGANIZAT_GET_ENTITYSET                   *
* Description: This method is used to add value help logic      *
*              for Sales Organization filter                    *                                             *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 07-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_vkorg  TYPE RANGE OF vkorg,
          lt_filter TYPE /iwbep/t_mgw_select_option.

*    lt_filter = it_filter_select_options.
*
*    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
*      CASE <lfs_filter>-property.
*
*        WHEN 'Vkorg'.
*          "Fill Sales Organization filter values
*          lt_vkorg = VALUE #( FOR ls_vkorg IN <lfs_filter>-select_options
*                              ( sign = 'I'
*                              option = 'EQ'
*                              low = ls_vkorg-low ) ).
*        WHEN 'Vtweg'.
*          "Fill Distribution Channel filter values
*          lt_vtweg = VALUE #( FOR ls_vtweg IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_vtweg-low ) ).
*        WHEN 'PlanType'.
*          "Fill Plan Type filter values
*          lt_plan_type = VALUE #( FOR ls_plan_type IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_plan_type-low ) ).
*
*      ENDCASE.
*    ENDLOOP.

    "Fetch Sales Org data
    SELECT SalesOrganization,
           \_Text-SalesOrganizationName
           FROM I_SalesOrganization
           WHERE \_Text-Language = @sy-langu
*           AND vtweg IN @lt_vtweg
*           AND plantype IN @lt_plan_type
           INTO TABLE @et_entityset.
    IF sy-subrc <> 0.
      CLEAR et_entityset.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_DISTRIB_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_DISTRIBUTION_CHANN
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_distrib_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_DISTRIB_GET_ENTITYSET                  *
* Description: This method is used to add value help logic      *
*              for Distribution Channel filter                  *                                             *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 11-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_filter     TYPE /iwbep/t_mgw_select_option,
          lr_ind        TYPE RANGE OF char1,
          lr_vtweg_fill TYPE RANGE OF vtweg,
          lt_vtweg      TYPE RANGE OF vtweg.

    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.
        WHEN 'f4_ind'.
          "Fill indicator value
          lr_ind = CORRESPONDING #( <lfs_filter>-select_options ).
*          lr_ind = VALUE #( FOR ls_ind IN <lfs_filter>-select_options
*                          ( sign = 'I'
*                            option = 'EQ'
*                            low = ls_ind-low ) ).
        WHEN 'DistCh'.
          "Fill Distribution Channel
          lt_vtweg = CORRESPONDING #( <lfs_filter>-select_options ).

      ENDCASE.
    ENDLOOP.

    "Filter Sales Organization based on authorization
    zcl_tp4_plan_check=>m_check_auth( IMPORTING  er_vtweg = DATA(lr_vtweg)
                                                 et_access = DATA(lt_access) ).

    "Filter sales Organization based on create/display
    DATA(lv_ind) = VALUE #( lr_ind[ 1 ]-low OPTIONAL ).
    IF lv_ind = 'C'.
      lr_vtweg_fill = VALUE #( FOR ls_vtweg IN lt_access WHERE ( access = 'E' )
                              ( sign = 'I'
                                option = 'EQ'
                                low = ls_vtweg-vtweg ) ).
      SORT lr_vtweg_fill BY low.
      DELETE ADJACENT DUPLICATES FROM lr_vtweg_fill COMPARING low.
    ELSE.
      lr_vtweg_fill = CORRESPONDING #( lr_vtweg ).
    ENDIF.

    "Fetch Promo Objective data
    SELECT distch,
           language,
           description
           FROM zcds_tp4_distribution_channel
           WHERE language = @sy-langu
           AND ( distch IN @lr_vtweg_fill AND
                 distch IN @lt_vtweg )
*           AND vtweg IN @lt_vtweg
*           AND plantype IN @lt_plan_type
*           AND objectiveid IN @lt_objective_id
           INTO CORRESPONDING FIELDS OF TABLE @et_entityset.
    IF sy-subrc = 0.
      SORT et_entityset BY distch.
      DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING distch.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_FUNDS_P_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_FUNDS_PLANTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_funds_p_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_FUNDS_P_GET_ENTITYSET                   *
* Description: This method is used to add filter logic          *
*              for Fund plan                                    *                                          *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 12-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_vkorg  TYPE RANGE OF vkorg,
          lt_status TYPE RANGE OF zde_tp_status,
          lt_filter TYPE /iwbep/t_mgw_select_option,
          lt_fundid TYPE RANGE OF char10."zde_fund_id.


    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'Vkorg'
         OR  'Salesorg'.
          "Fill Sales Organization filter values
          lt_vkorg = CORRESPONDING #( <lfs_filter>-select_options ).
*          lt_vkorg = VALUE #( FOR ls_vkorg IN <lfs_filter>-select_options
*                              ( sign = 'I'
*                              option = 'EQ'
*                              low = ls_vkorg-low ) ).

        WHEN 'Status'.
          "Fill Status filter values
          lt_status = CORRESPONDING #( <lfs_filter>-select_options ).
*          lt_status = VALUE #( FOR ls_status IN <lfs_filter>-select_options
*                              ( sign = 'I'
*                              option = 'EQ'
*                              low = ls_status-low ) ).

        WHEN 'Fundplanid'.
          "Fill Fund ID filter values
          lt_fundid = CORRESPONDING #( <lfs_filter>-select_options ).

      ENDCASE.
    ENDLOOP.

    "Fetch Fund Plan data
    SELECT fundplanid,
           description,
           salesorg
           FROM zcds_tp4_funds_plan
           WHERE salesorg IN @lt_vkorg
             AND status   IN @lt_status
             AND fundplanid IN @lt_fundid
           INTO CORRESPONDING FIELDS OF TABLE @et_entityset.
    IF sy-subrc = 0.
      SORT et_entityset BY fundplanid.
      DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING fundplanid.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_OBJECTI_GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_REQUEST_OBJECT              TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TS_ZCDS_TP4_OBJECTIVETYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_objecti_get_entity.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_OBJECTI_GET_ENTITY                      *
* Description: This method is used to get unique Promo Object   *
*              data based on key values                         *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 31-07-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

**TRY.
*CALL METHOD SUPER->ZCDS_TP4_OBJECTI_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.


    "Data declarations
    DATA: lv_client    TYPE mandt,
          lv_vkorg     TYPE vkorg,
          lv_vtweg     TYPE vtweg,
          lv_plan_type TYPE zde_plantype,
          lv_object_id TYPE zde_objective.


    "Get Key value
*    lv_client = VALUE #( it_key_tab[ name = 'Mandt' ]-value OPTIONAL ).
    lv_vkorg  = VALUE #( it_key_tab[ name = 'Vkorg' ]-value OPTIONAL ).
    lv_vtweg  = VALUE #( it_key_tab[ name = 'Vtweg' ]-value OPTIONAL ).
    lv_plan_type = VALUE #( it_key_tab[ name = 'PlanType' ]-value OPTIONAL ).
    lv_object_id = VALUE #( it_key_tab[ name = 'ObjectiveId' ]-value OPTIONAL ).


    IF lv_vkorg <> abap_false
      AND lv_vtweg <> abap_false
      AND lv_plan_type <> abap_false
      AND lv_object_id <> abap_false.
      "Fetch Promo Object data
      SELECT SINGLE *
        FROM zcds_tp4_objective
        INTO CORRESPONDING FIELDS OF @er_entity
        WHERE vkorg = @lv_vkorg
        AND vtweg = @lv_vtweg
        AND plantype = @lv_plan_type
        AND objectiveid = @lv_object_id.
      IF sy-subrc NE 0.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message = 'No data found'.
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_OBJECTI_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_OBJECTIVETYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_objecti_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_OBJECTI_GET_ENTITYSET                   *
* Description: This method is used to add filter logic          *
*              for Promo objective per Sales Org & Promo plan   *
*              type                                             *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 31-07-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_vkorg        TYPE RANGE OF vkorg,
          lt_vtweg        TYPE RANGE OF vtweg,
          lt_plan_type    TYPE RANGE OF zde_plantype,
          lt_objective_id TYPE RANGE OF zde_objective,
          lt_filter       TYPE /iwbep/t_mgw_select_option.


    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'Vkorg'.
          "Fill Sales Organization filter values
          lt_vkorg = corresponding #( <lfs_filter>-select_options ).
*          lt_vkorg = VALUE #( FOR ls_vkorg IN <lfs_filter>-select_options
*                              ( sign = 'I'
*                              option = 'EQ'
*                              low = ls_vkorg-low ) ).
        WHEN 'Vtweg'.
          "Fill Distribution Channel filter values
          lt_vtweg = corresponding #( <lfs_filter>-select_options ).
*          lt_vtweg = VALUE #( FOR ls_vtweg IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_vtweg-low ) ).
        WHEN 'PlanType'.
          "Fill Plan Type filter values
          lt_plan_type = corresponding #( <lfs_filter>-select_options ).
*          lt_plan_type = VALUE #( FOR ls_plan_type IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_plan_type-low ) ).
        WHEN 'ObjectiveId'.
          "Fill Objective id From filter values
          lt_objective_id = corresponding #( <lfs_filter>-select_options ).
*          lt_objective_id = VALUE #( FOR ls_objective IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_objective-low ) ).
      ENDCASE.
    ENDLOOP.

    "Fetch Promo Objective data
    SELECT vkorg,
           vtweg,
           plantype,
           objectiveid,
           description
           FROM zcds_tp4_objective
           WHERE vkorg IN @lt_vkorg
           AND vtweg IN @lt_vtweg
           AND plantype IN @lt_plan_type
           AND objectiveid IN @lt_objective_id
           INTO CORRESPONDING FIELDS OF TABLE @et_entityset.
    IF sy-subrc = 0.
      SORT et_entityset BY vkorg vtweg plantype objectiveid.
      DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING vkorg vtweg plantype objectiveid.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_PROMOPL_GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_REQUEST_OBJECT              TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TS_ZCDS_TP4_PROMOPLANTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_promopl_get_entity.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_PROMOPL_GET_ENTITY                      *
* Description: This method is used to get unique Promo Plan     *
*              General Configuration data based on key values   *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 01-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lv_vkorg     TYPE vkorg,
          lv_vtweg     TYPE vtweg,
          lv_plan_type TYPE zde_plantype.


    "Get Key value
    lv_vkorg  = VALUE #( it_key_tab[ name = 'Vkorg' ]-value OPTIONAL ).
    lv_vtweg  = VALUE #( it_key_tab[ name = 'Vtweg' ]-value OPTIONAL ).
    lv_plan_type = VALUE #( it_key_tab[ name = 'PlanType' ]-value OPTIONAL ).

    IF lv_vkorg <> abap_false
      AND lv_vtweg <> abap_false
      AND lv_plan_type <> abap_false.

      "Fetch Promo Object data
      SELECT SINGLE *
        FROM zcds_tp4_promoplan
        INTO CORRESPONDING FIELDS OF @er_entity
        WHERE vkorg = @lv_vkorg
        AND vtweg = @lv_vtweg
        AND plantype = @lv_plan_type.
      IF sy-subrc NE 0.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message = 'No data found'.
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_PROMOPL_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_PROMOPLANTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_promopl_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_PROMOPL_GET_ENTITYSET                   *
* Description: This method is used to add filter logic          *
*              for Promo Plan General Configuration             *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 01-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

**TRY.
*CALL METHOD SUPER->ZCDS_TP4_PROMOPL_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

    "Data declarations
    DATA: lt_vkorg     TYPE RANGE OF vkorg,
          lt_vtweg     TYPE RANGE OF vtweg,
          lt_plan_type TYPE RANGE OF zde_plantype,
          lt_filter    TYPE /iwbep/t_mgw_select_option.


    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'Vkorg'.
          "Fill Sales Organization filter values
          lt_vkorg = corresponding #( <lfs_filter>-select_options ).
*          lt_vkorg = VALUE #( FOR ls_vkorg IN <lfs_filter>-select_options
*                              ( sign = 'I'
*                              option = 'EQ'
*                              low = ls_vkorg-low ) ).
        WHEN 'Vtweg'.
          "Fill Distribution Channel filter values
          lt_vtweg = corresponding #( <lfs_filter>-select_options ).
*          lt_vtweg = VALUE #( FOR ls_vtweg IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_vtweg-low ) ).
        WHEN 'PlanType'.
          "Fill Plan Type filter values
          lt_plan_type = corresponding #( <lfs_filter>-select_options ).
*          lt_plan_type = VALUE #( FOR ls_plan_type IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_plan_type-low ) ).

      ENDCASE.
    ENDLOOP.

    "Fetch Promo Plan data
    SELECT vkorg,
           vtweg,
           plantype,
           planclass,
           description,
           maxtactics
           FROM zcds_tp4_promoplan
           INTO CORRESPONDING FIELDS OF TABLE @et_entityset
           WHERE vkorg IN @lt_vkorg
           AND vtweg IN @lt_vtweg
           AND plantype IN @lt_plan_type.
    IF sy-subrc = 0.
      SORT et_entityset BY vkorg vtweg plantype.
      DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING vkorg vtweg plantype.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_SPEND_GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_REQUEST_OBJECT              TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TS_ZCDS_TP4_SPENDTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_spend_get_entity.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_SPEND_GET_ENTITY                        *
* Description: This method is used to get unique Spend type per *
*              SO, Promo plan type, Objective & Tactic          *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 01-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************


    "Data declarations
    DATA: lv_vkorg      TYPE vkorg,
          lv_vtweg      TYPE vtweg,
          lv_plan_type  TYPE zde_plantype,
          lv_object_id  TYPE zde_objective,
          lv_tactic_id  TYPE zde_tactic,
          lv_spend_type TYPE zde_spend_type.


    "Get Key value
    lv_vkorg  = VALUE #( it_key_tab[ name = 'Vkorg' ]-value OPTIONAL ).
    lv_vtweg  = VALUE #( it_key_tab[ name = 'Vtweg' ]-value OPTIONAL ).
    lv_plan_type = VALUE #( it_key_tab[ name = 'PlanType' ]-value OPTIONAL ).
    lv_object_id = VALUE #( it_key_tab[ name = 'ObjectiveId' ]-value OPTIONAL ).
    lv_tactic_id = VALUE #( it_key_tab[ name = 'TacticId' ]-value OPTIONAL ).
    lv_spend_type = VALUE #( it_key_tab[ name = 'SpendType' ]-value OPTIONAL ).

    IF lv_vkorg <> abap_false
      AND lv_vtweg <> abap_false
      AND lv_plan_type <> abap_false
      AND lv_object_id <> abap_false
      AND lv_tactic_id <> abap_false
      AND lv_spend_type <> abap_false.
      "Fetch Promo Object data
      SELECT SINGLE *
        FROM zcds_tp4_spend
        INTO CORRESPONDING FIELDS OF @er_entity
        WHERE vkorg = @lv_vkorg
        AND vtweg = @lv_vtweg
        AND plantype = @lv_plan_type
        AND objectiveid = @lv_object_id
        AND tacticid = @lv_tactic_id
        AND spendtype = @lv_spend_type.
      IF sy-subrc NE 0.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message = 'No data found'.
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_SPEND_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_SPENDTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_spend_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_TACTICS_GET_ENTITYSET                   *
* Description: This method is used to add filter logic          *
*              for Spend type per SO, Promo plan type, Objective*
*              & Tactic                                         *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 01-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_vkorg        TYPE RANGE OF vkorg,
          lt_vtweg        TYPE RANGE OF vtweg,
          lt_plan_type    TYPE RANGE OF zde_plantype,
          lt_objective_id TYPE RANGE OF zde_objective,
          lt_tactic_id    TYPE RANGE OF zde_tactic,
          "  lt_spend_type   TYPE RANGE OF zde_spend_type,
          "lt_spend_cls    TYPE RANGE OF zde_spend_type_class,
          lt_filter       TYPE /iwbep/t_mgw_select_option.


    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'Vkorg'.
          "Fill Sales Organization filter values
          lt_vkorg = corresponding #( <lfs_filter>-select_options ).
*          lt_vkorg = VALUE #( FOR ls_vkorg IN <lfs_filter>-select_options
*                              ( sign = 'I'
*                              option = 'EQ'
*                              low = ls_vkorg-low ) ).
        WHEN 'Vtweg'.
          "Fill Distribution Channel filter values
          lt_vtweg = corresponding #( <lfs_filter>-select_options ).
*          lt_vtweg = VALUE #( FOR ls_vtweg IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_vtweg-low ) ).
        WHEN 'PlanType'.
          "Fill Plan Type filter values
          lt_plan_type = corresponding #( <lfs_filter>-select_options ).
*          lt_plan_type = VALUE #( FOR ls_plan_type IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_plan_type-low ) ).
        WHEN 'ObjectiveId'.
          "Fill Objective id From filter values
          lt_objective_id = corresponding #( <lfs_filter>-select_options ).
*          lt_objective_id = VALUE #( FOR ls_objective IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_objective-low ) ).

        WHEN 'TacticId'.
          "Fill Tactic id From filter values
          lt_tactic_id = corresponding #( <lfs_filter>-select_options ).
*          lt_tactic_id = VALUE #( FOR ls_tactic IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_tactic-low ) ).

*        WHEN 'SpendType'.
*          "Fill Spend Type From filter values
*          lt_spend_type = VALUE #( FOR ls_spend IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_spend-low ) ).

*        WHEN 'SpendTypeClass'.
*          "Fill Spend Type Class From filter values
*          lt_spend_cls = VALUE #( FOR ls_spend_cl IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_spend_cl-low ) ).
      ENDCASE.
    ENDLOOP.

    "Filter Status group based on authorization
    zcl_tp4_plan_check=>m_check_auth( IMPORTING er_status_grp = DATA(lt_status_grp_auth)
                                                er_vkorg      = DATA(lr_vkorg)
                                                er_plantype   = DATA(lr_plantype)
                                                et_access     = DATA(lt_access) ).

    "Fetch Spend type data
    SELECT Vkorg,
           Vtweg,
           PlanType,
           ObjectiveId,
           TacticId,
           spendmethod,
           spendalloc,
           SpendType,
           spendtypeclass,
           description,
           tacticsdesc
           FROM zcds_tp4_spend
           WHERE ( vkorg IN @lt_vkorg
             AND   vkorg IN @lr_vkorg )
             AND vtweg IN @lt_vtweg
             AND ( plantype IN @lt_plan_type
             AND   plantype IN @lr_plantype )
             AND objectiveid IN @lt_objective_id
             AND tacticid IN @lt_tactic_id
*           AND spendtypeclass = 'OI'
           "AND spendtype IN @lt_spend_type
           INTO CORRESPONDING FIELDS OF TABLE @et_entityset.
    IF sy-subrc = 0.
      SORT et_entityset BY vkorg vtweg plantype objectiveid tacticid spendtype.
      DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING vkorg vtweg plantype objectiveid tacticid spendtype.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_STATUS_GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_REQUEST_OBJECT              TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TS_ZCDS_TP4_STATUSTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_status_get_entity.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_STATUS_GET_ENTITY                       *
* Description: This method is used to get unique Available      *
*              status                                           *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 01-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************


    "Data declarations
    DATA: lv_status_grp TYPE zde_tp_status_grp,
          lv_status     TYPE zde_tp_status.


    "Get Key value
    lv_status_grp = VALUE #( it_key_tab[ name = 'Statusgroup' ]-value OPTIONAL ).
    lv_status = VALUE #( it_key_tab[ name = 'Status' ]-value OPTIONAL ).


    IF lv_status_grp <> abap_false
      AND  lv_status <> abap_false.
      "Fetch Promo Object data
      SELECT SINGLE *
        FROM zcds_tp4_status
        INTO CORRESPONDING FIELDS OF @er_entity
        WHERE statusgroup = @lv_status_grp
        AND status = @lv_status.
      IF sy-subrc NE 0.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message = 'No data found'.
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_STATUS_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_STATUSTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_status_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_STATUS_GET_ENTITYSET                    *
* Description: This method is used to add filter logic          *
*              for Available status                             *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 01-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_plan_type            TYPE RANGE OF zde_plantype,
          lr_plan_type_fill       TYPE RANGE OF zde_plantype,
          lr_vkorg_fill           TYPE RANGE OF vkorg,
          lt_vkorg                TYPE RANGE OF vkorg,
          lt_status_grp           TYPE RANGE OF zde_tp_status_grp,
          lt_status               TYPE RANGE OF zde_tp_status,
          lt_old_status           TYPE RANGE OF zde_tp_status,
          lt_new_status           TYPE RANGE OF zde_tp_status,
          lt_filter               TYPE /iwbep/t_mgw_select_option,
          lr_ind                  TYPE RANGE OF char1,
          lr_status_grp_auth_fill TYPE RANGE OF zde_tp_status_grp,
          lt_filter_table         TYPE zocl_tp4_promo_plan_mpc=>tt_zcds_tp4_statustype.


    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.
*        WHEN 'Statusgroup'.
*          "Fill Tactic id From filter values
*          lt_status_grp = VALUE #( FOR ls_sts_grp IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_sts_grp-low ) ).
*
        WHEN 'Status'.
*          "Fill Spend Type From filter values
          lt_status = CORRESPONDING #( <lfs_filter>-select_options ).
*          lt_status = VALUE #( FOR ls_status IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_status-low ) ).
        WHEN 'PlanType'.
          "Fill Plan Type From filter values
          lt_plan_type = CORRESPONDING #( <lfs_filter>-select_options ).
*          lt_plan_type = VALUE #( FOR ls_plan IN <lfs_filter>-select_options
*                                         ( sign = 'I'
*                                         option = 'EQ'
*                                         low = ls_plan-low ) ).

        WHEN 'f4_ind'.
          "Fill indicator value
          lr_ind = CORRESPONDING #( <lfs_filter>-select_options ).
*          lr_ind = VALUE #( FOR ls_ind IN <lfs_filter>-select_options
*                          ( sign = 'I'
*                            option = 'EQ'
*                            low = ls_ind-low ) ).
      ENDCASE.
    ENDLOOP.

    "Filter Status group based on authorization
    zcl_tp4_plan_check=>m_check_auth( IMPORTING er_status_grp = DATA(lt_status_grp_auth)
                                                er_vkorg      = DATA(lr_vkorg)
                                                er_plantype   = DATA(lr_plantype)
                                                et_access = DATA(lt_access) ).


    "Filter sales Organization based on create/display
    DATA(lv_ind) = VALUE #( lr_ind[ 1 ]-low OPTIONAL ).
    IF lv_ind = 'C'.
      lr_status_grp_auth_fill = VALUE #( FOR ls_st_grp IN lt_access WHERE ( access = 'E' )
                              ( sign = 'I'
                                option = 'EQ'
                                low = ls_st_grp-status_grp ) ).
      SORT lr_status_grp_auth_fill BY low.
      DELETE ADJACENT DUPLICATES FROM lr_status_grp_auth_fill COMPARING low.
      lr_vkorg_fill = VALUE #( FOR ls_vkorg IN lt_access WHERE ( access = 'E' )
                              ( sign = 'I'
                                option = 'EQ'
                                low = ls_vkorg-vkorg ) ).
      SORT lr_vkorg_fill BY low.
      DELETE ADJACENT DUPLICATES FROM lr_vkorg_fill COMPARING low.
      lr_plan_type_fill = VALUE #( FOR ls_plantype IN lt_access WHERE ( access = 'E' )
                              ( sign = 'I'
                                option = 'EQ'
                                low = ls_plantype-plan_type ) ).
      SORT lr_plan_type_fill BY low.
      DELETE ADJACENT DUPLICATES FROM lr_plan_type_fill COMPARING low.
    ELSE.
      lr_status_grp_auth_fill = CORRESPONDING #( lt_status_grp_auth ).
      lr_vkorg_fill           = CORRESPONDING #( lr_vkorg ).
      lr_plan_type_fill       = CORRESPONDING #( lr_plantype ).
    ENDIF.

    IF lt_status_grp_auth IS NOT INITIAL.
      "Fetch Status Group
      SELECT vkorg,
             vtweg,
             plan_type,
             statusgroup
             FROM zttp4_c_promopln
             WHERE   vkorg        IN @lr_vkorg_fill
               AND ( plan_type    IN @lt_plan_type
               AND   plan_type    IN @lr_plan_type_fill )
               AND   statusgroup  IN @lr_status_grp_auth_fill
             INTO TABLE @DATA(lt_status_group).
      IF sy-subrc = 0.
        "Fill Status group range
        lt_status_grp = VALUE #( FOR ls_grp IN lt_status_group
                                                 ( sign = 'I'
                                                 option = 'EQ'
                                                 low = ls_grp-statusgroup ) ).
        SORT lt_status_grp BY low.
        DELETE ADJACENT DUPLICATES FROM lt_status_grp COMPARING low.

        CASE lv_ind.
          WHEN 'C'."Creation page
            "Fetch Status data for creation page
            SELECT statusgroup,
            status,
            initialstatus,
            statusorder,
            description,
            edit,
            statfrom,
            statto,
            promobp
            FROM zcds_tp4_status
            WHERE statusgroup IN @lt_status_grp
              AND spras        = @sy-langu
              AND edit         = @abap_true
              AND status      IN @lt_status
              INTO CORRESPONDING FIELDS OF TABLE @et_entityset.
            CHECK sy-subrc = 0.
            SORT et_entityset BY statusgroup status.
            DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING statusgroup status.

            "Get valid status to change
*            SELECT SINGLE statusgroup,
*            status,
*            initialstatus,
*            statusorder,
*            description,
*            edit,
*            statfrom,
*            statto
*             FROM zcds_tp4_status
*             WHERE statusgroup IN @lt_status_grp
*               AND edit         = @abap_true
*               AND status      IN @lt_status
*            INTO @DATA(ls_old_status).
*            CHECK sy-subrc = 0.
*            lt_filter_table = VALUE #( FOR ls_status_new IN et_entityset
*                           WHERE ( statfrom = ls_old_status-statusorder
*                           AND ( statusorder BETWEEN ls_old_status-statfrom AND ls_old_status-statto ) )
**                               AND status <> ls_old_status-status )
*                                ( statusgroup = ls_status_new-statusgroup
*                                  status = ls_status_new-status
*                                  initialstatus = ls_status_new-initialstatus
*                                  statusorder = ls_status_new-statusorder
*                                  description = ls_status_new-description
*                                  edit = ls_status_new-edit
*                                  statfrom = ls_status_new-statfrom
*                                  statto = ls_status_new-statto ) ).

*            et_entityset = CORRESPONDING #( lt_filter_table ).

          WHEN 'D' "Landing page
           OR  space.
            "Fetch Status data for landing page
            SELECT statusgroup,
            status,
            initialstatus,
            statusorder,
            description,
            edit
            FROM zcds_tp4_status
            WHERE statusgroup IN @lt_status_grp
              AND spras        = @sy-langu
              AND status      IN @lt_status
            INTO CORRESPONDING FIELDS OF TABLE @et_entityset.
            IF sy-subrc = 0.
              SORT et_entityset BY statusgroup status.
              DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING statusgroup status.
            ENDIF.
        ENDCASE.
        "Fetch Status data
*        SELECT statusgroup,
*        status,
*        initialstatus,
*        statusorder,
*        description,
*        edit
*        FROM zcds_tp4_status
*        WHERE statusgroup IN @lt_status_grp
*        AND spras = @sy-langu
**      AND status IN @lt_status
*        INTO CORRESPONDING FIELDS OF TABLE @et_entityset.
*        IF sy-subrc = 0.
*          SORT et_entityset BY statusgroup status.
*          DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING statusgroup status.
*        ENDIF.
      ENDIF.
    ENDIF.

*    "Fetch Promo Objective data
*    SELECT statusgroup,
*    status,
*    initialstatus,
*    statusorder,
*    description
*    FROM zcds_tp4_status
*    WHERE statusgroup IN @lt_status_grp
*    AND status IN @lt_status
*    INTO TABLE @et_entityset.
*    IF sy-subrc <> 0.
*      CLEAR et_entityset.
*    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_SALES_A_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_SALES_AREATYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_sales_a_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_SALES_A_GET_ENTITYSET                   *
* Description: This method is used to add value help logic      *
*              for Sales Area                                   *                                             *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 20-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_vkorg  TYPE RANGE OF vkorg,
          lt_vtweg  TYPE RANGE OF vtweg,
          lt_filter TYPE /iwbep/t_mgw_select_option,
          lr_ind    TYPE RANGE OF char1,
          lt_sa_id  TYPE RANGE OF zde_responsability_area .


    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'Vkorg'.
          "Fill Sales Organization filter values
          lt_vkorg = corresponding #( <lfs_filter>-select_options ).
*          lt_vkorg = VALUE #( FOR ls_vkorg IN <lfs_filter>-select_options
*                              ( sign = 'I'
*                              option = 'EQ'
*                              low = ls_vkorg-low ) ).
        WHEN 'Vtweg'.
          "Fill Distribution Channel filter values
          lt_vtweg = corresponding #( <lfs_filter>-select_options ).
*          lt_vtweg = VALUE #( FOR ls_vtweg IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_vtweg-low ) ).
        WHEN 'Vtweg'.
          "Fill Distribution Channel filter values
          lt_vtweg = corresponding #( <lfs_filter>-select_options ).

        WHEN 'SaId'.
          "Fill Sales Area
          lt_sa_id = corresponding #( <lfs_filter>-select_options ).

        WHEN 'f4_ind'.
          "Fill F4 Ind
          lr_ind = corresponding #( <lfs_filter>-select_options ).

      ENDCASE.
    ENDLOOP.

    "Fetch Sales area data
    zcl_tp4_promoplan=>m_get_sales_area(
    EXPORTING it_vkorg = lt_vkorg
              it_vtweg = lt_vtweg
              it_ind = lr_ind
              it_sa_id = lt_sa_id
    IMPORTING et_sales_area = DATA(lt_sales_area) ).

    et_entityset = CORRESPONDING #( lt_sales_area ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_SKU_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_SKUTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_sku_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_SKU_GET_ENTITYSET                       *
* Description: This method is used to add value help logic      *
*              for Selling SKU                                  *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 21-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_vkorg  TYPE RANGE OF vkorg,
          lt_vtweg  TYPE RANGE OF vtweg,
          lt_filter TYPE /iwbep/t_mgw_select_option.


    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'Vkorg'.
          "Fill Sales Organization filter values
          lt_vkorg = corresponding #( <lfs_filter>-select_options ).
*          lt_vkorg = VALUE #( FOR ls_vkorg IN <lfs_filter>-select_options
*                              ( sign = 'I'
*                              option = 'EQ'
*                              low = ls_vkorg-low ) ).
        WHEN 'Vtweg'.
          "Fill Distribution Channel filter values
          lt_vtweg = corresponding #( <lfs_filter>-select_options ).
*          lt_vtweg = VALUE #( FOR ls_vtweg IN <lfs_filter>-select_options
*                               ( sign = 'I'
*                               option = 'EQ'
*                               low = ls_vtweg-low ) ).
      ENDCASE.
    ENDLOOP.

    "Fetch Selling SKU data
    zcl_tp4_promoplan=>m_get_selling_sku(
    EXPORTING it_vkorg = lt_vkorg
              it_vtweg = lt_vtweg
    IMPORTING et_selling_sku = DATA(lt_selling_sku) ).

    et_entityset = CORRESPONDING #( lt_selling_sku ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_SALES01_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_SALES_ORGTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_sales01_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_SALES01_GET_ENTITYSET                   *
* Description: This method is used to add value help logic      *
*              for Sales Organization                           *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 21-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_filter TYPE /iwbep/t_mgw_select_option,
          lr_ind    TYPE RANGE OF char1,
          lt_vkorg  TYPE RANGE OF vkorg.

    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.
        WHEN 'f4_ind'.
          "Fill indicator value
          lr_ind = corresponding #( <lfs_filter>-select_options ).
*          lr_ind = VALUE #( FOR ls_ind IN <lfs_filter>-select_options
*                          ( sign = 'I'
*                            option = 'EQ'
*                            low = ls_ind-low ) ).
        WHEN 'SalesOrg'.
          "Fill indicator value
          lt_vkorg = corresponding #( <lfs_filter>-select_options ).

      ENDCASE.
    ENDLOOP.
    "Fetch Sales Organization data
    zcl_tp4_promoplan=>m_sales_org(
    EXPORTING it_ind      = lr_ind
              it_vkorg    = lt_vkorg
    IMPORTING et_salesorg = DATA(lt_salesorg) ).

    et_entityset = CORRESPONDING #( lt_salesorg ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_SUBBRAN_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_SUBBRANDTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_subbran_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_SUBBRAN_GET_ENTITYSET                   *
* Description: This method is used to add value help logic      *
*              for Sub-brand                                    *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 21-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************
    "Data declarations
    DATA: lt_filter  TYPE /iwbep/t_mgw_select_option,
          lr_ind     TYPE RANGE OF char1,
          lr_subrand TYPE RANGE OF zde_zzsubrand,
          lr_subdesc TYPE RANGE OF zde_zzsubdesc.

    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'Subrand'.
          "Fill Brand filter values
          LOOP AT <lfs_filter>-select_options ASSIGNING FIELD-SYMBOL(<lfs_so>).
            APPEND VALUE #(  low = to_upper( <lfs_so>-low ) high = to_upper( <lfs_so>-high ) option =  <lfs_so>-option sign = <lfs_so>-sign  ) TO lr_subrand.
          ENDLOOP.

        WHEN 'Subdesc'.
          "Fill Brand filter values
          LOOP AT <lfs_filter>-select_options ASSIGNING <lfs_so>.
            APPEND VALUE #(  low = to_upper( <lfs_so>-low ) high = to_upper( <lfs_so>-high ) option =  <lfs_so>-option sign = <lfs_so>-sign  ) TO lr_subdesc.
          ENDLOOP.

      ENDCASE.
    ENDLOOP.

    IF lr_subdesc IS INITIAL.
       lr_subdesc = lr_subrand.
    ENDIF.

    "Fetch Product Hierarchy data
    zcl_tp4_promoplan=>m_get_subrand(
      EXPORTING
        it_subbrand = lr_subrand
        it_subdesc  = lr_subdesc
      IMPORTING
        et_subrand  = DATA(lt_subrand) ).

    et_entityset = CORRESPONDING #( lt_subrand ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_BRAND_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_BRANDTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_brand_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_BRAND_GET_ENTITYSET                     *
* Description: This method is used to add value help logic      *
*              for Brand                                        *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 25-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************
    "Data declarations
    DATA: lt_filter  TYPE /iwbep/t_mgw_select_option,
          lr_ind     TYPE RANGE OF char1,
          lt_domname TYPE RANGE OF zde_zzbrand,
          lr_domdesc  TYPE RANGE OF zcds_tp4_brand-description.

    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'Domvalue'.
          "Fill Brand filter values
          LOOP AT <lfs_filter>-select_options ASSIGNING FIELD-SYMBOL(<lfs_so>).
            APPEND VALUE #(  low = to_upper( <lfs_so>-low ) high = to_upper( <lfs_so>-high ) option =  <lfs_so>-option sign = <lfs_so>-sign  ) TO lt_domname.
          ENDLOOP.

        WHEN 'Description'.
          LOOP AT <lfs_filter>-select_options ASSIGNING <lfs_so>.
            APPEND VALUE #(  low = to_upper( <lfs_so>-low ) high = to_upper( <lfs_so>-high ) option =  <lfs_so>-option sign = <lfs_so>-sign  ) TO lr_domdesc.
          ENDLOOP.
      ENDCASE.
    ENDLOOP.

    IF lr_domdesc IS INITIAL.
       lr_domdesc = lt_domname.
    ENDIF.

    "Fetch Brand data
    zcl_tp4_promoplan=>m_get_brand(
      EXPORTING it_brand = lt_domname
                it_branddesc = lr_domdesc
      IMPORTING et_brand = DATA(lt_brand) ).

    et_entityset = CORRESPONDING #( lt_brand ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PROMO_PLAN_DPC_EXT->ZCDS_TP4_CURR_GET_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER
* | [--->] IV_FILTER_STRING               TYPE        STRING
* | [--->] IV_SEARCH_STRING               TYPE        STRING
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PROMO_PLAN_MPC=>TT_ZCDS_TP4_CURRTYPE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zcds_tp4_curr_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   ZCDS_TP4_CURR_GET_ENTITYSET                      *
* Description: This method is used to add value help logic      *
*              for currency                                     *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 25-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_vkorg  TYPE RANGE OF vkorg,
          lt_filter TYPE /iwbep/t_mgw_select_option.

    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'SalesOrg'.
          "Fill Sales Organization filter values
          lt_vkorg = corresponding #( <lfs_filter>-select_options ).
*          lt_vkorg = VALUE #( FOR ls_vkorg IN <lfs_filter>-select_options
*                              ( sign = 'I'
*                              option = 'EQ'
*                              low = ls_vkorg-low ) ).

      ENDCASE.
    ENDLOOP.

    "Fetch currency data
    zcl_tp4_promoplan=>m_get_currency(
    EXPORTING it_vkorg = lt_vkorg
    IMPORTING et_curr = DATA(lt_curr) ).

    et_entityset = CORRESPONDING #( lt_curr ).

  ENDMETHOD.
ENDCLASS.