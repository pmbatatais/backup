# 🏛️ Backup – Ambiente de Backup com REST Server, Restic e Backrest

Este documento detalha a concepção do ambiente de backup da **Prefeitura Municipal de Batatais**, apresentando seus **principais componentes — FreeBSD, ZFS, REST Server, Restic e Backrest —** e explicando como eles se conectam para formar uma **estrutura padronizada e confiável de proteção de dados**.

> ℹ️ **Notas importantes:**
> 
> - A instalação do **Backrest** ou do **REST Server** **não deve ser realizada de forma isolada**; é fundamental compreender previamente a arquitetura e o modelo de funcionamento institucional descritos neste documento.
> - A documentação completa sobre **instalação, operação e manutenção** está disponível na seção **Documentação Municipal**.

---
🧠 Alguns termos técnicos podem ser novos para parte dos leitores. Para facilitar a compreensão, todas as expressões técnicas utilizadas estão explicadas de forma clara no **Glossário Técnico**, ao final do documento.

---
## ⚠️ Definição do Escopo de Backup e Política de Dados Críticos (Gestão de TI)

O ambiente de backup (Backrest/Restic) não se destina à **instalação indiscriminada** em todas as máquinas clientes. O foco é em **máquinas clientes com dados críticos (servidores de arquivos SAMBA ou computadores clientes)**, desde que determinados e priorizados pela Gestão de Informática.

### Estratégia para Setores com alta carga de dados críticos:

Se um determinado setor ou secretaria possui uma alta carga de dados críticos, o ideal é que a Gestão de T.I. implemente um **servidor de arquivos SAMBA local** (utilizando a base **FreeBSD + ZFS**) e que o cliente de backup (**Backrest/Restic**) seja instalado neste servidor, centralizando a proteção dos dados.

### Política de Responsabilidade de Dados:

A Gestão de T.I deverá criar um **documento oficial** para que os setores/secretarias estejam cientes da obrigatoriedade de **salvar dados no servidor de arquivos** designado. Se o usuário optar por não salvar dados nos repositórios oficiais (servidores de arquivos), a Gestão de T.I **não se responsabilizará pelos dados perdidos**.

---
## 🏛️ Padrões Técnicos da Prefeitura Municipal de Batatais

A Prefeitura adota um **layout técnico institucional** para garantir estabilidade, previsibilidade e continuidade.

Esses padrões incluem:
*   Sistema operacional oficial: **FreeBSD**
*   Sistema de arquivos oficial: **ZFS**
*   Uso de **datasets individuais** por serviço
*   Publicação HTTP/HTTPS via **Nginx** e certificado SSL **Let's Encrypt**
*   Usuários e permissões mínimas por serviço

>✅ **Seguir o layout institucional é obrigatório** se o servidor fará parte da infraestrutura oficial.

##### ⚠️ Riscos de não seguir o layout:
*   Incompatibilidade com automações
*   Quebra de scripts oficiais
*   Repositórios inacessíveis pelo Backrest
*   Perda de integridade por ausência de ZFS
*   Falta de suporte técnico interno
*   Incompatibilidade com serviços como **Nextcloud** , GLPI, etc

Este manual assume **integralmente** o layout técnico institucional.
Qualquer variação é feita por conta e risco do operador.

---
### ✅ Público-alvo

Este manual é destinado a:
*   Técnicos de infraestrutura
*   Administradores de sistemas
*   Operadores autorizados do TI
*   Equipes que instalam, atualizam ou dão manutenção em servidores e estações corporativas
*   Responsáveis por servidores **FreeBSD** ou ambientes integrados ao backup institucional

O conteúdo pressupõe conhecimentos básicos de:
*   Shell
*   Git
*   Conceitos de rede (SSH, HTTP/HTTPS)
*   Estrutura de permissões
*   Noções de publicação via Nginx

---
### ✅ Requisitos para seguir o manual

