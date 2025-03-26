# SOWインボイスジェネレーター

このプロジェクトは、標準化された設定ファイルに基づいて作業範囲記述書（SOW）と関連するインボイスの生成を自動化することを目的としています。生成されたドキュメントはPDF形式で、プロジェクト管理と請求に必要なすべての詳細が含まれています。

## プロジェクト構造

```plaintext
sow_invoice_generator
├── src
│   ├── generate_sow.py        # Script to generate the SOW PDF
│   ├── generate_invoices.py    # Script to generate invoices for each milestone
│   └── config
│       ├── sow_inv.config      # Configuration file with project details
│       └── bad_inv.config  # Configuration file for generating bad invoices
│       └── bad_sow.config  # Configuration file for generating bad SOWs
├── requirements.txt            # List of dependencies for the project
└── README.md                   # Documentation for the project
```

## インストール

プロジェクトをセットアップするには、以下の手順に従ってください：

1. 必要な依存関係をインストールします：

``` bash
pip install -r requirements.txt
```

## 使用法

### 作業範囲記述書（SOW）の生成

SOW PDFを生成するには、以下のコマンドを実行します：

``` bash
cd /data/data_generator
python src/generate_sow.py "Contoso Ltd."
```

これにより、`Contoso Ltd.` ベンダーの `sow_inv.config` ファイルに指定されたプロジェクトの詳細、目的、タスク、スケジュール、コンプライアンス、および成果物を含むPDFドキュメントが作成されます。

ベンダーを指定せずにコマンドを実行すると、すべてのベンダーのSOWが生成されます。

``` bash
python src/generate_sow.py
```

### インボイスの生成

SOWで定義された各マイルストーンのインボイスを生成するには、（`/data/data_generator` ディレクトリ内で）以下を実行します：

```bash
python src/generate_invoices.py "Contoso Ltd."
```

これにより、そのベンダーのSOWで指定されたマイルストーンと成果物にリンクされた個別のPDFインボイスが作成されます。

ベンダーを指定せずにコマンドを実行すると、すべてのベンダーのインボイスが生成されます。

``` bash
python src/generate_invoices.py
```

## 設定ファイル

`sow_inv.config` ファイルには、プロジェクトに必要なすべての標準化された値が含まれています。これには以下が含まれます：

- ベンダーの詳細
- プロジェクトの範囲と目的
- タスクとスケジュール
- 支払い条件とコンプライアンス要件
- 各マイルストーンに関連する成果物

設定ファイルが正しくフォーマットされていることを確認し、SOWおよびインボイス生成スクリプトとのシームレスな統合を促進してください。

`bad_sow.config` および `bad_inv.config` ファイルには、データベースへのシードプロセスの一部としてデプロイされていないベンダーの誤ったデータが含まれています。データベースにシードされていないベンダーは以下の通りです：


1. Contoso Ltd.
1. Lucerne Publishing
1. VanArsdel Ltd.
1. Trey Research
1. Fabrikam Inc.
1. The Phone Company

## 不良SOWの生成

bad_sow.config構成ファイルを使用して`Fabrikam Inc`ベンダーの不良SOWを生成するには、（`/data/data_generator`ディレクトリ内で）次を実行します：

```bash
python src/generate_sow.py "Fabrikam Inc" bad_sow.config
```

## 不良請求書の生成

bad_inv.config構成ファイルを使用して`Fabrikam Inc`ベンダーの不良請求書を生成するには、（`/data/data_generator`ディレクトリ内で）次を実行します：

```bash
python src/generate_invoices.py "Fabrikam Inc" bad_inv.config
```

## 出力

生成されたSOWと請求書は

```plaintext
../data/sample_docs
```

ディレクトリに保存されます。任意のPDFビューアで開くことができます。
