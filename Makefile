
.PHONY: test
test: 
	go test -v -count=1 ./...

.PHONY: binary
binary: 
	go build -a -installsuffix cgo -o hello .

.PHONY: buildx
buildx:
	@docker buildx create --use --name=multiarch --node=multiarch && \
	docker buildx build \
		--platform linux/amd64,linux/arm/v7,linux/arm64 \
		--output "type=image,push=false" \
		--tag ghcr.io/lucasroesler/buildx-bug:latest \
		.