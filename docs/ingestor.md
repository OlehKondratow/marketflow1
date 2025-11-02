for t in ohlcv_raw trades_raw signals_raw; do
  az eventhubs eventhub create \
    --name $t \
    --namespace-name marketflow-kafka-ns \
    --resource-group marketflow-rg \
    --message-retention 7 \
    --partition-count 3
done
