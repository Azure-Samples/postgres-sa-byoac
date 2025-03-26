# 2.6 デプロイの検証

!!! success "セットアップが完了しました！"

    ワークショップの**プロビジョン**と**セットアップ**のステップを完了しました。

    - [X] 必要なツールとソフトウェアをインストールしました
    - [X] サンプルリポジトリをフォークし、ローカルクローンを作成しました
    - [X] Azureでインフラストラクチャリソースをプロビジョニングしました
    - [X] React UIとPython APIをAzure Container Appsにデプロイしました
    - [X] ローカル開発環境を設定しました

プロビジョニングされたリソースグループを確認する際に参照できるAzureアプリケーションアーキテクチャのリマインダーです。

![ソリューションアーキテクチャ](../img/data-ingestion-validation-architecture-diagram.png)

このセクションでは、次のソリューション開発フェーズに進む前にセットアップを検証します。

---

## デプロイされたAzureリソースの確認

!!! tip "Azureポータルを使用すると、Azureにプロビジョニングされたリソースを表示し、正しく設定されているかを確認できます"

1. 新しいブラウザタブを開き、以下のリンクに移動します。ログインを求められる場合があります。

    ```bash title=""
    https://portal.azure.com/#browse/resourcegroups
    ```

2. "Microsoft Azureへようこそ"の画面が表示される場合があります。**キャンセル**を選択して画面を閉じるか、**はじめに**をクリックしてAzureポータルの紹介ツアーを受けることができます。

3. サブスクリプションのリソースグループページに直接移動します。リソースグループのリストで、`rg-postgresql-accelerator`という名前のものを見つけます（または、異なる名前を割り当てた場合はその名前を見つけます）。このリソースグループは、`azd up`リソースデプロイメントの一環として作成されました。AI対応ソリューションを構築およびデプロイするために必要なすべてのAzureリソースが含まれています。

    !!! tip "検索フィルターを使用して表示されるリソースグループの数を減らすことができます。"

4. リソースグループを選択します。

    !!! note "デプロイされたリソースのリストを確認します。"

        リソースグループの作成に加えて、`azd up`コマンドは以下の表に示すように、複数のリソースをそのリソースグループにデプロイしました。

