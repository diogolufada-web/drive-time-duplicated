# Drive Time — O que levar / ter pronto (1 página)

## No telemóvel (notas)
- Apple ID + password
- Código 2FA
- Email admin@drivetimeapp.com

## Físico
- [ ] iPhone + cabo
- [ ] Mac + carregador
- [ ] Wi‑Fi

## Contas (activar antes)
- [ ] Apple Developer (99 €/ano)
- [ ] App Store Connect — app **Drive Time** criada
- [ ] Bundle ID **pt.drivetime.app** registado
- [ ] Contrato **Paid Apps** + IBAN (se 19 €)

## Projecto
- [ ] Pasta ou `git clone` com branch estável
- [ ] Ficheiros: `docs/IOS_FAST_TRACK.md`, `scripts/mac_ios_build.sh`

## URLs (testar no browser)
- [ ] https://drive-time-da85f.web.app/privacy-policy.html

## No Mac — 4 comandos
```bash
cd drive-time-duplicated
./scripts/mac_ios_build.sh prep
open ios/Runner.xcworkspace
# Signing → Team → Run ▶ no iPhone
# Product → Archive → Upload TestFlight
```

## Antes de submeter revisão App Store
- [ ] Criar conta `reviewer@drivetimeapp.com` + password em `app-store-connect/review-notes.txt`
- [ ] 3–5 capturas de ecrã (1290×2796)
- [ ] Ícone 1024×1024 (já no Xcode Assets)
