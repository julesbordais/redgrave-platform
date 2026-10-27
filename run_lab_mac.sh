#!/usr/bin/env bash
# RED-201 dbt lab - macOS. Run from inside redgrave_dbt:  bash run_lab_mac.sh
# Edit the 3 lines below first.
export SNOWFLAKE_ACCOUNT="ORGNAME-ACCOUNTNAME"
export SNOWFLAKE_USER="YOUR_USER"
export SNOWFLAKE_PRIVATE_KEY_FILE="/full/path/to/rsa_key.p8"
export DBT_PROFILES_DIR=.
set -e
[ -d .venv ] || python3 -m venv .venv
source .venv/bin/activate
pip install -q dbt-core==1.11.16 dbt-snowflake==1.11.6
dbt --version
dbt debug                     # step 2  -> All checks passed!
dbt run --select silver_products silver_orders silver_order_lines   # step 3-4
dbt run                       # step 5  -> PASS=6
dbt test                      # step 6  -> PASS=18
dbt build                     # step 6  -> PASS=24
dbt source freshness || true  # step 7  -> WARN if bronze loaded >24h ago (expected)
echo ""
echo ">>> Step 8: run step8_break.sql INSERT in Snowsight, then:  dbt build   (expect 1 FAIL + SKIPs)"
echo ">>> Then run the DELETE in step8_break.sql and:            dbt build   (back to PASS=24)"
echo ">>> Step 9: dbt docs generate && dbt docs serve   (Ctrl+C to stop)"
