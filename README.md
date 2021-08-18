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
  (name 'home-service-dwl-guile)
  (url "https://github.com/engstrand-config/home-service-dwl-guile")
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

    ; A list of gexps to be executed after starting dwl-guile.
    ; This is the equivalent of specifying a script to the '-s' flag of dwl.
    ; The gexp's will be executed in the same order as in the list.
    ;
    ; You can find the generated script in: @file{$HOME/.config/dwl-guile/startup.scm}.
    (startup-commands
      (list
        #~(system* ...)))

    ; If qt applications should be rendered natively in Wayland.
    ; Enabling this will set QT_QPA_PLATFORM="wayland-egl" and install
    ; the "qtwayland" package to enable support for Wayland.
    (native-qt? #t)

    ; Create a custom configuration for dwl.
    (config
      (dwl-config ...))))

; You can also use the default configuration
(service home-dwl-guile-service-type)
```

### Extending the dwl-guile home service
To help with conditionally apply certain configuration options to dwl-guile,
the home service can be extended. This is especially useful if you use something
like [rde](https://github.com/abcdw/rde).

Consider the following exaple that will add two new keybindings for
dismissing system notifications from [mako](https://github.com/emersion/mako):

```scheme
(simple-service
  'add-mako-dwl-keybindings
  home-dwl-guile-service-type
  (modify-dwl-guile-config
    (config =>
            (dwl-config
              (inherit config)
              (keys
                (append
                  (list
                    (dwl-key
                      (modifiers '(SUPER CTRL))
                      (key "d")
                      (action `(system* ,(file-append mako "/bin/makoctl")
                                        "dismiss")))
                    (dwl-key
                      (modifiers '(SUPER CTRL SHIFT))
                      (key "d")
                      (action `(system* ,(file-append mako "/bin/makoctl")
                                        "dismiss" "--all"))))
                (dwl-config-keys config)))))))
```

There are two different syntax macros that you can use for convenience:

* `modify-dwl-guile` - to modify the home service configuration
* `modify-dwl-guile-config` - to modify the dwl config

Both macros follow the same format, but the parameter `config` (the name does
not matter) will take on different values based on the macro. For
`modify-dwl-guile`, `config` will refer to the `home-dwl-guile-configuration`
record, whereas the `config` of `modify-dwl-guile-config` will refer to the
`config` field of the `home-dwl-guile-configuration` record. Using the
`modify-dwl-guile-config` macro will only modify the dwl config.

It is very important that you remember to **inherit the received `config`** to make
sure that your previous configuration options are not overridden. Each service
extension will be recursively composed into a single configuration.

You can find more examples of this in
[our GNU Guix configuration](https://github.com/engstrand-config/guix-dotfiles),
mainly in the `engstrand/features/wayland.scm` file.

### Patching
TODO

### dwl configuration
TODO
