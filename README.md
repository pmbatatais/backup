# 🏛️ Backup – Ambiente de Backup com REST Server, Restic e Backrest

Este documento consolida a **documentação oficial da Prefeitura Municipal de Batatais** referente ao ambiente padronizado de backup utilizado em todos os equipamentos institucionais.

---
## ✅ Público-alvo

Este manual é destinado a:

- Técnicos de infraestrutura
- Administradores de sistemas
- Operadores autorizados do TI
- Equipes que instalam, atualizam ou dão manutenção em servidores e estações corporativas
- Responsáveis por servidores **FreeBSD** ou ambientes integrados ao backup institucional

O conteúdo pressupõe conhecimentos básicos de:

- Shell
- Git
- Conceitos de rede (SSH, HTTP/HTTPS)
- Estrutura de permissões
- Noções de publicação via Nginx

---
## ✅ Requisitos para seguir o manual

Para executar os procedimentos aqui descritos, o operador deve possuir:

- Acesso administrativo ao servidor (root/administrator)
- Acesso à rede interna onde o **REST Server** está disponível
- Credenciais válidas para autenticação
- Acesso ao repositório Git com scripts oficiais
- Conhecimento básico de linha de comando e permissões

Requisitos adicionais caso envolva publicação via Nginx:

- Acesso ao servidor web
- Permissão para criar arquivos de domínio
- Permissão para criar ou renovar certificados SSL (Certbot)

---
## ✅ Responsabilidades do operador

O operador responsável pela implantação e manutenção deve:

- Garantir conectividade com o **REST Server**
- Acompanhar falhas recorrentes e verificar logs
- Manter as credenciais protegidas
- Criar datasets no local correto (FreeBSD/ZFS)
- Validar espaço em disco adequado para os repositórios
- Testar acesso local e remoto após publicações via Nginx
- Notificar o TI sobre inconsistências, anomalias ou incidentes
- Acompanhar mudanças estruturais (IP, DNS, certificados, permissões…)

---
## 🏛️ Padrões Técnicos da Prefeitura Municipal de Batatais

A Prefeitura adota um **layout técnico institucional** para garantir estabilidade, previsibilidade e continuidade.

Esses padrões incluem:

- Sistema operacional oficial: **FreeBSD**
- Sistema de arquivos oficial: **ZFS**
- Uso de **datasets individuais** por serviço
- Publicação HTTP/HTTPS via **Nginx** e certificado SSL **Let's Encrypt**
- Usuários e permissões mínimas por serviço

> ✅ **Seguir o layout institucional é obrigatório** se o servidor fará parte da infraestrutura oficial.

### ⚠️ Riscos de não seguir o layout:

- Incompatibilidade com automações
- Quebra de scripts oficiais
- Repositórios inacessíveis pelo Backrest
- Perda de integridade por ausência de ZFS
- Falta de suporte técnico interno
- Incompatibilidade com serviços como **Nextcloud**, GLPI, etc

Este manual assume **integralmente** o layout técnico institucional.  
Qualquer variação é feita por conta e risco do operador.

---
## 🧭 Introdução — Por que padronizamos este ambiente?

Durante anos, diferentes ferramentas de backup foram usadas na Prefeitura, mas muitas já não atendem às necessidades atuais, como:

- Crescimento do volume de arquivos
- Restaurações rápidas e confiáveis
- Segurança contra ataques modernos
- Auditoria simples
- Integridade e criptografia ponta a ponta

Ferramentas anteriores apresentaram limitações importantes.

---
### ❌ Cobian Backup via FTP

Ainda presente no setor de Compras, mas **não administrado pelo TI**.

Problemas principais:

- Uso de FTP (inseguro)
- Falta total de criptografia
- Restaurações lentas
- Estruturas inconsistentes
- Projeto abandonado

---
### ❌ Duplicati

Apesar da interface amigável, não é adequado ao ambiente institucional:

- Depende de banco de dados interno
- Travamentos em restaurações grandes
- Lentidão com grande volume de arquivos
- Inconsistências sob alta carga
- Manutenção complexa em escala

---
## 🔗 Arquitetura — Como tudo funciona

Após entendermos **por que** a Prefeitura precisa de um ambiente padronizado — segurança, simplicidade e menos erros — este tópico responde à pergunta:

