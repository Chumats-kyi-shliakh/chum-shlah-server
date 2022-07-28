from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routers import router
from .db import db


ORIGINS = [
    '*'
    # "http://devmaps.xyz",
    # "https://devmaps.xyz",
    # "http://localhost",
    # "http://localhost:8080",
]

app = FastAPI()


@app.on_event("startup")
async def startup_event():
    await db.get_pool()


@app.on_event("shutdown")
async def shutdown_event():
    await db.close_pool()

app.add_middleware(
    CORSMiddleware,
    allow_origins=ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router.router, prefix="/router")
