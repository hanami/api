# Hanami::API
Minimal, extremely fast, lightweight Ruby framework for HTTP APIs.

## [Unreleased]

### Added

- [Sean Collins] Official support for Ruby 3.3 & 3.4
- [Sean Collins] Drop support for Ruby 3.1

## v0.3.0 - 2022-12-25

### Added
- [Luca Guidi] Official support for Ruby 3.1 & 3.2
- [Thomas Jachmann] Streamed responses
- [Luca Guidi] Introduce `Hanami::API.helpers` to define helper methods to be used in route blocks
- [Luca Guidi] Introduce `Hanami::API#to_inspect` to inspect app routes

### Changed
- [Luca Guidi] Drop support for Ruby 2.7

## v0.2.0 - 2021-01-05
### Added
- [Luca Guidi] Official support for Ruby: MRI 3.0
- [Luca Guidi] Introduce `Hanami::API::DSL` which gives the ability to other Ruby web frameworks to use the `Hanami::API` DSL

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
