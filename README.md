## kickstart-go-app

This is a build script to setup a base development structure for my golang
projects. It comes with some default libraries downloaded and a base project
dir.


Requirements:
- you should have done a `go mod init $awesome_module_name`
- protoc [optional]
- curl


Structure:
- `cmd/` this contains the `main.go`/entrypoint for each type of standalone
  binaries. `cmd/server/main.go`, `cmd/worker/main.go`
- `app/` this directory has most of your application code.
    - `core/` contains all your domain/model split folders, repositories,
      services, externals
    - `web/` has all your controller and http related code. This will simply
      reply on the core to achieve the functionality
- `config/` is the directory to store your application config files. `.env`,
  `ebv.yaml`, `dev.env`, etc.
- `pkg/` is where you place your config loading, logger initialization, and
  other core functionality 

Optionally:

- Can choose to use `proto` to generate API docs, by specifying the directory
  path like `-p protos/`
- `openapiv2/` will have the generated json.


Preinstall packages:
- `github.com/go-batteries/diaper`, a wrapper over viper, which allows to use
  different sources for value. Like `env://` for ENV, `ssm://` for SSM. Its
  configurable
- `zerolog` for logging. It also has some structured logging
- `echo v4` for router

On choosing to use `proto`, it will download:
- `protobuf`
- `protoc-gen-go`
- `protoc-gen-go-grpc`
- protoc-gen-openapiv2

In addition it also downloads the required `proto` defintion from `googleapis`
and `grpc-gateway`. The basic ones to support a decent list of annotations.

