# Drive Time — Play Store (guia completo)

Conta: **admin@drivetimeapp.com** · Programador: **DTerrível**  
App: **Drive Time** · Pacote: **pt.drivetime.app** · Preço: **19 €** (paga, vitalício)  
AAB: `dist/DriveTime-1.0.0-build10.aab` · Versão **1.0.0 (10)**

---

## Ficheiros no PC

| Ficheiro | Uso |
|----------|-----|
| `dist/DriveTime-1.0.0-build10.aab` | Upload Play Console |
| `play-store/icon-512.png` | Ícone 512×512 |
| `play-store/feature-graphic-1024x500.png` | Imagem destaque |
| Capturas de ecrã (telefone) | Mín. 2 |

---

## Ordem recomendada (13 tarefas do painel)

### 1. Política de privacidade
**Painel → Defina a Política de Privacidade**

```
https://drive-time-da85f.web.app/privacy-policy.html
```

Guardar.

---

### 2. Detalhes de início de sessão
- A app **requer** início de sessão? **Sim**
- Como: **email + palavra-passe** (Firebase Auth)
- Existe registo na app? **Sim**
- Credenciais de teste para revisores? **Opcional** — podes criar conta teste `reviewer@drivetimeapp.com` ou deixar nota com credenciais temporárias
- Restrições especiais (2FA empresa, etc.)? **Não**

---

### 3. Anúncios
- A app contém anúncios? **Não**

---

### 4. Classificação de conteúdo
Questionário IARC — respostas típicas:
- Violência, sexualidade, drogas, jogos de azar: **Não**
- Partilha localização / compras na app: **Não** (compra é preço da app na loja, não IAP)
- Email, nome: **Sim** (funcionalidade)
- Resultado esperado: classificação baixa (PEGI 3 / Todos)

---

### 5. Público-alvo
- Destinada a crianças? **Não**
- Grupo etário: **18 anos ou mais** (motoristas profissionais)

---

### 6. Segurança dos dados (Data safety)
| Pergunta | Resposta |
|----------|----------|
| Recolhe dados? | Sim |
| Encriptação em trânsito | Sim |
| Pedido de eliminação | Sim — email admin@drivetimeapp.com |
| Venda a terceiros / marketing | Não |
| Tipos | Email, nome, NIF, telefone, veículo, turnos/pausas, idioma/tema |
| Finalidade | Funcionalidade da app, gestão de conta |
| Contacto privacidade | admin@drivetimeapp.com |

---

### 7. Apps governamentais
- App governamental? **Não**

---

### 8. Funcionalidades financeiras
- App bancária / pagamentos / crypto? **Não**  
  (registo de horas TVDE não é serviço financeiro)

---

### 9. Saúde
- App de saúde? **Não**

---

### 10. Categoria e contacto
- Categoria: **Produtividade** ou **Ferramentas**
- Email: **admin@drivetimeapp.com**
- Site (opcional): https://drive-time-da85f.web.app/

---

### 11. Ficha da loja
**Aumentar número de utilizadores → Presença na loja → Ficha da loja principal**

**Descrição curta:**
```
Registo de turnos, pausas e relatórios para motoristas TVDE.
```

**Descrição completa:**
```
Drive Time é a aplicação de apoio ao registo de horas de trabalho para motoristas TVDE em Portugal.

FUNCIONALIDADES:
• Registo de turnos com início, pausa, retoma e fim
• Contagem de horas efectivas em tempo real
• Alertas informativos de tempo de condução
• Histórico dos últimos 7 dias
• Relatórios em PDF
• Dados de motorista e veículo
• Interface em português e inglês
• Modo claro e escuro

A app ajuda-te a organizar os teus registos de forma simples e profissional. Os totais e relatórios são informativos — deves sempre validar os registos e cumprir a legislação aplicável, incluindo os limites da Lei n.º 45/2018.

Suporte: admin@drivetimeapp.com
```

Upload: ícone, imagem destaque, 2+ capturas de ecrã.

---

### 12. Conta de comerciante + preço 19 €
**Obrigatório para app paga.**

1. Painel → **Criar uma conta de comerciante** (ou Definições → pagamentos)
2. IBAN, morada fiscal, NIF — dados da entidade que recebe
3. Depois: **Monetização** ou **Preços da app** → **Paga** → **19,00 €** (Portugal)

---

### 13. Upload AAB (testes internos)
**Testar e lançar → Testes → Testes internos → Criar versão**

- Upload: `DriveTime-1.0.0-build10.aab`
- Notas da versão:
```
Primeira versão — registo de turnos, pausas, histórico e relatórios PDF. Fecho automático de turno às 24h.
```
- **Rever versão** → **Implementar nos testes internos**

---

## Depois dos testes internos
1. Testes fechados (opcional, 12+ testers)
2. **Candidatar-se à produção**
3. **Produção** → nova versão ou promover → publicar

---

## Verificação pacote
Ao criar a app, nome do pacote: **pt.drivetime.app** (não alterável depois).
