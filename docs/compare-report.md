# Build Comparison Report

Generated: Thu Apr 23 23:50:05 TST 2026

- Original sender:   47e3e99165ee867a4b058d6d7c003fbdce06e57a
- Original receiver: 5ec5156586b146335e0b940fa565f05ff3eec9a4
- Monorepo:          241c22a61af8d33b988b4fbffda05ac2cfec0508

## Build Status

| App | Platform | Original | Monorepo |
|-----|----------|----------|----------|
| sender | web | OK | OK |
| sender | windows | OK | OK |
| sender | apk | OK | OK |
| receiver | apk | OK | OK |

## Comparison Results

### sender / web

- Build: original=`OK`, monorepo=`OK`
- Result: **EQUIVALENT** (all artifacts match)

  ```
  Match: 406, expected-diff: 3, unexpected-diff: 0
  - [EXPECTED:metadata] flutter_bootstrap.js: orig=8113B vs mono=8112B (sha 2527f4e6..78244aad)
  - [EXPECTED:metadata] flutter_service_worker.js: orig=43614B vs mono=43614B (sha baac0da5..bd07a76c)
  ```

### sender / windows

- Build: original=`OK`, monorepo=`OK`
- Result: **EQUIVALENT** (all artifacts match)

  ```
  Files match: 388, expected-diff: 30, unexpected-diff: 0
  - [EXPECTED:timestamp] AirSync_Sender.exe: orig=404992B vs mono=404992B
  - [EXPECTED:metadata] AirSync_Sender.pdb: orig=5099520B vs mono=5107712B
  ```

### sender / apk

- Build: original=`OK`, monorepo=`OK`
- Result: **EQUIVALENT** (all artifacts match)

  ```
  APK entries match: 841, expected-diff: 23, unexpected-diff: 0
  - [EXPECTED:metadata] assets/sentry-debug-meta.properties: orig=104B vs mono=104B
  - [EXPECTED:timestamp] lib/arm64-v8a/libapp.so: orig=11338656B vs mono=11338656B
  ```

### receiver / apk

- Build: original=`OK`, monorepo=`OK`
- Result: **EQUIVALENT** (all artifacts match)

  ```
  APK entries match: 735, expected-diff: 29, unexpected-diff: 0
  - [EXPECTED:metadata] assets/dexopt/baseline.prof: orig=1504B vs mono=1371B
  - [EXPECTED:metadata] assets/dexopt/baseline.profm: orig=190B vs mono=188B
  ```

## Summary

- Total targets: 4
- Equivalent: 4
- Divergent: 0
- Skipped: 0

## Logs

Build logs: `/d/tmp/verify-20260422-215813/compare/logs/`
