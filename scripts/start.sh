#! /bin/bash
set -e
set -x

function start_frontend() {
        if [ $(id -u) -eq 0 ]; then
                su -s /bin/bash www-data -c "
                /opt/lf/moonbridge/moonbridge \
                /opt/lf/webmcp/bin/mcp.lua \
                /opt/lf/webmcp/ \
                /opt/lf/frontend/ \
                main lfconfig
                "
        else
                /opt/lf/moonbridge/moonbridge \
                /opt/lf/webmcp/bin/mcp.lua \
                /opt/lf/webmcp/ \
                /opt/lf/frontend/ \
                main lfconfig
        fi
}

if [ x$1 == "xstart_frontend" ]; then
        start_frontend
elif [ x$1 == "xstart_update" ]; then
        # start database update
        echo "wait for database"
        export PGPASSWORD=$DBPASS;
        while ! timeout 5 psql -h $DBHOST -U $DBUSER  $DBNAME -c "SELECT count(*) FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';"; do
          echo -n ".";
          sleep 1;
        done
        echo "### start database update ###"
        env LF_UPDATES=/opt/lf/core python3 /opt/lf/core/update-core.py
        # start update daemon
        echo "### start update daemon ###"
        /opt/lf/bin/lf_updated
elif [ -z $1 ] ; then
        #service exim4 startlf-liquid-feedback-update-5744dddd75-kqnsv
        service postgresql start

        /opt/lf/bin/lf_updated &

        start_frontend

else
        exec "$@"
fi

