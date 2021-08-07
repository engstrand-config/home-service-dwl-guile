# Patches
This directory contains the dwl-guile patch, as well as other dwl patches that
are compatible with dwl-guile (some patches may have been modified to be
compatible with dwl-guile).

## Incompatible patches
If a patch does any of the following:
* Adds new functions that *should* be used in a keybinding
* Modifies types or fields of structs that are used in the configuration

the patch will quite certainly **not** be compatible with dwl-guile (without
manual modification). Note that some of the base structs (e.g. `Key` and
`Button`) have been modified by dwl-guile and might cause conflicts with other
patches.

### Modify patch to be compatible with dwl-guile
TODO

## Default patches
dwl-guile is based on the following:
* dwl (version 0.2)
* [keycode patch](https://github.com/djpohly/dwl/compare/main...Sevz17:keycodes.patch)

## Applying patches in your GNU/Guix home configuration
TODO