```markdown
| Name                        | Type                             |
| --------------------------- | -------------------------------- |
| `appcs-<unique_string>`     | Application Configuration        |
| `appi-<unique_string>`      | Application Insights             |
| `ca-api-<unique_string>`    | Container App                    |
| `ca-portal-<unique_string>` | Container App                    |
| `cae-<unique_string>`       | Container Apps Environment       |
| `cr<unique_string>`         | Container registry               |
| `di-<unique_string>`        | Document Intelligence            |
| `kv-<unique_string>`        | Key Vault                        |
| `lang-<unique_string>`      | Language                         |
| `log-<unique_string>`       | Log Analytics workspace          |
| `mle-<unique_string>`       | Machine learning online endpoint |
| `mlw-<unique_string>`       | Azure Machine Learning workspace |
| `openai-<unique_string>`    | Azure OpenAI                     |
| `psql-data<unique_string>`  | Azure Database for PostgreSQL flexible server |
| `st<unique_string>`         | Storage Account                  |

上記のリソース名にある `<unique_string>` トークンは、リソースの命名時に Bicep スクリプトによって生成されるユニークな文字列を表しています。これにより、リソースがユニークに命名され、リソース命名の衝突を避けることができます。

上記のリソースに加えて、_Managed Identities_ のような、表にあるリソースをサポートするいくつかの他のリソースも表示されます。

## デプロイされたアプリが実行されていることを確認する

`azd up` コマンドには、Woodgrove Bank アプリケーションを **Azure Container Apps** (ACA) にデプロイする手順が含まれています。2つのコンテナが作成されました。1つは Woodgrove Bank ポータル UI 用で、もう1つはそれをサポートするバックエンド API 用です。

!!! info "Azure Container Apps (ACA) のデプロイ"

    ACA は、コンテナ化されたアプリケーションを簡単にデプロイおよび管理できる完全に管理されたサーバーレスプラットフォームです。デプロイを簡素化し、スケーラビリティとコスト効率を提供し、インフラストラクチャ管理を気にせずにアプリケーションの構築に集中することができます。

### Woodgrove API が実行されていることを確認する

1. Azure リソースグループに開かれたブラウザウィンドウで、名前が **ca-api** で始まる **コンテナアプリ** リソースを選択します。

    ![リソースグループ内のリソースのスクリーンショット。ca-api コンテナーアプリリソースが強調表示されています。](../img/azure-portal-rg-ca-api.png)

2. API コンテナーアプリの **概要** ページの **基本情報** セクションで、**アプリケーション URL** を選択し、デプロイされた Woodgrove Bank API を新しいブラウザタブで開きます。

    ![Azure ポータルの API コンテナーアプリページのスクリーンショット。アプリケーション URL が強調表示されています。](../img/azure-portal-api-container-app.png)

3. 画面に `Welcome to the Woodgrove Bank API!` というメッセージが表示されるはずです。これは、API アプリが正常にデプロイされたことを確認するものです。

### Woodgrove ポータル UI を開く

1. Azure ポータルで、リソースを含むリソースグループに戻り、名前が **ca-portal** で始まる **コンテナーアプリ** リソースを選択します。

    ![リソースグループ内のリソースのスクリーンショット。ca-portal コンテナーアプリリソースが強調表示されています。](../img/azure-portal-rg-ca-portal.png)

2. ポータルコンテナーアプリの **概要** ページの **基本情報** セクションで、**アプリケーション URL** を選択し、デプロイされた Woodgrove Bank ポータルを新しいブラウザタブで開きます。

    ![Azure ポータルの API コンテナーアプリページのスクリーンショット。アプリケーション URL が強調表示されています。](../img/azure-portal-portal-container-app.png)

3. Woodgrove Bank 契約管理ポータルで、**ベンダー** ページを選択し、ベンダーのリストが正しく読み込まれることを確認します。

    ![Woodgrove Bank 契約管理ポータルのベンダーページのスクリーンショット](../img/woodgrove-bank-portal-vendors.png)

## Azure AI Foundry で Azure OpenAI モデルのデプロイを表示する

!!! tip "Azure AI Foundry ポータルを使用すると、アプリの Azure AI リソースを表示および管理できます。"

Azure AI Foundry ポータルを使用して、`gpt-4o` および `text-embedding-ada-002` モデルが Azure OpenAI サービスにデプロイされたことを確認します。

1. Azure ポータルで、リソースを含むリソースグループに戻り、**Azure OpenAI** リソースを選択します。

    ![リソースグループ内のリソースのスクリーンショット。Azure OpenAI リソースが強調表示されています。](../img/azure-portal-rg-openai.png)

2. Azure OpenAI リソースの **概要** ページで、**Azure AI Foundry ポータルを探索** を選択します。

    ![Azure OpenAI サービスの概要ブレードのスクリーンショット。Explore Azure AI Foundry ポータルが赤い枠で強調表示されています。](../img/azure-portal-openai-overview.png)

3. **Azure AI Foundry** で、左側のナビゲーションメニューの **共有リソース** の下にある **デプロイメント** メニュー項目を選択します。

    ![Azure AI Foundry のスクリーンショット。デプロイメントメニュー項目が強調表示され、選択されています。完了と埋め込みモデルのデプロイメントが表示されています。](../img/azure-ai-foundry-deployments.png)

4. `gpt-4o` モデルの `completions` デプロイメントと `text-embedding-ada-002` モデルの `embeddings` デプロイメントが表示されていることを確認します。

## セマンティックランカーモデルのデプロイメントを確認する（オプション）

セットアップ中に Azure ML セマンティックランカーモデルをデプロイすることを選択した場合、Azure Machine Learning Studio を使用して、セマンティックランカーモデルがオンラインエンドポイントに正常にデプロイされたことを確認します。

!!! warning "このステップは、`azd up` デプロイメント中に `deployAMLModel` に `mini` または `bge` を選択した場合にのみ必要です。`none` を選択した場合は、このステップをスキップしてください。"

1. Azure ポータルで、リソースを含むリソースグループに戻り、**Azure Machine Learning ワークスペース** リソースを選択します。

    ![リソースグループ内のリソースのスクリーンショット。Azure Machine Learning ワークスペースリソースが強調表示されています。](../img/azure-portal-rg-aml-workspace.png)

2. Azure ML ワークスペースページから、**スタジオを起動** ボタンを選択して、新しいブラウザウィンドウで Azure Machine Learning Studio を開きます。

    ![Azure Machine Learning ワークスペースページのスタジオ起動セクションのスクリーンショット。スタジオ起動ボタンが赤い枠で強調表示されています。](../img/azure-ml-workspace-launch-studio.png)

3. プロンプトが表示されたら、Machine Learning Studio にサインインします。

4. Machine Learning Studio で、左側のリソースメニューの **アセット** の下にある **エンドポイント** を選択し、次にあなたのエンドポイント（`bge-v2-m3-reranker model` または `msmarco-minilm-deployment-6 model`）を選択します。

    ![Azure Machine Learning Studioのエンドポイントページのスクリーンショット。エンドポイントメニュー項目とリランカーモデルエンドポイントが強調表示されています。](../img/aml-studio-endpoints.png)

5. エンドポイントページで、(_bgev2m3-v1_ または _msmarco-minilm-deployment-6_) デプロイメントの **Provisioning state** が **Succeeded** であることを確認します。

    ![Azure ML Studioでのセマンティックランカーモデルデプロイメントのスクリーンショット。モデルのプロビジョニング状態がSucceededであることが強調表示されています。](../img/aml-studio-endpoints-model-deployment-succeeded.png)

!!! tip "Azure Portalを開いたままにしておいてください。後で再訪します。"
