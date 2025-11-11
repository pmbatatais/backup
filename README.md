# 🏛️ Backup – Ambiente de Backup com REST Server, Restic e Backrest

## 🧭 Sobre este documento

Este guia foi elaborado para apresentar, de forma clara e prática, **como funciona o ambiente de backup institucional da Prefeitura Municipal de Batatais**, suas bases técnicas e seus princípios de padronização.

Cada capítulo foi pensado para que o leitor **compreenda não apenas o “como”, mas também o “porquê”** das escolhas feitas — desde o sistema operacional até as políticas de backup e restauração.

### 📘 Estrutura dos capítulos

**🔗 Arquitetura — Como tudo funciona**  
Aqui você descobrirá **como cada parte do sistema se conecta**: o papel do **Sistema Operacional** na estabilidade, o funcionamento do **Servidor de Backup** como repositório central e o trabalho conjunto dos softwares na execução dos backups. 

**🗃️ Documentação Municipal**  
Esta seção reúne os **manuais oficiais** produzidos pela equipe de TI da Prefeitura.  
Nela estão descritos os **procedimentos padronizados** de instalação, configuração, restauração e solução de problemas, além das políticas institucionais que orientam o uso das ferramentas.  
Trata-se do **material de referência direta para o operador técnico** — essencial para garantir conformidade com o layout institucional e sucesso na implantação.

**📚 Referências Bibliográficas**  
A última seção é um convite ao aprendizado contínuo.  
Ela reúne as **fontes técnicas e estudos de caso reais** que inspiraram este projeto.
Explorar essas leituras é entender o que está por trás de cada decisão técnica e enxergar como o uso de software livre e sistemas robustos pode transformar a gestão pública de TI.

---
## 🎯 Público-alvo

Este manual foi feito para quem faz a tecnologia acontecer no dia a dia da Prefeitura. 

Ele é voltado a:
- Técnicos de infraestrutura
- Administradores de sistemas
- Operadores de TI autorizados
- Equipes que instalam, atualizam ou mantêm servidores e estações
- Responsáveis por servidores **FreeBSD** ou ambientes integrados ao backup institucional

> 💡 Se você já administrou um servidor ou lidou com backups em rede, este manual é o seu guia.

---
## 💭 Introdução — Por que padronizamos este ambiente?

Durante muitos anos, a Prefeitura utilizou diferentes ferramentas de backup, sistemas operacionais e formas de armazenamento.  
Cada setor trabalhava à sua maneira — com versões distintas do Windows, scripts improvisados, partições mal organizadas e programas sem compatibilidade entre si.

Essa falta de padrão, embora parecesse funcional no dia a dia, escondia uma série de riscos:

- **Auditorias difíceis** e relatórios incompletos
- **Restaurações lentas ou falhas** em momentos críticos
- **Ambientes inseguros**, sem criptografia ou controle de acesso
- **Retrabalho** na manutenção e suporte técnico

Com o tempo, esses problemas se tornaram mais evidentes: sistemas antigos deixaram de receber suporte, ferramentas como o _Cobian Backup via FTP_ ficaram obsoletas e soluções como o _Duplicati_ mostraram instabilidade em grandes volumes de dados. 

Era preciso mudar — e mudar com método.

---
### 🌱 A necessidade da mudança

O objetivo da nova estrutura de backup da Prefeitura **não é apenas trocar ferramentas**, mas **criar um ambiente padronizado, seguro, acessível e sustentável** — técnica e financeiramente. 

Para isso, foram definidos alguns princípios:

---
#### 🏛️ 1. Centralização — Um único ponto, menos erros

Antes, cada setor fazia backups de maneira diferente, em locais distintos e com métodos próprios.  
Agora, com tudo concentrado em um **servidor central**, o acompanhamento é muito mais simples:

