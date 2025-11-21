# 🛠️ 変更点: Node.js v18 -> v20-slim (Iron)
# ビルドツール(rolldown)が styleText 関数(v20.12+)を必要とするため
FROM node:20-slim

# 1. 必要なツール（Git, Python, ビルドツール）をインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    make \
    g++ \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリ（ここがNodeCGのルートになります）
WORKDIR /app/nodecg

# 2. NodeCG v2.6.2 をGitHubから直接クローン
# --depth 1 で履歴を浅く取得し、イメージサイズを削減
RUN git clone --branch nodecg-v2.6.2 --depth 1 https://github.com/nodecg/nodecg.git .

# 3. 依存関係のインストールとビルド
# NodeCG本体のビルドには devDependencies が必要なため、単に npm install を実行
RUN npm install --unsafe-perm

# 4. NodeCGのビルド（TypeScriptのコンパイルなど）
RUN npm run build --if-present

# 5. 設定とバンドル用のディレクトリ作成
RUN mkdir -p cfg bundles logs

# 権限修正（nodeユーザーが書き込めるように）
RUN chown -R node:node /app/nodecg

# ポート公開
EXPOSE 9090

# 実行ユーザー切り替え
USER node

# 6. 起動コマンド
# CLIを経由せず、NodeCG本体のエントリーポイントを直接叩くことでエラーを回避
CMD ["node", "index.js"]