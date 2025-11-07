
# **🏛️ Manual de Instalação – Backrest (FreeBSD, Linux e Windows)**

Este guia descreve o processo completo de instalação e configuração do **cliente de backup Backrest**, que será utilizado para enviar backups ao **servidor Rest Server**.  
A versão adotada é a **1.10.1**, considerada **a mais estável e recente**.

---
## **🙏 Agradecimentos**

O **Backrest** é um cliente moderno de backup desenvolvido por [**Gareth George**](https://github.com/garethgeorge/backrest), compatível com **Restic** e **REST Server**, oferecendo interface web e automação no envio e verificação de backups.

Também fica o agradecimento ao [**Projeto FreeBSD**](https://www.freebsd.org/), cuja arquitetura consistente, documentação sólida e foco em estabilidade o tornam uma base extremamente confiável para ambientes de produção — e que inspirou a construção deste guia.

---
## 📌 Considerações Iniciais

Ao longo deste manual, diversos comandos e URLs fazem referência a **`http://localhost`**. Esse endereço indica acesso **local**, ou seja, realizado diretamente no servidor onde o Backrest está instalado.  
Em ambientes sem interface gráfica — comuns em servidores de produção — a interface web deverá ser acessada **remotamente**, a partir de outra máquina autorizada da rede, utilizando o endereço IPv4 do computador, se acessado localmente,  ou o subdomínio institucional configurado para esse fim.

Exemplo ilustrativo de acesso remoto:

```plaintext
http://10.0.0.100:9898
https://clientebackup.pmbatatais.sp.gov.br
```

Por questões de segurança e padronização, este documento **não inclui** informações operacionais sensíveis, como endereços internos, portas, credenciais ou localização física dos servidores. Esses detalhes serão disponibilizados exclusivamente em um **repositório privado da Prefeitura**, acessível somente a colaboradores autorizados.

### ✅ Escopo deste documento

Este guia aborda exclusivamente:

- A instalação do cliente **Backrest**
- A configuração inicial para uso com o **REST Server institucional**
- A criação de repositórios, planos de backup e políticas básicas de retenção

Não estão incluídos:

- Procedimentos avançados de restauração
- Configuração do servidor REST Server
- Diretrizes formais de política de backup
- Troubleshooting avançado  
    Esses tópicos possuem documentação própria.

### ✅ Público-alvo

Este manual é destinado a técnicos e administradores de sistemas autorizados da Prefeitura de Batatais que realizam manutenção em servidores e estações corporativas.

### ✅ Requisitos para seguir o tutorial

Para executar os procedimentos, o operador deve possuir:

- Acesso administrativo ao sistema (root/administrator)
- Acesso de rede ao REST Server institucional
- Credenciais válidas para autenticação
- Conhecimento básico de linha de comando

### ✅ Responsabilidades do operador

O operador é responsável por:

- Garantir conectividade com o servidor REST
- Acompanhar falhas recorrentes de backup
- Manter as credenciais de forma segura
- Notificar a equipe responsável sobre incidentes ou inconsistências

---
## **📝 Sobre o Backrest**

O **Backrest** é um cliente moderno que orquestra operações de backup com **Restic**, oferecendo uma interface web centralizada para gerenciamento de repositórios, agendamento, consulta de logs e administração de snapshots. Toda a criptografia ocorre **no cliente**, garantindo que apenas dados criptografados sejam enviados ao servidor.

Seu fluxo operacional envolve a configuração de repositórios, definição de diretórios e políticas, execução dos backups via Restic e visualização dos snapshots na interface. O Backrest permite listar, comparar, verificar e aplicar retenção, além de trabalhar com múltiplos repositórios simultaneamente.

Integrado ao **REST Server**, utiliza-o apenas como armazenamento seguro, mantendo todo o processamento e controle no cliente — alinhado às práticas de segurança da Prefeitura.

O Backrest se destaca por ser:

- ✅ Intuitivo e de rápida implementação
- ✅ Seguro (criptografia completa no cliente)
- ✅ Multiplataforma (Windows, Linux, FreeBSD, MacOS, Darwin)
- ✅ Altamente automatizado
- ✅ Adequado para uso corporativo e ambientes públicos

Principais vantagens:

- 🌐 Interface Web de administração (`http://localhost:9898`)
- 🔒 Criptografia ponta a ponta
- 📋 Logs detalhados
- 🔗 Integração direta com REST Server

---
## **📘 Conceitos Fundamentais**

Antes de iniciar a configuração do ambiente, é importante compreender alguns conceitos essenciais que estruturam o funcionamento do Backrest e do Restic. Esses conceitos garantem que o operador tenha clareza sobre os componentes envolvidos no processo de backup, recuperação e manutenção do repositório.

**📌 Restic Repository**  
É o local de armazenamento onde os dados de backup são efetivamente mantidos. Embora o Backrest gerencie esse repositório automaticamente, compreender sua função permite que o técnico interaja diretamente com os dados utilizando a CLI do Restic, quando necessário.

**📌 Backrest Repository**  
Refere-se ao conjunto de configurações definido dentro do Backrest, que especifica:

- O destino onde os backups serão armazenados;
- As credenciais de criptografia e autenticação;
- As regras de orquestração do backup;
- Opções adicionais, como hooks e parâmetros avançados.

É, portanto, a “configuração lógica” que controla como o cliente Backrest se comporta frente ao repositório físico do Restic.

**📌 Backup Plan (Plano de Backup)**  
É o conjunto de diretrizes que define:

- Quais diretórios ou arquivos serão incluídos no backup;
- A periodicidade de criação dos snapshots;
- As políticas de retenção (por quanto tempo manter os backups);
- Os momentos em que devem ocorrer rotinas de manutenção.

Cada plano de backup é executado automaticamente com base nessas definições.

**📌 Operações Essenciais**

- **Backup:** Gera um novo snapshot dos dados definidos no plano.
- **Forget:** Marca snapshots antigos para remoção com base na política de retenção (mas não remove fisicamente os dados imediatamente).
- **Prune:** Remove os dados não referenciados no repositório, liberando espaço.
- **Restore:** Recupera arquivos de um snapshot específico para o sistema local.


**Referência:** 
Documentação oficial do Backrest – _Getting Started / Core Concepts_.  
Disponível em: [https://garethgeorge.github.io/backrest/introduction/getting-started](https://garethgeorge.github.io/backrest/introduction/getting-started). Acesso em: 04 nov. 2025.

---
## **🔗 Integração com o REST Server da Prefeitura**

Antes de iniciar a configuração do **Backrest (cliente)**, é imprescindível que o **REST Server** — servidor responsável pelo armazenamento centralizado dos backups — esteja plenamente implantado e operacional.

O **REST Server** é um serviço leve e estável, compatível nativamente com o _Restic_, recebendo apenas blocos já criptografados, sem necessidade de processamento adicional. Essa arquitetura reduz pontos de falha, simplifica a manutenção e aumenta a confiabilidade da infraestrutura de backup.

Sua adoção no ambiente da **Prefeitura Municipal de Batatais** considerou critérios de segurança, desempenho e estabilidade. O servidor foi implantado em **FreeBSD**, utilizando **ZFS** como sistema de arquivos — tecnologias reconhecidas por robustez, administração simples e alta estabilidade em operação contínua. Esses fatores tornam a solução adequada para armazenamento corporativo de dados críticos.

### 💡 Importante:

Sem o servidor configurado, o cliente Backrest **não terá um destino válido** para armazenar os backups.  
Certifique-se de que o servidor REST:

- Está em execução e acessível pela rede;
- Tem a porta configurada (ex.: `8000`);
- Possui o repositório REST ativo e pronto para receber conexões.

A Prefeitura de Batatais mantém um manual técnico completo para isso, disponível em:
👉 [Repositório oficial – Servidor de Backup (REST Server)](https://github.com/pmbatatais/backup-server)

---
## **🌍 Instalação por Sistema Operacional**

A seguir, abordaremos a instalação do Backrest no **FreeBSD, Linux e Windows**
Consulte a documentação oficial no GitHub para obter instruções de instalação específicas por plataforma.

👉 [Guia de Instalação Backrest](https://github.com/garethgeorge/backrest)
📌 Todos os binários estão disponíveis em: [https://github.com/garethgeorge/backrest/releases](https://github.com/garethgeorge/backrest/releases)

---
### 😈 Instalação no FreeBSD

Eu, **Leonardo Ribeiro**, adaptei este manual para o ambiente **FreeBSD**, sistema operacional utilizado oficialmente na **Prefeitura Municipal de Batatais**.

Repositório institucional do cliente:  
➡️ [https://github.com/pmbatatais/backup-client.git](https://github.com/pmbatatais/backup-client.git)

#### 🧱 Instalar os pré-requisitos

```shell
sudo pkg install -y git curl
```

#### 1️⃣ — Clonar o repositório oficial da Prefeitura

```
git clone https://github.com/pmbatatais/backup-client.git && cd backup-client
```

O diretório inclui:

- `install.sh` adaptado para FreeBSD
- Arquivos de configuração
- Estrutura padronizada pela Prefeitura

#### 2️⃣ — Baixar o binário do Backrest para FreeBSD

```
fetch https://github.com/garethgeorge/backrest/releases/download/v1.10.1/backrest_Freebsd_x86_64.tar.gz
tar -xzf backrest_Freebsd_x86_64.tar.gz
```

#### 3️⃣ — Conceder permissão de execução ao instalador

```
chmod +x install.sh
```

#### 4️⃣ — Executar o instalador

```
sudo sh install.sh
```

> 🔧 O script detectará automaticamente o sistema (FreeBSD) e criará o serviço **rc.d** do Backrest.

O processo irá:

- Copiar o binário para `/usr/local/bin/backrest`
- Criar o serviço `/usr/local/etc/rc.d/backrest`
- Ativar o serviço no boot (`sysrc backrest_enable=YES`)
- Iniciar o serviço automaticamente

#### 🧰 Comandos de serviço

```shell
sudo service backrest start
sudo service backrest stop
sudo service backrest status
tail -f /var/log/backrest.log
```

---
### 🐧 Instalação no Linux

O Backrest pode ser executado diretamente no Linux sem instalação formal.

#### 1️⃣ — Baixar o binário Linux adequado

Acesse as releases:  
➡️ [https://github.com/garethgeorge/backrest/releases](https://github.com/garethgeorge/backrest/releases)

Baixe a release mais recente: `backrest_Linux_x86_64.tar.gz`

```shell
curl -LO https://github.com/garethgeorge/backrest/releases/download/v1.10.1/backrest_Linux_x86_64.tar.gz
```

#### 2️⃣  — Instalar

```shell
mkdir backrest && tar -xzvf backrest_Linux_x86_64.tar.gz -C backrest
cd backrest && ./install.sh
```

O script `install.sh` irá:

- Mover o binário do Backrest para `/usr/local/bin`
- Criar e iniciar o serviço `system.d` por meio do usuário atual. Use `sudo ./install.sh` para instalar como root

#### 3️⃣ — Verifique a instalação

Acesse o Backrest em: [http://localhost:9898](http://localhost:9898)
Para o serviço **system.d**: `sudo systemctl status backrest`

> 🚨 Aviso:
>  
> Caso necessário, ajuste o `usuário` definido no arquivo de serviço _system.d_. Tanto o script de instalação quanto as instruções manuais de configuração utilizam, por padrão, o usuário atualmente logado no sistema.
> 
> Por padrão, o Backrest escuta somente na interface _localhost_. Caso seja necessário permitir conexões remotas, é possível habilitar essa opção por meio da variável de ambiente **BACKREST_PORT**.
>  
> Para instalações que utilizam _system.d_, execute:
> ```shell
> sudo systemctl edit backrest
> ```
> E adicione o seguinte conteúdo:
> ```ini
> [Service]
Environment="BACKREST_PORT=0.0.0.0:9898"
> ```
> A definição de **0.0.0.0** autoriza o recebimento de conexões provenientes de qualquer interface de rede.

---
### 🖥️ Instalação no Windows

Faça o download do instalador correspondente à arquitetura do seu sistema na [página de _releases_](https://github.com/garethgeorge/backrest/releases)
O instalador, denominado [BackrestSetup-x86_64.exe](https://github.com/garethgeorge/backrest/releases/download/v1.10.1/BackrestSetup-x86_64.exe), instalará o Backrest e um aplicativo gráfico na barra de tarefas (_tray application_) em:

```shell
%localappdata%\Programs\Backrest
```

O aplicativo de bandeja, configurado para iniciar automaticamente durante o login do usuário, é responsável por monitorar a execução do Backrest.

**Observação:**  
Para ajustar a porta padrão **antes da instalação**, defina uma variável de ambiente do usuário denominada **BACKREST_PORT**.  
No Windows 10 ou superior, acesse:

**Configurações > Sistema > Sobre > Configurações avançadas do sistema > Variáveis de Ambiente**

Em “Variáveis de usuário”, crie uma nova variável chamada **BACKREST_PORT** com o valor:

```makefile
127.0.0.1:porta
```

Exemplo:
`127.0.0.1:8080` para utilizar a porta `8080`.

Caso a alteração seja necessária **após a instalação**, execute novamente o instalador para atualizar os atalhos com a porta configurada.

---
## **⚙️ Configurações Iniciais**

Após a instalação, acesse o Backrest pelo endereço padrão `http://localhost:9898` (ou pela porta configurada durante a implantação). Será necessário concluir o processo inicial de configuração conforme descrito abaixo.

### 1. Configuração da Instância

#### Instance ID (Identificador da Instância)

- Identificador único da instalação do Backrest.
- Utilizado para diferenciar snapshots provenientes de diferentes clientes Backrest.
- **Atenção:** este identificador **não pode ser alterado** após a configuração inicial.

#### Autenticação

Na primeira execução, o sistema solicitará a criação de usuário e senha de acesso.
Para redefinir as credenciais, remova a chave `"users"` do arquivo de configuração:

- **Linux/FreeBSD/macOS:** `~/.config/backrest/config.json`
- **Windows:** `%appdata%\backrest\config.json`

A autenticação pode ser desativada em ambientes locais controlados ou quando o acesso é realizado por meio de um _reverse proxy_ autenticador.

### 2. Configuração do Repositório (REST Server)

Selecione **“Add Repo”** para configurar o local de armazenamento dos seus backups. Você pode criar um novo repositório ou vincular-se a um já existente no REST Server institucional da Prefeitura.

#### Parâmetros Essenciais do Repositório

##### ✅ Repository Name

- Identificador amigável e descritivo para facilitar a gestão.
- Este nome **não pode ser alterado** após a criação.

##### ✅ Repository URI (via protocolo REST)

Especifica o endereço do repositório hospedado no REST Server.  
O acesso remoto ao repositório de backup da Prefeitura Municipal de Batatais é realizado por meio de **autenticação HTTP Basic Auth**, disponibilizada através de um **subdomínio institucional seguro (HTTPS)** gerenciado por _reverse proxy_.

O servidor REST é normalmente acessado no formato abaixo:

`rest:https://backup.pmbatatais.sp.gov.br/repo`
_(O endereço acima é apenas ilustrativo.)_

##### ✅ Credenciais e Variáveis de Ambiente

###### **Credenciais do Repositório**

As credenciais do repositório são definidas no momento da **criação** do repositório.  
Se você estiver configurando o Backrest para usar um **repositório já existente**, precisará informar **exatamente a mesma senha** que foi utilizada originalmente.

⚠️ **Atenção importante:**  
Depois que uma senha é definida para um repositório Restic, **não existe forma de alterá-la**.  
Por isso, use uma senha **forte, única** e que seja armazenada de forma segura — preferencialmente em um **gerenciador de senhas institucional**.

###### **Variáveis de ambiente**

Para que o Backrest consiga se autenticar corretamente no REST Server, é necessário configurar as seguintes **variáveis de ambiente**:

| Variável                 | Descrição                                       |
| ------------------------ | ----------------------------------------------- |
| **REST_RESTIC_USERNAME** | Usuário autorizado no Basic Auth do REST Server |
| **REST_RESTIC_PASSWORD** | Senha correspondente ao usuário autorizado      |

##### ✅ Opções Avançadas (aplicáveis ao REST)

- **--no-lock**: permite desabilitar controle de bloqueio quando necessário.
- **--limit-upload / --limit-download**: define limites de largura de banda, caso se deseje restringir o consumo de rede.

##### ✅ Políticas de Manutenção

- **Prune Policy**: agenda a remoção de dados obsoletos não utilizados por nenhum snapshot.
- **Check Policy**: agenda verificações de integridade dos dados armazenados.

Após adicionar o repositório, utilize a função **“Index Snapshots”** para importar snapshots já existentes, quando aplicável.

### 3. Configuração do Plano de Backup

Selecione **“Add Plan”** para criar um novo plano, definindo os seguintes parâmetros:
#### ✅ Plan Name

- Nome descritivo e imutável.
- Sugestão: padrão que indique origem e conteúdo (ex.: `rest-servidorX`).
#### ✅ Repository

- Selecione o repositório REST associado ao servidor institucional.
- Este vínculo **não pode ser alterado** posteriormente.
#### ✅ Backup Configuration

- **Paths:** diretórios e arquivos que serão incluídos no backup.
- **Excludes:** caminhos ou padrões a serem excluídos (ex.: caches ou diretórios temporários).

#### ✅ Schedule (Agendamento)

Defina o intervalo desejado:

- Execuções horárias ou diárias; ou
- Expressão CRON (ex.: `0 0 * * *` para backups diários à meia-noite).

Opções de relógio:

- **UTC ou horário local**
- **Última execução:** baseado no último ciclo completo

#### ✅ Retention Policy (Política de Retenção)

Controla o ciclo de vida dos snapshots:

- **Por quantidade:** manter os N snapshots mais recentes
- **Por tempo:** manter snapshots diários, semanais, mensais etc.
- **Nenhuma:** retenção manual

### 🏆 Sucesso

Após esta etapa, o Backrest estará configurado e passará a executar os backups automaticamente conforme as políticas definidas.  
O sistema permite acompanhar o status das execuções pela interface e restaurar arquivos a partir de qualquer snapshot disponível.

### 👮 Recomendação de Segurança

Mantenha uma cópia das credenciais e chaves de criptografia do repositório (como a senha do repositório Restic) em local seguro.  
A perda dessas informações impede completamente a restauração dos dados.

Recomenda-se armazenar também uma cópia segura do arquivo completo de configuração:
- **Linux/FreeBSD/MacOS:** `~/.config/backrest/config.json`
Esse arquivo pode ser protegido em um cofre de senhas institucional ou armazenamento criptografado autorizado.

### **Referência:** 
Documentação oficial do Backrest – _Initial Setup_
Disponível em: https://garethgeorge.github.io/backrest/introduction/getting-started/

---

## **🔡 Variáveis de Ambiente**
### Variáveis de Ambiente (Unix)

|Variável|Descrição|Valor Padrão|
|---|---|---|
|**BACKREST_PORT**|Porta e interface onde o serviço será vinculado|`127.0.0.1:9898` (ou `0.0.0.0:9898` para imagens Docker)|
|**BACKREST_CONFIG**|Caminho para o arquivo de configuração|`$HOME/.config/backrest/config.json`  <br>_(ou, se `$XDG_CONFIG_HOME` estiver definido, `$XDG_CONFIG_HOME/backrest/config.json`)_|
|**BACKREST_DATA**|Caminho para o diretório de dados|`$HOME/.local/share/backrest`  <br>_(ou, se `$XDG_DATA_HOME` estiver definido, `$XDG_DATA_HOME/backrest`)_|
|**BACKREST_RESTIC_COMMAND**|Caminho para o binário do Restic|Versão gerenciada pelo Backrest em: `$XDG_DATA_HOME/backrest/restic-x.x.x`|
|**XDG_CACHE_HOME**|Caminho para o diretório de cache|_(não possui valor padrão definido)_|

### Variáveis de Ambiente (Windows)

|Variável|Descrição|Valor Padrão|
|---|---|---|
|**BACKREST_PORT**|Porta e interface onde o serviço será vinculado|`127.0.0.1:9898`|
|**BACKREST_CONFIG**|Caminho para o arquivo de configuração|`%appdata%\backrest`|
|**BACKREST_DATA**|Caminho para o diretório de dados|`%appdata%\backrest\data`|
|**BACKREST_RESTIC_COMMAND**|Caminho para o binário do Restic|Versão gerenciada pelo Backrest em: `C:\Program Files\restic\restic-x.x.x`|
|**XDG_CACHE_HOME**|Caminho para o diretório de cache|_(não possui valor padrão definido)_|

---

## **🔗 Referências**

- **Documentação Oficial Backrest**: https://garethgeorge.github.io/backrest/introduction/getting-started
- **REST Server:** <https://github.com/restic/rest-server>
- **Manual institucional (Servidor REST):** <https://github.com/pmbatatais/backup-server>
- **Ferramenta Restic:** [https://restic.net](https://restic.net/)
- **Documentação ZFS (FreeBSD):** <https://docs.freebsd.org/pt-br/books/handbook/zfs/>
- **Repositório do cliente:** <https://github.com/pmbatatais/backup-client.git>

---

## **📜 Autor**

**Leonardo Ribeiro**  
Prefeitura Municipal de Batatais  
Responsável técnico pela padronização dos sistemas de backup e infraestrutura de servidores.
