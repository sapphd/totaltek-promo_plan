class ZOCL_TP4_PLAN_HDR_DPC_EXT definition
  public
  inheriting from ZOCL_TP4_PLAN_HDR_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
protected section.

  methods ENTITYSET_FILTER
    importing
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IV_ENTITY_NAME type STRING
    changing
      !CT_ENTITYSET type TABLE
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION .
  methods ENTITYSET_SORT .
  methods ENTITYSET_PAGING .
  methods RAISE_EXCEPTION_FROM_MESSAGE
    importing
      !IV_MESSAGE type BAPI_MSG
    exceptions
      /IWBEP/CX_MGW_BUSI_EXCEPTION .

  methods PLAN_CALENDARSET_GET_ENTITY
    redefinition .
  methods PLAN_CALENDARSET_GET_ENTITYSET
    redefinition .
  methods PLAN_HEADERSET_CREATE_ENTITY
    redefinition .
  methods PLAN_HEADERSET_GET_ENTITY
    redefinition .
  methods PLAN_HEADERSET_GET_ENTITYSET
    redefinition .
  methods PLAN_HEADERSET_UPDATE_ENTITY
    redefinition .
  methods PLAN_ITEM_OISET_CREATE_ENTITY
    redefinition .
  methods PLAN_ITEM_OISET_GET_ENTITY
    redefinition .
  methods PLAN_ITEM_OISET_GET_ENTITYSET
    redefinition .
  methods PLAN_ITEM_OISET_UPDATE_ENTITY
    redefinition .
  methods PLAN_PRODUCTSSET_GET_ENTITYSET
    redefinition .
  methods PLAN_VOLUMESET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZOCL_TP4_PLAN_HDR_DPC_EXT IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_HEADERSET_GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_REQUEST_OBJECT              TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TS_PLAN_HEADER
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD plan_headerset_get_entity.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   PLAN_HEADERSET_GET_ENTITY                        *
* Description: This method is used to get unique plan header    *
*              data based on key values                         *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 31-07-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations

    DATA: lv_plan_id    TYPE zde_plan_id,
          lv_client     TYPE mandt,
          lv_authorized TYPE char1,
          lv_display    TYPE char1,
          ls_address    TYPE bapiaddr3,
          lt_return     TYPE TABLE OF bapiret2,
          lt_plan_id       TYPE RANGE OF  zde_plan_id.

    "Get Key value

    lv_plan_id = VALUE #( it_key_tab[ name = 'PlanId' ]-value OPTIONAL ).

    IF lv_plan_id IS INITIAL.
      RETURN.
    ENDIF.
    lt_plan_id = VALUE #( FOR ls_key_tab IN it_key_tab
                                ( sign   = 'I'
                                  option = 'EQ'
                                  low    = ls_key_tab-value ) ).

    zcl_tp4_promoplan=>m_get_header_set(
          EXPORTING it_plan_id = lt_plan_id
          IMPORTING et_header = DATA(lt_header) ).
    "Fetch Plan header data

    SELECT SINGLE *
      FROM zttp4_planheader
      INTO CORRESPONDING FIELDS OF @er_entity
      WHERE plan_id = @lv_plan_id.

    IF sy-subrc NE 0.

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message = 'No data found'.

    ELSE.
*      CONVERT TIME STAMP BUYING_DATE_T TIME ZONE get_timezone( ) INTO DATE er_entity-buying_date_t.
    ENDIF.

    CALL METHOD zcl_tp4_plan_check=>check_ztp4_pr
      EXPORTING
        iv_vkorg      = er_entity-vkorg
        iv_vtweg      = er_entity-vtweg
        iv_plan_type  = er_entity-plan_type
        iv_actvt      = '02'
      CHANGING
        cv_authorized = lv_authorized
        cv_display    = lv_display.

    IF  lv_authorized IS INITIAL
    AND lv_display    IS INITIAL.
      CLEAR er_entity.
      RETURN.
    ENDIF.

    " Sales Org description

    SELECT SINGLE vtext
      FROM tvkot
      INTO er_entity-vkorg_desc
      WHERE vkorg = er_entity-vkorg
      AND   spras = sy-langu.

    " Distr. Channel description

    SELECT SINGLE vtext
      FROM tvtwt
      INTO er_entity-vtweg_desc
      WHERE vtweg = er_entity-vtweg
      AND   spras = sy-langu.

    " Plan Type description

    SELECT SINGLE description
      FROM zttp4_c_promop_t
      INTO er_entity-plan_type_desc
      WHERE vkorg      = er_entity-vkorg
      AND   vtweg      = er_entity-vtweg
      AND   plan_type  = er_entity-plan_type
      AND   spras      = sy-langu.

    " Customer Name

    SELECT SINGLE name1
      FROM kna1
      INTO er_entity-customer_name
      WHERE kunnr = er_entity-plan_customer.

    " Status description

    SELECT SINGLE description
      FROM zttp4_c_sta_text
      INTO er_entity-status_desc
      WHERE status = er_entity-status
      AND   spras  = sy-langu.

    " Objective description

    SELECT SINGLE description
      FROM zttp4_c_object_t
      INTO er_entity-objective_desc
      WHERE objective_id = er_entity-objective_id
      AND   spras        = sy-langu.

    " Tactic description

    SELECT SINGLE description
      FROM zttp4_c_tactcs_t
      INTO er_entity-tactic_desc
      WHERE tactic_id = er_entity-tactic_id
      AND   spras     = sy-langu.

    " Fund Plan description

    SELECT SINGLE description
      FROM zttp4_funds_plan
      INTO er_entity-fund_plan_desc
      WHERE fundplanid = er_entity-fund_plan.

    " SA name
    SELECT SINGLE sa_name
      FROM zttp4_sa
      INTO er_entity-sa_name
      WHERE sa_id = er_entity-sa_id.

    "Responsible user id
    er_entity-resp_user = sy-uname.

    "Responsible User Name
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = sy-uname
      IMPORTING
        address  = ls_address
      TABLES
        return   = lt_return.
    IF sy-subrc = 0.
      er_entity-resp_user_name = ls_address-fullname.
    ENDIF.

    "Currency
    SELECT SINGLE waers
      FROM tvko
      INTO er_entity-currency
      WHERE vkorg = er_entity-vkorg.
    IF sy-subrc <> 0.
      CLEAR er_entity-currency.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_HEADERSET_GET_ENTITYSET
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
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TT_PLAN_HEADER
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD plan_headerset_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   PLAN_HEADERSET_GET_ENTITYSET                     *
* Description: This method is used to add filtering logic       *
*              for plan header service                          *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 23-07-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations

    DATA: lt_plan_id       TYPE RANGE OF  zde_plan_id,
          lt_vkorg         TYPE RANGE OF vkorg,
          lt_vtweg         TYPE RANGE OF vtweg,
          lt_plan_type     TYPE RANGE OF zde_plantype,
          lt_date_from     TYPE RANGE OF zde_order_date_f,
          lt_date_to       TYPE RANGE OF zde_order_date_t,
          lt_instore_df    TYPE RANGE OF zde_instore_date_f,
          lt_instore_dt    TYPE RANGE OF zde_instore_date_t,
          lt_buy_df        TYPE RANGE OF zde_buying_date_f,
          lt_buy_dt        TYPE RANGE OF zde_buying_date_t,
          lt_prodh         TYPE RANGE OF prodh_d,
          lt_brand         TYPE RANGE OF zde_zzbrand,
          lt_subbrand      TYPE RANGE OF zde_zzsubrand,
          lt_spend_type    TYPE RANGE OF zde_spend_type,
          lt_filter        TYPE /iwbep/t_mgw_select_option,
          lt_filter_exp    TYPE STANDARD TABLE OF string,
          lv_filter_string TYPE string,
          lv_property      TYPE string,
          lv_operator      TYPE string,
          lv_value         TYPE string,
          ls_select_option TYPE /iwbep/s_mgw_select_option,
          lt_or_conditions TYPE TABLE OF string,
          lv_property_name TYPE string,
          " Populate the select options table
          ls_filter_option TYPE /iwbep/s_mgw_select_option,
          ls_range_option  TYPE /iwbep/s_cod_select_option,
          lt_plan_cust     TYPE RANGE OF zde_plan_customer,
          lt_status        TYPE RANGE OF zde_tp_status.


    lt_filter = it_filter_select_options.

    IF lt_filter IS INITIAL AND iv_filter_string IS NOT INITIAL.

      lv_filter_string = iv_filter_string.

      "Clean string filter

      REPLACE ALL OCCURRENCES OF '(' IN lv_filter_string WITH ''.
      REPLACE ALL OCCURRENCES OF ')' IN lv_filter_string WITH ''.
      REPLACE ALL OCCURRENCES OF ' eq ' IN lv_filter_string WITH '='.
      REPLACE ALL OCCURRENCES OF ' or ' IN lv_filter_string WITH ' OR '.
      REPLACE ALL OCCURRENCES OF ' '' ' IN lv_filter_string WITH ''.

      " Splitting by OR conditions

      SPLIT lv_filter_string AT ' OR ' INTO TABLE lt_or_conditions.

      LOOP AT lt_or_conditions INTO DATA(lv_or_cond).

        " Extract property, operator, and value

        DATA(lv_eq_pos) = find( val = lv_or_cond sub = '=' ).

        IF lv_eq_pos IS NOT INITIAL.

          lv_operator = 'EQ'.
          lv_property_name = substring( val = lv_or_cond off = 0 len = lv_eq_pos ).
          lv_value = substring( val = lv_or_cond off = lv_eq_pos + 1 ).

        ENDIF.

        CONDENSE lv_property_name.
        CONDENSE lv_value.

        ls_filter_option-property = lv_property_name.

        ls_range_option-sign = 'I'.
        ls_range_option-option = lv_operator.
        ls_range_option-low = lv_value.

        APPEND ls_range_option TO ls_filter_option-select_options.
        APPEND ls_filter_option TO lt_filter.
        CLEAR ls_filter_option.

      ENDLOOP.

    ENDIF.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).

      CASE <lfs_filter>-property.

        WHEN 'PlanId'.

          "Fill Plan Id filter values

          lt_plan_id = VALUE #( FOR ls_plan_id IN <lfs_filter>-select_options
                                ( sign   = 'I'
                                  option = 'EQ'
                                  low    = ls_plan_id-low ) ).

        WHEN 'Vkorg'.

          "Fill Sales Organization filter values

          lt_vkorg = VALUE #( FOR ls_vkorg IN <lfs_filter>-select_options
                              ( sign   = 'I'
                                option = 'EQ'
                                low    = ls_vkorg-low ) ).
        WHEN 'Vtweg'.

          "Fill Distribution Channel filter values

          lt_vtweg = VALUE #( FOR ls_vtweg IN <lfs_filter>-select_options
                              ( sign   = 'I'
                                option = 'EQ'
                                low    = ls_vtweg-low ) ).

        WHEN 'PlanType'.

          "Fill Plan Type filter values

          lt_plan_type = VALUE #( FOR ls_plan_type IN <lfs_filter>-select_options
                                  ( sign   = 'I'
                                    option = 'EQ'
                                    low    = ls_plan_type-low ) ).

        WHEN 'OrderDateF'.

          "Fill Order Date From filter values

          lt_date_from = VALUE #( FOR ls_date_from IN <lfs_filter>-select_options
                                  ( sign   = 'I'
                                    option = 'LE'
                                    low    = ls_date_from-low ) ).

        WHEN 'OrderDateT'.

          "Fill Order Date to filter values

          lt_date_to = VALUE #( FOR ls_date_to IN <lfs_filter>-select_options
                                ( sign   = 'I'
                                  option = 'GE'
                                  low    = ls_date_to-low ) ).

        WHEN 'BuyingDateF'.

          "Fill Buying Date From filter values

          lt_buy_df = VALUE #( FOR ls_buy_df IN <lfs_filter>-select_options
                                  ( sign   = 'I'
                                    option = 'LE'
                                    low    = ls_buy_df-low ) ).

        WHEN 'BuyingDateT'.

          "Fill Buying Date to filter values

          lt_buy_dt = VALUE #( FOR ls_buy_dt IN <lfs_filter>-select_options
                                ( sign   = 'I'
                                  option = 'GE'
                                  low    = ls_buy_dt-low ) ).

        WHEN 'InstoreDateF'.

          "Fill Instore Date from filter values

          lt_instore_df = VALUE #( FOR ls_instore_f IN <lfs_filter>-select_options
                                ( sign   = 'I'
                                  option = 'LE'
                                  low    = ls_instore_f-low ) ).
        WHEN 'InstoreDateT'.

          "Fill Instore Date to filter values

          lt_instore_dt = VALUE #( FOR ls_instore_t IN <lfs_filter>-select_options
                                ( sign   = 'I'
                                  option = 'GE'
                                  low    = ls_instore_t-low ) ).


        WHEN 'Prodh'.

          "Fill Prodh filter values

          lt_prodh = VALUE #( FOR ls_prodh IN <lfs_filter>-select_options
                              ( sign   = 'I'
                                option = 'EQ'
                                low    = ls_prodh-low ) ).

        WHEN 'Brand'.

          "Fill Brand filter values

          lt_brand = VALUE #( FOR ls_brand IN <lfs_filter>-select_options
                              ( sign   = 'I'
                                option = 'EQ'
                                low    = ls_brand-low ) ).

        WHEN 'Subbrand'.

          "Fill Subbrand filter values

          lt_subbrand = VALUE #( FOR ls_subbrand IN <lfs_filter>-select_options
                                 ( sign   = 'I'
                                   option = 'EQ'
                                   low    = ls_subbrand-low ) ).

        WHEN 'PlanCustomer'.

          "Fill Plan Customer filter values

          lt_plan_cust = VALUE #( FOR ls_plancust IN <lfs_filter>-select_options
                                  ( sign   = 'I'
                                    option = 'EQ'
                                    low    = ls_plancust-low ) ).

        WHEN 'Status'.

          "Fill Status filter values

          lt_status = VALUE #( FOR ls_status IN <lfs_filter>-select_options
                               ( sign   = 'I'
                                 option = 'EQ'
                                 low    = ls_status-low ) ).

        WHEN 'SpendType'.

          "Fill Spend Type values
          lt_spend_type = VALUE #( FOR ls_spend_type IN <lfs_filter>-select_options
                    ( sign   = 'I'
                      option = 'EQ'
                      low    = ls_spend_type-low ) ).

      ENDCASE.

    ENDLOOP.


    "Fetch Plan Header Data
    zcl_tp4_promoplan=>m_get_header_set(
          EXPORTING it_prodh = lt_prodh
              it_brand = lt_brand
              it_subbrand = lt_subbrand
              it_plan_id = lt_plan_id
              it_vkorg = lt_vkorg
              it_vtweg = lt_vtweg
              it_plan_type = lt_plan_type
              it_date_from = lt_date_from
              it_date_to = lt_date_to
              it_buy_fdate = lt_buy_df
              it_buy_tdate = lt_buy_dt
              it_instore_fdate = lt_instore_df
              it_instore_tdate = lt_instore_dt
              it_plan_cust = lt_plan_cust
              it_status = lt_status
              it_spend_type = lt_spend_type
          IMPORTING et_header = DATA(lt_header) ).

    et_entityset = CORRESPONDING #( lt_header ).
