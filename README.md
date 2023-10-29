# APS de API RESTful com Rails

Projeto de API RESTful com JWT (Json Web Token) usando o framework Rails e containers Docker,
para carregamento usando docker compose, provendo acesso a dados de um dataset baixado do [Kaggle](https://www.kaggle.com/).

## Estrutura

A API foi desenvolvida com auxílio do framework Rails em Ruby 3.2,
e colocada em uma imagem docker para deployment usando `docker compose`.

## Pré-requisitos

Antes de tudo, `Ruby 3.2` e `Bundle 2.0`, ou versões mais recentes,
devem estar instalados no sistema, como também a gem `rails >= 7.0.5`.

Como o projeto só foi testado em `Ruby 3.2` com `Bundle 2.0`,
recomenda-se instalar a versão mais próxima possível de ambas,
mesmo que uma versão mais recente funcione corretamente.

## Instalação das Dependências do Rails

Para executar o rails localmente, que é necessário para gerar o banco de dados
ou executar o servidor fora de um `container docker`, algumas dependências devem
ser instaladas localmente. Para isso o `bundle` deve ser configurado para instalação
das dependências definidas no arquivo [Gemfile](./src/Gemfile) de forma local:

- Linux
  ```bash
  fulano:~/APS> cd src
  fulano:~/APS/src> bin/bundle config set path vendor/bundle
  ```

- Windows
  ```powershell
  C:\Users\Fulano\APS> chdir src
  C:\Users\Fulano\APS\src> ruby bin\bundle config set path vendor/bundle
  ```

Com isso, é possível instalar as gems na pasta `src/vendor/bundle`:

- Linux
  ```bash
  fulano:~/APS/src> bin/bundle install
  ```

- Windows
  ```powershell
  C:\Users\Fulano\APS\src> ruby bin\bundle install
  ```

## Criação do Banco de Dados

O banco de dados pode ser criado e carregado pelo próprio rails através da tarefa `db:setup`,
com isso o banco de dados será criado e a tarefa `db:seed` será executada para carregamento
do banco com os dados do dataset, como também com alguns usuários pré-definidos:

### Linux

  ```bash
  fulano:~/APS/src> bin/bundle exec bin/rails db:setup
  ```

### Windows

  ```powershell
  C:\Users\Fulano\APS\src> ruby bin\bundle exec bin\rails db:setup
  ```

###### Observação: embora seja possível executar `bin/rails` diretamente em algumas instalações, `bin/bundle exec bin/rails` evita conflitos de dependências do sistema operacional.
###### Aviso: em caso de falha, pode ser necessário destruir o banco com a tarefa `db:reset` antes de tentar novamente.

## Executando o Servidor Localmente

Para executar o servidor localmente fora de um contêiner docker, é necessário executar o rails
através do bundle para que as dependências [instaladas anteriormente](#instalação-das-dependências-do-rails)
sejam usadas:

- Linux
  ```bash
  fulano:~/APS/src> bin/bundle exec bin/rails server
  ```

- Windows
  ```powershell
  C:\Users\Fulano\APS\src> ruby bin\bundle exec bin\rails server
  ```

## Executando o Servidor como Serviço Docker

Caso `docker` e `docker-compose` estejam instalados, o servidor também pode ser executado
dentro de um contêiner docker como um serviço através do comando `docker compose up`.
Se tudo der certo, o docker deve gerar as imagens do serviço descritas no arquivo
[compose.yaml](./compose.yaml) e iniciar os contêineres do serviço automaticamente.

Caso apareça uma mensagem de erro parecida com "Cannot connect to the docker daemon at unix://var/run/docker.sock.
Is the docker daemon running?", o daemon do docker pode não estar em execução e precisa ser iniciado
com `sudo systemctl start docker`.

###### Observação: no Linux, pode ser necessário executar `docker compose up` como root usando `sudo`.

## Geração de Tokens JWT

Tokens JWT podem ser gerados com base no nome ou ID de um usuário através da tarefa Rake 'jwt:novo',
e serão armazenados na pasta [jwt](./jwt) com o nome to usuário associado ao token. Como exemplo,
um token para um usuário com nome "admin" e ID '2' pode ser gerado das seguintes formas:

- Linux
  ```bash
  fulano:~/APS/src> bin/bundle exec bin/rails "jwt:novo[2]"
  ```

- Windows
  ```powershell
  C:\Users\Fulano\APS\src> ruby bin/bundle "jwt:novo[2]"
  ```

Ou usando o nome do usuário:

- Linux
  ```bash
  fulano:~/APS/src> bin/bundle exec bin/rails "jwt:novo[,admin]"
  ```

- Windows
  ```powershell
  C:\Users\Fulano\APS\src> ruby bin/bundle "jwt:novo[,admin]"
  ```

Por questões de segurança tokens são invalidados sempre que o cadastro do usuário é alterado,
isso evita que uma falha de segurança do tipo "privilege escalation" comprometa a API inteira
dando privilégios de administração para todos os usuários. Além disso, tokens devem ser gerados
e distribuídos de forma manual, já que a conexão com o servidor não é criptografada.

###### Observação: só é possível gerar tokens se o servidor for executado de forma local, gerar tokens dentro de um container Docker não é suportado.

### Integrantes
- Gabriel Pavan de Moura
- Giovani Giaqueto de Oliveira
- Leonardo Figueiredo do Nascimento
- João da Silva Nodari
- Luciana Balsaneli Scabini
