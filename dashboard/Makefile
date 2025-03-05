# pip install grpcio grpcio-tools
# pip install psycopg2-binary 
all: protoc
run:
	python3 ./app.py

protoc:
	python3 -m grpc_tools.protoc -I ../qshare/proto --python_out=. --grpc_python_out=. qobjs.proto
	python3 -m grpc_tools.protoc -I ../qshare/proto --python_out=. --grpc_python_out=. na.proto
