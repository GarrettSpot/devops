# 21

> Lab run notes: everything ran from a scratch copy of `session21-python/`. Host ports were remapped so nothing clashed with other stacks: Postgres `5432 -> 18410`, backend `8000 -> 18411`, frontend `3000 -> 18412`, local uvicorn `18413`, kind Ingress `80 -> 18420`, port-forwards `18421-18423`. Kubernetes ran in a kind cluster called `session21` with its own `$KUBECONFIG`. Passwords are shown as `****`.

## CI pipeline run locally (test job)

The `.github/workflows/ci-cd.yml` steps were run by hand in the same images the workflow uses (Python 3.12, Node 22). Nothing was pushed to GHCR, and the deploy job was replaced by the Helm deploy into kind further down.

```bash
…/session21-python ❯ cat .github/workflows/ci-cd.yml | grep -E "name:|run:|working-directory" 
name: TaskBoard Python CI/CD
      - name: Install backend dependencies
        run: pip install -r requirements.txt
        working-directory: backend
      - name: Run backend tests
        run: pytest -q
        working-directory: backend
      - name: Build frontend
        run: npm install && npm run build
        working-directory: frontend
          username: ${{ github.actor }}
      - name: Build images
        run: |
      - name: Scan backend
      - name: Scan frontend
      - name: Push images
        run: |
      - name: Configure kubectl
        run: |
      - name: Deploy with Helm
        run: |

…/session21-python ❯ docker run --rm -v "$PWD/backend:/src" -w /src python:3.12-slim sh -c "cp -r /src /work && cd /work && pip install -q --root-user-action=ignore -r requirements.txt && pytest -q"

[notice] A new release of pip is available: 25.0.1 -> 26.2.2
[notice] To update, run: pip install --upgrade pip
..F                                                                      [100%]
=================================== FAILURES ===================================
_________________________ test_create_task_validation __________________________
... (traceback trimmed) ...
    def do_execute(self, cursor, statement, parameters, context=None):
>       cursor.execute(statement, parameters)
E       sqlalchemy.exc.OperationalError: (sqlite3.OperationalError) no such table: tasks
E       [SQL: INSERT INTO tasks (title, description, priority, status, assignee, created_at) VALUES (?, ?, ?, ?, ?, ?)]
E       [parameters: ('Deploy application', '', 'HIGH', 'TODO', 'Student', '2026-10-26 09:16:27.084284')]
E       (Background on this error at: https://sqlalche.me/e/20/e3q8)

... (warnings summary trimmed) ...
=========================== short test summary info ============================
FAILED tests/test_api.py::test_create_task_validation - sqlalchemy.exc.Operat...
1 failed, 2 passed, 3 warnings in 0.84s
```

`test_create_task_validation` fails: `TestClient(app)` is used without a `with` block, so the FastAPI startup hook (`Base.metadata.create_all`) never runs and the SQLite test DB has no `tasks` table. Fix: create the tables in the test module.

```bash
…/session21-python ❯ git diff --no-index ../backend-orig/tests/test_api.py backend/tests/test_api.py
diff --git 1/../backend-orig/tests/test_api.py 2/backend/tests/test_api.py
index 71f959f..3a89546 100644
--- 1/../backend-orig/tests/test_api.py
+++ 2/backend/tests/test_api.py
@@ -3,6 +3,10 @@ os.environ["DATABASE_URL"] = "sqlite:///./test.db"
 
 from fastapi.testclient import TestClient
 from app.main import app
+from app.db import Base, engine
+
+# TestClient without a `with` block never fires the startup event, so create the tables here
+Base.metadata.create_all(bind=engine)
 
 client = TestClient(app)
 

…/session21-python ❯ docker run --rm -v "$PWD/backend:/src" -w /src python:3.12-slim sh -c "cp -r /src /work && cd /work && pip install -q --root-user-action=ignore -r requirements.txt && pytest -v -p no:warnings"

[notice] A new release of pip is available: 25.0.1 -> 26.2.2
[notice] To update, run: pip install --upgrade pip
============================= test session starts ==============================
platform linux -- Python 3.12.15, pytest-8.3.4, pluggy-1.7.0 -- /usr/local/bin/python3.12
cachedir: .pytest_cache
rootdir: /work
configfile: pytest.ini
plugins: anyio-4.15.1
collecting ... collected 3 items

tests/test_api.py::test_health PASSED                                    [ 33%]
tests/test_api.py::test_root PASSED                                      [ 66%]
tests/test_api.py::test_create_task_validation PASSED                    [100%]

============================== 3 passed in 0.32s ===============================
```

Frontend build (`npm install && npm run build`):

```bash
…/session21-python ❯ docker run --rm -v "$PWD/frontend:/src:ro" node:22-alpine sh -c "cp -r /src /work && cd /work && npm install --no-audit --no-fund && npm run build"
Unable to find image 'node:22-alpine' locally
22-alpine: Pulling from library/node
Digest: sha256:fe4f6d74e20370acb04ad889077d14d0f64a9c8ea6a42bc60cddf1e844699914
Status: Downloaded newer image for node:22-alpine

added 19 packages in 11s
npm notice
npm notice New major version of npm available! 10.9.9 -> 12.2.1
npm notice Changelog: https://github.com/npm/cli/releases/tag/v12.2.1
npm notice To update run: npm install -g npm@12.2.1
npm notice

> taskboard-frontend@1.0.0 build
> vite build

vite v8.3.5 building client environment for production...
transforming...
✓ 15 modules transformed.
rendering chunks...
computing gzip size...
dist/index.html                   0.34 kB │ gzip:  0.25 kB
dist/assets/index-DkMuKOF6.css    6.40 kB │ gzip:  2.04 kB
dist/assets/index-CnYUJSM1.js   227.22 kB │ gzip: 70.89 kB

✓ built in 102ms
```

## CI pipeline run locally (Docker build)

```bash
…/session21-python ❯ docker build --progress=plain -t taskboard-backend:local ./backend 2>&1 | grep -E "^#[0-9]+ (\[|DONE|naming|exporting)" | grep -v "^#[0-9]* \[internal\]"
#1 DONE 0.0s
#2 DONE 0.0s
#3 DONE 0.0s
#4 DONE 0.0s
#5 [1/7] FROM docker.io/library/python:3.12-slim@sha256:a0f57064cbdcd6285fa45f51237ab0b35ea8ebaed06a1f5973e89e19dfb86704
#5 DONE 0.0s
#6 [2/7] WORKDIR /app
#7 [3/7] COPY requirements.txt .
#7 DONE 0.0s
#8 [4/7] RUN pip install --no-cache-dir -r requirements.txt && useradd --create-home --uid 10001 appuser
#8 DONE 11.4s
#9 [5/7] COPY alembic.ini ./
#9 DONE 0.0s
#10 [6/7] COPY alembic ./alembic
#10 DONE 0.0s
#11 [7/7] COPY app ./app
#11 DONE 0.0s
#12 exporting to image
#12 exporting layers
#12 exporting layers 9.7s done
#12 exporting manifest sha256:402c8fceb5448039c9e6039524326ca7105860036bf758bc91835a830117e15a done
#12 exporting config sha256:b295893cfae1833e9974fe329aea782122ea75e395ca5386fb53a04ef5640619 done
#12 exporting attestation manifest sha256:82a382fbec1093f77ce886d29e196cfc12cba4a2c62a944fa1c8310f6fc447d9 done
#12 exporting manifest list sha256:10db942ca629741a151b84141e4d5d2f7c5a73f339c0b4b52993e709d70b099d done
#12 naming to docker.io/library/taskboard-backend:local done
#12 DONE 10.4s

…/session21-python ❯ docker build --progress=plain -t taskboard-frontend:local ./frontend 2>&1 | grep -E "^#[0-9]+ (\[|DONE|naming|exporting)" | grep -v "^#[0-9]* \[internal\]"
#1 DONE 0.0s
#2 DONE 0.0s
#3 DONE 2.6s
#4 DONE 0.0s
#5 DONE 0.0s
#6 [build 1/6] FROM docker.io/library/node:22-alpine@sha256:fe4f6d74e20370acb04ad889077d14d0f64a9c8ea6a42bc60cddf1e844699914
#6 DONE 0.0s
#7 [build 2/6] WORKDIR /app
#8 [build 3/6] COPY package*.json ./
#8 DONE 0.1s
#9 [stage-1 1/3] FROM docker.io/library/nginx:1.27-alpine@sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10
#9 DONE 3.8s
#10 [build 4/6] RUN npm install
#10 DONE 11.7s
#11 [build 5/6] COPY . .
#11 DONE 0.0s
#12 [build 6/6] RUN npm run build
#12 DONE 0.5s
#13 [stage-1 2/3] COPY --from=build /app/dist /usr/share/nginx/html
#13 DONE 0.0s
#14 [stage-1 3/3] COPY nginx.conf /etc/nginx/conf.d/default.conf
#14 DONE 0.0s
#15 exporting to image
#15 exporting layers
#15 exporting layers 0.1s done
#15 exporting manifest sha256:620b6ca0f51654795c538d7cbee2b2cd654a558d27429cb3166f5495fe6114dc done
#15 exporting config sha256:77d313caf5c20ff52b0acf9bbd7ac36a88faa9ca2e355de5bce93def5b1c2419 done
#15 exporting attestation manifest sha256:de4739e51f325eab970ed1f9faabf3298621ec38b919a771eb743de44867e29b done
#15 exporting manifest list sha256:d1f23d0fed7364089a2289ceda9f73cfec06bccafe4aa3e9de63ee51572ba411
#15 exporting manifest list sha256:d1f23d0fed7364089a2289ceda9f73cfec06bccafe4aa3e9de63ee51572ba411 done
#15 naming to docker.io/library/taskboard-frontend:local done
#15 DONE 0.2s

…/session21-python ❯ docker images | grep -E "REPOSITORY|taskboard"
taskboard-backend:local                                                                10db942ca629        295MB         70.4MB        
taskboard-frontend:local                                                               d1f23d0fed73       75.3MB           21MB        
```

## CI pipeline run locally (Trivy scan)

Same settings as the workflow: `HIGH,CRITICAL`, `ignore-unfixed`, `exit-code 1`. Both images fail the gate as shipped:

