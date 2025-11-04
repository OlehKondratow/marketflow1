#!/usr/bin/env bash
SCOPE=$1
PRINCIPAL=$2

EXISTS=$(az role assignment list \
  --scope "$SCOPE" \
  --assignee "$PRINCIPAL" \
  --query "[].id" -o tsv)

if [[ -z "$EXISTS" ]]; then
  # 🔹 возвращаем строку "false"
  echo '{"exists": "false"}'
else
  # 🔹 возвращаем строку "true"
  echo '{"exists": "true"}'
fi
