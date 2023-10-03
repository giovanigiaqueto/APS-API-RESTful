# APS de API RESTful com Rails

Projeto de API RESTful com JWT (Json Web Token) usando o framework Rails e containers Docker,
para carregamento usando docker compose, provendo acesso a dados de um dataset baixado do [Kaggle](https://www.kaggle.com/)

## Estrutura

A API foi desenvolvida com auxílio do framework Rails em Ruby 3.5,
e colocada em uma imagem docker para deployment usando `docker compose`

## Pré-requisitos

Antes de tudo, `Ruby 3.5` e `Bundle 2.0`, ou versões mais recentes,
devem estar instalados no sistema, como também a gem `rails >= 7.0.5`.

Como o projeto só foi testado em `Ruby 3.5` com `Bundle 2.0`,
recomenda-se instalar a versão mais próxima possível de ambas,
mesmo que uma versão mais recente funcione corretamente.

## Instalação das Dependências do Rails

Para executar o rails localmente, que é necessário para gerar o banco de dados
ou executar o servidor fora de um `container docker`, algumas dependências devem
ser instaladas através do comando `bundle install --deployment`:

- Linux
  ```bash
  fulano:~/APS> cd src
  fulano:~/APS/src> bin/bundle install --deployment
  ```

- Windows
  ```powershell
  C:\Users\Fulano\APS> chdir src
  C:\Users\Fulano\APS\src> ruby bin\bundle install --deployment
  ```

## Criação do Banco de Dados

Para cria o banco de dados, ele precisa ser gerado pelo rails e carregado com o dataset
contido no arquivo [dataset/corruption.csv](./dataset/corruption.csv) através do script
[dataset/script.rb](./dataset/script.rb).

### Linux

- criação do banco de dados
  ```bash
  fulano:~/APS/src> bin/bundle exec bin/rails db:migrate:load
  ```

- carregamento do dataset
  ```bash
  fulano:~/APS/src> dataset/script.rb
  ```

### Windows

- criação do banco de dados
  ```powershell
  C:\Users\Fulano\APS\src> ruby bin\bundle exec bin\rails db:migrate:load
  ```

- carregamento do dataset
  ```powershell
  C:\Users\Fulano\APS\src> ruby dataset\script.rb
  ```

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

###### Observação: no Linux, pode necessário executar `docker compose up` como root usando `sudo`.

### Integrantes
- Gabriel Pavan de Moura
- Giovani Giaqueto de Oliveira
- Leonardo Figueiredo do Nascimento
- João da Silva Nodari
- Luciana Balsaneli Scabini
