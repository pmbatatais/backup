# 🧠 Guia Completo de Instalação do Wiki.js no FreeBSD

Este documento descreve, de forma direta e didática, o processo completo de instalação e configuração do **Wiki.js** em um sistema **FreeBSD**, incluindo a criação do banco de dados, configuração de serviço e troubleshooting.

> **Nota:** O Wiki.js é um sistema de gestão de conteúdo moderno, baseado em Node.js e PostgreSQL, ideal para documentar e organizar informações.  
> A Prefeitura Municipal de Batatais adotará oficialmente este serviço para armazenar documentos internos e registros administrativos, garantindo padronização, segurança e fácil acesso.

---
## ⚙️ 1. Requisitos

O servidor deve possuir:

- Acesso root ou permissão de superusuário;
- Conexão com a internet;
- PostgreSQL 17, Node.js e npm instalados;
- (Opcional) ZFS se desejar otimizar o armazenamento do banco de dados.

---
## 📦 2. Instalação dos Pacotes Necessários


```sheel
pkg install -y node npm wget
```

> A seguir, o PostgreSQL será instalado como explicado abaixo.

---
### 🗄️ 2.1. (Opcional) Criando um ZFS Dataset Dedicado para o PostgreSQL

Se você tiver **ZFS**, pode criar um dataset otimizado para o PostgreSQL 17:

```shell
zfs create \
  -o mountpoint=/var/db/postgres/data17 \
  -o compression=lz4 \
  -o recordsize=8k \
  -o redundant_metadata=most \
  -o primarycache=metadata \
  -o logbias=throughput \
  zroot/postgres17
```

---
### 📦 2.2. Instalação e Configuração do PostgreSQL 17

Instale o PostgreSQL 17:

```shell
pkg install -y postgresql17-server postgresql17-client
sysrc postgresql_enable=YES
```

Ajuste as permissões:

```shell
chown -R postgres:postgres /var/db/postgres/data17
```

Inicialize o banco de dados e inicie o serviço:

```shell
service postgresql initdb && service postgresql start
```

---
### 🗄️ 3. Criação do Banco de Dados

Entre no shell do PostgreSQL:

```shell
su - postgres psql
```

Crie o usuário e o banco de dados:

```sql
CREATE USER wikijs WITH PASSWORD 'SENHA_SENSIVEL';
CREATE DATABASE wiki OWNER wikijs;
GRANT ALL PRIVILEGES ON DATABASE wiki TO wikijs;
\q
exit
```
> Altere 'SENHA_SENSIVEL' por uma senha forte!

---
## 📁 4. Download e Configuração do Wiki.js

Crie o diretório de instalação:

```shell
mkdir -p /usr/local/www/wiki && cd /usr/local/www
```

Baixe o pacote mais recente do Wiki.js:

```shell
wget https://github.com/Requarks/wiki/releases/latest/download/wiki-js.tar.gz
```

Descompacte o conteúdo:

```shell
tar xzf wiki-js.tar.gz -C ./wiki cd ./wiki
```

Renomeie o arquivo de configuração:

```shell
mv config.sample.yml config.yml
```

Edite o arquivo `config.yml`:

```shell
nano config.yml
```

Na seção `db`, ajuste:

```yalm
db:
  type: postgres
  host: localhost
  port: 5432
  user: wikijs
  pass: SENHA_SENSIVEL
  db: wiki
  ssl: false
```

Salve e saia.

Ajuste o **owner** do diretório para o usuário do serviço `www`:

```shell
chown -R www:www /usr/local/www/wiki
chmod -R 755 /usr/local/www/wiki
```

---
## 🚀 5. Teste Inicial do Wiki.js

Execute manualmente para verificar o funcionamento:

```shell
node /usr/local/www/wiki/server
```

A aplicação iniciará na porta `3000`.  
Após confirmar o funcionamento, encerre com `Ctrl + C`.

---
## 🧩 6. Criação do Serviço `rc.d`

Crie o arquivo `/usr/local/etc/rc.d/wiki_server`:

