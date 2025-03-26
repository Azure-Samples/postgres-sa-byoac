# はじめに

このソリューションアクセラレーターは、金融サービス業界向けのAI対応アプリケーションのエンドツーエンドの例として設計されています。AI駆動のデータ検証、ベクター検索、セマンティックランキング、Azure Database for PostgreSQL上のGraphRAGを用いて既存のアプリケーションを強化するための生成AI機能の実装を示し、インテリジェントなコパイロットを通じて金融に関する質問に高品質な回答を提供する方法を示します。このアプリは、作業範囲記述書（SOW）と請求書で構成された小さなサンプルデータセットを使用しています。アクセラレーターのソースコードは以下のリポジトリに提供されています: <http://aka.ms/pg-byoac-repo/>.

アプリケーションのアーキテクチャは以下の通りです:

![ソリューションの高レベルアーキテクチャ図](../img/solution-architecture-diagram.png)

## 独自データをソリューションに持ち込む

このソリューションアクセラレーターは、デモンストレーション目的で提供されたサンプルのベンダー、SOW、および請求書データを使用するように構成されています。しかし、独自のデータを使用したり、既存のソリューションを拡張したりする場合は、特定のステップを変更する必要があります。適用可能な場合、カスタムデータセットを統合するために調整が必要な主要な領域を示すノートが提供されています。

## 学習目標

このソリューションアクセラレーターの目標は、Azure Database for PostgreSQLとAzure AI Servicesを使用して既存のアプリケーションに**豊富なAI機能を追加する**方法を教えることです。データの取り込み中に高度なAI検証を統合し、請求書などの金融文書が関連する作業範囲記述書と一致することを保証する実践的な経験を得ることができます。Azure OpenAIを活用して堅牢なデータ検証を行い、Azure Document Intelligenceを使用して包括的な抽出と分析を行うことで、データ品質を向上させます。コパイロットチャット機能を追加することで、ユーザーがベンダーの請求精度、タイムリーさ、品質について深い洞察を得ることができるようになります。この包括的なアプローチにより、金融サービス業界でのパフォーマンスと信頼性を向上させるAI強化機能を既存のアプリケーションにシームレスに追加するスキルを身につけることができます。

ソリューションアクセラレーターを完了することで、以下を学ぶことができます：

- Azure AI サービスを使用して、ワークフローを合理化するためにデータ検証タスクを自動化します。
- [Azure AI 拡張機能](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-integrate-azure-ai)を使用して、Azure Database for PostgreSQL ベースのアプリケーションに生成 AI 機能を統合します。
- コパイロットで[検索強化生成 (RAG) パターン](https://learn.microsoft.com/azure/ai-studio/concepts/retrieval-augmented-generation)を使用します <br/>（独自のデータに基づいて応答を行うため）。
- [Azure Container Apps](https://aka.ms/azcontainerapps) を使用してデプロイします <br/>（実際の使用のためにホストされた UI および API アプリを取得するため）。
- [Azure Developer CLI](https://aka.ms/azd) を AI アプリケーションテンプレートと共に使用します <br/>（チーム全体でアプリを一貫してプロビジョニングおよびデプロイするため）

## 学習リソース

1. **Azure Database for PostgreSQL - Flexible Server** | [概要](https://learn.microsoft.com/azure/postgresql/flexible-server/service-overview)
2. **Azure Database for PostgreSQL - Flexible Server における生成 AI** | [概要](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-overview)
3. **PostgreSQL 用 Azure AI 拡張機能** | [Azure AI の統合方法](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-azure-overview)
4. **Azure AI Foundry**  | [ドキュメント](https://learn.microsoft.com/azure/ai-studio/) · [アーキテクチャ](https://learn.microsoft.com/azure/ai-studio/concepts/architecture) · [SDK](https://learn.microsoft.com/azure/ai-studio/how-to/develop/sdk-overview) ·  [評価](https://learn.microsoft.com/azure/ai-studio/how-to/evaluate-generative-ai-app)
5. **Azure Container Apps**  | [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/) · [コードからデプロイ](https://learn.microsoft.com/azure/container-apps/quickstart-repo-to-cloud?tabs=bash%2Ccsharp&pivots=with-dockerfile)
6. **責任ある AI**  | [概要](https://www.microsoft.com/ai/responsible-ai) · [AI サービスと共に](https://learn.microsoft.com/azure/ai-services/responsible-use-of-ai-overview?context=%2Fazure%2Fai-studio%2Fcontext%2Fcontext) · [Azure AI コンテンツの安全性](https://learn.microsoft.com/azure/ai-services/content-safety/)
