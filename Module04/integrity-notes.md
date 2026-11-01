# Module 04 – Database Integrity Notes

What is Database Integrity?

As a pod we learnt that database integrity means making sure that data stored in a database is accurate, valid, consistent, and reliable. It helps prevent incorrect information from being saved.

We also discovered that there are three layers of Database integrity: Firstly there Entity Integrity which ensures that each and every record in table is unique and identifiable. It uses the PRIMARY KEY, NOT NULL, and UNIQUE constraints to prevent duplicate or missing required information.

The second entity is Referential Integrity which ensures that the relationships between tables are correct.It uses FOREIGN KEY constraints to prevent recording things that do not exist.

The third entity is Semantic Integrity which ensures that the values stored in the database make sense. For example a temperature 9000 degrees celsius would be rejected using the CHECK constraint.

Important SQLite Features

STRICT Tables

STRICT tables ensure that values match their declared data types. For example, text such as "abc" cannot be stored in a REAL temperature column.

CHECK Constraints

CHECK constraints prevent invalid values from being inserted into the database.

Example:
```sql
temperature REAL CHECK (temperature BETWEEN -40 AND 200)
```

Generated Columns

Generated columns automatically calculate values from other columns. For example, energy consumption can be calculated from power and time.

Triggers

Triggers automatically perform actions when certain events occur in the database. For example, when a machine overheats, a trigger can automatically create an alarm record.

UPSERT

UPSERT is used to insert new records or update existing ones when a uniqueness conflict occurs. This helps prevent duplicate sensor readings.

 Data Control Language (DCL)

DCL controls access to database information.

Unlike server-based databases, SQLite does not have built-in users or roles. Instead, access is controlled using file permissions, views, and read-only connections.

Why Database Integrity Is Important

Database integrity is important because it:

- Prevents incorrect sensor readings from being stored.
- Avoids duplicate records.
- Ensures relationships between tables are valid.
- Automatically creates alarms when machines overheat.
- Helps maintain reliable data without an internet connection.

 Conclusion

From this module, I learned that database integrity is important for keeping information accurate and reliable. SQLite can enforce rules using constraints, STRICT tables, generated columns, triggers, and UPSERT. These features help Wittkamp's factory store trustworthy sensor data locally without depending on cloud services.

TASK A 
for a table without constraints

CREATE TABLE t (
    sensor_id INTEGER,
    metric TEXT,
    value REAL
);

INSERT INTO t VALUES
(1, 'temp_c', 9000),
(1, 'temp_c', 'hot'),
(2, 'bogus', -500);

SELECT * FROM t;
Results

