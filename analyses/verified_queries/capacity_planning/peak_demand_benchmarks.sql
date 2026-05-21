SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_donor_retention
  METRICS avg_demand, p90_demand, avg_benchmark_utilization
  DIMENSIONS benchmarks.ticket_type, benchmarks.day_name, benchmarks.entry_window_start)
