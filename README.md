## Welcome to the **12 Days of Microbatch** demo! 🎅

The whole dbt-core team has been hard at work in Santa's workshop to bring a bunch of amazing features to the [dbt-core 1.9.0 release](https://github.com/dbt-labs/dbt-core/releases/tag/v1.9.0). One of those features is the new [_Microbatch_ incremental strategy](https://docs.getdbt.com/docs/build/incremental-microbatch). To thank the rest of the core team for their work, I've decided to give them gifts by starting the [twelve days of christmas](https://en.wikipedia.org/wiki/The_Twelve_Days_of_Christmas_(song)) early, and I need your help! I need you to help keep me up to date on what gifts have been delivered 🎁

## Setup

First, this project assumes you have access to snowflake. By default the project looks for a profile called `days_of_christmas`. If you'd like to use a different data warehouse you'll likely need to edit the timstamp conversion logic in `models/externally_updated_model.sql`, as the current conversion logic is snowflake specific.

Secondly, you'll need to be on `dbt-snowflake >= 1.9.0` (or the relevant adapter for you). To install it, you can simply run `pip install -r requirements.txt`.

Finally, ensure you have all the branches:
1. `git fetch --all`
2. `git pull --all`

# Start giving gifts

## Intial state
The 12 days of christmas have already started, there are probably already some gifts that have been delivered. To get our data warehouse to reflect that, do the following
1. Ensure you're on branch 1-init via `git checkout 1-init`
2. `dbt seed`
3. `dbt run`

You'll notice that _5_ batches are run for the `microbatch_delivery_tracking` model (that is if you are running this on Dec 13th, 2024. If you're sometime in the future, it'll likely be more). Specifically 2024-12-09, 2024-12-10, 2024-12-11, 2024-12-12, 2024-12-13. If you want to see exactly what we have thus far you can inspect the data by running `dbt show --inline "SELECT * FROM <YOUR_SCHEMA_NAME>.microbatch_delivery_tracking" --limit 20`.

## Day 5 (Dec 13, 2024) Gifts are delivered

It's been a day since we ran our project, and we want to see what other gifts have been delivered!
1. Ensure you're on branch 2-day-5 via `git checkout 2-day-5`
2. `dbt seed`
3. `dbt run`

This time only _2_ batches were run for the `microbatch_delivery_tracking` model. If you check out `models/microbatch_delivery_tracking.sql` you'll notice that the config doesn't have a `lookback` value set, in which case our lookback value is 1. So when we ran `dbt run` the `microbatch_delivery_tracking` model ran today's batch (Dec 13, 2024) and one lookback batch (Dec 12, 2024). Now if we inspect our data warehouse we'll see all data is there `dbt show --inline "SELECT * FROM <YOUR_SCHEMA_NAME>.microbatch_delivery_tracking" --limit 20`.

## Late arriving data

Looking at our data via `dbt show --inline "SELECT * FROM <YOUR_SCHEMA_NAME>.microbatch_delivery_tracking" --limit 20`, we noticed that the second turtle dove never showed up on Dec 10, 2024 🤔 Maybe it got delivered, but the delivery person's scanner didn't register it right away. Maybe it's arrived now?

1. Ensure you're on branch 3-second-turtle-dove via `git checkout 3-second-turtle-dove`
2. `dbt seed`
3. `dbt run`

If we now inspect our data `dbt show --inline "SELECT * FROM <YOUR_SCHEMA_NAME>.microbatch_delivery_tracking" --limit 20` the turtle dove still isn't there!?1?!?! What gives? Oh that's right our lookback is `1`. We didn't reprocess the data for batch `2024-12-10` so it still hasn't made it to our microbatch model table. When data arrives late like this we need to do a [targeted backfill](https://docs.getdbt.com/docs/build/incremental-microbatch#backfills).

1. `dbt run --event-time-start "2024-12-10" --event-time-end "2024-12-11"

Now if we go inspect our data via `dbt show --inline "SELECT * FROM <YOUR_SCHEMA_NAME>.microbatch_delivery_tracking" --limit 20` we'll see the second turtle dove did indeed get delivered! Nice! 😎

## Knowing who got what gift

There is one gap in our data currently, WE DON'T KNOW WHO GOT WHAT GIFT 😱 That is a problem! The good news though is that our upstream has started providing that information, so we can start propagating it

1. Ensure you're on branch 4-day-5 via `git checkout 4-info-on-reciever-added`
2. `dbt seed --full-refresh` (full refresh because the schema of the seed changed)
3. `dbt run`

Oh no! An error! What happened!?! If we check out `models/microbatch_delivery_tracking.sql` we can see we have the config `on_schema_change='fail'` set. This makes it such that if the schema of the incremental model changes inbetween runs, we'll fail on the next run ([docs](https://docs.getdbt.com/reference/resource-configs/contract#incremental-models-and-on_schema_change)). We did this because we don't want to silently have all the _older_ batches to have `null` for the new column `reciever`. In order to move forward, we have to do a [full refresh](https://docs.getdbt.com/reference/resource-configs/full_refresh#description) to get things running again

1. `dbt run --full-refresh`

Huh, it looks like that _mostly worked_. There were 5 batches than ran, but one failed, 2024-12-13. What happened? If we look in `models/microbatch_delivery_tracking.sql` we'll notice that the grinch snuck in and tried to foil our gift giving merriment! If we delete the lines

```
{% if model.batch.id == '20241213' %}
    GRINCH INPUTS BAD SQL;
{% endif %}
```

we should be good to go. Lets rerun things with retry

1. `dbt retry`

Woah! Did you see that, we ran only 1 batch! So if any number of batches failed, if we run `dbt retry` _only_ the previously failed batches will be rerun. Now if we check our data `dbt show --inline "SELECT * FROM <YOUR_SCHEMA_NAME>.microbatch_delivery_tracking" --limit 20`, it looks like everything is up to date. Thank you for helping me get these gifts delivered, you've been a huge help. Hopefully microbatch made your job easier 😉