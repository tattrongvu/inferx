
import os
import sys
import time

from typing import Any, Optional

import uvicorn
from fastapi import Body, FastAPI, Request
from fastapi.responses import JSONResponse, Response, StreamingResponse
from pydantic import BaseModel, Field
import asyncio

from diffusers import DiffusionPipeline
import torch
import io

pipe = DiffusionPipeline.from_pretrained("stabilityai/stable-diffusion-xl-base-1.0", torch_dtype=torch.float16, use_safetensors=True, variant="fp16")
pipe.to("cuda")

try:
    max_height = int(os.environ.get('height', 600))
except ValueError:
    max_height = 600

try:
    max_width = int(os.environ.get('width', 800))
except ValueError:
    max_width = 800

# if using torch < 2.0
# pipe.enable_xformers_memory_efficient_attention()

class PromptReq(BaseModel):
    prompt: str | None = "An astronaut riding a green horse"

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/liveness")
async def liveness() -> Response:
    return Response("liveness", status_code=200)


@app.get("/health")
async def readiness() -> Response:
    return Response("readiness", status_code=200)


@app.post("/funccall")
async def post_func_call(req: PromptReq):
    print("req: ", req)
    prompt = req.prompt

    print("max_height: ", max_height)
    print("max_width: ", max_width)
    # prompt = "An astronaut riding a green horse"

    images = pipe(prompt=prompt, height=max_height, width=max_width).images[0]
    # images.save("/Quark/test/a.png")

    print("req: 2 ", req.prompt)
    imgio = io.BytesIO()
    images.save(imgio, 'PNG')
    imgio.seek(0)
    print("req: done size ", len(imgio.getvalue()))
    return StreamingResponse(content=imgio, media_type="image/png")

async def main():
    config = uvicorn.Config(
        "__main__:app", port=8000, reload=True, log_level="debug", host="0.0.0.0"
    )
    server = uvicorn.Server(config)
    await server.serve()


if __name__ == "__main__":
    asyncio.run(main())
