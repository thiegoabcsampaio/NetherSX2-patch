# Mudanças de comportamento API 33 → 35 (e 36): impacto e correção

Análise feita sobre o APK `NetherSX2-v2.1-4248.apk` (SHA-256 `a39fe9f8…1050`) decodificado com apktool 2.12.1.
O código do app fica em `xyz.aethersx2.android`; o resto do smali (pacotes ofuscados `a`…`z6`, `x3`, `androidx`, `com.google`) são bibliotecas.

| API | Mudança | Achado no APK | Ação |
|---|---|---|---|
| 33 | `POST_NOTIFICATIONS` | Nenhum `NotificationManager` no código do app (só em libs, `androidx.work`/core). Serviços e receivers foram removidos pelo patch de anúncios | Nada a declarar |
| 33 | Mídia granular `READ_MEDIA_*` | Nenhuma permissão de storage; o app usa SAF (`ACTION_OPEN_DOCUMENT_TREE` em `MainActivity`/`SetupWizardActivity`) | Nada a fazer; testar seletor de pasta (checklist) |
| 34 | `registerReceiver` exige `RECEIVER_(NOT_)EXPORTED` | 17 arquivos chamam `registerReceiver`, **todos em bibliotecas** (appcompat `f/h$g`, lifecycle, work, `x3/*`); o código `xyz.aethersx2` não registra receivers. As libs usam o caminho `ContextCompat` com flag (`registerReceiver(...,I)`) ou broadcasts de sistema (isentos) | Sem alteração; observar `logcat` por `SecurityException` |
| 34 | Intents implícitos internos | `xyz.aethersx2` só usa `startActivity(Intent)` com ACTION_VIEW/OPEN_DOCUMENT(_TREE) para apps externos; nenhum `PendingIntent` no app | Sem alteração |
| 34 | `foregroundServiceType` | Único `Service` restante é `androidx.work.impl.foreground.SystemForegroundService`, **não declarado** no manifest (removido) | Sem alteração |
| 34 | Carregamento dinâmico de código | `DexClassLoader`/`PathClassLoader` só em libs ofuscadas (`x3/bd`, `x3/pb`, `x3/zw1`); nenhum carregamento de arquivo gravável do app | Sem alteração |
| 34 | `usesCleartextTraffic` | Java: `URLDownloader` baixa capas de URLs **definidas pelo usuário**. Nativo (libcurl, RetroAchievements) não é afetado pela política | `usesCleartextTraffic=false` + `networkSecurityConfig` (só CAs do sistema). **Efeito colateral:** templates de capa em `http://` deixam de funcionar; use `https://` |
| — | Permissão `INTERNET` | Usada por `libemucore.so` (RetroAchievements `https://retroachievements.org/dorequest.php`, jogo online) e `URLDownloader` | **Mantida** (remover quebraria funções) |
| 35 | Edge-to-edge forçado | `EmulationActivity` usa `setSystemUiVisibility` (imersivo) e os temas são `Theme.MaterialComponents`, sem tratamento de `WindowInsets` | Paliativo: `res/values-v35/styles.xml` com `windowOptOutEdgeToEdgeEnforcement=true` em `AppTheme` (herdado por todas as activities). Correção definitiva (insets via smali) **não feita**: exige editar muitas telas sem poder testar aqui |
| 35 | Predictive back | 11 arquivos com `onBackPressed` | `enableOnBackInvokedCallback=false` mantém o comportamento antigo |
| 36 | Opt-out de edge-to-edge ignorado | Só vale para apps com **targetSdk 36**. Com targetSdk 35 o opt-out continua valendo no Android 16 | Por isso o build para em 35. Subir para 36 exige tratar os insets de verdade |
| 15+ | Páginas de 16 KB | `libemucore.so`: LOADs 2 e 3 alinhados em 4 KB | **Não corrigido** (sem fonte; reescrever ELF é arriscado). O APK é entregue com a lib *stored* e alinhada a 16 KB no zip; em aparelhos com kernel 16 KB nativo a lib pode não carregar. Android 15/16 em kernel 4 KB (a maioria) e o modo de compatibilidade 16 KB do Android 16 não são afetados |

## Backup
`allowBackup=true` mantido. `dataExtractionRules`/`fullBackupContent` declarados explicitamente e vazios (nada excluído; o app não guarda credenciais).