Para executar corretamente os procedimentos descritos neste manual, o operador deve possuir:
*   **Acesso administrativo** ao sistema onde atuará (root no FreeBSD ou administrador no Windows).
*   **Conectividade** com a rede interna que hospeda o **REST Server**.
*   **Credenciais válidas** para autenticação nos repositórios.
*   **Acesso ao repositório Git oficial** , de onde são obtidos scripts e arquivos padronizados.
*   **Conhecimentos básicos de linha de comando** , permissões, caminhos de arquivos e redes.

Se o ambiente envolver publicação via **Nginx** , também são necessários:
*   Acesso ao servidor web.
*   Permissão para manipular arquivos de domínio.
*   Permissão para criar/renovar certificados SSL via Certbot.

> **Resumo:**
>O operador precisa ter acesso, conectividade e conhecimento suficiente para seguir o passo a passo sem supervisão constante.

---
### ✅ Responsabilidades do operador

O operador responsável pela implantação e manutenção deve:
*   Garantir conectividade com o **REST Server**
*   Acompanhar falhas recorrentes e verificar logs
*   Manter as credenciais protegidas
*   Criar datasets no local correto (FreeBSD/ZFS)
*   Validar espaço em disco adequado para os repositórios
*   Testar acesso local e remoto após publicações via Nginx
*   Notificar o TI sobre inconsistências, anomalias ou incidentes
*   Acompanhar mudanças estruturais (IP, DNS, certificados, permissões…)

---
## 🧭 Introdução — Por que padronizamos este ambiente?

Durante anos, a Prefeitura utilizou diferentes ferramentas de backup, sistemas operacionais e estruturas de arquivos; cada setor trabalhava com sua própria combinação — versões diversas de Windows, servidores improvisados, partições pouco organizadas e softwares incompatíveis entre si. 

Esse cenário, quando não padronizado, pode gerar vários problemas, como:
*   **Dificuldade de auditoria**
*   **Aumento do risco de falhas operacionais**
*   **Restaurações mais lentas ou inconsistentes**
*   **Maior exposição a falhas de segurança**

Com o tempo, também se identificou que:
*   Algumas ferramentas antigas não lidam bem com grande volume de dados
*   Sistemas de arquivos diferentes entre setores podem gerar inconsistências
*   Protocolos inseguros, como FTP, podem comprometer a confidencialidade
*   Métodos sem criptografia ou verificação de integridade podem afetar a confiabilidade do backup

---
#### ❌ Cobian Backup via FTP

Ainda presente no setor de Compras, mas **não administrado pelo TI**.

Problemas principais:
*   Uso de FTP (inseguro)
*   Falta total de criptografia
*   Restaurações lentas
*   Estruturas inconsistentes
*   Projeto abandonado

---
#### ❌ Duplicati

Apesar da interface amigável, não é adequado ao ambiente institucional:
*   Depende de banco de dados interno
*   Travamentos em restaurações grandes
*   Lentidão com grande volume de arquivos
*   Inconsistências sob alta carga
*   Manutenção complexa em escala

---
#### ❌ Sistemas Operacionais Windows antigos (Windows 7, 8, 8.1, 10)

Problemas comuns:
*   Sem suporte oficial
*   Falhas de segurança conhecidas
*   VSS instável ou quebrado
*   Drivers sem atualização
*   Perigo para backup e restauração

---
## 🔗 Arquitetura — Como tudo funciona

Após entendermos por que a Prefeitura precisa de um ambiente padronizado — segurança, simplicidade e menos erros — este tópico responde:

✅ **Como essa padronização realmente funciona, na prática?**

O ambiente foi construído com uma arquitetura simples e extremamente confiável:
uma estrutura central, padronizada e igual para todos, composta por **quatro partes fundamentais** :

*   **😈 FreeBSD + ZFS** — Sistema operacional extremamente resiliente com filesystem de integridade avançada.
*   **📡 REST Server** — Servidor central de recebimento e armazenamento dos dados criptografados.
*   **⚙️ Restic** — Responsável por criar, deduplicar e enviar os dados com segurança.
*   **🤖 Backrest** — Cliente de backup responsável por gerencia horários, políticas, pastas e o fluxo completo de backups.

