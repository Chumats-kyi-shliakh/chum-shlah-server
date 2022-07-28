"""
Upload OSM data
"""
 
from yoyo import step
import subprocess

__depends__ = {'sh_20220726_01_tpUf0-init-base'}
def apply_step(conn):
    try:
        subprocess.run([""" export $(grep -v '^#' .env | xargs) && \
        wget https://download.bbbike.org/osm/bbbike/Kiew/Kiew.osm.pbf && \
        osm2pgsql --slim --drop --output=flex --style=./db//osm2pgsql/routes.lua \
        --database=${DSN} -W Kiew.osm.pbf && \
        osm2pgsql --slim --drop --output=flex --style=./db//osm2pgsql/test-places.lua \
        --database=${DSN} -W Kiew.osm.pbf && \
        """], shell=True)
    finally:
        subprocess.run(["rm Kiew.osm.pbf"], shell=True)


steps = [
    step(apply_step)
]