```bash
…/session21-python ❯ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $TRIVY_CACHE:/root/.cache aquasec/trivy:0.60.0 image --quiet --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 taskboard-backend:local; echo "exit code: $?"
... (95 lines of the per-package summary table trimmed) ...
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/websockets-17.3.dist-info/METADATA        │ python-pkg │        0        │    -    │
└──────────────────────────────────────────────────────────────────────────────────┴────────────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)

Python (python-pkg)
===================
Total: 3 (HIGH: 3, CRITICAL: 0)

┌──────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬──────────────────────────────────────────────────────────────┐
│       Library        │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                             │
├──────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
│ starlette (METADATA) │ CVE-2025-62727 │ HIGH     │ fixed  │ 0.41.3            │ 0.49.1        │ starlette: Starlette DoS via Range header merging            │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2025-62727                   │
│                      ├────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                      │ CVE-2026-48818 │          │        │                   │ 1.1.0         │ starlette: Starlette: SSRF and NTLM credential theft via UNC │
│                      │                │          │        │                   │               │ paths in StaticFiles...                                      │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2026-48818                   │
│                      ├────────────────┤          │        │                   ├───────────────┼──────────────────────────────────────────────────────────────┤
│                      │ CVE-2026-54283 │          │        │                   │ 1.3.1         │ starlette: Starlette: request.form() limits silently ignored │
│                      │                │          │        │                   │               │ for application/x-www-form-urlencoded enable DoS             │
│                      │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2026-54283                   │
└──────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴──────────────────────────────────────────────────────────────┘
exit code: 1

…/session21-python ❯ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $TRIVY_CACHE:/root/.cache aquasec/trivy:0.60.0 image --quiet --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 taskboard-frontend:local; echo "exit code: $?"

Report Summary

┌──────────────────────────────────────────┬────────┬─────────────────┬─────────┐
│                  Target                  │  Type  │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────┼────────┼─────────────────┼─────────┤
│ taskboard-frontend:local (alpine 3.21.3) │ alpine │       60        │    -    │
└──────────────────────────────────────────┴────────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)

taskboard-frontend:local (alpine 3.21.3)
========================================
Total: 60 (HIGH: 58, CRITICAL: 2)

┌──────────────┬─────────────────┬──────────┬────────┬───────────────────┬───────────────┬──────────────────────────────────────────────────────────────┐
│   Library    │  Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                             │
├──────────────┼─────────────────┼──────────┼────────┼───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
... (215 vulnerability table lines trimmed) ...
│              │                 │          │        │                   │               │ pcre2_jit_match                                              │
│              │                 │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2026-89161                   │
├──────────────┼─────────────────┤          │        ├───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
│ tiff         │ CVE-2026-4775   │          │        │ 4.7.0-r0          │ 4.7.2-r0      │ libtiff: libtiff: Arbitrary code execution or denial of      │
│              │                 │          │        │                   │               │ service via signed integer...                                │
│              │                 │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2026-4775                    │
├──────────────┼─────────────────┤          │        ├───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
│ zlib         │ CVE-2026-22184  │          │        │ 1.3.1-r2          │ 1.3.2-r0      │ zlib: zlib: Arbitrary code execution via buffer overflow in  │
│              │                 │          │        │                   │               │ untgz utility                                                │
│              │                 │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2026-22184                   │
└──────────────┴─────────────────┴──────────┴────────┴───────────────────┴───────────────┴──────────────────────────────────────────────────────────────┘
exit code: 1
```

Fix for the frontend: newer nginx base image plus `apk upgrade`:

```bash
…/session21-python ❯ git diff --no-index ../frontend-Dockerfile.orig frontend/Dockerfile
diff --git 1/../frontend-Dockerfile.orig 2/frontend/Dockerfile
index dffc2e7..880d142 100644
--- 1/../frontend-Dockerfile.orig
+++ 2/frontend/Dockerfile
@@ -4,7 +4,8 @@ COPY package*.json ./
 RUN npm install
 COPY . .
 RUN npm run build
-FROM nginx:1.27-alpine
+FROM nginx:1.29-alpine
+RUN apk upgrade --no-cache
 COPY --from=build /app/dist /usr/share/nginx/html
 COPY nginx.conf /etc/nginx/conf.d/default.conf
 EXPOSE 80

…/session21-python ❯ docker build -q -t taskboard-frontend:local ./frontend
sha256:27873ed3c7547c75954e5526496bb210cdf0d1ad0477cffef22ff1ffbb649290

…/session21-python ❯ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $TRIVY_CACHE:/root/.cache aquasec/trivy:0.60.0 image --quiet --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 taskboard-frontend:local; echo "exit code: $?"

Report Summary

┌──────────────────────────────────────────┬────────┬─────────────────┬─────────┐
│                  Target                  │  Type  │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────┼────────┼─────────────────┼─────────┤
│ taskboard-frontend:local (alpine 3.23.4) │ alpine │        0        │    -    │
└──────────────────────────────────────────┴────────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)

exit code: 0
```

Fix for the backend: Starlette CVEs come from the pinned `fastapi==0.115.6`. Bumping FastAPI alone only reached Starlette 0.52.1 (because `prometheus-fastapi-instrumentator==7.0.2` caps it), so the instrumentator was bumped as well. Tests still pass and the scan is clean:

```bash
…/session21-python ❯ git diff --no-index ../backend-orig/requirements.txt backend/requirements.txt
diff --git 1/../backend-orig/requirements.txt 2/backend/requirements.txt
index fcb57b7..aff21f9 100644
--- 1/../backend-orig/requirements.txt
+++ 2/backend/requirements.txt
@@ -1,9 +1,9 @@
-fastapi==0.115.6
+fastapi==0.162.0
 uvicorn[standard]==0.34.0
 sqlalchemy==2.0.36
 psycopg[binary]==3.2.3
 pydantic-settings==2.7.1
-prometheus-fastapi-instrumentator==7.0.2
+prometheus-fastapi-instrumentator==8.1.0
 alembic==1.14.0
 pytest==8.3.4
 httpx==0.28.1

…/session21-python ❯ docker run --rm -v "$PWD/backend:/src" -w /src python:3.12-slim sh -c "cp -r /src /work && cd /work && pip install -q --root-user-action=ignore -r requirements.txt 2>/dev/null && pip list 2>/dev/null | grep -iE \"^(fastapi|starlette|prometheus-fastapi)\" && pytest -q -p no:warnings"
fastapi                           0.162.0
prometheus-fastapi-instrumentator 8.1.0
starlette                         1.10.0
...                                                                      [100%]
3 passed in 0.36s

…/session21-python ❯ docker build -q -t taskboard-backend:local ./backend
sha256:c21d851264c85948f2f8abbc5e93944268a80455d6dbc52dcc136bef91e2d040

…/session21-python ❯ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $TRIVY_CACHE:/root/.cache aquasec/trivy:0.60.0 image --quiet --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 taskboard-backend:local; echo "exit code: $?"

Report Summary

┌──────────────────────────────────────────────────────────────────────────────────┬────────────┬─────────────────┬─────────┐
│                                      Target                                      │    Type    │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ taskboard-backend:local (debian 13.7)                                            │   debian   │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/SQLAlchemy-2.0.36.dist-info/METADATA      │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/alembic-1.14.0.dist-info/METADATA         │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/annotated_doc-0.0.5.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/annotated_types-0.8.0.dist-info/METADATA  │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/anyio-4.15.1.dist-info/METADATA           │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/certifi-2026.10.23.dist-info/METADATA     │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/click-8.5.0.dist-info/METADATA            │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/fastapi-0.162.0.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/greenlet-3.5.6.dist-info/METADATA         │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/h11-0.16.0.dist-info/METADATA             │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/httpcore-1.0.9.dist-info/METADATA         │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/httptools-0.9.0.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/httpx-0.28.1.dist-info/METADATA           │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/idna-3.20.dist-info/METADATA              │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/iniconfig-2.3.1.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/mako-1.4.3.dist-info/METADATA             │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/markupsafe-3.0.4.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/opentelemetry_api-1.45.1.dist-info/METAD- │ python-pkg │        0        │    -    │
│ ATA                                                                              │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/packaging-26.3.dist-info/METADATA         │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/pip-25.0.1.dist-info/METADATA             │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/pluggy-1.7.0.dist-info/METADATA           │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/prometheus_client-0.26.0.dist-info/METAD- │ python-pkg │        0        │    -    │
│ ATA                                                                              │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/prometheus_fastapi_instrumentator-8.1.0.- │ python-pkg │        0        │    -    │
│ dist-info/METADATA                                                               │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/psycopg-3.2.3.dist-info/METADATA          │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/psycopg_binary-3.2.3.dist-info/METADATA   │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/pydantic-2.14.1.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/pydantic_core-2.50.1.dist-info/METADATA   │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/pydantic_settings-2.7.1.dist-info/METADA- │ python-pkg │        0        │    -    │
│ TA                                                                               │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/pytest-8.3.4.dist-info/METADATA           │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/python_dotenv-1.2.4.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/pyyaml-6.0.3.dist-info/METADATA           │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/starlette-1.10.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/typing_extensions-4.16.0.dist-info/METAD- │ python-pkg │        0        │    -    │
│ ATA                                                                              │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/typing_inspection-0.4.4.dist-info/METADA- │ python-pkg │        0        │    -    │
│ TA                                                                               │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/uvicorn-0.34.0.dist-info/METADATA         │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/uvloop-0.23.0.dist-info/METADATA          │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/watchfiles-1.3.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/websockets-17.3.dist-info/METADATA        │ python-pkg │        0        │    -    │
└──────────────────────────────────────────────────────────────────────────────────┴────────────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)

exit code: 0
```

## Docker Compose

```bash
…/session21-python ❯ docker compose up --build -d 2>&1 | grep -vE "^ *#|^\s*$|=> " 
 Image session21-python-frontend Building 
 Image session21-python-backend Building 
 Image session21-python-backend Built 
 Image session21-python-frontend Built 
 Network session21-python_default Creating 
 Volume session21-python_postgres-data Creating 
 Volume session21-python_postgres-data Created 
 Network session21-python_default Created 
 Container session21-python-postgres-1 Creating 
 Container session21-python-postgres-1 Created 
 Container session21-python-backend-1 Creating 
 Container session21-python-backend-1 Created 
 Container session21-python-frontend-1 Creating 
 Container session21-python-frontend-1 Created 
 Container session21-python-postgres-1 Starting 
 Container session21-python-postgres-1 Started 
 Container session21-python-backend-1 Starting 
 Container session21-python-backend-1 Started 
 Container session21-python-frontend-1 Starting 
 Container session21-python-frontend-1 Started 

…/session21-python ❯ docker compose ps
NAME                          IMAGE                       COMMAND                  SERVICE    CREATED          STATUS          PORTS
session21-python-frontend-1   session21-python-frontend   "/docker-entrypoint.…"   frontend   30 seconds ago   Up 18 seconds   0.0.0.0:18412->80/tcp, [::]:18412->80/tcp
session21-python-postgres-1   postgres:16-alpine          "docker-entrypoint.s…"   postgres   31 seconds ago   Up 29 seconds   0.0.0.0:18410->5432/tcp, [::]:18410->5432/tcp

…/session21-python ❯ docker compose ps -a backend
NAME                         IMAGE                      COMMAND                  SERVICE   CREATED          STATUS                      PORTS
session21-python-backend-1   session21-python-backend   "sh -c 'alembic upgr…"   backend   40 seconds ago   Exited (1) 26 seconds ago   

…/session21-python ❯ docker compose logs backend | tail -15
backend-1  |     raise exc_value.with_traceback(exc_tb)
backend-1  |   File "/usr/local/lib/python3.12/site-packages/sqlalchemy/pool/base.py", line 896, in __connect
backend-1  |     self.dbapi_connection = connection = pool._invoke_creator(self)
backend-1  |                                          ^^^^^^^^^^^^^^^^^^^^^^^^^^
backend-1  |   File "/usr/local/lib/python3.12/site-packages/sqlalchemy/engine/create.py", line 643, in connect
backend-1  |     return dialect.connect(*cargs, **cparams)
backend-1  |            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
backend-1  |   File "/usr/local/lib/python3.12/site-packages/sqlalchemy/engine/default.py", line 621, in connect
backend-1  |     return self.loaded_dbapi.connect(*cargs, **cparams)
backend-1  |            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
backend-1  |   File "/usr/local/lib/python3.12/site-packages/psycopg/connection.py", line 119, in connect
backend-1  |     raise last_ex.with_traceback(None)
backend-1  | sqlalchemy.exc.OperationalError: (psycopg.OperationalError) connection failed: connection to server at "172.18.0.2", port 5432 failed: Connection refused
backend-1  | 	Is the server running on that host and accepting TCP/IP connections?
backend-1  | (Background on this error at: https://sqlalche.me/e/20/e3q8)
```

