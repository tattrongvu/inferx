import asyncio
import os
import sys
import time
from threading import Thread

import uvicorn

from fastapi import FastAPI
from fastapi.responses import JSONResponse, Response, StreamingResponse
from pydantic import BaseModel, Field
from transformers import AutoModelForCausalLM, AutoTokenizer, TextIteratorStreamer

os.environ["CURL_CA_BUNDLE"] = ""

import torch

torch.manual_seed(0)

from transformers import AutoModelForCausalLM, AutoTokenizer

modelname = sys.argv[1]
max_tokens = int(sys.argv[2])

model = AutoModelForCausalLM.from_pretrained(
    modelname, torch_dtype=torch.float16
).to("cuda:0")

print(model)
tokenizer = AutoTokenizer.from_pretrained(modelname)

app = FastAPI()

class PromptReq(BaseModel):
    model: str | None = None
    prompt: str
    max_tokens: int
    temperature: int | None = 0
    stream: bool | None = True
    

async def generate(prompt, max_tokens):
    inputs = tokenizer([prompt], return_tensors="pt").to("cuda:0")
    streamer = TextIteratorStreamer(tokenizer)
    generation_kwargs = dict(inputs, streamer=streamer, max_new_tokens=max_tokens)
    thread = Thread(target=model.generate, kwargs=generation_kwargs)
    thread.start()
    for new_text in streamer:
        yield new_text


@app.get("/health")
async def liveness() -> Response:
    return Response("health", status_code=200)

@app.post("/v1/completions")
async def post_func_call(req: PromptReq):
    print("req:", req.prompt)
    print("max_tokens:", req.max_tokens)
    if req.max_tokens > max_tokens:
        req.max_tokens = max_tokens
    prompt = req.prompt

    if req.stream :
        return StreamingResponse(generate(prompt, req.max_tokens))
    else:
        inputs = tokenizer(prompt, return_tensors="pt").to("cuda:0")
        generate_ids = model.generate(
            inputs.input_ids, max_length=req.max_tokens, pad_token_id=tokenizer.eos_token_id
        )
        output = tokenizer.batch_decode(
            generate_ids, skip_special_tokens=True, clean_up_tokenization_spaces=False
        )[0]
        resp = {"result": output}
    return JSONResponse(content=resp, status_code=200)       

async def main():
    config = uvicorn.Config(
        "__main__:app", port=8000, reload=True, log_level="debug", host="0.0.0.0"
    )
    server = uvicorn.Server(config)
    await server.serve()


if __name__ == "__main__":
    asyncio.run(main())
