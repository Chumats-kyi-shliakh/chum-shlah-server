from fastapi import HTTPException, status
from config import settings

import asyncpg
import json
import asyncio


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

    async def fetch(self, sql, *args) -> list or None:
        conn = await self.pool.acquire()

        try:
            res = await conn.fetch(sql, *args)
            if res:
                res = [dict(el) for el in res]
                return res

      
        except Exception as error:
            print(error)

            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)
        finally:
            await self.pool.release(conn)


if __name__ == '__main__':

    async def main():
        db = AsyncDB(dsn='')
        await db.get_pool()

        res = await db.fetch("""SELECT usename FROM pg_catalog.pg_user""")
        print(res)

    asyncio.get_event_loop().run_until_complete(main())