- **Manutenções mais simples:** discos danificados podem ser substituídos rapidamente sem interromper os backups de todos os setores
- **Checagem de integridade dos backups:** é possível verificar a consistência e a completude dos dados armazenados, garantindo que as restaurações funcionem quando necessário
- **Segurança e confiabilidade uniformes:** centralizar o armazenamento diminui o risco de perda de dados ou duplicação, enquanto cada cliente mantém a consistência das regras locais

👉 **Em resumo:** com um ponto único, o controle é maior e o trabalho, menor.

---
#### ⚙️ 2. Padronização — Um mesmo sistema para todos

Ter um **sistema operacional e estrutura únicos** garante que tudo funcione da mesma forma, independentemente do setor.  
Isso significa:

- Menos incompatibilidades
- Atualizações mais fáceis de aplicar
- Ambiente previsível e mais seguro

👉 **Padronizar é prevenir erros antes que aconteçam.**

---
#### 🔓 3. Tecnologias abertas — Liberdade e economia

Optar por **soluções de código aberto** permite que a Prefeitura tenha total transparência sobre o funcionamento das ferramentas — sem depender de licenças ou contratos caros.

- Reduz custos de manutenção
- Garante independência de fornecedores
- Permite auditorias completas e personalização conforme a necessidade

👉 **Software livre é sinônimo de sustentabilidade tecnológica.**

---
#### 💡 4. Facilidade de uso — Backup para todos

O novo ambiente foi planejado para ser **intuitivo e acessível**.  
Mesmo técnicos com pouca experiência conseguem operar o sistema sem recorrer a scripts complexos.

- Interface simples e web
- Redução de erros por comando incorreto
- Menos dependência de pessoal especializado

👉 **Quando é fácil de usar, é fácil de manter.**

---
#### 🚀 5. Eficiência e economia — Fazer mais com menos

A nova estrutura de backup **salva apenas o que foi alterado**, em vez de copiar tudo de novo.  
Isso torna o processo **mais rápido e econômico**, além de usar menos espaço de armazenamento.

- Backups e restaurações mais ágeis
- Dados compactados e organizados
- Funciona até em máquinas simples, com HDs convencionais

👉 **Velocidade e economia andando juntas.**

---
#### 🔗 E agora? — Como tudo isso se conecta na prática

Até aqui, vimos _por que_ a Prefeitura precisou **mudar a forma de realizar seus backups** — buscando segurança, padronização e economia.  
Mas compreender o motivo é apenas o primeiro passo.

O próximo capítulo mostra **como essas ideias foram transformadas em uma estrutura real e funcional**:  
um ambiente padronizado, centralizado e de código aberto, onde cada componente tem um papel bem definido.

> 👉 **A seguir: _Arquitetura — Como tudo funciona_**  
> Descubra como o sistema foi construído — do servidor central aos clientes de backup — e como cada parte se integra para garantir a proteção dos dados públicos de maneira simples, segura e eficiente.

---
## 🛠️ Arquitetura — Como tudo funciona

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
### 😈 1. FreeBSD + ZFS — A base sólida do servidor de backup

O **FreeBSD** é um sistema operacional amplamente usado em servidores do mundo todo, conhecido por três qualidades essenciais: **estabilidade, simplicidade e previsibilidade**.  
Ele é o tipo de sistema que “faz o que precisa ser feito, e faz bem”.

Diferente do Windows, voltado ao uso geral, e do Linux, que possui dezenas de distribuições com comportamentos distintos, o FreeBSD mantém um **padrão único e coeso** — seu núcleo e suas ferramentas evoluem juntos, formando um ambiente confiável para serviços críticos como **backup** e **compartilhamento de arquivos (Samba)**.

> 💡 **Curiosidade:** grandes empresas confiam no FreeBSD. 
> A **Netflix** usa FreeBSD em seus servidores de streaming, a **Sony** o utiliza no sistema interno do **PlayStation**, e o **WhatsApp** já o adotou em parte de sua infraestrutura de rede. 
> Em todos esses casos, o motivo é o mesmo: **desempenho previsível e estabilidade de longo prazo.**

