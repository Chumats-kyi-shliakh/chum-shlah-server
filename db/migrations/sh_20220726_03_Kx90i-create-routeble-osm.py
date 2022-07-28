"""
Create routeble OSM
"""

from yoyo import step
import os

__depends__ = {'sh_20220726_02_gkv6o-upload-osm-data'}


def apply_step(conn):
    cursor = conn.cursor()
    print('Loading...')
    with open(f'{os.getcwd()}/db/data-processing/highway2ways.sql') as f:
        cursor.execute(f.read())


steps = [step(apply_step)]
