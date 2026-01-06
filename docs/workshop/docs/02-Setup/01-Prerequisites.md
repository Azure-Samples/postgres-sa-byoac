# 2.1 Prerequisites

Review the details about what you need to do before starting the workshop, what you are expected to know beforehand, and what you can expect to take away after completing it.

## What You Need

To be able to complete this solution accelerator, you will need:

1. **Your Own Computer.**
    - Any computer capable of running Visual Studio Code, Docker Desktop, and a modern web browser will do.
    - You must have the ability to install software on the computer.
    - We recommend installing a recent version of Edge, Chrome, or Safari.
2. **A GitHub Account.**
    - This is required to create a copy (known as a fork) of the sample repository.
    - We recommend using a personal (vs. enterprise) GitHub account for convenience.
    - If you don't have a GitHub account, [sign up for a free one](https://github.com/signup) now. (It takes just a few minutes.)
3. **An Azure Subscription.**
    - This is needed to provision the Azure infrastructure for your AI project.
    - If you don't have an Azure account, [sign up for a free one](https://aka.ms/free) now. (It takes just a few minutes.)
4. **Sufficient Azure ML Online Endpoint CPU Quota.**
    - To run the solution accelerator's Semantic Re-ranker element,  you have two choices.
      - You can run small, but high quality model on a Standard DASv4 with 4 vCPUs.
      - You can alternatively run a much larger, and even more accurate model on a Standard DASv4 with 16 vCPUs.
      - Therefore, depending on the model you choose, you need to ensure you have either 4 or 16 cores available to you in your subscription. Detailed instructions are provided in the setup section to verify this in your subscription.
5. **An Appropriate Azure Region For Your Workshop Resources**
    - To ensure you can successfully complete the workshop and deploy the required Azure resources, you must choose a region that supports those resources.
    - Before selecting an Azure region:
      - Review the regional availability guidance for the [gpt-4o](https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=global-standard%2Cstandard-chat-completions#standard-models-by-endpoint) and [text-embedding-ada-002](https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=global-standard%2Cstandard-embeddings#standard-models-by-endpoint) models in Azure OpenAI.
        - Select a region that **supports the Azure OpenAI `gpt-4o` and `text-embedding-ada-002` models**.
        - Ensure you have **at least 25K TPMs of `Standard` capacity available in the region** for  `gpt-4o` and 10K TPMs of `text-embedding-ada-002` models. Follow [these instructions](https://learn.microsoft.com/azure/ai-services/openai/how-to/quota?tabs=rest#view-and-request-quota) to check your available quota.

    You must choose a region that supports **both Azure OpenAI models**, has at least 25K TPM of `Standard` capacity for  `gpt-4o` and 10k for `text-embedding-ada-002` model.

    !!! danger "Choosing a region that doesn't support both Azure OpenAI models will result in deployment failure when running `azd up`."

## What You Should Know

To get the most of this solution accelerator, you should have:

### Recommended Knowledge and Experience

1. **Familiarity with Visual Studio Code**
    - The default editor used in this workshop is Visual Studio Code. You will configure your VS Code development environment with the required extensions and code libraries.
    - The workshop requires Visual Studio Code and other tools to be installed on your computer. You will be running the solution code from your local computer.
2. **Familiarity with the Azure Portal**
    - The workshop assumes you are familiar with navigating to resources within the Azure portal.
    - You will use the Azure portal to retrieve endpoints, keys, and other values associated with the resources you deploy for this workshop.

### Preferred Knowledge and Experience

1. **Familiarity with `git` operations**
    - You will be forking the sample repository into your GitHub account.
    - You will be committing code changes to your forked repo.
2. **Familiarity with the `bash` shell**.
    - If needed, you will use `bash` in the VS Code terminal to run post-provisioning scripts.
    - You will also use it to run Azure CLI and Azure Developer CLI commands during setup.

## What You Will Take Away

After completing this workshop, you will have:

1. A personal fork (copy) of the [Build Your Own Advanced AI Copilot with PostgreSQL](http://aka.ms/pg-byoac-repo/) repository in your GitHub profile. This repo contains all the materials you need to reproduce the workshop later.

2. Hands-on understanding of the [Azure AI Foundry](https://ai.azure.com) portal and relevant developer tools (e.g., Azure Developer CLI, Prompty, FastAPI) to streamline end-to-end development workflows for your own AI apps.

3. An understanding of how Azure AI services can be integrated into applications to create powerful AI-enabled applications.