*    SELECT hdr~mandt,
*           hdr~plan_id,
*           hdr~vkorg,
*           hdr~vtweg,
*           hdr~plan_type,
*           hdr~plan_customer,
*           hdr~order_date_f,
*           hdr~order_date_t,
*           hdr~buying_date_f,
*           hdr~buying_date_t,
*           hdr~instore_date_f,
*           hdr~instore_date_t,
*           hdr~status,
*           hdr~description,
*           hdr~objective_id,
*           hdr~tactic_id,
*           hdr~contract_id,
*           hdr~fund_plan,
*           hdr~status_group,
*           hdr~sa_id,
*           hdr~currency,
*           hdr~createdon,
*           hdr~createdby,
*           hdr~changedon,
*           hdr~changedby,
*           hdr~resp_user,
*           linked_promo
*    FROM zttp4_planheader AS hdr
*    LEFT OUTER JOIN zttp4_promoplani AS itm
*    ON itm~plan_id = hdr~plan_id
*    INTO CORRESPONDING FIELDS OF TABLE @et_entityset
*    WHERE itm~prodh IN @lt_prodh
*    AND  itm~brand IN @lt_brand
*    AND itm~subbrand IN @lt_subbrand
*    AND hdr~plan_id IN @lt_plan_id
*    AND hdr~vkorg IN @lt_vkorg
*    AND hdr~vtweg IN @lt_vtweg
*    AND hdr~plan_type IN @lt_plan_type
*    AND hdr~order_date_f IN @lt_date_from
*    AND hdr~order_date_t IN @lt_date_to
*    AND hdr~plan_customer IN @lt_plan_cust
*    AND hdr~status IN @lt_status.
*    IF sy-subrc = 0.
*      SORT et_entityset BY plan_id.
*    ENDIF.
*
*    LOOP AT et_entityset ASSIGNING FIELD-SYMBOL(<lfs_entity>).
*
*      <lfs_entity>-resp_user = sy-uname.
*
*      " Sales Org description
*
*      SELECT SINGLE vtext
*        FROM tvkot
*        INTO <lfs_entity>-vkorg_desc
*        WHERE vkorg = <lfs_entity>-vkorg
*        AND   spras = sy-langu.
*
*      " Distr. Channel description
*
*      SELECT SINGLE vtext
*        FROM tvtwt
*        INTO <lfs_entity>-vtweg_desc
*        WHERE vtweg = <lfs_entity>-vtweg
*        AND   spras = sy-langu.
*
*      " Plan Type description
*
*      SELECT SINGLE description
*        FROM zttp4_c_promop_t
*        INTO <lfs_entity>-plan_type_desc
*        WHERE vkorg      = <lfs_entity>-vkorg
*        AND   vtweg      = <lfs_entity>-vtweg
*        AND   plan_type  = <lfs_entity>-plan_type
*        AND   spras      = sy-langu.
*
*      " Customer Name
*
*      SELECT SINGLE name1
*        FROM kna1
*        INTO <lfs_entity>-customer_name
*        WHERE kunnr = <lfs_entity>-plan_customer.
*
*      " Status description
*
*      SELECT SINGLE description
*        FROM zttp4_c_sta_text
*        INTO <lfs_entity>-status_desc
*        WHERE status = <lfs_entity>-status
*        AND   spras  = sy-langu.
*
*      " Objective description
*
*      SELECT SINGLE description
*        FROM zttp4_c_object_t
*        INTO <lfs_entity>-objective_desc
*        WHERE objective_id = <lfs_entity>-objective_id
*        AND   spras        = sy-langu.
*
*      " Tactic description
*
*      SELECT SINGLE description
*        FROM zttp4_c_tactcs_t
*        INTO <lfs_entity>-tactic_desc
*        WHERE tactic_id = <lfs_entity>-tactic_id
*        AND   spras     = sy-langu.
*
*      " Fund Plan description
*
*      SELECT SINGLE description
*        FROM zttp4_funds_plan
*        INTO <lfs_entity>-fund_plan_desc
*        WHERE fundplanid = <lfs_entity>-fund_plan.
*
*      " SA name
*
*      SELECT SINGLE sa_name
*        FROM zttp4_sa
*        INTO <lfs_entity>-sa_name
*        WHERE sa_id = <lfs_entity>-sa_id.
*
*    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_HEADERSET_CREATE_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY_C(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IO_DATA_PROVIDER               TYPE REF TO /IWBEP/IF_MGW_ENTRY_PROVIDER(optional)
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TS_PLAN_HEADER
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD plan_headerset_create_entity.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   PLAN_HEADERSET_CREATE_ENTITY                     *
* Description: This method is created for handling Promotion    *
*              Plan header data creation                        *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 12-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: ls_header             TYPE zttp4_planheader,
          lob_message_container TYPE REF TO /iwbep/if_message_container,
          lt_item_oi            TYPE TABLE OF zttp4_promoplani,
          lv_msg_v1             type sy-msgv1,
          lv_authorized         type char1.

    "Read incoming data from the request
    io_data_provider->read_entry_data( IMPORTING es_data = ls_header ).

    " Get the message container instance
    lob_message_container = me->mo_context->get_message_container( ).

    CALL METHOD zcl_tp4_plan_check=>check_ztp4_pr
      EXPORTING
        iv_vkorg      = ls_header-vkorg
        iv_vtweg      = ls_header-vtweg
        iv_plan_type  = ls_header-plan_type
        iv_actvt      = '01'
      CHANGING
        cv_authorized = lv_authorized.

    IF lv_authorized IS INITIAL.
      lv_msg_v1                            = ls_header-plan_id.
      CALL METHOD lob_message_container->add_message
        EXPORTING
          iv_msg_type               = /iwbep/if_message_container=>gcs_message_type-success
          iv_msg_id                 = 'ZTP4_MSG'
          iv_msg_number             = '014'
          iv_msg_v1                 = lv_msg_v1
          iv_add_to_response_header = abap_true. "
      RETURN.
    ENDIF.

    "Validate Promotion Plan Data
    zcl_tp4_promoplan=>m_validate_data(
    EXPORTING is_header = ls_header
    IMPORTING ev_error = DATA(lv_error)
              et_error = DATA(lt_error) ).

    IF lt_error IS NOT INITIAL.
      DATA(ls_error) = VALUE #( lt_error[ type = 'E' ] ).

      " Add the validation error message
      CALL METHOD lob_message_container->add_message
        EXPORTING
          iv_msg_type               = /iwbep/if_message_container=>gcs_message_type-error
          iv_msg_id                 = ls_error-id
          iv_msg_number             = ls_error-number
*         iv_msg_v1                 = ls_header-plan_id
          iv_add_to_response_header = abap_true. "

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lob_message_container.
    ENDIF.

    "Update Plan Id
    CHECK lv_error IS INITIAL.
    zcl_tp4_promoplan=>m_update_plan_id(
    IMPORTING ev_error = lv_error
    CHANGING cs_header = ls_header
             ct_item_oi = lt_item_oi ).

    "Call method to create Plan Header data
    CHECK lv_error IS INITIAL.
    zcl_tp4_promoplan=>m_create_plan_hdr(
    IMPORTING ev_error = lv_error
              et_error = lt_error
    CHANGING cs_header = ls_header
    RECEIVING rv_promo_plan_id = DATA(lv_plab_id) ).

    IF lv_error IS INITIAL
      AND lt_error IS INITIAL.
*      " Get the message container instance
*      lob_message_container = me->mo_context->get_message_container( ).

      " Add the success message
      CALL METHOD lob_message_container->add_message
        EXPORTING
          iv_msg_type               = /iwbep/if_message_container=>gcs_message_type-success
          iv_msg_id                 = 'ZTP4_MSG'
          iv_msg_number             = '000'
*         iv_msg_v1                 = ls_header-plan_id
          iv_add_to_response_header = abap_true. "

      "Return Plan header data
      er_entity = CORRESPONDING #( ls_header ).
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_HEADERSET_UPDATE_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY_U(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IO_DATA_PROVIDER               TYPE REF TO /IWBEP/IF_MGW_ENTRY_PROVIDER(optional)
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TS_PLAN_HEADER
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD plan_headerset_update_entity.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   PLAN_HEADERSET_UPDATE_ENTITY                     *
* Description: This method is used to update plan header data   *
*              data based on key values                         *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 26-08-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: ls_plan_data          TYPE zttp4_planheader,
          lob_message_container TYPE REF TO /iwbep/if_message_container.

    DATA: lv_authorized TYPE char1,
          lv_msg_v2     TYPE sy-msgv2.

    DATA(lv_plan_id) = VALUE #( it_key_tab[ name = 'PlanId' ]-value OPTIONAL ).

    "Fetch data
    io_data_provider->read_entry_data( IMPORTING es_data = ls_plan_data ).

    " Get the message container instance
    lob_message_container = me->mo_context->get_message_container( ).


    IF ls_plan_data IS NOT INITIAL AND
       lv_plan_id IS NOT INITIAL.

      ls_plan_data-plan_id = lv_plan_id.

      CALL METHOD zcl_tp4_plan_check=>check_ztp4_pr
        EXPORTING
          iv_vkorg      = ls_plan_data-vkorg
          iv_vtweg      = ls_plan_data-vtweg
          iv_plan_type  = ls_plan_data-plan_type
          iv_actvt      = '02'
        CHANGING
          cv_authorized = lv_authorized.

      IF lv_authorized IS INITIAL.
        lv_msg_v2                          = ls_plan_data-plan_id.
        CALL METHOD lob_message_container->add_message
          EXPORTING
            iv_msg_type               = /iwbep/if_message_container=>gcs_message_type-success
            iv_msg_id                 = 'ZTP4_MSG'
            iv_msg_number             = '019'
            iv_msg_v1                 = 'You are not authorized to change promo plan'(001)
            iv_msg_v2                 = lv_msg_v2
            iv_add_to_response_header = abap_true. "
        RETURN.
      ENDIF.


      "Update Plan Header
      zcl_tp4_promoplan=>m_update_planhdr( EXPORTING is_header = ls_plan_data
                                           IMPORTING ev_error  = DATA(lv_error) ).
      IF lv_error IS NOT INITIAL.

        "Add the  error message
        CALL METHOD lob_message_container->add_message
          EXPORTING
            iv_msg_type               = /iwbep/if_message_container=>gcs_message_type-error
            iv_msg_id                 = 'ZTP4_MSG'
            iv_msg_number             = '015'
*           iv_msg_v1                 = ls_header-plan_id
            iv_add_to_response_header = abap_true. "

        "Raise error
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lob_message_container.

      ENDIF.

    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZOCL_TP4_PLAN_HDR_DPC_EXT->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING(optional)
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING(optional)
* | [--->] IV_SOURCE_NAME                 TYPE        STRING(optional)
* | [--->] IO_DATA_PROVIDER               TYPE REF TO /IWBEP/IF_MGW_ENTRY_PROVIDER
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH(optional)
* | [--->] IO_EXPAND                      TYPE REF TO /IWBEP/IF_MGW_ODATA_EXPAND
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY_C(optional)
* | [<---] ER_DEEP_ENTITY                 TYPE REF TO DATA
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.

*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY*
*                                                               *
* Description: This method is created for handing creation of   *
*               Plan Header, Planning OI, Planning BB, Planning *
*               Free Goods                                      *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 01-09-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_deep               TYPE zocl_tp4_plan_hdr_mpc_ext=>gty_deep,
          ls_plan_hdr           TYPE zttp4_planheader,
          lt_plan_itm_oi        TYPE TABLE OF zttp4_promoplani,
          lt_plan_itm_fg        TYPE TABLE OF zttp4_plan_fg_i,
          lt_plan_itm_volume    TYPE TABLE OF zttp4_planvolume,
          lt_plan_total         TYPE TABLE OF zttp4_plan_total,
          lt_plan_itm_total     TYPE TABLE OF zttp4_plani_pnl,
          lt_plan_volume_pw     TYPE TABLE OF zst_tp4_plan_volume_pw, "Volume to save
          lob_message_container TYPE REF TO /iwbep/if_message_container,
          lr_prodh              TYPE RANGE OF prodh_d,
          lr_matnr              TYPE RANGE OF matnr,
          lr_brand              TYPE RANGE OF zde_zzbrand,
          lr_subbrand           TYPE RANGE OF zde_zzsubrand,
          lr_spend_type         TYPE RANGE OF zde_spend_type,
          ls_header             TYPE zttp4_planheader,
          lt_item_oi_st         TYPE TABLE OF zst_tp4_plan_item_oi.

    FIELD-SYMBOLS: <lfs_plan_volume_pw> TYPE zttp4_planvolume .

    "Read incoming data from the request
    io_data_provider->read_entry_data( IMPORTING es_data = lt_deep ).

    " Get the message container instance
    lob_message_container = me->mo_context->get_message_container( ).

    IF lt_deep IS NOT INITIAL.
      "Map Plan header
      ls_header = CORRESPONDING #( lt_deep ).
      zcl_tp4_map_promo=>m_map_header(
        CHANGING
          cs_header = ls_header ).

      lt_deep-status_group = ls_header-status_group.
      lt_deep-currency = ls_header-currency.
      lt_deep-resp_user = ls_header-resp_user.

      "Map Plan Item Total data
      "First row of_deep-to_item with ITEM_NO = 0
      IF lt_deep-to_item[] IS NOT INITIAL.
        zcl_tp4_map_promo=>m_map_item_total(
          EXPORTING
            it_all        = lt_deep
          IMPORTING
            et_item_total = lt_plan_total
        ).

        "Clear total row
        DELETE lt_deep-to_item WHERE item_no IS INITIAL.
      ENDIF.

      "Avoid the logic of deleting items
      DELETE lt_deep-to_item WHERE delete IS NOT INITIAL.
      IF lt_deep-plan_id IS NOT INITIAL.
        LOOP AT lt_deep-to_item ASSIGNING FIELD-SYMBOL(<lfs_item_aux>).
          <lfs_item_aux>-plan_id = lt_deep-plan_id.
        ENDLOOP.
        SORT lt_deep-to_item BY plan_id item_no.
      ENDIF.

      "Map Plan Item OI data
      lt_item_oi_st = CORRESPONDING #( lt_deep-to_item ).

      zcl_tp4_map_promo=>m_map_oi(
        EXPORTING
          is_header  = ls_header
          it_item_oi = lt_item_oi_st
        IMPORTING
          et_item_oi = DATA(lt_item_oi) ).

      "Map Plan Item Free Goods data

      "Map Plan volumes data
      zcl_tp4_map_promo=>m_map_volume_save(
        EXPORTING
          it_volume = lt_deep-to_volume
        CHANGING
          cs_volume = lt_plan_volume_pw
          cs_deep   = lt_deep           "Deep Entity
      ).

    ENDIF.

    IF  lt_plan_volume_pw[] IS NOT INITIAL.
      lt_plan_itm_volume[] = lt_plan_volume_pw[].
    ENDIF.

    "Create Promo plan data
    zcl_tp4_promoplan=>m_create_update(
      EXPORTING
        it_item_fg       = lt_plan_itm_fg
        it_volume        = lt_plan_itm_volume
        it_total         = lt_plan_total
      IMPORTING
        ev_error         = DATA(lv_error)
        et_error         = DATA(lt_error)
      CHANGING
        cs_header        = ls_header
        ct_item_oi       = lt_item_oi
        ct_item_total    = lt_plan_total
      RECEIVING
        rv_promo_plan_id = DATA(lv_plan_id) ).

    IF lv_error IS INITIAL
      AND lt_error IS INITIAL.

      lt_deep = CORRESPONDING #( ls_header ).

      "Fetch product hierarchy description
      lr_prodh = VALUE #( FOR ls_prodh IN lt_item_oi
                          ( sign = 'I'
                            option = 'EQ'
                            low = ls_prodh-prodh ) ).
      SORT lr_prodh BY low.
      DELETE ADJACENT DUPLICATES FROM lr_prodh COMPARING low.
      SELECT prodh,
             vtext
             FROM t179t
             WHERE prodh IN @lr_prodh
             AND spras = @sy-langu
             INTO TABLE @DATA(lt_prodh).
      IF sy-subrc <> 0.
        CLEAR lt_prodh.
      ENDIF.

      "Fetch Selling SKU
      lr_matnr = VALUE #( FOR ls_matnr IN lt_item_oi
                              ( sign = 'I'
                                option = 'EQ'
                                low = ls_matnr-matnr ) ).
      SORT lr_matnr BY low.
      DELETE ADJACENT DUPLICATES FROM lr_matnr COMPARING low.
      SELECT matnr,
             maktx
             FROM makt
             WHERE matnr IN @lr_matnr
             AND spras = @sy-langu
             INTO TABLE @DATA(lt_matnr).
      IF sy-subrc <> 0.
        CLEAR lt_matnr.
      ENDIF.

      "Fetch Brand description
      lr_brand = VALUE #( FOR ls_brand  IN lt_item_oi
                              ( sign = 'I'
                                option = 'EQ'
                                low = ls_brand-brand ) ).
      SORT lr_brand  BY low.
      DELETE ADJACENT DUPLICATES FROM lr_brand COMPARING low.
      SELECT domvalue,
             description
             FROM zcds_tp4_brand
             WHERE domvalue IN @lr_brand
             AND ddlanguage = @sy-langu
             INTO TABLE @DATA(lt_brand).
      IF sy-subrc <> 0.
        CLEAR lt_brand.
      ENDIF.

      "Fetch Subbrand description
      lr_subbrand = VALUE #( FOR ls_subbrand  IN lt_item_oi
                              ( sign = 'I'
                                option = 'EQ'
                                low = ls_subbrand-subbrand ) ).
      SORT lr_subbrand  BY low.
      DELETE ADJACENT DUPLICATES FROM lr_subbrand COMPARING low.
      SELECT zzsubrand,
             zzsubdesc
             FROM ztmdg_mm_subrand
             WHERE zzsubrand IN @lr_subbrand
             INTO TABLE @DATA(lt_subbrand).
      IF sy-subrc <> 0.
        CLEAR lt_subbrand.
      ENDIF.

      "Fetch Spend type description
      lr_spend_type = VALUE #( FOR ls_spend  IN lt_item_oi
                              ( sign = 'I'
                                option = 'EQ'
                                low = ls_spend-spend_type ) ).
      SORT lr_spend_type BY low.
      DELETE ADJACENT DUPLICATES FROM lr_spend_type COMPARING low.
      SELECT spend_type,
             description
             FROM zttp4_c_spend_t
             WHERE spend_type IN @lr_spend_type
             INTO TABLE @DATA(lt_spend_txt).
      IF sy-subrc <> 0.
        CLEAR lt_spend_txt.
      ENDIF.

      LOOP AT lt_item_oi  ASSIGNING FIELD-SYMBOL(<lfs_item>).

        IF lt_deep-to_item IS NOT INITIAL.
          IF <lfs_item>-spend_nro = 2.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-tactic_2  = <lfs_item>-tactic_id.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_method_2  = <lfs_item>-spend_method.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-discount_amt_2  = <lfs_item>-discount_amt.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-discount_2  = <lfs_item>-discount.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_type_2  = <lfs_item>-spend_type.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_type_2_desc = VALUE #( lt_spend_txt[ spend_type = <lfs_item>-spend_type ]-description OPTIONAL ).
          ELSEIF <lfs_item>-spend_nro = 3.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-tactic_3  = <lfs_item>-tactic_id.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_method_3  = <lfs_item>-spend_method.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-discount_amt_3  = <lfs_item>-discount_amt.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-discount_3  = <lfs_item>-discount.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_type_3  = <lfs_item>-spend_type.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_type_3_desc = VALUE #( lt_spend_txt[ spend_type = <lfs_item>-spend_type ]-description OPTIONAL ).
          ELSEIF <lfs_item>-spend_nro = 4.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-tactic_4  = <lfs_item>-tactic_id.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_method_4  = <lfs_item>-spend_method.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-discount_amt_4  = <lfs_item>-discount_amt.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-discount_4  = <lfs_item>-discount.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_type_4  = <lfs_item>-spend_type.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_type_4_desc = VALUE #( lt_spend_txt[ spend_type = <lfs_item>-spend_type ]-description OPTIONAL ).
          ELSEIF <lfs_item>-spend_nro = 5.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-tactic_5  = <lfs_item>-tactic_id.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_method_5  = <lfs_item>-spend_method.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-discount_amt_5  = <lfs_item>-discount_amt.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-discount_5  = <lfs_item>-discount.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_type_5  = <lfs_item>-spend_type.
            lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_type_5_desc = VALUE #( lt_spend_txt[ spend_type = <lfs_item>-spend_type ]-description OPTIONAL ).
          ENDIF.
        ENDIF.

        IF <lfs_item>-spend_nro = 1.
          APPEND CORRESPONDING #( <lfs_item> MAPPING spend_method_1 = spend_method
                                                     discount_amt_1 = discount_amt
                                                     discount_1 =   discount
                                                     spend_type_1 =  spend_type
                                                     tactic_1 = tactic_id
                                                     EXCEPT spend_nro ) TO lt_deep-to_item.

          lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-prodh_desc = VALUE #( lt_prodh[ prodh = <lfs_item>-prodh ]-vtext OPTIONAL ).
          lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-matnr_desc = VALUE #( lt_matnr[ matnr = <lfs_item>-matnr ]-maktx OPTIONAL ).
          lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-brand_desc = VALUE #( lt_brand[ domvalue = <lfs_item>-brand ]-description OPTIONAL ).
          lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-subbrand_desc = VALUE #( lt_subbrand[ zzsubrand = <lfs_item>-subbrand ]-zzsubdesc OPTIONAL ).
          lt_deep-to_item[ plan_id = <lfs_item>-plan_id item_no = <lfs_item>-item_no ]-spend_type_1_desc = VALUE #( lt_spend_txt[ spend_type = <lfs_item>-spend_type ]-description OPTIONAL ).
        ENDIF.
      ENDLOOP.

      "Save Volume data per Week
      LOOP AT lt_plan_volume_pw ASSIGNING <lfs_plan_volume_pw>.
        <lfs_plan_volume_pw>-plan_id = ls_header-plan_id.
        MODIFY zttp4_planvolume FROM <lfs_plan_volume_pw>.
      ENDLOOP.

      "Add the success message
      CALL METHOD lob_message_container->add_message
        EXPORTING
          iv_msg_type               = /iwbep/if_message_container=>gcs_message_type-success
          iv_msg_id                 = 'ZTP4_MSG'
          iv_msg_number             = '000'
