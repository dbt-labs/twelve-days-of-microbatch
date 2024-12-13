{{ config(materialized='table', event_time='delivered_at') }}

SELECT gift_id as id, gift, TO_TIMESTAMP_TZ(given_at) as delivered_at, reciever FROM {{ref('gifts_seed')}}
