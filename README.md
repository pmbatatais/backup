# 🏛️ Backup – Ambiente de backup com REST Server, Restic e Backrest
Este repositório consolida a **documentação oficial da Prefeitura Municipal de Batatais** referente ao ambiente padronizado de backup utilizado nos equipamentos institucionais.  

O objetivo é garantir **uniformidade**, **segurança da informação**, **rastreabilidade** e **facilidade de manutenção** em toda a infraestrutura municipal.

Nosso objetivo é oferecer um ambiente:

- ✅ Seguro  
- ✅ Confiável  
- ✅ Escalável  
- ✅ Fácil de administrar  
- ✅ Padronizado entre todos os setores  

Este material inclui:

- Descrição dos componentes do sistema 
- Instalação completa do servidor e clientes
- Diretrizes oficiais adotadas pelo Setor de TI

---
## 📚 Documentação oficial da Prefeitura

### ✅ 1. Instalação do Servidor (REST Server)
👉 [**Acessar Tutorial Oficial**](https://github.com/pmbatatais/backup-server)

### ✅ 2. Instalação do Cliente (Backrest + Restic)
👉 [**Acessar Tutorial Oficial**](https://github.com/pmbatatais/backup-client)

### ✅ 3. Como fazer backup
🚧 _Documento em elaboração_

### ✅ 4. Como restaurar dados
🚧 _Documento em elaboração_

### ✅ 5. Solução de Problemas
🚧 _Documento em elaboração_

---
## 🧭 Introdução — Por que padronizamos este ambiente?

Ao longo dos anos, diversas tecnologias de backup foram utilizadas ou testadas na Prefeitura.  
Algumas funcionaram bem no passado, mas não atendem mais às exigências atuais de:

- Grande volume de arquivos  
- Necessidade de restaurações rápidas  
- Segurança contra ataques recentes  
- Simplicidade de auditoria  
- Integridade dos dados  
- Criptografia e proteção legal  

As ferramentas legadas incluíam:
### ❌ Cobian Backup via FTP

Ainda presente no setor de Compras (mas **não administrado pelo TI**).  
Problemas:

- Sem criptografia  
- FTP é inseguro e obsoleto  
- Restaurações lentas  
- Estrutura frágil  
- Projeto abandonado  

### ❌ Duplicati 
Pontos positivos: fácil instalação e interface bonita.  
Mas apresenta falhas graves em ambientes institucionais:

- Depende de banco de dados interno
- Restaurações grandes podem travar por horas
- Inconsistência de dados com volumes elevados
- Lentidão significativa
- Alta taxa de falhas sob carga
- Dificuldade de manutenção  

---
## 🚀 A solução moderna

Para substituir todas as tecnologias antigas e garantir **robustez**, a Prefeitura adotou um conjunto moderno e corporativo:
### **REST Server + Restic + Backrest**

---
## 🔗 Visão Geral - Como tudo funciona

Antes da implantação, é essencial compreender o papel de cada elemento na arquitetura.

> 🧠 Repositório é o **local onde os backups ficam armazenados** no servidor **REST Server**.

| Componente      | Função                                                   | Local de Execução            |
| --------------- | -------------------------------------------------------- | ---------------------------- |
| **REST Server** | Armazenamento dos repositórios Restic                    | Servidor central             |
| **Restic**      | Motor de backup (criptografia, deduplicação e snapshots) | Estações/Servidores clientes |
| **Backrest**    | Cliente WEB que opera o Restic automaticamente           | Estações/Servidores clientes |

Benefícios institucionais:

- ✅ Segurança elevada
- ✅ Padronização absoluta
- ✅ Facilidade de auditoria
- ✅ Restaurações rápidas
- ✅ Redução de espaço por deduplicação
- ✅ Resiliência contra ataques e corrupção
- ✅ Independência entre setores e máquinas

---
## 🖥️ REST Server (Servidor de Repositórios Restic)

🔗 **Site oficial:** [https://github.com/restic/rest-server](https://github.com/restic/rest-server)

O **REST Server** é o serviço responsável por hospedar os **[^1]repositórios** utilizados pelos clientes Restic. Ele **não faz backup por si só**: apenas recebe e organiza os dados enviados pelos clientes.
REST Server foi projetado para ser **leve**, **eficiente** e altamente confiável, implementando apenas o necessário da API REST utilizada pelo Restic.

Características principais:

- ✅ Projeto ativo e confiável
- ✅ Extremamente leve
- ✅ Altíssimo desempenho
- ✅ Função estritamente de **servidor de armazenamento**
- ✅ Opera com baixo consumo de recursos
- ✅ Ideal para ambientes corporativos com alta demanda de padronização

Este é o componente central que recebe, organiza e mantém os dados enviados pelos clientes autorizados.

🗂️ **Pense nele como o “armário seguro” onde os backups ficam organizados.**

---
## 🧩 Restic (Motor de backup)

🔗 **Site oficial:** [https://restic.net/](https://restic.net/)  
🔗 **GitHub:** [https://github.com/restic/restic](https://github.com/restic/restic)

O **Restic** é a ferramenta principal de backup utilizada nas máquinas da Prefeitura.  
Ele é o responsável por todos os mecanismos críticos de segurança e eficiência, entre eles:

- 🔒 **Criptografia ponta a ponta** (os dados são protegidos antes mesmo de deixar o cliente)
- 📦 **Deduplicação** (reduz espaço de armazenamento)
- 🔁 **Snapshots versionados**
- 🗂️ Organização do repositório remoto
- 🔍 Processos rápidos de restauração
### Por que Restic?

- Extremamente rápido mesmo com milhões de arquivos;
- Restaurações confiáveis e instantâneas;
- Sem banco interno → **nada corrompe**  
- Arquitetura moderna;
- Adequado para máquinas lentas e redes mistas;

Fluxo simplificado:

`Cliente Restic  →  Criptografa + Deduplica  →  Envia ao REST Server`

---
## 📦 Backrest (Cliente de Backup Padronizado da Prefeitura)

🔗 **Repositório oficial:** [https://github.com/garethgeorge/backrest](https://github.com/garethgeorge/backrest)  
🔗 **Documentação:** [https://garethgeorge.github.io/backrest/introduction/getting-started/](https://garethgeorge.github.io/backrest/introduction/getting-started/)

O **Backrest** é o cliente de backup corporativo utilizado nos computadores da Prefeitura.  
Ele garante que **toda máquina** da Prefeitura execute backups regularmente sem intervenção do usuário.

Ele foi adotado devido a:
  
- ✅ Operação automatizada por serviço  
- ✅ Logs organizados para auditoria  
- ✅ Suporte a políticas de retenção  
- ✅ Baixa intervenção do usuário  
- ✅ Padronização entre setores e secretarias

O Backrest realiza automaticamente:

- Inclusão/exclusão de diretórios definidos pelo administrador
- Execução periódica de backups
- Limpeza automatizada conforme política de retenção
- Administração das variáveis e parâmetros do Restic
- Funcionalidade silenciosa em segundo plano

Essa ferramenta garante que o ambiente institucional siga práticas modernas de backup, reduzindo riscos de perda de dados e assegurando governança.

---
## ✅ Conclusão

O ambiente REST Server + Restic + Backrest representa a **melhor solução moderna** para proteger os dados da Prefeitura Municipal de Batatais.

Ele supera completamente tecnologias antigas como **Cobian FTP** e **Duplicati**, oferecendo um sistema:

- Seguro
- Integrado  
- Escalável
- Altamente confiável
- Simples de administrar

---
## ✅ Créditos

- **REST Server** – [https://github.com/restic/rest-server](https://github.com/restic/rest-server)
- **Restic** – [https://restic.net](https://restic.net)
- **Backrest** – [https://github.com/garethgeorge/backrest](https://github.com/garethgeorge/backrest)

---
## 📜 Autor Técnico

**Leonardo Ribeiro**  
*Setor de Tecnologia da Informação*
Prefeitura Municipal de Batatais 
Responsável pela padronização do ambiente de backup, documentação técnica e implantação da infraestrutura.

[^1]: O repositório é o **local onde os backups ficam armazenados** no servidor **REST Server**.
