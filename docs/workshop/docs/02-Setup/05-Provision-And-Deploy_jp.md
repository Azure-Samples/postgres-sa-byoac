# 2.5 プロビジョニングとデプロイ

このラボを完了するには、有効な Azure サブスクリプション、GitHub アカウント、および関連する Azure OpenAI モデルへのアクセスが必要です。詳細が必要な場合は、[前提条件](./00-Prerequisites.md)セクションを確認してください。

## Docker Desktop を起動する

Docker Desktop は、_Woodgrove Bank Portal and API_ アプリケーションを実行するためのコンテナを作成およびデプロイするために使用されます。`azd up` を使用してデプロイメントプロセスを開始する前に、実行している必要があります。

1. コンピュータのアプリケーションメニューから Docker Desktop を起動します。

2. システムトレイまたはメニューバーに Docker アイコンが表示されていることを確認して、実行中であることを確認します。

## Azure に認証する

`azd up` コマンドを実行する前に、VS Code 環境を Azure に認証する必要があります。

1. Azure リソースを作成するには、VS Code から認証されている必要があります。VS Code で新しい統合ターミナルを開き、次の手順を完了します。

### プロビジョニング後のタスクのために `az` で認証する

1. 以下のコマンドを使用して Azure CLI `az` にログインします。

    ```bash  title=""
    az login
    ```

2. 開いたブラウザウィンドウでログインプロセスを完了します。

    !!! info "複数の Azure サブスクリプションを持っている場合は、`az account set -s <subscription-id>` を実行して使用する正しいサブスクリプションを指定する必要があるかもしれません。"

### リソースのプロビジョニングと管理のために `azd` で認証する

1. Azure Developer CLI にログインします。これはインストールごとに一度だけ必要です。

    ```bash title=""
    azd auth login
    ```

## Azure リソースのプロビジョニングとアプリのデプロイ (UI と API)

これで、Azure リソースをプロビジョニングし、Woodgrove Bank ソリューションをデプロイする準備が整いました。

1. `azd up` を使用して Azure インフラストラクチャをプロビジョニングし、Web アプリケーションを Azure にデプロイします。

    ```bash title=""
    azd up
    ```

    !!! info "`azd up` コマンドのためにいくつかの入力を求められます:"

        - **Enter a new environment name**: `dev` などの値を入力します。
        - `azd up` コマンドの環境は、構成ファイル、環境変数、およびリソースが正しくプロビジョニングおよびデプロイされることを保証します。
        - `azd` 環境を削除する必要がある場合は、VS Code エクスプローラーのプロジェクトのルートにある `.azure` フォルダーを見つけて削除します。
        - **Select an Azure location to use**: 上下の矢印キーを使用して、このワークショップで使用する Azure サブスクリプションを選択します。
        - **Select an Azure location to use**: 上下の矢印キーを使用して、リソースをデプロイする Azure リージョンを選択します。
        - **Enter a value for the `deployAMLModel` infrastructure parameter**: 上下の矢印キーを使用して次のいずれかの値を選択します:
            - `mini` は "MiniLM-L6-v2" クロスエンコーダーモデルをデプロイします（小型、最速、高精度、4 vCPU Azure ML ホストをデプロイ）
            - `bge` は "BGE-Reranker-v2-M3" クロスエンコーダーモデルをデプロイします（大型、速い、最高精度、16 vCPU Azure ML ホストをデプロイ）
            - `none` はクロスエンコーダーをデプロイせず、セマンティックリランカー機能をスキップします。
        - `False` を選択した場合、このアクセラレータのオプションの **セマンティックランカー** セクションをスキップする必要があります。
        - **Enter a value for the `resourceGroupName` infrastructure parameter**: `rg-postgresql-accelerator` または類似の名前を入力します。