```shell
nano /usr/local/etc/rc.d/wiki_server
```

Conteúdo sugerido (já configurado para usuário `www`, PID e log):

```sh
#!/bin/sh

# PROVIDE: wiki_server
# REQUIRE: NETWORKING
# KEYWORD: shutdown

. /etc/rc.subr

name="wiki_server"
rcvar="wiki_server_enable"

wiki_dir="/usr/local/www/wiki"
pidfile="/var/run/${name}/${name}.pid"
logfile="/var/log/${name}/${name}.log"

command="/usr/local/bin/node"
command_args="server"

load_rc_config $name
: ${wiki_server_enable:="NO"}

start_cmd="${name}_start"
stop_cmd="${name}_stop"
status_cmd="${name}_status"

wiki_server_start()
{
    echo "Iniciando Wiki.js..."

    # Garantir diretórios criados
    install -d -o www -g www /var/run/${name}
    install -d -o www -g www /var/log/${name}

    cd ${wiki_dir} || {
        echo "Falha ao entrar no diretório ${wiki_dir}"
        return 1
    }

    /usr/sbin/daemon \
        -u www \
        -f \
        -p ${pidfile} \
        -o ${logfile} \
        ${command} ${command_args}

    echo "Wiki.js iniciado."
}

wiki_server_stop()
{
    if [ -f "${pidfile}" ]; then
        kill "$(cat ${pidfile})" 2>/dev/null && rm -f "${pidfile}"
        echo "Wiki.js encerrado."
    else
        echo "PID file não encontrado: ${pidfile}"
    fi
}

wiki_server_status()
{
    if [ -f "${pidfile}" ]; then
        if ps -p "$(cat ${pidfile})" >/dev/null 2>&1; then
            echo "Wiki.js está em execução (PID $(cat ${pidfile}))"
        else
            echo "Wiki.js não está em execução, mas o PID file existe."
        fi
    else
        echo "Wiki.js não está em execução."
    fi
}

run_rc_command "$1"
```

Salve e torne o script **executável**:

```shell
chmod +x /usr/local/etc/rc.d/wiki_server
```

---
## 🔧 7. Habilitação do Serviço

```shell
sysrc wiki_server_enable=YES
```

---
## ▶️ 8. Iniciar o Wiki.js via Serviço

```shell
service wiki_server start
```

Verifique o status:

```shell
service wiki_server status
```

Log padrão:

```sh
/var/log/wiki_server/wiki_server.log
```

---
## 🌐 9. Acesso ao Wiki.js

Acesse no navegador:

```http
http://<IP_DO_SERVIDOR>:3000
```

---
## 🌐 10. Publicando o Wiki.js em um domínio ou subdomínio usando NGINX

Neste capítulo, vamos tornar o **Wiki.js** acessível na internet de forma segura utilizando o **NGINX** como **proxy reverso**, configurando **certificados SSL com Let’s Encrypt** para criptografar a comunicação, e **autenticação básica (Basic Auth)** para controlar o acesso remoto.

O NGINX irá receber todas as requisições externas de usuários e as encaminhará para o Wiki.js, garantindo que o acesso seja controlado e protegido.

Para os exemplos, usamos o domínio fictício `meudominio.com`. Em instituições como prefeituras, o técnico pode solicitar a criação de um subdomínio dentro do domínio oficial da instituição (`*.sp.gov.br`).

Também é possível utilizar:

- Um domínio próprio (registrado em HostGator, Registro.br, Cloudflare etc.)
- Um serviço DDNS gratuito, como DuckDNS, FreeDNS ou Cloudflare DDNS

---
### 🏗️ Estrutura do NGINX no FreeBSD

O **NGINX** (pronuncia-se “engine-x”) é um servidor web leve e de alto desempenho, amplamente utilizado para hospedar sites, sistemas e APIs.

Ele não serve apenas para “mostrar páginas”, como o Apache, mas também pode atuar como **proxy reverso**, intermediando o acesso a serviços internos.

💡 **O NGINX é o “porteiro” do servidor**  
Ele recebe todas as requisições externas e as redireciona para o serviço correto dentro da infraestrutura.