*         iv_msg_v1                 = ls_header-plan_id
          iv_add_to_response_header = abap_true. "

      "Return Promo Plan data
      me->copy_data_to_ref(
        EXPORTING
          is_data = lt_deep
        CHANGING
          cr_data = er_deep_entity ).

    ELSEIF lv_error IS NOT INITIAL
      AND lt_error IS NOT INITIAL.
      DATA(ls_error) = VALUE #( lt_error[ type = 'E' ] ).

      " Add the validation error message
      CALL METHOD lob_message_container->add_message
        EXPORTING
          iv_msg_type               = /iwbep/if_message_container=>gcs_message_type-error
          iv_msg_id                 = ls_error-id
          iv_msg_number             = ls_error-number
          iv_msg_v1                 = ls_error-message_v1
          iv_msg_v2                 = ls_error-message_v2
          iv_msg_v3                 = ls_error-message_v3
          iv_msg_v4                 = ls_error-message_v4
          iv_add_to_response_header = abap_true. "

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lob_message_container.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZOCL_TP4_PLAN_HDR_DPC_EXT->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING(optional)
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING(optional)
* | [--->] IV_SOURCE_NAME                 TYPE        STRING(optional)
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION(optional)
* | [--->] IT_ORDER                       TYPE        /IWBEP/T_MGW_SORTING_ORDER(optional)
* | [--->] IS_PAGING                      TYPE        /IWBEP/S_MGW_PAGING(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH(optional)
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR(optional)
* | [--->] IV_FILTER_STRING               TYPE        STRING(optional)
* | [--->] IV_SEARCH_STRING               TYPE        STRING(optional)
* | [--->] IO_EXPAND                      TYPE REF TO /IWBEP/IF_MGW_ODATA_EXPAND(optional)
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITYSET(optional)
* | [<---] ER_ENTITYSET                   TYPE REF TO DATA
* | [<---] ET_EXPANDED_CLAUSES            TYPE        STRING_TABLE
* | [<---] ET_EXPANDED_TECH_CLAUSES       TYPE        STRING_TABLE
* | [<---] ES_RESPONSE_CONTEXT            TYPE        TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
***********************************************************************
* Project   :  TP4                                                    *
* RICEFW ID:                                                          *
* SCA ID   :   SCA ID – XXXX                                          *
* Method   :   /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET  *                               *
* Description: This method is used to Fetch Promo Plan Plan deep      *
*              entity data                                            *
*                                                                     *
* Created By : Sangeeta Singh/R73078                                  *
* Created Date: 04-09-2025                                            *
* Transport Request: DD4K915363                                       *
***********************************************************************

    DATA: lv_plan_id        TYPE zde_plan_id,
          lv_item_no        TYPE zde_item_no,
          lv_spend_type     TYPE zde_spend_type,
          ls_discount       TYPE zst_tp4_plan_item_oi,
          lS_ITEM           TYPE zst_tp4_plan_item_oi,
          lS_header         TYPE ZST_TP4_PLAN_hdr,

          "Filters
          ls_filter         TYPE /iwbep/s_mgw_select_option,
          ls_select_options TYPE /iwbep/s_cod_select_option,

          "Products Entity
          lt_deep           TYPE TABLE OF zocl_tp4_plan_hdr_mpc_ext=>gty_deep, "Deep Entity Type
          ls_deep           TYPE zocl_tp4_plan_hdr_mpc_ext=>gty_deep,
          lt_deep_products  TYPE TABLE OF zst_tp4_plan_products, "Deep Entity Type
          ls_deep_products  TYPE zst_tp4_plan_products,
          lt_items_lp_out   TYPE esales_bapiitemex_tab,
          lv_matnr          TYPE matnr,
          lv_prodh          TYPE prodh_d,
          lv_BRAND          TYPE zde_zzbrand,
          lv_subrand        TYPE zde_zzsubrand,
          lv_BUYING_DATE_F  TYPE zde_BUYING_DATE_F,
          lv_BUYING_DATE_T  TYPE zde_BUYING_DATE_T,
          lv_vtweg          TYPE vtweg,
          lv_vkorg          TYPE vkorg,
          lv_umren          TYPE umren,
          lv_umrez          TYPE umrez,
          lv_plan_customer  TYPE zde_plan_customer,
          lv_prod_select    TYPE zde_prod_sel,
          lv_where_constant TYPE string,
          lt_item_oi_lp     TYPE TABLE OF zttp4_promoplani, "zst_tp4_plan_item_oi,
          lt_week           TYPE TABLE OF zde_year_week,
          lt_calendar       TYPE TABLE OF zttp4_calendar.

    CONSTANTS: lc_constant TYPE string VALUE 'ZTP4_PPC'.

    CASE iv_entity_set_name.

      WHEN 'Plan_HeaderSet'.
        "Get Header data
        zcl_tp4_promoplan=>m_get_header_set(
        IMPORTING et_header = DATA(lt_header) ).

        "Return Promo Plan data
        me->copy_data_to_ref(
        EXPORTING
          is_data =  lt_header
        CHANGING
          cr_data = er_entityset ).

      WHEN 'Plan_Item_OISet'.
        "Get Key value
        lv_plan_id = VALUE #( it_key_tab[ name = 'PlanId' ]-value OPTIONAL ).

        IF lv_plan_id IS NOT INITIAL.
          "Fetch item navigation data
          zcl_tp4_promoplan=>m_get_itemoi_set(
          EXPORTING iv_plan_id = lv_plan_id
          IMPORTING et_item_oi = DATA(lt_item_oi)
                    et_item_oi_set = DATA(lt_item_oi_set) ).
          "Return Promo Plan data
          IF lt_item_oi_set IS NOT INITIAL.
            me->copy_data_to_ref(
            EXPORTING
              is_data =  lt_item_oi_set
            CHANGING
              cr_data = er_entityset ).
          ENDIF.
        ENDIF.

      WHEN 'Plan_VolumeSet'.
        "Get Key value
        lv_plan_id = VALUE #( it_key_tab[ name = 'PlanId' ]-value OPTIONAL ).
        lv_item_no =  VALUE #( it_key_tab[ name = 'ItemNo' ]-value OPTIONAL ).

        IF lv_plan_id IS INITIAL.
          ls_item-Matnr =  VALUE #( it_key_tab[ name = 'Matnr' ]-value OPTIONAL ).
          ls_item-Prodh =  VALUE #( it_key_tab[ name = 'Prodh' ]-value OPTIONAL ).
          ls_item-Brand =  VALUE #( it_key_tab[ name = 'Brand' ]-value OPTIONAL ).
          ls_item-Subbrand =  VALUE #( it_key_tab[ name = 'Subbrand' ]-value OPTIONAL ).
          ls_header-Buying_Date_F =  VALUE #( it_key_tab[ name = 'BuyingDateF' ]-value OPTIONAL ).
          ls_header-Buying_Date_T =  VALUE #( it_key_tab[ name = 'BuyingDateT' ]-value OPTIONAL ).
          ls_header-Vtweg =  VALUE #( it_key_tab[ name = 'Vtweg' ]-value OPTIONAL ).
          ls_header-Vkorg =  VALUE #( it_key_tab[ name = 'Vkorg' ]-value OPTIONAL ).
          ls_header-Plan_Customer =  VALUE #( it_key_tab[ name = 'PlanCustomer' ]-value OPTIONAL ).
          ls_header-product_selection =  VALUE #( it_key_tab[ name = 'ProductSelection' ]-value OPTIONAL ).
        ENDIF.

        "Fetch volume navigation data
        zcl_tp4_promoplan=>m_get_volume_set(
        EXPORTING iv_plan_id  = lv_plan_id
                  iv_item_no = lv_item_no
                  is_item_aux = lS_ITEM
                  is_header = ls_header
        IMPORTING et_volume = DATA(lt_volume)
        CHANGING cs_discount = ls_discount  ).

        "Return Promo Plan data
        IF lt_volume IS NOT INITIAL.
          me->copy_data_to_ref(
          EXPORTING
            is_data =  lt_volume
          CHANGING
            cr_data = er_entityset ).
        ENDIF.

      WHEN 'Plan_ProductsSet'.

        "Get filters
        READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'Matnr'.
        IF sy-subrc = 0.
          READ TABLE ls_filter-select_options INTO ls_select_options INDEX 1.
          IF sy-subrc = 0.
            lv_Matnr = ls_select_options-low.
          ENDIF.
        ENDIF.

        READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'Prodh'.
        IF sy-subrc = 0.
          READ TABLE ls_filter-select_options INTO ls_select_options INDEX 1.
          IF sy-subrc = 0.
            lv_Prodh = ls_select_options-low.
          ENDIF.
        ENDIF.

        READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'Brand'.
        IF sy-subrc = 0.
          READ TABLE ls_filter-select_options INTO ls_select_options INDEX 1.
          IF sy-subrc = 0.
            lv_brand = ls_select_options-low.
          ENDIF.
        ENDIF.

        READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'Subbrand'.
        IF sy-subrc = 0.
          READ TABLE ls_filter-select_options INTO ls_select_options INDEX 1.
          IF sy-subrc = 0.
            lv_subrand = ls_select_options-low.
          ENDIF.
        ENDIF.

        READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'Vkorg'.
        IF sy-subrc = 0.
          READ TABLE ls_filter-select_options INTO ls_select_options INDEX 1.
          IF sy-subrc = 0.
            lv_Vkorg = ls_select_options-low.
          ENDIF.
        ENDIF.

        READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'Vtweg'.
        IF sy-subrc = 0.
          READ TABLE ls_filter-select_options INTO ls_select_options INDEX 1.
          IF sy-subrc = 0.
            lv_Vtweg = ls_select_options-low.
          ENDIF.
        ENDIF.

        READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'BuyingDateF'.
        IF sy-subrc = 0.
          READ TABLE ls_filter-select_options INTO ls_select_options INDEX 1.
          IF sy-subrc = 0.
            REPLACE ALL OCCURRENCES OF '-' IN ls_select_options-low WITH ''.
            lv_Buying_Date_F = ls_select_options-low.
          ENDIF.
        ENDIF.

        READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'BuyingDateT'.
        IF sy-subrc = 0.
          READ TABLE ls_filter-select_options INTO ls_select_options INDEX 1.
          IF sy-subrc = 0.
            REPLACE ALL OCCURRENCES OF '-' IN ls_select_options-low WITH ''.
            lv_Buying_Date_T = ls_select_options-low.
          ENDIF.
        ENDIF.
        READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'PlanCustomer'.
        IF sy-subrc = 0.
          READ TABLE ls_filter-select_options INTO ls_select_options INDEX 1.
          IF sy-subrc = 0.
            lv_Plan_Customer = ls_select_options-low.
          ENDIF.
        ENDIF.
        READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'ProductSelection'.
        IF sy-subrc = 0.
          READ TABLE ls_filter-select_options INTO ls_select_options INDEX 1.
          IF sy-subrc = 0.
            lv_Prod_select = ls_select_options-low.
          ENDIF.
        ENDIF.

        " Get PPC / UOM
        zcl_tp4_promoplan=>m_get_uom_ppc(
          EXPORTING
            iv_vtweg         = lv_vtweg                 " Distribution Channel
            iv_buying_date_f = lv_BUYING_DATE_F                 " Buying Date From
            iv_buying_date_t = lv_BUYING_DATE_T                 " Buying Date to
            iv_plan_customer = lv_plan_customer                " Plan customer
            iv_prod_select   = lv_prod_select              " Product Selection
            iv_matnr         = lv_matnr                 " Material Number
            iv_vkorg         = lv_vkorg                " Sales Organization
            iv_prodh         = lv_prodh                " Product Hierarchy
          IMPORTING
            ev_ppc           = ls_deep_products-ppc                " Distribution Channel
            ev_uom           = ls_deep_products-uom                 " UOM
        ).

        ls_deep_products-matnr          = lv_matnr     .
        ls_deep_products-prodh          = lv_Prodh    .
        ls_deep_products-brand          = lv_brand    .
        ls_deep_products-subbrand       = lv_subrand    .
        ls_deep_products-vkorg          = lv_vkorg .
        ls_deep_products-vtweg          = lv_vtweg .
        ls_deep_products-plan_customer  = lv_plan_customer  .
        ls_deep_products-product_selection = lv_prod_select .
        ls_deep_products-buying_date_f  = lv_BUYING_DATE_F.
        ls_deep_products-buying_date_t  = lv_BUYING_DATE_T  .

        IF lv_Prodh IS NOT INITIAL.
          CONCATENATE 'ZTP4_PROD_ACTIVE' lv_vkorg lv_vtweg
          INTO lv_where_constant SEPARATED BY '_'.
          SELECT SINGLE low FROM tvarvc INTO @DATA(lv_VMSTA)
                  WHERE name EQ @lv_where_constant.
          IF sy-subrc = 0.
            SELECT SINGLE matnr FROM mvke
                  INTO @DATA(lv_matnr_lp)
                  WHERE vkorg = @lv_vkorg
                    AND vtweg = @lv_vtweg
                    AND prodh = @lv_prodh
                    AND vmsta = @lv_VMSTA.
          ENDIF.
        ENDIF.
        IF lv_Prodh IS NOT INITIAL OR lv_matnr IS NOT INITIAL.
          IF lv_matnr_lp IS INITIAL.
            lv_matnr_lp = lv_matnr.
          ENDIF.
          "Get List price
          zcl_tp4_promoplan=>m_get_list_price(
            IMPORTING
              ev_vtweg         = lv_vtweg                 "Distribution Channel
              ev_buying_date_f = lv_buying_date_f         "Buying Date From
              ev_buying_date_t = lv_buying_date_t         "Buying Date to
              ev_plan_customer = lv_plan_customer         "Plan Customer
              ev_prod_select   = lv_prod_select           "Product Selection
              ev_vkorg         = lv_vkorg                 "Sales Organization
              ev_matnr         = lv_matnr_lp              "Material
              ev_uom           = ls_deep_products-uom     "UOM
            CHANGING
              ct_item_out = lt_items_lp_out
          ).
        ENDIF.

        IF lt_items_lp_out[] IS NOT INITIAL.
          ls_deep_products-list_price = COND #( WHEN lt_items_lp_out[ 1 ]-subtotal2 IS INITIAL THEN 0 ELSE lt_items_lp_out[ 1 ]-subtotal2 / 10 ).
          ls_deep_products-net_cost = COND #( WHEN lt_items_lp_out[ 1 ]-subtotal3 IS INITIAL THEN 0 ELSE lt_items_lp_out[ 1 ]-subtotal3 / 10 ).
          ls_deep_products-discount_edlp = ls_deep_products-list_price - ls_deep_products-net_cost.
          IF lt_items_lp_out[ 1 ]-net_value1 IS NOT INITIAL AND lt_items_lp_out[ 1 ]-tx_doc_cur  IS NOT INITIAL.
            ls_deep_products-tax = lt_items_lp_out[ 1 ]-tx_doc_cur / lt_items_lp_out[ 1 ]-net_value1.
          ELSE.
            ls_deep_products-tax =  0.
          ENDIF.

        ENDIF.

        zcl_tp4_promoplan=>m_get_comm_pric(
          CHANGING
            cs_deep_products = ls_deep_products
        ).

        APPEND ls_deep_products TO lt_deep_products.

        "Return Products detaill and volume data
        IF  lt_deep_products IS NOT INITIAL.
          me->copy_data_to_ref(
          EXPORTING
            is_data = lt_deep_products
          CHANGING
            cr_data = er_entityset ).
        ENDIF.

    ENDCASE.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_ITEM_OISET_CREATE_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY_C(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IO_DATA_PROVIDER               TYPE REF TO /IWBEP/IF_MGW_ENTRY_PROVIDER(optional)
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TS_PLAN_ITEM_OI
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method PLAN_ITEM_OISET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->PLAN_ITEM_OISET_CREATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**    io_data_provider        =
**  IMPORTING
**    er_entity               =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_ITEM_OISET_GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_REQUEST_OBJECT              TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TS_PLAN_ITEM_OI
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD plan_item_oiset_get_entity.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   PLAN_ITEM_OISET_GET_ENTITY                       *
* Description: This method is used to get unique plan header    *
*              data based on key values                         *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 05-09-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lv_plan_id    TYPE zde_plan_id,
          lv_item_no    TYPE zde_item_no,
          lv_spend_type TYPE zde_spend_type.


    "Get Key values
    lv_plan_id = VALUE #( it_key_tab[ name = 'PlanId' ]-value OPTIONAL ).
    lv_item_no = VALUE #( it_key_tab[ name = 'ItemNo' ]-value OPTIONAL ).
    lv_spend_type = VALUE #( it_key_tab[ name = 'SpendType1' ]-value OPTIONAL ).

    IF lv_plan_id IS NOT INITIAL
      AND lv_item_no IS NOT INITIAL.
      "Fetch item navigation data
      zcl_tp4_promoplan=>m_get_itemoi_set(
      EXPORTING iv_plan_id = lv_plan_id
      IMPORTING et_item_oi = DATA(lt_item_oi)
                et_item_oi_set = DATA(lt_item_oi_set) ).

      "Return output
      er_entity = VALUE #( lt_item_oi_set[ plan_id = lv_plan_id item_no = lv_item_no ] ).

    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_ITEM_OISET_GET_ENTITYSET
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
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TT_PLAN_ITEM_OI
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD plan_item_oiset_get_entityset.
*****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   PLAN_ITEM_OISET_GET_ENTITYSET                    *
* Description: This method is used to fetch Plan OI Item Data   *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 04-09-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

    "Data declarations
    DATA: lt_plan_id    TYPE RANGE OF  zde_plan_id,
          lt_item_no    TYPE RANGE OF zde_item_no,
          lt_spend_type TYPE RANGE OF zde_spend_type,
          lt_prodh      TYPE RANGE OF prodh_d,
          lt_brand      TYPE RANGE OF zde_zzbrand,
          lt_subbrand   TYPE RANGE OF zde_zzsubrand,
          lt_filter     TYPE /iwbep/t_mgw_select_option.


    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'PlanId'.

          "Fill Plan Id filter values
          lt_plan_id = VALUE #( FOR ls_plan_id IN <lfs_filter>-select_options
                                ( sign   = 'I'
                                  option = 'EQ'
                                  low    = ls_plan_id-low ) ).

        WHEN 'ItemNo'.

          "Fill Item Number filter values
          lt_item_no = VALUE #( FOR ls_item_no IN <lfs_filter>-select_options
                                ( sign   = 'I'
                                  option = 'EQ'
                                  low    = ls_item_no-low ) ).

        WHEN 'SpendType1' OR
             'SpendType2' OR
             'SpendType3' OR
             'SpendType4' OR
             'SpendType5'  .

          "Fill Spend Type 1 filter values
          lt_spend_type = VALUE #( BASE lt_spend_type FOR ls_spend_type IN <lfs_filter>-select_options
                                ( sign   = 'I'
                                  option = 'EQ'
                                  low    = ls_spend_type-low ) ).

        WHEN 'Prodh'.

          "Fill Prodh filter values
          lt_prodh = VALUE #( FOR ls_prodh IN <lfs_filter>-select_options
                              ( sign   = 'I'
                                option = 'EQ'
                                low    = ls_prodh-low ) ).

        WHEN 'Brand'.

          "Fill Brand filter values
          lt_brand = VALUE #( FOR ls_brand IN <lfs_filter>-select_options
                              ( sign   = 'I'
                                option = 'EQ'
                                low    = ls_brand-low ) ).

        WHEN 'Subbrand'.

          "Fill Subbrand filter values
          lt_subbrand = VALUE #( FOR ls_subbrand IN <lfs_filter>-select_options
                                 ( sign   = 'I'
                                   option = 'EQ'
                                   low    = ls_subbrand-low ) ).


      ENDCASE.

    ENDLOOP.

    "Get Item Data
    zcl_tp4_promoplan=>m_get_itemoi_set(
          EXPORTING it_prodh = lt_prodh
              it_brand = lt_brand
              it_subbrand = lt_subbrand
              it_plan_id = lt_plan_id
              it_item_no = lt_item_no
              it_spend_type = lt_spend_type
          IMPORTING et_item_oi = DATA(lt_item_oi)
                    et_item_oi_set = DATA(lt_item_oi_set) ).

    et_entityset = CORRESPONDING #( lt_item_oi_set ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_ITEM_OISET_UPDATE_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY_U(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [--->] IO_DATA_PROVIDER               TYPE REF TO /IWBEP/IF_MGW_ENTRY_PROVIDER(optional)
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TS_PLAN_ITEM_OI
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method PLAN_ITEM_OISET_UPDATE_ENTITY.
**TRY.
*CALL METHOD SUPER->PLAN_ITEM_OISET_UPDATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**    io_data_provider        =
**  IMPORTING
**    er_entity               =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZOCL_TP4_PLAN_HDR_DPC_EXT->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING(optional)
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING(optional)
* | [--->] IV_SOURCE_NAME                 TYPE        STRING(optional)
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH(optional)
* | [--->] IO_EXPAND                      TYPE REF TO /IWBEP/IF_MGW_ODATA_EXPAND(optional)
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [<---] ER_ENTITY                      TYPE REF TO DATA
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
* | [<---] ET_EXPANDED_CLAUSES            TYPE        STRING_TABLE
* | [<---] ET_EXPANDED_TECH_CLAUSES       TYPE        STRING_TABLE
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.
***********************************************************************
* Project   :  TP4                                                    *
* RICEFW ID:                                                          *
* SCA ID   :   SCA ID – XXXX                                          *
* Method   :   /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITY     *
* Description: This method is used to Fetch Promo Plan Plan deep      *
*              entity data                                            *
*                                                                     *
* Created By : Sangeeta Singh/R73078                                  *
* Created Date: 05-09-2025                                            *
* Transport Request: DD4K915363                                       *
***********************************************************************

    "Data declarations
    DATA: lv_plan_id TYPE zde_plan_id,
          lv_client  TYPE mandt,
          ls_address TYPE bapiaddr3,
          lt_return  TYPE TABLE OF bapiret2,
          ls_deep    TYPE  zocl_tp4_plan_hdr_mpc_ext=>gty_deep,
          ls_header  TYPE zst_tp4_plan_hdr,
          lt_plan_id TYPE RANGE OF  zde_plan_id.

    "Get Key value
    lv_plan_id = VALUE #( it_key_tab[ name = 'PlanId' ]-value OPTIONAL ).

    IF lv_plan_id IS INITIAL.
      RETURN.
    ENDIF.

    CASE iv_entity_set_name.

      WHEN 'Plan_HeaderSet'.
