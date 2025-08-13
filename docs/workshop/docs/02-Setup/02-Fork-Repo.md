# 2.2 Fork Repo

You must create a copy (known as a fork) of the [PostgreSQL Solution Accelerator: Build your own AI Copilot](https://aka.ms/pg-byoac-repo/) GitHub repo and then clone that onto your local computer so you can work with its contents. After completing this step, you should have:

- [X] Forked the **PostgreSQL Solution Accelerator: Build your own AI Copilot** repo to your personal GitHub profile
- [X] Created a local clone of the repo
- [X] Opened the cloned repo in Visual Studio Code

## Fork Repo To Your Profile

Forking in GitHub refers to creating a personal copy of a public repository, which allows you to freely experiment with changes without affecting the original project.

1. To fork the repo, open a new browser window or tab and navigate to <https://aka.ms/pg-byoac-repo/>.

2. Select the **Fork** button to create a copy of the repo in your GitHub profile.

    ![The Fork button is highlighted on the GitHub toolbar.](../img/git-hub-toolbar-fork.png)

3. Login with your GitHub profile, if prompted.

4. On the **Create a new fork** page, select **Create fork** to make a copy of the repo under your GitHub profile.

    ![Screenshot of the Create a new fork page in GitHub.](../img/github-create-fork.png)

5. The forked repo will open within your GitHub profile.

## Clone the Forked Repo

1. On the GitHub page for your fork, select the **Code** button and then select the **Copy URL to clipboard** button next to the repo's HTTPS clone link:

    ![The GitHub Code menu is expanded and the copy button for the HTTPS clone link is highlighted.](../img/github-code-clone-https.png)

2. Open a new command prompt and change directories to the folder in which you want to clone the repo (e.g., D:\repos).

3. Once in the desired directory, run the following `git clone` command to download a copy of your fork onto your local machine. Ensure you replace the `<url_of_your_forked_repo>` token with the clone link you copied in the previous step.

    ```bash title="" linenums="0"
    git clone <url_of_your_forked_repo>
    ```

4. Once the repository has been cloned, change directories at the command prompt to the folder of the cloned repo, then run the following command to open the project in Visual Studio Code:

    ```bash title="" linenums="0"
    code .
    ```

!!! tip "Leave Visual Studio Code open as you will be using it throughout the remainder of the workshop."
