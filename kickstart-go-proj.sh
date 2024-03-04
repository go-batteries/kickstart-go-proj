#!/bin/bash
#
# setup the project directory structure for a golang project
# 
#

set -e

declare PROTOS_DIR

usage() {
  echo "Usage $0 [ -p protos ] [ -s ]" >&2
  echo " -p  download base proto definitions in directory" >&2
  echo " -s  build with server" >&2
}

function setup_base() {
  echo "readying directories"

  touch README.md
  touch Makefile

  mkdir -p app/{core,web}
  mkdir -p cmd/{server,worker,cli}
  mkdir -p pkg/

}

function setup_required_protos() {
  echo "building directories for google api protos"

  mkdir -p protos/{core,web}
  mkdir -p openapiv2 

  local google_api_dir_root="protos/includes/googleapis"
  local grpc_ecosystem_dir_root="protos/includes/grpc_ecosystem/protoc-gen-openapiv2"

  mkdir -p "${google_api_dir_root}/google/"{api,protobuf}
  mkdir -p "${grpc_ecosystem_dir_root}/options"

  ls "${google_api_dir_root}/google/api"
  ls "${grpc_ecosystem_dir_root}/options"

	curl "https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/http.proto" \
		-o "${google_api_dir_root}/google/api/http.proto" \

	curl "https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/annotations.proto" \
		-o "${google_api_dir_root}/google/api/annotations.proto"

	curl "https://raw.githubusercontent.com/protocolbuffers/protobuf/main/src/google/protobuf/descriptor.proto" \
		-o "${google_api_dir_root}/google/protobuf/descriptor.proto"

	curl "https://raw.githubusercontent.com/protocolbuffers/protobuf/main/src/google/protobuf/struct.proto" \
		-o "${google_api_dir_root}/google/protobuf/struct.proto"

	curl "https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/main/protoc-gen-openapiv2/options/annotations.proto" \
	  -o "${grpc_ecosystem_dir_root}/options/annotations.proto"

	curl "https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/main/protoc-gen-openapiv2/options/openapiv2.proto" \
		-o "${grpc_ecosystem_dir_root}/options/openapiv2.proto"
}
 

function setup_go_protogen_execs() {
  export GOBIN=$(go env GOBIN) 

  go mod download google.golang.org/protobuf
  go install google.golang.org/protobuf/cmd/protoc-gen-go
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
}

function import_base_modules() {
  go get -u github.com/go-batteries/diaper
  go get -u github.com/rs/zerolog/log
}

function install_server_modules() {
  go get -u github.com/labstack/echo/v4
  go get -u github.com/labstack/echo/v4/middleware
}

while getopts ":h:p:s" arg; do
  case "$arg" in
    h)
      usage
      exit 0
      ;;
    p)
      PROTOS_DIR="${OPTARG}"
      ;;
    s)
      WITH_SERVER=1
      ;;
  esac
done

go mod tidy

setup_base
import_base_modules

if [[ ! -z "$PROTOS_DIR" ]]; then
  setup_required_protos
  setup_go_protogen_execs
fi


if [[ $WITH_SERVER -eq 1 ]]; then
  install_server_modules
fi

