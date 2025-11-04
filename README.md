# 🚀 Backup – Ambiente de Backup com Rest Server, Restic e Backrest
Este repositório reúne **toda a documentação oficial da Prefeitura de Batatais** sobre o ambiente de backup padronizado, incluindo:

✅ Explicação clara dos componentes  
✅ Tutoriais de instalação  
✅ Exemplos de configuração  
✅ Como fazer backup  
✅ Como restaurar  
✅ Boas práticas

---
## 📚 Documentação oficial da Prefeitura

### ✅ 1. Instalação do Servidor (REST Server)  
[**➡️ Acessar Tutorial**](https://github.com/pmbatatais/backup-server)

### ✅ 2. Instalação do Cliente (Backrest + Restic)  
[**➡️ Acessar Tutorial**](https://github.com/pmbatatais/backup-client)

### ✅ 3. Como Fazer Backup  
🚧 *Em desenvolvimento*

### ✅ 4. Como Restaurar  
🚧 *Em desenvolvimento*

### ✅ 5. Solução de Problemas  
🚧 *Em desenvolvimento*

---
## 🔎 Sobre o REST Server, o Restic Backup e o cliente Backrest

Antes de configurar o ambiente, é importante entender o papel de cada componente no processo de backup:

|Componente|Função|Onde roda|
|---|---|---|
|**REST Server**|Servidor de armazenamento|No servidor|
|**Restic**|Motor de backup (criptografia + deduplicação)|No cliente|
|**Backrest**|Cliente que usa o Restic internamente|No cliente|

Essa separação ajuda a compreender como tudo funciona “por baixo dos panos”.

---
## 🖥️ REST Server (Servidor de Repositórios Restic)
🔗 **Site oficial:** [https://github.com/restic/rest-server](https://github.com/restic/rest-server)

O **REST Server** é um servidor HTTP minimalista e de alta performance, projetado exclusivamente para hospedar **repositórios do Restic**.  
Ele implementa apenas o necessário da API REST do Restic, permitindo que qualquer cliente Restic envie, liste ou recupere dados via HTTPS.

✅ É **somente o servidor**  
✅ Não faz backup por conta própria  
✅ Não criptografa nem deduplica  
✅ Apenas **recebe e organiza** os dados enviados pelo Restic

Ideal para instituições que precisam de:

- Servidor centralizado
- Alto desempenho
- Baixo consumo
- Simplicidade de manutenção

---
## 🧩 Restic (Motor de Backup)

🔗 **Site oficial:** [https://restic.net/](https://restic.net/)  
🔗 **GitHub:** [https://github.com/restic/restic](https://github.com/restic/restic)

O **Restic** é a ferramenta principal de backup. Ele é responsável por:

- 🔒 Criptografar os dados **no cliente**;
- 📦 Realizar deduplicação de blocos;
- 🔁 Manter histórico de versões;
- 🗂️ Organizar snapshots no repositório;
- 🔍 Restaurar arquivos rapidamente;

> **Restic = Inteligência do backup**
> **REST Server = Onde os backups ficam guardados**

Fluxo:

`Cliente Restic  →  Criptografa + Deduplica  →  Envia para o REST Server`

---
## 📦 Backrest (Cliente de backup usado pela Prefeitura)

🔗 **Repositório:** [https://github.com/garethgeorge/backrest](https://github.com/garethgeorge/backrest)  
🔗 **Documentação:** [https://garethgeorge.github.io/backrest/introduction/getting-started/](https://garethgeorge.github.io/backrest/introduction/getting-started/)

O **Backrest** é um cliente simplificado que automatiza o uso do Restic.  
Ele foi criado para ambientes corporativos que precisam de:

✅ Execução automática  
✅ Configuração centralizada (YAML)  
✅ Execução como serviço  
✅ Logs organizados

Ele faz:

- Agendamentos
- Políticas de retenção
- Inclusão/exclusão de diretórios
- Configuração das variáveis do Restic
- Execução silenciosa em segundo plano

Por isso é ideal para parques tecnológicos padronizados como o da **Prefeitura Municipal de Batatais**.

---
## ✅ Como tudo funciona junto

Fluxo completo:

`Backrest (cliente)        ↓ Restic (motor do backup)       ↓ Criptografa + Deduplica       ↓ REST Server (servidor de armazenamento)`

---
## ✅ Créditos

- **Rest Server** – [https://github.com/restic/rest-server](https://github.com/restic/rest-server)
- **Restic** – [https://restic.net](https://restic.net)
- **Backrest** – [https://github.com/garethgeorge/backrest](https://github.com/garethgeorge/backrest)

---
## **📜 Autor**

**Leonardo Ribeiro**  
Prefeitura Municipal de Batatais  
Responsável técnico pela padronização dos sistemas de backup e infraestrutura de servidores.
