# dwl home service
A Guix home service for installing and configuring dwl.

> This is a work in progress and everything is not fully functional

## Features
- Install dwl
- Apply patches from your home config
- Dynamically configure dwl (no more config.h) using Guile

## Usage
```zsh
source pre-inst-env
```

and you should now be able to use the dwl service in your home environment:

```guile
; import the service
(use-modules (gnu home-services dwl))

; enable the service and optionally pass in a configuration
(service home-dwl-service-type
  (home-dwl-configuration
    (config
      (dwl-config ...))))

; or use the default configuration
(service home-dwl-service-type)
```