*        "Fetch Plan header data
*        SELECT SINGLE *
*          FROM zttp4_planheader
*          INTO CORRESPONDING FIELDS OF @ls_deep
*          WHERE plan_id = @lv_plan_id.
*
*        IF sy-subrc NE 0.
*
*          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*            EXPORTING
*              message = 'No data found'.
*        ELSE.
*          SELECT * FROM zttp4_promoplani
*            INTO TABLE @DATA(lt_item)
*            WHERE plan_id = @lv_plan_id.
*          IF sy-subrc = 0.
*            ls_deep-to_item = CORRESPONDING #( lt_item ).
*          ENDIF.
*
*        ENDIF.
*
*        " Sales Org description
*
*        SELECT SINGLE vtext
*          FROM tvkot
*          INTO ls_deep-vkorg_desc
*          WHERE vkorg = ls_deep-vkorg
*          AND   spras = sy-langu.
*
*        " Distr. Channel description
*
*        SELECT SINGLE vtext
*          FROM tvtwt
*          INTO ls_deep-vtweg_desc
*          WHERE vtweg = ls_deep-vtweg
*          AND   spras = sy-langu.
*
*        " Plan Type description
*
*        SELECT SINGLE description
*          FROM zttp4_c_promop_t
*          INTO ls_deep-plan_type_desc
*          WHERE vkorg      = ls_deep-vkorg
*          AND   vtweg      = ls_deep-vtweg
*          AND   plan_type  = ls_deep-plan_type
*          AND   spras      = sy-langu.
*
*        " Customer Name
*
*        SELECT SINGLE name1
*          FROM kna1
*          INTO ls_deep-customer_name
*          WHERE kunnr = ls_deep-plan_customer.
*
*        " Status description
*
*        SELECT SINGLE description
*          FROM zttp4_c_sta_text
*          INTO ls_deep-status_desc
*          WHERE status = ls_deep-status
*          AND   spras  = sy-langu.
*
*        " Objective description
*
*        SELECT SINGLE description
*          FROM zttp4_c_object_t
*          INTO ls_deep-objective_desc
*          WHERE objective_id = ls_deep-objective_id
*          AND   spras        = sy-langu.
*
*        " Tactic description
*
*        SELECT SINGLE description
*          FROM zttp4_c_tactcs_t
*          INTO ls_deep-tactic_desc
*          WHERE tactic_id = ls_deep-tactic_id
*          AND   spras     = sy-langu.
*
*        " Fund Plan description
*
*        SELECT SINGLE description
*          FROM zttp4_funds_plan
*          INTO ls_deep-fund_plan_desc
*          WHERE fundplanid = ls_deep-fund_plan.
*
*        " SA name
*        SELECT SINGLE sa_name
*          FROM zttp4_sa
*          INTO ls_deep-sa_name
*          WHERE sa_id = ls_deep-sa_id.
*
*        "Responsible user id
*        ls_deep-resp_user = sy-uname.
*
*        "Responsible User Name
*        CALL FUNCTION 'BAPI_USER_GET_DETAIL'
*          EXPORTING
*            username = sy-uname
*          IMPORTING
*            address  = ls_address
*          TABLES
*            return   = lt_return.
*        IF sy-subrc = 0.
*          ls_deep-resp_user_name = ls_address-fullname.
*        ENDIF.
*
*        "Currency
*        SELECT SINGLE waers
*          FROM tvko
*          INTO ls_deep-currency
*          WHERE vkorg = ls_deep-vkorg.
*        IF sy-subrc <> 0.
*          CLEAR ls_deep-currency.
*        ENDIF.
*
        lt_plan_id = VALUE #( FOR ls_key_tab IN it_key_tab
                                ( sign   = 'I'
                                  option = 'EQ'
                                  low    = ls_key_tab-value ) ).

        zcl_tp4_promoplan=>m_get_header_set(
              EXPORTING it_plan_id = lt_plan_id
              IMPORTING et_header = DATA(lt_header) ).
        ls_deep = CORRESPONDING #( lt_header[ 1 ] ).
        "Promo BP Button Logic
        ls_header = CORRESPONDING #( ls_deep ).
        zcl_tp4_promoplan=>m_promobp_btn( CHANGING cs_header = ls_header ).
        ls_deep = CORRESPONDING #( ls_header ).
        "Return Promo Plan data
        me->copy_data_to_ref(
        EXPORTING
          is_data =  ls_deep
        CHANGING
          cr_data = er_entity ).

      WHEN 'Plan_VolumeSet'.

