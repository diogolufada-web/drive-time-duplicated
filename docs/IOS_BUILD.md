# Drive Time — Compilar e publicar para iOS (no Mac)

Guia para compilar a app **Drive Time** num Mac (ex.: Mac de um amigo) e enviar para a App Store / TestFlight.

App: **Drive Time** · Bundle ID: **pt.drivetime.app** · Firebase: **drive-time-da85f**

---

## O que já está preparado (feito no Windows)

| Item | Estado |
|------|--------|
| Bundle ID iOS = `pt.drivetime.app` | ✅ (igual ao Android) |
| App iOS no Firebase (`pt.drivetime.app`) | ✅ criada |
| `ios/Runner/GoogleService-Info.plist` | ✅ atualizado para o novo bundle |
| Ícones iOS (`AppIcon.appiconset`) | ✅ logo DT |
| Permissão de notificações (Info.plist) | ✅ |
| Nome a mostrar = "Drive Time" | ✅ |

> O login da app usa **email/palavra-passe**. O login Google/Apple **não** está ligado à interface, por isso não é preciso configurar OAuth iOS para a versão atual. (Ver secção "Login Google/Apple" se quiseres ativar.)

---

## Pré-requisitos no Mac

1. **macOS** recente + **Xcode** (App Store) — abrir uma vez e aceitar licenças
2. **Flutter** instalado: https://docs.flutter.dev/get-started/install/macos
3. **CocoaPods**:
   ```bash
   sudo gem install cocoapods
   ```
4. **Conta Apple Developer** (99 €/ano) — idealmente a TUA conta, para a app ficar tua
   - Para só testar no iPad/iPhone ligado por cabo, basta um Apple ID gratuito (válido 7 dias)

---

## Passos para compilar

### 1. Copiar o projeto para o Mac
Copia a pasta inteira do projeto (via USB, Git, ou cloud). Se usares Git:
```bash
git clone <repo> drive-time
cd drive-time
git checkout flutterflow
```

### 2. Obter dependências
```bash
flutter pub get
```

### 3. Instalar pods iOS
```bash
cd ios
pod install
cd ..
```
> Se der erro de versões, corre `pod repo update` e repete `pod install`.

### 4. Abrir no Xcode
Abre **sempre** o workspace (não o `.xcodeproj`):
```bash
open ios/Runner.xcworkspace
```

### 5. Configurar a assinatura (Signing)
No Xcode:
1. Seleciona o projeto **Runner** → target **Runner** → separador **Signing & Capabilities**
2. **Team:** escolhe a tua conta Apple Developer
3. **Bundle Identifier:** confirma que está `pt.drivetime.app`
4. Deixa **"Automatically manage signing"** ligado

### 6. Testar no iPad/iPhone (rápido)
1. Liga o iPad por cabo e confia no computador
2. No Xcode, escolhe o dispositivo no topo
3. **Run** (▶) — a app instala no iPad
   - Com Apple ID gratuito, a app dura 7 dias; com conta paga, normal

Ou por terminal:
```bash
flutter run --release
```

---

## Publicar na App Store (TestFlight → App Store)

### 1. Criar a app no App Store Connect
1. https://appstoreconnect.apple.com → **Apps** → **+** → **Nova app**
2. Plataforma: **iOS**
3. Nome: **Drive Time**
4. Idioma principal: **Português (Portugal)**
5. Bundle ID: **pt.drivetime.app** (regista-o antes em developer.apple.com → Identifiers, se não aparecer)
6. SKU: `drivetime` (qualquer identificador interno)

### 2. Gerar o build assinado
No Xcode:
1. Em cima, escolhe destino **"Any iOS Device (arm64)"**
2. Menu **Product → Archive**
3. Quando terminar, abre o **Organizer** → seleciona o archive → **Distribute App**
4. Escolhe **App Store Connect** → **Upload**

Ou por terminal:
```bash
flutter build ipa --release
```
O `.ipa` fica em `build/ios/ipa/`. Depois envia com **Transporter** (app gratuita da Apple) ou com o Xcode Organizer.

### 3. TestFlight
1. No App Store Connect → a tua app → **TestFlight**
2. O build aparece após processamento (alguns minutos)
3. Adiciona testadores (email) → eles instalam pela app **TestFlight** no iPhone/iPad

### 4. Submeter para a App Store
1. App Store Connect → **App Store** → preenche ficha (descrição, capturas, categoria, preço **19 €**)
2. Seleciona o build do TestFlight
3. **Enviar para revisão**

---

## Preço 19 € (app paga)

No App Store Connect:
1. A tua app → **Preços e disponibilidade**
2. Escolhe o escalão de preço mais próximo de **19 €**
3. Precisas de ter os **Acordos / Contratos pagos** assinados em **Business** (dados fiscais + bancários)

---

## Capturas de ecrã para a App Store

A Apple exige capturas de tamanhos específicos (diferentes do Android):
- **iPhone 6.9"** (ex.: 15 Pro Max): 1320 × 2868 px
- **iPad 13"** (se suportares iPad): 2064 × 2752 px

Podes tirá-las no **Simulador** do Xcode (Cmd+S) ou no iPad real.

---

## Login Google/Apple (opcional, só se quiseres ativar mais tarde)

A versão atual usa email/palavra-passe. Para ativar login Google no iOS:
1. Em Firebase Console → Definições do projeto → app iOS `pt.drivetime.app` → descarrega o novo `GoogleService-Info.plist` (terá `REVERSED_CLIENT_ID`)
2. Substitui o ficheiro em `ios/Runner/`
3. No `Info.plist`, atualiza o `CFBundleURLSchemes` com o novo `REVERSED_CLIENT_ID`
4. Liga o botão de login Google na interface (`lib/pages/loginpage/`)

Para **Sign in with Apple**: adiciona a capability **"Sign in with Apple"** em Signing & Capabilities (obrigatório se ativares login social na App Store).

---

## Resolução de problemas

| Erro | Solução |
|------|---------|
| `pod install` falha | `pod repo update` e repetir |
| "Signing requires a development team" | Escolhe a Team em Signing & Capabilities |
| "Bundle ID já em uso" | Já registaste o ID; usa o existente |
| Firestore não compila | O Podfile já fixa `FirebaseFirestore 11.13.0` via git |
| Ícone rejeitado (alpha) | O ícone 1024 não tem transparência — OK |

---

## Resumo rápido (no Mac)

```bash
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
# Xcode: Signing → Team → Run (testar) ou Product → Archive (publicar)
```
