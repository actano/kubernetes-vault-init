# kubernetes-vault-init

Enhanced init container for usage with [kubernetes-vault](https://github.com/Boostport/kubernetes-vault).

Based on the `boostport/kubernetes-vault-init` image this container additionally renders a static config file using [vault-template](https://github.com/actano/vault-template) after receiving its Vault token.

## Usage

The init container is configured with the following environment variables:

| env variable | description |
|--------------|-------------|
| `VAULT_ROLE_ID` | The id of the corresponding app role in vault. |
| `VAULT_ADDR` | The endpoint URL of the Vault API. |
| `TEMPLATE_FILE` | Path to the template file which should be rendered with secrets from Vault. |
| `OUTPUT_FILE` | Path for the rendered output file. |

For information on how to write templates see [vault-template](https://github.com/actano/vault-template).

## Example

Secrets in the Vault:

```bash
vault write secret/login username=admin password=secret
```

`ConfigMap` for the template file:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: secrets-template
data:
  secrets.template.yml: |
    login:
      username: {{ vault "secret/login" "username" }}
      password: {{ vault "secret/login" "password" }}
```

`Pod` which needs secrets:

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    pod.boostport.com/vault-approle: sample-app
    pod.boostport.com/vault-init-container: init-secrets
spec:
  initContainers:
    - name: init-secrets
      image: rplan/kubernetes-vault-init
      env:
        - name: VAULT_ROLE_ID
          vaule: <...> # UUID of the vault app role
        - name: VAULT_ADDR
          value: http://vault.example.com:8200
        - name: TEMPLATE_FILE
          value: /var/run/secrets/config-template/secrets.template.yml
        - name: OUTPUT_FILE
          value: /var/run/secrets/config/secrets.yml
      volumeMounts:
        - name: secrets-config-template
          mountPath: /var/run/secrets/config-template
        - name: secrets-config
          mountPath: /var/run/secrets/config
  containers:
    - name: sample-app
      image: <...> # Image which consumes the secrets at /var/run/secrets/config/secrets.yml
      volumeMounts:
        - name: secrets-config
          mountPath: /var/run/secrets/config
          readOnly: true
  volumes:
    - name: secrets-config-template
      configMap:
        name: secrets-template
    - name: secrets-config
      emptyDir: {}
```

This will provide the `sample-app` container a static YAML file at `/var/run/secrets/config/secrets.yml` when the Pod starts:

```yaml
login:
  username: admin
  password: secret
```
