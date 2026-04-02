class ZOCL_TP4_PROMO_PLAN_MPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_MODEL
  create public .

public section.

  interfaces IF_SADL_GW_MODEL_EXPOSURE_DATA .

  types:
    begin of TS_I_COMPANYCODESTDVHTYPE.
      include type I_COMPANYCODESTDVH.
  types:
    end of TS_I_COMPANYCODESTDVHTYPE .
  types:
   TT_I_COMPANYCODESTDVHTYPE type standard table of TS_I_COMPANYCODESTDVHTYPE .
  types:
    begin of TS_I_CUSTOMER_VHTYPE.
      include type I_CUSTOMER_VH.
  types:
    end of TS_I_CUSTOMER_VHTYPE .
  types:
   TT_I_CUSTOMER_VHTYPE type standard table of TS_I_CUSTOMER_VHTYPE .
  types:
    begin of TS_I_SALESORGANIZATIONTYPE.
      include type I_SALESORGANIZATION.
  types:
      T_SALESORGANIZATION type I_SALESORGANIZATIONTEXT-SALESORGANIZATIONNAME,
    end of TS_I_SALESORGANIZATIONTYPE .
  types:
   TT_I_SALESORGANIZATIONTYPE type standard table of TS_I_SALESORGANIZATIONTYPE .
  types:
    begin of TS_ZCDS_TP4_BRANDTYPE.
      include type ZCDS_TP4_BRAND.
  types:
    end of TS_ZCDS_TP4_BRANDTYPE .
  types:
   TT_ZCDS_TP4_BRANDTYPE type standard table of TS_ZCDS_TP4_BRANDTYPE .
  types:
    begin of TS_ZCDS_TP4_CURRTYPE.
      include type ZCDS_TP4_CURR.
  types:
    end of TS_ZCDS_TP4_CURRTYPE .
  types:
   TT_ZCDS_TP4_CURRTYPE type standard table of TS_ZCDS_TP4_CURRTYPE .
  types:
    begin of TS_ZCDS_TP4_DISTRIBUTION_CHANN.
      include type ZCDS_TP4_DISTRIBUTION_CHANNEL.
  types:
    end of TS_ZCDS_TP4_DISTRIBUTION_CHANN .
  types:
   TT_ZCDS_TP4_DISTRIBUTION_CHANN type standard table of TS_ZCDS_TP4_DISTRIBUTION_CHANN .
  types:
    begin of TS_ZCDS_TP4_FUNDS_PLANTYPE.
      include type ZCDS_TP4_FUNDS_PLAN.
  types:
    end of TS_ZCDS_TP4_FUNDS_PLANTYPE .
  types:
   TT_ZCDS_TP4_FUNDS_PLANTYPE type standard table of TS_ZCDS_TP4_FUNDS_PLANTYPE .
  types:
    begin of TS_ZCDS_TP4_OBJECTIVETYPE.
      include type ZCDS_TP4_OBJECTIVE.
  types:
    end of TS_ZCDS_TP4_OBJECTIVETYPE .
  types:
   TT_ZCDS_TP4_OBJECTIVETYPE type standard table of TS_ZCDS_TP4_OBJECTIVETYPE .
  types:
    begin of TS_ZCDS_TP4_PROMOPLANTYPE.
      include type ZCDS_TP4_PROMOPLAN.
  types:
    end of TS_ZCDS_TP4_PROMOPLANTYPE .
  types:
   TT_ZCDS_TP4_PROMOPLANTYPE type standard table of TS_ZCDS_TP4_PROMOPLANTYPE .
  types:
    begin of TS_ZCDS_TP4_PROMOPNLTYPE.
      include type ZCDS_TP4_PROMOPNL.
  types:
    end of TS_ZCDS_TP4_PROMOPNLTYPE .
  types:
   TT_ZCDS_TP4_PROMOPNLTYPE type standard table of TS_ZCDS_TP4_PROMOPNLTYPE .
  types:
    begin of TS_ZCDS_TP4_PROMOROITYPE.
      include type ZCDS_TP4_PROMOROI.
  types:
    end of TS_ZCDS_TP4_PROMOROITYPE .
  types:
   TT_ZCDS_TP4_PROMOROITYPE type standard table of TS_ZCDS_TP4_PROMOROITYPE .
  types:
    begin of TS_ZCDS_TP4_SALES_AREATYPE.
      include type ZCDS_TP4_SALES_AREA.
  types:
    end of TS_ZCDS_TP4_SALES_AREATYPE .
  types:
   TT_ZCDS_TP4_SALES_AREATYPE type standard table of TS_ZCDS_TP4_SALES_AREATYPE .
  types:
    begin of TS_ZCDS_TP4_SALES_ORGTYPE.
      include type ZCDS_TP4_SALES_ORG.
  types:
    end of TS_ZCDS_TP4_SALES_ORGTYPE .
  types:
   TT_ZCDS_TP4_SALES_ORGTYPE type standard table of TS_ZCDS_TP4_SALES_ORGTYPE .
  types:
    begin of TS_ZCDS_TP4_SKUTYPE.
      include type ZCDS_TP4_SKU.
  types:
    end of TS_ZCDS_TP4_SKUTYPE .
  types:
   TT_ZCDS_TP4_SKUTYPE type standard table of TS_ZCDS_TP4_SKUTYPE .
  types:
    begin of TS_ZCDS_TP4_SPENDTYPE.
      include type ZCDS_TP4_SPEND.
  types:
    end of TS_ZCDS_TP4_SPENDTYPE .
  types:
   TT_ZCDS_TP4_SPENDTYPE type standard table of TS_ZCDS_TP4_SPENDTYPE .
  types:
    begin of TS_ZCDS_TP4_STATUSTYPE.
      include type ZCDS_TP4_STATUS.
  types:
    end of TS_ZCDS_TP4_STATUSTYPE .
  types:
   TT_ZCDS_TP4_STATUSTYPE type standard table of TS_ZCDS_TP4_STATUSTYPE .
  types:
    begin of TS_ZCDS_TP4_SUBBRANDTYPE.
      include type ZCDS_TP4_SUBBRAND.
  types:
    end of TS_ZCDS_TP4_SUBBRANDTYPE .
  types:
   TT_ZCDS_TP4_SUBBRANDTYPE type standard table of TS_ZCDS_TP4_SUBBRANDTYPE .
  types:
    begin of TS_ZCDS_TP4_TACTICSTYPE.
      include type ZCDS_TP4_TACTICS.
  types:
    end of TS_ZCDS_TP4_TACTICSTYPE .
  types:
   TT_ZCDS_TP4_TACTICSTYPE type standard table of TS_ZCDS_TP4_TACTICSTYPE .

  constants GC_I_COMPANYCODESTDVHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_CompanyCodeStdVHType' ##NO_TEXT.
  constants GC_I_CUSTOMER_VHTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_Customer_VHType' ##NO_TEXT.
  constants GC_I_SALESORGANIZATIONTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'I_SalesOrganizationType' ##NO_TEXT.
  constants GC_ZCDS_TP4_BRANDTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_BRANDType' ##NO_TEXT.
  constants GC_ZCDS_TP4_CURRTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_CURRType' ##NO_TEXT.
  constants GC_ZCDS_TP4_DISTRIBUTION_CHANN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_DISTRIBUTION_CHANNELType' ##NO_TEXT.
  constants GC_ZCDS_TP4_FUNDS_PLANTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_FUNDS_PLANType' ##NO_TEXT.
  constants GC_ZCDS_TP4_OBJECTIVETYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_OBJECTIVEType' ##NO_TEXT.
  constants GC_ZCDS_TP4_PROMOPLANTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_PromoPlanType' ##NO_TEXT.
  constants GC_ZCDS_TP4_PROMOPNLTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_PROMOPNLType' ##NO_TEXT.
  constants GC_ZCDS_TP4_PROMOROITYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_PROMOROIType' ##NO_TEXT.
  constants GC_ZCDS_TP4_SALES_AREATYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_SALES_AREAType' ##NO_TEXT.
  constants GC_ZCDS_TP4_SALES_ORGTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_SALES_ORGType' ##NO_TEXT.
  constants GC_ZCDS_TP4_SKUTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_SKUType' ##NO_TEXT.
  constants GC_ZCDS_TP4_SPENDTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_SPENDType' ##NO_TEXT.
  constants GC_ZCDS_TP4_STATUSTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_STATUSType' ##NO_TEXT.
  constants GC_ZCDS_TP4_SUBBRANDTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_SUBBRANDType' ##NO_TEXT.
  constants GC_ZCDS_TP4_TACTICSTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZCDS_TP4_TACTICSType' ##NO_TEXT.

  methods DEFINE
    redefinition .
  methods GET_LAST_MODIFIED
    redefinition .
