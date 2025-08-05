# 2.7 Setup Dev Environment

In this step, you will configure your Python development environment in Visual Studio Code. At the end of this step, you should have:

- [X] Created a Python virtual environment
- [X] Installed the required Python libraries from `requirements.txt`
- [X] Create and populated a `.env` file in the **Woodgrove API** project.
- [X] Connected to your database using the PostgreSQL extension in VS Code.

## Create a Python virtual environment

Virtual environments in Python are essential for maintaining a clean and organized development space, allowing individual projects to have their own set of dependencies, isolated from others. This prevents conflicts between different projects and ensures consistency in your development workflow. By using virtual environments, you can manage package versions easily, avoid dependency clashes, and keep your projects running smoothly. It's a best practice that keeps your coding environment stable and dependable, making your development process more efficient and less prone to issues.

1. Return to Visual Studio Code, where you have the **PostgreSQL Solution Accelerator: Build your own AI Copilot** project open.

2. In Visual Studio Code, open a new terminal window and change directories to the `src/api` folder of the repo, and create a virtual environment named `.venv` by running the following command at the terminal prompt:

    ```bash title=""
    cd src/api
    python -m venv .venv 
    ```

    The above command will create a `.venv` folder under the `api` folder, which will provide a dedicated Python environment for the `api` project that can be used throughout this lab.

3. Activate the virtual environment.

    !!! note "Select the appropriate command for your OS and shell from the table."

        | Platform | Shell | Command to activate virtual environment |
        | -------- | ----- | --------------------------------------- |
        | POSIX | bash/zsh | `source .venv/bin/activate` |
        | | fish | `source .venv/bin/activate.fish` |
        | | csh/tcsh | `source .venv/bin/activate.csh` |
        | | pwsh | `.venv/bin/Activate.ps1` |
        | Windows | cmd.exe | `.venv\Scripts\activate.bat` |
        | | PowerShell | `.venv\Scripts\Activate.ps1` |
        | macOS | bash/zsh | `source .venv/bin/activate` |

4. Execute the command at the terminal prompt to activate your virtual environment.

## Install required Python libraries

The `requirements.txt` file in the `src\api` folder contains the set of Python libraries needed to run the Python components of the solution accelerator.

!!! tip "Review required libraries"

    Open the `src\api\requirements.txt` file in the repo to review the required libraries and the versions that are being used.

1. From the integrated terminal window in VS Code, run the following command to install the required libraries in your virtual environment:

    ```bash title=""
    pip install -r requirements.txt
    ```

## Create `.env` file

Configuration values, such as connection string and endpoints, that allow your application to interact with Azure services are hosted in an Azure App Configuration service. To enable your application to retrieve these values, you must provide it with the endpoint of that service. You will use a `.env` file to host the endpoint as an environment variable, which will allow you to run the Woodgrove API locally. The `.env` file will be created within the `src\api\app` folder of the project.

1. In VS Code, navigate to the `src\api\app` folder in the **Explorer** panel.

2. Right-click the `app` folder and select **New file...** from the context menu.

3. Enter `.env` as the name of the new file within the VS Code **Explorer** panel.

4. In the `.env` file, add the following as the first line, replacing the `{YOUR_APP_CONFIG_ENDPOINT}` with the endpoint for the App Configuration resource in your deployed resource group.

    ```ini title=""
    AZURE_APP_CONFIG_ENDPOINT={YOUR_APP_CONFIG_ENDPOINT}
    ```

    !!! note "Retrieve the endpoint for your App Configuration resource"

        To get the endpoint for your App Configuration resource:

        1. Navigate to your App Configuration resource in the [Azure portal](https://portal.azure.com/).
        
        2. Select **Access settings** from the resource navigation menu, under **Settings**.
        
        3. Copy the **Endpoint** value and paste it into the `.env` file.

            ![Screenshot of the App Configuration Access Settings page, with the Endpoint copy button highlighted.](../img/app-config-access-settings-endpoint.png)

5. Save the `.env` file.

## Connected to your database using the PostgreSQL extension in VS Code

TODO: Change these steps to be how to connect from VS Code. Include screen shots...

You will use the PostgreSQL extension in VS Code to configure various features in the database and execute queries to test those features. The `azd up` deployment script added your Microsoft Entra ID user as the owner of the database, so you will authenticate with Entra ID. Please follow the steps below to connect to your Azure Database for PostgreSQL - Flexible Server using the PostgreSQL extension in VS Code:

1. Navigate to your Azure Database for PostgreSQL - Flexible Server resource in the [Azure portal](https://portal.azure.com/).

2. On the Azure Database for PostgreSQL - Flexible Server page, copy the **Server name** value from the **Essentials** panel on the **Overview** page by selecting the _Copy to clipboard_ button to the right of the value.

    ![Screenshot of the Azure Database for PostgreSQL - Flexible Server Overview blade in the Azure portal, with the Server name highlighted.](../img/azure-database-for-postgresql-server-name.png)

3. On your development computer, open pgAdmin.

4. In the pgAdmin **Object Explorer**, right-click on **Servers** and in the context menu select **Register >**, then **Server...**.

    ![Screenshot of the pgAdmin Servers context menu, with Register > Server highlighted.](../img/pgadmin-register-server.png)

5. In tab of **Register - Server** dialog, follow these steps:

    1. On the **General** tab, enter "PostgreSQLSolutionAccelerator" into the **Name** field and clear the **Connect now** option.

        ![Screenshot of the Register Server general tabl with the name and connect now fields highlighted.](../img/pgadmin-register-server-general-tab.png)

    2. Select the **Connection** tab and provide your Azure Database for PostgreSQL flexible server instance details for **Hostname/address** and **Username**.

        1. Paste the **Server name** value of your Azure Database for PostgreSQL flexible server into the **Host name/address** field.

        2. The **Username** value is your Microsoft Entra ID or email.

    3. Select **Save**.

    4. Right-click the newly added **PostgreSQLSolutionAccelerator** server in the pgAdmin Object Explorer, and select **Connect Server** in the context menu.

        ![Screenshot of the server context menu, with Connect Server highlighted.](../img/pgadmin-connect-server.png)

    5. In the **Connect to Server** dialog, you will need to provide an access token.

        !!! note "To Retrieve Your Microsoft Entra ID Access Token"

            1. In VS Code, open a new integrated terminal.

            2. At the integrated terminal prompt, execute the following command to generate and output an access token:

                ```bash
                $token = az account get-access-token --resource-type oss-rdbms --output json | ConvertFrom-Json
                $token.accessToken
                ```

            3. Copy the output value.

                !!! info "The token is a Base64 string. It encodes all the information about the authenticated user and is targeted to the Azure Database for PostgreSQL service."

    6. Return to pgAdmin and the **Connect to Server** dialog and paste the access token into the password field.

        ![Screenshot of the Connect to Server dialog, with the access token entered into the password box.](../img/pgadmin-connect-to-server.png)

        !!! note "Do not save password!"

            Ensure the **Save Password** box in the _Connect to Server_ dialog is unchecked. Checking this box can cause your login to fail.

    7. Select **OK**.

        !!! warning "Access token expiration"

            If your access token expires during the course of the workshop, you will need to come back and repeat the above steps to reauthenticate.

!!! tip "Leave VS Code open as you will be using it throughout the remainder of the workshop."
