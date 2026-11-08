sqlite> CREATE TABLE t_safe (
(x1...>     sensor_id INTEGER PRIMARY KEY,
(x1...>     metric TEXT NOT NULL
(x1...>         CHECK(metric IN ('temp_c', 'power_w', 'rpm')),
(x1...>     value REAL NOT NULL
(x1...>         CHECK(value BETWEEN -273.15 AND 5000)
(x1...> ) STRICT;
sqlite> INSERT INTO t VALUES
   ...> (1, 'temp_c', 9000),
   ...> (1, 'temp_c', 'hot'),
   ...> (2, 'bogus', -500);
sqlite> 
sqlite> SELECT * FROM t;
╭───────────┬────────┬────────╮
│ sensor_id │ metric │ value  │
╞═══════════╪════════╪════════╡
│         1 │ temp_c │ 9000.0 │
│         1 │ temp_c │ hot    │
│         2 │ bogus  │ -500.0 │
│         1 │ temp_c │ 9000.0 │
│         1 │ temp_c │ hot    │
│         2 │ bogus  │ -500.0 │
╰───────────┴────────┴────────╯