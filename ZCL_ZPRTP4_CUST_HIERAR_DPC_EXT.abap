class ZCL_ZPRTP4_CUST_HIERAR_DPC_EXT definition
  public
  inheriting from ZCL_ZPRTP4_CUST_HIERAR_DPC
  create public .

public section.

  data GV_CUSTHITYP type BAPIKNA1_KNVH-CUSTHITYP .
  data GT_FINAL type ZPRTP4_TT_CUST_HIERARCHY_F4 .
  data GV_VKORG type KNVH-VKORG .
  data GV_VTWEG type KNVH-VTWEG .
  data GV_SPART type KNVH-SPART .
  data GV_HITYP type KNVH-HITYP .
  data GV_SA_ID type ZTTP4_SA_BP-SA_ID .
  data GV_KUNNR type KNVH-KUNNR .

  methods GET_DATA
    importing
      !IT_CUSTOMERS type ZPRTP4_RANGE_CUST_HRCHY
    changing
      !CT_FINAL type ZPRTP4_TT_CUST_HIERARCHY_F4 .
  methods GET_CHILD_DETAILS
    importing
      !IT_NODE_LIST type /IRM/T_GBAPIKNA1_KNVH .
protected section.

  methods CUST_HIERARCHY_F_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZPRTP4_CUST_HIERAR_DPC_EXT IMPLEMENTATION.


  METHOD cust_hierarchy_f_get_entityset.

*    DATA : lv_vkorg TYPE knvh-vkorg,
*           lv_kunnr TYPE knvh-kunnr,
*           lv_vtweg TYPE knvh-vtweg,
*           lv_SPART TYPE knvh-spart,
*           lv_HITYP TYPE knvh-hityp,
*           lv_sa_id TYPE zttp4_sa_bp-sa_id.
*
*    DATA : ls_sel_options  TYPE /iwbep/s_mgw_select_option,
*           lt_filter_vkorg TYPE /iwbep/t_cod_select_options,
*           lt_filter_vtweg TYPE /iwbep/t_cod_select_options,
*           lt_filter_kunnr TYPE /iwbep/t_cod_select_options,
*           lt_filter_spart TYPE /iwbep/t_cod_select_options,
*           lt_filter_sa_id TYPE /iwbep/t_cod_select_options.
*    DATA: lt_sales_area TYPE TABLE OF  bapi_sdvtber.
*
*    TYPES : BEGIN OF lty_final,
*              kunnr    TYPE kunnr_kh,
*              vkorg    TYPE vkorg,
*              vtweg    TYPE vtweg,
*              spart    TYPE spart,
*              datab    TYPE datab_kh,
*              datbi    TYPE datbi_kh,
*              hkunnr   TYPE hkunnr_kh,
*              Level    TYPE c LENGTH 2,
*              NameOrg1 TYPE bu_nameor1,
*              sa_id    TYPE zde_responsability_area,
*              date     TYPE sydatum,
*              hier_flg TYPE char1,
*            END OF lty_final.
*
*
*    DATA: ls_final     TYPE lty_final,
*          lt_final     TYPE TABLE OF lty_final,
*          lt_final_tmp TYPE TABLE OF lty_final.
*
*    DATA: lt_customers TYPE RANGE OF knvh-kunnr.
*    TYPES: lr_customers LIKE LINE OF  lt_customers.
*    TYPES: ty_final TYPE TABLE OF  lty_final.
*
*    DATA: lv_custhityp       TYPE bapikna1_knvh-custhityp,
*          lv_customerno      TYPE bapikna103-customer,
*          lt_node_list       TYPE /irm/t_gbapikna1_knvh,
*          lt_node_list_child TYPE /irm/t_gbapikna1_knvh.
*
*    TYPES : lty_node_list TYPE /irm/t_gbapikna1_knvh.

*    IF sy-uname = 'R73078'.
    "Data declarations
    TYPES: BEGIN OF lty_customer,
             kunnr  TYPE kunnr_kh,
             hkunnr TYPE hkunnr_kh,
             index  TYPE sytabix,
           END OF lty_customer.
    DATA: lt_vkorg              TYPE RANGE OF vkorg,
          lt_vtweg              TYPE RANGE OF vtweg,
          lt_sa_id              TYPE RANGE OF zde_responsability_area,
          lt_date               TYPE RANGE OF sydatum,
          lt_kunnr              TYPE RANGE OF kunnr_kh,
          lt_filter             TYPE /iwbep/t_mgw_select_option,
          lr_customer           TYPE RANGE OF zde_plan_customer,
          lt_customer_i_current TYPE TABLE OF lty_customer,
          lt_customer_all       TYPE TABLE OF lty_customer,
          lt_cust_tmp           TYPE TABLE OF lty_customer,
          lt_hkunnr             TYPE TABLE OF lty_customer,
          lr_hkunnr             TYPE RANGE OF kunnr_kh,
          lr_kunnr              TYPE RANGE OF kunnr_kh,
          lt_final1             TYPE TABLE OF zprtp4_cust_hierarchy_f4,
          lt_hlvl               TYPE TABLE OF zprtp4_cust_hierarchy_f4,
          lv_hkunnr             TYPE kunnr_kh,
          lv_kunnr1             TYPE kunnr_kh,
          lt_kunnr1             TYPE TABLE OF lty_customer,
          lt_hierflg            TYPE RANGE OF char1,
          lv_index              TYPE sytabix,
          lv_level_indx         TYPE char1,
          ls_return             TYPE bapiret2,
          lt_node_list_tmp      TYPE /irm/t_gbapikna1_knvh,
          lt_node_list          TYPE /irm/t_gbapikna1_knvh.


    lt_filter = it_filter_select_options.

    LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<lfs_filter>).
      CASE <lfs_filter>-property.

        WHEN 'Vkorg'.
          "Fill Sales Organization filter values
          lt_vkorg = VALUE #( FOR ls_vkorg IN <lfs_filter>-select_options
                              ( sign = 'I'
                              option = 'EQ'
                              low = ls_vkorg-low ) ).
        WHEN 'Vtweg'.
          "Fill Distribution Channel filter values
          lt_vtweg = VALUE #( FOR ls_vtweg IN <lfs_filter>-select_options
                               ( sign = 'I'
                               option = 'EQ'
                               low = ls_vtweg-low ) ).
        WHEN 'SA_ID'.
          "Fill Sales area id filter values
          lt_sa_id = VALUE #( FOR ls_sa_id IN <lfs_filter>-select_options
                               ( sign = 'I'
                               option = 'EQ'
                               low = ls_sa_id-low ) ).

        WHEN 'Date'.
          "Fill date filter values
          lt_date = VALUE #( FOR ls_date IN <lfs_filter>-select_options
                               ( sign = 'I'
                               option = 'EQ'
                               low = ls_date-low ) ).

        WHEN 'Kunnr'.
          "Fill Plan Customer filter values
          lt_kunnr = VALUE #( FOR ls_kunnr IN <lfs_filter>-select_options
                               ( sign = 'I'
                               option = 'EQ'
                               low = ls_kunnr-low ) ).

        WHEN 'Hier_flg'.
          "Fill Plan Customer filter values
          lt_hierflg = VALUE #( FOR ls_hierflg IN <lfs_filter>-select_options
                               ( sign = 'I'
                               option = 'EQ'
                               low =  ls_hierflg-low ) ).
      ENDCASE.
    ENDLOOP.

    IF lt_date IS INITIAL.
      lt_date = VALUE #( ( sign = 'I'
                           option = 'EQ'
                           low = sy-datum ) ).
    ENDIF.

    "Get all customers
    IF lt_sa_id IS INITIAL OR
       lt_vkorg IS INITIAL OR
      lt_vtweg IS INITIAL.
      "Fetch authorized values for the user
      SELECT vkorg,
             vtweg,
             sa_id
             FROM zttp4_sa_users
        WHERE vkorg IN @lt_vkorg
        AND user_name = @sy-uname
        AND from_date <= @sy-datum
        AND to_date >= @sy-datum
        AND ( promo_access = 'D' OR
        promo_access = 'E' )
        INTO TABLE @DATA(lt_auth).
      IF sy-subrc = 0.
        "Fill Sales Organization range
        lt_vkorg = VALUE #( FOR ls_vkorg_sa IN lt_auth
                              ( sign = 'I'
                              option = 'EQ'
                              low = ls_vkorg_sa-vkorg ) ).
        SORT lt_vkorg BY low.
        DELETE ADJACENT DUPLICATES FROM lt_vkorg COMPARING low.

        "Fill distribution channel range
        lt_vtweg = VALUE #( FOR ls_vtweg_sa IN lt_auth
                              ( sign = 'I'
                              option = 'EQ'
                              low = ls_vtweg_sa-vtweg ) ).
        SORT lt_vtweg BY low.
        DELETE ADJACENT DUPLICATES FROM lt_vtweg COMPARING low.

        "Fill sales team range
        lt_sa_id = VALUE #( FOR ls_said_sa IN lt_auth
                              ( sign = 'I'
                              option = 'EQ'
                              low = ls_said_sa-sa_id ) ).
        SORT lt_sa_id BY low.
        DELETE ADJACENT DUPLICATES FROM lt_sa_id COMPARING low.

      ENDIF.
    ENDIF.


    SELECT plan_customer
    FROM zttp4_sa_bp
    WHERE vkorg IN @lt_vkorg
    AND vtweg IN @lt_vtweg
    AND sa_id IN @lt_sa_id
      INTO TABLE @DATA(lt_customer).
    IF sy-subrc = 0.
*      lr_customer = VALUE #( FOR ls_customer IN lt_customer
*                            ( sign = 'I'
*                              option = 'EQ'
*                              low = ls_customer-plan_customer ) ).

      "Get Customer Hierarchies
      DATA(lv_date) = VALUE #( lt_date[ 1 ]-low OPTIONAL ).
      SELECT SINGLE low FROM tvarvc
       WHERE name = 'ZP_TP4_HITYP'
         AND type = 'P'
        INTO @DATA(lv_hitype).
      IF sy-subrc <> 0.
        CLEAR lv_hitype.
      ENDIF.

      LOOP AT lt_customer ASSIGNING FIELD-SYMBOL(<lfs_customer>).

        CALL FUNCTION 'BAPI_CUSTOMER_GET_CHILDREN'
          EXPORTING
*           VALID_ON   = SY-DATUM
            custhityp  = CONV hityp_kh( lv_hitype )
*           NODE_LEVEL = '00'
            customerno = <lfs_customer>-plan_customer
          IMPORTING
            return     = ls_return
          TABLES
