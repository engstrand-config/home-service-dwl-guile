# dwl home service
A Guix home service for installing and configuring dwl.

> This is a work in progress and not everything is fully functional

## Features
- Install dwl with guile support
- Automatically start dwl on login
- Dynamically configure dwl (no more config.h) using Guile

## Usage
```zsh
source pre-inst-env
```

and you should now be able to use the dwl service in your home environment:

```scheme
; import the service
(use-modules (gnu home-services dwl-guile))

; enable the service and add a configuration
(service home-dwl-guile-service-type
  (home-dwl-guile-configuration
    ; optionally specify a custom dwl package.
    ; the package will be automatically patched to
    ; support configuration using guile.
    (package my-custom-dwl)

    ; update dwl package definition to generate a desktop
    ; entry in `.guix-home/profile/share/wayland-sessions`.
    (desktop-entry? #t)

    ; create a custom configuration (similar to config.h).
    ; the syntax is mostly the same as the one in config.h
    ; and all of the available options can be also be set using guile.
    (config
      (dwl-config ...))))

; or use the default configuration
(service home-dwl-guile-service-type)
```
