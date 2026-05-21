-- Teams Notification Setup
-- ========================
-- 1. Create an Incoming Webhook in your Teams channel:
--    Teams > Channel > Connectors > Incoming Webhook > Create
--    Copy the webhook URL
--
-- 2. Replace <YOUR_TEAMS_WEBHOOK_URL> below and run:

CREATE NOTIFICATION INTEGRATION IF NOT EXISTS MUSEUM_TEAMS_ALERTS
  TYPE = WEBHOOK
  ENABLED = TRUE
  WEBHOOK_URL = '<YOUR_TEAMS_WEBHOOK_URL>'
  WEBHOOK_BODY_TEMPLATE = '{"@type":"MessageCard","@context":"http://schema.org/extensions","themeColor":"0076D7","summary":"SNOWFLAKE_WEBHOOK_MESSAGE","sections":[{"activityTitle":"Museum DW Alert","facts":[{"name":"Alert","value":"SNOWFLAKE_WEBHOOK_MESSAGE"}],"markdown":true}]}'
  WEBHOOK_HEADERS = ('Content-Type'='application/json');

-- 3. Update the agent pattern analysis proc to also send to Teams:
-- ALTER PROCEDURE MUSEUM_DW_PROD.MONITORING.ANALYZE_AGENT_QUESTION_GAPS()
-- Add: CALL SYSTEM$SEND_NOTIFICATION('MUSEUM_TEAMS_ALERTS', :alert_msg);

-- 4. Update DAG_FINALIZER to send failure alerts to Teams:
-- Add SYSTEM$SEND_NOTIFICATION call on pipeline failure
