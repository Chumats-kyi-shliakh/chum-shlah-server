"""
Init base
"""

from yoyo import step
import os

__depends__ = {}


def apply_step(conn):
    cursor = conn.cursor()
    with open(f'{os.getcwd()}/db/table-managment/create-tables.sql') as f:
        cursor.execute(f.read())


steps = [step(apply_step)]
