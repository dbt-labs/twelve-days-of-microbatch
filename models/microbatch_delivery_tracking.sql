{{ config(
    materialized='incremental',
    incremental_strategy='microbatch',
    event_time='delivered_at',
    batch_size='day',
    unique_key='id',
    begin='2024-12-09',
    on_schema_change='fail'
)}}
SELECT * FROM {{ ref('externally_updated_model')}}