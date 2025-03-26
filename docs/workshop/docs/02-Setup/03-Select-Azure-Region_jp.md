# 2.3 Azure リージョンを選択する

`azd up` コマンドを使用して Azure リソースを正常にデプロイするためには、必要な Azure OpenAI `gpt-4o` および `text-embedding-ada-002` モデルをサポートし、それぞれのモデルに対して少なくとも 10K TPM の `Standard` キャパシティが利用可能なリージョンを選択する必要があります。このステップを完了すると、以下が達成されているはずです：

- [X] ワークショップリソースのための Azure リージョンを選択した

## リージョンの可用性と Azure OpenAI のクォータを確認する

このワークショップを正常に完了するために必要なすべてのリソースと機能をサポートする Azure リージョンはほんの一握りしかありません。

!!! danger "適切なリージョンを選択しないと、デプロイが失敗します！"

以下の手順に従って、必要なサービス、モデル、および機能のリージョンの可用性を確認し、それに基づいてデプロイ用のリージョンを選択してください。

1. Azure OpenAI の [gpt-4o](https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=global-standard%2Cstandard-chat-completions#standard-models-by-endpoint) および [text-embedding-ada-002](https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=global-standard%2Cstandard-embeddings#standard-models-by-endpoint) モデルのリージョンの可用性ガイダンスを確認します。

2. **両方の `gpt-4o` および `text-embedding-ada-002` モデルに対して、リージョンに少なくとも 10K TPM の `Standard` キャパシティが利用可能であることを確認します。** 利用可能なクォータを確認するには、[これらの手順](https://learn.microsoft.com/azure/ai-services/openai/how-to/quota?tabs=rest#view-and-request-quota)に従ってください。

## ワークショップリソースをサポートする Azure リージョンを選択する

1. 上記のレビューから要件を満たすリージョンに基づいて、**両方の Azure OpenAI モデルをサポートし、** **十分な `Standard` TPM キャパシティを持つリージョンを選択します。**

!!! danger "両方の Azure OpenAI モデルをサポートするリージョンを選択してください！"

    - 両方の Azure OpenAI モデルをサポートしないリージョンを選択すると、`azd up` を実行した際にデプロイが失敗します。

    - `gpt-4o` および `text-embedding-ada-002` モデルの両方に対して少なくとも 10K TPM キャパシティを持たないリージョンを選択すると、`azd up` を実行した際にデプロイが失敗します。
