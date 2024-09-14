ARG TELEPORT_AGENT_VERSION=16.3.0
ARG CONTROL_CONTAINER_VERSION=0.7.15

FROM public.ecr.aws/gravitational/teleport-distroless:${TELEPORT_AGENT_VERSION} as teleport
FROM public.ecr.aws/bottlerocket/bottlerocket-control:v${CONTROL_CONTAINER_VERSION}

COPY --from=teleport /usr/local/bin/teleport /usr/local/bin/teleport

ENTRYPOINT ["/usr/local/bin/teleport"]
CMD [ "start", "--config", "/.bottlerocket/host-containers/current/user-data" ]