Essa combinação garante que **todos os setores** sigam um padrão único de operação: o backup ocorre sempre da mesma forma e sobre a mesma base tecnológica. Com o servidor central padronizado em FreeBSD e ZFS, o ambiente torna-se mais estável e seguro, reduzindo variações entre sistemas e assegurando que todo o processo de backup funcione de maneira uniforme e confiável em toda a Prefeitura.

---
### 😈 1. FreeBSD + ZFS — Por que esta é a base do servidor de backup e dos servidores de arquivos críticos?

O **FreeBSD** é um sistema operacional amplamente utilizado em servidores, reconhecido pela sua estabilidade, simplicidade e comportamento previsível.

Diferentemente do Windows, voltado ao uso geral, e do Linux, que possui diversas distribuições com características distintas, o **FreeBSD** mantém um padrão único — kernel e ferramentas evoluem juntos, oferecendo um ambiente mais coeso e confiável para serviços críticos como backup e **serviços de arquivos Samba**.

Embora o **Linux** , especialmente o **Debian com btrfs** , também seja recomendado por sua estabilidade e amplo suporte, os manuais da **Prefeitura Municipal de Batatais** **não abordarão a instalação do REST Server ou servidores de arquivos em Linux** , focando exclusivamente na solução oficial adotada.

A escolha do **FreeBSD + ZFS** como base do **REST Server** e dos servidores de arquivos (via Samba) se fundamenta em pontos amplamente reconhecidos:
*   **Confiabilidade elevada:** pilha de rede estável e comportamento consistente em produção.
*   **ZFS robusto:** sistema de arquivos empresarial, com verificação de integridade, correção automática e snapshots nativos.
*   **Uso consolidado:** presente em datacenters, appliances profissionais e serviços de alta disponibilidade, como TrueNAS.
*   **Maior maturidade:** ZFS, criado pela Sun/Oracle, é mais estável e confiável que btrfs em ambientes corporativos.

Assim, a arquitetura do ambiente não depende apenas das ferramentas de backup (Restic e Backrest), mas também de uma base sólida no próprio sistema operacional — garantindo segurança, previsibilidade e resiliência ao servidor de backup, **e também aos servidores de arquivos que hospedam os dados críticos**.

---
### 📡 1. REST Server — Servidor central dedicado ao armazenamento

O **REST Server** é um servidor leve e muito rápido que implementa a **API oficial do Restic**.
👉 **Na prática, o REST Server é o “cofre central” onde o backup é armazenado**.

Ele não cria backup — ele *recebe* e *armazena*. A operação é sempre no sentido **cliente → servidor**.

No ambiente da instituição, ele fica instalado em uma **máquina dedicada exclusivamente para isso** , disponível na rede para receber os backups dos clientes.

---
###### 🤷‍♂️ Por que ele é centralizado?

Ao manter um único ponto de armazenamento:
*   O monitoramento é mais simples
*   A administração do ambiente é facilitada
*   Todos os setores seguem um padrão único
*   Diminui-se a chance de erros causados por múltiplos sistemas independentes
*   A segurança fica uniforme em toda a estrutura
*   A manutenção é concentrada e mais eficiente

A centralização também permite que políticas de segurança, retenção e auditoria sejam aplicadas a todos os setores da mesma forma.
###### 🏃 O que ele faz, na prática?

Sempre que um computador (ou servidor SAMBA de dados críticos) envia um backup, o **REST Server** :
1.  **Recebe os dados criptografados**
2.  **Armazena** no repositório correspondente
3.  **Organiza** o conteúdo conforme a estrutura do Restic
4.  **Registra** o recebimento
5.  **Mantém o histórico** de versões anteriores (snapshots)

> 🚨 Importante:
> Ele recebe os dados **já criptografados** , portanto não acessa nem interpreta o conteúdo.
>Sua função é exclusivamente armazenar e disponibilizar o repositório quando solicitado.

---
### ⚙️ 2. Restic — Ferramenta responsável pela preparação e envio dos dados

O **Restic** é o programa que *realmente cria os backups*.

