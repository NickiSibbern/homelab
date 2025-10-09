# cluster gateway
to create a new service you have to add a new HTTPRoute in order for the gateway api to pick up the route to your service.


## example
``` yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
    ports:
      - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
  labels:
    app: nginx
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: nginx-wildcard-test-route
  namespace: default
spec:
  parentRefs:
  - name: main-gateway
    namespace: default
    sectionName: https
  hostnames:
  - nginx-test.nickisibbern.dk
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: nginx-svc
      port: 80

```
