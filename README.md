# 🐳 SMTP Server Docker Image

This is a simple SMTP Relay server based on [postfix](https://www.postfix.org/).

You can run a local smtp server which are pointed to the real private email provider.

_Tested on Gmail and Yahoo._

> **INPORTANT: SMTP server doesn't have any authentication layer. Please do not put it into the public network.**

## Usage

### Option 1: Use configuration file
1. Create a configuration file: ```cp env.example .env```
2. Update values in the ```.env``` file
3. Run docker image: ```docker run -d -it --rm -p 25:25 --env-file .env --name smtpserver rev9en/smtpserver```

### Option 2: use a system environemnt variables, without a configuration file:
```bash
docker run -d -it --rm -p 25:25 \
    -e SMTP_SERVER=<your real stmp server> \
    -e SMTP_PORT=<real smtp port, ex: 465> \
    -e SMTP_USERNAME=john.k.smith@example.com \
    -e SMTP_PASSWORD=SecretPassword \
    --name smtpserver rev9en/smtpserver
```

After that a regular smtp server will be available on localhost port 25.


## Test

1. Start ```rev9en/smtpserver``` docker image (see: [usage section](#usage))
2. Run test script to send a test email via SMTP server on localhost port 25: ```python send-test-email.py <sender-email@sample.com>```

## Build locally

```bash
make build
```

## Links

* [Docker image source code](https://github.com/revgen/docker/docker-smtpserver)
* [Docker hub page](https://hub.docker.com/r/rev9en/smtpserver)
* [Docker alpine official page](https://hub.docker.com/_/alpine)
* [Postfix Documentation](https://www.postfix.org/documentation.html)
* [How to configure gmail server as a relayhost in Postfix?](https://access.redhat.com/solutions/3201002)
* [Postfix relay through Yahoo!](https://www.webcodegeeks.com/web-servers/postfix-relay-through-yahoo-ssl/)
