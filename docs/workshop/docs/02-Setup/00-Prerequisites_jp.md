# 2.0 前提条件

ワークショップを始める前に必要なこと、事前に知っておくべきこと、完了後に得られるものについての詳細を確認してください。

## 必要なもの

このソリューションアクセラレーターを完了するためには、以下が必要です：

1. **あなた自身のコンピュータ。**
    - Visual Studio Code、Docker Desktop、および最新のウェブブラウザを実行できるコンピュータであれば問題ありません。
    - コンピュータにソフトウェアをインストールできる必要があります。
    - Edge、Chrome、またはSafariの最新バージョンをインストールすることをお勧めします。
2. **GitHubアカウント。**
    - サンプルリポジトリのコピー（フォークと呼ばれる）を作成するために必要です。
    - 個人用（企業用ではなく）のGitHubアカウントを使用する方が便利なので、お勧めです。
    - GitHubアカウントをお持ちでない場合は、[無料でサインアップ](https://github.com/signup)してください。（数分で完了します。）
3. **Azureサブスクリプション。**
    - AIプロジェクトのためのAzureインフラストラクチャをプロビジョニングするために必要です。
    - Azureアカウントをお持ちでない場合は、[無料でサインアップ](https://aka.ms/free)してください。（数分で完了します。）
4. **十分なAzure MLオンラインエンドポイントCPUクォータ**
    - ソリューションアクセラレーターの**セマンティックリランカー**要素を実行するために、2つの選択肢があります。
        - Standard DASv4 with 4 vCPUs 上で、小型で高品質なモデルを実行できます。
        - または、Standard DASv4 with 16 vCPUs 上で、より大きく、さらに正確なモデルを実行することもできます。
        - したがって、選択するモデルに応じて、サブスクリプションで4または16コアが利用可能であることを確認する必要があります。サブスクリプションでこれを確認するための詳細な手順はセットアップセクションに提供されています。
5. **ワークショップリソースに適したAzureリージョン**
    - ワークショップを成功裏に完了し、必要なAzureリソースをデプロイするためには、それらのリソースをサポートするリージョンを選択する必要があります。
    - Azureリージョンを選択する前に：
      - Azure OpenAIの[gpt-4o](https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=global-standard%2Cstandard-chat-completions#standard-models-by-endpoint)および[text-embedding-ada-002](https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=global-standard%2Cstandard-embeddings#standard-models-by-endpoint)モデルの地域可用性ガイダンスを確認してください。
        - **Azure OpenAIの`gpt-4o`および`text-embedding-ada-002`モデルをサポートするリージョン**を選択してください。
        - 両方の`gpt-4o`および`text-embedding-ada-002`モデルに対して、**少なくとも10K TPMの`Standard`キャパシティがリージョンで利用可能であること**を確認してください。[これらの指示](https://learn.microsoft.com/azure/ai-services/openai/how-to/quota?tabs=rest#view-and-request-quota)に従って、利用可能なクォータを確認してください。

Azure OpenAIモデルの両方をサポートし、両モデルに対して少なくとも10K TPMの`Standard`キャパシティを持つリージョンを選択する必要があります。

!!! danger "Azure OpenAIモデルの両方をサポートしていないリージョンを選択すると、`azd up`を実行した際にデプロイが失敗します。"

## 知っておくべきこと

このソリューションアクセラレータを最大限に活用するためには、以下の知識と経験が必要です。

### 推奨される知識と経験

1. **Visual Studio Codeに精通していること**
    - このワークショップで使用するデフォルトのエディタはVisual Studio Codeです。必要な拡張機能やコードライブラリを使用してVS Codeの開発環境を設定します。
    - ワークショップでは、Visual Studio Codeやその他のツールをコンピュータにインストールする必要があります。ローカルコンピュータからソリューションコードを実行します。
2. **Azureポータルに精通していること**
    - ワークショップでは、Azureポータル内のリソースにナビゲートすることに精通していることを前提としています。
    - Azureポータルを使用して、このワークショップのためにデプロイするリソースに関連するエンドポイント、キー、その他の値を取得します。
3. **PostgreSQLに精通していること**
    - ワークショップでは、基本的なSQL構文に精通していることを前提としています。
    - テーブルを変更したり、拡張機能を作成したり、テーブルに対してクエリを実行するためにSQL文を実行します。

### 望ましい知識と経験

1. **`git`操作に精通していること**
    - サンプルリポジトリをGitHubアカウントにフォークします。
    - フォークしたリポジトリにコードの変更をコミットします。
2. **`bash`シェルに精通していること**
    - 必要に応じて、VS Codeターミナルで`bash`を使用してプロビジョニング後のスクリプトを実行します。
    - セットアップ中にAzure CLIおよびAzure Developer CLIコマンドを実行するためにも使用します。
3. **PythonおよびJavaScript UIフレームワークに精通していること**
    - スターターソリューションに変更を加えるために、React JavaScriptおよびPythonコードを修正します。
    - 一部のステップでは、コマンドラインやVS CodeからPythonコードを作成して実行します。
    - 一部のステップでは、Pythonカーネルを選択して既存のスクリプトを実行します。

## あなたが得られるもの

このワークショップを完了すると、以下のものを得ることができます:

1. GitHubプロフィールに[Build Your Own Advanced AI Copilot with PostgreSQL](http://aka.ms/pg-byoac-repo/)リポジトリの個人用フォーク（コピー）。このリポジトリには、後でワークショップを再現するために必要なすべての資料が含まれています。

2. [Azure AI Foundry](https://ai.azure.com)ポータルと関連する開発者ツール（例: Azure Developer CLI、Prompty、FastAPI）を使用して、独自のAIアプリのエンドツーエンド開発ワークフローを効率化するための実践的な理解。

3. Azure AIサービスをアプリケーションに統合して、強力なAI対応アプリケーションを作成する方法の理解。