🔁 **O que é um Proxy Reverso?**  
Imagine que a instituição tem vários serviços internos:

- Wiki.js
- Painel de gestão
- Sistema interno de chamados

Cada serviço está em um servidor diferente na rede interna. O NGINX funciona como uma **central de entrada**, recebendo o pedido do usuário e encaminhando para o serviço correto, sem expor IPs internos.

Exemplo: Quando alguém acessa `https://wiki.meudominio.com`, o NGINX encaminha silenciosamente a requisição para Wiki.js (`http://10.0.0.120:3000`), e o usuário nunca vê o IP interno.

---
### ⚙️ Instalando o NGINX no FreeBSD

A instalação segue o padrão oficial da Prefeitura de Batatais, mas pode ser adaptada para outros ambientes.

1. Conecte-se ao servidor Web:

```shell
ssh admin@ip-do-servidor -p porta-ssh
```

2. Instale o NGINX:

```shell
sudo pkg install nginx
```

3. Ative o serviço para iniciar automaticamente:

```shell
sudo sysrc nginx_enable=YES
```

4. Inicie o NGINX:

```shell
sudo service nginx start
```

5. Verifique se está funcionando:

```http
http://ip-do-servidor
```

Deverá aparecer a página padrão do NGINX: “Welcome to nginx!”.

---
### 🧩 Configuração — Proxy reverso para Wiki.js

A Prefeitura adota a convenção de **armazenar cada serviço em arquivos separados** dentro do diretório:

```sh
/usr/local/etc/nginx/sites.d/
```

Exemplos de arquivos:

```shell
/usr/local/etc/nginx/sites.d/meudominio.com
/usr/local/etc/nginx/sites.d/glpi.meudominio.com
/usr/local/etc/nginx/sites.d/wiki_js.meudominio.com
```

O Wiki.js terá seu próprio arquivo, chamado:

```shell
/usr/local/etc/nginx/sites.d/wiki_js.meudominio.com
```

---
### ⏳ Preparando o NGINX

Edite o arquivo principal do NGINX:

```shell
nano /usr/local/etc/nginx/nginx.conf
```

 **Habilitar suporte a arquivos individuais (`sites.d/*.conf`)**

Dentro do bloco `http {}`, adicione:

```nginx
include sites.d/*;
```

**Adicionar servidores default para bloquear acessos diretos pelo IP**

Ainda no bloco `http {}`, adicione:

```nginx
server {
    listen 80 default_server;
    server_name _;
    return 444;
}

server {
    listen 443 ssl default_server;
    include snippets/ssl-domain.conf; # Ajuste o nome conforme certificado
    server_name _;
    return 444;
}
```

Se quiser, adicione este modelo ao seu arquivo `nginx.conf`:

