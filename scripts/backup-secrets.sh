#!/usr/bin/env bash
set -euo pipefail

VAULT_NAME="$1"
BACKUP_STORAGE_ACCOUNT="plstatsdrbackup"
BACKUP_CONTAINER="secrets-backups"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")

SECRETS=$(az keyvault secret list --vault-name "$VAULT_NAME" --query "[].name" -o tsv)

for SECRET_NAME in $SECRETS; do
  LOCAL_FILE="/tmp/${SECRET_NAME}-${TIMESTAMP}.backup"

  echo "Backing up secret: ${SECRET_NAME}"
  az keyvault secret backup \
    --vault-name "$VAULT_NAME" \
    --name "$SECRET_NAME" \
    --file "$LOCAL_FILE"

  az storage blob upload \
    --account-name "$BACKUP_STORAGE_ACCOUNT" \
    --container-name "$BACKUP_CONTAINER" \
    --name "${VAULT_NAME}/${SECRET_NAME}-${TIMESTAMP}.backup" \
    --file "$LOCAL_FILE" \
    --auth-mode login

  rm "$LOCAL_FILE"
  echo "Uploaded: ${VAULT_NAME}/${SECRET_NAME}-${TIMESTAMP}.backup"
done

echo "Backup complete: ${SECRETS} secrets backed up from ${VAULT_NAME}"