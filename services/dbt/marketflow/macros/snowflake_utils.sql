{% macro to_timestamp(expr) %}
TO_TIMESTAMP_LTZ({{ expr }})
{% endmacro %}

{% macro merge_incremental(target, source, keys) %}
merge into {{ target }} as t
using {{ source }} as s
on {% for k in keys %} t.{{ k }} = s.{{ k }} {% if not loop.last %} and {% endif %}{% endfor %}
when matched then update set *
when not matched then insert *
{% endmacro %}
