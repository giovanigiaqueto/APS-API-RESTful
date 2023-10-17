
# Changelog

## [Hotfix v0.2.1](https://github.com/giovanigiaqueto/APS-API-RESTful/tag/v0.2.1)

[Changelog Completo](https://github.com/giovanigiaqueto/APS-API-RESTful/compare/v0.2.0...v0.2.1)

Correção de erro grave na validação de usuários que impedia a existência de usuários sem permissão
de escrita (alteração, criação e remoção de dados) ou administração (usuário admin).

Também foi corrigido um erro na tarefa 'jwt:novo' para criação de tokens JWT, que considerava um ID vazio como inválido
ao invés de não fornecido. Isso impedia que um token fosse criado somente com o nome do usuário, sem fornecer
o ID do registro no banco de dados.

**Correções:**

* hotfix: correção na validação de usuários [099edcb](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/099edcb)
* bugfix: correção na tarefa de criação de tokens JWT [a15d361](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/a15d361)

## [Release v0.2.0](https://github.com/giovanigiaqueto/APS-API-RESTful/tag/v0.2.0)

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

## [Hotfix v0.1.1](https://github.com/giovanigiaqueto/APS-API-RESTful/tag/v0.1.1)

[Changelog Completo](https://github.com/giovanigiaqueto/APS-API-RESTful/compare/v0.1.0...v0.1.1)

Correção de erro de sintaxe no script de carregamento do dataset
que impedia sua utilização para carregamento do dataset no banco de dados.

**Correções:**

* hotfix: correção do script de carregamento do dataset [2f8f620](https://github.com/giovanigiaqueto/APS-API-RESTful/commit/2f8f620)

## [Release v0.1.0](https://github.com/giovanigiaqueto/APS-API-RESTful/tag/v0.1.0)

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

