with candles as (
    select
        symbol,
        ts,
        close,
        {{ sma('close', 5) }} as sma_5,
        {{ sma('close', 20) }} as sma_20,
        {{ rsi('close', 14) }} as rsi_14
    from {{ ref('stg_ohlcv_raw') }}
)
select *,
       case when sma_5 > sma_20 then 'BUY' else 'SELL' end as signal
from candles
qualify row_number() over (partition by symbol order by ts desc) <= 5000
