# 🧠 Guia Completo de Instalação do Wiki.js no FreeBSD

Este documento descreve, de forma direta e didática, o processo completo de instalação e configuração do **Wiki.js** em um sistema **FreeBSD**, incluindo a criação do banco de dados, configuração de serviço e troubleshooting.

---
## ⚙️ 1. Requisitos

O servidor deve possuir:
- Acesso root ou permissão de superusuário;
- Conexão com a internet;
- PostgreSQL, Node.js e npm instalados.

---
## 📦 2. Instalação dos Pacotes Necessários

```shell
pkg install -y postgresql16-server postgresql16-client node npm wget
```

Habilite o PostgreSQL no sistema:

```shell
sysrc postgresql_enable=YES service postgresql initdb service postgresql start
```

---
## 🗄️ 3. Criação do Banco de Dados

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

---
## 📁 4. Download e Configuração do Wiki.js

Crie o diretório de instalação:

```shell
mkdir -p /usr/local/www/wiki cd /usr/local/www
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

```yaml
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

---
## 🚀 5. Teste Inicial do Wiki.js

Execute manualmente para verificar o funcionamento:

```shell
node server
```

A aplicação iniciará na porta `3000`.  
Após confirmar o funcionamento, encerre com `Ctrl + C`.

---
## 🧩 6. Criação do Serviço rc.d

Crie o arquivo `/usr/local/etc/rc.d/wiki_server`:

```shell
nano /usr/local/etc/rc.d/wiki_server
```

Cole o conteúdo:

```sh
#!/bin/sh

# PROVIDE: wiki_server
# REQUIRE: NETWORKING
# KEYWORD: shutdown

. /etc/rc.subr

name="wiki_server"
rcvar="wiki_server_enable"
pidfile="/var/run/${name}.pid"
log_file="/var/log/${name}.log"
command="/usr/sbin/daemon"
wiki_dir="/usr/local/www/wiki"
node_exec="/usr/local/bin/node"
wiki_exec="${wiki_dir}/server"

load_rc_config $name
: ${wiki_server_enable:="NO"}

start_cmd="${name}_start"
stop_cmd="${name}_stop"
status_cmd="${name}_status"

wiki_server_start() {
    echo "Iniciando Wiki.js..."
    /usr/sbin/daemon -f -p ${pidfile} -o ${log_file} ${node_exec} ${wiki_exec}
}

wiki_server_stop() {
    if [ -f ${pidfile} ]; then
        kill $(cat ${pidfile}) && rm -f ${pidfile}
        echo "Wiki.js encerrado."
    else
        echo "PID file não encontrado: ${pidfile}"
    fi
}

wiki_server_status() {
    if [ -f ${pidfile} ]; then
        if ps -p $(cat ${pidfile}) > /dev/null 2>&1; then
            echo "Wiki.js está em execução (PID $(cat ${pidfile}))"
        else
            echo "Wiki.js não está em execução, mas o PID file existe."
        fi
    else
        echo "Wiki.js não está em execução."
    fi
}

load_rc_config $name
run_rc_command "$1"
```

Salve e torne o script executável:

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

```lua
/var/log/wiki_server.log
```

---
## 🌐 9. Acesso ao Wiki.js

Acesse no navegador:

```http
http://<IP_DO_SERVIDOR>:3000
```

---
## 🔁 10. Reverse Proxy (Observação)

O Wiki.js opera na porta `3000`.  
Para disponibilizar o conteúdo nas portas `80` ou `443`, configure um **reverse proxy** no servidor web.

**Exemplo Nginx:**

```nginx
location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

---
## 🧱 11. Estrutura Final

|Componente|Caminho|Função|
|---|---|---|
|Diretório de instalação|`/usr/local/www/wiki`|Código e configuração do Wiki.js|
|Arquivo de configuração|`/usr/local/www/wiki/config.yml`|Parâmetros do banco e ambiente|
|Script de serviço|`/usr/local/etc/rc.d/wiki_server`|Controle de inicialização|
|Log de execução|`/var/log/wiki_server.log`|Saída do serviço|
|Banco de dados|`wiki` (PostgreSQL)|Armazenamento dos dados|

---

# 🧯 12. Troubleshooting – Erros Comuns e Soluções

## ❌ 12.1. Erro de Conexão ao Banco

**Mensagem:**

```pgsql
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
## ⚠️ 12.2. Porta 3000 em Uso

**Erro:**

```perl
Error: listen EADDRINUSE: address already in use :::3000
```

**Solução:**

```shell
sockstat -4 -l | grep 3000
kill <PID>
service wiki_server restart
```

---
## 🧩 12.3. Wiki.js Inicia Manualmente, mas Não via Serviço

**Soluções:**

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
tail -n 50 /var/log/wiki_server.log
```

---
## 🌐 12.4. Página Não Carrega Após Proxy

Verifique o `proxy_pass` do Nginx e recarregue:

```shell
service nginx reload
```

---

## 🔁 12.5. Serviço Não Reinicia Após Reboot

Ative:

```shell
sysrc wiki_server_enable=YES
```

---

## 🧰 12.6. Verificação e Diagnóstico

```shell
psql -h localhost -U wikijs -d wiki -c '\dt'
node -v
ps aux | grep node
tail -f /var/log/wiki_server.log
```

---

## 💾 12.7. Backup do Banco de Dados

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
- O banco PostgreSQL estará configurado e funcional;
- O serviço `wiki_server` iniciará automaticamente no sistema;
- A aplicação poderá ser acessada via `http://<IP_DO_SERVIDOR>:3000` ou através de um reverse proxy.

🧭 **Pronto!** Seu Wiki.js no FreeBSD está operacional, gerenciável e pronto para uso.