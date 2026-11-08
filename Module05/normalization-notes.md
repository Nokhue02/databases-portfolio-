ROUND 1: FDs
LLM's response
1. job_id → machine_id
2. machine_id → site
3. machine_id → technician
4. part_no → part_price
5. (job_id, part_no) → machine_id, site, technician, part_price

Our Response as a Pod
machine_id →  technician
machine_id →  site
part_no  →  part_price

At first we didn't understand its fifth answer but according to what we learnt from the LLM that both the job_id and part_no cannot individually uniquely identify a row however when they are combined then they can be used to identify a row or attribute.

ROUND 3 — Database Normalization

I created an unnormalized table called `flat_jobpart` containing 200,000 records.

I then decomposed the table into four normalized tables: `machine`, `part`, `job`, and `job_part`.

The purpose of normalization was to reduce data duplication and prevent update, insert, and delete anomalies.

I used `SELECT DISTINCT` to avoid duplicate records and `CAST` to convert part prices from TEXT to REAL.

Expected verification results:

- Machine: 50 rows
- Part: 10 rows
- Job: 20,000 rows
- Job_part: 200,000 rows

The final integrity check should confirm that the original table and normalized job-part table both contain 200,000 records.

ROUND 4: Normalized vs Denormalized 

NORMALIZED RUN TIME:
Run Time: real 1.013915 user 0.234375 sys 0.234375

DENORMALIZED RUN TIME:
Run Time: real 0.965423 user 0.156250 sys 0.140625

EXECUTION PLANS

Normalized query execution plan:

```text
SCAN jp
SEARCH j USING INTEGER PRIMARY KEY (rowid=?)
SEARCH m USING INDEX sqlite_autoindex_machine_1
SEARCH p USING INDEX sqlite_autoindex_part_1
USE TEMP B-TREE FOR GROUP BY
```

Denormalized query execution plan:

```text
SCAN report_jobpart USING INDEX ix_report_machine
USE TEMP B-TREE FOR GROUP BY
```

Performance results:

- Normalized query: 1.013915 seconds
- Denormalized query: 0.965423 seconds
- Time saved: 0.048492 seconds
- Speedup: approximately 1.05×
- Execution time reduction: approximately 4.8%

Conclusion:

The normalized query accesses four tables and performs three joins, while the denormalized query accesses only one reporting table.

The denormalized query was slightly faster in this experiment. However, the improvement was relatively small.

The execution plans show that the denormalized query avoids the joins, although it still scans the reporting table and uses a temporary B-tree for grouping.

This demonstrates that denormalization can improve read performance, but the benefits must be compared against the additional storage and update costs.

Round 5 — Writes and Storage

In this round, I investigated the maintenance and storage costs of normalization and denormalization.

Update cost: Changing the site of one machine requires updating only one row in the normalized `machine` table. In the denormalized `report_jobpart` table, the same change affects 4,000 rows because the site information is duplicated.

Storage cost: The normalized design stores machine and part information separately, while the denormalized design repeats site, technician, and part price across job-part records. I measured the storage using SQLite's `dbstat` table.

Index experiment: I tested the reporting query with and without the `ix_report_machine` index to determine whether the index improves query performance.

Conclusion:Denormalization can improve read performance, but it increases data redundancy and the cost of updating duplicated information. The best design depends on the balance between reading and writing operations.

ROUND 6

BENCHMARK RESULTS
Measurement	                                Normalized (3NF)	                    Denormalized
Dashboard query time	                       1,013.915 ms	                         965.423 ms
Rows changed by one site update	                   1	                              4,000
Storage	                                         3,976 KB	                         10,832 KB
Redundancy	                                     Minimal	                        Site, technician and price repeated


Recommendation to Yasmin Kaya

As a pod we agreed that it would be better if Kortmann would keep it's transactional database normalized in Third Normal Form (3NF) while using a separate denormalized reporting table for the machine-health dashboard. Our benchmark showed that the denormalized query took 965.423 milliseconds compared with 1,013.915 milliseconds for the normalized query, making it approximately 4.8% faster. However, updating one machine's site required changing only one row in the normalized database but 4,000 rows in the denormalized table. The denormalized table also occupied 10,832 KB compared with 3,976 KB for the normalized tables, demonstrating the additional storage cost. To prevent the reporting table from becoming outdated, I recommend a scheduled rebuild from the normalized tables, with the refreshed data replacing the previous reporting data only after the rebuild succeeds. This would preserve data integrity in the transactional database while providing the dashboard with a simpler reporting query. Although the measured performance improvement was small, this approach allows Kortmann to evaluate reporting performance without sacrificing the correctness of its primary database.