2. プロセスが完了するのを待ちます。`deployAMLModel` 設定で選択したオプションに応じて、デプロイにかかる時間は異なります。
    - `mini` を選択した場合、すべてをデプロイするのに約27分かかることがあります。
    - `bge` を選択した場合、すべてをデプロイするのに約47分かかることがあります。
    - `none` を選択した場合、すべてをデプロイするのに約14分かかることがあります。

    !!! info "なぜ MiniLM-L6-v2 または BGE-Reranker-v2-M3 を選ぶのか？"

        MiniLM-L-6-v2 と BGE-Reranker-v2-M3 の間で選択する際、主な違いは精度とレイテンシーのトレードオフにあります。

        - MiniLM-L-6-v2 は軽量なクロスエンコーダーリランカーで、基本的なベクトル検索に対して堅実な精度向上を提供し、レイテンシーと計算要件が比較的低いです。パフォーマンスやコストに大きな影響を与えずにランキングの忠実度を向上させたいシナリオに最適です。このモデルは、ほとんどの実用的なアプリケーションにおいて優れたバランスを保ち、リソースが限られた環境でもうまくスケールします。

        - 一方、BGE-Reranker-v2-M3 はより大きく強力なクロスエンコーダーで、最先端のランキング品質を提供し、MRR や nDCG スコアが顕著に高いです。最大の関連性とセマンティックな忠実度が重要な法務、研究、企業の知識システム、またはカスタマーサポートアシスタントなどの高精度検索パイプラインで優れています。追加のレイテンシーが許容される場合に最適です。

        実際には、MiniLM-L6-v2 をデフォルトのリランカーとして使用し、精度がレイテンシーを上回るプレミアムまたは専門的なワークロードに対して BGE-Reranker-v2-M3 に切り替えることができます。

        ### 比較表: ベクトル検索 vs. MiniLM-L6-v2 vs. BGE-Reranker-v2-M3
        | メトリック / 特徴    | 標準ベクトル検索 (例: BGE Base, OpenAI Embedding) | MiniLM-L-6-v2 リランカー     | BGE-Reranker-v2-M3          |
        |--------------------|------------------------------------------------|----------------------------|-----------------------------|
        | **入力モード**      | 別々の埋め込み (クエリ + ドキュメント)               | ジョイントクエリ + ドキュメント | ジョイントクエリ + ドキュメント |
        | **レイテンシー**    | 低 (サブミリ秒からミリ秒)                           | 中 (10–30ms 典型的)         | 高 (50–100ms+)              |
        | **計算要件**       | 最小限 (ドット積またはコサイン類似度)                 | 低 (小さなモデル)             | 中程度 (大きなモデル)          |
        | **MRR@10**        | ~0.32–0.36                                      | ~0.38–0.39                 | ~0.42–0.44                  |
        | **nDCG@10**       | ~0.45–0.50                                      | ~0.52–0.54                 | ~0.57–0.60                  |
        | **ランキング品質**  | 普通 — 粗いセマンティック関連性                      | より良い — 多少のニュアンス    | 優れた — 高い忠実度            |
        | **最適な使用ケース** | 高速な初回取得                                    | 軽量なリランキング            | 高精度なリランキング            |

    !!! failure "Not enough subscription CPU quota"

        `azd up` コマンドを実行する前にAzure MLのCPUクォータを確認していない場合、次のようなCPUクォータエラーメッセージが表示されることがあります：

        _(OutOfQuota) サブスクリプションのCPUクォータが不足しています。要求されたCPUクォータの量は (4 または 16) で、最大クォータの量は [N/A] です。トラブルシューティングガイドは、こちらでご覧いただけます: https://aka.ms/oe-tsg#error-outofquota_

        ワークショップを続行することはできますが、デプロイされたモデルが利用できないため、オプションの **Semantic Ranking** セクションをスキップする必要があります。

    !!! failure "Deployment failed: Postgresql server is not in an accessible state"

        Azure BicepデプロイメントがPostgreSQLサーバーをプロビジョニングした後にPostgreSQL管理ユーザーを追加しようとすると、`サーバーがアクセス可能な状態ではありません` というエラーが発生する可能性があります。これは、PostgreSQLサーバーがAzureバックエンドでまだプロビジョニング中であるにもかかわらず、デプロイメントがすでに成功したと返された場合に発生することがあります。このエラーが発生した場合は、単に `azd up` コマンドを再実行してください。

        ```
        ERROR: error executing step command 'provision': deployment failed: error deploying infrastructure: deploying to subscription:

        Deployment Error Details:
        AadAuthOperationCannotBePerformedWhenServerIsNotAccessible: The server 'psql-datacvdjta5pfnc5e' is not in an accessible state to perform Azure AD Principal operation. Please make sure the server is accessible before executing Azure AD Principal operations.
        ```

3. 正常に完了すると、コンソールに `SUCCESS: ...` メッセージが表示されます。
