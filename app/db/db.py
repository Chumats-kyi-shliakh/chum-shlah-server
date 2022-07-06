from fastapi import HTTPException, status

import asyncpg
import json


class AsyncDB():
    def __init__(self, dsn, codec='jsonb', min_size=1, max_size=10) -> None:
        self.pool = None
        self.dsn = dsn
        self.codec = codec
        self.min_size = min_size
        self.max_size = max_size

    async def jsonb_codec(self, conn):
        await conn.set_type_codec(
            'jsonb',
            encoder=json.dumps,
            decoder=json.loads,
            schema='pg_catalog'
        )

    async def get_pool(self):
        if self.codec == 'jsonb':
            codec = self.jsonb_codec

        if not self.pool:
            self.pool = await asyncpg.create_pool(
                dsn=self.dsn,
                command_timeout=60,
                min_size=self.min_size,
                max_size=self.max_size,
                init=codec)
        return self.pool

    async def close_pool(self):
        await self.pool.close()

    async def fetch(self, sql, *args) -> list or None:
        pool = await self.get_pool()
        conn = await pool.acquire()
        try:
            res = await conn.fetch(sql, *args)
            if res:
                res = [dict(el) for el in res]
                return res

        except Exception as error:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error)
        finally:
            await self.pool.release(conn)