*        "Get Key value
*        lv_plan_id = VALUE #( it_key_tab[ name = 'PlanId' ]-value OPTIONAL ).
*        DATA(lv_item_no) =  VALUE #( it_key_tab[ name = 'ItemNo' ]-value OPTIONAL ).
**        lv_spend_type =  VALUE #( it_key_tab[ name = 'SpendType1' ]-value OPTIONAL ).
*
*        DATA(ls_header) = VALUE #( lt_header[ plan_id = lv_plan_id ] OPTIONAL ).
*        DATA(ls_item_oi) = VALUE #( lt_item_oi_set[ item_no = lv_item_no ] OPTIONAL ).
*
*        "Fetch volume navigation data
*        zcl_tp4_promoplan=>m_get_volume_set(
*        EXPORTING is_header = ls_header
*        IMPORTING et_volume = DATA(lt_volume)
*        CHANGING cs_discount = ls_item_oi  ).
*
*        "Return Promo Plan data
*        IF lt_item_oi_set IS NOT INITIAL.
*          me->copy_data_to_ref(
*          EXPORTING
*            is_data =  lt_volume
*          CHANGING
*            cr_data = er_entityset ).
*        ENDIF.
    ENDCASE.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_VOLUMESET_GET_ENTITYSET
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
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TT_PLAN_VOLUME
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method PLAN_VOLUMESET_GET_ENTITYSET.
****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   PLAN_VOLUMESET_GET_ENTITYSET                     *
* Description: This method is used to fetch volume data         *
*                                                               *
* Created By : Sangeeta Singh/R73078                            *
* Created Date: 12-09-2025                                      *
* Transport Request: DD4K915363                                 *
*****************************************************************

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->ENTITYSET_FILTER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_FILTER_SELECT_OPTIONS       TYPE        /IWBEP/T_MGW_SELECT_OPTION
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [<-->] CT_ENTITYSET                   TYPE        TABLE
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD entityset_filter.