╭───────────┬────────┬────────╮
│ sensor_id │ metric │ value  │
╞═══════════╪════════╪════════╡
│         1 │ temp_c │ 9000.0 │
│         1 │ temp_c │ hot    │
│         2 │ bogus  │ -500.0 │
╰───────────┴────────┴────────╯
For Task A a code with Constraints does not allow random data to be put into the table
sqlite> CREATE TABLE t_safe (
(x1...>     sensor_id INTEGER PRIMARY KEY,
(x1...>     metric TEXT NOT NULL
(x1...>         CHECK(metric IN ('temp_c', 'power_w', 'rpm')),
(x1...>     value REAL NOT NULL
(x1...>         CHECK(value BETWEEN -273.15 AND 5000)
(x1...> ) STRICT;
Parse error near line 1: table t_safe already exists
  CREATE TABLE t_safe (     sensor_id INTEGER PRIMARY KEY,     metric TEXT NOT N
               ^--- error here
sqlite> INSERT INTO t_safe VALUES (1, 'temp_c', 9000);
Error near line 8: CHECK constraint failed: value BETWEEN -273.15 AND 5000
sqlite> INSERT INTO t_safe VALUES (1, 'temp_c', 'hot');
Error near line 9: cannot store TEXT value in REAL column t_safe.value
sqlite> INSERT INTO t_safe VALUES (2, 'bogus', -500);
Error near line 10: CHECK constraint failed: metric IN ('temp_c', 'power_w', 'rpm')

Test	                                           Your result	Meaning
Temperature 9000°C	    Correctly rejected	    CHECK prevented an unrealistic temperature
Text 'hot'	             Correctly rejected	            STRICT prevented text in a numeric column
Metric 'bogus'	          Correctly rejected	CHECK prevented an unknown metric


Task A – Testing SQLite Constraints

I created a STRICT table with PRIMARY KEY, NOT NULL, and CHECK constraints. I tested three invalid sensor readings, and SQLite rejected all three.

Test 1: Temperature of 9000°C

Error: `CHECK constraint failed: value BETWEEN -273.15 AND 5000`

This demonstrates domain integrity because the temperature exceeded the permitted range.

Test 2: Text value "hot"

Error: `cannot store TEXT value in REAL column t_safe.value`

This demonstrates STRICT type enforcement because a text value cannot be stored in the REAL column.

Test 3: Invalid metric "bogus"

Error: `CHECK constraint failed: metric IN ('temp_c', 'power_w', 'rpm')`

This demonstrates domain integrity because the metric was not one of the permitted values.

Observation: SQLite successfully rejected invalid readings when constraints were applied, unlike the original unconstrained table.

Results for Task 1

sqlite> INSERT INTO sensor VALUES (1,'cnc-01','temp_c','degC'), (2,'cnc-01','vib_rms','mm/s');
sqlite> INSERT INTO reading(sensor_id, ts, value, interval_s) VALUES (1,'2026-03-01 08:00:00', 41.5, 1);
sqlite> 
sqlite> -- rejected: domain check (impossible temperature)
sqlite> INSERT INTO reading(sensor_id, ts, value, interval_s) VALUES (1,'2026-03-01 08:00:01', 9000, 1);
Error near line 36: CHECK constraint failed: value >= -273.15 AND value <= 5000
sqlite> -- rejected: STRICT type (text into a REAL)
sqlite> INSERT INTO reading(sensor_id, ts, value, interval_s) VALUES (1,'2026-03-01 08:00:02', 'hot', 1);
Error near line 38: cannot store TEXT value in REAL column reading.value
sqlite> -- rejected: referential integrity (sensor 99 does not exist)
sqlite> INSERT INTO reading(sensor_id, ts, value, interval_s) VALUES (99,'2026-03-01 08:00:03', 40, 1);
Error near line 40: FOREIGN KEY constraint failed
sqlite> -- rejected: entity integrity (duplicate sensor for the same machine+metric)
sqlite> INSERT INTO sensor VALUES (3,'cnc-01','temp_c','degC');
Error near line 42: UNIQUE constraint failed: sensor.machine_id, sensor.metric
sqlite> SELECT
   ...>     reading_id,
   ...>     sensor_id,
   ...>     value,
   ...>     interval_s,
   ...>     energy_j
   ...> FROM reading;
╭────────────┬───────────┬───────┬────────────┬──────────╮
│ reading_id │ sensor_id │ value │ interval_s │ energy_j │
╞════════════╪═══════════╪═══════╪════════════╪══════════╡
│          1 │         1 │  41.5 │          1 │     41.5 │
╰────────────┴───────────┴───────┴────────────┴──────────╯
Task 1: Proving the Constraints

I tested the SQLite database using valid and invalid sensor readings.

Test 1: Impossible temperature

Error: `CHECK constraint failed: value >= -273.15 AND value <= 5000`

The database rejected a temperature of 9000°C because it exceeded the allowed range.

Test 2: Invalid data type**

Error: `cannot store TEXT value in REAL column reading.value`

The STRICT table rejected the text value "hot" because the column requires a numeric value.

Test 3: Referential integrity**

Error: `FOREIGN KEY constraint failed`

The database rejected sensor ID 99 because the sensor does not exist in the sensor table.

Test 4: Duplicate sensor

Error: `UNIQUE constraint failed: sensor.machine_id, sensor.metric`

The database rejected a duplicate combination of machine ID and metric.

Generated Column

The valid reading had a value of 41.5 and an interval of 1 second. The generated column calculated 41.5 automatically.

Conclusion

The experiment demonstrated that SQLite constraints can reject invalid data, prevent duplicate sensor definitions, and maintain valid relationships between tables.

This was used to check if the UPSERT constraint was functioning
sqlite> -- Create a unique index to prevent duplicate readings
sqlite> CREATE UNIQUE INDEX IF NOT EXISTS ux_reading_sensor_ts
   ...> ON reading(sensor_id, ts);
sqlite> 
sqlite> -- Insert a reading or update it if it already exists
sqlite> INSERT INTO reading(sensor_id, ts, value, interval_s)
   ...> VALUES (1, '2026-03-01 08:00:00', 41.7, 1)
   ...> ON CONFLICT(sensor_id, ts)
   ...> DO UPDATE SET value = excluded.value;
sqlite> 
sqlite> -- Display the readings for sensor 1
sqlite> SELECT sensor_id, ts, value
   ...> FROM reading
   ...> WHERE sensor_id = 1;
╭───────────┬─────────────────────┬───────╮
│ sensor_id │         ts          │ value │
╞═══════════╪═════════════════════╪═══════╡
│         1 │ 2026-03-01 08:00:00 │  41.7 │
╰───────────┴─────────────────────┴───────╯
sqlite> 
sqlite> -- Count the readings with the same sensor and timestamp
sqlite> SELECT COUNT(*) AS number_of_rows
   ...> FROM reading
   ...> WHERE sensor_id = 1
   ...> AND ts = '2026-03-01 08:00:00';
╭────────────────╮
│ number_of_rows │
╞════════════════╡
│              1 │
╰────────────────╯

For Task 2

(databases-portfolio) C:\Users\machi\OneDrive\Desktop\Databases\databases-portfolio->python Module04/ingest.py
CSV readings processed: 0
Total database rows: 1

(databases-portfolio) C:\Users\machi\OneDrive\Desktop\Databases\databases-portfolio->python Module04/ingest.py
Traceback (most recent call last):
  File "C:\Users\machi\OneDrive\Desktop\Databases\databases-portfolio-\Module04\ingest.py", line 21, in <module>
    int(row["sensor_id"]),
        ~~~^^^^^^^^^^^^^
KeyError: 'sensor_id'

(databases-portfolio) C:\Users\machi\OneDrive\Desktop\Databases\databases-portfolio->python Module04/ingest.py
CSV readings processed: 5
Total database rows: 5
 
 There was an error because the readings in csv started from line 2 not 1

 Checking the UPSERT constraint 
(databases-portfolio) C:\Users\machi\OneDrive\Desktop\Databases\databases-portfolio->python Module04/ingest.py
CSV readings processed: 5
Total database rows: 5

(databases-portfolio) C:\Users\machi\OneDrive\Desktop\Databases\databases-portfolio->python Module04/ingest.py
CSV readings processed: 5
Total database rows: 5


(databases-portfolio) C:\Users\machi\OneDrive\Desktop\Databases\databases-portfolio->python Module04/ingest.py
CSV readings processed: 4
Total database rows: 5

database row still shows 5 even after one record was deleted because UPSERT keeps does not delete existing records

Task 2: Idempotent Edge Ingestion with UPSERT

Objective

The purpose of this task was to prevent duplicate sensor readings when the same data is processed multiple times.

Implementation

I created a unique index on the sensor ID and timestamp to identify duplicate readings.

I then created a Python script called `ingest.py`, which reads sensor measurements from a CSV file and inserts them into SQLite using `executemany()` and UPSERT.

Results

| Execution | CSV readings processed | Total database rows |
|---|---|---|
| First run | 5 | 5 |
| Second run | 5 | 5 |
| Third run | 4 | 5 |

Observation

During the first and second executions, the program processed 5 CSV readings, but the total number of database rows remained at 5.

This demonstrates that UPSERT prevented duplicate records when the same data was processed twice.

The third execution processed only 4 readings, but the database still contained 5 rows.

Conclusion

I learned that UPSERT makes database ingestion idempotent by inserting new readings and updating existing readings when their unique keys match. This is useful for edge gateways because sensor readings may be transmitted again after network interruptions.


Task 3: Triggers for Alarms and Audit

Objective

The objective was to implement SQLite triggers that automatically generate alarms for high vibration readings and record changes to sensor values. I also measured the performance impact of using an alarm trigger.

Alarm Trigger Results

I inserted a vibration reading of 2.7 mm/s, exceeding the threshold of 2.0 mm/s.

SQLite automatically created an alarm with the reason "vibration over 2.0 mm/s".

Audit Trigger Results

I updated a sensor reading from 2.7 to 1.4. SQLite automatically recorded the change in the audit table.

- Reading ID: 6
- Old value: 2.7
- New value: 1.4

Performance Benchmark

I used a Python benchmark to compare the time required to insert 10,000 synthetic readings with and without the alarm trigger.

| Test | Execution time |
|---|---|
| Without alarm trigger | 0.0318 seconds |
| With alarm trigger | 0.0673 seconds |
| Additional time | Approximately 0.0354 seconds |

The benchmark showed that enabling the trigger increased ingestion time by approximately 112%.

Without the trigger, the database contained one existing alarm. With the trigger enabled, the database contained 10,001 alarms, confirming that 10,000 additional alarms were generated.

Conclusion

I learned that SQLite triggers can automatically enforce database rules without relying on application code. The alarm trigger detected high vibration readings, while the audit trigger recorded updates to sensor values.

The performance test demonstrated that triggers introduce additional processing overhead. However, they are useful for maintaining data consistency and automatically recording important events.

Task 4: Access Control Without a Server

Objective

The purpose of this task was to demonstrate how SQLite can provide read-only access without requiring a database server.

Creating the View

I created a view called `machine_health`, which displays machine IDs, sensor metrics, peak readings, and the number of readings.

The view successfully displayed the machine's temperature and vibration information.

Read-Only Access Test

Since I used Windows, I used `attrib +R Module04\edge.db` instead of the Linux command `chmod 444`.

I opened the database in read-only mode and executed a SELECT query.

Result: The query successfully returned 6 readings.

I then attempted to delete readings using the same read-only connection.

Error:`attempt to write a readonly database`

This confirmed that SQLite prevented the DELETE operation.

After testing, I restored the file's writable attribute using `attrib -R Module04\edge.db`.

Comparison with PostgreSQL

PostgreSQL uses a database server with user accounts, roles, and permissions such as GRANT and REVOKE. SQLite does not provide built-in database users or roles, so access control relies on operating-system permissions and read-only connections. File-based access control is suitable for a trusted edge gateway because the database is accessed by a limited number of local processes. However, a multi-tenant web application requires stronger user-level access control and isolation, which PostgreSQL can provide.

Conclusion

This task demonstrated that SQLite can protect data from modification through read-only connections. I also learned that views can simplify access to selected information without exposing every column in the original tables, although views alone do not enforce access permissions.