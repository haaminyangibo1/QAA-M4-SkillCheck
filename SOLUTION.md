# Mini Project: worked solution

This `solution` branch holds a complete, working version of the mini project.
The `main` branch is unchanged and stays as the learners' starting point.

## What changed from the starter code

| File | Change |
| --- | --- |
| `codebase/backend/Dockerfile` | Written: Node 18 image, `npm install`, starts with `node index.js` |
| `codebase/backend/.dockerignore` | New: keeps local `node_modules` out of the image |
| `codebase/frontend/Dockerfile` | Written: nginx image, copies our config and the html/js files |
| `codebase/frontend/nginx.conf` | New: serves the site and forwards `/colour` to the backend |
| `codebase/frontend/index.js` | `fetch('http://localhost:5000/colour')` changed to `fetch('/colour')` |
| `codebase/k8s/app.yaml` | New: 2x backend pods (ClusterIP), 2x frontend pods (LoadBalancer) |
| `codebase/k8s-deploy.sh` | Written: fills in the image name and tag, applies the YAML, waits for the rollout |
| `codebase/JenkinsFile` | Written: Checkout, Build images, Push images, Deploy |
| `codebase/run-local.sh` | New: runs both containers on one machine for a quick test |

## How a request flows

```
Browser --> frontend Service (LoadBalancer) --> nginx pod --/colour--> backend Service (ClusterIP) --> backend pod
```

The browser only ever talks to nginx. nginx is inside the cluster, so it can
reach the backend by its Service name, `backend`.

## Run it locally (Docker only)

```bash
cd codebase
./run-local.sh            # builds both images and starts them
curl localhost:8081/colour
./run-local.sh stop
```

## Deploy by hand

```bash
docker login
docker build -t <user>/colour-backend:v1 codebase/backend
docker build -t <user>/colour-frontend:v1 codebase/frontend
docker push <user>/colour-backend:v1
docker push <user>/colour-frontend:v1
./codebase/k8s-deploy.sh <user> v1
kubectl get service frontend      # open the EXTERNAL-IP in a browser
```

## Jenkins setup

1. Jenkins user can run `docker` and `kubectl`:
   `sudo usermod -aG docker jenkins`, and a kubeconfig at `/var/lib/jenkins/.kube/config`.
2. Credential: Username with password, ID `dockerhub`, DockerHub username + access token.
3. Pipeline job: *Pipeline script from SCM*, this repo, branch `*/solution`,
   **Script Path `codebase/JenkinsFile`**, trigger *GitHub hook trigger for GITScm polling*.
4. GitHub webhook: `http://<jenkins-ip>:8080/github-webhook/`, push events.

A push to the branch then builds, pushes and deploys automatically. Each build
uses its build number as the image tag, so Kubernetes always rolls out the new version.