* Generic method to filter any entityset table of the corresponding Model.
    DATA:
      lob_root        TYPE REF TO cx_root,
      lob_data_descr  TYPE REF TO cl_abap_datadescr,
      lob_table_descr TYPE REF TO cl_abap_tabledescr,
      lob_dp_facade   TYPE REF TO /iwbep/cl_mgw_dp_facade,  "/IWBEP/IF_MGW_DP_FACADE,
      lob_model       TYPE REF TO /iwbep/if_mgw_odata_re_model,
      ls_entity_props TYPE /iwbep/if_mgw_odata_re_prop=>ty_s_mgw_odata_property,
      lt_entity_props TYPE /iwbep/if_mgw_odata_re_prop=>ty_t_mgw_odata_properties,
      ls_filter_sel   TYPE /iwbep/s_mgw_select_option,
      lv_entity_name  TYPE /iwbep/med_external_name,
      lv_tabix        TYPE i,
      lv_type         TYPE string,
      lv_message      TYPE string..

    FIELD-SYMBOLS:
      <lfs_val>  TYPE data,
      <lfs_data> TYPE data.

* Pre-check.
    CHECK lines( it_filter_select_options ) > 0.

* 'Type-cast' datatype.
    lv_entity_name = iv_entity_name.

* Get type of table.
    TRY.
