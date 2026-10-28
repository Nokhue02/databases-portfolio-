Task A: Plan Safari

Predictions before checking the plans

SELECT * FROM maint_job WHERE technician = 'Beier';

Prediction: SEARCH

Reason: The technician column has an index, ix_job_tech.

SELECT * FROM machine WHERE machine_name = 'cnc-02';

Prediction: SCAN

Reason: I expect SQLite to examine the machine table because I have not confirmed an index on machine_name.

SELECT * FROM maint_job WHERE technician LIKE '%ei%';

Prediction: SCAN

Reason: The leading wildcard in %ei% makes it difficult for SQLite to use the technician index.

Actual plans and observations

### Actual plans after adding `ix_job_tech`

| Query | Actual plan | Explanation |
|---|---|---|
| `technician = 'Beier'` | `SEARCH maint_job USING INDEX ix_job_tech` | SQLite can use the index to find matching technicians. |
| `machine_name = 'cnc-02'` | `SCAN machine` | SQLite scans the machine table because the plan does not use an index for this query. |
| `technician LIKE '%ei%'` | `SCAN maint_job` | The leading wildcard prevents the normal technician index from narrowing the search. |

### Conclusion

Adding an index can help a query when its condition matches the index structure. It does not help every query: a leading-wildcard `LIKE` can still require a table scan. The execution plan is evidence of what SQLite actually does.

### Task B — Algebra Check

**My original expression**

`technician, avg_days (γ technician; AVG(days) (σ days > 5))`

**What I intended**

I wanted to filter maintenance jobs where `days > 5`, group the remaining rows by technician, and calculate the average days for each technician.

**Where I was wrong**

My idea was mostly correct, but my notation was incomplete. I did not explicitly include `maint_job` in the selection expression, and I placed the output column names outside the relational algebra expression without clearly showing how they were produced.

**Corrected relational algebra**

γ technician; AVG(days) (σ days > 5 (maint_job))

**Corrected SQL**

```sql
SELECT technician, AVG(days) AS avg_days
FROM maint_job
WHERE days > 5
GROUP BY technician;
```

**Explanation**

Selection (σ) filters the rows first. Grouping and aggregation (γ) then groups the remaining rows by technician and calculates the average days for each group.

**AI comparison**

I will compare my corrected expression with the AI-generated expression and check that both filter before grouping and calculate the average separately for each technician.