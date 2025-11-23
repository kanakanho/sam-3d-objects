# Docker Development Environment Setup

このドキュメントでは、SAM 3D Objects プロジェクトをDockerコンテナ内で開発するための手順を説明します。

## 前提条件

* Docker Engine (>= 20.10)
* Docker Compose (>= 1.29)
* NVIDIA Docker Runtime ([nvidia-docker](https://github.com/NVIDIA/nvidia-docker))
* NVIDIA GPU with at least 32 GB VRAM
* Linux 64-bit architecture

## 1. NVIDIA Docker のインストール

まず、NVIDIA Container Toolkitをインストールする必要があります:

```bash
# Add the package repositories
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install nvidia-docker2
sudo apt-get update
sudo apt-get install -y nvidia-docker2

# Restart Docker daemon
sudo systemctl restart docker

# Test GPU access
docker run --rm --gpus all nvidia/cuda:12.1.1-base-ubuntu22.04 nvidia-smi
```

## 2. Docker イメージのビルド

プロジェクトのルートディレクトリで以下のコマンドを実行します:

```bash
# Docker イメージをビルド
docker build -t sam3d-objects:dev .

# または、docker-compose を使用
docker-compose build
```

**注意**: 初回のビルドには時間がかかります（30分〜1時間程度）。すべての依存関係がインストールされます。

## 3. コンテナの起動

### 方法 A: docker-compose を使用（推奨）

```bash
# コンテナをバックグラウンドで起動
docker-compose up -d

# コンテナに接続
docker-compose exec sam3d-dev mamba run -n sam3d-objects bash

# コンテナを停止
docker-compose down
```

### 方法 B: docker run を使用

```bash
docker run --gpus all \
  --shm-size=16gb \
  -it \
  -v $(pwd):/workspace \
  --name sam3d-dev \
  sam3d-objects:dev
```

## 4. VSCode Dev Container の使用

VSCode で開発する場合は、Dev Container 機能を使用することをお勧めします。

### 必要な拡張機能

* [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### 使い方

1. プロジェクトを VSCode で開く
2. コマンドパレット (Ctrl+Shift+P / Cmd+Shift+P) を開く
3. "Remote-Containers: Reopen in Container" を選択
4. コンテナのビルドと起動が完了するまで待つ

VSCode は自動的にコンテナ内でワークスペースを開き、すべての開発ツールが利用可能になります。

### 含まれる VSCode 拡張機能

* Python
* Pylance
* Jupyter
* Ruff (linter)
* Docker
* GitLens

## 5. 環境の確認

コンテナ内で以下のコマンドを実行して、環境が正しくセットアップされているか確認します:

### 方法 A: 検証スクリプトを使用（推奨）

```bash
# コンテナ内で検証スクリプトを実行
/workspace/scripts/verify-docker-env.sh
```

### 方法 B: 手動で確認

```bash
# conda 環境をアクティベート
mamba activate sam3d-objects

# Python のバージョン確認
python --version  # Should be 3.11.0

# PyTorch と CUDA の確認
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA Available: {torch.cuda.is_available()}'); print(f'CUDA Version: {torch.version.cuda}')"

# GPU の確認
nvidia-smi
```

## 6. デモの実行

環境が正しくセットアップされたら、デモを実行できます:

```bash
# conda 環境をアクティベート（まだの場合）
mamba activate sam3d-objects

# チェックポイントのダウンロード（初回のみ）
# まず HuggingFace でログイン
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

# デモを実行
python demo.py
```

## トラブルシューティング

### GPU が認識されない

```bash
# ホストシステムで確認
nvidia-smi

# Docker で NVIDIA ランタイムが有効か確認
docker run --rm --gpus all nvidia/cuda:12.1.1-base-ubuntu22.04 nvidia-smi
```

### メモリ不足エラー

`--shm-size` を増やすか、`docker-compose.yml` の `shm_size` 設定を調整してください。

### ビルドエラー

1. Docker と NVIDIA Container Toolkit が最新版であることを確認
2. キャッシュをクリアしてビルドをやり直す:
   ```bash
   docker-compose build --no-cache
   ```

## 開発のヒント

### コンテナ内でのコード変更

コンテナ内で変更したコードは、ボリュームマウントによってホストシステムにも反映されます。

### Jupyter Notebook の使用

```bash
# コンテナ内で Jupyter を起動
mamba activate sam3d-objects
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
```

その後、ブラウザで表示されるトークン付きのURLにアクセスします。

### パッケージの追加

新しいパッケージを追加する場合:

1. `requirements.txt` などに追加
2. コンテナ内で `pip install <package>` を実行
3. 永続化するには Dockerfile を更新してリビルド

## 参考リンク

* [Docker Documentation](https://docs.docker.com/)
* [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker)
* [VS Code Remote Containers](https://code.visualstudio.com/docs/remote/containers)