The backend exited because `depends_on` only waits for the Postgres container to start, not for Postgres to accept connections, so `alembic upgrade head` hit `Connection refused`. Fix: add a `pg_isready` healthcheck and `condition: service_healthy`.

```bash
…/session21-python ❯ git diff --no-index ../compose.before-fix.yml docker-compose.yml
diff --git 1/../compose.before-fix.yml 2/docker-compose.yml
index 22597f6..aefea83 100644
--- 1/../compose.before-fix.yml
+++ 2/docker-compose.yml
@@ -9,13 +9,19 @@ services:
       - "18410:5432"
     volumes:
       - postgres-data:/var/lib/postgresql/data
+    healthcheck:
+      test: ["CMD-SHELL", "pg_isready -U taskboard -d taskboard"]
+      interval: 5s
+      timeout: 3s
+      retries: 10
 
   backend:
     build: ./backend
     environment:
       DATABASE_URL: postgresql+psycopg://taskboard:****@postgres:5432/taskboard
     depends_on:
-      - postgres
+      postgres:
+        condition: service_healthy
     ports:
       - "18411:8000"
 

…/session21-python ❯ docker compose up -d
 Container session21-python-frontend-1 Running 
 Container session21-python-postgres-1 Recreate 
 Container session21-python-postgres-1 Recreated 
 Container session21-python-postgres-1 Starting 
 Container session21-python-postgres-1 Started 
 Container session21-python-postgres-1 Waiting 
 Container session21-python-postgres-1 Healthy 
 Container session21-python-backend-1 Starting 
 Container session21-python-backend-1 Started 

…/session21-python ❯ docker compose ps
NAME                          IMAGE                       COMMAND                  SERVICE    CREATED              STATUS                    PORTS
session21-python-backend-1    session21-python-backend    "sh -c 'alembic upgr…"   backend    About a minute ago   Up 30 seconds             0.0.0.0:18411->8000/tcp, [::]:18411->8000/tcp
session21-python-frontend-1   session21-python-frontend   "/docker-entrypoint.…"   frontend   About a minute ago   Up About a minute         0.0.0.0:18412->80/tcp, [::]:18412->80/tcp
session21-python-postgres-1   postgres:16-alpine          "docker-entrypoint.s…"   postgres   36 seconds ago       Up 35 seconds (healthy)   0.0.0.0:18410->5432/tcp, [::]:18410->5432/tcp

…/session21-python ❯ docker compose logs backend | tail -8
backend-1  | (Background on this error at: https://sqlalche.me/e/20/e3q8)
backend-1  | INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
backend-1  | INFO  [alembic.runtime.migration] Will assume transactional DDL.
backend-1  | INFO  [alembic.runtime.migration] Running upgrade  -> 0001_create_tasks
backend-1  | INFO:     Started server process [7]
backend-1  | INFO:     Waiting for application startup.
backend-1  | INFO:     Application startup complete.
backend-1  | INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

## REST API CRUD, metrics and database

(`18411` = backend directly, `18412` = through the frontend nginx `/api/` proxy)

```bash
…/session21-python ❯ curl -s localhost:18411/
{"service":"TaskBoard API","version":"1.0.0","docs":"/docs"}

…/session21-python ❯ curl -s localhost:18411/health
{"status":"UP"}

…/session21-python ❯ curl -s localhost:18411/ready
{"status":"READY"}

…/session21-python ❯ curl -s -X POST localhost:18411/api/tasks -H 'Content-Type: application/json' -d '{"title":"Set up CI pipeline","description":"pytest + docker build + trivy","priority":"HIGH","assignee":"Adam"}' | jq
{
  "title": "Set up CI pipeline",
  "description": "pytest + docker build + trivy",
  "priority": "HIGH",
  "status": "TODO",
  "assignee": "Adam",
  "id": 1,
  "created_at": "2026-10-26T09:25:35.285418Z"
}

…/session21-python ❯ curl -s -X POST localhost:18412/api/tasks -H 'Content-Type: application/json' -d '{"title":"Remove me","priority":"LOW","assignee":"Adam"}' | jq -c
{"title":"Remove me","description":"","priority":"LOW","status":"TODO","assignee":"Adam","id":4,"created_at":"2026-10-26T09:25:35.371821Z"}

…/session21-python ❯ curl -s -X PUT localhost:18411/api/tasks/2 -H 'Content-Type: application/json' -d '{"status":"IN_PROGRESS"}' | jq -c
{"title":"Write Helm chart","description":"","priority":"MEDIUM","status":"IN_PROGRESS","assignee":"Adam","id":2,"created_at":"2026-10-26T09:25:35.316020Z"}

…/session21-python ❯ curl -s -X PUT localhost:18411/api/tasks/1 -H 'Content-Type: application/json' -d '{"status":"DONE"}' | jq -c
{"title":"Set up CI pipeline","description":"pytest + docker build + trivy","priority":"HIGH","status":"DONE","assignee":"Adam","id":1,"created_at":"2026-10-26T09:25:35.285418Z"}

…/session21-python ❯ curl -s -o /dev/null -w "%{http_code}\n" -X DELETE localhost:18411/api/tasks/4
204

…/session21-python ❯ curl -s localhost:18411/api/tasks/4
{"detail":"Task not found"}

…/session21-python ❯ curl -s localhost:18412/api/tasks | jq -c ".[]"
{"title":"Configure Grafana dashboard","description":"","priority":"LOW","status":"TODO","assignee":"Adam","id":3,"created_at":"2026-10-26T09:25:35.332213Z"}
{"title":"Write Helm chart","description":"","priority":"MEDIUM","status":"IN_PROGRESS","assignee":"Adam","id":2,"created_at":"2026-10-26T09:25:35.316020Z"}
{"title":"Set up CI pipeline","description":"pytest + docker build + trivy","priority":"HIGH","status":"DONE","assignee":"Adam","id":1,"created_at":"2026-10-26T09:25:35.285418Z"}

…/session21-python ❯ curl -s localhost:18412/api/tasks/stats
{"total":3,"todo":1,"inProgress":1,"done":1}

…/session21-python ❯ curl -s localhost:18411/metrics | grep -E "^http_requests_total" | head
http_requests_total{handler="/",method="GET",status="2xx"} 1.0
http_requests_total{handler="/health",method="GET",status="2xx"} 1.0
http_requests_total{handler="/ready",method="GET",status="2xx"} 1.0
http_requests_total{handler="/api/tasks",method="POST",status="2xx"} 4.0
http_requests_total{handler="/api/tasks/{task_id}",method="PUT",status="2xx"} 2.0
http_requests_total{handler="/api/tasks/{task_id}",method="DELETE",status="2xx"} 1.0
http_requests_total{handler="/api/tasks/{task_id}",method="GET",status="4xx"} 1.0
http_requests_total{handler="/api/tasks",method="GET",status="2xx"} 1.0
http_requests_total{handler="/api/tasks/stats",method="GET",status="2xx"} 1.0
```

![TaskBoard frontend served by Docker Compose](taskboard-compose.png)

![FastAPI Swagger docs](fastapi-docs.png)

```bash
…/session21-python ❯ docker compose exec postgres psql -U taskboard -d taskboard -c "\dt" -c "SELECT id, title, priority, status, assignee FROM tasks;"
              List of relations
 Schema |      Name       | Type  |   Owner   
--------+-----------------+-------+-----------
 public | alembic_version | table | taskboard
 public | tasks           | table | taskboard
(2 rows)

 id |            title            | priority |   status    | assignee 
----+-----------------------------+----------+-------------+----------
  3 | Configure Grafana dashboard | LOW      | TODO        | Adam
  2 | Write Helm chart            | MEDIUM   | IN_PROGRESS | Adam
  1 | Set up CI pipeline          | HIGH     | DONE        | Adam
(3 rows)

…/session21-python ❯ docker compose down -v
 Container session21-python-frontend-1 Stopping 
 Container session21-python-frontend-1 Stopped 
 Container session21-python-frontend-1 Removing 
 Container session21-python-frontend-1 Removed 
 Container session21-python-backend-1 Stopping 
 Container session21-python-backend-1 Stopped 
 Container session21-python-backend-1 Removing 
 Container session21-python-backend-1 Removed 
 Container session21-python-postgres-1 Stopping 
 Container session21-python-postgres-1 Stopped 
 Container session21-python-postgres-1 Removing 
 Container session21-python-postgres-1 Removed 
 Volume session21-python_postgres-data Removing 
 Network session21-python_default Removing 
 Volume session21-python_postgres-data Removed 
 Network session21-python_default Removed 
```

## Run backend directly (venv + Alembic + Uvicorn)

The local Python is 3.14, and `psycopg[binary]==3.2.3` has no wheel for it, so the install fails. For the local run it was installed with `psycopg[binary]==3.2.13` (requirements.txt left unchanged). Postgres came from `docker compose up -d postgres` on host port 18410.

```bash
…/session21-python/backend ❯ python -m venv .venv && source .venv/bin/activate && python --version
Python 3.14.7

…/session21-python/backend ❯ source .venv/bin/activate && timeout 300 pip install -q -r requirements.txt 2>&1 | tail -8; echo "pip exit: ${PIPESTATUS[0]}"
ERROR: Could not find a version that satisfies the requirement psycopg-binary==3.2.3; implementation_name != "pypy" and extra == "binary" (from psycopg[binary]) (from versions: 3.2.10, 3.2.11, 3.2.12, 3.2.13, 3.3.0, 3.3.1, 3.3.2, 3.3.3, 3.3.4, 3.3.5, 3.3.6)

[notice] A new release of pip is available: 26.2.1 -> 26.2.2
[notice] To update, run: pip install --upgrade pip
ERROR: No matching distribution found for psycopg-binary==3.2.3; implementation_name != "pypy" and extra == "binary"
pip exit: 1

