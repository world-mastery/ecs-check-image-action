FROM alpine:3.10

LABEL com.github.actions.name="ECS check image action"
LABEL com.github.actions.description="Checks a given image name agains a deployed service in ECS"

ENV GITHUB_WORKSPACE=/github/workspace
RUN ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime
RUN apk add --no-cache python py-pip jq

RUN pip install awscli

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR ${GITHUB_WORKSPACE}