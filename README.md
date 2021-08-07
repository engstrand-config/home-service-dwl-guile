# dwl home service
A Guix home service for installing and configuring dwl-guile, a fork of dwl that
allows you to dynamically configure dwl using Guile.

You can find the source of dwl-guile
[here](https://github.com/engstrand-config/dwl-guile).

> This is a work in progress and not everything is fully functional

## Features
- Install dwl with guile support
- Automatically start dwl on login
- Apply patches to dwl using the home service (optional)
- Dynamically configure dwl using Guile (no config.h)

## Channel introduction
To make installation and usage as simple as possible, `home-dwl-service` is
provided using a channel.

Add the channel to your `~/.config/guix/channels.scm`:

```scheme
(channel
  (name 'home-dwl-service)
  (url "https://github.com/engstrand-config/home-dwl-service")
  (branch "main")
  (introduction
    (make-channel-introduction
      "314453a87634d67e914cfdf51d357638902dd9fe"
      (openpgp-fingerprint
        "C9BE B8A0 4458 FDDF 1268 1B39 029D 8EB7 7E18 D68C"))))
```

## Usage
```scheme
; Import the service
(use-modules (dwl-guile home-service)
             (dwl-guile patches)) ; import you want dynamic patches

; Enable the service and add a configuration
(service home-dwl-guile-service-type
  (home-dwl-guile-configuration
    ; Optionally specify a custom dwl package.
    ; It will automatically be patched with the dwl-guile patch,
    ; unless you set (package-transform? #f).
    (package my-custom-dwl)

    ; Set this to false if you already have a fully patched dwl
    (package-transform? #f)

    ; Optionally pass in a list of dwl patches to
    ; apply. Note that some patches will have conflicts.
    ; It is generally recommended to create a custom, patched dwl
    ; and convert it into a package. You can then set the custom
    ; package using the package field above.
    (patches (list (%patch-xwayland)))

    ; tty to auto-start dwl on
    (tty-number 2)

    ; Environment variables to set.
    ; By default, a chunk of different variables will be set to
    ; ensure compatibility with many applications.
    ;
    ; Set it to an empty list to skip setting environment variables:
    ; (environment-variables '())
    ;
    ; Or extend the default environment variables:
    ; (environment-variables (cons `(("var" . "value")) %base-environment-variables))

    ; Create a custom configuration for dwl.
    (config
      (dwl-config ...))))

; You can also use the default configuration
(service home-dwl-guile-service-type)
```

### Patching
TODO

### dwl configuration
TODO
