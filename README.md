# YTSideload

A minimal Theos tweak that contains **only the sideloading fix** from
[`dayanch96/YTLite`](https://github.com/dayanch96/YTLite): the hooks required
to make a resigned YouTube.ipa run and log in after it has been repackaged by
tools such as Sideloadly, AltStore, TrollStore, or esign.

Everything else from the upstream tweak (custom UI, settings panel, native
share sheet, FAQ / resources / localization assets) has been removed.

## What it does

`Tweak.x` patches the YouTube app at runtime so that:

- `YTVersionUtils`, `GCKBUtils`, `GPCDeviceInfo`, `OGLBundle`, `GVROverlayView`,
  `OGLPhenotypeFlagServiceImpl`, `SSOConfiguration` all return the original
  App Store bundle id / display name.
- `APMAEU.isFAS` and `GULAppEnvironmentUtil.isFromAppStore` both return `YES`.
- `NSBundle.bundleIdentifier`, `infoDictionary` and
  `objectForInfoDictionaryKey:` are rewritten for the main bundle only (caller
  stack check via `dladdr`).
- `SSOKeychainHelper` / `SSOKeychainCore` return a dynamically resolved
  access group — fixes Google sign-in on YouTube 17.33.2 and higher.
- `NSFileManager.containerURLForSecurityApplicationGroupIdentifier:` is
  redirected to `Documents/AppGroup/` so the resigned app has a writable
  container.

The hooks only activate when the app is **not** installed from the App Store
(checked via `appStoreReceiptURL`), so the same binary is safe to ship inside
an IPA without breaking real App Store builds.

## Build

Requirements: `theos`, `make` (GNU), `ldid`, `dpkg-deb`, and an iOS SDK.

```sh
export THEOS=~/theos
make package               # default: rootless .deb
make package THEOS_PACKAGE_SCHEME=        # rootful
make package THEOS_PACKAGE_SCHEME=roothide
make package-all            # all three schemes
make dylib                  # extract YTSideload.dylib for IPA injection
make clean-all              # wipe build artifacts
```

The resulting `.deb` is written to `packages/`. `make dylib` additionally
extracts the raw `YTSideload.dylib` to `build/` so it can be dropped into an
IPA with a sideloading tool.

## Credits

- [dayanch96/YTLite](https://github.com/dayanch96/YTLite) — original project.
- [PoomSmart/IAmYouTube](https://github.com/PoomSmart/IAmYouTube) — the
  bundle-identifier patch approach reused in the sideloading fix.
