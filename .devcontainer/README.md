# VSCode Dev Container Configuration

この設定により、VSCode で SAM 3D Objects プロジェクトを Docker コンテナ内で開発できます。

## 使い方

1. VSCode に [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 拡張機能をインストール

2. このプロジェクトを VSCode で開く

3. コマンドパレット (Ctrl+Shift+P または Cmd+Shift+P) を開く

4. "Remote-Containers: Reopen in Container" を選択

5. コンテナのビルドと起動が完了するまで待つ（初回は時間がかかります）

## 機能

- **自動環境構築**: すべての依存関係が自動的にインストールされます
- **GPU サポート**: NVIDIA GPU がコンテナ内で利用可能
- **Python 開発ツール**: Pylance、Jupyter、Ruff などが事前設定済み
- **フォーマット**: Black によるコード整形が保存時に自動実行
- **ボリュームマウント**: ホストとコンテナ間でファイルが同期

## 前提条件

- Docker Engine (>= 20.10)
- NVIDIA Container Toolkit
- NVIDIA GPU (32GB VRAM以上推奨)

## 設定のカスタマイズ

`devcontainer.json` を編集して、追加の拡張機能やポート転送などを設定できます。

## トラブルシューティング

コンテナのビルドに失敗する場合:

1. Docker Desktop / Docker Engine を再起動
2. コマンドパレットから "Remote-Containers: Rebuild Container" を実行
3. それでも解決しない場合は、`docker system prune -a` でキャッシュをクリア