…/session21-python/backend ❯ source .venv/bin/activate && pip install -q -r <(sed 's/psycopg\[binary\]==3.2.3/psycopg[binary]==3.2.13/' requirements.txt) 2>&1 | grep -v notice; echo "pip exit: ${PIPESTATUS[0]}"

pip exit: 0

…/session21-python/backend ❯ export DATABASE_URL='postgresql+psycopg://taskboard:****@localhost:18410/taskboard'

…/session21-python/backend ❯ source .venv/bin/activate && alembic upgrade head
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> 0001_create_tasks

…/session21-python/backend ❯ uvicorn app.main:app --port 18413 &
INFO:     Started server process [873195]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:18413 (Press CTRL+C to quit)
INFO:     127.0.0.1:53150 - "GET /health HTTP/1.1" 200 OK

…/session21-python/backend ❯ curl -s http://localhost:18413/health
{"status":"UP"}

…/session21-python/backend ❯ curl -s http://localhost:18413/api/tasks
[]
```

## Terraform (init / validate / plan only)

The configuration creates a VPC, NAT gateway **and an EKS cluster with managed nodes** (not only S3/VPC), so only `init`, `validate` and `plan` were run. Nothing was applied.

```bash
…/session21-python/terraform ❯ terraform version
Terraform v1.15.9
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.17.0. You can update by downloading from https://developer.hashicorp.com/terraform/install

…/session21-python/terraform ❯ terraform init -no-color
Initializing the backend...

Initializing modules...
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 21.29.0 for eks...
- eks in .terraform/modules/eks
Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 6.7.3 for vpc...
- vpc in .terraform/modules/vpc
- eks.fargate_profile in .terraform/modules/eks/modules/fargate-profile
Downloading registry.terraform.io/terraform-aws-modules/kms/aws 4.0.0 for eks.kms...
- eks.kms in .terraform/modules/eks.kms
- eks.self_managed_node_group in .terraform/modules/eks/modules/self-managed-node-group
- eks.eks_managed_node_group in .terraform/modules/eks/modules/eks-managed-node-group
- eks.self_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
- eks.eks_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data

Error: Terraform encountered problems during initialisation, including problems
with the configuration, described below.

The Terraform configuration must be valid before initialization so that
Terraform can determine which modules and providers need to be installed.

Error: Invalid single-argument block definition

  on main.tf line 1, in module "vpc":
   1: module "vpc" { source = "terraform-aws-modules/vpc/aws" version = "5.8.1" name = "taskboard-vpc" cidr = "10.20.0.0/16" azs = ["ap-south-1a","ap-south-1b"] private_subnets = ["10.20.1.0/24","10.20.2.0/24"] public_subnets = ["10.20.101.0/24","10.20.102.0/24"] enable_nat_gateway = true single_nat_gateway = true }

A single-line block definition must end with a closing brace immediately
after its single argument definition.

Error: Invalid single-argument block definition

  on versions.tf line 1, in terraform:
   1: terraform { required_version = ">= 1.7.0" required_providers { aws = { source = "hashicorp/aws" version = "~> 5.0" } } }

A single-line block definition must end with a closing brace immediately
after its single argument definition.
```

`terraform init` fails: `main.tf` and `versions.tf` put several arguments inside single-line blocks, which HCL does not allow. Fix: expand the blocks onto multiple lines (same values).

```bash
…/session21-python/terraform ❯ git diff --no-index --stat ../../tf-orig/main.tf main.tf; git diff --no-index ../../tf-orig/versions.tf versions.tf
 ../../tf-orig/main.tf => main.tf | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)
diff --git 1/../../tf-orig/versions.tf 2/versions.tf
index 95df5bb..9919af5 100644
--- 1/../../tf-orig/versions.tf
+++ 2/versions.tf
@@ -1,2 +1,13 @@
-terraform { required_version = ">= 1.7.0" required_providers { aws = { source = "hashicorp/aws" version = "~> 5.0" } } }
-provider "aws" { region = var.aws_region }
+terraform {
+  required_version = ">= 1.7.0"
+  required_providers {
+    aws = {
+      source  = "hashicorp/aws"
+      version = "~> 5.0"
+    }
+  }
+}
+
+provider "aws" {
+  region = var.aws_region
+}

…/session21-python/terraform ❯ terraform init -no-color
Initializing the backend...

Initializing modules...
Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 5.8.1 for vpc...
- vpc in .terraform/modules/vpc
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 20.37.1 for eks...
- eks in .terraform/modules/eks
- eks.fargate_profile in .terraform/modules/eks/modules/fargate-profile
Downloading registry.terraform.io/terraform-aws-modules/kms/aws 2.1.0 for eks.kms...
- eks.kms in .terraform/modules/eks.kms
- eks.eks_managed_node_group in .terraform/modules/eks/modules/eks-managed-node-group
- eks.self_managed_node_group in .terraform/modules/eks/modules/self-managed-node-group
- eks.eks_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
- eks.self_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data

Initializing provider plugins...
- Finding hashicorp/cloudinit versions matching ">= 2.0.0"...
- Finding hashicorp/null versions matching ">= 3.0.0"...
- Finding hashicorp/aws versions matching ">= 4.33.0, ~> 5.0, >= 5.30.0, >= 5.95.0, < 6.0.0"...
- Finding hashicorp/tls versions matching ">= 3.0.0"...
- Finding hashicorp/time versions matching ">= 0.9.0"...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)
- Installing hashicorp/tls v4.4.2...
- Installed hashicorp/tls v4.4.2 (signed by HashiCorp)
- Installing hashicorp/time v0.14.2...
- Installed hashicorp/time v0.14.2 (signed by HashiCorp)
- Installing hashicorp/cloudinit v2.4.1...
- Installed hashicorp/cloudinit v2.4.1 (signed by HashiCorp)
- Installing hashicorp/null v3.3.2...
- Installed hashicorp/null v3.3.2 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

…/session21-python/terraform ❯ terraform fmt -recursive -check; echo "fmt exit: $?"
fmt exit: 0

…/session21-python/terraform ❯ terraform validate -no-color
Success! The configuration is valid.

…/session21-python/terraform ❯ terraform plan -no-color -lock=false > plan.txt 2>&1; echo "plan exit: $?"; grep -E "will be created|will be read|^Plan:|Error" plan.txt
plan exit: 0
  # module.eks.data.tls_certificate.this[0] will be read during apply
  # module.eks.aws_cloudwatch_log_group.this[0] will be created
  # module.eks.aws_eks_access_entry.this["cluster_creator"] will be created
  # module.eks.aws_eks_access_policy_association.this["cluster_creator_admin"] will be created
  # module.eks.aws_eks_cluster.this[0] will be created
  # module.eks.aws_iam_openid_connect_provider.oidc_provider[0] will be created
  # module.eks.aws_iam_policy.cluster_encryption[0] will be created
  # module.eks.aws_iam_policy.custom[0] will be created
  # module.eks.aws_iam_role.this[0] will be created
  # module.eks.aws_iam_role_policy_attachment.cluster_encryption[0] will be created
  # module.eks.aws_iam_role_policy_attachment.custom[0] will be created
  # module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"] will be created
  # module.eks.aws_iam_role_policy_attachment.this["AmazonEKSVPCResourceController"] will be created
  # module.eks.aws_security_group.cluster[0] will be created
  # module.eks.aws_security_group.node[0] will be created
  # module.eks.aws_security_group_rule.cluster["ingress_nodes_443"] will be created
  # module.eks.aws_security_group_rule.node["egress_all"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_443"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_4443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_6443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"] will be created
  # module.eks.time_sleep.this[0] will be created
  # module.vpc.aws_default_network_acl.this[0] will be created
  # module.vpc.aws_default_route_table.default[0] will be created
  # module.vpc.aws_default_security_group.this[0] will be created
  # module.vpc.aws_eip.nat[0] will be created
  # module.vpc.aws_internet_gateway.this[0] will be created
  # module.vpc.aws_nat_gateway.this[0] will be created
  # module.vpc.aws_route.private_nat_gateway[0] will be created
  # module.vpc.aws_route.public_internet_gateway[0] will be created
  # module.vpc.aws_route_table.private[0] will be created
  # module.vpc.aws_route_table.public[0] will be created
  # module.vpc.aws_route_table_association.private[0] will be created
  # module.vpc.aws_route_table_association.private[1] will be created
  # module.vpc.aws_route_table_association.public[0] will be created
  # module.vpc.aws_route_table_association.public[1] will be created
  # module.vpc.aws_subnet.private[0] will be created
  # module.vpc.aws_subnet.private[1] will be created
  # module.vpc.aws_subnet.public[0] will be created
  # module.vpc.aws_subnet.public[1] will be created
  # module.vpc.aws_vpc.this[0] will be created
  # module.eks.module.eks_managed_node_group["main"].aws_eks_node_group.this[0] will be created
  # module.eks.module.eks_managed_node_group["main"].aws_iam_role.this[0] will be created
  # module.eks.module.eks_managed_node_group["main"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"] will be created
  # module.eks.module.eks_managed_node_group["main"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"] will be created
  # module.eks.module.eks_managed_node_group["main"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"] will be created
  # module.eks.module.eks_managed_node_group["main"].aws_launch_template.this[0] will be created
  # module.eks.module.kms.data.aws_iam_policy_document.this[0] will be read during apply
  # module.eks.module.kms.aws_kms_alias.this["cluster"] will be created
  # module.eks.module.kms.aws_kms_key.this[0] will be created
  # module.eks.module.eks_managed_node_group["main"].module.user_data.null_resource.validate_cluster_service_cidr will be created
Plan: 54 to add, 0 to change, 0 to destroy.
```

## Kubernetes + Helm on kind

```bash
…/session21-python ❯ cat kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 18420
        protocol: TCP

…/session21-python ❯ kind create cluster --name session21 --config kind-config.yaml --kubeconfig $KUBECONFIG
Creating cluster "session21" ...
 ✓ Ensuring node image (kindest/node:v1.37.0) 🖼️
 ✓ Preparing nodes 📦 
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-session21"
You can now use your cluster with:

kubectl cluster-info --context kind-session21 --kubeconfig /tmp/claude-1000/-home-shohe-year-3-devops-mine/a1bf6e3b-3c54-412a-89c8-35788d81aa0b/scratchpad/k8s-c/kubeconfig

Have a nice day! 👋

…/session21-python ❯ kind load docker-image taskboard-backend:local taskboard-frontend:local --name session21
Image: "taskboard-backend:local" with ID "sha256:c21d851264c85948f2f8abbc5e93944268a80455d6dbc52dcc136bef91e2d040" not yet present on node "session21-control-plane", loading...
Image: "taskboard-frontend:local" with ID "sha256:27873ed3c7547c75954e5526496bb210cdf0d1ad0477cffef22ff1ffbb649290" not yet present on node "session21-control-plane", loading...

…/session21-python ❯ kubectl apply -f k8s/namespace.yaml
namespace/taskboard created

