# Drive Time — Fast track iPhone + App Store

**Objectivo:** instalar no iPhone e submeter **TestFlight** (e depois App Store) numa sessão no Mac emprestado.

| Campo | Valor |
|-------|--------|
| App | Drive Time |
| Bundle ID | `pt.drivetime.app` |
| Firebase | `drive-time-da85f` |
| Versão actual | `1.0.0` (build **14** no pubspec) |
| Login | Email + palavra-passe |
| Preço alvo | 19 € (app paga) |
| Suporte | admin@drivetimeapp.com |
| Privacidade (URL) | https://drive-time-da85f.web.app/privacy-policy.html |

---

## ANTES do Mac (faz HOJE no Windows — ~45 min)

Marca cada item quando estiver feito.

### Conta Apple
- [ ] **Apple Developer Program** activo (99 €/ano) — [developer.apple.com/programs](https://developer.apple.com/programs)
- [ ] **2FA** activo no Apple ID (telemóvel contigo no dia do Mac)
- [ ] Sabes email + password do Apple ID (não partilhes com ninguém além de ti)

### Identificador da app
- [ ] [developer.apple.com](https://developer.apple.com) → **Certificates, Identifiers & Profiles** → **Identifiers**
- [ ] Confirma ou cria **App ID** com bundle **`pt.drivetime.app`**
- [ ] Capabilities: **Push Notifications** (opcional, app usa notificações locais — normalmente OK sem push server)

### App Store Connect (podes fazer no PC)
- [ ] [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Apps** → **+** → Nova app iOS
- [ ] Nome: **Drive Time** · Idioma: **Português (Portugal)** · Bundle: **pt.drivetime.app** · SKU: `drivetime`
- [ ] **Acordos** (App Store Connect → **Business** / **Agreements**): assina **Paid Apps** se vais cobrar 19 €
- [ ] **Banking & Tax**: IBAN + NIF preenchidos (obrigatório para app paga)
- [ ] Copia textos de `app-store-connect/metadata-pt.txt` para a ficha da loja
- [ ] URL privacidade: `https://drive-time-da85f.web.app/privacy-policy.html`
- [ ] Abre esse URL no browser — tem de carregar (se não, faz deploy hosting antes)

### Firebase
- [ ] Firestore **regras publicadas** (Console → Firestore → Regras, ou `firebase deploy --only firestore:rules` na pasta `firebase/`)
- [ ] App iOS **`pt.drivetime.app`** existe no Firebase Console com `GoogleService-Info.plist` (já está no repo)

### Projecto no Mac
- [ ] Código no Mac: **Git clone** OU pasta copiada por USB/cloud (branch actual com build estável)
- [ ] Imprime ou guarda no telemóvel este ficheiro + `scripts/mac_ios_build.sh`

### Material físico no dia
- [ ] iPhone + **cabo Lightning/USB-C**
- [ ] Mac emprestado com **Xcode** instalado (App Store, ~12 GB)
- [ ] Internet Wi‑Fi estável

---

## NO Mac — sessão rápida (~90 min)

### 0. Instalar ferramentas (se faltar)
```bash
# Flutter: https://docs.flutter.dev/get-started/install/macos
flutter doctor
# Xcode: abrir uma vez, aceitar licença
sudo xcodebuild -license accept
sudo gem install cocoapods
```

### 1. Abrir projecto
```bash
cd ~/caminho/para/drive-time-duplicated
chmod +x scripts/mac_ios_build.sh
./scripts/mac_ios_build.sh prep
```

### 2. Xcode — assinatura (obrigatório, 2 min)
```bash
open ios/Runner.xcworkspace
```
1. Projecto **Runner** → target **Runner** → **Signing & Capabilities**
2. **Team:** a tua conta Apple Developer
3. **Bundle Identifier:** `pt.drivetime.app`
4. **Automatically manage signing:** ON

### 3. Testar no iPhone (15 min)
1. iPhone: **Definições → Privacidade → Modo programador** (iOS 16+) se aparecer
2. Liga cabo → **Confiar** neste computador
3. Xcode: escolhe o iPhone no topo → **Run ▶**
4. iPhone: **Definições → Geral → VPN e gestão** → **Confiar** no programador

**Testa:** login → turno → pausa → stop → PDF → Definições (versão 1.0.0 build 14)

Ou terminal:
```bash
flutter run --release -d <id-do-iphone>
```

### 4. Gerar build para TestFlight (30 min)
**Xcode (recomendado):**
1. Destino: **Any iOS Device (arm64)**
2. **Product → Archive**
3. **Organizer** → **Distribute App** → **App Store Connect** → **Upload**

**Ou terminal:**
```bash
./scripts/mac_ios_build.sh ipa
# IPA em: build/ios/ipa/*.ipa
# Enviar com app "Transporter" (Mac App Store)
```

### 5. TestFlight (15 min + espera Apple ~15–30 min)
1. App Store Connect → **Drive Time** → **TestFlight**
2. Quando o build aparecer → **Internal Testing** → adiciona o teu email
3. No iPhone: instala app **TestFlight** → aceita convite → instala Drive Time

### 6. App Store pública (quando TestFlight OK)
1. App Store Connect → **App Store** → versão **1.0.0**
2. Preenche capturas (mín. iPhone 6.7" — ver abaixo)
3. Seleciona o build do TestFlight
4. **Notas para revisão:** copia de `app-store-connect/review-notes.txt`
5. **Enviar para revisão**

---

## Capturas de ecrã (App Store)

Tira no **Simulador** (Xcode → iPhone 15 Pro Max) ou iPhone real:

| Dispositivo | Tamanho |
|-------------|---------|
| iPhone 6.7" | 1290 × 2796 px |
| iPhone 6.5" (alternativa) | 1284 × 2778 px |

Ecrãs sugeridos: Login · Home com turno · Histórico · Relatórios/PDF · Definições

Simulador: **Cmd + S** guarda PNG na secretária.

---

## Problemas frequentes

| Erro | Solução |
|------|---------|
| Signing requires a development team | Xcode → Signing → escolhe Team |
| pod install falha | `cd ios && pod repo update && pod install` |
| Flutter not found | Instala Flutter e `export PATH` |
| Build não aparece no Connect | Espera 15–30 min; verifica email Apple |
| Firebase / permission-denied | Publica regras Firestore; login com email correcto |
| Untrusted developer | iPhone → Gestão de dispositivos → Confiar |

---

## Ordem mínima (se tiveres pouco tempo)

```
1. prep (script)     → 10 min
2. Run no iPhone     → 15 min
3. Archive + Upload  → 30 min
4. TestFlight        → 15 min
5. App Store ficha   → outro dia OK
```

---

## Ficheiros de apoio

| Ficheiro | Uso |
|----------|-----|
| `app-store-connect/metadata-pt.txt` | Textos copy-paste App Store Connect |
| `app-store-connect/review-notes.txt` | Notas para revisor Apple |
| `scripts/mac_ios_build.sh` | Comandos automáticos no Mac |
| `docs/IOS_BUILD.md` | Guia detalhado |

---

## Depois de publicar

- [ ] Convida testers TestFlight (emails)
- [ ] Monitoriza crashes / feedback
- [ ] Próximo build iOS: incrementa `version:` no `pubspec.yaml` (ex. `1.0.0+15`)
