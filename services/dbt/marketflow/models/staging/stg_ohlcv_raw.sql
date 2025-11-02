-- Raw staging view from STAGING.OHLCV_RAW
select
    symbol,
    ts,
    open,
    high,
    low,
    close,
    volume
from {{ source('staging', 'ohlcv_raw') }}