…/session21-python ❯ helm upgrade --install taskboard ./helm/taskboard --namespace taskboard --create-namespace --set backend.image=taskboard-backend --set backend.tag=local --set frontend.image=taskboard-frontend --set frontend.tag=local
Release "taskboard" does not exist. Installing it now.
Error: unable to build kubernetes objects from release manifest: resource mapping not found for name: "taskboard-taskboard-backend" namespace: "" from "": no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1"
ensure CRDs are installed first
```

The chart ships a `ServiceMonitor`, so the Prometheus Operator CRDs must exist first. Install kube-prometheus-stack with `monitoring/prometheus-values.yaml`:

```bash
…/session21-python ❯ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories

…/session21-python ❯ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈

…/session21-python ❯ cat monitoring/prometheus-values.yaml
grafana:
  enabled: true
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    serviceMonitorNamespaceSelector: {}

…/session21-python ❯ helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f monitoring/prometheus-values.yaml --wait --timeout 10m
Release "kube-prometheus-stack" does not exist. Installing it now.
NAME: kube-prometheus-stack
LAST DEPLOYED: Mon Oct 26 14:58:14 2026
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=kube-prometheus-stack"

Get Grafana 'admin' user password by running:

  kubectl --namespace monitoring get secrets kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=kube-prometheus-stack" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Get your grafana admin user password by running:

  kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

…/session21-python ❯ kubectl get pods -n monitoring
NAME                                                        READY   STATUS            RESTARTS   AGE
alertmanager-kube-prometheus-stack-alertmanager-0           0/2     PodInitializing   0          112s
kube-prometheus-stack-grafana-69bcd45576-tdknr              3/3     Running           0          2m8s
kube-prometheus-stack-kube-state-metrics-78dc75b868-nkm5z   1/1     Running           0          2m8s
kube-prometheus-stack-operator-975598bdf-rsckf              1/1     Running           0          2m8s
kube-prometheus-stack-prometheus-node-exporter-c46xz        1/1     Running           0          2m8s
prometheus-kube-prometheus-stack-prometheus-0               0/2     PodInitializing   0          112s

…/session21-python ❯ helm upgrade --install taskboard ./helm/taskboard --namespace taskboard --create-namespace --set backend.image=taskboard-backend --set backend.tag=local --set frontend.image=taskboard-frontend --set frontend.tag=local
Release "taskboard" does not exist. Installing it now.
NAME: taskboard
LAST DEPLOYED: Mon Oct 26 15:00:33 2026
NAMESPACE: taskboard
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
```

## Troubleshooting the Helm deploy

```bash
…/session21-python ❯ kubectl get pods -n taskboard
NAME                                           READY   STATUS              RESTARTS      AGE
taskboard-frontend-bbb7b895f-2v4c8             0/1     CrashLoopBackOff    2 (17s ago)   60s
taskboard-frontend-bbb7b895f-5hswr             0/1     Error               2 (22s ago)   61s
taskboard-postgres-755b4497b-dqcws             0/1     ContainerCreating   0             61s
taskboard-taskboard-backend-7d8fb7697c-6wh9l   0/1     CrashLoopBackOff    3 (19s ago)   61s
taskboard-taskboard-backend-7d8fb7697c-prmc9   0/1     CrashLoopBackOff    3 (21s ago)   60s

…/session21-python ❯ kubectl logs deploy/taskboard-frontend -n taskboard | tail -5
Found 2 pods, using pod/taskboard-frontend-bbb7b895f-5hswr
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/10/26 09:31:27 [emerg] 1#1: host not found in upstream "backend" in /etc/nginx/conf.d/default.conf:13
nginx: [emerg] host not found in upstream "backend" in /etc/nginx/conf.d/default.conf:13

…/session21-python ❯ kubectl logs deploy/taskboard-taskboard-backend -n taskboard | tail -4
Found 2 pods, using pod/taskboard-taskboard-backend-7d8fb7697c-6wh9l
    raise last_ex.with_traceback(None)
sqlalchemy.exc.OperationalError: (psycopg.OperationalError) connection failed: connection to server at "10.96.108.216", port 5432 failed: Connection refused
	Is the server running on that host and accepting TCP/IP connections?
