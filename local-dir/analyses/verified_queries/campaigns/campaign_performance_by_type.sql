SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS avg_open_rate, avg_click_to_open_rate, total_emails_sent
  DIMENSIONS dim_campaign.campaign_type)
