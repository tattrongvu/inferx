all: ctl dash spdk runmodel

ctl:	
	cargo +stable build --bin ixctl
	sudo cp -f ixctl_logging_config.yaml /opt/inferx/config/
	sudo cp -f target/debug/ixctl /opt/inferx/bin/

dash:
	mkdir -p ./target/dashboard
	-rm ./target/dashboard/* -rf
	cp ./dashboard/* ./target/dashboard -rL
	cp ./deployment/dashboard.Dockerfile ./target/dashboard/Dockerfile
	-sudo docker image rm inferx/inferx_dashboard:v0.1.0
	sudo docker build -t inferx/inferx_dashboard:v0.1.0 ./target/dashboard
	# sudo docker push inferx/inferx_dashboard:v0.1.0

pushdash:
	# sudo docker login -u inferx
	sudo docker tag inferx/inferx_dashboard:v0.1.0 inferx/inferx_dashboard:v0.1.0
	sudo docker push inferx/inferx_dashboard:v0.1.0

runmodel:
	mkdir -p ./target/runmodel
	cp ./script/run_model.py ./target/runmodel
	cp ./script/run_llava.py ./target/runmodel
	cp ./script/run_stablediffusion.py ./target/runmodel
	cp ./deployment/vllm-opai.Dockerfile ./target/runmodel/Dockerfile
	-sudo docker image rm vllm-openai-upgraded:v0.1.0
	sudo docker build -t vllm-openai-upgraded:v0.1.0 ./target/runmodel

spdk:
	mkdir -p ./target/spdk
	-rm ./target/spdk/* -rf
	cp ./deployment/spdk.Dockerfile ./target/spdk/Dockerfile
	-sudo docker image rm inferx/spdk-container:v0.1.0
	sudo docker build -t inferx/spdk-container:v0.1.0 ./target/spdk

sql:
	cp ./dashboard/sql/create_table.sql /opt/inferx/config/

compose_blob: 
	sudo docker compose -f docker-compose_blob.yml  build

compose: 
	sudo docker compose -f docker-compose.yml  build

run:
	- sudo rm -f /opt/inferx/log/inferx.log
	- sudo rm -f /opt/inferx/log/onenode.log
	sudo docker compose -f docker-compose.yml up -d

runblob:
	- sudo rm -f /opt/inferx/log/inferx.log
	- sudo rm -f /opt/inferx/log/onenode.log
	sudo docker compose -f docker-compose_blob.yml up -d

stop:
	sudo docker compose -f docker-compose.yml down
	
stopblob:
	sudo docker compose -f docker-compose_blob.yml down