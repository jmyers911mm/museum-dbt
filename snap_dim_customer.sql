
      begin;
    merge into "MUSEUM_DW_PROD"."SILVER"."SNAP_DIM_CUSTOMER" as DBT_INTERNAL_DEST
    using "MUSEUM_DW_PROD"."SILVER"."SNAP_DIM_CUSTOMER__dbt_tmp" as DBT_INTERNAL_SOURCE
    on DBT_INTERNAL_SOURCE.dbt_scd_id = DBT_INTERNAL_DEST.dbt_scd_id

    when matched
     
       and DBT_INTERNAL_DEST.dbt_valid_to is null
     
     and DBT_INTERNAL_SOURCE.dbt_change_type in ('update', 'delete')
        then update
        set dbt_valid_to = DBT_INTERNAL_SOURCE.dbt_valid_to

    when not matched
     and DBT_INTERNAL_SOURCE.dbt_change_type = 'insert'
        then insert ("CUSTOMER_ID", "CRM_CONTACT_ID", "FULL_NAME", "PRIMARY_EMAIL", "PRIMARY_PHONE", "EMAIL_COUNT", "PHONE_COUNT", "MEMBERSHIP_TYPE", "MEMBERSHIP_STATUS", "CUSTOMER_SEGMENT", "DBT_UPDATED_AT", "DBT_VALID_FROM", "DBT_VALID_TO", "DBT_SCD_ID")
        values ("CUSTOMER_ID", "CRM_CONTACT_ID", "FULL_NAME", "PRIMARY_EMAIL", "PRIMARY_PHONE", "EMAIL_COUNT", "PHONE_COUNT", "MEMBERSHIP_TYPE", "MEMBERSHIP_STATUS", "CUSTOMER_SEGMENT", "DBT_UPDATED_AT", "DBT_VALID_FROM", "DBT_VALID_TO", "DBT_SCD_ID")

;
    commit;
  