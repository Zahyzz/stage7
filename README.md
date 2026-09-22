# Stage 7 – PDF chatbot on Azure

A Streamlit chatbot (`chatbot.py`) with a FastAPI backend (`backend.py`) and ChromaDB. Chats are stored in Azure Database for PostgreSQL and chat files in Azure Blob Storage. The backend reads all of its settings from Azure Key Vault through the VM's managed identity.

## How it runs

- On every push to `main`, [.github/workflows/deploy.yml](.github/workflows/deploy.yml) builds the backend and chatbot images and pushes them to Docker Hub as `<DOCKERHUB_USERNAME>/stage7-backend` and `<DOCKERHUB_USERNAME>/stage7-chatbot`.
- The deploy job then logs in to Azure and uses `az vm run-command` to run [update_app.sh](update_app.sh) on the VM. The script pulls the latest code and images and restarts the stack with Docker Compose.
- The app is served at `http://<VM-public-IP>:8501`.

## Key Vault secrets

The backend reads these secrets from the vault named by `KEY_VAULT_NAME`:

`PROJ-DB-NAME`, `PROJ-DB-USER`, `PROJ-DB-PASSWORD`, `PROJ-DB-HOST`, `PROJ-DB-PORT`, `PROJ-OPENAI-API-KEY`, `PROJ-AZURE-STORAGE-SAS-URL`, `PROJ-AZURE-STORAGE-CONTAINER`, `PROJ-CHROMADB-HOST`, `PROJ-CHROMADB-PORT`

The VM's system-assigned identity needs the **Key Vault Secrets User** role on the vault.

## VM setup

1. Clone the repo with the deploy key:
   ```sh
   GIT_SSH_COMMAND='ssh -i /home/azureuser/.ssh/stage7_deploy_key -o IdentitiesOnly=yes' git clone git@github.com:Zahyzz/stage7.git ~/stage7
   ```
2. Create `~/stage7/.env` from [.env.example](.env.example), setting `KEY_VAULT_NAME` and `DOCKERHUB_NAMESPACE`. This file holds no secrets.
3. Run `~/stage7/update_app.sh`.

## GitHub repository secrets

| Secret | Value |
|---|---|
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token with Read & Write access |
| `AZURE_CREDENTIALS` | Service principal JSON with `clientId`, `clientSecret`, `subscriptionId`, `tenantId` |
| `RESOURCE_GROUP_NAME` | Resource group that contains the VM |
| `VM_NAME` | Name of the VM |
