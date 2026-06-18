# Drive Time BETA — Distribuição a testers

## Reverter alterações (se algo correr mal)

Sem commit: na pasta do projeto:

```powershell
git status
git checkout -- lib/ ios/ pubspec.yaml docs/ scripts/
git clean -fd dist/   # opcional: remove APKs gerados
```

Com commit recente: `git log` e depois `git revert <hash>` ou `git reset --hard <hash-anterior>` (só se souberes o que estás a fazer).

## Build APK release (Android)

Pré-requisitos: `android/key.properties` e `android/upload-keystore.jks` (não vão para o Git).

```powershell
.\scripts\build_release_apk.ps1
```

Saída: `dist/DriveTime-BETA-1.0.0-build4.apk`

## Build AAB release (Google Play)

Mesmos pré-requisitos de assinatura (`android/key.properties` + `upload-keystore.jks`).

```powershell
.\scripts\build_release_aab.ps1
```

Saída: `dist/DriveTime-1.0.0-build8.aab`

Upload no [Google Play Console](https://play.google.com/console) → **Testar e publicar** → **Testes internos** (ou produção).

**Antes de publicar:** URL pública da política de privacidade (`https://drivetimeapp.com/privacy-policy.html`), ícones/capturas de ecrã, formulário Data safety, e conta Google Play Developer (taxa única).

Páginas estáticas prontas em `site/` (index + privacy-policy) — publicar no domínio `drivetimeapp.com` (Firebase Hosting, Netlify, ou alojamento do registo de domínio).

## Checklist de teste (Android + iPhone)

- [ ] Registo → dados motorista → veículo → home
- [ ] Login e recuperar palavra-passe
- [ ] Iniciar turno, pausa, retomar, terminar (com confirmação)
- [ ] Timer de horas a actualizar em tempo real
- [ ] Histórico (últimos 7 dias)
- [ ] Relatório PDF com acentos (PT)
- [ ] Definições: versão visível, tema, idioma
- [ ] Sem erros `permission-denied` em uso normal

## Distribuir APK

1. **Firebase App Distribution** — upload do APK, convidar emails dos testers.
2. **Google Play Internal testing** — upload AAB, lista de testers.

## iPhone (50% dos clientes)

Build e TestFlight exigem **Mac + Xcode + Apple Developer**. Ver plano iOS no chat; bundle actual: `com.mycompany.drivetime`.

Publicar regras Firestore antes de testers:

```powershell
firebase deploy --only firestore:rules
```

(ficheiro: `firebase/firestore.rules`)

## Crashlytics / Analytics (opcional)

Útil após primeiros testers; requer configuração extra no Firebase Console e dependências no `pubspec.yaml`.
