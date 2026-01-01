apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-api-ingress
  namespace: ${namespace}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  labels:
    app: web-api
    managed-by: terraform
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ${ingress_host}
    secretName: web-api-tls
  rules:
  - host: ${ingress_host}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-api-service
            port:
              number: 80