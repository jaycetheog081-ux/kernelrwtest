# ANE Probe

A probe-only iOS app for checking whether selected ANE-related IOKit service names are visible and whether user-client types 0–8 can be opened from the app sandbox.

## Safety scope

This project intentionally excludes `ane_overflow.m`, `ane_overflow.h`, overflow triggers, heap spraying, memory corruption, and exploit routines. An opened service is **not** proof of a vulnerability or kernel exploitability.

## Build

This repository uses XcodeGen and GitHub Actions:

1. Push the repository to GitHub.
2. Open **Actions → Build ANE Probe IPA**.
3. Run the workflow (or push to `main`/`master`).
4. Download the `ANEProbe-unsigned-ipa` artifact.

The IPA is unsigned and must be installed using an appropriate signing/install workflow. The workflow uses macOS 15 and Xcode 16.4.

## Device test

Install and launch **ANE Probe**, then tap **Run ANE Service Probe**. Save the on-screen output for analysis. A result of `service not found` or `IOServiceOpen` failure only describes what the app sandbox could observe on that OS/device configuration.
