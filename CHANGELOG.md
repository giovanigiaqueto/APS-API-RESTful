
# Changelog

## [Versão v1.0.0](https://github.com/giovanigiaqueto/APS-API-RESTful/releases/tag/v1.0.0)

[Changelog Completo](https://github.com/giovanigiaqueto/APS-API-RESTful/compare/v0.2.2...v1.0.0)

**Mudanças Principais:**

* Métodos REST
    * Suporte completo para listagem, busca, criação, alteração e remoção dos cadastros de países e usuários,
        com necessidade de permissão de escrita para alterar cadastros e permissão de administrador para
        acessar ou alterar cadastros de usuários
    * Suporte para busca, alteração e remoção de usuários por ID,
        dado que o usuário da requisição tenha permissão de administrador
    * Renomeação de países
    * Renomeação de usuários por ID ou nome
    * Suporte para o usuário de uma requisição ler informações sobre
        seu cadastro e token JWT usado sem necessitar de autenticação
        (campos vazios são retornados caso a autenticação falhe)
* Testagem extensiva de todos os métodos REST,
    que pode ser feita com `bin/bundle exec bin/rails test`
* Requisições não autenticadas ou autorizadas
    * Definição de tipos de erro relacionados à autorização e autenticação
    * Separação entre autenticação e autorização, gerando erros de autorização
        quando uma requisição é autenticada corretamente, mas o usuário da requisição
        não pode acessar ou alterar um recurso por falta de permissões de acesso,
        e erros de autenticação quando a autenticação não pode ser concluída
* Recuperação automática de alguns tipos de erros nos controladores,
    convertendo alguns tipos de exceção em respostas HTTP pré-definidas
    * Resposta HTTP "Bad Request (400)" quando uma requisição não tem um parâmetro obrigatório
    * Resposta HTTP "Unauthorized (401)" em erros de autenticação não tratados
    * Resposta HTTP "Forbidden (403)" em erros de autorização não tratados
    * Resposta HTTP "Not Found (404)" quando um recurso não pode ser encontrado
* Carregamento do Dataset
    * Carregamento facilitado do dataset pela task Rake 'db:seed'
    * Adição de biblioteca de suporte para carregamento do dataset,
        simplificando a implementação da tarefa de carregamento
    * Remoção do script antigo de carregamento do dataset

**Lista de Mudanças:**

* rails/api: leitura de informações do usuário que fez a requisição [7c14c59](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/7c14c59)
* testagem: testagem completa dos métodos de manipulação de usuários por ID [b5ab59f](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/b5ab59f)
* rails/api: suporte à renomeação do países e usuários [c338415](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/c338415)
* rails/api: implementação dos métodos de manipulação de cadastro de usuários [37f064c](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/37f064c)
* testagem: testagem completa dos métodos de manipulação de países [e28a49f](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/e28a49f)
* rails/api: criação, remoção e atualização de registros de países na API [f46df00](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/f46df00)
* rails/routing: remodelação do roteamento da API de manipulação de países [a9a57fb](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/a9a57fb)
* auth/http: diferenciação entre os códigos de status Unauthorized e Forbidden [4fcb72e](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/4fcb72e)
* rails/app: recuperação de erro padronizada em partes dos controladores [060313d](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/060313d)
* auth/http: melhoria dos métodos de resposta à requisições [d40d4fe](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/d40d4fe)
* auth: melhoria do método de autorização de requisições [20b9370](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/20b9370)
* auth/http: adição de tipos de exceção para requisições não autorizadas [29051ab](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/29051ab)
* auth/jwt, auth/http: separação de ApplicationController em Auth::Http e Auth::Jwt [44a65c1](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/44a65c1)
* readme: correções no README.md [4a4f1c4](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/4a4f1c4)
* readme: update do README.md com novas instruções de configuração [87256fb](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/87256fb)
* dataset/script: remoção do script antigo de carregamento do dataset [9b28d79](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/9b28d79)
* dataset/rake: carregamento do dataset via task Rake [5c15211](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/5c15211)
* dataset: novo módulo para facilitar o carregamento do dataset no banco [6a8165c](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/6a8165c)
* rails/rake: carregamento de valores no banco através da tarefa 'db:seeds' [431894f](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/431894f)
* rails/rake: tarefa Rake para carregamento de usuários pré-definidos no banco [e37b591](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/e37b591)

## [Hotfix v0.2.2](https://github.com/giovanigiaqueto/APS-API-RESTful/releases/tag/v0.2.2)

[Changelog Completo](https://github.com/giovanigiaqueto/APS-API-RESTful/compare/v0.2.1...v0.2.2)

Correção de erro no script de carregamento do dataset que impedia o seu uso,
alteração do schema de banco de dados, script de carregamento do dataset
e validação do modelo que representa os dados dos países (classe Country)
para suportarem países com renda anual média desconhecida ("n/a" na coluna "Ø Annual Income").

Anteriormente, a renda anual média de países com renda anual média desconhecida
era convertida para "0.0" pelo script de carregamento do dataset. Isso foi corrigido,
e um arquivo de migração do banco de dados foi gerado para permitir o carregamento
desses países no banco, que pode ser usada para migrar o banco de dados com o comando
`bin/rails db:migrate`.

A migração do banco não irá alterar cadastros antigos, em instalações antigas
os países com renda anual média desconhecida devem ser alterados manualmente
pelos comandos `bin/rails console` ou `bin/rails dbconsole`.

**Correções:**

* dataset/script: alteração do script de carregamento do dataset para aceitar rendas nulas [c3ffadb](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/c3ffadb)
* migração: migração do banco de dados para permitir renda anual nula [fc5317b](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/fc5317b)
* hotfix: correção das opções do script de carregamento do dataset [7ca4921](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/7ca4921)

## [Hotfix v0.2.1](https://github.com/giovanigiaqueto/APS-API-RESTful/releases/tag/v0.2.1)

[Changelog Completo](https://github.com/giovanigiaqueto/APS-API-RESTful/compare/v0.2.0...v0.2.1)

Correção de erro grave na validação de usuários que impedia a existência de usuários sem permissão
de escrita (alteração, criação e remoção de dados) ou administração (usuário admin).

Também foi corrigido um erro na tarefa 'jwt:novo' para criação de tokens JWT, que considerava um ID vazio como inválido
ao invés de não fornecido. Isso impedia que um token fosse criado somente com o nome do usuário, sem fornecer
o ID do registro no banco de dados.

**Correções:**

* hotfix: correção na validação de usuários [099edcb](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/099edcb)
* bugfix: correção na tarefa de criação de tokens JWT [a15d361](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/a15d361)

## [Release v0.2.0](https://github.com/giovanigiaqueto/APS-API-RESTful/releases/tag/v0.2.0)

[Changelog Completo](https://github.com/giovanigiaqueto/APS-API-RESTful/compare/v0.1.1...v0.2.0)

**Mudanças Principais:**

* Suporte para autenticação JWT (Json Web Token)
    * Verificação de tokens JWT em requisições HTTP para garantir
        que ele seja utilizado somente por usuários do serviço
    * Invalidação de tokens antigos quando o cadastro do usuário é alterado
    * Criação, visualização e listagem de tokens JWT através de tasks do [Rake](https://github.com/ruby/rake)
* Suporte para usuários do serviço com permissão de leitura,
    leitura/escrita ou administrador (admin)
* Melhorias no script de carregamento do dataset
    * Adição de opções de linha de comando
    * Mensagem de ajuda através das opções `--ajuda`, `--help` ou `-h`
* Desenvolvimento
    * Alteração no .gitignore para que gems instaladas localmente não sejam incluídas no repositório

**Lista de Mudanças:**

* rails/rake: criação de tasks para listagem, criação e vizualização de tokens JWT [b689aac](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/b689aac)
* ruby/gems: alteração do src/Gemfile.lock [e84ca62](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/e84ca62)
* http: adição de código de status HTTP para requisições não autorizadas [82fcc71](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/82fcc71)
* jwt: adição de métodos para autenticação JWT [a56ade4](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/a56ade4)
* jwt: adição de pasta para armazenar tokens JWT [be2283d](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/be2283d)
* credenciais: alteração do arquivo de credenciais para uso com JWT [fd0d6b5](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/fd0d6b5)
* banco: atualização do esquema de banco de dados [b6a6409](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/b6a6409)
* rails/orm: adição de modelo User para gerenciamento de usuários [3247d0c](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/3247d0c)
* ruby/gems: alteração em .gitignore para ignorar gems instaladas localmente [974d31b](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/974d31b)
* dataset/script: adição de mensagem de ajuda ao script 'dataset/script.rb' [fa26f3f](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/fa26f3f)
* dataset/script: adição de opções ao script 'dataset/script.rb' [4c73fa5](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/4c73fa5)
* dataset/script: adição de comentários no script 'dataset/script.rb' [1be1b54](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/1be1b54)

## [Hotfix v0.1.1](https://github.com/giovanigiaqueto/APS-API-RESTful/releases/tag/v0.1.1)

[Changelog Completo](https://github.com/giovanigiaqueto/APS-API-RESTful/compare/v0.1.0...v0.1.1)

Correção de erro de sintaxe no script de carregamento do dataset
que impedia sua utilização para carregamento do dataset no banco de dados.

**Correções:**

* hotfix: correção do script de carregamento do dataset [2f8f620](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/2f8f620)

## [Release v0.1.0](https://github.com/giovanigiaqueto/APS-API-RESTful/releases/tag/v0.1.0)

**Adições Principais:**

* API RESTful com [Ruby on Rails](https://rubyonrails.org/)
    * Listagem e busca de países por nome, com os seguintes dados:
        * Nome (em inglês, primeira letra maiúscula)
        * Índices de corrupção (numero inteiro)
        * Renda anual per capita média
* Suporte para [Docker](https://www.docker.com/)
    * Dockerfile para criação de imagens
    * compose.yml para carregamento do serviço com `docker compose up`

**Mudanças:**

* repositório: correções no README.md [df9a076](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/df9a076)
* repositório: alterações no README.md [469afe5](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/469afe5)

**Adições:**

* dataset/script: script de carregamento do dataset no banco de dados [c8fadc1](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/c8fadc1)
* rails/api: métodos de leitura e listagem de países na API [4ffdb55](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/4ffdb55)
* rails, dockerfile: código da API em Rails e Dockerfile da imagem [a84acd4](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/a84acd4)
