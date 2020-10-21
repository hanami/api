# Hanami::API
Minimal, extremely fast, lightweight Ruby framework for HTTP APIs.

## v0.1.2 - 2020-10-21
### Fixed
- [Luca Guidi] Ensure to be able to instantiate an `Hanami::API` app multiple times

## v0.1.1 - 2020-05-20
### Fixed
- [Luca Guidi] Ensure Rack middleware to be mounted in scopes without a leading slash
- [Luca Guidi] Ensure nested scopes to use the given middleware stack
- [Luca Guidi] Ensure nested scopes to inherit middleware from outer scopes

## v0.1.0 - 2020-02-19
### Added
- [Luca Guidi] Allow to use Rack middleware with scope visibility
- [Luca Guidi] Block syntax: introduced `json` to render JSON response body
- [Luca Guidi] Block syntax: introduced `redirect` to perform HTTP redirect
- [Luca Guidi] Block syntax: introduced `halt` to interrupt the execution flow and return a HTTP status and body
- [Luca Guidi] Block syntax: introduced `status`, `headers`, `body` that act both as getters and setters for the response values
- [Luca Guidi] Block syntax: introduced `params` getter
- [Luca Guidi] Introduced `Hanami::API` superclass
