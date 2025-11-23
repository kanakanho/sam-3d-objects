# Docker Commands Cheat Sheet

SAM 3D Objects プロジェクトで使用する一般的なDockerコマンドのリファレンスです。

## 基本的なコマンド

### コンテナの管理

```bash
# イメージをビルド
docker-compose build
# または
make build

# コンテナを起動（デタッチモード）
docker-compose up -d
# または
make up

# コンテナを停止
docker-compose down
# または
make down

# コンテナを再起動
docker-compose restart
# または
make restart

# コンテナの状態を確認
docker-compose ps

# コンテナのログを表示
docker-compose logs -f
# または
make logs
```

### コンテナに接続

```bash
# Bashシェルを開く
docker-compose exec sam3d-dev mamba run -n sam3d-objects bash
# または
make shell

# Python REPLを開く
docker-compose exec sam3d-dev mamba run -n sam3d-objects python

# 特定のコマンドを実行
docker-compose exec sam3d-dev mamba run -n sam3d-objects python demo.py
```

## 開発タスク

### 環境の検証

```bash
# 検証スクリプトを実行
docker-compose exec sam3d-dev /workspace/scripts/verify-docker-env.sh

# PyTorchとCUDAを確認
docker-compose exec sam3d-dev mamba run -n sam3d-objects \
  python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"

# または
make test
```

### コードの実行

```bash
# デモを実行
docker-compose exec sam3d-dev mamba run -n sam3d-objects python demo.py

# Jupyter Notebookを起動
docker-compose exec sam3d-dev mamba run -n sam3d-objects \
  jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root

# テストを実行
docker-compose exec sam3d-dev mamba run -n sam3d-objects pytest
```

### パッケージの管理

```bash
# 新しいパッケージをインストール
docker-compose exec sam3d-dev mamba run -n sam3d-objects pip install <package-name>

# requirements.txtから再インストール
docker-compose exec sam3d-dev mamba run -n sam3d-objects pip install -r requirements.txt

# インストール済みパッケージを確認
docker-compose exec sam3d-dev mamba run -n sam3d-objects pip list
```

## トラブルシューティング

### コンテナのリセット

```bash
# コンテナを完全に削除して再作成
docker-compose down
docker-compose up -d

# イメージから再ビルド
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### ログとデバッグ

```bash
# コンテナの詳細情報を表示
docker-compose ps -a

# すべてのログを表示
docker-compose logs

# 特定のサービスのログのみ
docker-compose logs sam3d-dev

# リアルタイムでログを追跡
docker-compose logs -f --tail=100 sam3d-dev
```

### リソースの確認

```bash
# GPUの状態を確認
docker-compose exec sam3d-dev nvidia-smi

# コンテナのリソース使用状況
docker stats sam3d-dev

# ディスク使用量
docker system df
```

### クリーンアップ

```bash
# コンテナとボリュームを削除
docker-compose down -v

# イメージも削除
docker-compose down
docker rmi sam3d-objects:dev

# Dockerシステム全体をクリーンアップ（注意！）
docker system prune -a

# または
make clean
```

## ファイルのコピー

### ホストとコンテナ間

```bash
# ホストからコンテナへ
docker cp /path/on/host/file.txt sam3d-dev:/workspace/file.txt

# コンテナからホストへ
docker cp sam3d-dev:/workspace/output.ply /path/on/host/output.ply
```

**注意**: ボリュームマウントを使用しているため、通常はファイルコピーは不要です。
`/workspace` ディレクトリはホストと同期されています。

## 高度な使用法

### カスタムコマンドでコンテナを起動

```bash
# カスタムコマンドで一時的なコンテナを起動
docker-compose run --rm sam3d-dev mamba run -n sam3d-objects python my_script.py
```

### 複数のターミナルで接続

```bash
# ターミナル1
docker-compose exec sam3d-dev mamba run -n sam3d-objects bash

# ターミナル2（別のウィンドウ）
docker-compose exec sam3d-dev mamba run -n sam3d-objects bash
```

### ポートフォワーディング

Jupyter Notebookやその他のWebサービスを使用する場合:

```yaml
# docker-compose.yml に追加
ports:
  - "8888:8888"  # Jupyter
  - "6006:6006"  # TensorBoard
```

その後:

```bash
docker-compose down
docker-compose up -d
```

## Makefileのショートカット

プロジェクトに含まれるMakefileでは、以下のコマンドが利用可能です:

```bash
make help      # ヘルプを表示
make build     # イメージをビルド
make up        # コンテナを起動
make down      # コンテナを停止
make restart   # コンテナを再起動
make shell     # Bashシェルを開く
make logs      # ログを表示
make clean     # すべてクリーンアップ
make test      # 環境をテスト
```

## VSCode Dev Container

VSCode Dev Containerを使用している場合、ほとんどのコマンドはVSCode内から直接実行できます:

1. `Ctrl+Shift+P` (Cmd+Shift+P on Mac) でコマンドパレットを開く
2. "Remote-Containers" で始まるコマンドを検索

よく使うコマンド:
- `Remote-Containers: Rebuild Container` - コンテナを再ビルド
- `Remote-Containers: Reopen Locally` - ローカルで開き直す
- `Remote-Containers: Show Container Log` - ログを表示

## 参考リンク

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose CLI Reference](https://docs.docker.com/compose/reference/)
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker)
