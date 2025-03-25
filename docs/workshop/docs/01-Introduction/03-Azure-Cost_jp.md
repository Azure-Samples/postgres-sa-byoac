# 1.3 Azure コスト見積もり

Microsoft Azure リソースは、あなたの Azure サブスクリプション内でプロビジョニングされます。これらのサービスのコストはあなたの責任となります。ソリューションのコストは、選択した Azure リージョンやデプロイメントオプションによって異なります。

特に、デプロイメント時に指定する `deployAMLModel` オプションが全体のコストに影響を与えます:

- 次のいずれかの設定で Semantic Ranker 用の Azure Machine Learning モデルをデプロイすることにより:
    - `mini`（ms-marco-MiniLM-L-6-v2 モデルをデプロイ）、ソリューションのコストは約 $5.50/日。
    - `bge`（bge-reranker-v2-m3 モデルをデプロイ）、ソリューションのコストは約 $17.40/日。
    - `none`（セマンティック再ランキングをデプロイしない）、ソリューションのコストは約 $1.10/日。

このガイドのセットアップセクションでは、このデプロイメントオプションの選び方を説明します。

このソリューションのためにデプロイされた Azure リソースの _推定コスト_ の内訳は次のとおりです:

- Azure ML VM（セマンティック再ランキングクロスエンコーダーモデルのデプロイメント）:
    - ms-marco-MiniLM-L-6-v2（mini）モデルを STANDARD_D4AS_V4 で実行: 約 $4.40/日
    - bge-reranker-v2-m3（bge）モデルを STANDARD_D16AS_V4 で実行: 約 $16.30/日
- Azure Database for PostgreSQL: 約 $0.90/日
- Azure App Configuration: 約 $0.02/日
- Azure Container Registry: 約 $0.17/日
- Azure OpenAI Service: Copilot、AI 検証、およびソリューションで処理されるドキュメント数に依存。
- その他のサービスは最小限のコスト。

推定月額コストをまとめると:

- D-Class 4 vCPU での月額コスト（mini モデル使用）: 約 $170.20
- D-Class 16 vCPU での月額コスト（bge モデル使用）: 約 $539.10
- セマンティック再ランキングなしでの月額コスト: 約 $33.80

!!! warning "上記のコストはあくまで推定です。"

    ここで提供されているコストは、提供された構成を使用してソリューションアクセラレータを実行することに基づく推定値であり、ソリューションアクセラレータを実行する際のコストに関する一般的なガイダンスを提供することを目的としています。デプロイメントオプション、リージョンの選択、データサイズによって、個々のコストは異なります。

It seems like your message was empty. Please paste the Markdown content you want translated, and I'll assist you with the translation.