A Prefeitura adotou o **FreeBSD** aliado ao **ZFS** como base para o servidor de backup central e para os servidores de arquivos. 

Essa combinação se destaca por:
- 🔒 **Confiabilidade elevada:** rede estável e comportamento consistente em produção.
- 🧩 **ZFS robusto:** sistema de arquivos empresarial com verificação de integridade, correção automática e snapshots nativos.
- 🧱 **Maturidade e estabilidade:** tecnologia testada em larga escala, presente em datacenters e soluções profissionais como o **TrueNAS**.

Assim, a infraestrutura de backup não depende apenas de boas ferramentas, mas de uma **fundação sólida** — um sistema operacional previsível, seguro e resiliente, capaz de proteger os dados da Prefeitura com o mesmo nível de confiabilidade que grandes serviços da internet confiam há décadas.

> **Previsibilidade**, em sistemas, significa **estabilidade de comportamento**. 
> É a garantia de que o servidor fará **hoje, amanhã e no próximo ano** exatamente o que foi planejado — sem “surpresas” após uma atualização, uma reinstalação ou uma nova versão.

---
### 📡 1. REST Server — Servidor central dedicado ao armazenamento

O **REST Server** é um servidor leve e muito rápido que implementa a **API oficial do Restic**.
👉 **Na prática, o REST Server é o “cofre central” onde o backup é armazenado**.

Ele não cria backup — ele *recebe* e *armazena*. A operação é sempre no sentido **cliente → servidor**.

No ambiente da instituição, ele fica instalado em uma **máquina dedicada exclusivamente para isso** , disponível na rede para receber os backups dos clientes.

---
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

---
#### 🔑 Repositórios e senhas

Todo backup criado pelo Restic é armazenado em um **repositório**, que possui:

1. **Nome do repositório** – para identificar o backup (ex.: `Obras_Backrest_2025-11-11`)
2. **Senha de criptografia** – essencial para restaurar dados
3. **Endereço** – local onde os repositórios são salvos (ex: `restserver.meudominio.com`)

> ⚠️ Se a senha do repositório for perdida, **os backups se tornam inacessíveis**, mesmo que os dados estejam fisicamente presentes.

Exemplos de comandos Restic:

- Inicializar um repositório remoto:

```shell
restic -r rest:https://restserver.meudominio.com/Obras_Backrest_2025-11-11 init
```

- Fazer backup de uma pasta:

```shell
restic -r rest:https://restserver.meudominio.com/Obras_Backrest_2025-11-11 backup /mnt/disk1/@fileserver
```

- Listar snapshots (histórico de backups):

```shell
restic -r rest:https://restserver.meudominio.com/Obras_Backrest_2025-11-11 snapshots
```

- Verificar integridade:

```shell
restic -r rest:https://restserver.meudominio.com/Obras_Backrest_2025-11-11 check
```

> Todos os comandos solicitam a **senha do repositório**, garantindo que apenas operadores autorizados possam restaurar dados.
> `restserver.meudominio.com` é o endereço do **REST Server**, podendo ser o endereço local `http://127.0.0.1:8000` ou um domínio válido. 