Ele é moderno, rápido e seguro. A documentação oficial o define como:
*   Um software de backup que funciona no Linux, Windows, macOS e BSD
*   Capaz de enviar backups para vários tipos de armazenamento (local, nuvem, servidores próprios)
*   Extremamente eficiente — só envia os pedaços dos arquivos que realmente mudaram
*   Totalmente criptografado
*   Permite verificar se o backup está saudável e restaurável
*   É gratuito e de código aberto

> 👉 **Na prática, o Restic é o “motor” do backup**.
> Ele pega os arquivos da máquina (ou do servidor SAMBA local) e os envia ao servidor, de forma segura e **deduplicada**.


**Referência:** 
Documentação oficial do Restic – _Introduction_.
Disponível em: [https://restic.net/](https://restic.net/). Acesso em: 04 nov. 2025.

---
###### ✅ O que o Restic faz?

Ele executa cinco funções principais:
1.  **Criptografia** dos dados localmente, antes de saírem da máquina
2.  **Deduplicação** , evitando enviar arquivos já existentes no servidor
3.  **Criação de snapshots** , que registram o estado dos arquivos em cada execução
4.  **Envio seguro** ao *REST Server*
5.  **Manutenção de histórico** , permitindo restaurar versões antigas

Restic é rápido, leve e altamente confiável, sendo eficiente mesmo em máquinas simples. Isso o torna adequado para computadores antigos ou com pouca memória.

---
### 🤖 3. Backrest — O cliente que organiza, agenda e gerencia os backups

O **Backrest** é um *cliente de backup* instalado junto com o **Restic** nos computadores dos setores, **focado nas máquinas com dados críticos ou nos servidores de arquivos SAMBA**.
Enquanto o *Restic* é a ferramenta que realiza o backup, **o Backrest é quem gerencia quando e como ele deve acontecer**.

>👉 **Na prática: o Backrest é o “cliente oficial” instalado nas máquinas da Prefeitura**.
>Ele faz o Restic funcionar automaticamente, sem que o usuário precise usar linha de comando.

---
###### ✅ O que o Backrest verifica?

*   Horário programado do backup
*   Pastas incluídas e excluídas
*   Políticas de retenção
*   Conectividade com o REST Server
*   Falhas na execução anterior
*   Alterações nos arquivos desde o último backup

**Referência:** 
Documentação oficial do Backrest – _Getting Started / Core Concepts_.  
Disponível em: [https://garethgeorge.github.io/backrest/introduction/getting-started](https://garethgeorge.github.io/backrest/introduction/getting-started). Acesso em: 04 nov. 2025.

---
## 📡 4. Fluxo visual

```css
┌─────────────────────────────┐
│    Computadores dos setores │
│  (Obras, Saúde, etc)        │ 
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

##### ✅ Segurança total
*   Dados criptografados antes de sair do cliente
*   REST Server não conhece o conteúdo
*   Todos os repositórios são seguros contra leitura indevida
##### ✅ Integridade e confiabilidade
*   Cada snapshot é verificado
*   Dados corrompidos são detectados
*   Repositórios podem ser reparados
##### ✅ Desempenho
*   Envia apenas arquivos modificados
*   Deduplicação reduz tráfego
*   Backups são rápidos mesmo em HDs antigos
##### ✅ Recuperação simples
*   Restaurar um arquivo leva segundos
*   Histórico de versões organizado
*   Restaurar uma pasta inteira é instantâneo
##### ✅ Padronização institucional
*   Cada setor segue a mesma estrutura
*   Scripts oficiais funcionam em todos os ambientes
*   Treinamento simples para operadores
##### ✅ Escalabilidade
*   É simples adicionar novos setores
*   Novos computadores entram no sistema rapidamente
*   O servidor central escala com mais armazenamento

---
## 🚨 Desafios e Considerações sobre a Solução de Backup (Restic/Backrest)

Embora o ambiente **REST Server + Restic + Backrest** seja reconhecido por oferecer **segurança total**, **integridade e confiabilidade**, e **padronização institucional**, é importante reconhecer os desafios que esta arquitetura impõe ao operador técnico.
##### Testemunho de Uso e Estabilidade

A experiência do corpo técnico da Prefeitura, que utiliza esta solução há cerca de 8 meses desde a implementação do servidor **Nextcloud**, atesta a estabilidade do sistema. Durante esse período, não foram registrados problemas operacionais que afetassem a integridade ou a capacidade de restauração dos dados.
##### 1. Curva de Aprendizagem e Complexidade Conceitual

O principal desafio prático encontrado na operação desta solução é a **curva de aprendizagem**. Diferentemente de ferramentas com interfaces gráficas intuitivas, a operação correta exige que o operador possua **conhecimentos básicos de linha de comando**, **Shell**, **Git** e **estrutura de permissões**.

A dificuldade primária reside na compreensão dos conceitos abstratos da solução, mesmo que o **Glossário Técnico** os explique:
*   **Diferenciação de Componentes:** É crucial saber diferenciar as funções específicas do **Restic** (motor de backup, responsável pela criptografia e deduplicação), do **REST Server** (servidor central de armazenamento) e do **Backrest** (cliente de agendamento e gerenciamento).
*   **Conceitos de Repositório e Snapshot:** O operador deve entender como o *repository* armazena os dados de forma **deduplicada** e como o **Snapshot** representa o estado dos arquivos em um instante específico para permitir restaurações de versões antigas.
##### 2. Requisitos Técnicos Elevados
A solidez da solução institucional depende integralmente do **layout técnico obrigatório**. Isso significa que a base do servidor deve ser **FreeBSD + ZFS**, um sistema de arquivos que garante **verificação de integridade** e **correção automática** dos dados.

Embora essa exigência garanta **segurança e resiliência**, ela também impõe que o operador possua **conhecimento suficiente** sobre esses sistemas operacionais e *filesystems* para criar *datasets* no local correto e garantir a estabilidade do ambiente.
##### 3. Dependência de Documentação Detalhada
Apesar de serem ferramentas *open source* robustas, a implantação na Prefeitura utiliza scripts e automações oficiais. O sucesso da manutenção e da **solução de problemas** depende da conclusão e do acompanhamento dos manuais oficiais, dos quais algumas seções ainda estão **"Em elaboração"**.

---
## 🚩 Conclusão

O ambiente **REST Server + Restic + Backrest** é a solução moderna, segura e institucional da Prefeitura Municipal de Batatais.

Ele substitui soluções antigas e oferece:

*   Segurança
*   Escalabilidade
*   Confiabilidade
*   Consistência
*   Auditoria simplificada
*   Restaurações rápidas
*   Padronização total

---
## 📚 Referências Bibliográficas

**FreeBSD Project.** *FreeBSD Handbook e Documentação Oficial.*
Disponível em: https://www.freebsd.org/

**REST Server.** *Restic REST API Server.*
Disponível em: https://github.com/restic/rest-server

**Restic.** *Restic Backup Tool — Documentação Oficial.*
Disponível em: https://restic.net

**Backrest.** *Web UI para Restic — Documentação e Repositório.*
Disponível em: https://github.com/garethgeorge/backrest

**Let's Encrypt.** *Sobre o Projeto.*
Disponível em: https://letsencrypt.org/about/

**NGINX.** *Documentação Oficial do Servidor Web.*
Disponível em: https://nginx.org/en/

**Pettit, J.** *Why We Use FreeBSD Over Linux: A CTO’s Perspective.*
DZone, 2020.
Disponível em: https://dzone.com/articles/why-we-use-freebsd-over-linux-a-ctos-perspective

**Ellis, B.** *High-Performance Computing Storage Performance and Reliability: Comparing Btrfs with ZFS.*
USENIX, LISA 2011.
Disponível em: https://www.usenix.org/legacy/event/lisa11/tech/full_papers/ellis.pdf

---
## 🗃️ Documentação municipal
##### ✅ 1. Instalação do REST Server
👉 **Tutorial Oficial:** [https://github.com/pmbatatais/backup/tree/main/backup-server](https://github.com/pmbatatais/backup/tree/main/backup-server)

##### ✅ 2. Instalação do Cliente de Backup
👉 **Tutorial Oficial:** [https://github.com/pmbatatais/backup/tree/main/backup-client](https://github.com/pmbatatais/backup/tree/main/backup-client)

##### ✅ 3. Como fazer backup
🚧 Em elaboração

##### ✅ 4. Como restaurar dados
🚧 Em elaboração

##### ✅ 5. Solução de problemas
🚧 Em elaboração

---
## 📘 GLOSSÁRIO TÉCNICO — TERMOS IMPORTANTES

Esta seção explica, de forma simples, todos os termos técnicos citados no documento.
Use sempre que tiver dúvida.

---
### 🖥️ FreeBSD

Sistema operacional UNIX-like, usado mundialmente em servidores.
É conhecido por:
*   Altíssima estabilidade
*   Rede extremamente confiável
*   Performance consistente
*   Segurança nativa elevada
*   Excelente integração com ZFS

É o “sistema operacional oficial” dos servidores da Prefeitura.

---
### 🗄️ ZFS

Sistema de arquivos moderno criado pela Sun Microsystems.

Ele combina:
*   Sistema de arquivos
*   Gerenciamento de discos
*   Snapshots
*   Checksums de integridade
*   Compressão
*   Autocorreção de dados
É extremamente robusto e resistente a falhas.

---
### 💾 Storage Pool (ZFS Pool)

É o “conjunto de discos” onde o ZFS armazena todos os dados.

Pense nele como a *caixa principal* onde o sistema guarda:

*   arquivos
*   bancos de dados
*   datasets
*   snapshots

O pool pode ser:

*   De um disco só
*   Mirror (espelho)
*   RAIDZ (paridade)

---
### 🗃️ Dataset

Uma "subpasta avançada" dentro do ZFS, com seu próprio conjunto de regras.

Cada serviço pode ter:

*   seu dataset
*   sua compressão
*   seu limite de espaço
*   seus snapshots
*   suas permissões

Datasets evitam bagunça e deixam tudo organizado.

---
### 👯‍♂️ Mirror (espelho)

Forma de redundância com **2 discos idênticos**.
O ZFS grava tudo nos dois ao mesmo tempo.
Se um disco falhar → o sistema continua funcionando sem perda de dados.

---
### 🛢️ RAIDZ1

Redundância com **pelo menos 3 discos**.

Ele armazena:
*   Dados
*   Paridade (informação que permite recuperar um disco perdido)

Se 1 disco falhar → o sistema continua funcionando.

---
### 🌳 Btrfs

Sistema de arquivos moderno do Linux.

Oferece:
*   Snapshots
*   Checksums
*   Compressão
*   Subvolumes
*   Envio incremental (send/receive)

É muito bom para servidores Debian, principalmente com Samba.
Embora não seja o padrão oficial, continua sendo uma excelente alternativa.

---
### ⚙️ Restic

Ferramenta de backup:
*   Criptografa
*   Deduplica
*   Cria snapshots
*   Envia dados para o REST Server

É o “motor” do backup.

---
### 📡 REST Server

Servidor central onde ficam armazenados os repositórios do Restic.
É leve, eficiente e seguro.

---
### 🤖 Backrest

Cliente de backup usado nas máquinas da Prefeitura.

Ele:
*   Agenda
*   Executa
*   Organiza
*   Mantém
*   Restaura
*   Automatiza tudo usando Restic

---
### 🔐 Snapshot (no ZFS ou no Restic)

Representa o estado dos arquivos em um instante específico.

Serve para:
*   Restaurar versões antigas
*   Proteger contra ransomware
*   Criar históricos
*   Reverter erros

---
### 🔑 Deduplicação

Técnica usada pelo Restic e ZFS para armazenar apenas **os pedaços diferentes** dos arquivos.
Economiza espaço e acelera backups.

---
## 📜 Autor Técnico

**Leonardo Ribeiro**
Setor de Tecnologia da Informação
Prefeitura Municipal de Batatais

Responsável pela padronização, documentação e implantação da infraestrutura de backup.
