class ZCL_ZPRTP4_PROD_HIERAR_DPC_EXT definition
  public
  inheriting from ZCL_ZPRTP4_PROD_HIERAR_DPC
  create public .

public section.
protected section.

  methods PRODHIERSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZPRTP4_PROD_HIERAR_DPC_EXT IMPLEMENTATION.


  METHOD prodhierset_get_entityset.

    DATA: lr_sa_id TYPE RANGE OF zttp4_sa-sa_id.
    DATA: lv_sa_id TYPE zttp4_sa-sa_id,
          lt_vkorg TYPE RANGE OF vkorg,
          lt_vtweg TYPE RANGE OF vtweg,
          lt_sa_id TYPE RANGE OF zde_responsability_area,
          lr_prodh TYPE RANGE OF prodh_d,
          lv_prodh TYPE prodh_d.



    " Get filter values from the request

    LOOP AT it_filter_select_options INTO DATA(ls_filter).

      LOOP AT ls_filter-select_options INTO DATA(ls_sel).

        CASE ls_filter-property.
          WHEN 'SaId'.
            lv_sa_id = ls_sel-low.
            APPEND VALUE #( sign = ls_sel-sign option = ls_sel-option low = ls_sel-low high = ls_sel-high ) TO lr_sa_id.
        ENDCASE.

      ENDLOOP.

    ENDLOOP.

    IF lr_sa_id[] IS NOT INITIAL.

      " Get Product Hierarchy by Sales Area

      SELECT prodh
        FROM zttp4_sa_prodh
        INTO TABLE @DATA(lt_prodh)
        WHERE sa_id IN @lr_sa_id.

      SORT lt_prodh.
      DELETE ADJACENT DUPLICATES FROM lt_prodh COMPARING prodh.

    ELSE.
      "Get authorized values for current user
      SELECT vkorg,
             vtweg,
             sa_id
             FROM zttp4_sa_users
        WHERE user_name = @sy-uname
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


        "Get Product Hierarchy
        SELECT prodh
               FROM zttp4_sa_prodh
               INTO TABLE @lt_prodh
               WHERE vkorg IN @lt_vkorg
               AND vtweg IN @lt_vtweg
               AND sa_id IN @lt_sa_id.
        IF sy-subrc <> 0.
          CLEAR lv_prodh.
        ELSE.
          SORT lt_prodh.
          DELETE ADJACENT DUPLICATES FROM lt_prodh COMPARING prodh.
        ENDIF.
      ENDIF.

    ENDIF.

*    DATA(lv_prodh_like) = |{ lv_prodh(3) }%|.


    lr_prodh = VALUE #( FOR ls_prodh IN lt_prodh ( sign   = 'I'
                                                   option = 'CP'
                                                   low    = ls_prodh-prodh(3) && '*' ) ) .

    SELECT prodh
      FROM mvke
      INTO TABLE @DATA(lt_mvke)
     WHERE vkorg IN @lt_vkorg
       AND vtweg IN @lt_vtweg
       AND prodh IN @lr_prodh.

    SORT lt_mvke BY prodh.
    DELETE ADJACENT DUPLICATES FROM lt_mvke COMPARING prodh.

    CLEAR lr_prodh.
    LOOP AT lt_mvke INTO DATA(ls_mvke).

      lr_prodh = VALUE #( BASE lr_prodh ( sign   = 'I'
                                          option = 'EQ'
                                          low    = ls_mvke-prodh(3) )
                                        ( sign   = 'I'
                                          option = 'EQ'
                                          low    = ls_mvke-prodh(6) )
                                        ( sign   = 'I'
                                          option = 'EQ'
                                          low    = ls_mvke-prodh(9) )
                                        ( sign   = 'I'
                                          option = 'EQ'
                                          low    = ls_mvke-prodh(14) )
                                        ( sign   = 'I'
                                          option = 'EQ'
                                          low    = ls_mvke-prodh ) ) .

    ENDLOOP.

    SORT lr_prodh BY low.
    DELETE ADJACENT DUPLICATES FROM lr_prodh COMPARING low.
    " Get Product Hierarchy

*    LOOP AT lt_prodh ASSIGNING FIELD-SYMBOL(<lfs_prodh>).
*      DATA(lv_prodh_like) = |{ <lfs_prodh>-prodh(3) }%|.
      SELECT a~prodh, a~stufe, b~vtext
        FROM t179 AS a INNER JOIN t179t AS b ON a~prodh EQ b~prodh
        INTO TABLE @DATA(lt_t179)
        WHERE a~prodh IN @lr_prodh"LIKE @lv_prodh_like
        AND   b~spras EQ @sy-langu.
*    ENDLOOP.

    IF lt_t179 IS INITIAL.
      SELECT a~prodh, a~stufe, b~vtext
        FROM t179 AS a INNER JOIN t179t AS b ON a~prodh EQ b~prodh
        INTO TABLE @lt_t179
        WHERE b~spras EQ @sy-langu.
    ENDIF.

    SORT lt_t179 BY prodh stufe.

    LOOP AT lt_t179 INTO DATA(ls_t179).

      APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<lfs_entityset>).

      CASE ls_t179-stufe.

        WHEN '1'.

          <lfs_entityset>-said  = lv_sa_id.
          <lfs_entityset>-prodh = ls_t179-prodh.
          <lfs_entityset>-stufe = ls_t179-stufe.
          <lfs_entityset>-vtext = ls_t179-vtext.

        WHEN '2'.

          <lfs_entityset>-said      = lv_sa_id.
          <lfs_entityset>-prodh     = ls_t179-prodh.
          <lfs_entityset>-stufe     = ls_t179-stufe.
          <lfs_entityset>-vtext     = ls_t179-vtext.
          <lfs_entityset>-prodhprev = ls_t179-prodh(3).

        WHEN '3'.

          <lfs_entityset>-said      = lv_sa_id.
          <lfs_entityset>-prodh     = ls_t179-prodh.
          <lfs_entityset>-stufe     = ls_t179-stufe.
          <lfs_entityset>-vtext     = ls_t179-vtext.
          <lfs_entityset>-prodhprev = ls_t179-prodh(6).

        WHEN '4'.

          <lfs_entityset>-said      = lv_sa_id.
          <lfs_entityset>-prodh     = ls_t179-prodh.
          <lfs_entityset>-stufe     = ls_t179-stufe.
          <lfs_entityset>-vtext     = ls_t179-vtext.
          <lfs_entityset>-prodhprev = ls_t179-prodh(9).

        WHEN '5'.

          <lfs_entityset>-said      = lv_sa_id.
          <lfs_entityset>-prodh     = ls_t179-prodh.
          <lfs_entityset>-stufe     = ls_t179-stufe.
          <lfs_entityset>-vtext     = ls_t179-vtext.
          <lfs_entityset>-prodhprev = ls_t179-prodh(14).

      ENDCASE.

    ENDLOOP.

    SORT et_entityset BY prodh stufe.

  ENDMETHOD.
ENDCLASS.