*           sales_area =
            node_list  = lt_node_list_tmp.

        lt_node_list = CORRESPONDING #( BASE ( lt_node_list ) lt_node_list_tmp ).
        FREE: lt_node_list_tmp.
      ENDLOOP.

      lr_kunnr = VALUE #( FOR ls_kunnr_n IN lt_node_list
                        ( sign   = 'I'
                          option = 'EQ'
                          low    = ls_kunnr_n-customer ) ).

      SORT lr_kunnr BY low.
      DELETE ADJACENT DUPLICATES FROM lr_kunnr COMPARING low.

      SELECT partner,
             name_org1
        FROM but000
       WHERE partner IN @lr_kunnr
        INTO TABLE @DATA(lt_bp_data).
      IF sy-subrc <> 0.
        CLEAR lt_bp_data.
      ENDIF.
      DATA(lv_hierflg) = VALUE char1( lt_hierflg[ 1 ]-low OPTIONAL ).

      LOOP AT lt_node_list INTO DATA(ls_node_list).

        ls_node_list-node_level                += 1.
        APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<lfs_entityset>).
        <lfs_entityset>-kunnr                   = ls_node_list-customer.
        <lfs_entityset>-vkorg                   = ls_node_list-sales_org.
        <lfs_entityset>-vtweg                   = ls_node_list-distr_chan.
        <lfs_entityset>-datbi                   = lv_date.
        <lfs_entityset>-hkunnr                  = ls_node_list-parent_customer.
        <lfs_entityset>-level                   = 'L' && ls_node_list-node_level+1(1).
        <lfs_entityset>-nameorg1                = VALUE #( lt_bp_data[ partner = ls_node_list-customer ]-name_org1 OPTIONAL ).
        <lfs_entityset>-sa_id                   = VALUE #( lt_sa_id[ 1 ]-low OPTIONAL ).

        CHECK ls_node_list-node_level           = 01.
        CLEAR: <lfs_entityset>-hkunnr.
      ENDLOOP.

      IF lv_hierflg                             = 'E'.     "Equal Level.
        DELETE et_entityset WHERE level        <> 'L1'.
      ENDIF.
    ENDIF.



*      IF lv_hierflg = 'E'.                            "Equal Level
*        "Fill Fiori structure
*        et_entityset = VALUE #( FOR ls_node_list IN lt_node_list WHERE ( node_level = 00 )
*                                ( kunnr = ls_node_list-customer
*                                  vkorg = ls_node_list-sales_org
*                                  vtweg = ls_node_list-distr_chan
*                                  datbi = lv_date
**                                    hkunnr = ls_cust_current-hkunnr
*                                  level = 'L' && ls_node_list-node_level
*                                  nameorg1 = VALUE #( lt_bp_data[ partner = ls_node_list-customer ]-name_org1 OPTIONAL )
*                                  sa_id =  VALUE #( lt_sa_id[ 1 ]-low OPTIONAL )
*                                   ) ).
*      ELSEIF lv_hierflg = 'D'.                        "lower level
*        "Fill Fiori structure
*        et_entityset = VALUE #( FOR ls_node_list IN lt_node_list
*                                ( kunnr = ls_node_list-customer
*                                  vkorg = ls_node_list-sales_org
*                                  vtweg = ls_node_list-distr_chan
*                                  datbi = lv_date
*                                  hkunnr = ls_node_list-parent_customer
*                                  level = 'L' && ( ls_node_list-node_level+1(1) + 1 )
*                                  nameorg1 = VALUE #( lt_bp_data[ partner = ls_node_list-customer ]-name_org1 OPTIONAL )
*                                  sa_id =  VALUE #( lt_sa_id[ 1 ]-low OPTIONAL )
*                                   ) ).
*      ENDIF.
*    ENDIF.









***      SELECT kunnr,
***             hkunnr
***             FROM knvh
***             WHERE hityp = @lv_hitype "N
***             AND kunnr IN @lr_customer
***             AND vkorg IN @lt_vkorg
***             AND vtweg IN @lt_vtweg
***             AND datbi >= @lv_date
***             INTO TABLE @DATA(lt_customer_current).
***      IF sy-subrc = 0.
***        CLEAR: lt_customer.
***        lt_customer = VALUE #( FOR ls_kunnr_i IN lt_customer_current
***                             ( plan_customer = ls_kunnr_i-kunnr ) ).
****        IF lt_customer IS INITIAL.
****          lt_customer = VALUE #( FOR ls_kunnr_i IN lt_customer_current
****                               ( plan_customer = ls_kunnr_i-kunnr ) ).
****        ENDIF.

