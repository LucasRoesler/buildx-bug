# Buildx bug with kubernetes client-go fake

This is a minimal reproduction of a bug I have found when using the fake ClientSet from `k8s.io/client-go@v0.18.2`.

## Problem

This repo contains a single test, it uses the `fake.NewSimpleClientset` to test an informer. 

In my local environment with Go 1.15, this test passes

```sh
$ go version
go version go1.15.6 linux/amd64
$ make test
go test -v -count=1 ./...
=== RUN   Test_kubernetestFakeFailure
--- PASS: Test_kubernetestFakeFailure (0.00s)
PASS
ok  	github.com/LucasRoesler/buildx-bug	0.009s
```

But this test fails when run inside a docker build using buildx to produce a multiach build for amd/intel + arm.

```sh
$ make buildx                      
multiarch
[+] Building 67.6s (17/22)                                                                                            
 => [internal] load build definition from Dockerfile                                                             0.0s
 => => transferring dockerfile: 447B                                                                             0.0s
 => [internal] load .dockerignore                                                                                0.0s
 => => transferring context: 2B                                                                                  0.0s
 => [linux/arm64 internal] load metadata for docker.io/library/alpine:3.12                                       0.7s
 => [linux/amd64 internal] load metadata for docker.io/library/golang:1.15                                       0.6s
 => [linux/amd64 internal] load metadata for docker.io/library/alpine:3.12                                       0.6s
 => [linux/arm/v7 internal] load metadata for docker.io/library/alpine:3.12                                      1.6s
 => CACHED [linux/arm/v7 ship 1/2] FROM docker.io/library/alpine:3.12@sha256:3c7497bf0c7af93428242d6176e8f7905f  0.0s
 => => resolve docker.io/library/alpine:3.12@sha256:3c7497bf0c7af93428242d6176e8f7905f2201d8fc5861f45be7a346b5f  0.0s
 => [internal] load build context                                                                                0.1s
 => => transferring context: 187.07kB                                                                            0.1s
 => CACHED [linux/amd64 build 1/5] FROM docker.io/library/golang:1.15@sha256:de97bab9325c4c3904f8f7fec8eb469169  0.0s
 => => resolve docker.io/library/golang:1.15@sha256:de97bab9325c4c3904f8f7fec8eb469169a1d247bdc97dcab38c2c75cf4  0.0s
 => CACHED [linux/arm64 ship 1/2] FROM docker.io/library/alpine:3.12@sha256:3c7497bf0c7af93428242d6176e8f7905f2  0.0s
 => => resolve docker.io/library/alpine:3.12@sha256:3c7497bf0c7af93428242d6176e8f7905f2201d8fc5861f45be7a346b5f  0.0s
 => CACHED [linux/amd64 ship 1/2] FROM docker.io/library/alpine:3.12@sha256:3c7497bf0c7af93428242d6176e8f7905f2  0.0s
 => => resolve docker.io/library/alpine:3.12@sha256:3c7497bf0c7af93428242d6176e8f7905f2201d8fc5861f45be7a346b5f  0.0s
 => [linux/amd64 build 2/5] WORKDIR /app                                                                         0.0s
 => [linux/amd64 build 3/5] COPY . .                                                                             0.1s
 => ERROR [linux/amd64 build 4/5] RUN go test -v ./...                                                          65.0s
 => CANCELED [linux/amd64 build 4/5] RUN go test -v ./...                                                       65.0s
 => [linux/amd64 build 4/5] RUN go test -v ./...                                                                57.2s
 => CANCELED [linux/amd64 build 5/5] RUN go build -a -installsuffix cgo -o hello .                               7.8s
------                                                                                                                
 > [linux/amd64 build 4/5] RUN go test -v ./...:
#16 64.69 === RUN   Test_kubernetestFakeFailure
#16 64.72     main_test.go:104: expected 2 functions, got 0
#16 64.74 --- FAIL: Test_kubernetestFakeFailure (0.05s)
#16 64.75 FAIL
#16 64.75 FAIL	github.com/LucasRoesler/buildx-bug	0.489s
#16 64.76 FAIL
------
Dockerfile:15
--------------------
  13 |     
  14 |     COPY . .
  15 | >>> RUN go test -v ./...
  16 |     RUN go build -a -installsuffix cgo -o hello .
  17 |     
--------------------
error: failed to solve: rpc error: code = Unknown desc = executor failed running [/bin/sh -c go test -v ./...]: exit code: 1
make: *** [Makefile:13: buildx] Error 1
```

## Context
This was noticed while trying to add a new test to `github.com/openfaas/faas-netes`: https://github.com/openfaas/faas-netes/pull/739/checks?check_run_id=1673889281