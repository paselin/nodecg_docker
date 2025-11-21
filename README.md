# nodecg-docker

このリポジトリは NodeCG を Docker 環境で動かすための設定と、配信イベント向けのバンドル（主に speedcontrol 系）をコンテナ化して起動・開発できるようにまとめたものです。

## 目次
- 概要
- 前提条件
- 簡単な起動手順
- 開発ワークフロー（バンドル単位）
- リポジトリ構成
- 含まれるバンドル（概要）
- トラブルシューティング
- 貢献方法
- ライセンス

## 概要
- NodeCG 本体と複数のバンドルを Docker / docker-compose で起動します。
- 各バンドルは `bundles/` 配下にあり、個別に開発・ビルドできます。

## 前提条件
- Docker と docker-compose（または Docker Desktop）がインストールされていること
- 開発時にローカルでビルドする場合は Node.js と pnpm/npm が必要になる場合があります（バンドルごとの README を参照してください）

## 簡単な起動手順
リポジトリのルートで以下を実行します。

```bash
# ビルドして起動（フォアグラウンド）
docker-compose up --build

# デタッチして起動
docker-compose up -d --build

# 停止
docker-compose down
```

付属のラッパースクリプトも利用できます：`start.sh`（macOS/Linux）と `start.bat`（Windows）。

## 開発ワークフロー（バンドル単位）
1. `bundles/<bundle-name>` に移動
2. バンドルの README / package.json を確認して依存をインストール（例: `pnpm install`）
3. ビルド（必要な場合）: `pnpm run build` 等
4. コンテナで動作確認、またはローカルの NodeCG に接続して動作確認

例:

```bash
cd bundles/nodecg-speedcontrol
pnpm install
pnpm run build
```

ホットリロードやファイル同期が設定されている場合は、それに従って編集→反映を行ってください。

## リポジトリ構成

- `docker-compose.yml` - 全体の Docker Compose 設定
- `Dockerfile` - ルートにある場合は NodeCG 用のイメージ定義
- `nodecg.json` - NodeCG の設定
- `start.sh`, `start.bat` - 起動ラッパー
- `bundles/` - NodeCG バンドル群

- `bundles/` - NodeCG バンドル群（注意: 多くの開発フローでは `bundles/` をローカルで管理するため、ルートの `.gitignore` によりデフォルトで無視されていることがあります。リポジトリにバンドルが含まれていない（空の）場合は、必要なバンドルを別途配置してください。）
  - 例: `nodecg-speedcontrol/`, `speedcontrol-additions/`, `speedcontrol-simpletext/` などを配置して利用します。

※ バンドルが `bundles/` に存在しない場合は、別リポジトリからクローンする、または配布されたパッケージをコピーして配置してください。
各バンドル内には通常それぞれの `README.md`、`package.json`、`Dockerfile`、`docker-compose.yml` が含まれているので、個別に確認してください。

## よく使われるバンドル（概要）
- `nodecg-speedcontrol`: run 管理・レイアウト・ダッシュボード等を提供する主要バンドル
- `speedcontrol-additions`: 追加機能（コメント管理やインポート等）を提供するバンドル群
- `speedcontrol-simpletext`: 簡易なグラフィック（テキスト）表示用

## トラブルシューティング
- コンテナ起動時にポート競合が発生する場合、`docker-compose.yml` 内のポート設定を確認してください。
- バンドルが読み込まれない場合、`nodecg` のログ（コンテナのログ）を確認し、バンドルディレクトリが正しいか確認してください。
- `.gitignore` により `bundles/` が無視されている場合、新規ファイルは Git に追加されません。既にコミット済みのファイルは `.gitignore` の変更だけでは追跡解除されません。

## 貢献方法
1. Issue を立てて変更内容や目的を共有してください。
2. Fork → ブランチ作成 → 変更 → Pull Request を送ってください。

PR には変更点の要約と動作確認手順を添えてください。

## ライセンス
- 各バンドルに個別の `LICENSE` ファイルがある場合はそちらが優先されます。全体としてのライセンスは各ファイル／バンドルに従います。

---

作成日: 2025-11-21