***        lt_customer_i_current = CORRESPONDING #( lt_customer_current ).
***        lt_customer_all = CORRESPONDING #( lt_customer_current ).
***        DATA(lv_hierflg) = VALUE char1( lt_hierflg[ 1 ]-low OPTIONAL ).
***        IF lv_hierflg = 'E'."Equal Level
***          lr_kunnr = VALUE #( FOR ls_kunnr_e IN lt_customer_current WHERE ( kunnr IS NOT INITIAL )
***                                 ( sign = 'I'
***                                   option = 'EQ'
***                                   low = ls_kunnr_e-kunnr
***                                  )  ).
***
***          SORT lr_kunnr BY low.
***          DELETE ADJACENT DUPLICATES FROM lr_kunnr COMPARING low.
***
***          SELECT partner,
***            name_org1
***          FROM but000
***          WHERE partner IN @lr_kunnr
****        WHERE partner IN @lr_hkunnr
***          INTO TABLE @DATA(lt_bp_data).
***          IF sy-subrc <> 0.
***            CLEAR lt_bp_data.
***          ENDIF.
***          "Fill Fiori structure
***          et_entityset = VALUE #( FOR ls_cust_current IN lt_customer_current
***                                  ( kunnr = ls_cust_current-kunnr
***                                    vkorg = VALUE #( lt_vkorg[ 1 ]-low OPTIONAL )
***                                    vtweg = VALUE #( lt_vtweg[ 1 ]-low OPTIONAL )
***                                    datbi =  lv_date
****                                    hkunnr = ls_cust_current-hkunnr
***                                    level = 'L1'
***                                    nameorg1 = VALUE #( lt_bp_data[ partner =  ls_cust_current-kunnr ]-name_org1 OPTIONAL )
***                                    sa_id =  VALUE #( lt_sa_id[ 1 ]-low OPTIONAL )
***                                     ) ).
***          RETURN.
***        ELSEIF lv_hierflg = 'U' OR lv_hierflg IS INITIAL."higher level
***          CLEAR lt_customer_all.
***
***          "Get all customers for sales org, distribution channel and  Hierarchy type
***          SELECT kunnr,
***                 hkunnr
***             FROM knvh
***             WHERE hityp = @lv_hitype "N
****               AND vkorg IN @lt_vkorg
****               AND vtweg IN @lt_vtweg
***             AND datbi >= @lv_date
***             INTO TABLE @lt_cust_tmp.
***          IF sy-subrc = 0.
***
***            LOOP AT lt_customer_current ASSIGNING FIELD-SYMBOL(<lfs_cust_curr>).
***              lv_hkunnr = <lfs_cust_curr>-hkunnr.
***              lv_index = sy-tabix.
***              APPEND INITIAL LINE TO lt_customer_all ASSIGNING FIELD-SYMBOL(<lfs_cust_all>).
***              <lfs_cust_all>-kunnr = <lfs_cust_curr>-kunnr.
***              <lfs_cust_all>-hkunnr = <lfs_cust_curr>-hkunnr.
***              <lfs_cust_all>-index = lv_index.
***              DO 7 TIMES.
***                IF lv_hkunnr IS INITIAL."Top level
***                  EXIT.
***                ENDIF.
***                DATA(ls_cust_tmp) = VALUE #( lt_cust_tmp[ kunnr = lv_hkunnr  ] OPTIONAL ).
***                IF ls_cust_tmp IS NOT INITIAL.
***                  CLEAR:  lv_hkunnr, lt_hkunnr.
****                    lt_hkunnr = VALUE #( FOR ls_hkunnr IN lt_cust_tmp WHERE ( hkunnr <> space )
****                                          ( kunnr =  ls_hkunnr-kunnr
****                                           hkunnr = ls_hkunnr-hkunnr
****                                           index = lv_index ) ).
***
***                  lt_hkunnr = VALUE #( ( kunnr =  ls_cust_tmp-kunnr
***                                         hkunnr = ls_cust_tmp-hkunnr
***                                         index = lv_index ) ).
***                  APPEND INITIAL LINE TO lt_customer_all ASSIGNING <lfs_cust_all>.
****                    <lfs_cust_all>-kunnr = VALUE #( lt_cust_tmp[ 1 ]-kunnr OPTIONAL ).
****                    <lfs_cust_all>-hkunnr = VALUE #( lt_cust_tmp[ 1 ]-hkunnr OPTIONAL ).
***                  <lfs_cust_all>-kunnr = ls_cust_tmp-kunnr.
***                  <lfs_cust_all>-hkunnr = ls_cust_tmp-hkunnr.
***                  <lfs_cust_all>-index = lv_index.
***
****                  lt_customer_all = CORRESPONDING #( BASE ( lt_customer_all ) lt_cust_tmp  ).
***                  IF lt_hkunnr IS NOT INITIAL.
***                    lv_hkunnr = VALUE #( lt_hkunnr[ 1 ]-hkunnr OPTIONAL ).
***                  ENDIF.
****                DELETE lt_customer_current WHERE hkunnr = <lfs_cust_curr>-hkunnr.
***                  CLEAR ls_cust_tmp.
***                ENDIF.
***              ENDDO.
***            ENDLOOP.
***          ENDIF.
***
***        ELSEIF lv_hierflg = 'D'."lower level
***          CLEAR lt_customer_all.
***          SELECT kunnr,
***                                hkunnr
***                         FROM knvh
***                         WHERE hityp = @lv_hitype "N
****                           AND hkunnr = @lv_kunnr1
***                         AND vkorg IN @lt_vkorg
***                         AND vtweg IN @lt_vtweg
***                         AND datbi >= @lv_date
***                         INTO TABLE @lt_cust_tmp.
***          IF sy-subrc = 0.
***            LOOP AT lt_customer_i_current ASSIGNING FIELD-SYMBOL(<lfs_i_current>).
***
***              lv_kunnr1 = <lfs_i_current>-kunnr.
***              lv_index = sy-tabix.
***              APPEND INITIAL LINE TO lt_customer_all ASSIGNING <lfs_cust_all>.
***              <lfs_cust_all>-kunnr = <lfs_i_current>-kunnr.
***              <lfs_cust_all>-hkunnr = <lfs_i_current>-hkunnr.
***              <lfs_cust_all>-index = lv_index.
***
***              DO 7 TIMES.
***                ls_cust_tmp = VALUE #( lt_cust_tmp[ hkunnr = lv_kunnr1  ] OPTIONAL ).
***                IF ls_cust_tmp IS NOT INITIAL.
***                  CLEAR:  lv_kunnr1, lt_kunnr1.
***                  lt_kunnr1 = VALUE #(
****                    FOR ls_kunnr1 IN lt_cust_tmp WHERE ( kunnr <> space )
***                                        ( kunnr =  ls_cust_tmp-kunnr
***                                         hkunnr = ls_cust_tmp-hkunnr
***                                         index = lv_index ) ).
****                    lt_customer_all = CORRESPONDING #( BASE ( lt_customer_all ) lt_cust_tmp  ).
***                  APPEND INITIAL LINE TO lt_customer_all ASSIGNING <lfs_cust_all>.
***                  <lfs_cust_all>-kunnr = ls_cust_tmp-kunnr.
***                  <lfs_cust_all>-hkunnr = ls_cust_tmp-hkunnr.
***                  <lfs_cust_all>-index = lv_index.
***
***                  IF lt_kunnr1 IS NOT INITIAL.
***                    lv_kunnr1 = VALUE #( lt_kunnr1[ 1 ]-kunnr OPTIONAL ).
***                  ENDIF.
***                  CLEAR  ls_cust_tmp.
***                ELSE."last level
***                  EXIT."move to next customer
***                ENDIF.
***              ENDDO.
***            ENDLOOP.
***          ENDIF.
***
****            LOOP AT lt_customer_i_current ASSIGNING FIELD-SYMBOL(<lfs_i_current>).
****
****              lv_kunnr1 = <lfs_i_current>-kunnr.
****
****              DO 7 TIMES.
****                SELECT kunnr,
****                       hkunnr
****                FROM knvh
****                WHERE hityp = @lv_hitype "N
****                AND hkunnr = @lv_kunnr1
****                AND vkorg IN @lt_vkorg
****                AND vtweg IN @lt_vtweg
****                AND datbi >= @lv_date
****                INTO TABLE @lt_cust_tmp.
****                IF sy-subrc = 0.
****                  CLEAR:  lv_kunnr1, lt_kunnr1.
****                  lt_kunnr1 = VALUE #( FOR ls_kunnr1 IN lt_cust_tmp WHERE ( kunnr <> space )
****                                        ( kunnr =  ls_kunnr1-kunnr
****                                         hkunnr = ls_kunnr1-hkunnr ) ).
****                  lt_customer_all = CORRESPONDING #( BASE ( lt_customer_all ) lt_cust_tmp  ).
****                  IF lt_kunnr1 IS NOT INITIAL.
****                    lv_kunnr1 = VALUE #( lt_kunnr1[ 1 ]-kunnr OPTIONAL ).
****                  ENDIF.
****                  CLEAR lt_cust_tmp.
****                ELSE."last level
****                  EXIT."move to next customer
****                ENDIF.
****              ENDDO.
****            ENDLOOP.
***
***        ENDIF.
***
***        "BP: General data
****        lr_hkunnr = VALUE #( FOR ls_hkunnr IN lt_customer_all WHERE ( hkunnr IS NOT INITIAL )
****                            ( sign = 'I'
****                              option = 'EQ'
****                              low = ls_hkunnr-hkunnr
****                             )  ).
****
****        SORT lr_hkunnr BY low.
****        DELETE ADJACENT DUPLICATES FROM lr_hkunnr COMPARING low.
***
***
***        lr_kunnr = VALUE #( FOR ls_kunnr_nm IN lt_customer_all WHERE ( kunnr IS NOT INITIAL )
***                                    ( sign = 'I'
***                                      option = 'EQ'
***                                      low = ls_kunnr_nm-kunnr
***                                     )  ).
***
***        SORT lr_kunnr BY low.
***        DELETE ADJACENT DUPLICATES FROM lr_kunnr COMPARING low.
***
***
***        SELECT partner,
***          name_org1
***        FROM but000
***        WHERE partner IN @lr_kunnr
****        WHERE partner IN @lr_hkunnr
***        INTO TABLE @lt_bp_data.
***        IF sy-subrc <> 0.
***          CLEAR lt_bp_data.
***        ENDIF.
***
***        IF lv_hierflg = 'D'."Lower level
***          LOOP AT lt_customer_all INTO DATA(ls_customer_all) GROUP BY ls_customer_all-index INTO DATA(lt_group_key).
***            DATA(lv_counter) = 1.
***            LOOP AT GROUP lt_group_key INTO DATA(ls_lvl).
***              APPEND INITIAL LINE TO lt_final1 ASSIGNING FIELD-SYMBOL(<lfs_low>).
***              <lfs_low>-kunnr = ls_lvl-kunnr.
***              <lfs_low>-vkorg = VALUE #( lt_vkorg[ 1 ]-low OPTIONAL ).
***              <lfs_low>-vtweg = VALUE #( lt_vtweg[ 1 ]-low OPTIONAL ).
***              <lfs_low>-datbi =  lv_date.
***              <lfs_low>-hkunnr = COND #( WHEN lv_counter = 1 THEN space ELSE ls_lvl-hkunnr ).
***              <lfs_low>-level = |{ 'L' }| && |{ lv_counter }|.
***              <lfs_low>-nameorg1 = VALUE #( lt_bp_data[ partner =  ls_lvl-kunnr ]-name_org1 OPTIONAL ).
***              <lfs_low>-sa_id =  VALUE #( lt_sa_id[ 1 ]-low OPTIONAL ).
***
***              lv_counter = lv_counter + 1.
***            ENDLOOP.
***          ENDLOOP.
***
***        ELSEIF lv_hierflg = 'U' OR lv_hierflg IS INITIAL."higher level
***          "Fill Odata structure based on levels
***          lt_hlvl = VALUE #( FOR ls_cust_all IN lt_customer_all WHERE ( hkunnr IS INITIAL )
***                                     ( kunnr = ls_cust_all-kunnr
***                                       vkorg = VALUE #( lt_vkorg[ 1 ]-low OPTIONAL )
***                                       vtweg = VALUE #( lt_vtweg[ 1 ]-low OPTIONAL )
****                               spart = ls_cust_all-spart
****                               datab = ls_cust_all-datab
***                                       datbi = lv_date
***                                       hkunnr = ls_cust_all-hkunnr
***                                       level = 'L1'
***                                       nameorg1 = VALUE #( lt_bp_data[ partner =  ls_cust_all-kunnr ]-name_org1 OPTIONAL )
***                                       sa_id = VALUE #( lt_sa_id[ 1 ]-low OPTIONAL ) )
***                                       ).
***
***          "Get previous level Customer
***          DATA(lv_level) = '1'.
***
***          "Fill lower level Odata
***          DATA : lv_kunnr_l1 TYPE kunnr_kh.
***          LOOP AT  lt_hlvl ASSIGNING FIELD-SYMBOL(<lfs_hlvl>).
***            lv_kunnr_l1 = <lfs_hlvl>-kunnr.
***            lv_level = 1.
***            APPEND  <lfs_hlvl> TO lt_final1.
***            WHILE  lv_kunnr_l1 IS NOT INITIAL.
***              DATA(ls_cust_all1) = VALUE #( lt_customer_all[ hkunnr =  lv_kunnr_l1 ] OPTIONAL ).
***              DATA(lv_cust_index) = line_index(  lt_customer_all[ hkunnr = lv_kunnr_l1 ] ).
***              IF ls_cust_all1 IS NOT INITIAL.
***                lv_kunnr_l1 = ls_cust_all1-kunnr.
***                lv_level = lv_level + 1.
***                APPEND INITIAL LINE TO lt_final1 ASSIGNING FIELD-SYMBOL(<lfs_final1>).
***                <lfs_final1>-kunnr = ls_cust_all1-kunnr.
***                <lfs_final1>-vkorg = VALUE #( lt_vkorg[ 1 ]-low OPTIONAL ).
***                <lfs_final1>-vtweg = VALUE #( lt_vtweg[ 1 ]-low OPTIONAL ).
****                 spart = <lfs_customer_all>-spart.
******              datab = <lfs_customer_all>-datab.
***                <lfs_final1>-datbi = lv_date.
***                <lfs_final1>-hkunnr = ls_cust_all1-hkunnr.
***                <lfs_final1>-level = |{ 'L' }| && |{ lv_level }|.
***                <lfs_final1>-nameorg1 = VALUE #( lt_bp_data[ partner =  <lfs_final1>-kunnr ]-name_org1 OPTIONAL ).
***                <lfs_final1>-sa_id = VALUE #( lt_sa_id[ 1 ]-low OPTIONAL ).
***                DELETE lt_customer_all  INDEX  lv_cust_index.
***              ELSE.
***                CLEAR lv_kunnr_l1.
***              ENDIF.
***            ENDWHILE.
***            CLEAR:  lv_level, lv_cust_index.
***          ENDLOOP.
***        ENDIF.
***
***
****        et_entityset = CORRESPONDING #( gt_final1 ).
****        DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING kunnr vkorg vtweg hkunnr level.
***        LOOP AT lt_final1 ASSIGNING FIELD-SYMBOL(<lfs_gt_final1>).
***          IF NOT ( line_exists( et_entityset[ kunnr = <lfs_gt_final1>-kunnr vkorg = <lfs_gt_final1>-vkorg vtweg = <lfs_gt_final1>-vtweg
***                  hkunnr = <lfs_gt_final1>-hkunnr level = <lfs_gt_final1>-level  ] ) ).
***            APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<lfs_entityset>).
***            <lfs_entityset>-kunnr = <lfs_gt_final1>-kunnr.
***            <lfs_entityset>-vkorg = <lfs_gt_final1>-vkorg.
***            <lfs_entityset>-vtweg = <lfs_gt_final1>-vtweg.
***            <lfs_entityset>-datbi = <lfs_gt_final1>-datbi.
***            <lfs_entityset>-hkunnr = <lfs_gt_final1>-hkunnr.
***            <lfs_entityset>-level = <lfs_gt_final1>-level.
***            <lfs_entityset>-nameorg1 = <lfs_gt_final1>-nameorg1.
***            <lfs_entityset>-sa_id =  <lfs_gt_final1>-sa_id.
***          ENDIF.
***        ENDLOOP.
***      ENDIF.
***    ELSE."Customers is empty
***      RETURN.
***    ENDIF.
****    ELSE.
*
*
**reading sales org.
*      READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Vkorg'.
*      IF sy-subrc = 0.
*        lt_filter_vkorg = ls_sel_options-select_options[].
*        READ TABLE lt_filter_vkorg  INTO DATA(ls_filter_vkorg) INDEX 1.
*        IF sy-subrc = 0.
*          gv_vkorg = ls_filter_vkorg-low.
*        ENDIF.
*        CLEAR : ls_sel_options.
*      ENDIF.
** Reading Sales  distribution channel
*      READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Vtweg'.
*      IF sy-subrc = 0.
*        lt_filter_vtweg = ls_sel_options-select_options[].
*        READ TABLE lt_filter_vtweg  INTO DATA(ls_filter_vtweg) INDEX 1.
*        IF sy-subrc = 0.
*          gv_vtweg = ls_filter_vtweg-low.
*        ENDIF.
*        CLEAR : ls_sel_options.
*      ENDIF.
*
** Reading plan customer
*      READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Kunnr'.
*      IF sy-subrc = 0.
*        lt_filter_kunnr = ls_sel_options-select_options[].
*        READ TABLE lt_filter_kunnr  INTO DATA(ls_filter_kunnr) INDEX 1.
*        IF sy-subrc = 0.
*          gv_kunnr = ls_filter_kunnr-low.
*        ENDIF.
*        CLEAR : ls_sel_options.
*      ENDIF.
** Reading Sales division
*      READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Spart'.
*      IF sy-subrc = 0.
*        lt_filter_spart = ls_sel_options-select_options[].
*        READ TABLE lt_filter_spart  INTO DATA(ls_filter_spart) INDEX 1.
*        IF sy-subrc = 0.
*          gv_SPART = ls_filter_spart-low.
*        ENDIF.
*        CLEAR : ls_sel_options.
*      ENDIF.
*
**Reading SA_ID
*      READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'SA_ID'.
*      IF sy-subrc = 0.
*        lt_filter_sa_id = ls_sel_options-select_options[].
*        READ TABLE lt_filter_sa_id  INTO DATA(ls_filter_sa_id) INDEX 1.
*        IF sy-subrc = 0.
*          gv_sa_id = ls_filter_sa_id-low.
*        ENDIF.
*        CLEAR : ls_sel_options.
*      ENDIF.
*
**Reading cusomer hierarchy type from TVARVC
*      SELECT SINGLE low   "P
*     INTO gv_hityp
*     FROM tvarvc
*     WHERE name = 'Z_CUSTOMER_HIRERACHY_HITYP'
*         AND type = 'S'
*         AND sign = 'I'
*         AND opti = 'EQ'.
*
**Populate list of customers from zttp4_sa_bp based on the selction criteria
*      SELECT vkorg,
*             vtweg,
*             sa_id,
*           plan_customer
*         FROM zttp4_sa_bp
*         INTO TABLE @DATA(lt_sa_custmers)
*         WHERE
*         vkorg = @gv_vkorg
*         AND  vtweg = @gv_VTWEG
*         AND  sa_id = @gv_sa_id.
*
**prepare customer range table.
*      lt_customers = VALUE #(
*      FOR wa IN lt_sa_custmers
*      ( sign = 'I' option = 'EQ' low = wa-plan_customer ) ).
*
**    *Handling exceptions
*
*      TRY.
*          IF gv_kunnr IS NOT INITIAL AND lt_sa_custmers IS INITIAL.
*            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*              EXPORTING
*                textid  = /iwbep/cx_mgw_busi_exception=>business_error
*                message = 'No records found.'.
*          ENDIF.
*
*          IF lt_sa_custmers IS NOT INITIAL AND gv_kunnr IS NOT INITIAL.
*            DELETE lt_sa_custmers WHERE plan_customer EQ gv_kunnr.
*            IF sy-subrc <> 0.
*              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*                EXPORTING
*                  textid  = /iwbep/cx_mgw_busi_exception=>business_error
*                  message = 'No records found.'.
*            ENDIF.
*          ENDIF.
*
*        CATCH cx_root INTO DATA(lo_general_error).
*          RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
*            EXPORTING
*              textid = /iwbep/cx_mgw_tech_exception=>internal_error.
*      ENDTRY.
*
*      gv_custhityp = gv_hityp.
*
*      IF  lt_customers IS NOT INITIAL.
*        LOOP AT lt_customers INTO DATA(ls_customers).
** Get all the data for filterd customers
*          me->get_data(
*            EXPORTING
*              im_customers =   ls_customers               " Range table for customer hierarchy
*            CHANGING
*              ct_final     =     lt_final             " Table type for customer hierarchy
*          ).
*
*          CLEAR : ls_customers.
*        ENDLOOP.
*      ELSEIF lt_customers IS INITIAL.
*
**handling multiple disturbution channels.
*        SELECT vkorg, vtweg,spart FROM tvta
*         INTO TABLE @DATA(lt_tvta)
*          WHERE vkorg = @gv_vkorg AND vtweg = @gv_vtweg.
*
*        LOOP AT lt_tvta INTO DATA(ls_tvta).
*          lt_sales_area = VALUE #(
*          BASE  lt_sales_area
*          ( sales_org  = gv_vkorg
*           distr_chan =  gv_vtweg
*           division   = ls_tvta-spart ) ).
*          CLEAR :ls_tvta.
*
*
**get the root customer
*          CALL FUNCTION 'BAPI_CUSTOMER_GET_ROOT_LIST'
*            EXPORTING
*              valid_on   = sy-datum
*              custhityp  = gv_custhityp
*            TABLES
*              sales_area = lt_sales_area
*              node_list  = lt_node_list.
*          IF lt_node_list IS NOT INITIAL.
*            me->get_child_details( lt_node_list = lt_node_list ).
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*
*      IF gt_final IS NOT INITIAL.
**
**          copy_data_to_ref(
**        EXPORTING
**          is_data = gt_final
**        CHANGING
**          cr_data = et_entityset  ).
*
** Sending final data to Fiori
*        MOVE-CORRESPONDING gt_final TO et_entityset.
*        CLEAR gt_final.
*      ENDIF.
*    ENDIF.







































































































