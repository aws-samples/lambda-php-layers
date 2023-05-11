# Load .env file if it exists
-include .env
export # export all variables defined in .env

env-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

upload_layer: batch1 batch2 batch3 batch4 batch5 batch6 batch7 batch8

batch1:
	REGION=us-east-1 ./artisan upload_layer #US East (Ohio)
	REGION=us-east-2 ./artisan upload_layer #US East (Ohio)
	REGION=us-west-1 ./artisan upload_layer #US West (N. California)
	REGION=us-west-2 ./artisan upload_layer #US West (Oregon)

batch2:
	REGION=eu-west-1 ./artisan upload_layer #Europe (Ireland)
	REGION=eu-west-2 ./artisan upload_layer #Europe (London)
	REGION=eu-west-3 ./artisan upload_layer #Europe (Paris)
	REGION=eu-north-1 ./artisan upload_layer #Europe (Stockholm)

batch3:
	REGION=eu-south-1 ./artisan upload_layer #Europe (Milan)
	REGION=eu-south-2 ./artisan upload_layer #Europe (Spain)
	REGION=eu-central-1 ./artisan upload_layer #Europe (Frankfurt)
	REGION=eu-central-2 ./artisan upload_layer #Europe (Zurich)

batch4:
	REGION=ap-east-1 ./artisan upload_layer #Asia Pacific (Hong Kong)
	REGION=ap-south-1 ./artisan upload_layer #Asia Pacific (Mumbai)
	REGION=ap-south-2 ./artisan upload_layer #Asia Pacific (Hyderabad)

batch5:
	REGION=ap-northeast-1 ./artisan upload_layer #Asia Pacific (Tokyo)
	REGION=ap-northeast-2 ./artisan upload_layer #Asia Pacific (Seoul)
	REGION=ap-northeast-3 ./artisan upload_layer #Asia Pacific (Osaka)

batch6:
	REGION=ap-southeast-1 ./artisan upload_layer #Asia Pacific (Singapore)
	REGION=ap-southeast-2 ./artisan upload_layer #Asia Pacific (Sydney)
	REGION=ap-southeast-3 ./artisan upload_layer #Asia Pacific (Jakarta)
	REGION=ap-southeast-4 ./artisan upload_layer #Asia Pacific (Melbourne)

batch7:
	REGION=ca-central-1 ./artisan upload_layer #Canada (Central)
	REGION=sa-east-1 ./artisan upload_layer #South America (São Paulo)

batch8:
	REGION=af-south-1 ./artisan upload_layer #Africa (Cape Town)
	REGION=me-south-1 ./artisan upload_layer #Middle East (Bahrain)
	REGION=me-central-1 ./artisan upload_layer #Middle East (UAE)

devel:
	docker-compose up devel-php-74-fpm-nginx \
					  devel-php-80-fpm-nginx \
					  devel-php-81-fpm-nginx \
					  devel-php-82-fpm-nginx \
					  devel-php-82-static-fpm-nginx \
					  devel-nginx
	docker-compose down

prod:
	docker-compose up php-74-fpm-nginx \
					  php-80-fpm-nginx \
					  php-81-fpm-nginx \
					  php-82-fpm-nginx \
					  php-82-static-fpm-nginx \
                      nginx
	docker-compose down

beta:
	docker-compose up php-beta-fpm-nginx
	docker-compose down

clean:
	docker system prune -af
	docker image prune -f
	docker volume prune -f
	docker builder prune -f

php:
	ARCH=x86_64 IMAGE=php-beta TAG=devel.2023.3.13.1 ./artisan tests_run
	#ARCH=x86_64 IMAGE=php-beta TAG=layer.74.2023.3.13.1 ./artisan tests_run

nginx:
	ARCH=x86_64 IMAGE=nginx TAG=devel.1.23.2023.3.13.1 ./artisan tests_run
	ARCH=x86_64 IMAGE=nginx TAG=layer.1.23.2023.3.13.1 ./artisan tests_run

build:
	docker stop beta_local || true && docker rm beta_local || true
	docker rmi --force public.ecr.aws/awsguru/php-beta:local-x86_64
	docker build ./src/php-beta-fpm-nginx \
			     --platform=linux/x86_64 \
			     --build-arg ARCH=x86_64 \
			     --build-arg IMAGE=php-beta \
			     --build-arg TAG=local \
			     --build-arg DEVEL_TAG=devel.2023.3.13.1 \
			     --tag public.ecr.aws/awsguru/php-beta:local-x86_64 \
			     --file ./src/php-beta-fpm-nginx/prod.Dockerfile
	docker run -it --name beta_local -p 127.0.0.1:8001:8080/tcp public.ecr.aws/awsguru/php-beta:local-x86_64 bash
	docker stop beta_local || true && docker rm beta_local || true
	docker rmi --force public.ecr.aws/awsguru/php-beta:local-x86_64

