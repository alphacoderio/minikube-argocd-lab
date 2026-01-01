apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${app_name}-ingress
  namespace: ${namespace}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  labels:
    app: ${app_name}
    managed-by: terraform
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ${ingress_host}
    secretName: ${app_name}-tls
  rules:
  - host: ${ingress_host}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ${service_name}
            port:
              number: 80