# 2.5 Provision and Deploy

You will need a valid Azure subscription, a GitHub account, and access to relevant Azure OpenAI models to complete this lab. Review the [prerequisites](./00-Prerequisites.md) section if you need more details.

## Start Docker Desktop

Docker Desktop is used to create and deploy the containers used for runnig the _Woodgrove Bank Portal and API_ applications. It must be running before you begin the deployment process using `azd up`.

1. Launch Docker Desktop from the applications menu on your computer.

2. Look for the Docker icon in your system tray or menu bar to confirm it is running.

## Authenticate With Azure

Before running the `azd up` command, you must authenticate your VS Code environment to Azure.

1. To create Azure resources, you need to be authenticated from VS Code. Open a new integrated terminal in VS Code. Then, complete the following steps:

### Authenticate with `az` for post-provisioning tasks

1. Log into the Azure CLI `az` using the command below.

    ```bash  title=""
    az login
    ```

2. Complete the login process in the browser window that opens.

    !!! info "If you have more than one Azure subscription, you may need to run `az account set -s <subscription-id>` to specify the correct subscription to use."

### Authenticate with `azd` for provisioning & managing resources

1. Log in to Azure Developer CLI. This is only required once per-install.

    ```bash title=""
    azd auth login
    ```

## Provision Azure Resource and Deploy App (UI and API)

You are now ready to provision your Azure resources and deploy the Woodgrove Bank solution.

1. Use `azd up` to provision your Azure infrastructure and deploy the web application to Azure.

    ```bash title=""
    azd up
    ```

    !!! info "You will be prompted for several inputs for the `azd up` command:"

        - **Enter a new environment name**: Enter a value, such as `dev`.
        - The environment for the `azd up` command ensures configuration files, environment variables, and resources are provisioned and deployed correctly.
        - Should you need to delete the `azd` environment, locate and delete the `.azure` folder at the root of the project in the VS Code Explorer.
        - **Select an Azure Subscription to use**: Select the Azure subscription you are using for this workshop using the up and down arrow keys.
        - **Select an Azure location to use**: Select the Azure region into which resources should be deployed using the up and down arrow keys.
        - **Enter a value for the `deployAMLModel`**: Select one of the following values using the up and down arrow keys:
            - `mini` to deploy the "MiniLM-L6-v2" Cross Encoder model (smaller, fastest, high accuracy, deploys a 4 vCPU Azure ML host)
            - `bge` to deploy the "BGE-Reranker-v2-M3" Cross Encoder  model (larger, fast, highest accuracy, deploys a 16 vCPU Azure ML host)
            - `none` to not deploy any Cross Encoder and skip the Semantic Re-ranker feature.
        - If you select `False`, you will need to skip the optional **Semantic Ranker** section of this accelerator.
        - **Enter a value for the `resourceGroupName`**: Enter `rg-postgresql-accelerator`, or a similar name.

2. Wait for the process to complete. Depending on the option you selected for the `deployAMLModel` setting, the deployment will take different amounts of time:
    - If you chose `mini` then it may take roughly 27 minutes to deploy everything.
    - If you chose `bge` then it may take roughly 47 minutes to deploy everything.
    - If you chose `none` then it may take roughly 14 minutes to deploy everything.

    !!! info "Why choose MiniLM-L6-v2 or BGE-Reranker-v2-M3?"

        When deciding between MiniLM-L-6-v2 and BGE-Reranker-v2-M3, the key differences come down to accuracy vs. latency trade-offs.

        - MiniLM-L-6-v2 is a lightweight cross-encoder reranker that offers a solid accuracy boost over basic vector search with relatively low latency and compute requirements. It's ideal for scenarios where you want better ranking fidelity without significantly impacting performance or cost. This model strikes a great balance for most practical applications and scales well even in resource-constrained environments.

        - BGE-Reranker-v2-M3, on the other hand, is a larger, more powerful cross-encoder that delivers state-of-the-art ranking quality, with noticeably higher MRR and nDCG scores. It excels in high-precision search pipelines where maximum relevance and semantic fidelity are critical — such as legal, research, enterprise knowledge systems, or customer support assistants — and some additional latency is acceptable.

        In practice, you might use MiniLM-L6-v2 as a default reranker and switch to BGE-Reranker-v2-M3 for premium or specialized workloads where precision outweighs latency.

        ### Comparison Table: Vector Search vs. MiniLM-L6-v2 vs. BGE-Reranker-v2-M3
        | Metric / Feature            | Standard Vector Search (e.g., BGE Base, OpenAI Embedding) | MiniLM-L-6-v2 Reranker | BGE-Reranker-v2-M3 |
        |-----------------------------|-----------------------------------------------------------|------------------------|--------------------|
        | **Input Mode**              | Separate embeddings (query + doc)                         | Joint query + doc      | Joint query + doc   |
        | **Latency**                 | Low (sub-ms to ms)                                        | Medium (10–30ms typical)| Higher (50–100ms+)  |
        | **Compute Requirements**    | Minimal (dot product or cosine sim)                       | Low (small model)      | Moderate (larger model) |
        | **MRR@10**                  | ~0.32–0.36                                                | ~0.38–0.39             | ~0.42–0.44          |
        | **nDCG@10**                 | ~0.45–0.50                                                | ~0.52–0.54             | ~0.57–0.60          |
        | **Ranking Quality**         | Fair — coarse semantic relevance                          | Better — some nuance   | Excellent — high fidelity |
        | **Best Use Case**           | Fast first-pass retrieval                                 | Lightweight reranking  | High-precision reranking |

    !!! failure "Not enough subscription CPU quota"

        If you did not check your Azure ML CPU quota prior to starting running the `azd up` command, you may receive a CPU quota error message similar to the following:

        _(OutOfQuota) Not enough subscription CPU quota. The amount of CPU quota requested is (4 or 16) and your maximum amount of quota is [N/A]. Please see troubleshooting guide, available here: https://aka.ms/oe-tsg#error-outofquota_

        You can still continue with the workshop, but will need to skip the optional **Semantic Ranking** section, as you will not have the deployed model available.

    !!! failure "Deployment failed: Postgresql server is not in an accessible state"

        It's possible a `server is not in an accessible state` error may occur when the Azure Bicep deployment attempts to add the PostgreSQL Admin User after the PostgreSQL Server has been provisioned. This can occur if the PostgreSQL server is still being provisioned in the Azure backend, but the Deployment returned that it's successful already. If you encounter this error, simply re-run the `azd up` command.

        ```
        ERROR: error executing step command 'provision': deployment failed: error deploying infrastructure: deploying to subscription:

        Deployment Error Details:
        AadAuthOperationCannotBePerformedWhenServerIsNotAccessible: The server 'psql-datacvdjta5pfnc5e' is not in an accessible state to perform Azure AD Principal operation. Please make sure the server is accessible before executing Azure AD Principal operations.
        ```

3. On successful completion you will see a `SUCCESS: ...` message on the console.
