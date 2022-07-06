from fastapi import status, APIRouter, HTTPException, Depends

from ..db import db
from .. import schemas

router = APIRouter()


@router.get('/delivery-list', status_code=status.HTTP_200_OK)
async def get_delivery(lng: float = 28.66468, lat: float = 50.26009):

    sql_q = """SELECT cp_GetNearestOrders($1, $2)"""

    res = await db.fetch(sql_q, lng, lat)

    if not res:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return res[0]


@router.get('/directions', status_code=status.HTTP_200_OK)
async def get_delivery(origin: str = '28.66468,50.26009', destination: str = '30.11233,49.79832'):

    try:
        lng1, lat1 = [float(x.strip()) for x in origin.split(',')]
        lng2, lat2 = [float(x.strip()) for x in destination.split(',')]
    except:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY)

    sql_q = """SELECT cp_FromAtoB($1, $2, $3, $4)"""
    res = await db.fetch(sql_q, lng1, lat1, lng2, lat2)

    if not res:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return res[0]


@router.post('/tcp-route', status_code=status.HTTP_200_OK)
async def get_delivery(q: schemas.RouteQuery):

    sql_q = """SELECT gihcp_TCProute($1, $2, $3, $4)"""

    res = await db.fetch(sql_q, q.longitude, q.latitude, q.storage_ids, q.order_ids)

    if not res:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return res[0]
