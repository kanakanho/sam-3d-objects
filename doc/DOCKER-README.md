# Docker環境構築 - ドキュメント一覧

SAM 3D Objects プロジェクトのDocker環境に関するドキュメントへのクイックリンク集です。

## 📚 ドキュメント

### 1. [クイックスタート（3ステップ）](quick-start-docker-ja.md)
**推奨**: 最短でDocker環境を立ち上げたい方向け
- 前提条件の確認
- 3ステップでの起動手順
- 基本的なトラブルシューティング

### 2. [完全なDocker設定ガイド](docker-setup.md)
詳細な設定手順とトラブルシューティングを知りたい方向け
- NVIDIA Dockerの詳細なインストール手順
- 環境の検証方法
- Jupyter Notebookの使用方法
- よくある問題と解決方法

### 3. [Dockerコマンドチートシート](docker-commands-cheatsheet.md)
日常的な開発作業で使用するコマンドのリファレンス
- コンテナの管理
- 開発タスクの実行
- デバッグとトラブルシューティング
- VSCode Dev Containerの使い方

## 🚀 クイックリファレンス

### 最小構成での起動

```bash
# イメージをビルド
docker compose build

# コンテナを起動
docker compose up -d

# コンテナに接続
docker compose exec sam3d-dev mamba run -n sam3d-objects bash
```

### Makefileを使用（推奨）

```bash
make build   # ビルド
make up      # 起動
make shell   # シェルに接続
make test    # 環境をテスト
make down    # 停止
make clean   # クリーンアップ
```

### VSCode Dev Container

1. VSCodeで [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 拡張機能をインストール
2. プロジェクトを開く
3. `Ctrl+Shift+P` → "Remote-Containers: Reopen in Container"

## 📁 プロジェクト構造

```
sam-3d-objects/
├── .devcontainer/          # VSCode Dev Container設定
│   ├── devcontainer.json   # Dev Container設定ファイル
│   ├── post-create.sh      # コンテナ作成後のスクリプト
│   └── README.md           # Dev Container使い方
├── doc/                    # ドキュメント
│   ├── docker-setup.md     # 完全なDocker設定ガイド
│   ├── quick-start-docker-ja.md  # クイックスタート
│   └── docker-commands-cheatsheet.md  # コマンドリファレンス
├── scripts/                # ヘルパースクリプト
│   └── verify-docker-env.sh  # 環境検証スクリプト
├── Dockerfile              # Docker イメージ定義
├── docker-compose.yml      # Docker Compose設定
├── .dockerignore           # Docker ビルドから除外するファイル
└── Makefile                # 便利なコマンドのショートカット
```

## 🔧 構成の詳細

### ベースイメージ
- **nvidia/cuda:12.1.1-devel-ubuntu22.04**
- CUDA 12.1対応
- Ubuntu 22.04 LTS

### Python環境
- **Python 3.11.0**
- Mambaforge (高速なconda互換パッケージマネージャー)
- 環境名: `sam3d-objects`

### 含まれる主な依存関係
- PyTorch 2.5.1 with CUDA 12.1
- PyTorch3D
- CUDA深層学習ライブラリ群
- 3D処理ライブラリ (open3d, point-cloud-utils等)
- 開発ツール (pytest, black, flake8)

### VSCode拡張機能
- Python
- Pylance
- Jupyter
- Ruff (linter)
- Docker
- GitLens

## ⚙️ カスタマイズ

### メモリ設定の変更

大きなモデルを扱う場合、共有メモリを増やすことができます:

```yaml
# docker-compose.yml
shm_size: '32gb'  # デフォルトは16gb
```

### ポートの追加

Jupyter NotebookやTensorBoardなどのサービスを公開する場合:

```yaml
# docker-compose.yml
ports:
  - "8888:8888"  # Jupyter
  - "6006:6006"  # TensorBoard
```

### 追加パッケージのインストール

一時的なインストール（コンテナ内で）:
```bash
mamba run -n sam3d-objects pip install <package>
```

永続的なインストール（Dockerfileに追加）:
```dockerfile
RUN mamba run -n sam3d-objects pip install <package>
```

その後、イメージを再ビルド:
```bash
docker compose build
```

## 🐛 トラブルシューティング

### よくある問題

| 問題 | 解決方法 |
|------|----------|
| GPUが認識されない | `nvidia-smi` でGPUが見えるか確認、NVIDIA Docker Runtimeをインストール |
| ビルドが失敗する | `docker compose build --no-cache` でキャッシュをクリアして再ビルド |
| メモリ不足 | `docker-compose.yml` の `shm_size` を増やす |
| パッケージが見つからない | conda環境がアクティブか確認: `mamba activate sam3d-objects` |

詳細は [docker-setup.md](docker-setup.md) のトラブルシューティングセクションを参照してください。

## 📞 サポート

- 問題が発生した場合は [GitHub Issues](https://github.com/facebookresearch/sam-3d-objects/issues) に報告してください
- 設定の詳細については各ドキュメントを参照してください

## 🔗 関連リンク

- [Docker Documentation](https://docs.docker.com/)
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker)
- [VS Code Remote Containers](https://code.visualstudio.com/docs/remote/containers)
- [SAM 3D Objects - Main README](../README.md)
