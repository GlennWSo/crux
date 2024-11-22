{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
  }: let
    system = "x86_64-linux";
    overlays = [(import rust-overlay)];
    pkgs = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
      config.android_sdk.accept_license = true;
    };
    toolchain = pkgs.rust-bin.stable.latest.default.override {
      extensions = ["rust-src"];
      targets = ["aarch64-linux-android" "armv7-linux-androideabi" "i686-linux-android" "x86_64-linux-android" "wasm32-unknown-unknown"];
    };

    android = pkgs.androidenv.composeAndroidPackages {
      # cmdLineToolsVersion = "8.0";
      # toolsVersion = "26.1.1";
      # platformToolsVersion = "34.0.5";
      buildToolsVersions = ["34.0.0"];
      # includeEmulator = false;
      # emulatorVersion = "30.3.4";
      platformVersions = ["34"];
      includeSources = true;
      # includeSystemImages = false;
      # systemImageTypes = ["google_apis_playstore"];
      # abiVersions = ["armeabi-v7a" "arm64-v8a"];
      # cmakeVersions = ["3.10.2"];
      includeNDK = true;
      ndkVersions = ["27.0.12077973"];
      # useGoogleAPIs = false;
      # useGoogleTVAddOns = false;
      # includeExtras = [
      #   "extras;google;gcm"
      # ];
    };
    # android = pkgs.androidenv.androidPkgs;
  in {
    devShells.x86_64-linux.default = pkgs.mkShell rec {
      ANDROID_HOME = "${android.androidsdk}/libexec/android-sdk";
      ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
      GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${android.androidsdk}/libexec/android-sdk/build-tools/34.0.0/aapt2";
      RUSTC = "${toolchain}/bin/rustc";
      RUST_CARGO = "${toolchain}/bin/cargo";
      buildInputs = with pkgs; [
        cargo-ndk
        cargo-apk
        toolchain
        rust-analyzer
        glib

        wasm-pack
        pnpm
        trunk
        nodejs

        (android-studio.withSdk android.androidsdk)
        ktlint
        # gradle_8
        jdk21
        usbutils
        python312
      ];
    };
  };
}
