# 📊 StackOverflow SQL Analytics & User Performance Project

This repository contains a collection of intermediate-to-advanced SQL analytical queries focused on user activity tracking, engagement milestones, performance ranking, and data aggregation on StackOverflow-style database schemas.

---

## 🛠️ Key SQL Concepts Applied
- **Common Table Expressions (CTEs):** Modularized multi-step logic to maintain clean, readable, and maintainable analytical pipelines.
- **Window Functions:** Applied `RANK() OVER()` for global leaderboards and `COUNT(*) OVER(PARTITION BY ... ORDER BY ...)` for running totals without collapsing row detail.
- **Aggregations & Filtering:** Leveraged `GROUP BY`, `AVG()`, and `MIN()` alongside post-aggregation dynamic filtering.
- **Multi-Table Joins:** Integrated master user metadata (`users`) with activity and interaction logs (`posts`, `badges`).

---

## 🔍 Analytical Scenarios & Solutions

### 1. Global User Ranking by Average Post Score
**Objective:** Identify top-performing users with an average post score exceeding 40 and generate a global ranking leaderboard.

```sql
WITH avg_post_score AS (
    SELECT 
        user_id,
        AVG(score) AS avg_score
    FROM posts
    GROUP BY user_id
)
SELECT 
    u.id AS user_id, 
    u.display_name, 
    u.reputation, 
    a.avg_score,
    RANK() OVER (ORDER BY a.avg_score DESC) AS user_rank
FROM users u
JOIN avg_post_score a ON u.id = a.user_id
WHERE a.avg_score > 40;




2. Milestone Threshold Tracking (Badge Acquisition)
Objective: Dynamically identify the exact date each user crossed their milestone threshold (exceeding 1 total badge) in a scalable, non-hardcoded manner.

SQL


WITH running_totals AS (
    SELECT 
        user_id,
        date,
        COUNT(*) OVER (PARTITION BY user_id ORDER BY date) AS cumulative_badges
    FROM badges
)
SELECT 
    user_id,
    MIN(date) AS milestone_date
FROM running_totals
WHERE cumulative_badges > 1
GROUP BY user_id;
