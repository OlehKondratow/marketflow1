{% macro sma(column, window) %}
avg({{ column }}) over (
    partition by symbol
    order by ts
    rows between {{ window - 1 }} preceding and current row
)
{% endmacro %}

{% macro ema(column, window) %}
-- Simplified EMA approximation (for demonstration)
(2 / ({{ window }} + 1)) * {{ column }} +
(1 - (2 / ({{ window }} + 1))) * lag({{ column }}) over (partition by symbol order by ts)
{% endmacro %}

{% macro rsi(column, window) %}
avg(iif({{ column }} - lag({{ column }}) over (partition by symbol order by ts) > 0,
         {{ column }} - lag({{ column }}) over (partition by symbol order by ts),
         0)) over (partition by symbol order by ts rows between {{ window }} preceding and current row)
/ nullif(avg(abs({{ column }} - lag({{ column }}) over (partition by symbol order by ts))) over (partition by symbol order by ts rows between {{ window }} preceding and current row), 0)
{% endmacro %}