```nginx
user www www;
worker_processes auto;

error_log /var/log/nginx/error.log;

events {
    use kqueue;
    worker_connections 2048;
}

http {
	
	# MIME TYPES 
	include mime.types;
	# Por padrão, o NGINX não irá olhar para o cabeçalho "X-Forwarded-For" e vai assumir que o ip do proxy reverso é o IP real do cliente
	# Se o proxy reverso está na mesma rede, todos os clientes serão tratados como localhost
	# Defina set_real_ip_from para confiar em conexões vindas do proxy-reverso
	set_real_ip_from 127.0.0.1;
	# Defina real_ip_header para informar ao NGINX que X-Forwarded-For é o ip real do cliente, já que estamos em uma conexão confiável.
	real_ip_header X-Forwarded-For;
	
    # Cache configuration for frequently accessed files and file descriptors
    # This can improve performance but values should be tested for your specific workload
    open_file_cache max=200000 inactive=20s;  # Cache up to 200,000 items, removing inactive after 20s
    open_file_cache_valid 30s;               # Revalidate cached items after 30 seconds
    open_file_cache_min_uses 2;              # Only cache files accessed at least twice
    open_file_cache_errors on;               # Cache errors for files that can't be accessed

    # Define temporary storage path for client request bodies
    client_body_temp_path /var/tmp/nginx/client_body_temp 1 2;

    # Disable access logs to reduce I/O operations (can be enabled for debugging)
    access_log off;
	
    # Enable sendfile to use kernel-level file copying for better performance
    sendfile on;

    # Limit the amount of data transferred in a single sendfile() call
    sendfile_max_chunk 1m;

    # Enable TCP_NOPUSH to send headers in one packet for better efficiency
    tcp_nopush on;
	tcp_nodelay on;

    # Default MIME type for responses
    default_type  application/octet-stream;

    # Define log format for access logs (when enabled)
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    # Enable gzip compression for responses
    gzip on;
    gzip_static on;               # Serve pre-compressed files if they exist
    gzip_disable "msie6";         # Disable compression for old IE versions
    gzip_vary on;                 # Add "Vary: Accept-Encoding" header
    gzip_proxied any;             # Compress responses for all proxied requests
    gzip_comp_level 6;            # Compression level (1-9, with 6 being a good balance)
    gzip_buffers 64 8k;           # Number and size of buffers for compression
    gzip_http_version 1.1;        # Minimum HTTP version to compress responses for
    gzip_min_length 256;          # Minimum response length to compress
    gzip_types                    # File types to compress
        application/atom+xml
        application/javascript
        application/json
        application/ld+json
        application/manifest+json
        application/octet-stream
        application/rss+xml
        application/rtf
        application/vnd.geo+json
        application/vnd.ms-fontobject
        application/wasm
        application/x-font-ttf
        application/x-javascript
        application/x-web-app-manifest+json
        application/xhtml+xml
        application/xml
        font/opentype
        font/ttf
        font/truetype
        image/bmp
        image/svg+xml
        image/x-icon
        text/cache-manifest
        text/css
        text/csv
        text/javascript
        text/plain
        text/vcard
        text/vnd.rim.location.xloc
        text/vtt
        text/x-component
        text/x-cross-domain-policy
        text/xml;

    # Timeout for keep-alive connections
    keepalive_timeout 65;

    # Disable server tokens for security (hides Nginx version in headers)
    server_tokens off;
	
	include sites.d/*;


	# Bloquear qualquer requisição de clientes que não forem configuradas no NGIX 
	# Exemplo: bloquear acessos pelo ip público, bots, etc

	server {

		listen 80 default_server;
		server_name _;
		return 444;
		
	}


	server {

		listen 443 ssl default_server;
		include snippets/ssl-meudominio.com;
		server_name _;
		return 444;
		
	}
}
```

Adicione também este modelo ao arquivo `mime.types`, em `/usr/local/etc/nginx/mime.types`:

