# リソースのクリーンアップ

## GitHubで⭐️をください

!!! question "このワークショップとサンプルが役に立ちましたか？最新情報をお見逃しなく。"

**[Postgresで自分の高度なAIコパイロットを構築する](http://aka.ms/pg-byoac-repo/)** サンプルは、Azure AIプラットフォーム上でRAGベースのコパイロットをコードファーストで開発するための最新の機能とベストプラクティスを反映する、積極的に更新されているプロジェクトです。**[リポジトリを訪問する](http://aka.ms/pg-byoac-repo/)** または下のボタンをクリックして、私たちに⭐️をください。

<!-- ボタンを表示したい場所にこのタグを配置します。 -->
<a class="github-button" href="http://aka.ms/pg-byoac-repo/" data-color-scheme="no-preference: light; light: light; dark: dark;" data-size="large" data-show-count="true" aria-label="GitHubでaka.ms/pg-byoac-repoにスターを付ける"> PostgreSQLソリューションアクセラレータにスターを付ける！</a>

## フィードバックを提供する

このラボを他の人にとってより良くするためのフィードバックがありますか？[問題を開く](http://aka.ms/pg-byoac-repo/)してお知らせください。

## クリーンアップ

このワークショップを完了したら、作成したAzureリソースを削除してください。使用量ではなく、設定された容量に対して課金されます。このソリューションアクセラレータのために作成したリソースグループとすべてのリソースを削除する手順に従ってください。

1. VS Codeで、新しい統合ターミナルプロンプトを開きます。

2. ターミナルプロンプトで、デプロイメントスクリプトによって作成されたリソースを削除するために次のコマンドを実行します：

    !!! danger "リソースを削除するために次のAzure Developer CLIコマンドを実行してください！"

    ```bash title=""
    azd down --purge
    ```

    !!! tip "`--purge`フラグは、Azure KeyVaultやAzure OpenAIを含む、Azureでソフトデリート機能を提供するリソースを完全に削除するために必要です。"

3. ターミナルウィンドウで、削除されるリソースのリストが表示され、続行するかどうかのプロンプトが表示されます。プロンプトで「y」と入力して、リソースの削除を開始します。

## GitHubに変更を永続化する

ファイルに加えた変更を保存したい場合は、VS Codeのソースコントロールツールを使用して、GitHubリポジトリのフォークに変更をコミットしてプッシュしてください。

It seems like your message is empty. Please paste the Markdown content you want translated, and I'll assist you with the translation.
