build:
	docker build -t jmcarbo/swarmdind .
run:
	docker stack deploy -c docker-compose.yml swarmdind
stop:
	docker stack rm swarmdind
