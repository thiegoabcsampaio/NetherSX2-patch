# Relatório de testes

**Status: NÃO testado em aparelho.** O ambiente de build é x86_64 sem emulador arm64; só foram executadas as checagens estáticas do `scripts/verify.sh`.

## Estático (executado)
- targetSdk 35, versionCode 15246, versionName `v2.1-4248-modern.1`, package inalterado
- Permissões: apenas `VIBRATE` e `INTERNET`
- Assinatura v2 + v3 válida (v1 desligada)
- `libemucore.so` byte a byte idêntica à original, *stored* e alinhada a 16 KB no zip
- `zipalign -c` OK

## Checklist para executar no celular (Android 15/16)
Filtre `adb logcat -s AndroidRuntime` e `adb logcat | grep xyz.aethersx2`.
- [ ] Instalação sem o aviso "app de risco bloqueado / versão mais antiga do Android"
- [ ] Setup wizard: escolher pasta de dados e BIOS (SAF)
- [ ] Lista de jogos aparece; seletor de pasta de jogos funciona
- [ ] Abrir um jogo; salvar e carregar state; memory card
- [ ] Controle físico e touch; rotação; multitarefa; botão/gesto voltar
- [ ] Barras de status/navegação não cobrem menus nem a tela de emulação
- [ ] Download de capas com URL `https://` OK (URL `http://` deve falhar)
- [ ] RetroAchievements: login e notificação
- [ ] Sem crash no logcat
- [ ] Aparelho com kernel 16 KB (`adb shell getconf PAGESIZE` = 16384): o app abre? Anote o erro de `dlopen` se não abrir
