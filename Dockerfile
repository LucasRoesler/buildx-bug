FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.15 as build

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

WORKDIR /app

COPY . .
RUN go test -v ./...
RUN go build -a -installsuffix cgo -o hello .

FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:3.12 as ship

COPY --from=build /app/hello    .

CMD ["./hello"]