protected section.
private section.

  methods DEFINE_RDS_4
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods GET_LAST_MODIFIED_RDS_4
    returning
      value(RV_LAST_MODIFIED_RDS) type TIMESTAMP .
ENDCLASS.



CLASS ZOCL_TP4_PROMO_PLAN_MPC IMPLEMENTATION.


  method DEFINE.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*

model->set_schema_namespace( 'ZSRV_TP4_PROMO_PLAN' ).

define_rds_4( ).
get_last_modified_rds_4( ).
  endmethod.


  method DEFINE_RDS_4.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*
*   This code is generated for Reference Data Source
*   4
*&---------------------------------------------------------------------*
    TRY.
        if_sadl_gw_model_exposure_data~get_model_exposure( )->expose( model )->expose_vocabulary( vocab_anno_model ).
      CATCH cx_sadl_exposure_error INTO DATA(lx_sadl_exposure_error).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_med_exception
          EXPORTING
            previous = lx_sadl_exposure_error.
    ENDTRY.
  endmethod.


  method GET_LAST_MODIFIED.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


  CONSTANTS: lc_gen_date_time TYPE timestamp VALUE '20260312190617'.                  "#EC NOTEXT
 DATA: lv_rds_last_modified TYPE timestamp .
  rv_last_modified = super->get_last_modified( ).
  IF rv_last_modified LT lc_gen_date_time.
    rv_last_modified = lc_gen_date_time.
  ENDIF.
 lv_rds_last_modified =  GET_LAST_MODIFIED_RDS_4( ).
 IF rv_last_modified LT lv_rds_last_modified.
 rv_last_modified  = lv_rds_last_modified .
 ENDIF .
  endmethod.


  method GET_LAST_MODIFIED_RDS_4.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*
