FROM rplan/vault-template:1.0.0 as vault-template

FROM tutum/curl as download

RUN curl -L -o /jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
  chmod +x /jq

FROM boostport/kubernetes-vault-init

COPY --from=vault-template /vault-template /vault-template
COPY --from=download /jq /jq
COPY ./run.sh /run.sh

ENTRYPOINT ["/run.sh"]