(Background on this error at: https://sqlalche.me/e/20/e3q8)

…/session21-python ❯ kubectl get svc -n taskboard
NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
taskboard-frontend            ClusterIP   10.96.174.99    <none>        80/TCP     67s
taskboard-postgres            ClusterIP   10.96.108.216   <none>        5432/TCP   67s
taskboard-taskboard-backend   ClusterIP   10.96.99.88     <none>        8000/TCP   67s

…/session21-python ❯ kubectl get pods -n taskboard
NAME                                           READY   STATUS             RESTARTS      AGE
taskboard-frontend-bbb7b895f-2v4c8             0/1     CrashLoopBackOff   3 (24s ago)   96s
taskboard-frontend-bbb7b895f-5hswr             0/1     CrashLoopBackOff   3 (12s ago)   97s
taskboard-postgres-755b4497b-dqcws             1/1     Running            0             97s
taskboard-taskboard-backend-7d8fb7697c-6wh9l   0/1     CrashLoopBackOff   3 (55s ago)   97s
taskboard-taskboard-backend-7d8fb7697c-prmc9   0/1     Running            4 (57s ago)   96s
```

Two problems:

- **Backend** CrashLoopBackOff only while Postgres was still starting. It recovered once Postgres was ready (readiness probe `/ready`).
- **Frontend** CrashLoopBackOff: `nginx.conf` proxies to `http://backend:8000` (the Compose service name), but the chart's Service is `taskboard-taskboard-backend`, so nginx cannot resolve `backend`.

Fix in the chart: add an alias Service named `backend`. Also fix the Ingress, which pointed at a non-existent `taskboard-backend:8080` (the real Service is `<release>-taskboard-backend:8000`). Then upgrade and restart the frontend pods (`kubectl rollout restart deploy/taskboard-frontend -n taskboard`).

```bash
…/session21-python ❯ git diff --no-index ../helm-orig/taskboard helm/taskboard
diff --git 1/helm/taskboard/templates/backend-alias-service.yaml 2/helm/taskboard/templates/backend-alias-service.yaml
new file mode 100644
index 0000000..aa594be
--- /dev/null
+++ 2/helm/taskboard/templates/backend-alias-service.yaml
@@ -0,0 +1,12 @@
+# The frontend nginx.conf proxies /api/ to http://backend:8000 (the Docker Compose service name).
+# This alias Service gives the same DNS name inside the Kubernetes namespace (no labels, so the
+# ServiceMonitor does not scrape the backend twice).
+apiVersion: v1
+kind: Service
+metadata:
+  name: backend
+spec:
+  selector: {app: taskboard-backend}
+  ports:
+    - port: 8000
+      targetPort: 8000
diff --git 1/../helm-orig/taskboard/templates/ingress.yaml 2/helm/taskboard/templates/ingress.yaml
index 50cef97..0bf1061 100644
--- 1/../helm-orig/taskboard/templates/ingress.yaml
+++ 2/helm/taskboard/templates/ingress.yaml
@@ -8,6 +8,6 @@ spec:
   - host: {{ .Values.ingress.host }}
     http:
       paths:
-      - {path: /api, pathType: Prefix, backend: {service: {name: taskboard-backend, port: {number: 8080}}}}
+      - {path: /api, pathType: Prefix, backend: {service: {name: {{ include "taskboard.fullname" . }}-backend, port: {number: 8000}}}}
       - {path: /, pathType: Prefix, backend: {service: {name: taskboard-frontend, port: {number: 80}}}}
 {{- end }}

…/session21-python ❯ helm upgrade --install taskboard ./helm/taskboard --namespace taskboard --create-namespace --set backend.image=taskboard-backend --set backend.tag=local --set frontend.image=taskboard-frontend --set frontend.tag=local
Release "taskboard" has been upgraded. Happy Helming!
NAME: taskboard
LAST DEPLOYED: Mon Oct 26 15:02:29 2026
NAMESPACE: taskboard
STATUS: deployed
REVISION: 2
DESCRIPTION: Upgrade complete
TEST SUITE: None

…/session21-python ❯ kubectl get pods -n taskboard
NAME                                           READY   STATUS      RESTARTS      AGE
taskboard-frontend-6f9c4b5fcc-4vvmz            1/1     Running     0             11s
taskboard-frontend-6f9c4b5fcc-lbnfg            1/1     Running     0             22s
taskboard-frontend-bbb7b895f-5hswr             0/1     Completed   4 (53s ago)   2m18s
taskboard-postgres-755b4497b-dqcws             1/1     Running     0             2m18s
taskboard-taskboard-backend-7d8fb7697c-6wh9l   1/1     Running     4 (96s ago)   2m18s
taskboard-taskboard-backend-7d8fb7697c-prmc9   1/1     Running     4 (98s ago)   2m17s

…/session21-python ❯ kubectl get svc -n taskboard
NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
backend                       ClusterIP   10.96.61.237    <none>        8000/TCP   22s
taskboard-frontend            ClusterIP   10.96.174.99    <none>        80/TCP     2m18s
taskboard-postgres            ClusterIP   10.96.108.216   <none>        5432/TCP   2m18s
taskboard-taskboard-backend   ClusterIP   10.96.99.88     <none>        8000/TCP   2m18s

…/session21-python ❯ kubectl get endpoints -n taskboard
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                          ENDPOINTS                           AGE
backend                       10.244.0.13:8000,10.244.0.14:8000   22s
taskboard-frontend            10.244.0.18:80,10.244.0.19:80       2m18s
taskboard-postgres            10.244.0.17:5432                    2m18s
taskboard-taskboard-backend   10.244.0.13:8000,10.244.0.14:8000   2m18s

…/session21-python ❯ helm list -n taskboard
NAME     	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART          	APP VERSION
taskboard	taskboard	2       	2026-10-26 15:02:29.235779064 +0530 IST	deployed	taskboard-1.0.0	1.0.0      

…/session21-python ❯ kubectl get hpa -n taskboard
NAME                REFERENCE                                TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
taskboard-backend   Deployment/taskboard-taskboard-backend   cpu: <unknown>/60%   2         6         2          2m30s
```

## Ingress

Installed ingress-nginx (kind provider) and metrics-server (with `--kubelet-insecure-tls` for kind). Then deployed with `values-dev.yaml`. `taskboard.local` is resolved with `curl --resolve` / chromium `--host-resolver-rules` instead of editing `/etc/hosts`.

```bash
…/session21-python ❯ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.1/deploy/static/provider/kind/deploy.yaml | tail -5
deployment.apps/ingress-nginx-controller created
job.batch/ingress-nginx-admission-create created
job.batch/ingress-nginx-admission-patch created
ingressclass.networking.k8s.io/nginx created
validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created

…/session21-python ❯ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml | tail -3
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created

…/session21-python ❯ kubectl patch deployment metrics-server -n kube-system --type json -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
deployment.apps/metrics-server patched

…/session21-python ❯ cat helm/taskboard/values-dev.yaml
replicaCount: 1
ingress:
  enabled: true
  host: taskboard.local
hpa:
  enabled: false

…/session21-python ❯ helm upgrade --install taskboard ./helm/taskboard -n taskboard -f helm/taskboard/values-dev.yaml --set backend.image=taskboard-backend --set backend.tag=local --set frontend.image=taskboard-frontend --set frontend.tag=local
Release "taskboard" has been upgraded. Happy Helming!
NAME: taskboard
LAST DEPLOYED: Mon Oct 26 15:04:10 2026
NAMESPACE: taskboard
STATUS: deployed
REVISION: 3
DESCRIPTION: Upgrade complete
TEST SUITE: None

…/session21-python ❯ kubectl get ingress -n taskboard
NAME        CLASS   HOSTS             ADDRESS   PORTS   AGE
taskboard   nginx   taskboard.local             80      20s

…/session21-python ❯ kubectl get pods -n taskboard
NAME                                           READY   STATUS        RESTARTS        AGE
taskboard-frontend-6f9c4b5fcc-4vvmz            1/1     Running       0               110s
taskboard-postgres-755b4497b-dqcws             1/1     Running       0               3m57s
taskboard-taskboard-backend-7d8fb7697c-6wh9l   1/1     Running       4 (3m15s ago)   3m57s
taskboard-taskboard-backend-7d8fb7697c-prmc9   1/1     Terminating   4 (3m17s ago)   3m56s

…/session21-python ❯ curl -s --resolve taskboard.local:18420:127.0.0.1 http://taskboard.local:18420/api/tasks/stats
{"total":0,"todo":0,"inProgress":0,"done":0}

…/session21-python ❯ curl -s --resolve taskboard.local:18420:127.0.0.1 -X POST http://taskboard.local:18420/api/tasks -H 'Content-Type: application/json' -d '{"title":"Deploy TaskBoard to kind via Helm","priority":"HIGH","assignee":"Adam"}' | jq -c
{"title":"Deploy TaskBoard to kind via Helm","description":"","priority":"HIGH","status":"TODO","assignee":"Adam","id":1,"created_at":"2026-10-26T09:34:30.677264Z"}

…/session21-python ❯ curl -s --resolve taskboard.local:18420:127.0.0.1 http://taskboard.local:18420/ | head -12
<!doctype html><html><head><meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1.0"/><title>TaskBoard</title>  <script type="module" crossorigin src="/assets/index-CnYUJSM1.js"></script>
  <link rel="stylesheet" crossorigin href="/assets/index-DkMuKOF6.css">
</head><body><div id="root"></div></body></html>
```

![TaskBoard via Ingress on kind](taskboard-k8s-ingress.png)

## HPA + load test

`values-dev.yaml` disables the HPA, so the release was upgraded again with the default values (HPA on) and Ingress enabled:

```bash
…/session21-python ❯ helm upgrade --install taskboard ./helm/taskboard -n taskboard --set ingress.enabled=true --set backend.image=taskboard-backend --set backend.tag=local --set frontend.image=taskboard-frontend --set frontend.tag=local
Release "taskboard" has been upgraded. Happy Helming!
NAME: taskboard
LAST DEPLOYED: Mon Oct 26 15:04:46 2026
NAMESPACE: taskboard
STATUS: deployed
REVISION: 4
DESCRIPTION: Upgrade complete
TEST SUITE: None

…/session21-python ❯ helm history taskboard -n taskboard
REVISION	UPDATED                 	STATUS    	CHART          	APP VERSION	DESCRIPTION     
1       	Mon Oct 26 15:00:33 2026	superseded	taskboard-1.0.0	1.0.0      	Install complete
2       	Mon Oct 26 15:02:29 2026	superseded	taskboard-1.0.0	1.0.0      	Upgrade complete
3       	Mon Oct 26 15:04:10 2026	superseded	taskboard-1.0.0	1.0.0      	Upgrade complete
4       	Mon Oct 26 15:04:46 2026	deployed  	taskboard-1.0.0	1.0.0      	Upgrade complete

…/session21-python ❯ kubectl top pods -n taskboard
NAME                                           CPU(cores)   MEMORY(bytes)   
taskboard-frontend-6f9c4b5fcc-4tlzd            1m           7Mi             
taskboard-frontend-6f9c4b5fcc-4vvmz            1m           7Mi             
taskboard-postgres-755b4497b-dqcws             2m           33Mi            
taskboard-taskboard-backend-7d8fb7697c-6wh9l   2m           62Mi            
taskboard-taskboard-backend-7d8fb7697c-gg9dv   2m           61Mi            

…/session21-python ❯ kubectl get hpa -n taskboard
NAME                REFERENCE                                TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
taskboard-backend   Deployment/taskboard-taskboard-backend   cpu: 2%/60%   2         6         2          55s

…/session21-python ❯ cat scripts/load-test.sh
#!/usr/bin/env bash
set -euo pipefail
URL="${URL:-http://taskboard.local/api/health}"
for i in $(seq 1 500); do curl -s "$URL" >/dev/null || true; done
echo "Load test completed"
```

The script's default URL doesn't work: `taskboard.local` doesn't resolve from the host, and `/api/health` doesn't exist (health is `/health`). Without DNS every curl took the 5 s resolver timeout, so the first run was stopped. A port-forward and a real endpoint work:

```bash
…/session21-python ❯ curl -sS -m 10 http://taskboard.local/api/health; echo "curl exit: $?"
curl: (6) Could not resolve host: taskboard.local
curl exit: 6

…/session21-python ❯ curl -s -o /dev/null -w "%{http_code}\n" --resolve taskboard.local:18420:127.0.0.1 http://taskboard.local:18420/api/health
404

…/session21-python ❯ curl -s -o /dev/null -w "%{http_code}\n" --resolve taskboard.local:18420:127.0.0.1 http://taskboard.local:18420/health
200

…/session21-python ❯ kubectl port-forward svc/taskboard-taskboard-backend -n taskboard 18421:8000 &
Forwarding from 127.0.0.1:18421 -> 8000
Forwarding from [::1]:18421 -> 8000

…/session21-python ❯ time URL=http://localhost:18421/api/tasks bash scripts/load-test.sh
Load test completed

real	0m4.576s
user	0m1.381s
sys	0m1.337s
```

500 sequential curls through a port-forward don't load the CPU much, so an in-cluster load generator was used to show the HPA scaling:

```bash
…/session21-python ❯ kubectl create deployment load-generator -n taskboard --image=busybox:1.36 --replicas=3 -- /bin/sh -c "while true; do wget -q -O- http://taskboard-taskboard-backend:8000/api/tasks/stats >/dev/null; done"
deployment.apps/load-generator created

…/session21-python ❯ kubectl get hpa -n taskboard
NAME                REFERENCE                                TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
taskboard-backend   Deployment/taskboard-taskboard-backend   cpu: 269%/60%   2         6         6          7m22s

…/session21-python ❯ kubectl get hpa -n taskboard
NAME                REFERENCE                                TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
taskboard-backend   Deployment/taskboard-taskboard-backend   cpu: 258%/60%   2         6         6          8m22s

…/session21-python ❯ kubectl top pods -n taskboard
NAME                                           CPU(cores)   MEMORY(bytes)   
load-generator-5cb989b7d9-kknw4                289m         5Mi             
load-generator-5cb989b7d9-zqr27                308m         5Mi             
load-generator-5cb989b7d9-zxw2g                298m         5Mi             
taskboard-frontend-6f9c4b5fcc-4tlzd            1m           7Mi             
taskboard-frontend-6f9c4b5fcc-4vvmz            1m           7Mi             
taskboard-postgres-755b4497b-dqcws             198m         65Mi            
taskboard-taskboard-backend-7d8fb7697c-6wh9l   264m         64Mi            
taskboard-taskboard-backend-7d8fb7697c-8mmkf   251m         64Mi            
taskboard-taskboard-backend-7d8fb7697c-9f6s5   256m         63Mi            
taskboard-taskboard-backend-7d8fb7697c-fcxjc   265m         63Mi            
taskboard-taskboard-backend-7d8fb7697c-gg9dv   258m         63Mi            
taskboard-taskboard-backend-7d8fb7697c-jfstn   258m         64Mi            

…/session21-python ❯ kubectl get pods -n taskboard -l app=taskboard-backend
NAME                                           READY   STATUS    RESTARTS      AGE
taskboard-taskboard-backend-7d8fb7697c-6wh9l   1/1     Running   4 (11m ago)   12m
taskboard-taskboard-backend-7d8fb7697c-8mmkf   1/1     Running   0             113s
taskboard-taskboard-backend-7d8fb7697c-9f6s5   1/1     Running   0             2m8s
taskboard-taskboard-backend-7d8fb7697c-fcxjc   1/1     Running   0             113s
taskboard-taskboard-backend-7d8fb7697c-gg9dv   1/1     Running   0             8m23s
taskboard-taskboard-backend-7d8fb7697c-jfstn   1/1     Running   0             113s
```

## Monitoring (Prometheus + Grafana)

```bash
…/session21-python ❯ kubectl get servicemonitor -n taskboard
NAME                          AGE
taskboard-taskboard-backend   12m

…/session21-python ❯ kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 18422:9090 &
Forwarding from 127.0.0.1:18422 -> 9090
Forwarding from [::1]:18422 -> 9090

…/session21-python ❯ curl -s localhost:18422/api/v1/targets | jq -r '.data.activeTargets[] | select(.labels.namespace=="taskboard") | [.scrapePool, .labels.pod, .health] | @tsv'
serviceMonitor/taskboard/taskboard-taskboard-backend/0	taskboard-taskboard-backend-7d8fb7697c-gg9dv	up
serviceMonitor/taskboard/taskboard-taskboard-backend/0	taskboard-taskboard-backend-7d8fb7697c-9f6s5	up
serviceMonitor/taskboard/taskboard-taskboard-backend/0	taskboard-taskboard-backend-7d8fb7697c-jfstn	up
serviceMonitor/taskboard/taskboard-taskboard-backend/0	taskboard-taskboard-backend-7d8fb7697c-8mmkf	up
serviceMonitor/taskboard/taskboard-taskboard-backend/0	taskboard-taskboard-backend-7d8fb7697c-fcxjc	up
serviceMonitor/taskboard/taskboard-taskboard-backend/0	taskboard-taskboard-backend-7d8fb7697c-6wh9l	up

…/session21-python ❯ curl -s localhost:18422/api/v1/query --data-urlencode 'query=sum by (handler) (rate(http_requests_total{namespace="taskboard"}[2m]))' | jq -r '.data.result[] | "\(.metric.handler)  \(.value[1])"'
/ready  0.5901832539682539
/health  0.3552944444444444
/metrics  0.37196111111111113
/api/tasks/stats  693.1175744444445
/api/tasks  0
none  0

…/session21-python ❯ curl -s localhost:18422/api/v1/query --data-urlencode 'query=kube_horizontalpodautoscaler_status_current_replicas{namespace="taskboard"}' | jq -r '.data.result[] | "\(.metric.horizontalpodautoscaler) current_replicas=\(.value[1])"'
taskboard-backend current_replicas=6
```

![Prometheus targets from the TaskBoard ServiceMonitor](prometheus-taskboard-targets.png)

![PromQL request rate by handler during the load test](prometheus-taskboard-rate.png)

```bash
…/session21-python ❯ kubectl --namespace monitoring get secrets kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
****

…/session21-python ❯ kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 18423:80 &
Forwarding from 127.0.0.1:18423 -> 3000
Forwarding from [::1]:18423 -> 3000

…/session21-python ❯ curl -s -u "admin:$GF_PW" localhost:18423/api/datasources | jq -c ".[] | {name, uid, type, url}"
{"name":"Alertmanager","uid":"alertmanager","type":"alertmanager","url":"http://kube-prometheus-stack-alertmanager.monitoring:9093/"}
{"name":"Prometheus","uid":"prometheus","type":"prometheus","url":"http://kube-prometheus-stack-prometheus.monitoring:9090/"}

…/session21-python ❯ curl -s -u "admin:$GF_PW" -X POST localhost:18423/api/dashboards/db -H "Content-Type: application/json" -d @monitoring-dashboard.json | jq
{
  "folderUid": "",
  "id": 2465945710653440,
  "slug": "taskboard-backend",
  "status": "success",
  "uid": "taskboard",
  "url": "/d/taskboard/taskboard-backend",
  "version": 1
}

…/session21-python ❯ kubectl delete deployment load-generator -n taskboard
deployment.apps "load-generator" deleted from taskboard namespace
```

![Grafana TaskBoard dashboard: request rate, p95 latency, CPU, HPA replicas](grafana-taskboard-dashboard.png)

## Troubleshooting lab: broken image

```bash
…/session21-python ❯ kubectl apply -f troubleshooting/broken-image.yaml
deployment.apps/taskboard-broken-image created

…/session21-python ❯ kubectl get pods -n taskboard -l app=broken-image
NAME                                      READY   STATUS         RESTARTS   AGE
taskboard-broken-image-6669966b5b-g5cc6   0/1     ErrImagePull   0          40s

…/session21-python ❯ kubectl describe pod taskboard-broken-image-6669966b5b-g5cc6 -n taskboard | sed -n '/^Containers:/,/^Conditions:/p;/^Events:/,$p'
Containers:
  backend:
    Container ID:   
    Image:          ghcr.io/example/taskboard-backend:does-not-exist
    Image ID:       
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ErrImagePull
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rh47z (ro)
Conditions:
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  40s                default-scheduler  Successfully assigned taskboard/taskboard-broken-image-6669966b5b-g5cc6 to session21-control-plane
  Normal   Pulling    25s (x2 over 39s)  kubelet            spec.containers{backend}: Pulling image "ghcr.io/example/taskboard-backend:does-not-exist"
  Warning  Failed     24s (x2 over 39s)  kubelet            spec.containers{backend}: Failed to pull image "ghcr.io/example/taskboard-backend:does-not-exist": failed to pull and unpack image "ghcr.io/example/taskboard-backend:does-not-exist": failed to resolve reference "ghcr.io/example/taskboard-backend:does-not-exist": failed to authorize: failed to fetch anonymous token: unexpected status from GET request to https://ghcr.io/token?scope=repository%3Aexample%2Ftaskboard-backend%3Apull&service=ghcr.io: 403 Forbidden
  Warning  Failed     24s (x2 over 39s)  kubelet            spec.containers{backend}: Error: ErrImagePull
  Normal   BackOff    11s (x2 over 38s)  kubelet            spec.containers{backend}: Back-off pulling image "ghcr.io/example/taskboard-backend:does-not-exist"
  Warning  Failed     11s (x2 over 38s)  kubelet            spec.containers{backend}: Error: ImagePullBackOff

…/session21-python ❯ kubectl get events -n taskboard --sort-by=.lastTimestamp --field-selector involvedObject.kind=Pod | grep broken-image | tail -6
40s         Normal    Scheduled   pod/taskboard-broken-image-6669966b5b-g5cc6        Successfully assigned taskboard/taskboard-broken-image-6669966b5b-g5cc6 to session21-control-plane
25s         Normal    Pulling     pod/taskboard-broken-image-6669966b5b-g5cc6        Pulling image "ghcr.io/example/taskboard-backend:does-not-exist"
24s         Warning   Failed      pod/taskboard-broken-image-6669966b5b-g5cc6        Error: ErrImagePull
24s         Warning   Failed      pod/taskboard-broken-image-6669966b5b-g5cc6        Failed to pull image "ghcr.io/example/taskboard-backend:does-not-exist": failed to pull and unpack image "ghcr.io/example/taskboard-backend:does-not-exist": failed to resolve reference "ghcr.io/example/taskboard-backend:does-not-exist": failed to authorize: failed to fetch anonymous token: unexpected status from GET request to https://ghcr.io/token?scope=repository%3Aexample%2Ftaskboard-backend%3Apull&service=ghcr.io: 403 Forbidden
11s         Normal    BackOff     pod/taskboard-broken-image-6669966b5b-g5cc6        Back-off pulling image "ghcr.io/example/taskboard-backend:does-not-exist"
11s         Warning   Failed      pod/taskboard-broken-image-6669966b5b-g5cc6        Error: ImagePullBackOff
```

Diagnosis: `ErrImagePull` / `ImagePullBackOff`, because the image `ghcr.io/example/taskboard-backend:does-not-exist` can't be pulled. Fix: point the deployment at a real image (and give it the DB URL):

```bash
…/session21-python ❯ kubectl set image deployment/taskboard-broken-image backend=taskboard-backend:local -n taskboard
deployment.apps/taskboard-broken-image image updated

…/session21-python ❯ kubectl set env deployment/taskboard-broken-image -n taskboard DATABASE_URL=postgresql+psycopg://taskboard:****@taskboard-postgres:5432/taskboard
deployment.apps/taskboard-broken-image env updated

…/session21-python ❯ kubectl get pods -n taskboard -l app=broken-image
NAME                                      READY   STATUS        RESTARTS   AGE
taskboard-broken-image-558975d64-m58wb    0/1     Terminating   0          1s
taskboard-broken-image-5c49664495-ftcpn   1/1     Terminating   0          1s
taskboard-broken-image-66c4789f88-f7kkt   1/1     Running       0          1s

…/session21-python ❯ kubectl delete -f troubleshooting/broken-image.yaml
deployment.apps "taskboard-broken-image" deleted from taskboard namespace
```

## Troubleshooting lab: broken Service

```bash
…/session21-python ❯ kubectl apply -f troubleshooting/broken-service.yaml
service/broken-service created

…/session21-python ❯ kubectl get svc -n taskboard
NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
backend                       ClusterIP   10.96.61.237    <none>        8000/TCP   12m
broken-service                ClusterIP   10.96.186.91    <none>        8080/TCP   0s
taskboard-frontend            ClusterIP   10.96.174.99    <none>        80/TCP     14m
taskboard-postgres            ClusterIP   10.96.108.216   <none>        5432/TCP   14m
taskboard-taskboard-backend   ClusterIP   10.96.99.88     <none>        8000/TCP   14m

…/session21-python ❯ kubectl get endpoints -n taskboard
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                          ENDPOINTS                                                        AGE
backend                       10.244.0.13:8000,10.244.0.25:8000,10.244.0.30:8000 + 3 more...   12m
broken-service                <none>                                                           0s
taskboard-frontend            10.244.0.19:80,10.244.0.26:80                                    14m
taskboard-postgres            10.244.0.17:5432                                                 14m
taskboard-taskboard-backend   10.244.0.13:8000,10.244.0.25:8000,10.244.0.30:8000 + 3 more...   14m

…/session21-python ❯ kubectl get pods -n taskboard --show-labels
NAME                                           READY   STATUS        RESTARTS      AGE     LABELS
taskboard-broken-image-66c4789f88-f7kkt        1/1     Terminating   0             9s      app=broken-image,pod-template-hash=66c4789f88
taskboard-frontend-6f9c4b5fcc-4tlzd            1/1     Running       0             10m     app=taskboard-frontend,pod-template-hash=6f9c4b5fcc
taskboard-frontend-6f9c4b5fcc-4vvmz            1/1     Running       0             12m     app=taskboard-frontend,pod-template-hash=6f9c4b5fcc
taskboard-postgres-755b4497b-dqcws             1/1     Running       0             14m     app=taskboard-postgres,pod-template-hash=755b4497b
taskboard-taskboard-backend-7d8fb7697c-6wh9l   1/1     Running       4 (13m ago)   14m     app=taskboard-backend,pod-template-hash=7d8fb7697c
taskboard-taskboard-backend-7d8fb7697c-8mmkf   1/1     Running       0             3m55s   app=taskboard-backend,pod-template-hash=7d8fb7697c
taskboard-taskboard-backend-7d8fb7697c-9f6s5   1/1     Running       0             4m10s   app=taskboard-backend,pod-template-hash=7d8fb7697c
taskboard-taskboard-backend-7d8fb7697c-fcxjc   1/1     Running       0             3m55s   app=taskboard-backend,pod-template-hash=7d8fb7697c
taskboard-taskboard-backend-7d8fb7697c-gg9dv   1/1     Running       0             10m     app=taskboard-backend,pod-template-hash=7d8fb7697c
taskboard-taskboard-backend-7d8fb7697c-jfstn   1/1     Running       0             3m55s   app=taskboard-backend,pod-template-hash=7d8fb7697c

…/session21-python ❯ kubectl describe svc broken-service -n taskboard | grep -E "Selector|Endpoints|Port"
Selector:                 app=label-that-does-not-exist
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
Endpoints:                

…/session21-python ❯ kubectl run curl-test -n taskboard --rm -i --restart=Never --image=busybox:1.36 -- wget -q -T 3 -O- http://broken-service:8080/health; echo "exit: $?"
All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.
wget: can't connect to remote host (10.96.186.91): Connection refused
pod "curl-test" deleted from taskboard namespace
pod taskboard/curl-test terminated (Error)
exit: 1
```

Diagnosis: the selector `app=label-that-does-not-exist` matches no pods, so there are no endpoints and connections are refused. Fix: select `app=taskboard-backend` and target the container port 8000:

```bash
…/session21-python ❯ kubectl patch svc broken-service -n taskboard --type merge -p '{"spec":{"selector":{"app":"taskboard-backend"},"ports":[{"port":8080,"targetPort":8000}]}}'
service/broken-service patched

…/session21-python ❯ kubectl get endpoints broken-service -n taskboard
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME             ENDPOINTS                                                        AGE
broken-service   10.244.0.13:8000,10.244.0.25:8000,10.244.0.30:8000 + 3 more...   4s

…/session21-python ❯ kubectl run curl-test -n taskboard --rm -i --restart=Never --image=busybox:1.36 -- wget -q -T 3 -O- http://broken-service:8080/health; echo
{"status":"UP"}All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.
warning: couldn't attach to pod/curl-test, falling back to streaming logs: unable to upgrade connection: container curl-test not found in pod curl-test_taskboard
{"status":"UP"}pod "curl-test" deleted from taskboard namespace

…/session21-python ❯ kubectl delete -f troubleshooting/broken-service.yaml
service "broken-service" deleted from taskboard namespace
```

## Final demo checks

```bash
…/session21-python ❯ kubectl get hpa -n taskboard
NAME                REFERENCE                                TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
taskboard-backend   Deployment/taskboard-taskboard-backend   cpu: 8%/60%   2         6         6          10m

…/session21-python ❯ kubectl get pods -n taskboard
NAME                                           READY   STATUS        RESTARTS      AGE
taskboard-broken-image-66c4789f88-f7kkt        1/1     Terminating   0             24s
taskboard-frontend-6f9c4b5fcc-4tlzd            1/1     Running       0             10m
taskboard-frontend-6f9c4b5fcc-4vvmz            1/1     Running       0             12m
taskboard-postgres-755b4497b-dqcws             1/1     Running       0             14m
taskboard-taskboard-backend-7d8fb7697c-6wh9l   1/1     Running       4 (14m ago)   14m
taskboard-taskboard-backend-7d8fb7697c-8mmkf   1/1     Running       0             4m10s
taskboard-taskboard-backend-7d8fb7697c-9f6s5   1/1     Running       0             4m25s
taskboard-taskboard-backend-7d8fb7697c-fcxjc   1/1     Running       0             4m10s
taskboard-taskboard-backend-7d8fb7697c-gg9dv   1/1     Running       0             10m
taskboard-taskboard-backend-7d8fb7697c-jfstn   1/1     Running       0             4m10s

…/session21-python ❯ kubectl get svc -n taskboard
NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
backend                       ClusterIP   10.96.61.237    <none>        8000/TCP   12m
taskboard-frontend            ClusterIP   10.96.174.99    <none>        80/TCP     14m
taskboard-postgres            ClusterIP   10.96.108.216   <none>        5432/TCP   14m
taskboard-taskboard-backend   ClusterIP   10.96.99.88     <none>        8000/TCP   14m

…/session21-python ❯ helm list -n taskboard
NAME     	NAMESPACE	REVISION	UPDATED                              	STATUS  	CHART          	APP VERSION
taskboard	taskboard	4       	2026-10-26 15:04:46.7315509 +0530 IST	deployed	taskboard-1.0.0	1.0.0      

…/session21-python ❯ kubectl get ingress -n taskboard
NAME        CLASS   HOSTS             ADDRESS     PORTS   AGE
taskboard   nginx   taskboard.local   localhost   80      11m

…/session21-python ❯ kubectl get all -n monitoring | head -20
NAME                                                            READY   STATUS    RESTARTS   AGE
pod/alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0          16m
pod/kube-prometheus-stack-grafana-69bcd45576-tdknr              3/3     Running   0          17m
pod/kube-prometheus-stack-kube-state-metrics-78dc75b868-nkm5z   1/1     Running   0          17m
pod/kube-prometheus-stack-operator-975598bdf-rsckf              1/1     Running   0          17m
pod/kube-prometheus-stack-prometheus-node-exporter-c46xz        1/1     Running   0          17m
pod/prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   0          16m

NAME                                                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/alertmanager-operated                            ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP   16m
service/kube-prometheus-stack-alertmanager               ClusterIP   10.96.154.231   <none>        9093/TCP,8080/TCP            17m
service/kube-prometheus-stack-grafana                    ClusterIP   10.96.143.70    <none>        80/TCP                       17m
service/kube-prometheus-stack-kube-state-metrics         ClusterIP   10.96.237.64    <none>        8080/TCP                     17m
service/kube-prometheus-stack-operator                   ClusterIP   10.96.52.134    <none>        443/TCP                      17m
service/kube-prometheus-stack-prometheus                 ClusterIP   10.96.182.254   <none>        9090/TCP,8080/TCP            17m
service/kube-prometheus-stack-prometheus-node-exporter   ClusterIP   10.96.6.37      <none>        9100/TCP                     17m
service/prometheus-operated                              ClusterIP   None            <none>        9090/TCP                     16m

NAME                                                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/kube-prometheus-stack-prometheus-node-exporter   1         1         1       1            1           kubernetes.io/os=linux   17m
```

## HPA scale-down and Helm rollback

```bash
…/session21-python ❯ kubectl get hpa -n taskboard
NAME                REFERENCE                                TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
taskboard-backend   Deployment/taskboard-taskboard-backend   cpu: 3%/60%   2         6         2          15m

…/session21-python ❯ kubectl describe hpa taskboard-backend -n taskboard | sed -n "/^Events:/,\$p"
Events:
  Type    Reason             Age    From                       Message
  ----    ------             ----   ----                       -------
  Normal  SuccessfulRescale  9m31s  horizontal-pod-autoscaler  New size: 3; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  9m16s  horizontal-pod-autoscaler  New size: 6; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  31s    horizontal-pod-autoscaler  New size: 2; reason: All metrics below target

…/session21-python ❯ helm rollback taskboard 3 -n taskboard
level=WARN msg="Rollback \"taskboard\" failed: conflict occurred while applying object taskboard/taskboard-taskboard-backend apps/v1, Kind=Deployment: Apply failed with 1 conflict: conflict with \"kube-controller-manager\" with subresource \"scale\" using apps/v1: .spec.replicas"
Error: conflict occurred while applying object taskboard/taskboard-taskboard-backend apps/v1, Kind=Deployment: Apply failed with 1 conflict: conflict with "kube-controller-manager" with subresource "scale" using apps/v1: .spec.replicas

…/session21-python ❯ helm history taskboard -n taskboard
REVISION	UPDATED                 	STATUS    	CHART          	APP VERSION	DESCRIPTION                                                                                                                                                                                                                                                      
1       	Mon Oct 26 15:00:33 2026	superseded	taskboard-1.0.0	1.0.0      	Install complete                                                                                                                                                                                                                                                 
2       	Mon Oct 26 15:02:29 2026	superseded	taskboard-1.0.0	1.0.0      	Upgrade complete                                                                                                                                                                                                                                                 
3       	Mon Oct 26 15:04:10 2026	superseded	taskboard-1.0.0	1.0.0      	Upgrade complete                                                                                                                                                                                                                                                 
4       	Mon Oct 26 15:04:46 2026	superseded	taskboard-1.0.0	1.0.0      	Upgrade complete                                                                                                                                                                                                                                                 
5       	Mon Oct 26 15:20:33 2026	failed    	taskboard-1.0.0	1.0.0      	Rollback "taskboard" failed: conflict occurred while applying object taskboard/taskboard-taskboard-backend apps/v1, Kind=Deployment: Apply failed with 1 conflict: conflict with "kube-controller-manager" with subresource "scale" using apps/v1: .spec.replicas
```

Helm 4 uses server-side apply, and `.spec.replicas` is now owned by the HPA (`kube-controller-manager`, `scale` subresource), so the rollback conflicts. Retried with `--force-conflicts`:

```bash
…/session21-python ❯ kubectl get deploy,hpa -n taskboard
NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/taskboard-frontend            1/1     1            1           20m
deployment.apps/taskboard-postgres            1/1     1            1           20m
deployment.apps/taskboard-taskboard-backend   2/2     2            2           20m

NAME                                                    REFERENCE                                TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/taskboard-backend   Deployment/taskboard-taskboard-backend   cpu: 2%/60%   2         6         2          16m

…/session21-python ❯ helm rollback taskboard 3 -n taskboard --force-conflicts
Rollback was a success! Happy Helming!

…/session21-python ❯ helm history taskboard -n taskboard | cut -c1-120
REVISION	UPDATED                 	STATUS    	CHART          	APP VERSION	DESCRIPTION                                    
1       	Mon Oct 26 15:00:33 2026	superseded	taskboard-1.0.0	1.0.0      	Install complete                               
2       	Mon Oct 26 15:02:29 2026	superseded	taskboard-1.0.0	1.0.0      	Upgrade complete                               
3       	Mon Oct 26 15:04:10 2026	superseded	taskboard-1.0.0	1.0.0      	Upgrade complete                               
4       	Mon Oct 26 15:04:46 2026	superseded	taskboard-1.0.0	1.0.0      	Upgrade complete                               
5       	Mon Oct 26 15:20:33 2026	failed    	taskboard-1.0.0	1.0.0      	Rollback "taskboard" failed: conflict occurred 
6       	Mon Oct 26 15:20:58 2026	deployed  	taskboard-1.0.0	1.0.0      	Rollback to 3                                  

…/session21-python ❯ kubectl get deploy,hpa,ingress -n taskboard
NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/taskboard-frontend            1/1     1            1           20m
deployment.apps/taskboard-postgres            1/1     1            1           20m
deployment.apps/taskboard-taskboard-backend   1/2     2            1           20m

NAME                                                    REFERENCE                                TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/taskboard-backend   Deployment/taskboard-taskboard-backend   cpu: <unknown>/60%   2         6         1          16m

NAME                                  CLASS   HOSTS             ADDRESS     PORTS   AGE
ingress.networking.k8s.io/taskboard   nginx   taskboard.local   localhost   80      17m
```

The rolled-back manifest (revision 3, `values-dev.yaml`) has no HPA, but the HPA object from revision 4 was left in the cluster (still Helm-labelled) after the failed rollback. Removed it by hand:

```bash
…/session21-python ❯ helm get manifest taskboard -n taskboard | grep -E "^kind:" | sort | uniq -c
      3 kind: Deployment
      1 kind: Ingress
      1 kind: PersistentVolumeClaim
      1 kind: Secret
      4 kind: Service
      1 kind: ServiceMonitor

…/session21-python ❯ kubectl get hpa taskboard-backend -n taskboard -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}{" "}{.metadata.labels.app\.kubernetes\.io/managed-by}{"\n"}'
taskboard Helm

…/session21-python ❯ kubectl delete hpa taskboard-backend -n taskboard
horizontalpodautoscaler.autoscaling "taskboard-backend" deleted from taskboard namespace

…/session21-python ❯ kubectl get deploy,hpa -n taskboard
NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/taskboard-frontend            1/1     1            1           20m
deployment.apps/taskboard-postgres            1/1     1            1           20m
deployment.apps/taskboard-taskboard-backend   2/2     2            2           20m
```

## Cleanup

```bash
…/session21-python ❯ kind delete cluster --name session21 --kubeconfig $KUBECONFIG
Deleting cluster "session21" ...
Deleted nodes: ["session21-control-plane"]
```

## Not run

- `git push` / GHCR push / CI deploy job: these need GitHub access and a real cluster. The CI test, build and scan steps were run locally (above), and the deploy step was done with Helm on kind.
- `terraform apply` / `destroy`: it would create a billable EKS cluster and NAT gateway, so it was planned only.