*   This code is generated for Reference Data Source
*   4
*&---------------------------------------------------------------------*
*    @@TYPE_SWITCH:
    CONSTANTS: co_gen_date_time TYPE timestamp VALUE '20260312190618'.
    TRY.
        rv_last_modified_rds = CAST cl_sadl_gw_model_exposure( if_sadl_gw_model_exposure_data~get_model_exposure( ) )->get_last_modified( ).
      CATCH cx_root ##CATCH_ALL.
        rv_last_modified_rds = co_gen_date_time.
    ENDTRY.
    IF rv_last_modified_rds < co_gen_date_time.
      rv_last_modified_rds = co_gen_date_time.
    ENDIF.
  endmethod.


  method IF_SADL_GW_MODEL_EXPOSURE_DATA~GET_MODEL_EXPOSURE.
    CONSTANTS: co_gen_timestamp TYPE timestamp VALUE '20260312190618'.
    DATA(lv_sadl_xml) =
               |<?xml version="1.0" encoding="utf-16"?>|  &
               |<sadl:definition xmlns:sadl="http://sap.com/sap.nw.f.sadl" syntaxVersion="" >|  &
               | <sadl:dataSource type="CDS" name="I_COMPANYCODESTDVH" binding="I_COMPANYCODESTDVH" />|  &
               | <sadl:dataSource type="CDS" name="I_CUSTOMER_VH" binding="I_CUSTOMER_VH" />|  &
               | <sadl:dataSource type="CDS" name="I_SALESORGANIZATION" binding="I_SALESORGANIZATION" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_BRAND" binding="ZCDS_TP4_BRAND" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_CURR" binding="ZCDS_TP4_CURR" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_DISTRIBUTION_CHANNEL" binding="ZCDS_TP4_DISTRIBUTION_CHANNEL" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_FUNDS_PLAN" binding="ZCDS_TP4_FUNDS_PLAN" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_OBJECTIVE" binding="ZCDS_TP4_OBJECTIVE" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_PROMOPLAN" binding="ZCDS_TP4_PROMOPLAN" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_PROMOPNL" binding="ZCDS_TP4_PROMOPNL" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_PROMOROI" binding="ZCDS_TP4_PROMOROI" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_SALES_AREA" binding="ZCDS_TP4_SALES_AREA" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_SALES_ORG" binding="ZCDS_TP4_SALES_ORG" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_SKU" binding="ZCDS_TP4_SKU" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_SPEND" binding="ZCDS_TP4_SPEND" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_STATUS" binding="ZCDS_TP4_STATUS" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_SUBBRAND" binding="ZCDS_TP4_SUBBRAND" />|  &
               | <sadl:dataSource type="CDS" name="ZCDS_TP4_TACTICS" binding="ZCDS_TP4_TACTICS" />|  &
               |<sadl:resultSet>|  &
               |<sadl:structure name="I_CompanyCodeStdVH" dataSource="I_COMPANYCODESTDVH" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="I_Customer_VH" dataSource="I_CUSTOMER_VH" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="I_SalesOrganization" dataSource="I_SALESORGANIZATION" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_BRAND" dataSource="ZCDS_TP4_BRAND" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_CURR" dataSource="ZCDS_TP4_CURR" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_DISTRIBUTION_CHANNEL" dataSource="ZCDS_TP4_DISTRIBUTION_CHANNEL" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_FUNDS_PLAN" dataSource="ZCDS_TP4_FUNDS_PLAN" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_OBJECTIVE" dataSource="ZCDS_TP4_OBJECTIVE" maxEditMode="RO" exposure="TRUE" >| .
      lv_sadl_xml = |{ lv_sadl_xml }| &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_PromoPlan" dataSource="ZCDS_TP4_PROMOPLAN" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_PROMOPNL" dataSource="ZCDS_TP4_PROMOPNL" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_PROMOROI" dataSource="ZCDS_TP4_PROMOROI" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_SALES_AREA" dataSource="ZCDS_TP4_SALES_AREA" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_SALES_ORG" dataSource="ZCDS_TP4_SALES_ORG" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_SKU" dataSource="ZCDS_TP4_SKU" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_SPEND" dataSource="ZCDS_TP4_SPEND" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_STATUS" dataSource="ZCDS_TP4_STATUS" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_SUBBRAND" dataSource="ZCDS_TP4_SUBBRAND" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZCDS_TP4_TACTICS" dataSource="ZCDS_TP4_TACTICS" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |</sadl:resultSet>|  &
               |</sadl:definition>| .

   ro_model_exposure = cl_sadl_gw_model_exposure=>get_exposure_xml( iv_uuid      = CONV #( 'ZPRTP4_PROMO_PLAN' )
                                                                    iv_timestamp = co_gen_timestamp
                                                                    iv_sadl_xml  = lv_sadl_xml ).
  endmethod.
ENDCLASS.