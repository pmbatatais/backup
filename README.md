# **🚀 Guia de Instalação – Servidor de Backup com Rest Server no FreeBSD**

Este guia descreve como configurar um **servidor de backup** para armazenamento de backups **Restic** usando **Rest Server** 

---

## **🙏 Agradecimentos**

O **Rest Server** é mantido pela equipe do [**Restic**](https://github.com/restic/rest-server).  
Meus agradecimentos aos criadores pelo excelente trabalho que torna esta solução possível.

Eu, **Leonardo Ribeiro**, adaptei o script `install.sh` para ser totalmente compatível com **FreeBSD**.  
Repositório adaptado: <https://github.com/pmbatatais/backup-server.git>

---

## **⚙️ Ambiente utilizado**

- **Sistema operacional:** FreeBSD 14.3
- **Servidor de backup:** Repositório REST Server. [Leia a página oficial](https://github.com/restic/rest-server)
- **Armazenamento:**
  - 2 discos de 1TB em espelhamento (mirror) via ZFS
  - Pool ZFS: `zroot`
  - Dataset: `zroot/rest-server`
  - Mountpoint: `/mnt/backups/rest-server`
  - Compressão: `lz4`

---

## **💾 Sobre o Servidor REST Server e Backup com Restic**

O **REST Server** é um **servidor HTTP de alta performance** que implementa a **API REST do Restic**, permitindo que clientes Restic façam backups remotos de forma segura e eficiente usando a URL `rest`:

O **Restic** é uma ferramenta de backup moderna e confiável, que oferece:

- 🔒 **Criptografia ponta-a-ponta**: os dados são criptografados no cliente antes de serem enviados, garantindo que ninguém consiga acessá-los sem a chave.
- 📦 **Deduplicação de dados**: arquivos repetidos não são duplicados, economizando espaço em disco.

Combinando **REST Server + Restic**, você cria um **servidor de backup seguro, centralizado e eficiente**, pronto para receber dados de clientes confiáveis.

---

## **📦 Instalação passo a passo**

### **1️⃣ Instalar o Git**

No FreeBSD, use:

```sh
sudo pkg install -y git
```

### **2️⃣ Clonar o repositório**

```sh
git clone https://github.com/pmbatatais/backup-server.git && cd backup-server
```

### **3️⃣ Preparar o script de instalação**

Dê permissão de execução ao script:

```shell
sudo chmod +x install.sh
```

### **4️⃣ Criar o dataset ZFS para os backups**

Se ainda não tiver criado o dataset, faça o seguinte:

```
# Criar dataset zfs
sudo zfs create -o mountpoint=/mnt/backups/rest-server -o compression=lz4 zroot/rest-server

# Verificar se o dataset está montado corretamente
sudo zfs list
```

💡 **Dica:** Este dataset será o diretório onde os `Restic-Backups` serão armazenados.

### **5️⃣ Executar a instalação**

Rode o script adaptado para FreeBSD:

```shell
sudo sh install.sh
```

> 📢 Observação: Executar `./install.sh` direto pode não funcionar em alguns ambientes. \
> 🤓 Use sempre `sh install.sh`.

Você também pode modificar o caminho do repositório e a porta TCP:

```shell
sudo sh install.sh --path=/backups/repo_restic --port=8081
```

### 6️⃣ **Dica Bônus: Usuário SFTP Somente Leitura**
> Para permitir que um técnico ou usuário visualize os repositórios do REST Server **sem alterar ou excluir nada**, siga este passo a passo:

#### 👥 6.1. Criar o grupo `sftpusers` (se ainda não existir)
```sh
sudo pw groupadd sftpusers
```

#### 👤 6.2. Criar o usuário e adicioná-lo ao grupo `sftpusers`

```sh
sudo pw useradd readonly -m -d /mnt/backups/rest-server -s /usr/sbin/nologin -G sftpusers
sudo passwd readonly
```
> - `readonly`: nome do usuário de exemplo  
> - `/mnt/backups/rest-server`: diretório dos repositórios  
> - `/usr/sbin/nologin`: impede login SSH interativo

#### 🔒 6.3. Configurar SSH para Chroot (enjaular o usuário)

No `/etc/ssh/sshd_config` adicione:

```conf
Match Group sftpusers
    ChrootDirectory %h
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
```

> `%h` garante que o usuário fique **preso ao próprio diretório home**, sem acesso a outros diretórios do sistema

#### 📂 6.4. Ajustar permissões para leitura apenas

```sh
sudo chown -R root:sftpusers /mnt/backups/rest-server
sudo chmod -R 755 /mnt/backups/rest-server
```
> O usuário pode navegar e baixar arquivos, **mas não criar, alterar ou excluir**. \
> Subdiretórios devem seguir a mesma regra de propriedade `root:sftpusers`

#### ⚡ 6.5. Testar o acesso SFTP
```sh
sftp readonly@ip_do_servidor
```
> O usuário consegue visualizar e baixar arquivos, mas tentativas de escrita **serão negadas**.

### ✅ **Resumo:** Ideal para auditoria, consultas externas ou backups.  
> O usuário **fica seguro e enjaulado**, sem risco de modificar os repositórios do REST Server.

---

## **▶️ Uso do serviço**

- **Iniciar o serviço:**

```shell
sudo service rest_server start
```

- **Parar o serviço:**

```shell
sudo service rest_server stop
```

- **Verificar status:**

```shell
sudo service rest_server status
```

---

## **🌐 Publicando o Rest Server em um domínio ou subdomínio usando Nginx**

Este capítulo explica como disponibilizar seu **Rest Server** na web usando **Nginx**, com autenticação, SSL via Certbot e suporte tanto para:

✅ **Subpasta:** `https://meudominio.com/restserver`  
✅ **Subdomínio:** `https://backup.meudominio.com`

---


### **1️⃣ Estrutura do Nginx no FreeBSD**


- Arquivo principal:

```
/usr/local/etc/nginx.conf
```

- Arquivos individuais por domínio:

```
/usr/local/etc/sites.d/
```

O Nginx **não precisa estar instalado no mesmo servidor onde o Rest Server está rodando**.  
Esse detalhe é muito importante, especialmente em ambientes onde há separação de funções — como na [Prefeitura de Batatais](https://github.com/pmbatatais), onde o Nginx já está instalado no servidor do **Batatais Drive (Nextcloud)**.\
Se for o caso, basta se conectar ao servidor **Nextcloud** e adicionar os novos arquivos em `/usr/local/etc/sites.d/`
> Leia os manuais do nextcloud no [repositório oficial](https://github.com/pmbatatais/batatais-drive)

---
### **1️⃣ Conectando-se ao servidor Web**
> Todos os comandos desta sessão deverão ser realizados no servidor WEB, onde o NGINX está instalado.

```shell
ssh usuario@ip_servidor_web -p porta_ssh
```

Exemplo:

```shell
ssh admin@192.168.1.100 -p 65022
```
> Dados do servidor web da Prefeitura de Batatais.

---
### **2️⃣ Criando o arquivo de autenticação Basic Auth**

Para proteger o servidor REST contra clientes não autorizados, você pode configurar a autenticação básica HTTP, assim o cliente deverá inserir credenciais válidas para se autenticar.
> Basic HTTP Auth deve ser usado apenas em conexeções HTTPS pois a requisição é criptografada de ponta a ponta. 

Crie o arquivo **RESTSERVER** para autenticação:

- Usuário: restserver
- Senha: "SENHA_DO_USUARIO"
> Mude `SENHA_DO_USUARIO` para uma senha forte!

```shell
mkdir -p /usr/local/etc/nginx/passwords & \
openssl passwd -apr1 "SENHA_DO_USUARIO" | \
sed 's/^/restserver:/' > /usr/local/etc/nginx/passwords/RESTSERVER
```

Arquivo final criado automaticamente:

```shell
/usr/local/etc/nginx/passwords/RESTSERVER
```

### **✅ Como usar o usuário e senha ao conectar-se ao Rest Server (cliente Restic ou Backrestic)**

Quando você cria o arquivo:

```
/usr/local/etc/nginx/passwords/RESTSERVER
```

Ele contém:

- **Usuário:** `restserver`
- **Senha:** a que você definiu em `SENHA_DO_USUARIO`

Para que o cliente **Restic** consiga autenticar no Rest Server protegido por Basic Auth, é necessário definir **duas variáveis de ambiente**, [conforme a documentação oficial do Restic](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html#rest-server):

```
export RESTIC_REST_USERNAME=<MY_REST_SERVER_USERNAME>
export RESTIC_REST_PASSWORD=<MY_REST_SERVER_PASSWORD>
```

No seu caso, substituindo:

```plaintext
<MY_REST_SERVER_USERNAME> →  restserver  
<MY_REST_SERVER_PASSWORD> →  SENHA_DO_USUARIO
```

Exemplo:

```
export RESTIC_REST_USERNAME=restserver
export RESTIC_REST_PASSWORD="SENHA_DO_USUARIO"
```

### **📖 Como fazer isso no cliente Backrest (interface gráfica)**
> 📖 Leia o manual ["Instalando e configurando o cliente Backrest"](https://github.com/pmbatatais/backup-client)

No **Backrest**, ao adicionar ou editar um repositório Rest Server:

- Clique em **+ Add Repo** ou edite o repositório atual;
- Na tela de configuração, clique em **+ Set Environment Var**
- Adicione a primeira variável:

```shell
RESTIC_REST_USERNAME=restserver
```

- Clique novamente em **+ Set Environment Var**
- Adicione a segunda variável:

```shell
RESTIC_REST_PASSWORD=SENHA_DO_USUARIO
```

👋 O Backrestic enviará essas variáveis para o **Restic** durante a conexão, permitindo autenticação no `Rest Server` via **Basic Auth**.

---

### **✅ 3. Publicando o Rest Server em um VIRTUAL HOST**

(ex.: `https://meudominio.com/restserver`)

> ⚠️ Atenção: Este manual não cobre a criação de domínios/virtual hosts no Nginx.\
> 🤔 Se o arquivo do seu domínio ainda não existir, o técnico deverá criá-lo seguindo a documentação oficial do Nginx ou manuais disponíveis na internet.

Adicione o seguinte bloco `location` dentro do bloco `server { … }` HTTPS (onde **listen** é igual a 443):
> No Servidor **Nextcloud**, adicione a `location` em `/usr/local/etc/nginx/sites.d/nextcloud.domain.conf`

```nginx
# Rest Server em um virtual host
location ^~ /restserver/ {

	auth_basic "Restricted Backup Area";
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
```

> ⚠️ Atenção: `192.168.1.120:8000` é o IP e porta padrão do servidor **rest server**.\
> 🧐 Lembre-se de alterar o parâmetro `proxy-pass` para o ip e porta corretos.

Exemplo de um arquivo de domínio completo:

```nginx
server {

  listen 443 ssl;
  server_name batatais.sp.gov.br;
	
	# Include para cabeçalhos de segurança
	include snippets/ssl-batatais.conf;
	include snippets/ssl-params.conf;
	
	# Enable HTTP/2 for better performance
	http2 on;

  # Rest Server em um virtual host
  location ^~ /restserver/ {
  
    auth_basic "Restricted Backup Area";
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

### **✅ 4. Publicando o Rest Server em um SUBDOMÍNIO**

(ex.: `https://restserver.meudominio.com`)

Crie o arquivo:

```
/usr/local/etc/sites.d/restserver.meudominio.com.conf
```

#### **✅ Configuração recomendada:**

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

#### **🔐 Criando certificados SSL (domínio + subdomínio)**

Se você tiver múltiplos subdomínios → **deve listar todos** no Certbot.

Exemplo (para multiplos subdomínios):

```shell
certbot --nginx -d meudominio.com -d glpi.meudominio.com -d nextcloud.meudominio.com -d restserver.meudominio.com
```

Exemplo (domínio + subdomínio do Rest Server):

```shell
certbot --nginx -d meudominio.com -d restserver.meudominio.com
```

---

### **✅ 5. Testar e recarregar o Nginx**

```
nginx -t
service nginx reload
```

---

### **✅ 7. Subpasta vs Subdomínio — qual escolher?**

| **Método**     | **URL**                       | **Quando usar**                             |
|------------|---------------------------|-----------------------------------------|
| **Subpasta**   | meudominio.com/restserver | Simples, quando não quer criar DNS      |
| **Subdomínio** | backup.meudominio.com     | Isolado, profissional, ideal pra backup |

---

## **🔗 Referências**

- Projeto **Rest Server**: <https://github.com/restic/rest-server>
- Ferramenta de Backup **Restic**: <https://restic.net>
- Tudo sobre **ZFS**: <https://docs.freebsd.org/pt-br/books/handbook/zfs/>
- Repositório adaptado para FreeBSD: <https://github.com/pmbatatais/backup-server.git>

---

## **📜 Autor**

**Leonardo Ribeiro**  
Prefeitura Municipal de Batatais  
Responsável técnico pela padronização dos sistemas de backup e infraestrutura de servidores.
