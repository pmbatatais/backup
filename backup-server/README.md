# **🏛️ Guia de Instalação – Servidor de Backup com Rest Server no FreeBSD**

Este guia descreve como configurar um **servidor de backup FreeBSD** usando a tecnologia **REST Server**

---
## 🙏 Agradecimentos

O **REST Server** é mantido pela equipe do [**Restic**](https://github.com/restic/rest-server).  
Meus agradecimentos aos criadores pelo excelente trabalho que torna esta solução possível.

Também fica o agradecimento ao [**Projeto FreeBSD**](https://www.freebsd.org/), cuja arquitetura consistente, documentação sólida e foco em estabilidade o tornam uma base extremamente confiável para ambientes de produção — e que inspirou a construção deste guia.

---
## 📌 Considerações Iniciais

Este documento apresenta o procedimento oficial de implantação de um **servidor institucional de backup** baseado em **REST Server**, utilizando **FreeBSD** e armazenamento **ZFS**, conforme o **layout técnico adotado pela Prefeitura Municipal de Batatais**.

O objetivo é fornecer um guia padronizado, seguro e detalhado, permitindo que qualquer técnico autorizado possa instalar ou reinstalar o ambiente com consistência, mantendo compatibilidade com o restante da infraestrutura.

Este manual não contém informações sensíveis, como:
- Senhas reais
- Endereços de rede internos
- Estrutura física dos servidores
- Regras de firewall da Prefeitura
- Configurações privadas de proxy ou VPN

Esses dados estão disponíveis exclusivamente no **repositório privado da Prefeitura**: 

👉 **Repositório central de backup (privado):**  
[https://github.com/pmbatatais/infra](https://github.com/pmbatatais/infra)  
_(Acesso restrito a colaboradores autorizados.)_

Projetos complementares:

- **Cliente Backrest:** [https://github.com/pmbatatais/backup/tree/main/backup-client](https://github.com/pmbatatais/backup/tree/main/backup-client)
- **Nextcloud (Batatais-Drive):** [https://github.com/pmbatatais/batatais-drive](https://github.com/pmbatatais/batatais-drive)

---
### 🔭 Escopo deste documento

#### Este manual cobre exclusivamente:

- Instalação do **REST Server** no **FreeBSD**
- Criação e configuração do *dataset* ZFS destinado aos repositórios
- Criação opcional de um usuário SFTP somente leitura
- A publicação do **REST Server** em um domínio ou subdomínio utilizando **Nginx**
- O uso de **Basic Auth** para proteger o acesso ao servidor
- Como o **Backrest** (cliente) utiliza as variáveis de ambiente para autenticação

#### Este documento **não** aborda:

- Políticas internas de retenção de dados
- Regras administrativas de backup
- Restauração em produção
- Troubleshooting avançado
- Instalação/configuração do Backrest (cliente)
- Configurações específicas de firewall, VLAN ou VPN

A instalação e operação do cliente **Backrest** estão documentadas separadamente:  
👉 **Cliente Backrest (instalação oficial):** [https://github.com/pmbatatais/backup-client](https://github.com/pmbatatais/backup-client)

---
### **📖 Termos importantes que você encontrará neste manual**

Para evitar dúvidas, seguem explicações **breves** dos principais termos:
#### 🔹 FreeBSD
Sistema operacional oficial dos servidores da Prefeitura. É estável, seguro e integra-se perfeitamente ao ZFS.
#### 🔹 ZFS
Sistema de arquivos avançado que oferece:

- integridade de dados
- compressão
- snapshots
- replicação

É o filesystem **obrigatório** para os repositórios de backup.
#### 🔹 Dataset ZFS
Uma “subárea” independente dentro do ZFS, usada como diretório dedicado para cada serviço.  
Exemplo usado neste manual:  
`/mnt/backups/rest-server`
#### 🔹 REST Server
O serviço que recebe e armazena os dados enviados pelo Restic.  
Ele **não** faz backup — apenas armazena repositórios.
#### 🔹 Restic
O motor CLI que realiza o backup, criptografa arquivos e envia os dados ao REST Server.
#### 🔹 Backrest
Cliente corporativo utilizado nas máquinas da Prefeitura.  
Gerencia o Restic, credenciais e políticas de backup.
#### 🔹 Basic Auth
Autenticação HTTP usada para proteger o REST Server quando ele é publicado via Nginx.
#### 🔹 Nginx
Servidor web oficial para publicar o REST Server (e outros sistemas).

---
## 👨‍💻 Instalação passo a passo

Antes de iniciar a instalação, é fundamental entender **como a Prefeitura Municipal de Batatais padroniza seus servidores** e como o armazenamento de backups deve ser configurado.

O ambiente oficial utiliza:

- **FreeBSD** como sistema operacional
- **ZFS** como sistema de arquivos padrão
- Estrutura de diretórios organizada e padronizada
- *Datasets* dedicados por serviço

Essas escolhas fazem parte do **layout técnico institucional**, já explicado no capítulo _“Considerações Iniciais”_, e **não devem ser alteradas**.  
Se o técnico optar por usar outro sistema operacional, outro filesystem ou outra estrutura de diretórios, isso ficará **fora do escopo deste manual**, e deverá ser feito **por conta e risco**, sem suporte do layout oficial.

---
### 🔍 Sobre o uso de _datasets_ ZFS

O corpo técnico da Prefeitura definiu o **ZFS** como sistema de arquivos oficial por ser:

- extremamente robusto
- altamente confiável
- ideal para ambientes de backup
- nativamente integrado ao **FreeBSD**

Um _dataset_ ZFS funciona como um diretório especial gerenciado pelo ZFS, oferecendo:

- ✅ compressão integrada
- ✅ integridade de dados por checksums
- ✅ snapshots instantâneos
- ✅ replicação fácil
- ✅ gerenciamento independente para cada serviço

📣 Embora o **REST Server** _possa_ funcionar em qualquer diretório convencional, **para seguir o padrão institucional**, recomenda-se fortemente criar um *dataset* para os repositórios de backup.

---
### ⚠️ Atenção ao caminho do repositório

O script de instalação `install.sh` usa o argumento:

```shell
--path=/caminho/do/repo
```

Se você **não informar `--path`**, será utilizado o caminho **padrão definido pela Prefeitura**:

```shell
/mnt/backups/rest-server
```

✅ Portanto:

- Se você usar o caminho **padrão**, crie e monte o dataset ZFS exatamente em:  
    `/mnt/backups/rest-server`
- Se você optar por outro caminho via `--path`, o *dataset* **deve ser montado exatamente nesse caminho** — caso contrário o **REST Server** não funcionará corretamente.
  
🏁 Este alinhamento entre **dataset ZFS** e **caminho do argumento `--path`** é obrigatório para manter compatibilidade com o layout técnico institucional.

---
### 🔨 Instalação

---
#### 1️⃣ Instalar o Git

No FreeBSD, use:

```sh
sudo pkg install -y git
```

---
#### 2️⃣ Clonar o repositório

```sh
git clone https://github.com/pmbatatais/backup.git && cd backup/backup-server
```

---
#### 3️⃣ Preparar o script de instalação

Dê permissão de execução ao script:

```shell
sudo chmod +x install.sh
```

---
#### 4️⃣ Criar o *dataset* ZFS para os backups

Crie o dataset **no mesmo caminho** que será usado como repositório:

```
# Criar dataset zfs
sudo zfs create \
  -o mountpoint=/mnt/backups/rest-server \
  -o compression=lz4 \
  zroot/rest-server

# Verificar se o *dataset* está montado corretamente
sudo zfs list
```
> 💡 _Se pretende usar outro caminho com `--path`, ajuste o mountpoint acima para refletir o novo diretório._

---
#### 5️⃣ Executar a instalação

Rode o script `install.sh`:

```shell
sudo sh install.sh
```

> 📢 Observação: Executar `./install.sh` direto pode não funcionar em alguns ambientes.
> 🤓 Use sempre `sh install.sh`.

Para instalar definindo um **caminho personalizado** e/ou outra **porta**:
```shell
sudo sh install.sh --path=/backups/repo_restic --port=8081
```

---
#### 6️⃣ Uso do serviço

- _Iniciar o serviço_:
```shell
sudo service rest_server start
```

- _Parar o serviço_:
```shell
sudo service rest_server stop
```

- _Verificar status_:
```shell
sudo service rest_server status
```

- _Editar serviço_
```shell
sudo service rest_server edit
```
---
## 💡 Dica Bônus: Usuário SFTP *Somente Leitura*

> Para permitir que um técnico ou usuário visualize os repositórios do *REST Server* **sem alterar ou excluir nada**, siga este passo a passo:

---
#### 👥 1. Criar o grupo `sftpusers` (se ainda não existir)
```sh
sudo pw groupadd sftpusers
```

---
#### 👤 2. Criar o usuário e adicioná-lo ao grupo `sftpusers`

```sh
sudo pw useradd readonly -m -d /mnt/backups/rest-server -s /usr/sbin/nologin -G sftpusers
sudo passwd readonly
```
> - `readonly`: nome do usuário de exemplo  
> - `/mnt/backups/rest-server`: diretório dos repositórios  
> - `/usr/sbin/nologin`: impede login SSH interativo

---
#### 🔒 3. Configurar SSH para Chroot (enjaular o usuário)

Adicione ao final do arquivo `/etc/ssh/sshd_config`:

```conf
Match Group sftpusers
    ChrootDirectory %h
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
```

> A variável `%h` garante que o usuário fique **preso ao próprio diretório home**, sem acesso a outros diretórios do sistema

---
#### 📂 4. Ajustar permissões para leitura apenas

```sh
sudo chown -R root:sftpusers /mnt/backups/rest-server
sudo chmod -R 755 /mnt/backups/rest-server
```
> O usuário pode navegar e baixar arquivos, **mas não criar, alterar ou excluir**. \
> Subdiretórios devem seguir a mesma regra de propriedade `root:sftpusers`

---
#### ⚡ 5. Testar o acesso SFTP
```sh
sftp readonly@ip_do_servidor
```
> O usuário consegue visualizar e baixar arquivos, mas tentativas de escrita **serão negadas**.

---
## 🌐 Publicando o **REST Server** em um domínio ou subdomínio usando **NGINX**

Neste capítulo, vamos **tornar o REST Server acessível na internet de forma segura** utilizando o **NGINX como proxy reverso** e **configurando certificados SSL com o Let's Encrypt** para que a comunicação seja criptografada, e **autenticação básica (Basic Auth) para controlar o acesso remoto ao NGINX**. 

O **NGINX** irá receber todas as requisições externas de clientes **Backrest** e as encaminhará para o **REST Server**, garantindo que o acesso seja **controlado e protegido**.

>Para os exemplos, usamos o domínio fictício *meudominio.com*. 
>Na Prefeitura de Batatais, o técnico pode solicitar a criação de um *subdomínio* dentro do domínio oficial **batatais.sp.gov.br**.

Também é possível utilizar:
- um **domínio próprio** (registrado em HostGator, Registro.br, Cloudflare etc.)
- ou um **serviço DDNS gratuito**, como DuckDNS, FreeDNS ou Cloudflare DDNS

---
### 🏗️ Estrutura do Nginx no FreeBSD

O **NGINX** (lê-se “engine-x”) é um **servidor web leve e de alto desempenho**, amplamente utilizado na internet para hospedar sites, sistemas e APIs.

Mas o que o torna especial é que ele **não serve apenas para “mostrar páginas”** (*APACHE*), e sim para **“intermediar” acessos** — uma função conhecida como **proxy reverso**.

Em termos simples:

> 💡 O NGINX é o “porteiro” do servidor.  
> Ele recebe todas as requisições externas (vindas da internet ou da rede interna) e as redireciona para o serviço correto dentro da infraestrutura.

---
#### 🔁 O que é um Proxy Reverso?

Imagine que a Prefeitura tem vários serviços internos:

- Um servidor de backup (`REST Server`)
- Um painel de gestão
- Um sistema interno de chamados

Todos estão na rede interna, cada um numa máquina diferente. 
Em vez de abrir várias portas e IPs, o **NGINX funciona como uma “central de entrada”**.

👉 Ele recebe o pedido do usuário, identifica para qual serviço aquilo deve ir e **repassa a solicitação internamente** — sem que o usuário precise saber onde cada coisa está.
  
Quando alguém acessa `https://restserver.meudominio.com`, o NGINX **encaminha silenciosamente** a requisição para o REST Server (`http://10.0.0.120:8000`).

O usuário **nunca vê o IP interno nem a porta 8000** — tudo passa pelo NGINX.

---
#### ⚙️ Instalando o NGINX no FreeBSD

1. **Acesse o servidor Web (FreeBSD):**
    `ssh admin@192.168.1.10`
2. **Instale o NGINX via pkg:**
    `sudo pkg install nginx`
3. **Ative o serviço para iniciar automaticamente:**
    `sudo sysrc nginx_enable=YES`
4. **Inicie o NGINX:**
    `sudo service nginx start`
5. **Verifique se está funcionando:**  
    Abra no navegador:  
    `http://ip-do-servidor`  
    Deverá aparecer a página padrão do NGINX (“Welcome to nginx!”).

---
#### 🧩 Configuração — Proxy reverso para o REST Server

A configuração do NGINX é feita em arquivos dentro de `/usr/local/etc/nginx/`.

O principal arquivo é:

```shell
/usr/local/etc/nginx/nginx.conf
```

Você pode editar com:

`sudo ee /usr/local/etc/nginx/nginx.conf`

 📝 Arquivos individuais por domínio (padrão oficial):

```shell
/usr/local/etc/nginx/sites.d/
```

Este é o modelo **oficial** utilizado nos servidores da Prefeitura, seguindo o mesmo padrão de outros serviços:

```plaintext
/usr/local/etc/nginx/sites.d/nextcloud.domain.conf
/usr/local/etc/nginx/sites.d/nextcloud.local.conf
/usr/local/etc/nginx/sites.d/glpi.domain.conf
```

Para manter total consistência, o arquivo do **REST Server** também deverá seguir esse formato:

```shell
/usr/local/etc/nginx/sites.d/restserver.domain.conf
```

---
### ⏳ Preparando o Nginx

Antes de criar o Virtual Host ou subdomínio do **REST Server**, é essencial **preparar** o Nginx para que ele **aceite arquivos individuais de configuração e rejeite acessos indevidos**.

Todas essas configurações devem ser feitas no arquivo principal:

```shell
/usr/local/etc/nginx/nginx.conf
```

---
#### Habilitar suporte a arquivos individuais (`sites.d/*.conf`)

Este include é **obrigatório** para que o Nginx reconheça arquivos como:

- `/usr/local/etc/nginx/sites.d/restserver.domain.conf`
- `/usr/local/etc/nginx/sites.d/nextcloud.domain.conf`

Dentro do bloco `http {}`, adicione:

```nginx
include /usr/local/etc/nginx/sites.d/*.conf;
```
---
#### Adicionar servidores default para bloquear acessos diretos ao IP

Esses blocos evitam acessos indevidos como:

- chamadas por IP público
- bots
- scanners automáticos
- requisições que não correspondam a um domínio configurado

No bloco `http {}` do `nginx.conf`, adicione servidores _default_ para bloquear acessos sem domínio explícito:

```nginx
# Bloqueia qualquer requisição feita diretamente pelo IP
server {
    listen 80 default_server;
    server_name _;
    return 444;
}

server {
    listen 443 ssl default_server;
    include snippets/ssl-domain.conf; # caminhos do certbot (ajuste o nome)
    server_name _;
    return 444;
}
```
📌 _Obs.: O arquivo `snippets/ssl-domain.conf` é responsável por armazenar os caminhos dos certificados criados pelo Certbot. O nome é apenas ilustrativo._

---
#### Modelo `nginx.conf` pronto para copiar e colar

Se for o caso, limpe o conteúdo do arquivo `nginx.conf` e cole o seguinte conteúdo:

```nginx

user www www;
worker_processes auto;

error_log /var/log/nginx/error.log;

events {
    use kqueue;
    worker_connections 2048;
}

http {

	include mime.types;
	set_real_ip_from 127.0.0.1;
	real_ip_header X-Forwarded-For;
    open_file_cache max=200000 inactive=20s;
    open_file_cache_valid 30s;     
    open_file_cache_min_uses 2;       
    open_file_cache_errors on;
    client_body_temp_path /var/tmp/nginx/client_body_temp 1 2;
    access_log off;
    sendfile on;
    sendfile_max_chunk 1m;
    tcp_nopush on;
	tcp_nodelay on;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    keepalive_timeout 65;
    server_tokens off;
	include sites.d/*.conf;
	
	server {
	
		listen 80 default_server;
		server_name _;
		return 444;
	}
	
	server {
	
		listen 443 ssl default_server;
		include snippets/ssl-batatais.conf;
		server_name _;
		return 444;
	}
}

```

---
### 🔌 Separação entre Servidor WEB e Servidor REST

O Nginx **não precisa estar no mesmo servidor** onde o REST Server está rodando.  
Ambos podem estar separados — e isso é até desejável em algumas estruturas.

Contudo:

✅ **Recomendado**: manter os dois servidores **na mesma rede local** ou em uma **VPN**.

⚠️ Se eles estiverem em redes diferentes, será necessário **abrir portas no roteador**, o que é inseguro.
A documentação oficial do **REST Server** oferece alternativas de proteção para cenários com portas expostas, mas essa prática não é recomendada para a Prefeitura.

---
### 1️⃣ Conectando-se ao servidor Web

Todos os comandos deste capítulo são executados **no servidor onde o Nginx está instalado**.

```shell
ssh usuario@ip_servidor_web -p porta_ssh
```

👉 Exemplo:

```shell
ssh admin@192.168.1.3 -p 22
```

---
### 2️⃣ Criando o arquivo de autenticação **Basic Auth**

Para proteger o **REST Server** contra clientes não autorizados, utilizamos autenticação básica HTTP (Basic Auth).
Apenas clientes que fornecerem usuário e senha corretos poderão enviar dados ao servidor.

> **Importante**: A autenticação **Basic Auth** só é segura quando usada em conjunto com **HTTPS**, pois a criptografia protege as credenciais durante o envio.

#### 📝 Criando o arquivo de credenciais:

Execute o comando abaixo.

>Ele irá **solicitar o usuário e a senha** diretamente no terminal

```shell
printf "Usuário: "; read USERNAME && \
printf "Senha: "; stty -echo; read PASSWORD; stty echo; echo && \
mkdir -p /usr/local/etc/nginx/passwords && \
echo "${USERNAME}:$(openssl passwd -apr1 "$PASSWORD")" > /usr/local/etc/nginx/passwords/RESTSERVER
```

O arquivo final será criado automaticamente em:
```shell
/usr/local/etc/nginx/passwords/RESTSERVER
```

Se você quiser mudar o usuário ou a senha, basta executar o mesmo comando novamente; o arquivo `RESTSERVER` será automaticamente substituído por um novo contendo as credenciais atualizadas, sem necessidade de editar nada manualmente.

---
### 3️⃣ Publicando o REST Server em um VIRTUAL HOST
_(ex.: `https://meudominio.com/restserver`)_

Aqui você irá:

✅ Criar **o domínio** no Nginx  
✅ Incluir o **bloco *location*** do virtual-host  
✅ Preparar o domínio para o Certbot

---
#### 📌 3.1 Criando o domínio

Crie o arquivo em `/usr/local/etc/nginx/sites.d/restserver.domain.conf`

```shell
touch /usr/local/etc/nginx/sites.d/restserver.domain.conf
```

> 🚨 Certifique-se de que o bloco *http{ ... }*  do arquivo `nginx.conf` possui:

```nginx
include /usr/local/etc/nginx/sites.d/*.conf;
```

Adicione ao arquivo `restserver.domain.conf`:

```nginx

server {

    listen 80;
    server_name meudominio.com;

	# REST Server em um virtual host
	location ^~ /restserver/ {
	
		auth_basic "Restricted Backup Area";
		auth_basic_user_file /usr/local/etc/nginx/passwords/RESTSERVER;
		client_max_body_size 0;
		client_body_buffer_size 128k;
		gzip off;
		proxy_pass http://10.0.0.120:8000/;
		proxy_http_version 1.1;
		proxy_request_buffering off;
		proxy_buffering off;
		proxy_read_timeout 3600s;
		proxy_send_timeout 3600s;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header X-Forwarded-User $remote_user;
		keepalive_requests 1000;
		keepalive_timeout 65;

	}
}

```

---
#### ⚠️ Atenção — Substitua TODOS os valores ilustrativos

##### ✅ 1. `server_name meudominio.com`

Coloque aqui o **domínio real** que você configurou no DNS.  
Exemplos reais:

- `suaempresa.com`
- `pmbatatais.sp.gov.br`
- `gabinete.cloudflareddns.org`

---
##### ✅ 2. `proxy_pass http://10.0.0.120:8000/`

Esse valor é **somente simbólico**.

Você **deve substituir** por:

- o **IP real** do servidor REST Server
- a **porta real** configurada no seu REST Server

Exemplos:

```nginx
proxy_pass http://192.168.1.20:8000/;
proxy_pass http://10.10.0.5:9090/;
proxy_pass http://172.16.33.12:8000/;
```

---
### 4️⃣ Publicando o **REST Server** em um Subdomínio

Exemplo: (ex.: `https://restserver.meudominio.com`)

Aqui o processo é idêntico ao anterior, mas com `server_name` dedicado.

📝 Crie o arquivo de configurações `restserver.domain.conf`:

```shell
touch /usr/local/etc/sites.d/restserver.domain.conf
```

✏️ Adicione o conteúdo ao arquivo `restserver.domain.conf`:

```nginx
server {

    listen 80;
    server_name restserver.meudominio.com;

    # Inclui headers de segurança
    include /usr/local/etc/nginx/snippets/ssl-params.conf;

    location / {
	
        auth_basic "Área Restrita";
        auth_basic_user_file /usr/local/etc/nginx/passwords/RESTSERVER;

        client_max_body_size 0;
        client_body_buffer_size 128k;
        gzip off;

        proxy_pass http://192.168.1.120:8000/;
        proxy_http_version 1.1;
        proxy_request_buffering off;
        proxy_buffering off;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-User $remote_user;

        keepalive_requests 1000;
        keepalive_timeout 65;
    }
}
```

---
### 5️⃣ Habilitando SSL/TLS (HTTPS) com Let’s Encrypt e Certbot

Para disponibilizar o Rest Server com segurança, é essencial habilitar **HTTPS**, que criptografa toda a comunicação entre os clientes Backrest/Restic e o servidor.  
A forma mais simples e gratuita de obter um certificado válido é utilizando:

- **Let’s Encrypt** — autoridade certificadora gratuita e automatizada
- **Certbot** — a ferramenta que solicita, renova e configura automaticamente o certificado no Nginx

---
#### ✅ O que é Let’s Encrypt?

O **Let’s Encrypt** é uma autoridade certificadora gratuita e amplamente reconhecida.  
Ele gera **certificados SSL/TLS válidos e automáticos**, usados por milhões de sites para habilitar HTTPS.

---
#### ✅ O que o Certbot faz?

O **Certbot** é uma ferramenta que:

- solicita certificados ao Let’s Encrypt
- valida que você realmente controla o domínio
- instala e configura o certificado no Nginx
- renova automaticamente antes de expirar

Para habilitar HTTPS no FreeBSD, a forma recomendada é instalar o **Certbot** diretamente pelo gerenciador de pacotes do sistema:

```shell
pkg install -y py311-certbot py311-certbot-nginx
```

---
#### ✅ Principais parâmetros do Certbot

|Parâmetro|Explicação|
|---|---|
|`--nginx`|Pede ao Certbot para configurar automaticamente os blocos do Nginx|
|`-d dominio.com`|Diz qual domínio/subdomínio deve ter certificado|
|`--dry-run`|Testa a renovação sem alterar nada|
|`certonly`|Obtém o certificado _sem_ alterar o Nginx (não usaremos aqui)|
>📢 **Importante:** o certificado só é válido para os domínios especificados no parâmetro `-d`. 
>Se um domínio/subdomínio não for declarado, não terá HTTPS.

---
#### 📌 Criando o certificado para o domínio

Esse é o caso onde _não existe um subdomínio dedicado_.
O Rest Server fica “embaixo” do domínio principal, por exemplo:

```http
https://meudominio.com/restserver
```

##### ✅ Quando gerar o certificado?

- **Se o domínio já usa HTTPS**, você **não precisa** gerar novamente.
- **Se o domínio é novo ou nunca teve certificado**, gere assim:

```shell
certbot --nginx -d meudominio.com
```

Pronto. Todo o domínio agora suporta HTTPS, incluindo `/restserver`.

---
#### 📌 Criando o certificado para o subdomínio

Quando você cria um subdomínio como:

```http
restserver.meudominio.com
```

Você **precisa gerar o certificado contendo todos os subdomínios existentes no Nginx**, e não somente o subdomínio do **REST Server**.

---
##### 🤷‍♂️ Por que listar todos os subdomínios?

Porque o Certbot não “completa” automaticamente.  
Ele **substitui** a lista de domínios existente pelo que você declarar no comando.

➡️ Se você omitir `monitoramento.meudominio.com`, por exemplo, esse domínio perderá HTTPS.  
➡️ Por isso você deve listar **todos** os domínios/subdomínios que já existem + o novo subdomínio.

---
##### ✅ Como listar todos os subdomínios configurados no Nginx

Use:

```shell
grep -R "server_name" /usr/local/etc/nginx \
    | grep -v "dist" \
    | grep -v "alias" \
    | awk '{for(i=1;i<=NF;i++) if ($i != "server_name") print $i}' \
    | sed 's/;//' \
    | grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' \
    | grep -vE '(^localhost$|^_$)' \
    | sort -u
```

Exemplo de saída:

```shell
meudominio.com
www.meudominio.com
glpi.meudominio.com
nextcloud.meudominio.com
pmbatatais.meudominio.com
```

---
##### ✅ Emitindo o certificado com todos os domínios

Com a lista em mãos, gere assim:

```shell
certbot --nginx \
  -d seudominio.com \
  -d www.seudominio.com \
  -d monitoramento.seudominio.com \
  -d api.seudominio.com \
  -d restserver.seudominio.com
```

Esse comando:

✅ Atualiza o certificado existente  
✅ Não derruba domínios já configurados  
✅ Adiciona o novo subdomínio ao mesmo certificado SAN

---
### 6️⃣ Testar e recarregar o Nginx

```shell
nginx -t
service nginx restart
```

---
## 🧩 Integração do REST Server com o Backrest

_(Guia oficial para técnicos da Prefeitura de Batatais)_

Este capítulo explica **como integrar**, de forma segura e padronizada, o **Rest Server** ao cliente **Backrest**

Antes de continuar, certifique-se de que:

✅ Você **já instalou corretamente o Backrest** nas máquinas que farão backup (não confundir com o servidor REST Server — **são componentes completamente diferentes**). 

✅ Você **leu e entendeu o manual oficial de instalação do Backrest**, disponível em:  
👉 [https://github.com/pmbatatais/backup-client](https://github.com/pmbatatais/backup-client)

> ⚠️ **O Backrest não deve ser instalado no servidor REST Server.**  
> Cada máquina cliente tem o seu Backrest local, enquanto o servidor **REST Server** é o servidor que irá armazenar cópias enviadas pelo cliente. Lembre-se, a conexão é sempre **cliente -> servidor**

---
### 1. Acessando o painel do Backrest

Por padrão, o **Backrest** roda no endereço:

```http
http://ip_do_cliente:9898
```

Onde: 
* `ip_do_cliente:9898` é o endereço ip e porta de qualquer máquina que irá enviar backups ao servidor **REST Server**

> 📢 Caso o técnico tenha modificado a porta TCP durante a instalação, deverá usar a nova porta configurada.

---
### 2. Adicionado um repositório

Dentro do Backrest:

1. Abra o menu **Repositories**.
2. Clique em **+ Add Repo**.
3. No campo **Repository URI**, insira a URL do repositório no REST Server.

A sintaxe correta é **sempre**:

```backrest
rest:http://IP_DO_SERVIDOR:PORTA/NOME_DO_REPOSITORIO
```

Exemplo ilustrativo (não copie este endereço — o seu endereço real depende da sua infraestrutura):

`rest:http://192.168.1.120:8000/financeiro`

> ✅ O _Backrest_ é quem cria automaticamente o diretório do repositório no **REST Server**.  
> Se você digitar `.../novo_repositorio`, o Backrest criará automaticamente a pasta:
> `/backups/restic-server/novo_repositorio`

#### ⚠️ Sobre edição de repositórios no Backrest

Após adicionar um repositório, por padrão, o Backrest **não permite edição** de:

- endereço do repositório (Repository URI)
- nome do repositório
- senha do repositório

Se precisar modificar **qualquer um desses campos**, será preciso:

1. Excluir o repositório da lista do Backrest.
2. Inserir novamente com os novos dados.
3. Em seguida, clicar no botão **Index Snapshots** para reconstruir a listagem dos backups já existentes nesse repositório.

> ⚠️ A senha de um repositório Restic **não pode ser alterada**.  
> Se você perder essa senha, **não poderá recuperar nenhum snapshot**.  
> Isso já está explicado detalhadamente no manual municipal, disponível em [https://github.com/pmbatatais/backup/t](https://github.com/pmbatatais/backup/) — leia com atenção.

---
### 3. Registrando as credenciais de **Basic Auth** no Backrest

O REST Server pode exigir _usuário e senha_ por meio de **Basic Auth**, garantindo que somente clientes autorizados acessem os repositórios. O **Restic** utiliza **variáveis de ambiente** para enviar essas credenciais em cada operação, mas no ambiente da Prefeitura esse processo é totalmente automatizado pelo **cliente Backrest**, que é responsável por armazenar e repassar essas variáveis ao Restic.

As credenciais utilizadas devem ser **exatamente as mesmas criadas durante a configuração do Basic Auth**, descrita no capítulo **“Publicando o REST Server em um domínio ou subdomínio usando Nginx”, tópico _2. Criando o arquivo de autenticação Basic Auth_**.

Essas credenciais são sempre criadas no **servidor web** (Nginx/Apache/Caddy). Esse servidor pode ou não estar na mesma máquina do REST Server — porém, **não é recomendado** unificar ambos.

Depois de criar o usuário e senha no servidor web, registre-os no cliente Backrest:

1. Abra o Backrest e acesse o menu **Repositories**.
2. Clique em **+ Add Repo** (ou edite um repositório existente apenas para ajustar suas variáveis).
3. Clique em **+ Set Environment Var** e adicione:
```nginx
RESTIC_REST_USERNAME=seu_usuario
```
4. Clique novamente em **+ Set Environment Var** e adicione:
```nginx
RESTIC_REST_PASSWORD=sua_senha
```

Esses valores devem corresponder **exatamente** ao conteúdo do arquivo `RESTSERVER` criado no *Basic Auth*.

> ✅ **Se o técnico alterar as credenciais *Basic Auth* no servidor web, basta atualizar os mesmos valores no Backrest.**  
> As variáveis podem ser modificadas a qualquer momento sem recriar o repositório.

---
### 4. Testando a conexão

Após configurar:

1. Verifique se:
    - o endereço está correto
    - a porta está correta
    - o nome do repositório está correto
    - o servidor REST Server está ativo
    - as credenciais estão válidas
    - o Nginx/Apache está encaminhando corretamente para o REST Server (em caso de HTTPS)

2. Clique em **Test Configuration** no Backrest. 
3. Se tudo estiver correto, clique em **Submit** e salve as configurações. 

✅ O Backrest criará a pasta do repositório no REST Server (se ela ainda não existir)  
✅ Conectará ao repositório
✅ Permitirá backups, restores e indexação normalmente.

---
### 5. Dificuldades? Consulte os manuais

Evite tentar adivinhar comportamentos — isso causa perda de tempo e falhas de configuração.

👉 A prefeitura disponibiliza o manual completo de instalação do cliente Backrest em:
[https://github.com/pmbatatais/backup/tree/main/backup-client](https://github.com/pmbatatais/backup/tree/main/backup-client)

📌 Se quiser, leia também o **manual oficial**, disponível em: 
[https://garethgeorge.github.io/backrest/introduction/getting-started/](https://garethgeorge.github.io/backrest/introduction/getting-started/)

Ele contém:

- requisitos
- instalação
- boas práticas
- explicações sobre senhas
- erros comuns
- permissões
- fluxo de backup
- orientações para recuperação de desastres

Use sempre como referência oficial.

---
## 🔗 Referências

- Projeto **REST Server**: [https://github.com/restic/rest-server](https://github.com/restic/rest-server)
- Ferramenta de Backup **Restic**: [https://restic.net](https://restic.net)
- Documentação oficial **Backrest**: [https://garethgeorge.github.io/backrest/introduction/getting-started/](https://garethgeorge.github.io/backrest/introduction/getting-started/)
- Manual do município para instalação do cliente Backrest: [https://github.com/pmbatatais/backup/tree/main/backup-client](https://github.com/pmbatatais/backup/tree/main/backup-client)
- Tudo sobre **ZFS**: [https://docs.freebsd.org/pt-br/books/handbook/zfs/](https://docs.freebsd.org/pt-br/books/handbook/zfs/)

---
## 📜 Autor

**Leonardo Ribeiro**  
Prefeitura Municipal de Batatais  
Responsável técnico pela padronização dos sistemas de backup e infraestrutura de servidores.
