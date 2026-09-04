# Docker Fundamentals
```bash
~ ❯ cd pr
practice/ Projects/ 

~ ❯ cd pr
󱞩 /home/adam/practice

~/practice ❯ mkdir nodejs-app

~/practice ❯ cd nodejs-app/

…/practice/nodejs-app ❯ nvim server.js

…/practice/nodejs-app ❯ nvim dockerfile

…/practice/nodejs-app ❯ cd ..

~/practice ❯ docker build -t nodejs-app ./nodejs-app/
[+] Building 11.3s (8/8) FINISHED                                                      docker:default
 => [internal] load build definition from dockerfile                                             0.0s
 => => transferring dockerfile: 129B                                                             0.0s
 => [internal] load metadata for docker.io/library/node:22-alpine                                2.4s
 => [internal] load .dockerignore                                                                0.0s
 => => transferring context: 2B                                                                  0.0s
 => [1/3] FROM docker.io/library/node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f  8.7s
 => => resolve docker.io/library/node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f  0.0s
 => => sha256:16da5a6403776464b5bf551ef294de57da242eac594527ea551a46e7f76ac2d6 445B / 445B       0.2s
 => => sha256:a2980c1fee17dfd6263234b253955e0e9d5f38d47c0e71c001139897134899d0 1.26MB / 1.26MB   0.7s
 => => sha256:efbef6f9e333972a10ca323e700496a64e7ddcc3a6725e6afbbae52e690f4a4 52.63MB / 52.63MB  7.7s
 => => sha256:55afa1ecc21d2bb5e5045f32dafee56272ffd89860bac26f6c32123439af26a4 3.85MB / 3.85MB   3.0s
 => => extracting sha256:55afa1ecc21d2bb5e5045f32dafee56272ffd89860bac26f6c32123439af26a4        0.1s
 => => extracting sha256:efbef6f9e333972a10ca323e700496a64e7ddcc3a6725e6afbbae52e690f4a4a        0.8s
 => => extracting sha256:a2980c1fee17dfd6263234b253955e0e9d5f38d47c0e71c001139897134899d0        0.0s
 => => extracting sha256:16da5a6403776464b5bf551ef294de57da242eac594527ea551a46e7f76ac2d6        0.0s
 => [internal] load build context                                                                0.0s
 => => transferring context: 311B                                                                0.0s
 => [2/3] WORKDIR /app                                                                           0.1s
 => [3/3] COPY server.js .                                                                       0.0s
 => exporting to image                                                                           0.1s
 => => exporting layers                                                                          0.1s
 => => exporting manifest sha256:8b6bb08c53d7462b8e2e906032f297bb86b6a3e3c0bade37f7d5e287be1b94  0.0s
 => => exporting config sha256:410b25d2f19a4e102582ca55647d305df508484c69064385ff6266d06453e126  0.0s
 => => exporting attestation manifest sha256:da1a1cb0d00c58e33be67236c9bfa0a1c88342a0c73d25e543  0.0s
 => => exporting manifest list sha256:965ca414c62cd2a6bfe4eff035280556c7795b5161934dd88be612e05  0.0s
 => => naming to docker.io/library/nodejs-app:latest                                             0.0s
 => => unpacking to docker.io/library/nodejs-app:latest                                          0.0s

~/practice ❯ docker run -d --name nodejs-container -p 3001:3000 nodejs-app
959f3b8a69d4f0f9397f02c24f7d6a29edac58c6cbd9356fcb30ab139ef5da92

~/practice ❯ mkdir python-app

~/practice ❯ cd python-app/

…/practice/python-app ❯ nvim app.py

…/practice/python-app ❯ nvim dockerfile

…/practice/python-app ❯ cd ..

~/practice ❯ docker build -t python-app ./python-app
[+] Building 6.0s (8/8) FINISHED                                                       docker:default
 => [internal] load build definition from dockerfile                                             0.0s
 => => transferring dockerfile: 129B                                                             0.0s
 => [internal] load metadata for docker.io/library/python:3.13-alpine                            2.9s
 => [internal] load .dockerignore                                                                0.0s
 => => transferring context: 2B                                                                  0.0s
 => [1/3] FROM docker.io/library/python:3.13-alpine@sha256:7415fbc3c9e4979cc717d92377ab2bc7b2b4  2.8s
 => => resolve docker.io/library/python:3.13-alpine@sha256:7415fbc3c9e4979cc717d92377ab2bc7b2b4  0.0s
 => => sha256:b04626f2ffdb09c6430b484993db7c8cbecc0f67a3fce6265bb08fda7bffef2a 247B / 247B       0.3s
 => => sha256:1246c75eb338cb1302c85931f1c4b19360ecc0295730d8e6c143feefc6d875d 15.21MB / 15.21MB  2.4s
 => => sha256:a8754e842af47bb367714de3fec4bbc455aa684e0aacc1aa7e7364fbcd441 408.09kB / 408.09kB  1.2s
 => => extracting sha256:a8754e842af47bb367714de3fec4bbc455aa684e0aacc1aa7e7364fbcd4416c1        0.0s
 => => extracting sha256:1246c75eb338cb1302c85931f1c4b19360ecc0295730d8e6c143feefc6d875d3        0.3s
 => => extracting sha256:b04626f2ffdb09c6430b484993db7c8cbecc0f67a3fce6265bb08fda7bffef2a        0.0s
 => [internal] load build context                                                                0.0s
 => => transferring context: 472B                                                                0.0s
 => [2/3] WORKDIR /app                                                                           0.1s
 => [3/3] COPY app.py .                                                                          0.0s
 => exporting to image                                                                           0.1s
 => => exporting layers                                                                          0.1s
 => => exporting manifest sha256:11295557abfeb1cc41e31ac54ddb9b8b8b02902072933a203111d1a8b896c8  0.0s
 => => exporting config sha256:edccc3c5eddead5e59008bda8d32bd36171de4226030c1a1f74a13b5c22540c4  0.0s
 => => exporting attestation manifest sha256:021fa638b1f9c55d3810dfbb6cf006dc2907e582e283d33b0b  0.0s
 => => exporting manifest list sha256:3d81ab46a6cebb43b2a01eb411f410514c3c4985fbc8589aa2b758ff8  0.0s
 => => naming to docker.io/library/python-app:latest                                             0.0s
 => => unpacking to docker.io/library/python-app:latest                                          0.0s

~/practice ❯ docker run -d --name python-container -p 3002:5000 python-app
3237f30cd5cc3ee8cdff70122c621793e8da8a8144f9fe3b0fb6f4226d49e2a0

~/practice ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 20:42   devops
drwxr-xr-x     - adam  4 Sep 22:37   git_practice
drwxr-xr-x     - adam  4 Sep 22:47   git_practice_2
drwxr-xr-x     - adam  4 Sep 23:23   nodejs-app
drwxr-xr-x     - adam  4 Sep 23:25   python-app
.rw-r--r--    12 adam  4 Sep 20:06   hard.txt
lrwxrwxrwx     - adam  4 Sep 20:06   soft.txt -> original.txt

~/practice ❯ mv nodejs-app/ ./devops/5_networking_fundamentals/

~/practice ❯ mv python-app/ ./devops/5_networking_fundamentals/

~/practice ❯ cd devops

…/practice/devops ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 23:28   5_networking_fundamentals
drwxr-xr-x     - adam  4 Sep 23:15   devops

…/practice/devops ❯ cd ..

~/practice ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 23:28   devops
drwxr-xr-x     - adam  4 Sep 22:37   git_practice
drwxr-xr-x     - adam  4 Sep 22:47   git_practice_2
.rw-r--r--    12 adam  4 Sep 20:06   hard.txt
lrwxrwxrwx     - adam  4 Sep 20:06   soft.txt -> original.txt

~/practice ❯ cd devops/

…/practice/devops ❯ cd 
5_networking_fundamentals/ devops/                    

…/practice/devops ❯ cd 5_networking_fundamentals/

…/devops/5_networking_fundamentals ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 23:25   python-app
.rw-r--r--    92 adam  4 Sep 23:23  󰡯 dockerfile
.rw-r--r--   273 adam  4 Sep 23:22   server.js

…/devops/5_networking_fundamentals ❯ mv python-app ../devops/5_docker_fundamentals/

…/devops/5_networking_fundamentals ❯ mv dockerfile ../devops/5_docker_fundamentals/nodejs-app/
mv: cannot move 'dockerfile' to '../devops/5_docker_fundamentals/nodejs-app/': Not a directory

…/devops/5_networking_fundamentals ✗ mkdir ../devops/5_docker_fundamentals/nodejs-app

…/devops/5_networking_fundamentals ❯ mv dockerfile ../devops/5_docker_fundamentals/nodejs-app/

…/devops/5_networking_fundamentals ❯ mv server.js ../devops/5_docker_fundamentals/nodejs-app/

…/devops/5_networking_fundamentals ❯ cd ..

…/practice/devops ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 23:30   5_networking_fundamentals
drwxr-xr-x     - adam  4 Sep 23:15   devops

…/practice/devops ❯ rm 5_networking_fundamentals/
rm: cannot remove '5_networking_fundamentals/': Is a directory

…/practice/devops ✗ rmdir 5_networking_fundamentals/

…/practice/devops ❯ cd devops/

devops main ? ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 21:10   1_linux_fundamentals
drwxr-xr-x     - adam  4 Sep 21:14   2_shell_scripting
drwxr-xr-x     - adam  4 Sep 22:49   3_Git_Github
drwxr-xr-x     - adam  4 Sep 23:06   4_Networking
drwxr-xr-x     - adam  4 Sep 23:29   5_docker_fundamentals

devops main ? ❯ cd 5_docker_fundamentals/

devops/5_docker_fundamentals main ? ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 23:30   nodejs-app
drwxr-xr-x     - adam  4 Sep 23:25   python-app

devops/5_docker_fundamentals main ? ❯ mkdir java-app

devops/5_docker_fundamentals main ? ❯ git add nodejs-app/ python-app/

devops/5_docker_fundamentals main ❯ cd ..

devops main ❯ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   5_docker_fundamentals/nodejs-app/dockerfile
	new file:   5_docker_fundamentals/nodejs-app/server.js
	new file:   5_docker_fundamentals/python-app/app.py
	new file:   5_docker_fundamentals/python-app/dockerfile


devops main ❯ git remove python-app
git: 'remove' is not a git command. See 'git --help'.

The most similar command is
	remote

devops main ✗ git commit -m "add node-app and python-app"
[main 351a314] add node-app and python-app
 4 files changed, 45 insertions(+)
 create mode 100644 5_docker_fundamentals/nodejs-app/dockerfile
 create mode 100644 5_docker_fundamentals/nodejs-app/server.js
 create mode 100644 5_docker_fundamentals/python-app/app.py
 create mode 100644 5_docker_fundamentals/python-app/dockerfile

devops main ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 21:10   1_linux_fundamentals
drwxr-xr-x     - adam  4 Sep 21:14   2_shell_scripting
drwxr-xr-x     - adam  4 Sep 22:49   3_Git_Github
drwxr-xr-x     - adam  4 Sep 23:06   4_Networking
drwxr-xr-x     - adam  4 Sep 23:33   5_docker_fundamentals

devops main ❯ cd 5_docker_fundamentals/

devops/5_docker_fundamentals main ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 23:33   java-app
drwxr-xr-x     - adam  4 Sep 23:30   nodejs-app
drwxr-xr-x     - adam  4 Sep 23:25   python-app

devops/5_docker_fundamentals main ❯ cd java-app/

…/5_docker_fundamentals/java-app main ❯ nvim Main.java

…/5_docker_fundamentals/java-app main ? ❯ nvim Dockerfile

…/5_docker_fundamentals/java-app main ? ❯ docker build -t java-app ./java-app
[+] Building 0.0s (0/0)                                                                docker:default
ERROR: failed to build: unable to prepare context: path "./java-app" not found

…/5_docker_fundamentals/java-app main ? ✗ ls
Permissions Size User Date Modified Name
.rw-r--r--   123 adam  4 Sep 23:34   Dockerfile
.rw-r--r--   801 adam  4 Sep 23:34   Main.java

…/5_docker_fundamentals/java-app main ? ❯ cd ..

devops/5_docker_fundamentals main ? ❯ docker build -t java-app ./java-app
[+] Building 28.1s (9/9) FINISHED                                                      docker:default
 => [internal] load build definition from Dockerfile                                             0.0s
 => => transferring dockerfile: 160B                                                             0.0s
 => [internal] load metadata for docker.io/library/eclipse-temurin:21-jdk-alpine                 3.0s
 => [internal] load .dockerignore                                                                0.0s
 => => transferring context: 2B                                                                  0.0s
 => [1/4] FROM docker.io/library/eclipse-temurin:21-jdk-alpine@sha256:6ea5548706b60ac0a602eaf4  24.3s
 => => resolve docker.io/library/eclipse-temurin:21-jdk-alpine@sha256:6ea5548706b60ac0a602eaf48  0.0s
 => => sha256:d7ef08a27864ae3d6ee3399a0909e667d6fb889dd93bc8d8fa25cbde844a15e3 2.46kB / 2.46kB   0.2s
 => => sha256:e04839fa2debe7ec750a1b3926314c52ec376eb0d5ed81310e907af857ed918f 128B / 128B       0.5s
 => => sha256:8dcf1f5eca60c3a20398445d682d111c67441c56056e59a0a3a16183f9da 158.33MB / 158.33MB  22.9s
 => => sha256:80c624ebf42c48614632c25eda29ff963d8bff68cf72141f38572ff353df411 21.43MB / 21.43MB  4.1s
 => => extracting sha256:80c624ebf42c48614632c25eda29ff963d8bff68cf72141f38572ff353df4118        0.3s
 => => extracting sha256:8dcf1f5eca60c3a20398445d682d111c67441c56056e59a0a3a16183f9da46f6        1.4s
 => => extracting sha256:e04839fa2debe7ec750a1b3926314c52ec376eb0d5ed81310e907af857ed918f        0.0s
 => => extracting sha256:d7ef08a27864ae3d6ee3399a0909e667d6fb889dd93bc8d8fa25cbde844a15e3        0.0s
 => [internal] load build context                                                                0.0s
 => => transferring context: 839B                                                                0.0s
 => [2/4] WORKDIR /app                                                                           0.1s
 => [3/4] COPY Main.java .                                                                       0.0s
 => [4/4] RUN javac Main.java                                                                    0.4s
 => exporting to image                                                                           0.2s
 => => exporting layers                                                                          0.1s
 => => exporting manifest sha256:913f55290f92eb975d56e59b3beb48102c65f0ade838241a27ce626a07271e  0.0s
 => => exporting config sha256:52ac00b44e3809d29146953f4c3566567543ed39efc6fb59aa32084890df22ff  0.0s
 => => exporting attestation manifest sha256:c72faa1091a2a5d1e3271927991532964967808481c2c7a4cf  0.0s
 => => exporting manifest list sha256:327802aee97a3a60d689f05139efde25f084dda161fbc67f7100e3039  0.0s
 => => naming to docker.io/library/java-app:latest                                               0.0s
 => => unpacking to docker.io/library/java-app:latest                                            0.0s

```
```
devops/5_docker_fundamentals main ? ❯ mkdir apache-app

devops/5_docker_fundamentals main ? ❯ cd apache-app/

…/5_docker_fundamentals/apache-app main ? ❯ ls

…/5_docker_fundamentals/apache-app main ? ❯ nvim index.html

…/5_docker_fundamentals/apache-app main ? ❯ nvim dockerfile

…/5_docker_fundamentals/apache-app main ? ❯ cd ..

devops/5_docker_fundamentals main ? ❯ docker run -d --name apache-container -p 3004:80 apache-app
Unable to find image 'apache-app:latest' locally
docker: Error response from daemon: pull access denied for apache-app, repository does not exist or may require 'docker login'

Run 'docker run --help' for more information

devops/5_docker_fundamentals main ? ✗ docker run -d --name apache-container -p 3004:80 apache-app/
docker: invalid reference format

Run 'docker run --help' for more information

devops/5_docker_fundamentals main ? ✗ docker run -d --name apache-container -p 3004:80 ./apache-app
docker: invalid reference format

Run 'docker run --help' for more information

devops/5_docker_fundamentals main ? ✗ docker build -t apache-app ./apache-app
[+] Building 5.7s (7/7) FINISHED                                                       docker:default
 => [internal] load build definition from dockerfile                                             0.0s
 => => transferring dockerfile: 114B                                                             0.0s
 => [internal] load metadata for docker.io/library/httpd:2.4-alpine                              2.2s
 => [internal] load .dockerignore                                                                0.0s
 => => transferring context: 2B                                                                  0.0s
 => [internal] load build context                                                                0.0s
 => => transferring context: 169B                                                                0.0s
 => [1/2] FROM docker.io/library/httpd:2.4-alpine@sha256:1b766f17b84026429b7cb243317b142921b244  3.1s
 => => resolve docker.io/library/httpd:2.4-alpine@sha256:1b766f17b84026429b7cb243317b142921b244  0.0s
 => => sha256:ec6419fed67b69364a61620376ac3fb1a74bcd49ea9a01a14d2721ce026064b7 286B / 286B       0.2s
 => => sha256:5e8b952216466772946ad4898b1f62052b1ade358488f24149fe5ba025750338 5.81MB / 5.81MB   1.1s
 => => sha256:71af8d887193f611016b553a1cb1f98162c381cd63e47e4781341051ba40f06 11.02MB / 11.02MB  2.6s
 => => sha256:4f4fb700ef54461cfa02571ae0db9a0dc1e0cdb5577484a6d75e68dc38e8acc1 32B / 32B         0.7s
 => => sha256:f0c9ed0cf49eec26c13e77e0b85a14f91068406fef46fa2529079270b8895e02 932B / 932B       0.5s
 => => extracting sha256:f0c9ed0cf49eec26c13e77e0b85a14f91068406fef46fa2529079270b8895e02        0.0s
 => => sha256:e5ad846ecbb8d4f057feae38268d731c1cb615da29bcf5ea15e0594bb73c935a 146B / 146B       0.7s
 => => extracting sha256:e5ad846ecbb8d4f057feae38268d731c1cb615da29bcf5ea15e0594bb73c935a        0.0s
 => => extracting sha256:4f4fb700ef54461cfa02571ae0db9a0dc1e0cdb5577484a6d75e68dc38e8acc1        0.0s
 => => extracting sha256:71af8d887193f611016b553a1cb1f98162c381cd63e47e4781341051ba40f064        0.2s
 => => extracting sha256:5e8b952216466772946ad4898b1f62052b1ade358488f24149fe5ba025750338        0.1s
 => => extracting sha256:ec6419fed67b69364a61620376ac3fb1a74bcd49ea9a01a14d2721ce026064b7        0.0s
 => [2/2] COPY index.html /usr/local/apache2/htdocs/                                             0.1s
 => exporting to image                                                                           0.1s
 => => exporting layers                                                                          0.0s
 => => exporting manifest sha256:79a810270f557b828ae0b05ea48b60f3f32ad8ba280ab1107f8fe5d12f4e9d  0.0s
 => => exporting config sha256:d6b84f850298265d82767a33f7a5b208ec9fb98964c9ef18fae583ad2c6a7e55  0.0s
 => => exporting attestation manifest sha256:a4f4d2d2fd026c91b090a72a97cdfca379eb0c30d5a807d6a4  0.0s
 => => exporting manifest list sha256:b791dbbc37f9d50552dbb474a4ddf08e8b5e25d3f007706672c5b3541  0.0s
 => => naming to docker.io/library/apache-app:latest                                             0.0s
 => => unpacking to docker.io/library/apache-app:latest                                          0.0s

devops/5_docker_fundamentals main ? ❯ docker run -d --name apache-container -p 3004:80 apache-app
77c23fafe3f24290f3133731f09244bab9396f44d4a14ff0f8ad1e10f061de80

devops/5_docker_fundamentals main ? ❯ docker run -d --name java-container -p 3003:8080 java-app
a655a59c6713daef775b95f2cd9b35059ab3e7ea2f2d852930b0846e59724547

devops/5_docker_fundamentals main ? ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 23:38   apache-app
drwxr-xr-x     - adam  4 Sep 23:34   java-app
drwxr-xr-x     - adam  4 Sep 23:30   nodejs-app
drwxr-xr-x     - adam  4 Sep 23:25   python-app
.rw-r--r--   15k adam  4 Sep 23:36  󰂺 README.md

devops/5_docker_fundamentals main ? ❯ mkdir react-app

devops/5_docker_fundamentals main ? ❯ cd react-app/

…/5_docker_fundamentals/react-app main ? ❯ ls

…/5_docker_fundamentals/react-app main ? ❯ npm --version
11.19.0

…/5_docker_fundamentals/react-app main ? ❯ nvim package.json

…/5_docker_fundamentals/react-app main ? ❯ nvim index.html

…/5_docker_fundamentals/react-app main ? ❯ mkdir src

…/5_docker_fundamentals/react-app main ? ❯ nvim src/main.jsx

…/5_docker_fundamentals/react-app main ? ❯ nvim dockerfile

…/5_docker_fundamentals/react-app main ? ❯ cd ..

devops/5_docker_fundamentals main ? ❯ docker build -t react-app ./React-app
[+] Building 0.0s (0/0)                                                                docker:default
ERROR: failed to build: unable to prepare context: path "./React-app" not found

devops/5_docker_fundamentals main ? ✗ docker build -t react-app ./react-app
[+] Building 86.4s (12/13)                                                             docker:default
 => [internal] load build definition from dockerfile                                             0.0s
 => => transferring dockerfile: 231B                                                             0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                                  2.3s
 => [internal] load metadata for docker.io/library/node:22-alpine                                1.4s
 => [internal] load .dockerignore                                                                0.0s
 => => transferring context: 2B                                                                  0.0s
 => [build 1/6] FROM docker.io/library/node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb  0.0s
 => => resolve docker.io/library/node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f  0.0s
 => [internal] load build context                                                                0.0s
 => => transferring context: 999B                                                                0.0s
 => [stage-1 1/2] FROM docker.io/library/nginx:alpine@sha256:72ba65eb42c10344912a84ff42408db7d3  4.3s
 => => resolve docker.io/library/nginx:alpine@sha256:72ba65eb42c10344912a84ff42408db7d34f2feb64  0.0s
 => => sha256:6636b9fc203ce74d0b07a1d3f48cfa0151b23fa5e787232908e560673a66b55 20.52MB / 20.52MB  3.4s
 => => sha256:8f924cf5086c7b8a67e8b3e03b22851c1de8e11b0433c21904ef340d89e5014e 1.40kB / 1.40kB   0.6s
 => => sha256:51900e10fb9cfad93aa74360e5f938efcbe6d3396a380867b7561c84e5cd2daf 1.21kB / 1.21kB   1.0s
 => => sha256:58c524ea09ced2269cb14533d95b80de9fea9532abbf171585d8acee413893f2 956B / 956B       1.4s
 => => sha256:bc98d76756163f687c200ed6114df3904623bbb5e7698b420efaf8ef3c81dfcf 404B / 404B       1.0s
 => => sha256:af7dd138f4591521064c208da6af07f487ebc3e5b350989c0ec2017b3e5208e3 628B / 628B       1.0s
 => => sha256:850bf2dcecff7924b238f0b7cbae7b456e5206453b784fe6b4adfc949add274a 4.40MB / 4.40MB   2.3s
 => => extracting sha256:850bf2dcecff7924b238f0b7cbae7b456e5206453b784fe6b4adfc949add274a        0.1s
 => => extracting sha256:af7dd138f4591521064c208da6af07f487ebc3e5b350989c0ec2017b3e5208e3        0.0s
 => => extracting sha256:58c524ea09ced2269cb14533d95b80de9fea9532abbf171585d8acee413893f2        0.0s
 => => extracting sha256:bc98d76756163f687c200ed6114df3904623bbb5e7698b420efaf8ef3c81dfcf        0.0s
 => => extracting sha256:51900e10fb9cfad93aa74360e5f938efcbe6d3396a380867b7561c84e5cd2daf        0.0s
 => => extracting sha256:8f924cf5086c7b8a67e8b3e03b22851c1de8e11b0433c21904ef340d89e5014e        0.0s
 => => extracting sha256:6636b9fc203ce74d0b07a1d3f48cfa0151b23fa5e787232908e560673a66b553        0.3s
 => CACHED [build 2/6] WORKDIR /app                                                              0.0s
 => [build 3/6] COPY package.json .                                                              0.0s
 => [build 4/6] RUN npm install                                                                 10.3s
 => [build 5/6] COPY . .                                                                         0.0s
 => CANCELED [build 6/6] RUN npm run build                                                      73.6s
ERROR: failed to build: failed to solve: Canceled: context canceled

devops/5_docker_fundamentals main ? ✗ nvim re
react-app/ README.md  

devops/5_docker_fundamentals main ? ✗ nvim react-app/
dockerfile    index.html    package.json  src/          

devops/5_docker_fundamentals main ? ✗ nvim react-app/package.json 

devops/5_docker_fundamentals main ? ❯ cd ..

devops main ? ❯ docker build -t react-app ./react-app
[+] Building 0.0s (0/0)                                                                docker:default
ERROR: failed to build: unable to prepare context: path "./react-app" not found

devops main ? ✗ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 21:10   1_linux_fundamentals
drwxr-xr-x     - adam  4 Sep 21:14   2_shell_scripting
drwxr-xr-x     - adam  4 Sep 22:49   3_Git_Github
drwxr-xr-x     - adam  4 Sep 23:06   4_Networking
drwxr-xr-x     - adam  4 Sep 23:41   5_docker_fundamentals

devops main ? ❯ cd 5_docker_fundamentals/

devops/5_docker_fundamentals main ? ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 23:38   apache-app
drwxr-xr-x     - adam  4 Sep 23:34   java-app
drwxr-xr-x     - adam  4 Sep 23:30   nodejs-app
drwxr-xr-x     - adam  4 Sep 23:25   python-app
drwxr-xr-x     - adam  4 Sep 23:45   react-app
.rw-r--r--   15k adam  4 Sep 23:36  󰂺 README.md

devops/5_docker_fundamentals main ? ❯ docker build -t react-app ./react-app
[+] Building 10.9s (14/14) FINISHED                                                    docker:default
 => [internal] load build definition from dockerfile                                             0.0s
 => => transferring dockerfile: 231B                                                             0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                                  0.8s
 => [internal] load metadata for docker.io/library/node:22-alpine                                0.8s
 => [internal] load .dockerignore                                                                0.0s
 => => transferring context: 2B                                                                  0.0s
 => [build 1/6] FROM docker.io/library/node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb  0.0s
 => => resolve docker.io/library/node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f  0.0s
 => CACHED [stage-1 1/2] FROM docker.io/library/nginx:alpine@sha256:72ba65eb42c10344912a84ff424  0.0s
 => => resolve docker.io/library/nginx:alpine@sha256:72ba65eb42c10344912a84ff42408db7d34f2feb64  0.0s
 => [internal] load build context                                                                0.0s
 => => transferring context: 387B                                                                0.0s
 => CACHED [build 2/6] WORKDIR /app                                                              0.0s
 => [build 3/6] COPY package.json .                                                              0.0s
 => [build 4/6] RUN npm install                                                                  9.3s
 => [build 5/6] COPY . .                                                                         0.0s 
 => [build 6/6] RUN npm run build                                                                0.5s
 => [stage-1 2/2] COPY --from=build /app/dist /usr/share/nginx/html                              0.0s
 => exporting to image                                                                           0.1s
 => => exporting layers                                                                          0.1s
 => => exporting manifest sha256:655ee36f79b3bff16b3cb7ea88dfcbd5afade4982c24327f0f6df2dff69a4a  0.0s 
 => => exporting config sha256:bbe799e3da04ec6b916132f3f2b63d8c71ad09ec741815deab51f598be6accb2  0.0s 
 => => exporting attestation manifest sha256:6ec422046bd7d1fc3da87c857fe4502678173832a97804bc76  0.0s
 => => exporting manifest list sha256:bc45b170800c00b2ba22132c24d93234f8dba79cf3c8bab1e1cbcef9a  0.0s
 => => naming to docker.io/library/react-app:latest                                              0.0s
 => => unpacking to docker.io/library/react-app:latest                                           0.0s

devops/5_docker_fundamentals main ? ❯ docker run -d --name react-container -p 3005:80 react-app
ecbeed10b364bb992ddc19dc408626232f287f8ccd9dff680851f038b542846f

devops/5_docker_fundamentals main ? ❯ ls
Permissions Size User Date Modified Name
drwxr-xr-x     - adam  4 Sep 23:38   apache-app
drwxr-xr-x     - adam  4 Sep 23:34   java-app
drwxr-xr-x     - adam  4 Sep 23:30   nodejs-app
drwxr-xr-x     - adam  4 Sep 23:25   python-app
drwxr-xr-x     - adam  4 Sep 23:45   react-app
.rw-r--r--   15k adam  4 Sep 23:36  󰂺 README.md

devops/5_docker_fundamentals main ? ❯ mkdir nginx-app

devops/5_docker_fundamentals main ? ❯ cd n
nginx-app/  nodejs-app/ 

devops/5_docker_fundamentals main ? ❯ cd nginx-app/

…/5_docker_fundamentals/nginx-app main ? ❯ nvim index.html

…/5_docker_fundamentals/nginx-app main ? ❯ nvim dockerfile

…/5_docker_fundamentals/nginx-app main ? ❯ cd ..

devops/5_docker_fundamentals main ? ❯ docker build -t nginx-app ./nginx-app
[+] Building 1.1s (7/7) FINISHED                                                       docker:default
 => [internal] load build definition from dockerfile                                             0.0s
 => => transferring dockerfile: 116B                                                             0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                                  0.8s
 => [internal] load .dockerignore                                                                0.0s
 => => transferring context: 2B                                                                  0.0s
 => [internal] load build context                                                                0.0s
 => => transferring context: 174B                                                                0.0s
 => CACHED [1/2] FROM docker.io/library/nginx:alpine@sha256:72ba65eb42c10344912a84ff42408db7d34  0.0s
 => => resolve docker.io/library/nginx:alpine@sha256:72ba65eb42c10344912a84ff42408db7d34f2feb64  0.0s
 => [2/2] COPY index.html /usr/share/nginx/html/index.html                                       0.0s
 => exporting to image                                                                           0.1s
 => => exporting layers                                                                          0.0s
 => => exporting manifest sha256:edd558992a82572201cc0be32f79c103184fb37326743b12f9b4aa3ad305ea  0.0s
 => => exporting config sha256:906b473267e4f9cf051b77ca2e75ed7e44aa2ac188f259fd7419b920e7a67135  0.0s
 => => exporting attestation manifest sha256:a01b8ce54bbc2e861eb87381591efd418f5bb35bc4f9a6f404  0.0s
 => => exporting manifest list sha256:866862fa5d5e4f1acf8d377e09189763f54b942fed477ac2d323ec54e  0.0s
 => => naming to docker.io/library/nginx-app:latest                                              0.0s
 => => unpacking to docker.io/library/nginx-app:latest                                           0.0s

devops/5_docker_fundamentals main ? ❯ docker run -d --name nginx-container -p 3006:80 nginx-app
747aeef0df43df930706cee9ce6e958ef78a1e1f76e567cb1ef13713158e4436