✅ **Como essa padronização realmente funciona, na prática?**

A resposta está em um formato muito simples de entender:  
uma estrutura **central**, **padronizada** e **igual para todos**, formada por três partes que trabalham juntas:

> **REST Server (servidor central) + Restic (motor de backup) + Backrest (cliente de backup)**

Esse conjunto garante que _todos os setores_, _todas as máquinas_ e _todos os operadores_ sigam o mesmo modo de fazer o backup — sem invenções, sem métodos diferentes, sem complicações.

---
### 🖥️ 1. REST Server — Servidor central dedicado ao armazenamento

#### ✅ O que é?

O **REST Server** é um servidor leve e muito rápido que implementa a **API oficial do Restic**.

👉 **Na prática, o REST Server é o “cofre central” onde o backup é armazenado.**  
Ele não cria backup — ele _recebe_ e _armazena_. A operação é sempre no sentido **cliente → servidor**.

No ambiente da instituição, ele fica instalado em uma **máquina dedicada exclusivamente para isso**, disponível na rede para receber os backups dos clientes.

#### ✅ Por que ele é centralizado?

Ao manter um único ponto de armazenamento:

- O monitoramento é mais simples
- A administração do ambiente é facilitada
- Todos os setores seguem um padrão único
- Diminui-se a chance de erros causados por múltiplos sistemas independentes
- A segurança fica uniforme em toda a estrutura
- A manutenção é concentrada e mais eficiente

A centralização também permite que políticas de segurança, retenção e auditoria sejam aplicadas a todos os setores da mesma forma.

#### ✅ O que ele faz, na prática?

Sempre que um computador envia um backup, o **REST Server**:

1. **Recebe os dados criptografados**
2. **Armazena** no repositório correspondente
3. **Organiza** o conteúdo conforme a estrutura do Restic
4. **Registra** o recebimento
5. **Mantém o histórico** de versões anteriores (snapshots)

Importante: 
Ele recebe os dados **já criptografados**, portanto não acessa nem interpreta o conteúdo.  
Sua função é exclusivamente armazenar e disponibilizar o repositório quando solicitado.

---
### 📦 2. Restic — Ferramenta responsável pela preparação e envio dos dados

O **Restic** é o programa que _realmente cria os backups_.  
Ele é moderno, rápido e seguro. A documentação o define como:

- Um software de backup que funciona no Linux, Windows, macOS e BSD
- Capaz de enviar backups para vários tipos de armazenamento (local, nuvem, servidores próprios)
- Extremamente eficiente — só envia os pedaços dos arquivos que realmente mudaram
- Totalmente criptografado
- Permite verificar se o backup está saudável e restaurável
- É gratuito e de código aberto

👉 **Na prática, o Restic é o “motor” do backup.**  
Ele pega os arquivos da máquina e os envia ao servidor, de forma segura e **deduplicada**.

---
#### ✅ O que o Restic faz?

Ele executa cinco funções principais:

1. **Criptografia** dos dados localmente, antes de saírem da máquina
2. **Deduplicação**, evitando enviar arquivos já existentes no servidor
3. **Criação de snapshots**, que registram o estado dos arquivos em cada execução
4. **Envio seguro** ao *REST Server*
5. **Manutenção de histórico**, permitindo restaurar versões antigas

#### ✅ Como funciona a deduplicação

Se você tem:

- “relatório.xlsx” em uma pasta 'A'
- “relatório.xlsx” igual na pasta 'B'

Ele guarda **uma única vez** no servidor.

Isso economiza:

- Espaço ocupado no servidor
- Trafego de rede
- Tempo de backup
- Processamento no cliente

Restic é rápido, leve e altamente confiável, sendo eficiente mesmo em máquinas simples. Isso o torna adequado para computadores antigos ou com pouca memória.

---
### 🤖 3. Backrest — O cliente que organiza, agenda e gerencia os backups

O **Backrest** é um *cliente de backup* instalado junto com o **Restic** nos computadores dos setores.  
Enquanto o *Restic* é a ferramenta que realiza o backup, **o Backrest é quem gerencia quando e como ele deve acontecer**.

👉 **Na prática: o Backrest é o “cliente oficial” instalado nas máquinas da Prefeitura.**  
Ele faz o Restic funcionar automaticamente, sem que o usuário precise usar linha de comando.

