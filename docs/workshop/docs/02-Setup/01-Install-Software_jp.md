# 2.1 ソフトウェアのインストール

必要な開発環境は、Python ランタイムを備えた Visual Studio (VS) Code エディターを使用します。このラボを自分のコンピューターで完了するには、以下の必要なソフトウェアをインストールする必要があります。このステップを完了すると、次のソフトウェアがインストールされているはずです。

- [X] Azure コマンドラインツール
- [X] PowerShell 7
- [X] Git
- [X] Python 3.11+
- [X] Node.js
- [X] Docker デスクトップ
- [X] Visual Studio Code と必要な拡張機能
- [X] pgAdmin

## Azure コマンドラインツールのインストール

!!! note "このタスクでは、Azure CLI と Azure Developer CLI (`azd`) の両方をインストールします。"

    - Azure CLI は、ローカルマシンのコマンドプロンプトまたは VS Code ターミナルから Azure CLI コマンドを実行できるようにします。
    - Azure Developer CLI (`azd`) は、Azure 上でのアプリリソースのプロビジョニングとデプロイを加速するオープンソースツールです。

1. [Azure CLI](https://docs.microsoft.com/cli/azure/?view=azure-cli-latest) の最新バージョンをインストールまたはアップグレードします。OS に応じた手順は <https://learn.microsoft.com/cli/azure/install-azure-cli> を参照してください。

    !!! info "Azure CLI の最新バージョンへのアップグレード"

        すでに Azure CLI がインストールされている場合は、最新バージョンにアップグレードする必要があります。このガイドでは v2.69.0 以上が必要です。以下のコマンドを使用して最新バージョンにアップグレードできます。

        ```azurecli title=""
        az upgrade
        ```

2. インストールが完了したら、マシンでコマンドプロンプトを開き、次のコマンドを実行してインストールを確認します。

    ```azurecli title=""
    az version
    ```

3. 次に、Azure CLI に `ml` 拡張機能をインストールします。

    !!! info "`ml` 拡張機能について"

        Azure CLI の `ml` 拡張機能は、Azure Machine Learning の強化されたインターフェースです。コマンドラインからモデルのトレーニングとデプロイを可能にし、データサイエンスのスケーリングを加速し、モデルのライフサイクルを追跡する機能を備えています。

    `ml` 拡張機能をインストールするには、既存の拡張機能と CLI v1 の `azure-cli-ml` 拡張機能を最初に削除する必要があります。

    ```azurecli title=""
    az extension remove -n azure-cli-ml
    az extension remove -n ml
    ```

    次に、以下を実行して `ml` 拡張機能の最新バージョンをインストールします:

    ```azurecli title=""
    az extension add -n ml
    ```

4. お使いのOSに応じた手順に従って、Azure Developer CLIを最新バージョンにインストールまたはアップグレードします。詳細は <https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd> を参照してください。

    !!! info "Azure Developer CLIの最新バージョンへのアップグレード"

        すでにAzure Developer CLIをインストールしている場合は、最新バージョンにアップグレードする必要があります。このガイドではv1.12以上が必要です。

5. ターミナルプロンプトから次のコマンドを実行して、ツールがインストールされたことを確認します:

    ```bash title=""
    azd version
    ```

## PowerShell 7のインストール

ソリューションアクセラレータのプロビジョンとデプロイを実行するには、PowerShell 7をインストールする必要があります。デフォルトでは、Windows 11にはPowerShell 7が含まれていません。

1. お使いのOSに応じたインストール手順に従って、[PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell?view=powershell-7.5) をインストールまたはアップグレードします:

    - [Windows](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
    - [macOS](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.5)
    - [Linux](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.5)

2. インストールが完了したら、マシンでコマンドプロンプトを開き、次のコマンドを実行してインストールを確認します:

    ```bash title=""
    pwsh
    ```

3. コマンドプロンプトには、PowerShellのバージョンが `7.5.0` 以上であることが表示されるはずです。

    ![コマンドプロンプトに 'pwsh' コマンドの結果が表示されているスクリーンショット。](../img/powershell-verify-installation.png)

!!! failure "`pwsh` コマンドの実行エラー"

    `pwsh` コマンドの実行にエラーがある場合、PowerShell 7がインストールされていません。


    ![`pwsh` コマンドエラーのスクリーンショット。コマンドが認識されないと表示されている。](../img/powershell-pwsh-error.png)

## Gitのインストール

Gitは、コードの変更を追跡し、バージョン履歴を維持し、他の人とのコラボレーションを促進することで、コードの管理を可能にします。これにより、プロジェクトの開発を整理し、その整合性を維持するのに役立ちます。

1. <https://git-scm.com/downloads> からGitをダウンロードします。

2. デフォルトのオプションを使用してインストーラーを実行します。

## Pythonのインストール

Pythonは、このソリューションのバックエンドAPIを構築するために使用されるプログラミング言語です。Pythonの多用途なプログラミング機能とAzure Database for PostgreSQLの生成AIおよびベクター検索機能を利用することで、強力で効率的なAIコパイロットを作成し、複雑なワークフローを合理化できます。

1. <https://python.org/downloads> からPython 3.11+をダウンロードします。

2. デフォルトのオプションを使用してインストーラーを実行します。

3. ターミナルプロンプトから次のコマンドを使用して、Pythonがインストールされたことを確認します：

    ```bash title=""
    python --version
    ```

## Node.jsのインストール

Node.jsは、ブラウザ外でJavaScriptコードを実行できるオープンソースのランタイム環境です。スケーラブルなネットワークアプリケーションの構築に最適で、Reactシングルページアプリケーションとシームレスに連携し、サーバーサイドのロジックとAPIリクエストを処理するバックエンド環境を提供します。これにより、フロントエンドとバックエンド間の効率的な開発とスムーズな相互作用が可能になります。

1. <https://nodejs.org/en/download/> からNode.jsをダウンロードし、最新のLTSバージョンと正しいOSを選択します。

2. デフォルトのオプションを使用してインストーラーを実行します。

## Docker Desktopのインストール

Docker Desktopは、ローカルマシンでコンテナ化されたアプリケーションを構築、共有、および実行できるアプリケーションです。Dockerコンテナ、イメージ、およびネットワークを管理するためのユーザーフレンドリーなインターフェースを提供します。コンテナ化プロセスを合理化することで、Docker Desktopは異なる環境間でアプリケーションを一貫して開発、テスト、およびデプロイするのに役立ちます。

1. <https://docs.docker.com/desktop/> に記載されている手順を使用して、OSに適したDocker Desktopをダウンロードしてインストールします。


    - [Linux](https://docs.docker.com/desktop/setup/install/linux/)
    - [Mac](https://docs.docker.com/desktop/setup/install/mac-install/)
    - [Windows](https://docs.docker.com/desktop/setup/install/windows-install/)

## Visual Studio Code（および拡張機能）のインストール

Visual Studio Codeは、強力な機能と直感的なインターフェースを組み合わせた多用途のオープンソースコードエディタで、プロジェクトの効率的な記述、デバッグ、カスタマイズを支援します。

1. <https://code.visualstudio.com/download> からダウンロードしてインストールします。

    - インストーラーのデフォルトオプションを使用します。

2. インストールが完了したら、Visual Studio Codeを起動します。

3. **Extensions** メニューで、Microsoftから次の拡張機能を検索してインストールします。

    - [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)

4. VS Codeを閉じます。

## pgAdminのインストール

このワークショップを通じて、PostgreSQLデータベースに対してクエリを実行するためにpgAdminを使用します。pgAdminは、Postgresのための主要なオープンソース管理ツールです。

1. <https://www.pgadmin.org/download/> からpgAdminをダウンロードします。

2. デフォルトオプションを使用してインストーラーを実行します。
