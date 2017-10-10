## 概要
開発環境作成ついでに、コンテナ内で動くAngularを作成してみる


先日
https://qiita.com/friedaji/items/93813e765dddcb9680a0
色々はまってたものを
別のコンテナを作ったことで、作り直してみたのでまとめ直し

+ 10/6 ローカルインストールと、環境変数に対応修正


## 構成

buildとservでワーキングディレクトリを変えたかったので
composeファイルをオーバーライドするように設定

```:ファイル構成
　├ data/
　│　└ app/              ------ アプリケーションインストール用ディレクトリ
　├ nodejs/
　│　└ nodejs.dockerfile ------ コンテナ定義
　├ .env                 ------ 環境変数定義
　├ docker-compose       ------ ベースのcompose
　├ docker-compose.init.yml  -- アプリケーションインストール定義
　└ docker-compose.serv.yml  -- サービス起動用
```

### コンテナ
node.jsのオフィシャルコンテナに、ユーザーを追加し、PATHを通しておく

```yaml:nodejs.dockerfile
FROM node:8.6

ARG NODE_USER 
ARG DATA_DIR

RUN useradd -s /bin/false -m ${NODE_USER}

RUN mkdir -p /var/app
RUN chown -R ${NODE_USER}:${NODE_USER} /var/app

USER ${NODE_USER}
ENV PATH $PATH:./node_modules/.bin
WORKDIR ${DATA_DIR}
```

### Docker-compose

#### ベース

```yaml:docker-compose.yml
version: "3.3"
# angular cli
services:
  angular:
    #buildのみ
    build:
      args:
        - NODE_USER=$NODE_USER
        - DATA_DIR=$DATA_DIR
      context: ./nodejs
      dockerfile: nodejs.dockerfile
    volumes:
      - type: bind
        source: $HOST_DIR
        target: $DATA_DIR
      - type: bind
        source: ./logs
        target: /var/log/syslog
    logging:
      driver: "json-file"
      options:
        max-size: "50M"
        max-file: "10"
```

#### インストール用
ローカルインストールをしようとすると、ホスト側とのバインドのタイミングがbuildの後になる為
Dockerfileのほうでバインドしなければならないが、Windowsベースではややこしくなる
+ (containerから直接見えるのはDocker-for-Windowsのホストな為)
build後に実行をしています

```yaml:docker-compose.init.yml
version: "3.3"
# angular cli
# angular本体のインストール、プロジェクト作成
services:
  angular:
    command:
      - /bin/sh
      - -c
      - |
        npm install @angular/cli
        ng new ${APP}
```

#### 開発サーバ起動用
live reloadが有効にならず色々見た所
https://github.com/angular/angular-cli/issues/1610
pollを有効に、という事だったのでオプションに追加
また、デフォルトではコンテナ外から繋げない為、hostも指定する

```yaml:docker-compose.serv.yml
version: "3.3"
# angular cli
services:
  angular:
    environment:
      - "APP_DIR=${APP_DIR}"
    ports:
      - "$CPORT:$LPORT"
    working_dir: ${APP_DIR}
    #poll --- 単位ミリ秒で指定、且つwatching有効化
    #host --- コンテナ外からアクセスできるようにするため、全てのアドレスで待ち受ける
    command: ng serve --host 0.0.0.0 --poll=2000
```

```ini:.env
NODE_USER=appuser
APP=test-app
CPORT=4200
LPORT=4200
DATA_DIR=/var/app
APP_DIR=/var/app/test-app
HOST_DIR=./data/app
```

## 起動のしかた

### ビルド

コンテナのビルドを行い、ワーキングディレクトリをバインドする

```
docker-compose build
```

### アプリケーションの作成

インストール用の定義を実行する

```
docker-compose -f docker-compose.yml -f docker-compose.init.yml up
```

### サーバの起動

起動用のcomposeでベースをオーバーライドし、サーバーを起動する

```
docker-compose -f docker-compose.yml -f docker-compose.serv.yml up -d
```

### 動作確認

http://localhost:4200