*   Get DP facade.
        lob_dp_facade ?= me->/iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*   Get Model
        lob_model = lob_dp_facade->/iwbep/if_mgw_dp_int_facade~get_model( ).
*   Get Entity Properties.
        lt_entity_props = lob_model->get_entity_type( lv_entity_name )->get_properties( ).

*   Traverse filters.
        LOOP AT it_filter_select_options INTO ls_filter_sel.
*     Map Model Property to ABAP field name.
          READ TABLE lt_entity_props INTO ls_entity_props
          WITH KEY name = ls_filter_sel-property.
          IF sy-subrc = 0.
*       Evaluate (single) Property filter on EntitySet.
            LOOP AT ct_entityset ASSIGNING <lfs_data>.
              lv_tabix = sy-tabix.
*         Get Property value.
              ASSIGN COMPONENT ls_entity_props-technical_name OF STRUCTURE <lfs_data> TO <lfs_val>.
              IF sy-subrc = 0 AND <lfs_val> IS ASSIGNED.
*           Evaluate i'th filter (not adhering to filter => delete).
                IF <lfs_val> NOT IN ls_filter_sel-select_options.
*             Delete from table, when not adhering to filter.
                  DELETE ct_entityset INDEX lv_tabix.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
      CATCH cx_root INTO lob_root.

        " lv_message = 'Error in method ENTITYSET_FILTER :' && lx_root->get_text( ).
        "me->raise_exception_from_message( 'Error in method ENTITYSET_FILTER :' && lx_root->get_text( ) ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = 'Error in method ENTITYSET_FILTER :' && lob_root->get_text( ).
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->ENTITYSET_PAGING
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method ENTITYSET_PAGING.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->ENTITYSET_SORT
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method ENTITYSET_SORT.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_CALENDARSET_GET_ENTITY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_SOURCE_NAME                 TYPE        STRING
* | [--->] IT_KEY_TAB                     TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR
* | [--->] IO_REQUEST_OBJECT              TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_ENTITY(optional)
* | [--->] IT_NAVIGATION_PATH             TYPE        /IWBEP/T_MGW_NAVIGATION_PATH
* | [<---] ER_ENTITY                      TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TS_PLAN_CALENDAR
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD plan_calendarset_get_entity.

    DATA: lt_calendar TYPE STANDARD TABLE OF zttp4_calendar,
          ls_calendar TYPE zttp4_calendar,
          lv_vkorg    TYPE vkorg,
          lv_vtweg    TYPE vtweg,
          lv_yearweek TYPE zde_year_week.

    lv_vkorg    = VALUE #( it_key_tab[ name = 'Vkorg' ]-value OPTIONAL ).
    lv_vtweg    = VALUE #( it_key_tab[ name = 'Vtweg' ]-value OPTIONAL ).
    lv_yearweek = VALUE #( it_key_tab[ name = 'Yearweek' ]-value OPTIONAL ).

    SELECT SINGLE * FROM zttp4_calendar
      INTO CORRESPONDING FIELDS OF er_entity
      WHERE vkorg = lv_vkorg
      AND vtweg = lv_vtweg
      AND yearweek = lv_yearweek.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_CALENDARSET_GET_ENTITYSET
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
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TT_PLAN_CALENDAR
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD plan_calendarset_get_entityset.

    DATA: lt_calendar      TYPE STANDARD TABLE OF zttp4_calendar,
          ls_calendar      TYPE zttp4_calendar,
          ls_entity        TYPE zocl_tp4_plan_hdr_mpc=>ts_plan_calendar,
          lv_wstrg         TYPE string,
          lob_filter       TYPE REF TO /iwbep/if_mgw_req_filter,
          lt_select_option TYPE /iwbep/t_mgw_select_option.

    DATA: lr_vkorg         TYPE RANGE OF zttp4_calendar-vkorg.

    SELECT mandt, vkorg, vtweg, yearweek, split_week, start_day, end_day, cal_year, cal_month, screen_col FROM zttp4_calendar
      INTO CORRESPONDING FIELDS OF TABLE @lt_calendar
     WHERE vkorg IN @lr_vkorg.

    IF sy-subrc = 0.
      LOOP AT lt_calendar INTO ls_calendar.
        MOVE-CORRESPONDING ls_calendar TO ls_entity.
        APPEND ls_entity TO et_entityset.
      ENDLOOP.
    ENDIF.

    IF  it_filter_select_options[] IS NOT INITIAL.
      me->entityset_filter(
        EXPORTING
          it_filter_select_options = it_filter_select_options                " table of select options
          iv_entity_name           = iv_entity_name
        CHANGING
          ct_entityset             = et_entityset
      ).
    ELSE.

