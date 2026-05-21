import snowflake.connector
import os

conn = snowflake.connector.connect(
    account='om01578.east-us.azure',
    user='JMYERS',
    password='TempSnowSQL2026!',
    warehouse='COMPUTE_WH',
    database='MUSEUM_DW_PROD',
    schema='INTEGRATIONS'
)

cur = conn.cursor()
cur.execute("LIST @WORKSPACE_EXPORT")
files = [row[0].replace('workspace_export/', '') for row in cur]

for f in files:
    if f.startswith('target/') or f.startswith('logs/'):
        continue
    dir_path = os.path.dirname(f)
    if dir_path:
        os.makedirs(dir_path, exist_ok=True)
    try:
        cur.execute(f"GET @WORKSPACE_EXPORT/{f} file://{dir_path or '.'}")
        downloaded = f"{dir_path or '.'}/{os.path.basename(f)}.gz"
        if os.path.exists(downloaded):
            import gzip, shutil
            with gzip.open(downloaded, 'rb') as gz:
                with open(f, 'wb') as out:
                    shutil.copyfileobj(gz, out)
            os.remove(downloaded)
        print(f"  ✓ {f}")
    except Exception as e:
        print(f"  ✗ {f}: {e}")

conn.close()
print("Done!")