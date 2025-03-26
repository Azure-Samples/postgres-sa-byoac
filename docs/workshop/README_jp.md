# PostgreSQL ソリューション アクセラレータ - PostgreSQL を使用して独自の高度な AI コパイロットを構築する: ハンズオン ワークショップ

[![Open in GitHub Codespaces](https://img.shields.io/static/v1?style=for-the-badge&label=GitHub+Codespaces&message=Open&color=brightgreen&logo=github)](https://github.com/codespaces/new?hide_repo_select=true&machine=basicLinux32gb&repo=725257907&ref=main&devcontainer_path=.devcontainer%2Fdevcontainer.json&geo=UsEast)
[![Open in Dev Containers](https://img.shields.io/static/v1?style=for-the-badge&label=Dev%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/azure-samples/contoso-chat)

---

## PostgreSQL ソリューション アクセラレータについて - PostgreSQL を使用して独自の高度な AI コパイロットを構築する

このリソースは、Azure Database for PostgreSQL と Azure AI Services を使用して AI 搭載ソリューションを作成したい開発者向けのソリューション アクセラレータであり、学習ツールでもあります。**Woodgrove Bank** ソリューションは、Azure AI プラットフォーム上で AI 対応アプリケーションと RAG ベースのコパイロットの開発における最新の機能とベスト プラクティスを反映する、積極的に更新されるプロジェクトです。

**サンプルの現在のバージョンは、この高レベルのアーキテクチャに従っています**。

![ソリューションの高レベル アーキテクチャ図](./docs/img/solution-architecture-diagram.png)

## ワークショップ ガイド

現在のリポジトリには、リソースのプロビジョニングからアイデアの創出、評価、展開、使用までのワークフロー全体をカバーする、開発者向けのステップバイステップのラボ ガイドを含む `docs/workshop/` フォルダーが用意されています。

[ワークショップ ガイドのホスト版](https://aka.ms/pg-byoac-docs) を GitHub Pages で参照して、すばやく確認できます。また、このソースから直接ワークショップを**プレビューおよび拡張**することもできます。ローカルで [MKDocs](https://www.mkdocs.org/) ページを実行することで可能です:

1. `mkdocs-material` パッケージをインストールします

    ```bash
    pip install mkdocs-material
    ```

2. `workshop` フォルダーから `mkdocs serve` コマンドを実行します


    ```bash
    cd docs/workshop
    mkdocs serve -a localhost:5000
    ```

これにより、指定されたローカルアドレスでワークショップガイドのプレビューを含む開発サーバーが実行されます。ブラウザを開いて、`http://localhost:5000` に移動するだけでコンテンツを表示できます。

（オプション）ワークショップガイドをライブサイトにデプロイしたい場合は、`mkdocs gh-deploy` コマンドを使用して、コンテンツをGitHub Pagesサイトにプッシュできます。
