# AWS Lambda PHP Layers

The Lambda layer and Docker image for PHP-FPM work with [AWS Lambda Web Adapter](https://github.com/awslabs/aws-lambda-web-adapter).

## Usage

AWS Lambda PHP Layers work with Lambda functions packaged as both docker images and Zip packages.

### Docker image

```dockerfile
FROM public.ecr.aws/awsguru/php:82.2023.3.11.1 AS builder
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

COPY app /var/task/app
WORKDIR /var/task/app

RUN composer install --prefer-dist --optimize-autoloader --no-dev --no-interaction

FROM public.ecr.aws/awsguru/php:82.2023.3.11.1
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.7.0 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=builder /var/task /var/task

```

### Lambda Layer

We add PHP layer to the function and configure wrapper script.

1. attach PHP layer to your function. This layer containers PHP binary and a wrapper script.
    1. x86_64: `arn:aws:lambda:${AWS::Region}:753240598075:layer:Php82FpmNginxX86:13`
    2. arm64: `arn:aws:lambda:${AWS::Region}:753240598075:layer:Php82FpmNginxArm:13`

## Pre-requisites

The following tools should be installed and configured.

* [AWS CLI](https://aws.amazon.com/cli/)
* [SAM CLI](https://github.com/awslabs/aws-sam-cli)
* [Docker](https://www.docker.com/products/docker-desktop)

## Versions

### Supported Docker Images

| Custom Runtime | Version | Latest Version                         |
|----------------|---------|-----------------------------------------------|
| Nginx          | 1.23    | public.ecr.aws/awsguru/nginx:1.23.2023.3.13.1 |
| PHP            | 8.2     | public.ecr.aws/awsguru/php:82.2023.3.13.1     |
| PHP            | 8.1     | public.ecr.aws/awsguru/php:81.2023.3.13.1     |
| PHP            | 8.0     | public.ecr.aws/awsguru/php:80.2023.3.13.1     |
| PHP            | 7.4     | public.ecr.aws/awsguru/php:74.2023.3.13.1     |

### Supported Zip Layers

| Custom Runtime | Version | Arch   | Latest Version                                                 |
|----------------|---------|--------|----------------------------------------------------------------------|
| Nginx          | 1.23    | x86_64 | arn:aws:lambda:${AWS::Region}:753240598075:layer:Nginx123X86:13      |
| Nginx          | 1.23    | arm64  | arn:aws:lambda:${AWS::Region}:753240598075:layer:Nginx123Arm:13      |
| PHP            | 8.2     | x86_64 | arn:aws:lambda:${AWS::Region}:753240598075:layer:Php82FpmNginxX86:13 |
| PHP            | 8.2     | arm64  | arn:aws:lambda:${AWS::Region}:753240598075:layer:Php82FpmNginxArm:13 |
| PHP            | 8.1     | x86_64 | arn:aws:lambda:${AWS::Region}:753240598075:layer:Php81FpmNginxX86:13 |
| PHP            | 8.1     | arm64  | arn:aws:lambda:${AWS::Region}:753240598075:layer:Php81FpmNginxArm:13 |
| PHP            | 8.0     | x86_64 | arn:aws:lambda:${AWS::Region}:753240598075:layer:Php80FpmNginxX86:13 |
| PHP            | 8.0     | arm64  | arn:aws:lambda:${AWS::Region}:753240598075:layer:Php80FpmNginxArm:13 |
| PHP            | 7.4     | x86_64 | arn:aws:lambda:${AWS::Region}:753240598075:layer:Php74FpmNginxX86:13 |
| PHP            | 7.4     | arm64  | arn:aws:lambda:${AWS::Region}:753240598075:layer:Php74FpmNginxArm:13 |

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This project is licensed under the Apache-2.0 License.
