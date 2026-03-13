# Tsuzuri デプロイ手順 (Kamal)

## 前提条件

- ローカル環境に Docker がインストール済み
- デプロイ先サーバへの SSH アクセス
- ドメインの DNS 設定済み（A レコードがサーバ IP を指す）

## 初期セットアップ

### 0. サーバ初期化（Ubuntu）

デプロイ先サーバで以下を実行してください:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y docker.io curl git
sudo usermod -a -G docker <Server Username>
```

`usermod` 実行後は、対象ユーザーで再ログイン（または `newgrp docker`）が必要です。

### 1. `.env` の設定

`.env.sample` をコピーして `.env` を作成し、環境に合わせて値を設定します:

```bash
cp .env.sample .env
```

```bash
SERVER_IP=203.0.113.1          # デプロイ先サーバの IP アドレス
SERVER_USERNAME=ubuntu         # SSH ユーザー名
SERVER_SSH_PORT=22             # SSH ポート
TSUZURI_BASE_URL=https://your-domain.example
TSUZURI_DOMAIN=your-domain.example
TSUZURI_USERNAME=your-username
TSUZURI_EMAIL=admin@example.com
TSUZURI_PASSWORD=change-me
TSUZURI_SOURCE_URL=https://github.com/S-H-GAMELINKS/tsuzuri
```

`config/deploy.yml` は ERB テンプレートになっており、`.env` の値が自動的に反映されるため、基本的に編集不要です。

`TSUZURI_SOURCE_URL` は AGPL 準拠のためソースコードへのリンクに使われます。fork の場合は自分のリポジトリ URL に変更してください。

`TSUZURI_EMAIL` / `TSUZURI_PASSWORD` は初回 `db:prepare` 時の seed アカウント作成に使われます（既に `accounts` が存在する場合は seed はスキップされます）。

### 2. production credentials の生成

`config/credentials/production.yml.enc` と `config/credentials/production.key` を生成します:

```bash
RAILS_ENV=production bin/rails credentials:edit
```

エディタを閉じると、`production.yml.enc` と `production.key` が作成（または更新）されます。

### 3. `.kamal/secrets` の設定

```bash
RAILS_MASTER_KEY=$(cat config/credentials/production.key)
```

`RAILS_MASTER_KEY` のみ設定すれば十分です。ローカルレジストリではレジストリ用のパスワードは不要です。

`config/credentials/production.key` は秘密情報なので Git に含めないでください。

### 4. レジストリについて

デフォルトの `registry.server: localhost:5555` はそのままで OK です。Kamal がデプロイ先サーバ上にローカルレジストリを自動で起動するため、外部レジストリのアカウントやトークンは不要です。

> **リモートレジストリを使いたい場合（オプション）**
>
> ghcr.io や Docker Hub 等を使う場合は `config/deploy.yml` の `registry` セクションを以下のように変更し、`.kamal/secrets` に `KAMAL_REGISTRY_PASSWORD` を追加してください。
>
> ```yaml
> registry:
>   server: ghcr.io
>   username: your-user
>   password:
>     - KAMAL_REGISTRY_PASSWORD
> ```

## デプロイ実行

### 初回デプロイ

```bash
bin/kamal setup
```

これにより Docker のインストール、ローカルレジストリの起動、コンテナのビルド・プッシュ、サーバの初期化が行われます。

### 以降のデプロイ

```bash
bin/kamal deploy
```

## 便利コマンド

`config/deploy.yml` の `aliases` セクションで定義済み:

```bash
# Rails console
bin/kamal console

# サーバシェル
bin/kamal shell

# ログ
bin/kamal logs

# データベースコンソール
bin/kamal dbc
```

## データベース

Tsuzuri は SQLite3 を使用します。データベースファイルは Docker ボリュームにマウントされます:

```yaml
volumes:
  - "tsuzuri_storage:/rails/storage"
```

`/rails/storage` 配下に SQLite3 の DB ファイル、Solid Queue のデータ等が保存されます。

### バックアップ

サーバ上で Docker ボリュームのバックアップを取ることを推奨します:

```bash
# ボリュームの場所を確認
docker volume inspect tsuzuri_storage

# バックアップ例
sudo cp -r /var/lib/docker/volumes/tsuzuri_storage/_data /path/to/backup/
```

## トラブルシューティング

### コンテナが起動しない

```bash
bin/kamal app logs
```

でログを確認してください。`RAILS_MASTER_KEY` の設定漏れが最も多い原因です。

### データベースのマイグレーションエラー

```bash
bin/kamal app exec "bin/rails db:migrate"
```

### SSL 証明書が取得できない

- DNS の A レコードがサーバ IP を正しく指しているか確認
- ポート 80/443 がファイアウォールで開いているか確認

### アセットが 404 になる

再デプロイすることで解消される場合があります:

```bash
bin/kamal deploy
```