**Referência:** 
Documentação oficial do Restic – _Introduction_.
Disponível em: [https://restic.net/](https://restic.net/). Acesso em: 04 nov. 2025.

---
### 🤖 3. Backrest — O cliente que organiza, agenda e gerencia os backups

O **Backrest** é o cliente de backup instalado junto com o **Restic** nos computadores dos setores, focado nas máquinas com dados críticos ou nos servidores de arquivos SAMBA.

Todas as regras, políticas e definições relacionadas ao backup — desde **retenção e auditoria** até **nome e senha do repositório** — são **executadas no cliente Backrest**, garantindo consistência, segurança e conformidade com as políticas institucionais.

Enquanto o _Restic_ é a ferramenta que realiza o backup, o **Backrest gerencia quando, como e sob quais regras o backup deve acontecer**, automatizando todo o processo para que o usuário **não precise executar comandos manualmente**.

---
###### ✅ Funções do Backrest

- Agenda automática do backup
- Controle de pastas incluídas e excluídas
- Aplicação de políticas de retenção (quantos snapshots manter)
- Definição do **nome do repositório Restic** e da **senha de criptografia**
- Envio de logs e auditoria (por exemplo, via email)
- Verificação de conectividade com o REST Server
- Registro de falhas e alertas
- Monitoramento de alterações nos arquivos desde o último backup

> ⚠️ **Atenção sobre senha do repositório:** a senha de criptografia do Restic é **crítica**. Se for perdida, o backup **se torna inacessível e inutilizável**. É essencial armazená-la em um **cofre seguro de senhas**.

---
###### 🔄 Fluxo simplificado

1. Backrest verifica se é hora do backup
2. Inicia Restic para enviar arquivos para o repositório remoto
3. Confirma que o backup foi concluído com sucesso
4. Gera log detalhado para auditoria e envio

**Referência:** 
Documentação oficial do Backrest – _Getting Started / Core Concepts_.  
Disponível em: [https://garethgeorge.github.io/backrest/introduction/getting-started](https://garethgeorge.github.io/backrest/introduction/getting-started). Acesso em: 04 nov. 2025.

---
## ╰┈➤ 4. Fluxo visual

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
## ⚖️ Definição do Escopo de Backup e Política de Dados Críticos (Gestão de TI)

O ambiente de backup (**Backrest/Restic**) **não deve ser instalado em todas as máquinas automaticamente**.  
Ele é voltado apenas para **equipamentos que realmente armazenam dados importantes**, como **servidores de arquivos SAMBA** ou **computadores que guardam informações críticas**, sempre definidos pela Gestão de Informática.
### Setores com grande volume de dados importantes

Quando um setor ou secretaria trabalha com muitos dados críticos, a recomendação é que a Gestão de TI instale um **servidor de arquivos SAMBA exclusivo para aquele setor**, utilizando **FreeBSD + ZFS**.  
Nesse caso, o cliente de backup (**Backrest/Restic**) é instalado **somente nesse servidor**, garantindo que todos os arquivos do setor sejam protegidos de forma centralizada.
### Política de responsabilidade sobre os dados

A Gestão de TI deve elaborar um **documento oficial** informando que cada setor ou secretaria é responsável por **salvar seus arquivos no servidor indicado**.  
Se um usuário decidir **não utilizar o servidor de arquivos oficial** e guardar dados em outro lugar, a Gestão de TI **não poderá se responsabilizar por perdas de informação**.

---
## 🚨 Desafios e Considerações sobre a Solução de Backup

Nenhum sistema é perfeito — e reconhecer seus limites é o primeiro passo para aprimorá-lo.  
O ambiente **REST Server + Restic + Backrest**, adotado pela Prefeitura, trouxe avanços notáveis: segurança, integridade e padronização.  
Mas, como toda solução técnica, ele também impõe desafios que merecem atenção constante.

---
### 🧩 1. Curva de Aprendizagem — Entender antes de operar

O primeiro desafio é o **conceitual**.  
O sistema é poderoso, mas requer que o operador **entenda o que está fazendo** — e não apenas siga instruções.

Enquanto algumas ferramentas de backup funcionam com simples cliques, aqui é preciso compreender **como cada peça se encaixa**:
- **Restic:** é o motor — ele cria, deduplica e criptografa os dados.
- **REST Server:** é o cofre — guarda os repositórios de forma centralizada.
- **Backrest:** é o gerente — agenda, organiza e monitora tudo automaticamente.

Além disso, é fundamental entender:
- **Repositório:** local onde os dados ficam guardados (deduplicados e criptografados).
- **Snapshot:** fotografia do estado dos arquivos em um instante, base para restaurações.

> 💡 Operar com entendimento reduz erros e aumenta a segurança. Quem conhece a lógica confia na automação.

**Soluções sugeridas:**
- Treinamento estruturado sobre Restic, REST Server e Backrest.
- Glossário de termos, com exemplos práticos de repositórios e snapshots.
- Procedimentos de teste em ambiente controlado antes de operações críticas.

---
### ⚙️ 2. Requisitos Técnicos

O segundo desafio é o **nível técnico necessário**.  
A base da solução — **FreeBSD + ZFS** — é sólida, mas exige conhecimento específico.

O operador precisa dominar tarefas como:
- Criar e gerenciar **datasets ZFS** corretamente
- Garantir **verificação de integridade** e **espaço adequado**
- Manter **permissões e acessos** dentro do padrão institucional

Esses requisitos não são obstáculos, mas **etapas de amadurecimento técnico**.  
Quanto mais a equipe domina esses fundamentos, mais previsível e confiável se torna todo o ambiente de backup.

> ⚖️ O equilíbrio é simples: quem conhece o sistema, confia nele; quem apenas o executa, depende da sorte.

**Soluções sugeridas:**
- Guias de boas práticas para ZFS e FreeBSD.
- Automação de verificações periódicas de integridade e espaço.
- Checklists de permissões para novos datasets e servidores.

---
### 📚 3. Documentação — A base que ainda está em construção

Outro ponto essencial é a **dependência de documentação interna**.  
Embora o sistema use ferramentas _open source_, a Prefeitura mantém **scripts e automações próprias**, que precisam estar bem descritas.

Atualmente, parte dessa documentação ainda está **em elaboração**, o que dificulta a padronização de procedimentos e a capacitação de novos operadores.  
Manter essa documentação atualizada é tão importante quanto atualizar o servidor.

**Soluções sugeridas:**
- Finalizar manuais oficiais e manter versão atualizada.
- Criar documentação visual (diagramas de fluxo e arquitetura).
- Revisar periodicamente e treinar novos operadores com base nos manuais.

> 🧠 Manual técnico é mais do que papel — é memória institucional.  
> Um bom documento garante que o conhecimento não se perca quando as pessoas mudam.

---
### ⚠️ 4. Limitações do modelo cliente-centralizado

O modelo **REST Server + Backrest + Restic** funciona bem, mas apresenta **um desafio crescente conforme o ambiente aumenta**:
- Todas as políticas e manutenção estão nos **clientes**
- Se houver 10, 20 ou 50 clientes, qualquer alteração de política precisa ser aplicada **em cada máquina individualmente**
- Isso exige coordenação e aumenta risco de inconsistência

**Por que não escolher uma solução totalmente centralizada?**

- Soluções open-source totalmente centralizadas **existem** (UrBackup, Bacula, Amanda)
- Mas elas são **muito complexas de instalar e manter**
- As restaurações são lentas, mesmo usando PostgreSQL como backend, devido à necessidade de consultar o banco de dados
- Outras ferramentas como *BorgBackup* também mantêm gerenciamento **no cliente**, reproduzindo a mesma limitação

> ⚖️ Em resumo: **não há solução open-source que seja centralizada, simples e rápida para restaurações**.  
> O modelo REST Server + Backrest é um **bom compromisso entre simplicidade, segurança e eficiência**, mas exige disciplina na manutenção e monitoramento dos clientes.

---
### 🔐 5. Senhas, repositórios e controle — um ponto crítico

O controle de **senhas, repositórios e servidores** é atualmente o maior desafio operacional.  
A complexidade não está apenas nos repositórios Restic, mas também na **gestão dos servidores de arquivos**, usuários administrativos e políticas de acesso.

---
#### 📂 5.1 Repositórios e senhas

Cada repositório Restic precisa de **uma senha própria**. Sem ela, os dados são inacessíveis.  

Atualmente, ainda **não há inventário formal**, incluindo:
- Repositórios ativos e inativos.
- Senhas correspondentes.
- Responsáveis técnicos por cada repositório.

**Problemas atuais:**
- Senhas podem se perder ou ser compartilhadas sem controle.
- Repositórios órfãos podem ficar inacessíveis.
- Auditorias e rastreabilidade comprometidas.

**Soluções sugeridas:**

1. **Senhas individuais** para cada repositório, armazenadas em **cofre seguro da TI**.
2. **Lista centralizada de repositórios**, contendo:
    - Nome padronizado do repositório (ex.: setor_nome_data)
    - Setor ou sistema associado
    - Status (ativo/inativo)
    - Última data de backup
    - Hash da senha ou referência segura de recuperação
    - Responsável técnico
3. Integração com **Backrest prune** para limpar repositórios inativos de forma segura.
    

> 💡 Mesmo que o Restic esteja instalado no REST Server, **não há comando para listar repositórios automaticamente**. Inventário externo é obrigatório.

---
#### 🖥️ 5.2 Controle de servidores e usuários

O ambiente inclui **servidores legados e não padronizados**, cada um com usuários e senhas próprias:

|Servidor|Sistema atual|Backup|Observações|
|---|---|---|---|
|Compras|Windows 7|Cobian Backup + FTP|Sistema defasado; não padronizado; vulnerável|
|Obras|Debian 11|Backrest|Backup configurado, mas SO e usuários não padronizados|

**Problemas detectados:**

- Usuários administrativos diferentes.
- Senhas distintas ou desconhecidas.
- Acesso root/admin não auditado.
- Porta SSH não padronizada (atualmente alguns usam a padrão).
- Interfaces inconsistentes (GUI e shell misturados).
- Inventário de contas e senhas incompleto.

**Soluções sugeridas:**

1. **Usuário administrativo único e padronizado**
    - Ex.: `admin_backup`
    - Root/Administrator desativado ou uso restrito via sudo.
2. **Senhas diferenciadas, armazenadas com segurança**    
    - Cada servidor pode ter sua senha, mas registrada em cofre seguro.
    - Evitar senha única global; aumenta risco de comprometimento.
3. **SSH padronizado**
    - Porta uniforme (ex.: 2222)
    - Autenticação por chave pública sempre que possível
    - Login root desativado ou controlado
4. **Interface**
    - Priorizar Shell em servidores Linux/FreeBSD
    - GUI apenas em casos necessários ou legados
5. **Inventário completo e auditável**
    - Lista de servidores, usuários, senhas (ou referência ao cofre), portas SSH, serviços ativos
    - Integrar informações de Cobian, Backrest e Restic

---
#### 🗂️ 5.3 Padronização de nomes de repositórios

Além das senhas, **nomes padronizados para repositórios** ajudam na organização e auditoria. Sugestão:

- Formato: `[Setor]_[Sistema]_[DataInicial]`
- Exemplo: `Obras_Backrest_2025-01-01`
- Benefícios: fácil identificação, rastreabilidade e limpeza de repositórios inativos.

---
## 🎯 Conclusão — Uma mudança para durar

A padronização do ambiente de backup não é apenas uma decisão técnica — é uma decisão estratégica.  
Ao centralizar o armazenamento, unificar o sistema operacional, adotar ferramentas *open-source* e oferecer uma interface acessível, a Prefeitura cria uma estrutura de backup **mais segura, econômica e fácil de manter**.

Em outras palavras:

> **Menos complicação, mais previsibilidade.**  
> **Menos gasto, mais confiabilidade.**  
> **Menos risco, mais tranquilidade para todos os setores.**

Com essa base, a TI municipal deixa de “apagar incêndios” e passa a **operar de forma planejada**, com controle total sobre o ciclo de vida dos dados — desde o backup até a restauração.  
Essa mudança garante que o patrimônio digital da Prefeitura continue protegido, íntegro e disponível, hoje e nos próximos anos.

---
## 📚 Referências Bibliográficas

**FreeBSD Project.** _Manual FreeBSD e Documentação Oficial._  
Disponível em: [https://www.freebsd.org/](https://www.freebsd.org/)

**REST Server.** _Servidor de API REST para Restic._  
Disponível em: [https://github.com/restic/rest-server](https://github.com/restic/rest-server)

**Restic.** _Restic – Ferramenta de Backup: Documentação Oficial._  
Disponível em: [https://restic.net](https://restic.net)

**Backrest.** _Interface Web para Restic – Documentação e Repositório._  
Disponível em: [https://github.com/garethgeorge/backrest](https://github.com/garethgeorge/backrest)

**Let’s Encrypt.** _Sobre o Projeto._  
Disponível em: [https://letsencrypt.org/about/](https://letsencrypt.org/about/)

**NGINX.** _Documentação Oficial do Servidor Web._  
Disponível em: [https://nginx.org/en/](https://nginx.org/en/)

**Pettit, J.** _Por que usamos FreeBSD em vez de Linux: a perspectiva de um CTO._ DZone, 2020.  
Disponível em: [https://dzone.com/articles/why-we-use-freebsd-over-linux-a-ctos-perspective](https://dzone.com/articles/why-we-use-freebsd-over-linux-a-ctos-perspective)

**Netflix Case Study.** _Manutenção da maior rede de entrega de conteúdo do mundo com FreeBSD._ The FreeBSD Foundation.  
Disponível em: [https://freebsdfoundation.org/end-user-stories/netflix-case-study/](https://freebsdfoundation.org/end-user-stories/netflix-case-study/?utm_source=chatgpt.com) 

**Sony / PlayStation.** _PlayStation 4 — Sistema baseado em FreeBSD._ Linux Universe.
Disponível em: [https://linuxuniverse.com.br/bsd/playstation-4](https://linuxuniverse.com.br/bsd/playstation-4?utm_source=chatgpt.com)

**WhatsApp e FreeBSD.** _WhatsApp e FreeBSD + Erlang – escalando para bilhões com FreeBSD._ BSDInfo (e outras fontes).  
Disponível em: [https://www.bsdinfo.com.br/2014/02/28/whatsapp-e-freebsderlang/](https://www.bsdinfo.com.br/2014/02/28/whatsapp-e-freebsderlang/?utm_source=chatgpt.com)

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
### 🗃️📂 Restic Repository

É o local de armazenamento onde os dados de backup são efetivamente mantidos. Embora o Backrest gerencie esse repositório automaticamente, compreender sua função permite que o técnico interaja diretamente com os dados utilizando a CLI do Restic, quando necessário.

---
### 📌 Backrest Repository

Refere-se ao conjunto de configurações definido dentro do Backrest, que especifica:

- O destino onde os backups serão armazenados;
- As credenciais de criptografia e autenticação;
- As regras de orquestração do backup;
- Opções adicionais, como hooks e parâmetros avançados.

É, portanto, a “configuração lógica” que controla como o cliente Backrest se comporta frente ao repositório físico do Restic.

---
### 🔐 Snapshot (no ZFS ou no Restic)

Representa o estado dos arquivos em um instante específico.

Serve para:
*   Restaurar versões antigas
*   Proteger contra ransomware
*   Criar históricos
*   Reverter erros

---
### 👥 Deduplicação

Técnica usada pelo Restic e ZFS para armazenar apenas **os pedaços diferentes** dos arquivos.
Economiza espaço e acelera backups.

---
## 📜 Autor Técnico

**Leonardo Ribeiro**
Setor de Tecnologia da Informação
Prefeitura Municipal de Batatais

Responsável pela padronização, documentação e implantação da infraestrutura de backup.