```nginx
types {
    text/html                                        html htm shtml;
    text/css                                         css;
    text/xml                                         xml;
    image/gif                                        gif;
    image/jpeg                                       jpeg jpg;
    application/javascript                           js mjs;
    application/atom+xml                             atom;
    application/rss+xml                              rss;

    text/mathml                                      mml;
    text/plain                                       txt;
    text/vnd.sun.j2me.app-descriptor                 jad;
    text/vnd.wap.wml                                 wml;
    text/x-component                                 htc;

    image/avif                                       avif;
    image/png                                        png;
    image/svg+xml                                    svg svgz;
    image/tiff                                       tif tiff;
    image/vnd.wap.wbmp                               wbmp;
    image/webp                                       webp;
    image/x-icon                                     ico;
    image/x-jng                                      jng;
    image/x-ms-bmp                                   bmp;

    font/woff                                        woff;
    font/woff2                                       woff2;

    application/java-archive                         jar war ear;
    application/json                                 json;
    application/mac-binhex40                         hqx;
    application/msword                               doc;
    application/pdf                                  pdf;
    application/postscript                           ps eps ai;
    application/rtf                                  rtf;
    application/vnd.apple.mpegurl                    m3u8;
    application/vnd.google-earth.kml+xml             kml;
    application/vnd.google-earth.kmz                 kmz;
    application/vnd.ms-excel                         xls;
    application/vnd.ms-fontobject                    eot;
    application/vnd.ms-powerpoint                    ppt;
    application/vnd.oasis.opendocument.graphics      odg;
    application/vnd.oasis.opendocument.presentation  odp;
    application/vnd.oasis.opendocument.spreadsheet   ods;
    application/vnd.oasis.opendocument.text          odt;
    application/vnd.openxmlformats-officedocument.presentationml.presentation
                                                     pptx;
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                                                     xlsx;
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                                     docx;
    application/vnd.wap.wmlc                         wmlc;
    application/wasm                                 wasm;
    application/x-7z-compressed                      7z;
    application/x-cocoa                              cco;
    application/x-java-archive-diff                  jardiff;
    application/x-java-jnlp-file                     jnlp;
    application/x-makeself                           run;
    application/x-perl                               pl pm;
    application/x-pilot                              prc pdb;
    application/x-rar-compressed                     rar;
    application/x-redhat-package-manager             rpm;
    application/x-sea                                sea;
    application/x-shockwave-flash                    swf;
    application/x-stuffit                            sit;
    application/x-tcl                                tcl tk;
    application/x-x509-ca-cert                       der pem crt;
    application/x-xpinstall                          xpi;
    application/xhtml+xml                            xhtml;
    application/xspf+xml                             xspf;
    application/zip                                  zip;

    application/octet-stream                         bin exe dll;
    application/octet-stream                         deb;
    application/octet-stream                         dmg;
    application/octet-stream                         iso img;
    application/octet-stream                         msi msp msm;

    audio/midi                                       mid midi kar;
    audio/mpeg                                       mp3;
    audio/ogg                                        ogg;
    audio/x-m4a                                      m4a;
    audio/x-realaudio                                ra;

    video/3gpp                                       3gpp 3gp;
    video/mp2t                                       ts;
    video/mp4                                        mp4;
    video/mpeg                                       mpeg mpg;
    video/quicktime                                  mov;
    video/webm                                       webm;
    video/x-flv                                      flv;
    video/x-m4v                                      m4v;
    video/x-mng                                      mng;
    video/x-ms-asf                                   asx asf;
    video/x-ms-wmv                                   wmv;
    video/x-msvideo                                  avi;
}
```

---
### 🔌 Separação entre Servidor WEB e Wiki.js

O NGINX não precisa estar no mesmo servidor que o Wiki.js, mas recomenda-se que ambos estejam na **mesma rede local ou VPN**. Abrir portas diretamente na internet é inseguro.

---
### 1️⃣ Publicando o Wiki.js em um Virtual Host

Exemplo: `https://meudominio.com/wiki`

Crie o arquivo:

```sh
touch /usr/local/etc/nginx/sites.d/wiki_js.domain.conf
```

Adicione:

```nginx
server {
    listen 80;
    server_name meudominio.com;

    location ^~ /wiki/ {
        auth_basic "Área Restrita";
        auth_basic_user_file /usr/local/etc/nginx/passwords/WIKISERVER;

        client_max_body_size 0;
        client_body_buffer_size 128k;
        gzip off;

        proxy_pass http://10.0.0.120:3000/;
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

⚠️ Substitua `proxy_pass` e `server_name` pelos valores reais.

---
### 2️⃣ Publicando em Subdomínio

Exemplo: `https://wiki.meudominio.com`

```shell
touch /usr/local/etc/nginx/sites.d/wiki_js.domain.conf
```

Conteúdo:

