# 🏛️ Backup – Ambiente de backup com REST Server, Restic e Backrest
Este repositório consolida a **documentação oficial da Prefeitura Municipal de Batatais** referente ao ambiente padronizado de backup utilizado em todos os equipamentos institucionais.

Nosso objetivo é garantir:

- ✅ Segurança da informação
- ✅ Uniformidade técnica
- ✅ Rastreabilidade
- ✅ Desempenho e escalabilidade
- ✅ Facilidade de manutenção
- ✅ Padronização entre setores

---
# 📚 Documentação municipal

### ✅ 1. Servidor de Backup – REST Server

👉 **Tutorial Oficial:** [https://github.com/pmbatatais/backup-server](https://github.com/pmbatatais/backup-server)

### ✅ 2. Cliente de Backup – Backrest + Restic

👉 **Tutorial Oficial:** [https://github.com/pmbatatais/backup-client](https://github.com/pmbatatais/backup-client)

### ✅ 3. Como fazer backup

🚧 _Documento em elaboração_

### ✅ 4. Como restaurar dados

🚧 _Documento em elaboração_

### ✅ 5. Solução de problemas

🚧 _Documento em elaboração_

---
# 🧭 Introdução — Por que padronizamos este ambiente?

Durante anos, diferentes ferramentas de backup foram utilizadas na Prefeitura, cada uma com limitações que já não atendem às demandas atuais, como:

- Crescimento do volume de arquivos
- Necessidade de restaurações rápidas e confiáveis
- Segurança contra ataques modernos
- Auditoria simples e padronizada
- Integridade e criptografia ponta a ponta

Ferramentas antigas apresentavam problemas significativos:

### ❌ Cobian Backup via FTP

Ainda presente no setor do Compras, mas **não administrado pelo TI**.  
Problemas principais:

- Uso de FTP (protocolo inseguro)
- Falta de criptografia
- Restaurações lentas
- Estrutura propensa a falhas
- Projeto abandonado

### ❌ Duplicati

Apesar da interface amigável, não é adequado para ambiente institucional:

- Depende de banco de dados interno
- Travamentos em restaurações grandes
- Lentidão sob alto volume
- Inconsistência em cargas elevadas
- Difícil manutenção em escala

---
## 🚀 A Solução Moderna Adotada

Para atender às necessidades institucionais, padronizamos um ambiente corporativo robusto:

### ✅ **REST Server + Restic + Backrest**

Essa combinação oferece:

- Criptografia ponta a ponta
- Deduplicação inteligente
- Snapshots versionados
- Padronização absoluta
- Restaurações rápidas
- Alta confiabilidade
- Baixo consumo de recursos
- Execução automatizada e auditável

---
## 🔗 Arquitetura — Como tudo funciona

Antes da implantação, é necessário entender o papel de cada componente:

|Componente|Função|Onde roda|
|---|---|---|
|**REST Server**|Armazenamento dos repositórios Restic|Servidor central|
|**Restic**|Motor de backup (criptografia, deduplicação, snapshots)|Estações/Servidores clientes|
|**Backrest**|Automação do Restic com interface Web|Estações/Servidores clientes|

Benefícios institucionais:

- ✅ Segurança elevada
- ✅ Restaurações rápidas e confiáveis
- ✅ Auditoria simples
- ✅ Padronização total
- ✅ Redução de espaço por deduplicação
- ✅ Resiliência contra falhas e ataques
- ✅ Independência entre setores e máquinas

---
## 🖥️ REST Server

🔗 [https://github.com/restic/rest-server](https://github.com/restic/rest-server)

O **REST Server** é o serviço responsável por hospedar os repositórios utilizados pelos clientes Restic.  
Ele **não executa backups por conta própria**: sua função é armazenar e organizar os dados enviados.

Principais características:

- ✅ Extremamente leve e rápido
- ✅ Consumo mínimo de recursos
- ✅ Alta confiabilidade
- ✅ Função exclusiva de servidor de armazenamento
- ✅ Implementa apenas o necessário para o Restic

> 🗂️ Pense nele como o _cofre institucional_ onde os backups ficam organizados.

---
## 🧩 Restic — Motor de Backup

🔗 Site oficial: [https://restic.net](https://restic.net)  
🔗 Repositório: [https://github.com/restic/restic](https://github.com/restic/restic)

O **Restic** é o responsável por toda a lógica de backup nas máquinas clientes.  
Ele garante:

- 🔒 Criptografia ponta a ponta
- 📦 Deduplicação inteligente
- 🔁 Snapshots versionados
- 🚀 Restaurações rápidas
- 🛠️ Operação estável sem banco de dados interno

Por que o Restic foi adotado?

- Altíssimo desempenho com milhões de arquivos
- Comportamento consistente em máquinas lentas
- Baixo risco de corrupção
- Arquitetura moderna e confiável

Fluxo simplificado:  
**Cliente → Criptografa + Deduplica → Envia ao REST Server**

---
## 📦 Backrest — Cliente Padronizado de Backup

🔗 Repositório: [https://github.com/garethgeorge/backrest](https://github.com/garethgeorge/backrest)  
🔗 Documentação: [https://garethgeorge.github.io/backrest/introduction/getting-started/](https://garethgeorge.github.io/backrest/introduction/getting-started/)

O **Backrest** é o cliente corporativo responsável por operar o Restic automaticamente em todas as máquinas da Prefeitura.

Motivos da adoção:

- ✅ Executa backups de forma automatizada
- ✅ Trabalha como serviço silencioso
- ✅ Registra logs estruturados para auditoria
- ✅ Gerencia políticas de retenção
- ✅ Mantém a padronização entre setores

Funções automáticas:

- Inclusão/exclusão de diretórios configurados pelo TI
- Execução regular dos backups
- Limpeza do repositório com base nas políticas
- Administração dos parâmetros do Restic
- Funcionamento contínuo sem intervenção do usuário

---
# 🚩 Conclusão

O ambiente **REST Server + Restic + Backrest** representa a **solução institucional moderna e definitiva** adotada pela Prefeitura Municipal de Batatais.

Ele substitui por completo soluções antigas como Cobian FTP e Duplicati, oferecendo:

- Segurança
- Escalabilidade
- Confiabilidade
- Consistência
- Auditoria simplificada
- Restaurações rápidas e estáveis
- Padronização entre todos os setores

---
# 📢 Créditos

- **REST Server** — [https://github.com/restic/rest-server](https://github.com/restic/rest-server)
- **Restic** — [https://restic.net](https://restic.net)
- **Backrest** — [https://github.com/garethgeorge/backrest](https://github.com/garethgeorge/backrest)

---
# 📜 Autor Técnico

**Leonardo Ribeiro**  
Setor de Tecnologia da Informação  
Prefeitura Municipal de Batatais

Responsável pela padronização do ambiente de backup, documentação técnica e implantação da infraestrutura.
