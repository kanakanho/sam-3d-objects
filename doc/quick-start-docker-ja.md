# クイックスタート（Docker版）

このガイドでは、Dockerを使ってSAM 3D Objectsをできるだけ早く起動する方法を説明します。

## 前提条件の確認

以下がインストールされていることを確認してください：

1. **Docker** と **Docker Compose**
2. **NVIDIA Container Toolkit**
3. **NVIDIA GPU** (32GB VRAM以上推奨)

### NVIDIA Docker のインストール（必要な場合）

```bash
# Ubuntu/Debian の場合
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

## 3ステップで開始

### ステップ1: リポジトリをクローン

```bash
git clone https://github.com/facebookresearch/sam-3d-objects.git
cd sam-3d-objects
```

### ステップ2: Dockerコンテナをビルド＆起動

```bash
# イメージをビルド（初回のみ、30分〜1時間程度かかります）
docker-compose build

# コンテナを起動
docker-compose up -d

# コンテナに接続
docker-compose exec sam3d-dev mamba run -n sam3d-objects bash
```

または、Makefileを使用:

```bash
make build  # ビルド
make up     # 起動
make shell  # コンテナに接続
```

### ステップ3: 環境を検証

コンテナ内で検証スクリプトを実行:

```bash
/workspace/scripts/verify-docker-env.sh
```

すべてのチェックが通れば、環境の準備は完了です！

## デモを実行

### チェックポイントのダウンロード

```bash
# HuggingFaceにログイン（初回のみ）
pip install 'huggingface-hub[cli]<1.0'
huggingface-cli login

# チェックポイントをダウンロード
TAG=hf
huggingface-cli download \
  --repo-type model \
  --local-dir checkpoints/${TAG}-download \
  --max-workers 1 \
  facebook/sam-3d-objects
mv checkpoints/${TAG}-download/checkpoints checkpoints/${TAG}
rm -rf checkpoints/${TAG}-download
```

### デモを実行

```bash
python demo.py
```

これで `splat.ply` ファイルが生成されます！

## VSCode Dev Containerを使用

より統合された開発体験のために:

1. VSCodeに [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 拡張機能をインストール

2. プロジェクトをVSCodeで開く

3. `Ctrl+Shift+P` (Cmd+Shift+P on Mac) でコマンドパレットを開く

4. "Remote-Containers: Reopen in Container" を選択

5. 自動的にコンテナがビルドされ、VSCodeがコンテナ内で開きます

## よく使うコマンド

```bash
# コンテナの状態を確認
docker-compose ps

# コンテナのログを表示
docker-compose logs -f

# コンテナを停止
docker-compose down

# コンテナを再起動
docker-compose restart

# すべてをクリーンアップ
make clean
```

## トラブルシューティング

### GPUが認識されない

```bash
# ホストでGPUを確認
nvidia-smi

# Dockerでテスト
docker run --rm --gpus all nvidia/cuda:12.1.1-base-ubuntu22.04 nvidia-smi
```

### ビルドエラー

```bash
# キャッシュをクリアして再ビルド
docker-compose build --no-cache
```

### メモリ不足

`docker-compose.yml` の `shm_size` を増やす:

```yaml
shm_size: '32gb'  # デフォルトは16gb
```

## 次のステップ

- [完全なDocker設定ガイド](docker-setup.md)を読む
- [Jupyterノートブック](../notebook/)でより高度な使い方を学ぶ
- 複数オブジェクトの3D再構成を試す

## ヘルプが必要な場合

- [GitHub Issues](https://github.com/facebookresearch/sam-3d-objects/issues)
- [詳細なドキュメント](docker-setup.md)
