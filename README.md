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
## 📚 Documentação municipal

### ✅ 1. Servidor de Backup – REST Server

👉 **Tutorial Oficial:** [https://github.com/pmbatatais/backup/backup-server](/backup-server)

### ✅ 2. Cliente de Backup – Backrest + Restic

👉 **Tutorial Oficial:** [https://github.com/pmbatatais/backup/backup-client](/backup-client)

### ✅ 3. Como fazer backup

🚧 _Documento em elaboração_

### ✅ 4. Como restaurar dados

🚧 _Documento em elaboração_

### ✅ 5. Solução de problemas

🚧 _Documento em elaboração_

---
## 🧭 Introdução — Por que padronizamos este ambiente?

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
## 🏢 Ambiente atual da infraestrutura de backup

A Prefeitura Municipal de Batatais atualmente possui dois cenários distintos de armazenamento e proteção de dados. A compreensão desse cenário é essencial para justificar a padronização definida neste repositório.

### **1) Servidor de Arquivos — Secretaria de Obras e Planejamento**

Foi implantado um servidor dedicado com a seguinte estrutura:

- **Sistema Operacional:** Debian 12
- **Local**: Secretaria de Obras e Planejamento
- **IP**: 192.168.1.11
- **Interface gráfica:** habilitada
- **Compartilhamento:** via Samba
- **Uso:** armazenamento de arquivos setoriais
- **Backup:** automatizado pelo **Backrest**, enviando dados a cada **4 horas** para o **REST Server oficial** localizado no prédio da Prefeitura.

Este ambiente já segue a **padronização institucional**, utilizando o conjunto Backrest + Restic + REST Server.

---
### **2) Servidor de Arquivos — Secretaria de Administração**

Existe outro servidor utilizado exclusivamente por:

- Setor de Compras
- Secretário de Administração
- Diretor do setor

Condições operacionais:

- **Sistema Operacional:** Windows 7 (desatualizado)
- **Backup:** Cobian Backup
- **Método de envio:** FTP para espaço fornecido pela empresa Com4
- **Acesso técnico:** **inexistente**.
    
    - O acesso via AnyDesk, anteriormente configurado, foi removido sem documentação.
    - Não existe controle técnico, auditoria ou monitoramento do ambiente.

Esse cenário é **crítico**, pois não há garantia de integridade, segurança, atualização ou rastreabilidade. Incidentes como corrupção de arquivos, falhas ou malware podem ocorrer sem detecção.

### ⚠️ Sobre responsabilidade técnica

Ambientes que **não seguem a padronização** e nos quais o TI **não possui acesso administrativo**:

- **não podem ser monitorados**,
- **não podem ser auditados**,
- **não oferecem segurança mínima**,
- **não podem ter sua integridade assegurada**.

Portanto, o TI **não pode ser responsabilizado por qualquer perda, falha ou incidente** relacionado aos equipamentos fora deste ambiente padronizado.
Recomenda-se a **migração imediata** desse servidor para a solução corporativa definida nesta documentação.

---
### ⭐ Conclusão desta seção

O cenário atual demonstra a necessidade urgente de:

- Centralização
- Padronização
- Criptografia ponta a ponta
- Controle técnico
- Auditoria
- Backup institucional monitorado

A partir deste documento, **o único ambiente oficialmente suportado** é o modelo baseado em:

✅ **REST Server + Restic + Backrest**  
(com diretrizes, padrões, processos e responsabilidades definidos aqui.)

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
## 🚩 Conclusão

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
## 📢 Créditos

- **REST Server** — [https://github.com/restic/rest-server](https://github.com/restic/rest-server)
- **Restic** — [https://restic.net](https://restic.net)
- **Backrest** — [https://github.com/garethgeorge/backrest](https://github.com/garethgeorge/backrest)

---
## 📜 Autor Técnico

**Leonardo Ribeiro**  
Setor de Tecnologia da Informação  
Prefeitura Municipal de Batatais

Responsável pela padronização do ambiente de backup, documentação técnica e implantação da infraestrutura.
