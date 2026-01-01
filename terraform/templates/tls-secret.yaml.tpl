apiVersion: v1
kind: Secret
metadata:
  name: web-api-tls
  namespace: ${namespace}
type: kubernetes.io/tls
data:
  tls.crt: ${tls_crt}
  tls.key: ${tls_key}