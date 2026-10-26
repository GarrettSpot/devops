# 16

CI/CD with GitHub Actions, done in my own repo [GarrettSpot/gitops-demo](https://github.com/GarrettSpot/gitops-demo).

> **Note:** the workflows below are in a local working copy of the repo and have **not been pushed yet**, so nothing has run on GitHub Actions. Every job's steps were **executed locally (not yet run on GitHub Actions)** on my Linux machine, and the output below is from those local runs.

## CI vs CD

- **CI (Continuous Integration):** every push/PR is automatically built, linted and tested.
- **Continuous Delivery:** after CI passes, the artifact is always *deployable*, but production needs a manual approval.
- **Continuous Deployment:** after CI passes, it goes to production automatically.

```bash
…/cicd/sim ❯ ./ci_simulation.sh
[INFO] Starting CI simulation...
[INFO] Step 1: Pulling latest source code from git...
[PASS] Code checkout successful: commit 8f9b2d1
[INFO] Step 2: Setting up runtime environment...
Python 3.14.7
[INFO] Step 3: Running linter checks (flake8)...
[PASS] Zero style violations found
[INFO] Step 4: Running automated unit tests (pytest)...
[PASS] 14 unit tests executed: 14 passed, 0 failed
[INFO] Step 5: Calculating code coverage...
[PASS] Coverage: 92.4% (threshold: 80%)
[INFO] CI Pipeline Succeeded. Application artifact is verified and ready for CD.

…/cicd/sim ❯ ./cd_simulation.sh
[INFO] Starting CD simulation (Mode: delivery)...
[INFO] Step 1: Packaging verified artifact into container image...
[PASS] Image built and tagged: myapp:sha-8f9b2d1
[INFO] Step 2: Running container vulnerability scan (Trivy)...
[PASS] Vulnerabilities: 0 CRITICAL, 0 HIGH
[INFO] Step 3: Deploying to Staging environment...
[PASS] Staging deployment healthy: HTTP 200 returned from /health
[INFO] Continuous Delivery mode active: Ready for manual approval gate.
[INFO] Awaiting operator sign-off before production traffic shift.

…/cicd/sim ❯ ./cd_simulation.sh deployment
[INFO] Starting CD simulation (Mode: deployment)...
[INFO] Step 1: Packaging verified artifact into container image...
[PASS] Image built and tagged: myapp:sha-8f9b2d1
[INFO] Step 2: Running container vulnerability scan (Trivy)...
[PASS] Vulnerabilities: 0 CRITICAL, 0 HIGH
[INFO] Step 3: Deploying to Staging environment...
[PASS] Staging deployment healthy: HTTP 200 returned from /health
[INFO] Continuous Deployment mode active: Auto-promoting to Production...
[PASS] Production deployment complete: Traffic migrated with zero downtime.
```

## Pipeline Concepts

Pipeline = **stages** (source → build → verify → package → deploy). A stage has **jobs**, a job has **steps**. Jobs can run sequentially (`needs:`) or in parallel.

```bash
…/cicd/sim ❯ ./pipeline_stages.sh
=========================================
 CI/CD Pipeline Execution Demonstration
=========================================
[STAGE 1] Source Checkout
  - Pulling repository branch: main
  - HEAD commit: e4a10c8
  - Checkout status: [PASS]
[STAGE 2] Build & Dependencies
  - Resolving application dependencies
  - Compiling assets
  - Build status: [PASS]
[STAGE 3] Parallel Quality Gates
  - Sub-task A: Running Unit Tests & Coverage...
  - Sub-task B: Running Static Code Analysis (Lint)...
  - Sub-task C: Scanning for Credential Leaks...
  - Quality Gates status: [ALL PASSED]
[STAGE 4] Artifact Generation
  - Assembling distributable package: dist/app.tar.gz
  - Generating test results: reports/junit.xml
  - Artifacts stored: [PASS]
[STAGE 5] Deployment
  - Validating target cluster connectivity
  - Performing rolling deployment
  - Deployment status: [PASS]
=========================================
 Pipeline Finished Successfully in 2.1s
=========================================
```

## GitHub Actions in gitops-demo

Workflows live in `.github/workflows/*.yml`. The repo's `app/` folder is the path Argo CD syncs (`argocd-application.yaml` → `path: app`), so I kept the CI code out of it: the session 16 Python app goes in `calculator/` and the session 17 app in `devsecops/`. Each workflow uses `paths:` filters and `working-directory` so it only runs for its own folder.

```bash
…/cicd/gitops-demo main ❯ git status --short
?? .github/
?? .gitignore
?? calculator/
?? devsecops/

…/cicd/gitops-demo main ❯ find . -path ./.git -prune -o -type f -print | sort
./app/argocd-application.yaml
./app/deployment.yaml
./app/service.yaml
./calculator/app/calculator.py
./calculator/app/__init__.py
./calculator/build.sh
./calculator/pytest.ini
./calculator/requirements.txt
./calculator/tests/test_calculator.py
./devsecops/app/app.py
./devsecops/app/__init__.py
./devsecops/app/static/css/styles.css
./devsecops/app/static/js/main.js
./devsecops/app/templates/index.html
./devsecops/Dockerfile
./devsecops/.dockerignore
./devsecops/k8s/deployment.yaml
./devsecops/k8s/service.yaml
./devsecops/pytest.ini
./devsecops/requirements-dev.txt
./devsecops/requirements.txt
./devsecops/tests/test_app.py
./.github/workflows/ci.yml
./.github/workflows/devsecops.yml
./.github/workflows/hello.yml
./.gitignore
./README.md
```

## Workflows and Triggers

`.github/workflows/hello.yml` uses `push`, `workflow_dispatch` (manual run with a choice input), `env`, contexts (`github.*`) and a conditional step:

```yaml
name: Hello World

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: "Target environment"
        required: true
        default: staging
        type: choice
        options: [staging, production]

jobs:
  say-hello:
    runs-on: ubuntu-latest
    env:
      GLOBAL_ENV: demo-environment
    steps:
      - name: Print message
        run: echo "Hello from GitHub Actions"
      - name: Show context
        run: |
          echo "Event: ${{ github.event_name }}"
          echo "Branch: ${{ github.ref_name }} by ${{ github.actor }}"
          echo "Environment input: ${{ inputs.environment || 'n/a' }}"
          echo "Global env: $GLOBAL_ENV"
      - name: Only on main
        if: github.ref == 'refs/heads/main'
        run: echo "Running on main, commit ${{ github.sha }}"
```

Steps run locally:

```bash
…/cicd/gitops-demo main ❯ echo "Hello from GitHub Actions"
Hello from GitHub Actions

…/cicd/gitops-demo main ❯ GLOBAL_ENV=demo-environment; echo "Event: push"; echo "Branch: $(git branch --show-current) by $(git config user.name)"; echo "Environment input: n/a"; echo "Global env: $GLOBAL_ENV"; [ "$(git symbolic-ref HEAD)" = refs/heads/main ] && echo "Running on main, commit $(git rev-parse HEAD)"
Event: push
Branch: main by Adam
Environment input: n/a
Global env: demo-environment
Running on main, commit 9164d8185b872e087923e2df237f1c540dac682e
```

Other triggers: `pull_request` (PR opened/updated), `schedule` (cron, e.g. `'0 0 * * *'`), `release`, and `paths` / `paths-ignore` filters.

## Jobs, Steps, Runners and Matrix

`.github/workflows/ci.yml` is the full CI pipeline for `calculator/`:

- `lint` → `test` (matrix of Python 3.11 / 3.12 / 3.13 on `ubuntu-latest`) → `build` and `security-check` run in parallel after `test` (`needs:`).
- `uses:` runs a marketplace action (`actions/checkout`, `actions/setup-python`, `actions/upload-artifact`), `run:` runs shell commands.
- Runners: `ubuntu-latest` is GitHub-hosted. A self-hosted runner would be `runs-on: [self-hosted, linux]`.

```yaml
name: Calculator CI Pipeline

on:
  push:
    branches: [main]
    paths:
      - "calculator/**"
      - ".github/workflows/ci.yml"
  pull_request:
    branches: [main]
    paths:
      - "calculator/**"
      - ".github/workflows/ci.yml"
  workflow_dispatch:

defaults:
  run:
    working-directory: calculator

jobs:
  lint:
    name: Lint (flake8)
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source code
        uses: actions/checkout@v4
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
          cache-dependency-path: calculator/requirements.txt
      - name: Install flake8
        run: pip install flake8
      - name: Run flake8
        run: flake8 app/ tests/

  test:
    name: Test on Python ${{ matrix.python-version }}
    needs: lint
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        python-version: ["3.11", "3.12", "3.13"]
    steps:
      - name: Checkout source code
        uses: actions/checkout@v4
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      - name: Display Python version
        run: python --version
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Run tests with coverage
        run: |
          pytest -v \
            --junitxml=test-results/results.xml \
            --cov=app --cov-report=term-missing --cov-report=xml:coverage.xml
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results-py${{ matrix.python-version }}
          path: |
            calculator/test-results/
            calculator/coverage.xml
          retention-days: 7

  build:
    name: Build Application
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source code
        uses: actions/checkout@v4
      - name: Build application
        run: |
          chmod +x build.sh
          ./build.sh
      - name: Show build output
        run: cat build/build-info.txt
      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: calculator-build
          path: calculator/build/

  security-check:
    name: Security Check
    needs: test
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: .
    steps:
      - name: Checkout source code
        uses: actions/checkout@v4
      - name: Check for sensitive files
        run: |
          echo "Checking repository for common sensitive files..."
          if find . -path ./.git -prune -o -type f \( \
            -name ".env" -o -name "*.pem" -o -name "*.key" \
          \) -print | grep -q .; then
            echo "Potential sensitive file found."
            exit 1
          else
            echo "No common sensitive files found."
          fi
```

Validate the workflow YAML before pushing (actionlint in Docker + PyYAML):

```bash
…/cicd/gitops-demo main ❯ docker run --rm -v $PWD:/repo -w /repo rhysd/actionlint:latest -no-color -verbose
verbose: Linting all workflow files in repository: /repo
verbose: Detected project: /repo
verbose: Collected 3 YAML files
verbose: Linting 3 files
verbose: Linting .github/workflows/hello.yml
verbose: Using project at /repo
verbose: Linting .github/workflows/ci.yml
verbose: Using project at /repo
verbose: Linting .github/workflows/devsecops.yml
verbose: Using project at /repo
verbose: Found 0 parse errors in 0 ms for .github/workflows/ci.yml
verbose: Found 0 parse errors in 0 ms for .github/workflows/hello.yml
verbose: Found 0 parse errors in 0 ms for .github/workflows/devsecops.yml
verbose: Found total 0 errors in 29 ms for .github/workflows/hello.yml
verbose: Found total 0 errors in 39 ms for .github/workflows/devsecops.yml
verbose: Found total 0 errors in 40 ms for .github/workflows/ci.yml
verbose: Found 0 errors in 3 files

…/cicd/gitops-demo main ❯ python3 -c "import yaml,glob; [print(f, '-> jobs:', list(yaml.safe_load(open(f))['jobs'])) for f in sorted(glob.glob('.github/workflows/*.yml'))]"
.github/workflows/ci.yml -> jobs: ['lint', 'test', 'build', 'security-check']
.github/workflows/devsecops.yml -> jobs: ['test', 'sast', 'sca', 'secret-scan', 'docker-build', 'image-scan', 'push', 'deploy']
.github/workflows/hello.yml -> jobs: ['say-hello']
```

## Lint Job (flake8)

Steps executed locally (not yet run on GitHub Actions). The first run **failed**, so the job would have stopped the pipeline:

```bash
…/gitops-demo/calculator main ❯ python3 -m venv ../../venv16 && source ../../venv16/bin/activate && python --version
Python 3.14.7

…/gitops-demo/calculator main ❯ pip install -q flake8 && flake8 --version

[notice] A new release of pip is available: 26.2.1 -> 26.2.2
[notice] To update, run: pip install --upgrade pip
7.4.1 (mccabe: 0.7.0, pycodestyle: 2.15.0, pyflakes: 4.0.3) CPython 3.14.7 on
Linux

…/gitops-demo/calculator main ❯ flake8 app/ tests/
app/calculator.py:3:1: E302 expected 2 blank lines, found 1
app/calculator.py:26:1: W293 blank line contains whitespace
app/calculator.py:33:1: W293 blank line contains whitespace
app/calculator.py:34:80: E501 line too long (83 > 79 characters)
app/calculator.py:36:80: E501 line too long (98 > 79 characters)
app/calculator.py:38:1: W293 blank line contains whitespace
app/calculator.py:39:80: E501 line too long (83 > 79 characters)
app/calculator.py:40:1: W293 blank line contains whitespace
tests/test_calculator.py:3:80: E501 line too long (82 > 79 characters)
tests/test_calculator.py:5:1: E402 module level import not at top of file
tests/test_calculator.py:6:1: E402 module level import not at top of file
```

Fix: removed whitespace on blank lines, added the missing blank line before `def add`, removed the `sys.path` hack from the test (`pytest.ini` already sets `pythonpath = .`), and added a `.flake8` with `max-line-length = 100`:

```bash
…/gitops-demo/calculator main ❯ cat .flake8
[flake8]
max-line-length = 100
exclude = .venv,build

…/gitops-demo/calculator main ❯ flake8 app/ tests/ && echo 'flake8: no issues'
flake8: no issues
```

## Test Job (pytest + coverage, matrix)

Steps executed locally (not yet run on GitHub Actions), in a venv:

```bash
…/gitops-demo/calculator main ❯ pip install -q -r requirements.txt 2>&1 | grep -v notice; pip list 2>/dev/null | grep -Ei 'pytest|flake8|coverage'

coverage    7.17.0
flake8      7.3.0
pytest      8.4.2
pytest-cov  6.0.0

…/gitops-demo/calculator main ❯ pytest -v --junitxml=test-results/results.xml --cov=app --cov-report=term-missing --cov-report=xml:coverage.xml
============================= test session starts ==============================
platform linux -- Python 3.14.7, pytest-8.4.2, pluggy-1.7.0 -- /tmp/…/cicd/venv16/bin/python3
cachedir: .pytest_cache
rootdir: /tmp/…/cicd/gitops-demo/calculator
configfile: pytest.ini
testpaths: tests
plugins: cov-6.0.0
collecting ... collected 5 items

tests/test_calculator.py::test_add PASSED                                [ 20%]
tests/test_calculator.py::test_subtract PASSED                           [ 40%]
tests/test_calculator.py::test_multiply PASSED                           [ 60%]
tests/test_calculator.py::test_divide PASSED                             [ 80%]
tests/test_calculator.py::test_divide_by_zero PASSED                     [100%]

- generated xml file: /tmp/…/cicd/gitops-demo/calculator/test-results/results.xml -

---------- coverage: platform linux, python 3.14.7-final-0 -----------
Name                Stmts   Miss  Cover   Missing
-------------------------------------------------
app/__init__.py         0      0   100%
app/calculator.py      40     28    30%   23-55
-------------------------------------------------
TOTAL                  40     28    30%
Coverage XML written to file coverage.xml

============================== 5 passed in 0.03s ===============================

…/gitops-demo/calculator main ❯ ls test-results/ coverage.xml && head -3 test-results/results.xml
coverage.xml

test-results/:
results.xml
<?xml version="1.0" encoding="utf-8"?><testsuites name="pytest tests"><testsuite name="pytest" errors="0" failures="0" skipped="0" tests="5" time="0.032" timestamp="2026-10-26T14:35:57.950472+05:30" hostname="kekww"><testcase classname="tests.test_calculator" name="test_add" time="0.000" /><testcase classname="tests.test_calculator" name="test_subtract" time="0.000" /><testcase classname="tests.test_calculator" name="test_multiply" time="0.000" /><testcase classname="tests.test_calculator" name="test_divide" time="0.000" /><testcase classname="tests.test_calculator" name="test_divide_by_zero" time="0.000" /></testsuite></testsuites>
```

Matrix jobs: I ran the same steps in `python:<version>-slim` containers to stand in for the 3 matrix runners:

```bash
…/gitops-demo/calculator main ❯ docker run --rm --name cicd-py3.11 -v $PWD:/src:ro python:3.11-slim sh -c 'cp -r /src /w && cd /w && python --version && pip install -q --root-user-action=ignore --disable-pip-version-check -r requirements.txt && pytest -q -p no:cacheprovider'
Python 3.11.17
.....                                                                    [100%]
5 passed in 0.01s

…/gitops-demo/calculator main ❯ docker run --rm --name cicd-py3.12 -v $PWD:/src:ro python:3.12-slim sh -c 'cp -r /src /w && cd /w && python --version && pip install -q --root-user-action=ignore --disable-pip-version-check -r requirements.txt && pytest -q -p no:cacheprovider'
Python 3.12.15
.....                                                                    [100%]
5 passed in 0.01s

…/gitops-demo/calculator main ❯ docker run --rm --name cicd-py3.13 -v $PWD:/src:ro python:3.13-slim sh -c 'cp -r /src /w && cd /w && python --version && pip install -q --root-user-action=ignore --disable-pip-version-check -r requirements.txt && pytest -q -p no:cacheprovider'
Python 3.13.17
.....                                                                    [100%]
5 passed in 0.01s
```

(A multi-OS matrix with `macos-latest` / `windows-latest` can't be run on this Linux machine, so it is not included.)

## Build Job and Artifacts

`build.sh` copies the app into `build/` and writes `build-info.txt`; `actions/upload-artifact` uploads `calculator/build/` as `calculator-build`, and the test job uploads JUnit XML + coverage XML. Locally the artifact upload is replaced by a tarball:

```bash
…/gitops-demo/calculator main ❯ chmod +x build.sh && ./build.sh
=================================
Starting Application Build
=================================

Build files:
total 8
drwxr-xr-x 2 shohe shohe   80 Oct 26 14:36 .
drwxr-xr-x 7 shohe shohe  260 Oct 26 14:36 ..
-rw-r--r-- 1 shohe shohe  101 Oct 26 14:36 build-info.txt
-rw-r--r-- 1 shohe shohe 1445 Oct 26 14:36 calculator.py

Build completed successfully.

…/gitops-demo/calculator main ❯ cat build/build-info.txt
Application: Session 16 Calculator
Build Status: SUCCESS
Build Date: Mon Oct 26 02:36:28 PM IST 2026

…/gitops-demo/calculator main ❯ tar -czf ../../calculator-build.tgz build/ && tar -tzf ../../calculator-build.tgz
build/
build/build-info.txt
build/calculator.py

…/gitops-demo/calculator main ❯ printf '10 + 5\n9 / 0\n7 * 6\nq\n' | python app/calculator.py
Calculator Application
----------------------
Available operations: +, -, *, /
Type 'q' or 'quit' to exit.

Enter calculation (e.g., 10 + 5): Result: 15.0

Enter calculation (e.g., 10 + 5): Error: Cannot divide by zero

Enter calculation (e.g., 10 + 5): Result: 42.0

Enter calculation (e.g., 10 + 5): Goodbye!
```

## Security Check Job

Fails the pipeline (exit code 1) if a `.env`, `*.pem` or `*.key` file is in the repo. Tested by creating an empty `.env`:

```bash
…/cicd/gitops-demo main ❯ bash ../seccheck.sh
Checking repository for common sensitive files...
No common sensitive files found.

…/cicd/gitops-demo main ❯ touch .env && bash ../seccheck.sh
Checking repository for common sensitive files...
Potential sensitive file found.

…/cicd/gitops-demo main ❯ rm .env && bash ../seccheck.sh
Checking repository for common sensitive files...
No common sensitive files found.
```

## Secrets

- Stored in **Settings → Secrets and variables → Actions**, used as `${{ secrets.NAME }}`, masked as `***` in logs.
- `GITHUB_TOKEN` is created automatically for each run, e.g. `password: ${{ secrets.GITHUB_TOKEN }}` with `permissions: packages: write` to push to GHCR (used in session 17's `devsecops.yml`).
- Environment secrets (`environment: production`) can be protected with required reviewers.

## Running it on GitHub

To actually run these on GitHub Actions the files have to be committed and pushed to `GarrettSpot/gitops-demo` (not done yet):

```bash
git add .github/ .gitignore calculator/ devsecops/
git commit -m "add CI and DevSecOps workflows"
git push origin main
gh run list
gh run view <run-id> --log
```
