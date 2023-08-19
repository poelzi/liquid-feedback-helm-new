import os
import semver
import psycopg2
import re
import crypt
import sys
from psycopg2 import sql
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

UPDATE_RE = re.compile('core-update.v(\d\.\d\.\d[^-]*)-v(\d\.\d\.\d[^\.]*)')

def get_db_version(conn):
    with conn.cursor() as cur:
        try:
            cur.execute("SELECT * FROM liquid_feedback_version")
            version = cur.fetchone()
            if version is None:
                return None
            else:
                return semver.VersionInfo.parse(version[0])
        except psycopg2.errors.UndefinedTable:
            return None

def apply_sql_file(conn, filepath):
    print("Applying SQL file: {}".format(filepath))
    with open(filepath, 'r') as file:
        sql_command = file.read()
    with conn.cursor() as cur:
        cur.execute(sql.SQL(sql_command))
        conn.commit()

def update_schema(conn, updates_folder):
    current_version = get_db_version(conn)
    print("Current schema version: {}".format(current_version))
    all_files = os.listdir(updates_folder)
    sql_files = [f for f in all_files if f.startswith('core-update.v')]
    sql_files.sort()  # ensure files are processed in order
    for sql_file in sql_files:
        print("Updating schema for {}".format(sql_file))
        if sql_file.endswith('.sql'):
            #from_version, to_version = sql_file.replace('.sql', '').split('v')[1:]
            try:
                from_version, to_version = UPDATE_RE.match(sql_file).groups()
            except Exception as e:
                print("problems: {} {}".format(sql_file, e))
                continue
            from_version = semver.VersionInfo.parse(from_version.replace('_', '-'))
            to_version = semver.VersionInfo.parse(to_version.replace('_', '-'))
            if current_version is None or from_version > current_version:
                apply_sql_file(conn, os.path.join(updates_folder, sql_file))
                current_version = to_version

def update_users(conn, users_folder):
    for user in os.listdir(users_folder):
        if user.startswith('.'):
            continue
        with open(os.path.join(users_folder, user), 'r') as f:
            print ("Update admin user: {}".format(user))
            password = f.read()

            crypt_password = crypt.crypt(password, crypt.METHOD_SHA512)

            with conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO "member" (
                            "login",
                            "password",
                            "active",
                            "admin",
                            "name",
                            "activated",
                            "last_activity"
                        ) VALUES (
                            %s,
                            %s,
                            TRUE,
                            TRUE,
                            %s,
                            NOW(),
                            NOW()
                        )
                    ON CONFLICT (login) DO UPDATE
                        SET "password" = %s;
                """,
                (user, crypt_password, user, crypt_password))
                conn.commit()

def install_initial_schema(conn, updates_folder, schema_files):
    for schema_file in schema_files:
        apply_sql_file(conn, os.path.join(updates_folder, schema_file))

def main():
    LFUSER = os.environ.get('LFUSER', 'lf')
    DBHOST = os.environ.get('DBHOST', 'localhost')
    DBNAME = os.environ.get('DBNAME', 'liquid_feedback')
    DBUSER = os.environ.get('DBUSER', 'liquid_feedback')
    DBPASS = os.environ.get('DBPASS', 'liquid')
    updates_folder = os.environ.get('LF_UPDATES', 'updates')
    users_folder = os.environ.get('LF_ADMIN_USERS', '/etc/lf-users')
    print("Start database update on {}".format(DBHOST))
    
    conn = psycopg2.connect(dbname=DBNAME, user=DBUSER, password=DBPASS, host=DBHOST)
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    
    schema_files = [f'core.sql', 'init.sql']
    
    if get_db_version(conn) is None:
        print("Install initial files")
        install_initial_schema(conn, updates_folder, schema_files)
    
    update_schema(conn, updates_folder)

    update_users(conn, users_folder)

    conn.close()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("!!!!!!!!!!!!!!!!!!!!!!!!")
        print("Error running SQL update script, this is fatal and requires manual intervention:")
        print(e)
        print("!!!!!!!!!!!!!!!!!!!!!!!!")
        sys.stdout.flush()
        import time
        while True:
            time.sleep(600)
