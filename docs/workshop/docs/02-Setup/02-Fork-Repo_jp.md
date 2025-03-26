# 2.2 リポジトリをフォークする

[PostgreSQL Solution Accelerator: Build your own AI Copilot](http://aka.ms/pg-byoac-repo/) GitHub リポジトリのコピー（フォークと呼ばれる）を作成し、それをローカルコンピュータにクローンして、その内容を操作できるようにします。このステップを完了すると、次のことができるようになります。

- [X] **PostgreSQL Solution Accelerator: Build your own AI Copilot** リポジトリを個人の GitHub プロフィールにフォークした
- [X] リポジトリのローカルクローンを作成した
- [X] Visual Studio Code でクローンしたリポジトリを開いた

## プロフィールにリポジトリをフォークする

GitHub でのフォークとは、公開リポジトリの個人用コピーを作成することを指し、元のプロジェクトに影響を与えることなく自由に変更を試すことができます。

1. リポジトリをフォークするには、新しいブラウザウィンドウまたはタブを開き、<http://aka.ms/pg-byoac-repo/> に移動します。

2. **Fork** ボタンを選択して、リポジトリのコピーを GitHub プロフィールに作成します。

    ![GitHub ツールバーでフォークボタンが強調表示されています。](../img/git-hub-toolbar-fork.png)

3. プロンプトが表示されたら、GitHub プロフィールでログインします。

4. **Create a new fork** ページで、**Create fork** を選択して、GitHub プロフィールにリポジトリのコピーを作成します。

    ![GitHub の Create a new fork ページのスクリーンショット。](../img/github-create-fork.png)

5. フォークされたリポジトリが GitHub プロフィール内で開きます。

## フォークしたリポジトリをクローンする

1. フォークしたリポジトリの GitHub ページで、**Code** ボタンを選択し、リポジトリの HTTPS クローンリンクの横にある **Copy URL to clipboard** ボタンを選択します。

    ![GitHub Code メニューが展開され、HTTPS クローンリンクのコピー ボタンが強調表示されています。](../img/github-code-clone-https.png)

2. 新しいコマンドプロンプトを開き、リポジトリをクローンしたいフォルダにディレクトリを変更します（例: D:\repos）。

3. 希望のディレクトリに移動したら、次の `git clone` コマンドを実行して、フォークのコピーをローカルマシンにダウンロードします。前のステップでコピーしたクローンリンクで `<url_of_your_forked_repo>` トークンを置き換えることを忘れないでください。

    ```bash title=""
    git clone <url_of_your_forked_repo>
    ```

4. リポジトリがクローンされたら、コマンドプロンプトでクローンしたリポジトリのフォルダにディレクトリを変更し、次のコマンドを実行して Visual Studio Code でプロジェクトを開きます。

```bash title=""
code .
```

!!! tip "Visual Studio Codeを開いたままにしておいてください。ワークショップの残りの部分で使用します。"
