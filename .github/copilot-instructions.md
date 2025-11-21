## AIアシスタント向けクイック案内

このリポジトリは NodeCG を Docker 中心で立ち上げる開発環境と、代表的なバンドルである `nodecg-speedcontrol` を含みます。
ここでは AI コーダーがすぐに作業を始められるように、実行手順、主要ファイル、開発パターンをコンパクトにまとめます。

大まかな構成
- ルートの `Dockerfile` と `docker-compose.yml` で NodeCG をコンテナ実行します。`nodecg.json` と `bundles/` をコンテナにマウントする構成で、デフォルトポートは 9090 です。
- バンドルは `bundles/<bundle-name>/` 配下に置きます。典型的には次の構造です:
  - `dashboard/` — Vue + Webpack（ビルド設定は `bundles/.../webpack.config.mjs`）
  - `extension/` — TypeScript の Node サーバ/拡張（ビルドは `tsc`）

重要な開発ワークフロー（コマンド）
- リポジトリ全体を起動する（推奨）: ルートで
  - `./start.sh`（macOS/Linux）または `start.bat`（Windows）
  - 同等: `docker-compose up --build` / デタッチ: `docker-compose up -d --build`
  - 停止: `docker-compose down`
- バンドル単位での開発（例: `bundles/nodecg-speedcontrol`）
  - 依存インストール: `pnpm install`（`pnpm-lock.yaml` があるため pnpm を推奨）
  - 一度ビルド: `pnpm run build`（内部で `build:browser`（webpack）と `build:extension`（tsc）を実行）
  - 開発ウォッチ: `pnpm run watch`（`watch:browser` と `watch:extension` を並列実行）。Docker を使う場合はローカルで watch を走らせておくと、ビルド済みアセットがコンテナへ反映されます。
  - バンドル内から NodeCG を直接起動（ローカル検証）: `pnpm start`（`package.json` の `start` は `node ../..` を呼びます）

必読ファイル（実装やデバッグで最初に見るべき箇所）
- `docker-compose.yml` — `nodecg.json` と `./bundles` をコンテナにマウント。ポートとボリューム設定をまず確認。
- `Dockerfile` — NodeCG 本体をクローンしてビルドするイメージ定義（`git clone --branch nodecg-v2.6.2`）。実行コマンドは `node index.js`。
- `nodecg.json` — 開発向けに `developer.enable: true` と `panelResourceCacheDuration: 0`（リソースキャッシュ無効）が設定されています。
- `bundles/nodecg-speedcontrol/package.json` — バンドル固有のスクリプトと依存関係の参照先。重要なスクリプト:
  - `build:browser`（webpack）
  - `build:extension`（tsc）
  - `watch:browser` / `watch:extension`
  - `start`（NodeCG を起動するためのショートカット）
- `bundles/nodecg-speedcontrol/webpack.config.mjs` — dashboard（フロント）のエントリ検出や LiveReload の設定例が見られます。
- `bundles/*/tsconfig.*.json` — TypeScript のパス・モジュール解決を確認する際に参照。

このリポジトリ固有の慣習・注意点
- バンドルは自己完結を想定しています。変更は `bundles/<name>/` を編集し、そのバンドルの `pnpm` スクリプトでビルド/ウォッチするのが基本フローです。
- webpack は各エントリごとに出力をバンドルの `dashboard` フォルダへ置きます。`webpack.config.mjs` を見れば出力先やエントリ検出の挙動がわかります。
- `pnpm-lock.yaml` が存在するため依存は `pnpm` を推奨しますが、必要なら `npm` でも操作可能です。
- 開発時は LiveReload が有効になっているので、設定を不用意に外すとホットリロードが効かなくなります。

外部連携・依存のポイント
- NodeCG 本体は Docker イメージ作成時に Git からクローンされます（NodeCG v2.x セマンティクス）。
- `nodecg-speedcontrol` は Vue 2.7、Vuetify、webpack、TypeScript 等のエコシステムに依存しています。バージョンは `bundles/nodecg-speedcontrol/package.json` を参照。

よくあるトラブルと確認手順
- バンドルがダッシュボードに表示されない → コンテナにマウントされた `bundles/` に該当バンドルが存在するか、`docker-compose` の volume 設定を確認。
- フロント側の変更が反映されない → `nodecg.json` の `panelResourceCacheDuration` が 0（キャッシュ無効）になっているか、ローカルで `pnpm run watch` が動いているか確認。
- ログを見るには: `docker-compose logs -f` または `docker logs -f <container-name>`。

このファイルの編集方法
- リポジトリ特有の追加ルール（新しいバンドルの追加や CI の手順など）を見つけたら、該当ファイルへの短い参照と具体例を追加してください。

不明点がある場合に聞くべきこと（推奨）
- ローカルで NodeCG を起動してデバッグしたいのか、完全コンテナ化されたフローで動かすのかを教えてください。
- どのバンドルを重点的に編集したいか（例: `nodecg-speedcontrol` の UI 追加、`extension` の TypeScript ロジック修正など）。

参考リンク（リポジトリ内）
- `docker-compose.yml`, `Dockerfile`, `nodecg.json`, `start.sh`, `start.bat`
- `bundles/nodecg-speedcontrol/package.json`, `bundles/nodecg-speedcontrol/webpack.config.mjs`, `bundles/nodecg-speedcontrol/README.md`

---
この日本語版で不足している箇所や、さらに詳しいバンドル単位の手順（パネル追加の例、Replicant の追加手順など）を追加しましょうか？ご希望があれば対象バンドルを指定してください。