*===================================================================================
*    DATA : lv_vkorg TYPE knvh-vkorg,
*           lv_kunnr TYPE knvh-kunnr,
*           lv_vtweg TYPE knvh-vtweg,
*           lv_SPART TYPE knvh-spart,
*           lv_HITYP TYPE knvh-hityp,
*
*           lv_sa_id TYPE zttp4_sa_bp-sa_id.
*
*
*
*    DATA : ls_sel_options  TYPE /iwbep/s_mgw_select_option,
*           lt_filter_vkorg TYPE /iwbep/t_cod_select_options,
*           lt_filter_vtweg TYPE /iwbep/t_cod_select_options,
*           lt_filter_kunnr TYPE /iwbep/t_cod_select_options,
*           lt_filter_spart TYPE /iwbep/t_cod_select_options,
*           lt_filter_sa_id TYPE /iwbep/t_cod_select_options. "add
*
*    TYPES : BEGIN OF lty_final,
*              kunnr    TYPE kunnr_kh,
*              Level    TYPE c LENGTH 2,
*              hkunnr   TYPE hkunnr_kh,
*              datab    TYPE datab_kh,
*              datbi    TYPE datbi_kh,
*              NameOrg1 TYPE bu_nameor1,
*
**              kunnr    TYPE kunnr,
**              datab    TYPE datab,
**              datbi    TYPE datbi,
**              hkunnr   TYPE kunnr,
**              Level    TYPE c LENGTH 2,
**              NameOrg1 TYPE bu_nameor1,
*            END OF lty_final.
*
*    DATA: ls_final     TYPE lty_final,
*          lt_final     TYPE TABLE OF lty_final,
*          lt_final_tmp TYPE TABLE OF lty_final.
*
*
*    READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Vkorg'.
*    IF sy-subrc = 0.
*      lt_filter_vkorg = ls_sel_options-select_options[].
*      READ TABLE lt_filter_vkorg  INTO DATA(ls_filter_vkorg) INDEX 1.
*      IF sy-subrc = 0.
*        lv_vkorg = ls_filter_vkorg-low.
*      ENDIF.
*      CLEAR : ls_sel_options.
*    ENDIF.
*
*
*    READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Vtweg'.
*    IF sy-subrc = 0.
*      lt_filter_vtweg = ls_sel_options-select_options[].
*      READ TABLE lt_filter_vtweg  INTO DATA(ls_filter_vtweg) INDEX 1.
*      IF sy-subrc = 0.
*        lv_vtweg = ls_filter_vtweg-low.
*        IF lv_vtweg IS NOT INITIAL.
*          lv_vtweg = '10'.
*        ENDIF.
*      ENDIF.
*      CLEAR : ls_sel_options.
*    ENDIF.
*
*    READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Kunnr'.
*    IF sy-subrc = 0.
*      lt_filter_kunnr = ls_sel_options-select_options[].
*      READ TABLE lt_filter_kunnr  INTO DATA(ls_filter_kunnr) INDEX 1.
*      IF sy-subrc = 0.
*        lv_kunnr = ls_filter_kunnr-low.
*      ENDIF.
*      CLEAR : ls_sel_options.
*    ENDIF.
*
*
*    READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Spart'.
*    IF sy-subrc = 0.
*      lt_filter_spart = ls_sel_options-select_options[].
*      READ TABLE lt_filter_spart  INTO DATA(ls_filter_spart) INDEX 1.
*      IF sy-subrc = 0.
*        lv_SPART = ls_filter_spart-low.
**        IF lv_SPART IS NOT INITIAL.
**          lv_SPART = '00'.
**        ENDIF.
*      ENDIF.
*      CLEAR : ls_sel_options.
*    ELSE.
*      lv_SPART = '00'.
*    ENDIF.
*
*    lv_HITYP = 'P'.
*
**new
*
*    READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'SA_ID'.
*    IF sy-subrc = 0.
*      lt_filter_sa_id = ls_sel_options-select_options[].
*      READ TABLE lt_filter_sa_id  INTO DATA(ls_filter_sa_id) INDEX 1.
*      IF sy-subrc = 0.
*        lv_sa_id = ls_filter_sa_id-low.
*      ENDIF.
*      CLEAR : ls_sel_options.
*    ENDIF.
**eoe new
*
*
*
*    SELECT vkorg,
*           vtweg,
*           sa_id,
*         plan_customer
*       FROM zttp4_sa_bp
*       INTO TABLE @DATA(lt_sa_custmers)
*       WHERE
*       vkorg = @lv_vkorg
*       AND  vtweg = @lv_VTWEG
*       AND  sa_id = @lv_sa_id.
*
*    DATA: lt_sa_kunnr TYPE RANGE OF knvh-hkunnr.
*
*    lt_sa_kunnr = VALUE #(
*FOR wa IN lt_sa_custmers
*( sign = 'I' option = 'EQ' low = wa-plan_customer ) ).
*
*
*
*
*
*
*
**DATA :
**      lv_vkorg TYPE vkorg,
**       lv_kunnr TYPE kunnr,
**       lv_vtweg TYPE vtweg,
**       lv_SPART TYPE spart,
**       lv_HITYP TYPE hityp.
*
**DATA :
**      ls_sel_options  TYPE /iwbep/s_mgw_select_option,
**       lt_filter_vkorg TYPE /iwbep/t_cod_select_options,
**       lt_filter_vtweg TYPE /iwbep/t_cod_select_options,
**       lt_filter_kunnr TYPE /iwbep/t_cod_select_options,
**       lt_filter_spart TYPE /iwbep/t_cod_select_options.
*
**TYPES : BEGIN OF lty_final,
**          kunnr    TYPE kunnr,
**          Level    TYPE c LENGTH 2,
**          hkunnr   TYPE hkunnr_kh,
**          datab    TYPE datab,
**          datbi    TYPE datbi,
**          NameOrg1 TYPE bu_nameor1,
**        END OF lty_final.
*
**DATA:
**      ls_final TYPE lty_final,
**      lt_final TYPE TABLE OF lty_final.
*
*    DATA lv_prev_hkunnr TYPE  hkunnr_kh.
*    DATA lv_final_prev_hkunnr TYPE  hkunnr_kh.
*
**    lv_kunnr = '3000000024'.
**    lv_HITYP = 'P'.
**    lv_SPART = '00'.
**    lv_vkorg = '1081'.
**    lv_vtweg  = '10'.
**    lv_spart = '00'.
*
*
*    IF lv_kunnr IS INITIAL.
*
**    DATA lv_customer TYPE kunnr.
*
*
**      lv_customer = '1058004411'.
**      lv_customer = '1058004412'.
*
**   SELECT a~hityp,
**         a~kunnr,
**         a~vkorg,
**         a~vtweg,
**         a~spart,
**         a~datab,
**         a~datbi,
**         a~hkunnr,
**         b~name_org1
**         FROM knvh AS a
**         LEFT OUTER  JOIN but000 AS b
**         ON a~kunnr = b~partner
**         INTO TABLE @DATA(lt_knvh)
**         WHERE
***      a~kunnr = @lv_customer and
**          hityp = @lv_hityp
**         AND vkorg = @lv_vkorg
**         AND  vtweg = @lv_VTWEG
**         AND spart = @lv_spart
**         AND datbi   >=  @sy-datum.
**IF lv_customer is INITIAL.
*
*
*      SELECT
*         a~kunnr,
*         a~vkorg,
*         a~vtweg,
*         a~hkunnr,
*         a~hityp,
*         a~spart,
*         a~datab,
*         a~datbi,
*
*         b~name_org1
*         FROM knvh AS a
*         LEFT OUTER  JOIN but000 AS b
*         ON a~kunnr = b~partner
*         INTO TABLE @DATA(lt_knvh)
*         WHERE
**      a~kunnr = @lv_customer and
**      a~hkunnr = @lv_customer and
*          hityp = @lv_hityp
*         AND vkorg = @lv_vkorg
*         AND  vtweg = @lv_VTWEG
*         AND spart = @lv_spart
*         AND datbi   >=  @sy-datum.
**         and kunnr in @lt_sa_kunnr. "add
*      IF sy-subrc = 0.
*        DATA(lt_knvh_tmp) = lt_knvh.
*        DATA(lt_knvh_tmp2) = lt_knvh.
*
*        SORT lt_knvh_tmp2 ASCENDING BY  vkorg vtweg DESCENDING hkunnr.
*        SORT lt_knvh_tmp BY hkunnr ASCENDING.
*
**        bov
*        DELETE   lt_knvh_tmp WHERE kunnr NOT IN lt_sa_kunnr.
**        eov
*
*        DELETE lt_knvh_tmp WHERE hkunnr IS NOT INITIAL.
*        DELETE lt_knvh_tmp2 WHERE hkunnr IS INITIAL.
*
*        DATA: lv_index TYPE sy-tabix.
*        DATA: lv_counter TYPE c.
*
*
**delete lt_knvh_tmp WHERE hkunnr <> '1058004423'.
*
*        LOOP AT lt_knvh_tmp INTO DATA(ls_knvh).
*          ls_final-kunnr = ls_knvh-kunnr.
*          ls_final-NameOrg1 = ls_knvh-name_org1.
*          ls_final-datab = ls_knvh-datab.
*          ls_final-datbi = ls_knvh-datbi.
*          ls_final-hkunnr = ''.
*          ls_final-Level = 'L1'.
*
*          APPEND ls_final TO lt_final.
*          CLEAR ls_final.
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh-kunnr.
*          IF sy-subrc = 0.
*            lv_index  =  sy-tabix.
*
*            LOOP AT lt_knvh_tmp2  INTO DATA(ls_knvh_tmp2) FROM lv_index .
*
*              IF ls_knvh_tmp2-hkunnr NE ls_knvh-kunnr.
*                READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*                IF sy-subrc  = 0 .
*                  DATA(lv_kunnr_L2) = ls_knvh_tmp2-hkunnr.
*                  CLEAR : lv_index.
*                  EXIT.
*                ELSE.
*                  EXIT.
*                ENDIF.
*
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = ls_knvh-kunnr.
*              ls_final-Level = 'L2'.
*
**        READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh_tmp2-kunnr.
**        IF sy-subrc = 0.
**          ls_final-Level =  'L2'.
**        ELSE.
**          lv_counter = lv_counter + 1.
**          ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
**        ENDIF.
*
*
*              APPEND ls_final TO lt_final.
*              lv_final_prev_hkunnr  = ls_final-kunnr.
*              CLEAR ls_final.
*
**        IF ls_knvh_tmp2-hkunnr NE ls_knvh-kunnr.
**          DATA(lv_kunnr_L2) = ls_knvh_tmp2-kunnr.
**          CLEAR : lv_index.
**          EXIT.
**        ENDIF.
*            ENDLOOP.
*          ENDIF.
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*          IF sy-subrc = 0 .
*            IF  lv_kunnr_l2 IS INITIAL.
*              lv_kunnr_l2  =  lv_final_prev_hkunnr .
*            ENDIF.
*          ENDIF.
*          CLEAR : lv_final_prev_hkunnr, lv_counter.
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L2.
*          IF sy-subrc = 0.
*            lv_index  = sy-tabix.
*
*            LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L2.
**          DATA(lv_kunnr_L3) = lv_prev_hkunnr .
***          DATA(lv_kunnr_L3) = ls_knvh_tmp2-hkunnr.
**          CLEAR : lv_index,lv_prev_hkunnr .
**          EXIT.
**        ENDIF.
*
*
*              IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L2.
*                READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*                IF sy-subrc  = 0 .
**            DATA(lv_kunnr_L3) = ls_knvh_tmp2-hkunnr.
*                  DATA(lv_kunnr_L3) = lv_prev_hkunnr .
*                  CLEAR : lv_index.
*                  EXIT.
*                ELSE.
*                  EXIT.
*                ENDIF.
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = lv_kunnr_L2.
*              ls_final-Level = 'L3'.
*
**         READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh_tmp2-kunnr.
**        IF sy-subrc = 0.
**          ls_final-Level =  'L3'.
**        ELSE.
**          lv_counter = lv_counter + 1.
**          ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
**        ENDIF.
*
*              APPEND ls_final TO lt_final.
*              lv_final_prev_hkunnr  = ls_final-kunnr.
*              CLEAR ls_final.
*
*              lv_prev_hkunnr  = ls_knvh_tmp2-kunnr.
**
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L2.
**          DATA(lv_kunnr_L3) = ls_knvh_tmp2-kunnr.
**          CLEAR : lv_index.
**          EXIT.
**        ENDIF.
*            ENDLOOP.
*          ENDIF.
*
**    IF lv_kunnr_l3 IS INITIAL.
**      lv_kunnr_l3  =  lv_final_prev_hkunnr .
**      CLEAR : lv_final_prev_hkunnr .
**    ENDIF.
*
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*          IF sy-subrc = 0 .
*            IF  lv_kunnr_l3 IS INITIAL.
*              lv_kunnr_l3  =  lv_final_prev_hkunnr .
*            ENDIF.
*          ENDIF.
*          CLEAR : lv_final_prev_hkunnr .
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L3.
*          IF sy-subrc = 0.
*            lv_index  = sy-tabix.
*
*            LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L3.
**
**          DATA(lv_kunnr_L4) = lv_prev_hkunnr ..
***          DATA(lv_kunnr_L4) = ls_knvh_tmp2-hkunnr.
**          CLEAR : lv_index, lv_prev_hkunnr .
**          EXIT.
**        ENDIF.
*
*
*              IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L3.
*                READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*                IF sy-subrc  = 0 .
**            DATA(lv_kunnr_L4) = ls_knvh_tmp2-hkunnr.
*                  DATA(lv_kunnr_L4) = lv_prev_hkunnr ..
*                  CLEAR : lv_index.
*                  EXIT.
*                ELSE.
*                  EXIT.
*                ENDIF.
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = lv_kunnr_L3.
*              ls_final-Level = 'L4'.
*
**         READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh_tmp2-kunnr.
**        IF sy-subrc = 0.
**          ls_final-Level =  'L4'.
**        ELSE.
**          lv_counter = lv_counter + 1.
**          ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
**        ENDIF.
*
*              APPEND ls_final TO lt_final.
*              lv_final_prev_hkunnr  = ls_final-kunnr.
*              CLEAR ls_final.
*
*              lv_prev_hkunnr  = ls_knvh_tmp2-kunnr.
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L3.
**          DATA(lv_kunnr_L4) = ls_knvh_tmp2-kunnr.
**          CLEAR : lv_index.
**          EXIT.
**        ENDIF.
*            ENDLOOP.
*          ENDIF.
*
**    IF lv_kunnr_l4 IS INITIAL.
**      lv_kunnr_l4  =  lv_final_prev_hkunnr .
**      CLEAR : lv_final_prev_hkunnr .
**    ENDIF.
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*          IF sy-subrc = 0 .
*            IF  lv_kunnr_l4 IS INITIAL.
*              lv_kunnr_l4  =  lv_final_prev_hkunnr .
*            ENDIF.
*          ENDIF.
*          CLEAR : lv_final_prev_hkunnr, lv_counter.
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L4.
*          IF sy-subrc = 0.
*            lv_index  = sy-tabix.
*
*            LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L4.
***          DATA(lv_kunnr_L5) = ls_knvh_tmp2-hkunnr.
**          DATA(lv_kunnr_L5) = lv_prev_hkunnr .
**          CLEAR : lv_index, lv_prev_hkunnr .
**          EXIT.
**        ENDIF.
*
*
*              IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L4.
*                READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*                IF sy-subrc  = 0 .
**            DATA(lv_kunnr_L5) = ls_knvh_tmp2-hkunnr.
*                  DATA(lv_kunnr_L5) = lv_prev_hkunnr .
*                  CLEAR : lv_index.
*                  EXIT.
*                ELSE.
*                  EXIT.
*                ENDIF.
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = lv_kunnr_L4.
*              ls_final-Level = 'L5'.
*
**         READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh_tmp2-kunnr.
**        IF sy-subrc = 0.
**          ls_final-Level =  'L5'.
**        ELSE.
**          lv_counter = lv_counter + 1.
**          ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
**        ENDIF.
*
*              APPEND ls_final TO lt_final.
*              lv_final_prev_hkunnr  = ls_final-kunnr.
*              CLEAR ls_final.
*
*              lv_prev_hkunnr  = ls_knvh_tmp2-kunnr.
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L4.
**          DATA(lv_kunnr_L5) = ls_knvh_tmp2-kunnr.
**          CLEAR : lv_index.
**          EXIT.
**        ENDIF.
*            ENDLOOP.
*          ENDIF.
*
**    IF lv_kunnr_l5 IS INITIAL.
**      lv_kunnr_l5  =  lv_final_prev_hkunnr .
**      CLEAR : lv_final_prev_hkunnr .
**    ENDIF.
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*          IF sy-subrc = 0 .
*            IF  lv_kunnr_l5 IS INITIAL.
*              lv_kunnr_l5  =  lv_final_prev_hkunnr.
*            ENDIF.
*          ENDIF.
*          CLEAR : lv_final_prev_hkunnr, lv_counter.
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L5.
*          IF sy-subrc = 0.
*            lv_index  = sy-tabix.
*
*            LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L5.
***          DATA(lv_kunnr_L6) = ls_knvh_tmp2-hkunnr.
**          DATA(lv_kunnr_L6) = lv_prev_hkunnr .
**          CLEAR : lv_index, lv_prev_hkunnr .
**          EXIT.
**        ENDIF.
*
*              IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L5.
*                READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*                IF sy-subrc  = 0 .
**            DATA(lv_kunnr_L6) = ls_knvh_tmp2-hkunnr.
*                  DATA(lv_kunnr_L6) = lv_prev_hkunnr .
*                  CLEAR : lv_index.
*                  EXIT.
*                ELSE.
*                  EXIT.
*                ENDIF.
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = lv_kunnr_L5.
*              ls_final-Level = 'L6'.
*
**         READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh_tmp2-kunnr.
**        IF sy-subrc = 0.
**          ls_final-Level =  'L6'.
**        ELSE.
**          lv_counter = lv_counter + 1.
**          ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
**        ENDIF.
*
*              APPEND ls_final TO lt_final.
*              lv_final_prev_hkunnr  = ls_final-kunnr.
*              CLEAR ls_final.
*
*              lv_prev_hkunnr  = ls_knvh_tmp2-kunnr.
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L5.
**          DATA(lv_kunnr_L6) = ls_knvh_tmp2-kunnr.
**          CLEAR : lv_index.
**          EXIT.
**        ENDIF.
*            ENDLOOP.
*          ENDIF.
*
**    IF lv_kunnr_l6 IS INITIAL.
**      lv_kunnr_l6  =  lv_final_prev_hkunnr .
**      CLEAR : lv_final_prev_hkunnr .
**    ENDIF.
*
*
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*          IF sy-subrc = 0 .
*            IF  lv_kunnr_l6 IS INITIAL.
*              lv_kunnr_l6  =  lv_final_prev_hkunnr .
*            ENDIF.
*          ENDIF.
*          CLEAR : lv_final_prev_hkunnr, lv_counter.
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L6.
*          IF sy-subrc = 0.
*            lv_index  =  sy-tabix.
*
*            LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
*              IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L6.
**          DATA(lv_kunnr_L7) = ls_knvh_tmp2-kunnr.
*                CLEAR : lv_index,lv_counter.
*                EXIT.
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = lv_kunnr_L6.
*              ls_final-Level = 'L7'.
*
**        lv_counter = lv_counter + 1.
**        ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
*
*              APPEND ls_final TO lt_final.
*              CLEAR ls_final.
*            ENDLOOP.
*          ENDIF.
*
**        READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L7.
***        READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L6.
**        IF sy-subrc = 0.
**          lv_index  = sy-tabix.
**
**          LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
**            ls_final-kunnr = ls_knvh_tmp2-kunnr.
**            ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
**            ls_final-datab = ls_knvh_tmp2-datab.
**            ls_final-datbi = ls_knvh_tmp2-datbi.
**            ls_final-hkunnr = lv_kunnr_L7.
**            ls_final-Level = 'L8'.
**
**            APPEND ls_final TO lt_final.
**            CLEAR ls_final.
**
**            IF ls_knvh_tmp2-kunnr NE lv_kunnr_L7.
**              CLEAR : lv_index.
**              EXIT.
**            ENDIF.
**          ENDLOOP.
**        ENDIF.
*          CLEAR :
**    lv_kunnr_L7,
*          lv_kunnr_L6, lv_kunnr_L5, lv_kunnr_L4, lv_kunnr_L3, lv_kunnr_L2, lv_counter.
*        ENDLOOP.
**      clear : lv_kunnr_L7, lv_kunnr_L6, lv_kunnr_L5, lv_kunnr_L4, lv_kunnr_L3, lv_kunnr_L2.
*        REFRESH : lt_knvh_tmp, lt_knvh_tmp2, lt_knvh.
*
*      ENDIF.
*    ELSE.
*
**            DATA : lv_vkorg TYPE vkorg,
**           lv_kunnr TYPE kunnr,
**           lv_vtweg TYPE vtweg,
**           lv_SPART TYPE spart,
**           lv_HITYP TYPE hityp.
*
*      DATA: lt_hpath TYPE TABLE OF vbpavb.
*
*
*      CALL FUNCTION 'RKE_READ_CUSTOMER_HIERARCHY'
*        EXPORTING
*          customer       = lv_kunnr
*          date           = sy-datum
*          htype          = lv_hityp
*          sales_channel  = lv_vtweg
*          sales_division = lv_spart
*          sales_org      = lv_vkorg
*        TABLES
*          hpath          = lt_hpath.
*
*      IF lt_hpath IS NOT INITIAL.
*
*        SELECT a~kunnr,
*       a~hkunnr,
*       a~datab,
*       a~datbi,
*       b~hzuor,
*       c~name_org1 FROM knvh AS a
*       INNER JOIN  @lt_hpath  AS b
*       ON a~kunnr = b~kunnr
*       AND  a~datbi GE  @sy-datum
*       INNER JOIN    but000 AS c
*       ON a~kunnr = c~partner
*       INTO TABLE @DATA(lt_single_customer).
*        IF lt_single_customer IS NOT INITIAL.
*          SORT lt_single_customer BY hzuor ASCENDING.
*
**           SORT lt_single_customer BY hzuor DESCENDING..
*
*          LOOP AT lt_single_customer INTO DATA(ls_single_cust).
*            IF ls_single_cust-hzuor = '00'.
*              ls_final-kunnr = ls_single_cust-kunnr.
*              ls_final-hkunnr = ls_single_cust-hkunnr.
*              ls_final-datab = ls_single_cust-datab.
*              ls_final-datbi = ls_single_cust-datbi.
*              ls_final-nameorg1 = ls_single_cust-name_org1.
*              ls_final-Level = 'L7'.
*              APPEND   ls_final TO  lt_final_tmp.
*              CLEAR ls_final.
*            ELSE.
*
*              ls_final-kunnr = ls_single_cust-kunnr.
*              ls_final-hkunnr = ls_single_cust-hkunnr.
*              ls_final-datab = ls_single_cust-datab.
*              ls_final-datbi = ls_single_cust-datbi.
*              ls_final-nameorg1 = ls_single_cust-name_org1.
*              lv_counter = lv_counter + 1.
*              ls_final-Level =  |L{ lv_counter ALPHA = IN }|.
*
*              APPEND ls_final TO lt_final.
*              CLEAR: ls_final,ls_single_cust.
*            ENDIF.
*
*
*
*          ENDLOOP.
*          CLEAR : lv_counter.
*          APPEND LINES OF lt_final_tmp TO lt_final.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    IF lt_final IS NOT INITIAL.
*      MOVE-CORRESPONDING lt_final TO et_entityset.
*    ENDIF.
*  ENDMETHOD.
*=======================================================================
*  METHOD cust_hierarchy_f_get_entityset.
**
**    DATA : lv_vkorg TYPE vkorg,
**           lv_kunnr TYPE kunnr,
**           lv_vtweg TYPE vtweg,
**           lv_SPART TYPE spart,
**           lv_HITYP TYPE hityp.
*    DATA : lv_vkorg TYPE knvh-vkorg,
*           lv_kunnr TYPE knvh-kunnr,
*           lv_vtweg TYPE knvh-vtweg,
*           lv_SPART TYPE knvh-spart,
*           lv_sa_id TYPE zttp4_sa_bp-sa_id,
*           lv_HITYP TYPE knvh-hityp.
*
*
*
*    DATA : ls_sel_options  TYPE /iwbep/s_mgw_select_option,
*           lt_filter_vkorg TYPE /iwbep/t_cod_select_options,
*           lt_filter_vtweg TYPE /iwbep/t_cod_select_options,
*           lt_filter_kunnr TYPE /iwbep/t_cod_select_options,
*           lt_filter_sa_id TYPE /iwbep/t_cod_select_options,
*           lt_filter_spart TYPE /iwbep/t_cod_select_options.
*    TYPES : BEGIN OF lty_final,
*              kunnr    TYPE kunnr_kh,
*              Level    TYPE c LENGTH 2,
*              hkunnr   TYPE hkunnr_kh,
*              datab    TYPE datab_kh,
*              datbi    TYPE datbi_kh,
*              NameOrg1 TYPE bu_nameor1,
*
**              kunnr    TYPE kunnr,
**              datab    TYPE datab,
**              datbi    TYPE datbi,
**              hkunnr   TYPE kunnr,
**              Level    TYPE c LENGTH 2,
**              NameOrg1 TYPE bu_nameor1,
*            END OF lty_final.
*
*    DATA: ls_final     TYPE lty_final,
*          lt_final     TYPE TABLE OF lty_final,
*          lt_final_tmp TYPE TABLE OF lty_final.
*
*
*    READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Vkorg'.
*    IF sy-subrc = 0.
*      lt_filter_vkorg = ls_sel_options-select_options[].
*      READ TABLE lt_filter_vkorg  INTO DATA(ls_filter_vkorg) INDEX 1.
*      IF sy-subrc = 0.
*        lv_vkorg = ls_filter_vkorg-low.
*      ENDIF.
*      CLEAR : ls_sel_options.
*    ENDIF.
*
*
*    READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Vtweg'.
*    IF sy-subrc = 0.
*      lt_filter_vtweg = ls_sel_options-select_options[].
*      READ TABLE lt_filter_vtweg  INTO DATA(ls_filter_vtweg) INDEX 1.
*      IF sy-subrc = 0.
*        lv_vtweg = ls_filter_vtweg-low.
**        IF lv_vtweg IS NOT INITIAL.
**          lv_vtweg = '10'.
**        ENDIF.
*      ENDIF.
*      CLEAR : ls_sel_options.
*    ENDIF.
*
*    READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Kunnr'.
*    IF sy-subrc = 0.
*      lt_filter_kunnr = ls_sel_options-select_options[].
*      READ TABLE lt_filter_kunnr  INTO DATA(ls_filter_kunnr) INDEX 1.
*      IF sy-subrc = 0.
*        lv_kunnr = ls_filter_kunnr-low.
*      ENDIF.
*      CLEAR : ls_sel_options.
*    ENDIF.
*
*
*    READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'Spart'.
*    IF sy-subrc = 0.
*      lt_filter_spart = ls_sel_options-select_options[].
*      READ TABLE lt_filter_spart  INTO DATA(ls_filter_spart) INDEX 1.
*      IF sy-subrc = 0.
*        lv_SPART = ls_filter_spart-low.
**        IF lv_SPART IS NOT INITIAL.
**          lv_SPART = '00'.
**        ENDIF.
*      ENDIF.
*      CLEAR : ls_sel_options.
*    ELSE.
**      lv_SPART = '*'.
*    ENDIF.
*
*    lv_HITYP = 'P'.
*
*
*
*    READ TABLE it_filter_select_options INTO ls_sel_options WITH KEY property = 'SA_ID'.
*    IF sy-subrc = 0.
*      lt_filter_sa_id = ls_sel_options-select_options[].
*      READ TABLE lt_filter_sa_id  INTO DATA(ls_filter_sa_id) INDEX 1.
*      IF sy-subrc = 0.
*         lv_sa_id = ls_filter_sa_id-low.
*      ENDIF.
*      CLEAR : ls_sel_options.
*    ENDIF.
*
*
*
*
*
*    DATA lv_prev_hkunnr TYPE  hkunnr_kh.
*    DATA lv_final_prev_hkunnr TYPE  hkunnr_kh.
*
*
*   SELECT vkorg,
*          vtweg,
*          sa_id,
*        plan_customer
*      FROM zttp4_sa_bp
*      INTO TABLE @DATA(lt_sa_custmers)
*      WHERE
*      vkorg = @lv_vkorg
*      AND  vtweg = @lv_VTWEG
*      AND  sa_id = @lv_sa_id.
*
*    DATA: lt_customers TYPE RANGE OF knvh-HKUNNR.
*
*    lt_customers = VALUE #(
*FOR wa IN lt_sa_custmers
*( sign = 'I' option = 'EQ' low = wa-plan_customer ) ).
*
*
*
*
*
*    IF lv_kunnr IS INITIAL.
*
*
*      SELECT
*         a~kunnr,
*         a~vkorg,
*         a~vtweg,
*         a~hkunnr,
*         a~hityp,
*         a~spart,
*         a~datab,
*         a~datbi,
*         b~name_org1
*         FROM knvh AS a
*         LEFT OUTER  JOIN but000 AS b
*         ON a~kunnr = b~partner
*         INTO TABLE @DATA(lt_knvh)
*         WHERE
**      a~kunnr = @lv_customer and
**      a~hkunnr = @lv_customer and
*          hityp = @lv_hityp
*         AND vkorg = @lv_vkorg
*         AND  vtweg = @lv_VTWEG
*
**         and hkunnr in @lt_customers
*
*         AND spart = @lv_spart
*         AND datbi   >=  @sy-datum.
*      IF sy-subrc = 0.
*        DATA(lt_knvh_tmp) = lt_knvh.
*        DATA(lt_knvh_tmp2) = lt_knvh.
*
*        SORT lt_knvh_tmp2 ASCENDING BY  vkorg vtweg DESCENDING hkunnr.
*        SORT lt_knvh_tmp BY hkunnr ASCENDING.
*
*        DELETE lt_knvh_tmp WHERE hkunnr IS NOT INITIAL.
*        DELETE lt_knvh_tmp2 WHERE hkunnr IS INITIAL.
*
*        DATA: lv_index TYPE sy-tabix.
*
*        DATA: lv_counter TYPE c.
*
*
**delete lt_knvh_tmp WHERE hkunnr <> '1058004423'.
*
*        LOOP AT lt_knvh_tmp INTO DATA(ls_knvh).
*          ls_final-kunnr = ls_knvh-kunnr.
*          ls_final-NameOrg1 = ls_knvh-name_org1.
*          ls_final-datab = ls_knvh-datab.
*          ls_final-datbi = ls_knvh-datbi.
*          ls_final-hkunnr = ''.
*          ls_final-Level = 'L1'.
*
*          APPEND ls_final TO lt_final.
*          CLEAR ls_final.
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh-kunnr.
*          IF sy-subrc = 0.
*            lv_index  =  sy-tabix.
*
*            LOOP AT lt_knvh_tmp2  INTO DATA(ls_knvh_tmp2) FROM lv_index .
*
*              IF ls_knvh_tmp2-hkunnr NE ls_knvh-kunnr.
*                READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*                IF sy-subrc  = 0 .
*                  DATA(lv_kunnr_L2) = ls_knvh_tmp2-hkunnr.
*                  CLEAR : lv_index.
*                  EXIT.
*                ELSE.
*                  EXIT.
*                ENDIF.
*
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = ls_knvh-kunnr.
*              ls_final-Level = 'L2'.
*
**        READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh_tmp2-kunnr.
**        IF sy-subrc = 0.
**          ls_final-Level =  'L2'.
**        ELSE.
**          lv_counter = lv_counter + 1.
**          ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
**        ENDIF.
*
*
*              APPEND ls_final TO lt_final.
*              lv_final_prev_hkunnr  = ls_final-kunnr.
*              CLEAR ls_final.
*
**        IF ls_knvh_tmp2-hkunnr NE ls_knvh-kunnr.
**          DATA(lv_kunnr_L2) = ls_knvh_tmp2-kunnr.
**          CLEAR : lv_index.
**          EXIT.
**        ENDIF.
*            ENDLOOP.
*          ENDIF.
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*          IF sy-subrc = 0 .
*            IF  lv_kunnr_l2 IS INITIAL.
*              lv_kunnr_l2  =  lv_final_prev_hkunnr .
*            ENDIF.
*          ENDIF.
*          CLEAR : lv_final_prev_hkunnr, lv_counter.
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L2.
*          IF sy-subrc = 0.
*            lv_index  = sy-tabix.
*
*            LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L2.
**          DATA(lv_kunnr_L3) = lv_prev_hkunnr .
***          DATA(lv_kunnr_L3) = ls_knvh_tmp2-hkunnr.
**          CLEAR : lv_index,lv_prev_hkunnr .
**          EXIT.
**        ENDIF.
*
*
*              IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L2.
*                READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*                IF sy-subrc  = 0 .
**            DATA(lv_kunnr_L3) = ls_knvh_tmp2-hkunnr.
*                  DATA(lv_kunnr_L3) = lv_prev_hkunnr .
*                  CLEAR : lv_index.
*                  EXIT.
*                ELSE.
*                  EXIT.
*                ENDIF.
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = lv_kunnr_L2.
*              ls_final-Level = 'L3'.
*
**         READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh_tmp2-kunnr.
**        IF sy-subrc = 0.
**          ls_final-Level =  'L3'.
**        ELSE.
**          lv_counter = lv_counter + 1.
**          ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
**        ENDIF.
*
*              APPEND ls_final TO lt_final.
*              lv_final_prev_hkunnr  = ls_final-kunnr.
*              CLEAR ls_final.
*
*              lv_prev_hkunnr  = ls_knvh_tmp2-kunnr.
**
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L2.
**          DATA(lv_kunnr_L3) = ls_knvh_tmp2-kunnr.
**          CLEAR : lv_index.
**          EXIT.
**        ENDIF.
*            ENDLOOP.
*          ENDIF.
*
**    IF lv_kunnr_l3 IS INITIAL.
**      lv_kunnr_l3  =  lv_final_prev_hkunnr .
**      CLEAR : lv_final_prev_hkunnr .
**    ENDIF.
*
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*          IF sy-subrc = 0 .
*            IF  lv_kunnr_l3 IS INITIAL.
*              lv_kunnr_l3  =  lv_final_prev_hkunnr .
*            ENDIF.
*          ENDIF.
*          CLEAR : lv_final_prev_hkunnr .
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L3.
*          IF sy-subrc = 0.
*            lv_index  = sy-tabix.
*
*            LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L3.
**
**          DATA(lv_kunnr_L4) = lv_prev_hkunnr ..
***          DATA(lv_kunnr_L4) = ls_knvh_tmp2-hkunnr.
**          CLEAR : lv_index, lv_prev_hkunnr .
**          EXIT.
**        ENDIF.
*
*
*              IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L3.
*                READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*                IF sy-subrc  = 0 .
**            DATA(lv_kunnr_L4) = ls_knvh_tmp2-hkunnr.
*                  DATA(lv_kunnr_L4) = lv_prev_hkunnr ..
*                  CLEAR : lv_index.
*                  EXIT.
*                ELSE.
*                  EXIT.
*                ENDIF.
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = lv_kunnr_L3.
*              ls_final-Level = 'L4'.
*
**         READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh_tmp2-kunnr.
**        IF sy-subrc = 0.
**          ls_final-Level =  'L4'.
**        ELSE.
**          lv_counter = lv_counter + 1.
**          ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
**        ENDIF.
*
*              APPEND ls_final TO lt_final.
*              lv_final_prev_hkunnr  = ls_final-kunnr.
*              CLEAR ls_final.
*
*              lv_prev_hkunnr  = ls_knvh_tmp2-kunnr.
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L3.
**          DATA(lv_kunnr_L4) = ls_knvh_tmp2-kunnr.
**          CLEAR : lv_index.
**          EXIT.
**        ENDIF.
*            ENDLOOP.
*          ENDIF.
*
**    IF lv_kunnr_l4 IS INITIAL.
**      lv_kunnr_l4  =  lv_final_prev_hkunnr .
**      CLEAR : lv_final_prev_hkunnr .
**    ENDIF.
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*          IF sy-subrc = 0 .
*            IF  lv_kunnr_l4 IS INITIAL.
*              lv_kunnr_l4  =  lv_final_prev_hkunnr .
*            ENDIF.
*          ENDIF.
*          CLEAR : lv_final_prev_hkunnr, lv_counter.
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L4.
*          IF sy-subrc = 0.
*            lv_index  = sy-tabix.
*
*            LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L4.
***          DATA(lv_kunnr_L5) = ls_knvh_tmp2-hkunnr.
**          DATA(lv_kunnr_L5) = lv_prev_hkunnr .
**          CLEAR : lv_index, lv_prev_hkunnr .
**          EXIT.
**        ENDIF.
*
*
*              IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L4.
*                READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*                IF sy-subrc  = 0 .
**            DATA(lv_kunnr_L5) = ls_knvh_tmp2-hkunnr.
*                  DATA(lv_kunnr_L5) = lv_prev_hkunnr .
*                  CLEAR : lv_index.
*                  EXIT.
*                ELSE.
*                  EXIT.
*                ENDIF.
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = lv_kunnr_L4.
*              ls_final-Level = 'L5'.
*
**         READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh_tmp2-kunnr.
**        IF sy-subrc = 0.
**          ls_final-Level =  'L5'.
**        ELSE.
**          lv_counter = lv_counter + 1.
**          ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
**        ENDIF.
*
*              APPEND ls_final TO lt_final.
*              lv_final_prev_hkunnr  = ls_final-kunnr.
*              CLEAR ls_final.
*
*              lv_prev_hkunnr  = ls_knvh_tmp2-kunnr.
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L4.
**          DATA(lv_kunnr_L5) = ls_knvh_tmp2-kunnr.
**          CLEAR : lv_index.
**          EXIT.
**        ENDIF.
*            ENDLOOP.
*          ENDIF.
*
**    IF lv_kunnr_l5 IS INITIAL.
**      lv_kunnr_l5  =  lv_final_prev_hkunnr .
**      CLEAR : lv_final_prev_hkunnr .
**    ENDIF.
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*          IF sy-subrc = 0 .
*            IF  lv_kunnr_l5 IS INITIAL.
*              lv_kunnr_l5  =  lv_final_prev_hkunnr.
*            ENDIF.
*          ENDIF.
*          CLEAR : lv_final_prev_hkunnr, lv_counter.
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L5.
*          IF sy-subrc = 0.
*            lv_index  = sy-tabix.
*
*            LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L5.
***          DATA(lv_kunnr_L6) = ls_knvh_tmp2-hkunnr.
**          DATA(lv_kunnr_L6) = lv_prev_hkunnr .
**          CLEAR : lv_index, lv_prev_hkunnr .
**          EXIT.
**        ENDIF.
*
*              IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L5.
*                READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*                IF sy-subrc  = 0 .
**            DATA(lv_kunnr_L6) = ls_knvh_tmp2-hkunnr.
*                  DATA(lv_kunnr_L6) = lv_prev_hkunnr .
*                  CLEAR : lv_index.
*                  EXIT.
*                ELSE.
*                  EXIT.
*                ENDIF.
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = lv_kunnr_L5.
*              ls_final-Level = 'L6'.
*
**         READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = ls_knvh_tmp2-kunnr.
**        IF sy-subrc = 0.
**          ls_final-Level =  'L6'.
**        ELSE.
**          lv_counter = lv_counter + 1.
**          ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
**        ENDIF.
*
*              APPEND ls_final TO lt_final.
*              lv_final_prev_hkunnr  = ls_final-kunnr.
*              CLEAR ls_final.
*
*              lv_prev_hkunnr  = ls_knvh_tmp2-kunnr.
*
**        IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L5.
**          DATA(lv_kunnr_L6) = ls_knvh_tmp2-kunnr.
**          CLEAR : lv_index.
**          EXIT.
**        ENDIF.
*            ENDLOOP.
*          ENDIF.
*
**    IF lv_kunnr_l6 IS INITIAL.
**      lv_kunnr_l6  =  lv_final_prev_hkunnr .
**      CLEAR : lv_final_prev_hkunnr .
**    ENDIF.
*
*
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_final_prev_hkunnr .
*          IF sy-subrc = 0 .
*            IF  lv_kunnr_l6 IS INITIAL.
*              lv_kunnr_l6  =  lv_final_prev_hkunnr .
*            ENDIF.
*          ENDIF.
*          CLEAR : lv_final_prev_hkunnr, lv_counter.
*
*
*          READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L6.
*          IF sy-subrc = 0.
*            lv_index  =  sy-tabix.
*
*            LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
*              IF ls_knvh_tmp2-hkunnr NE lv_kunnr_L6.
**          DATA(lv_kunnr_L7) = ls_knvh_tmp2-kunnr.
*                CLEAR : lv_index,lv_counter.
*                EXIT.
*              ENDIF.
*
*              ls_final-kunnr = ls_knvh_tmp2-kunnr.
*              ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
*              ls_final-datab = ls_knvh_tmp2-datab.
*              ls_final-datbi = ls_knvh_tmp2-datbi.
*              ls_final-hkunnr = lv_kunnr_L6.
*              ls_final-Level = 'L7'.
*
**        lv_counter = lv_counter + 1.
**        ls_final-Level =  |C{ lv_counter ALPHA = IN }|.
*
*              APPEND ls_final TO lt_final.
*              CLEAR ls_final.
*            ENDLOOP.
*          ENDIF.
*
**        READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L7.
***        READ TABLE lt_knvh_tmp2 TRANSPORTING NO FIELDS WITH KEY hkunnr = lv_kunnr_L6.
**        IF sy-subrc = 0.
**          lv_index  = sy-tabix.
**
**          LOOP AT lt_knvh_tmp2 INTO  ls_knvh_tmp2 FROM lv_index .
**            ls_final-kunnr = ls_knvh_tmp2-kunnr.
**            ls_final-NameOrg1 = ls_knvh_tmp2-name_org1.
**            ls_final-datab = ls_knvh_tmp2-datab.
**            ls_final-datbi = ls_knvh_tmp2-datbi.
**            ls_final-hkunnr = lv_kunnr_L7.
**            ls_final-Level = 'L8'.
**
**            APPEND ls_final TO lt_final.
**            CLEAR ls_final.
**
**            IF ls_knvh_tmp2-kunnr NE lv_kunnr_L7.
**              CLEAR : lv_index.
**              EXIT.
**            ENDIF.
**          ENDLOOP.
**        ENDIF.
*          CLEAR :
**    lv_kunnr_L7,
*          lv_kunnr_L6, lv_kunnr_L5, lv_kunnr_L4, lv_kunnr_L3, lv_kunnr_L2, lv_counter.
*        ENDLOOP.
**      clear : lv_kunnr_L7, lv_kunnr_L6, lv_kunnr_L5, lv_kunnr_L4, lv_kunnr_L3, lv_kunnr_L2.
*        REFRESH : lt_knvh_tmp, lt_knvh_tmp2, lt_knvh.
*
*      ENDIF.
*    ELSE.
*
**            DATA : lv_vkorg TYPE vkorg,
**           lv_kunnr TYPE kunnr,
**           lv_vtweg TYPE vtweg,
**           lv_SPART TYPE spart,
**           lv_HITYP TYPE hityp.
*
*      DATA: lt_hpath TYPE TABLE OF vbpavb.
*
*
*      CALL FUNCTION 'RKE_READ_CUSTOMER_HIERARCHY'
*        EXPORTING
*          customer       = lv_kunnr
*          date           = sy-datum
*          htype          = lv_hityp
*          sales_channel  = lv_vtweg
*          sales_division = lv_spart
*          sales_org      = lv_vkorg
*        TABLES
*          hpath          = lt_hpath.
*
*      IF lt_hpath IS NOT INITIAL.
*
*        SELECT a~kunnr,
*       a~hkunnr,
*       a~datab,
*       a~datbi,
*       b~hzuor,
*       c~name_org1 FROM knvh AS a
*       INNER JOIN  @lt_hpath  AS b
*       ON a~kunnr = b~kunnr
*       AND  a~datbi GE  @sy-datum
*       INNER JOIN    but000 AS c
*       ON a~kunnr = c~partner
*       INTO TABLE @DATA(lt_single_customer).
*        IF lt_single_customer IS NOT INITIAL.
*          SORT lt_single_customer BY hzuor ASCENDING.
*
**           SORT lt_single_customer BY hzuor DESCENDING..
*
*          LOOP AT lt_single_customer INTO DATA(ls_single_cust).
*            IF ls_single_cust-hzuor = '00'.
*              ls_final-kunnr = ls_single_cust-kunnr.
*              ls_final-hkunnr = ls_single_cust-hkunnr.
*              ls_final-datab = ls_single_cust-datab.
*              ls_final-datbi = ls_single_cust-datbi.
*              ls_final-nameorg1 = ls_single_cust-name_org1.
*              ls_final-Level = 'L7'.
*              APPEND   ls_final TO  lt_final_tmp.
*              CLEAR ls_final.
*            ELSE.
*
*              ls_final-kunnr = ls_single_cust-kunnr.
*              ls_final-hkunnr = ls_single_cust-hkunnr.
*              ls_final-datab = ls_single_cust-datab.
*              ls_final-datbi = ls_single_cust-datbi.
*              ls_final-nameorg1 = ls_single_cust-name_org1.
*              lv_counter = lv_counter + 1.
*              ls_final-Level =  |L{ lv_counter ALPHA = IN }|.
*
*              APPEND ls_final TO lt_final.
*              CLEAR: ls_final,ls_single_cust.
*            ENDIF.
*
*
*
*          ENDLOOP.
*          CLEAR : lv_counter.
*          APPEND LINES OF lt_final_tmp TO lt_final.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    IF lt_final IS NOT INITIAL.
*      MOVE-CORRESPONDING lt_final TO et_entityset.
*    ENDIF.
*  ENDMETHOD.
  ENDMETHOD.


  METHOD get_child_details.

    DATA : lv_customerno      TYPE bapikna103-customer,
           lt_node_list_child TYPE /irm/t_gbapikna1_knvh,
           lv_counter         TYPE c,
           ls_custmor_data    TYPE bapikna101_1,
           ls_final           TYPE zprtp4_cust_hierarchy_f4.

    LOOP AT it_node_list INTO DATA(ls_node_list) .
      CLEAR : lv_customerno.
      lv_customerno       =  ls_node_list-customer.

      CLEAR : lt_node_list_child,
              ls_node_list.
