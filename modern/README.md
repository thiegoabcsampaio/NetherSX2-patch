# NetherSX2 modernizado (targetSdk 35)

Reempacota o **NetherSX2 v2.1-4248** sem recompilar o emulador: apktool → patches de manifest/recursos → zipalign → apksigner (v2+v3).
O APK original não é versionado; `scripts/setup.sh` baixa e confere o SHA-256 (`a39fe9f8…1050`).

Detalhes: [mudanças de API](docs/behavior-changes.md) · [testes](docs/test-report.md) · [changelog](CHANGELOG.md)

## Build local
Requer JDK 17+, `python3`, Android build-tools 35+ (`apksigner`, `aapt2`, `zipalign`).
```sh
export KS_PASS='sua-senha'
./scripts/keystore-gen.sh      # uma vez; guarde o .jks (nunca commitar)
./scripts/build.sh             # gera release/NetherSX2-v2.1-4248-modern.1.apk + SHA256SUMS
./scripts/verify.sh
```
Sem `zipalign -P` (build-tools < 35) o `build.sh` usa `scripts/align16k.py`.

## Build no GitHub Actions
Workflow `.github/workflows/modern-build.yml` (Actions → *Build modern APK* → Run workflow).
Para um APK atualizável entre versões, cadastre os secrets `KEYSTORE_BASE64` (`base64 -w0 nethersx2-modern.jks`) e `KS_PASS`. Sem eles o workflow gera uma chave descartável **só para teste**.

## Instalar e migrar dados
Como a assinatura muda, o Android **não** deixa atualizar por cima do NetherSX2 instalado. Antes:
1. Copiar a pasta de dados do app (saves, memory cards, configs; normalmente a pasta que você escolheu no setup), ou usar *Transfer Data → Export*;
2. Desinstalar o NetherSX2 antigo;
3. Instalar o APK novo e apontar para a mesma pasta.

## Limitações
- `libemucore.so` (sem código-fonte) continua com segmentos de 4 KB: pode não carregar em aparelhos com kernel de página de 16 KB.
- Edge-to-edge é tratado por opt-out (válido enquanto targetSdk ≤ 35), não por insets.
- Cover URLs em `http://` não funcionam mais.
- **Não testado em dispositivo**; use o checklist em `docs/test-report.md`.