#### ✅ O que o Backrest verifica?

- Horário programado do backup
- Pastas incluídas e excluídas
- Políticas de retenção
- Conectividade com o REST Server
- Falhas na execução anterior
- Alterações nos arquivos desde o último backup

---
#### ✅ O que o Backrest executa automaticamente?

- Programação e início do backup
- Execução completa do Restic
- Limpeza de versões antigas conforme a política
- Geração de novos snapshots
- Organização do repositório
- Reenvio em caso de falha temporária
- Registro detalhado no log do sistema

Para o usuário comum, o processo é invisível: ele simplesmente usa o computador normalmente enquanto o backup acontece em silêncio.

---
## 📡 4. Fluxo visual — desenhando o cenário na mente do leitor

Imagine o seguinte:


```scss
┌─────────────────────────────┐
│    Computadores dos setores │
│  (Admin., Obras, Saúde, etc)│
└───────────┬─────────────────┘
            │
            │ Backrest chama o Restic automaticamente
            ▼
┌─────────────────────────────┐
│        Restic               │
│ - Criptografa               │
│ - Deduplica                 │
│ - Cria snapshot             │
│ - Envia somente partes novas│
└───────────┬─────────────────┘
            │ (dados seguros e criptografados)
            ▼
┌─────────────────────────────┐
│        REST Server          │
│ - Recebe e armazena         │
│ - Mantém versões            │
│ - Não sabe o que tem dentro │
│ - Cofre central             │
└─────────────────────────────┘
```

O usuário final **não precisa fazer nada**.  
O operador técnico acompanha apenas logs, alertas e relatórios.

---
## 🛡️ Benefícios detalhados da arquitetura

### ✅ Segurança total

- Dados criptografados antes de sair do cliente
- REST Server não conhece o conteúdo
- Todos os repositórios são seguros contra leitura indevida

### ✅ Integridade e confiabilidade

- Cada snapshot é verificado
- Dados corrompidos são detectados
- Repositórios podem ser reparados

### ✅ Desempenho

- Envia apenas arquivos modificados
- Deduplicação reduz tráfego
- Backups são rápidos mesmo em HDs antigos

### ✅ Recuperação simples

- Restaurar um arquivo leva segundos
- Histórico de versões organizado
- Restaurar uma pasta inteira é instantâneo

### ✅ Padronização institucional

- Cada setor segue a mesma estrutura
- Scripts oficiais funcionam em todos os ambientes
- Treinamento simples para operadores

### ✅ Escalabilidade

- É simples adicionar novos setores
- Novos computadores entram no sistema rapidamente
- O servidor central escala com mais armazenamento

---
## 🚩 Conclusão

O ambiente **REST Server + Restic + Backrest** é a solução moderna, segura e institucional da Prefeitura Municipal de Batatais.

Ele substitui soluções antigas e oferece:

- Segurança
- Escalabilidade
- Confiabilidade
- Consistência
- Auditoria simplificada
- Restaurações rápidas
- Padronização total

---
## 📚 Referências

- FreeBSD Project — [https://www.freebsd.org/](https://www.freebsd.org/)
- REST Server — [https://github.com/restic/rest-server](https://github.com/restic/rest-server)
- Restic — [https://restic.net](https://restic.net)
- Backrest — [https://github.com/garethgeorge/backrest](https://github.com/garethgeorge/backrest)
- Let's Encrypt — [https://letsencrypt.org/about/](https://letsencrypt.org/about/)
- NGINX — [https://nginx.org/en/](https://nginx.org/en/)

---
## 🗃️ Documentação municipal

### ✅ 1. Instalação do REST Server

👉 **Tutorial Oficial:** [/backup-server](/backup-server)

### ✅ 2. Cliente de Backup – Backrest + Restic

👉 **Tutorial Oficial:** [/backup-client](/backup-client)

### ✅ 3. Como fazer backup

🚧 Em elaboração

### ✅ 4. Como restaurar dados

🚧 Em elaboração

### ✅ 5. Solução de problemas

🚧 Em elaboração

---
## 📜 Autor Técnico

**Leonardo Ribeiro**  
Setor de Tecnologia da Informação  
Prefeitura Municipal de Batatais

Responsável pela padronização, documentação e implantação da infraestrutura de backup.