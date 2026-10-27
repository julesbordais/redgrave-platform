"""Run SQL on Snowflake with the same key-pair env vars as dbt. Usage: python sf.py "SQL; SQL" """
import os, sys, snowflake.connector
from cryptography.hazmat.primitives import serialization
pw = os.environ.get("SNOWFLAKE_PRIVATE_KEY_PASSPHRASE")
with open(os.environ["SNOWFLAKE_PRIVATE_KEY_FILE"], "rb") as f:
    key = serialization.load_pem_private_key(f.read(), password=pw.encode() if pw else None)
der = key.private_bytes(serialization.Encoding.DER, serialization.PrivateFormat.PKCS8, serialization.NoEncryption())
con = snowflake.connector.connect(account=os.environ["SNOWFLAKE_ACCOUNT"], user=os.environ["SNOWFLAKE_USER"],
    private_key=der, role="SYSADMIN", warehouse="REDGRAVE_WH", database="REDGRAVE")
for cur in con.execute_string(sys.argv[1]):
    if cur.description:
        print(" | ".join(c[0] for c in cur.description))
        for r in cur.fetchall(): print(" | ".join(str(x) for x in r))
con.close()
