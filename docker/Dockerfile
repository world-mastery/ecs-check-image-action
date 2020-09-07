FROM ubuntu:20.10

LABEL com.github.actions.name="ECS check image action"
LABEL com.github.actions.description="Checks a given image name agains a deployed service in ECS"

ENV GITHUB_WORKSPACE=/github/workspace
RUN ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime
RUN apt-get update && apt-get install -y jq awscli


ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR ${GITHUB_WORKSPACE}
RUN apt-get clean