* Get all the children for single node.
      CALL FUNCTION 'BAPI_CUSTOMER_GET_CHILDREN'
        EXPORTING
          valid_on   = sy-datum
          custhityp  = gv_custhityp
          customerno = lv_customerno
        TABLES
          node_list  = lt_node_list_child.

      LOOP AT  lt_node_list_child INTO DATA(ls_nlist).
        IF sy-tabix = 1.
          lv_counter = 1.
        ENDIF.
* get the customer name.
        CALL FUNCTION 'BAPI_CUSTOMER_GETDETAIL1'
          EXPORTING
            customerno      = ls_nlist-customer
            pi_salesorg     = ls_nlist-sales_org
            pi_distr_chan   = ls_nlist-distr_chan
*           PI_DIVISION     =
          IMPORTING
            pe_personaldata = ls_custmor_data.
        DATA(lv_nameorg1) = |{ ls_custmor_data-firstname  } { ls_custmor_data-lastname }|.

        IF ls_nlist-node_level = '00'.
          ls_final-kunnr = ls_nlist-customer.
          ls_final-hkunnr = ls_nlist-parent_customer.
          ls_final-datab = ls_nlist-valid_from.
          ls_final-datbi = ls_nlist-valid_to.
          ls_final-nameorg1 = lv_nameorg1.
          ls_final-Level = 'L1'.
        ELSE.
          ls_final-kunnr = ls_nlist-customer.
          ls_final-hkunnr = ls_nlist-parent_customer.
          ls_final-datab = ls_nlist-valid_from.
          ls_final-datbi = ls_nlist-valid_to.
          ls_final-nameorg1 = lv_nameorg1.

          IF ls_nlist-node_level = '06'.
            ls_final-Level = 'L7'.
          ELSE.
            lv_counter = lv_counter + 1.
            ls_final-Level =  |L{ lv_counter ALPHA = IN }|.
          ENDIF.
        ENDIF.
* Filling final internal table
        APPEND   ls_final TO  gt_final.
        CLEAR ls_final.
      ENDLOOP.
       CLEAR : lv_counter.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_data.
    DATA : lv_counter    TYPE c,
           lv_customerno TYPE bapikna103-customer,
           lt_node_list  TYPE /irm/t_gbapikna1_knvh.
    DATA: lv_custhityp   TYPE bapikna1_knvh-custhityp.

    CLEAR: lt_node_list.

   lv_customerno =  IT_CUSTOMERS-low.
* Get the root customer for the each node.
    CALL FUNCTION 'BAPI_CUSTOMER_GET_ROOT'
      EXPORTING
        valid_on   = sy-datum
        custhityp  = gv_custhityp
        customerno = lv_customerno
      TABLES
        node_list  = lt_node_list.
    IF sy-subrc = 0.
*      get the child nodes for each root node.
      me->get_child_details( it_node_list = lt_node_list ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.