apiVersion: v1
kind: Service
metadata:
  name: ${service_name}
  namespace: ${namespace}
  labels:
    app: ${app_name}
    managed-by: terraform
spec:
  selector:
    app: ${app_name}
  ports:
  - port: 80
    targetPort: 8000
    protocol: TCP
  type: ClusterIP