```nginx
server {
    listen 80;
    server_name wiki.meudominio.com;

    include /usr/local/etc/nginx/snippets/ssl-params.conf;

    location / {
        auth_basic "Área Restrita";
        auth_basic_user_file /usr/local/etc/nginx/passwords/WIKISERVER;

        client_max_body_size 0;
        client_body_buffer_size 128k;
        gzip off;

        proxy_pass http://192.168.1.120:3000/;
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
### 3️⃣ Habilitando HTTPS com Let’s Encrypt e Certbot

Instale no FreeBSD:

```shell
pkg install -y py311-certbot py311-certbot-nginx
```

Gerar certificado para domínio principal:

```shell
certbot --nginx -d meudominio.com
```

Para subdomínios:

1. Liste todos os domínios configurados no NGINX:

```shell
grep -R "server_name" /usr/local/etc/nginx | grep -v "dist" | grep -v "alias" | awk '{for(i=1;i<=NF;i++) if ($i != "server_name") print $i}' | sed 's/;//' | grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' | grep -vE '(^localhost$|^_$)' | sort -u
```

2. Gere o certificado incluindo todos os domínios existentes + o subdomínio do Wiki.js:

```shell
certbot --nginx \
  -d meudominio.com \
  -d www.meudominio.com \
  -d wiki.meudominio.com
```

---
### 4️⃣ Testar e recarregar o NGINX

```shell
nginx -t service nginx restart
```

---
## 🧱 11. Estrutura Final

| Componente              | Caminho                                | Função                           |
| ----------------------- | -------------------------------------- | -------------------------------- |
| Diretório de instalação | `/usr/local/www/wiki`                  | Código e configuração do Wiki.js |
| Arquivo de configuração | `/usr/local/www/wiki/config.yml`       | Parâmetros do banco e ambiente   |
| Script de serviço       | `/usr/local/etc/rc.d/wiki_server`      | Controle de inicialização        |
| Log de execução         | `/var/log/wiki_server/wiki_server.log` | Saída do serviço                 |
| PID file                | `/var/run/wiki_server/wiki_server.pid` | Identificação do processo        |
| Banco de dados          | `wiki` (PostgreSQL 17)                 | Armazenamento dos dados          |

---
## 🧯 12. Troubleshooting – Erros Comuns e Soluções

### ❌ 12.1. Erro de Conexão ao Banco

**Mensagem:**

```http
SequelizeConnectionError: password authentication failed for user "wikijs"
```

**Solução:**

- Verifique a senha em `config.yml`;
- Ajuste o `pg_hba.conf`:

```sql
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
```

Recarregue:

```shell
service postgresql reload
```

---
### ⚠️ 12.2. Porta 3000 em Uso

**Erro:**

```http
Error: listen EADDRINUSE: address already in use :::3000
```

**Solução:**

```shell
sockstat -4 -l | grep 3000 kill <PID> service wiki_server restart
```

---
### 🧩 12.3. Wiki.js Inicia Manualmente, mas Não via Serviço

- Confirme permissões:

```shell
chmod +x /usr/local/etc/rc.d/wiki_server
```

- Verifique o caminho do Node.js:

```shell
which node
```

- Veja o log:

```shell
tail -n 50 /var/log/wiki_server/wiki_server.log
```

---
### 🌐 12.4. Página Não Carrega Após Proxy

Verifique o `proxy_pass` do Nginx e recarregue:

```shell
service nginx reload
```

---
### 🔁 12.5. Serviço Não Reinicia Após Reboot

Ative:

```shell
sysrc wiki_server_enable=YES
```

---
### 🧰 12.6. Verificação e Diagnóstico

```shell
psql -h localhost -U wikijs -d wiki -c '\dt' node -v ps aux | grep node tail -f /var/log/wiki_server.log
```

---
### 💾 12.7. Backup do Banco de Dados

Backup manual:

```shell
su - postgres pg_dump wiki > /var/backups/wiki_$(date +%Y%m%d).sql
```

Restauração:

```shell
psql -U wikijs -d wiki < /var/backups/wiki_YYYYMMDD.sql
```

---
# ✅ Conclusão

Após seguir este guia:

- O Wiki.js estará instalado em `/usr/local/www/wiki`;
- O banco PostgreSQL 17 estará configurado e funcional, podendo usar ZFS para melhor performance;
- O serviço `wiki_server` iniciará automaticamente no sistema;
- A aplicação poderá ser acessada via `http://<IP_DO_SERVIDOR>:3000` ou através de um reverse proxy.

🧭 **Pronto!** Seu Wiki.js no FreeBSD está operacional, gerenciável e pronto para uso.