*     LOOP AT lt_calendar INTO ls_calendar.
*        MOVE-CORRESPONDING ls_calendar TO ls_entity.
*        APPEND ls_entity TO et_entityset.
*      ENDLOOP.
      lob_filter = io_tech_request_context->get_filter( ).
      lt_select_option = lob_filter->get_filter_select_options( ).
      lv_wstrg = lob_filter->get_filter_string( ).

      SELECT mandt, vkorg, vtweg, yearweek, split_week, start_day, end_day, cal_year, cal_month, screen_col
        FROM zttp4_calendar
        INTO CORRESPONDING FIELDS OF TABLE @lt_calendar
        WHERE (lv_wstrg).

      IF sy-subrc = 0.
        CLEAR: ls_entity,et_entityset.
        LOOP AT lt_calendar INTO ls_calendar.
          MOVE-CORRESPONDING ls_calendar TO ls_entity.
          APPEND ls_entity TO et_entityset.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->PLAN_PRODUCTSSET_GET_ENTITYSET
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
* | [<---] ET_ENTITYSET                   TYPE        ZOCL_TP4_PLAN_HDR_MPC=>TT_PLAN_PRODUCTS
* | [<---] ES_RESPONSE_CONTEXT            TYPE        /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method PLAN_PRODUCTSSET_GET_ENTITYSET.
****************************************************************
* Project   :  TP4                                              *
* RICEFW ID:                                                    *
* SCA ID   :   SCA ID – XXXX                                    *
* Method   :   PLAN_PRODUCTSSET_GET_ENTITYSET                   *
* Description:          *
*                                                               *
* Created By :                           *
* Created Date: 01-10-2025                                      *
* Transport Request:                                 *
*****************************************************************
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZOCL_TP4_PLAN_HDR_DPC_EXT->RAISE_EXCEPTION_FROM_MESSAGE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_MESSAGE                     TYPE        BAPI_MSG
* | [EXC!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD raise_exception_from_message.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZOCL_TP4_PLAN_HDR_DPC_EXT->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ACTION_NAME                 TYPE        STRING(optional)
* | [--->] IT_PARAMETER                   TYPE        /IWBEP/T_MGW_NAME_VALUE_PAIR(optional)
* | [--->] IO_TECH_REQUEST_CONTEXT        TYPE REF TO /IWBEP/IF_MGW_REQ_FUNC_IMPORT(optional)
* | [<---] ER_DATA                        TYPE REF TO DATA
* | [!CX!] /IWBEP/CX_MGW_BUSI_EXCEPTION
* | [!CX!] /IWBEP/CX_MGW_TECH_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.

    DATA: ls_plan TYPE zocl_tp4_plan_hdr_mpc_ext=>ts_plan_header.

    IF iv_action_name = 'Promo_Button'.

      LOOP AT it_parameter INTO DATA(ls_parameter).

        CASE ls_parameter-name.
          WHEN 'PlanId'.
            DATA(lv_plan_id)    = ls_parameter-value.
          WHEN 'Status'.
            DATA(lv_status)     = ls_parameter-value.
          WHEN OTHERS.
        ENDCASE.

      ENDLOOP.

      zcl_tp4_promoplan=>m_set_new_status(
                EXPORTING
                  iv_planid     = CONV #( lv_plan_id )
                  iv_new_status = CONV #( lv_status )
                IMPORTING
                  ev_error      = DATA(lv_error) ).


      IF lv_error IS NOT INITIAL.
        "raise exception
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = mo_context->get_message_container( ).
      ELSE.

        ls_plan-plan_id         = lv_plan_id.

        copy_data_to_ref( EXPORTING is_data = ls_plan CHANGING cr_data = er_data ).

      ENDIF.

      ENDIF.
    ENDMETHOD.
ENDCLASS.