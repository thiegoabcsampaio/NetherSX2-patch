# Changelog

## v2.1-4248-modern.1 (versionCode 15246)
- targetSdk 32 → 35 (remove o bloqueio do Play Protect por "versão antiga do Android")
- `usesCleartextTraffic=false` + `networkSecurityConfig` (HTTPS only)
- `dataExtractionRules` / `fullBackupContent` explícitos
- Opt-out do edge-to-edge forçado do Android 15 (`values-v35`) e `enableOnBackInvokedCallback=false`
- APK alinhado (libs stored a 16 KB) e assinado v2+v3 com chave própria
- Núcleo nativo e smali **inalterados**; package `xyz.aethersx2.android` mantido
