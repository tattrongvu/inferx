import asyncio
import os
import sys
import time
from threading import Thread

import uvicorn

import requests
from fastapi import FastAPI
from fastapi.responses import JSONResponse, Response, StreamingResponse
from pydantic import BaseModel, Field
from transformers import AutoProcessor, LlavaForConditionalGeneration
from PIL import Image

import faulthandler
faulthandler.enable()

os.environ["CURL_CA_BUNDLE"] = ""

import torch

torch.manual_seed(0)

from transformers import AutoModelForCausalLM, AutoTokenizer

model_id = "llava-hf/llava-1.5-7b-hf"
model = LlavaForConditionalGeneration.from_pretrained(
    model_id, 
    torch_dtype=torch.float16, 
    low_cpu_mem_usage=True, 
).to("cuda:0")

print(model)
processor = AutoProcessor.from_pretrained(model_id)

app = FastAPI()

class PromptReq(BaseModel):
    prompt: str
    image: str
    

@app.get("/health")
async def liveness() -> Response:
    return Response("health", status_code=200)

@app.post("/v1/completions")
async def post_func_call(req: PromptReq):
    prompt = req.prompt
    image_file = req.image
    conversation = [
        {
            "role": "user",
            "content": [
                {"type": "text", "text": prompt},
                {"type": "image"},
                ],
        },
    ]
    prompt = processor.apply_chat_template(conversation, add_generation_prompt=True)
    raw_image = Image.open(requests.get(image_file, stream=True).raw)
    inputs = processor(images=raw_image, text=prompt, return_tensors='pt').to(0, torch.float16)

    output = model.generate(**inputs, max_new_tokens=200, do_sample=False)
    result = processor.decode(output[0][2:], skip_special_tokens=True)
    resp = {"result": result}
    return JSONResponse(content=resp, status_code=200)  


async def main():
    config = uvicorn.Config(
        "__main__:app", port=8000, reload=True, log_level="debug", host="0.0.0.0"
    )
    server = uvicorn.Server(config)
    await server.serve()


if __name__ == "__main__":
    asyncio.run(main())
