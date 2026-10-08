-- ============================================================
-- Student Engagement Analysis Queries
-- Author: [Your Name]
-- Context: BA Portfolio - EdTech Domain Analysis
-- 
-- Purpose: These queries demonstrate data analysis skills
-- relevant to product decisions in EdTech platforms.
-- Drawn from real patterns observed in 18 years of testing
-- engagement systems (game analytics + EdTech platforms)
-- ============================================================

-- ----------------------------------------
-- 1. Daily Active Students (DAS) Trend
-- BA Use Case: Product health metric for executive dashboard
-- Game Testing Parallel: Similar to DAU tracking in games
-- ----------------------------------------
SELECT 
    DATE(last_active_at) AS activity_date,
    COUNT(DISTINCT student_id) AS daily_active_students,
    COUNT(DISTINCT CASE WHEN grade IN ('K','1','2','3') THEN student_id END) AS das_elementary,
    COUNT(DISTINCT CASE WHEN grade IN ('4','5','6','7','8') THEN student_id END) AS das_middle,
    COUNT(DISTINCT CASE WHEN grade IN ('9','10','11','12') THEN student_id END) AS das_high
FROM student_sessions
WHERE last_active_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(last_active_at)
ORDER BY activity_date DESC;


-- ----------------------------------------
-- 2. Course Completion Funnel Analysis
-- BA Use Case: Identify where students drop off
-- Game Testing Parallel: Level completion funnels in games
-- ----------------------------------------
SELECT 
    c.course_name,
    COUNT(DISTINCT e.student_id) AS enrolled,
    COUNT(DISTINCT CASE WHEN p.completion_pct >= 25 THEN e.student_id END) AS reached_25_pct,
    COUNT(DISTINCT CASE WHEN p.completion_pct >= 50 THEN e.student_id END) AS reached_50_pct,
    COUNT(DISTINCT CASE WHEN p.completion_pct >= 75 THEN e.student_id END) AS reached_75_pct,
    COUNT(DISTINCT CASE WHEN p.completion_pct = 100 THEN e.student_id END) AS completed,
    ROUND(
        COUNT(DISTINCT CASE WHEN p.completion_pct = 100 THEN e.student_id END)::NUMERIC / 
        NULLIF(COUNT(DISTINCT e.student_id), 0) * 100, 2
    ) AS completion_rate_pct
FROM enrollments e
JOIN courses c ON e.course_id = c.id
LEFT JOIN student_progress p ON e.student_id = p.student_id AND e.course_id = p.course_id
GROUP BY c.course_name
ORDER BY completion_rate_pct DESC;


-- ----------------------------------------
-- 3. Cohort Retention Analysis (Week over Week)
-- BA Use Case: Measure if product changes improve retention
-- Game Testing Parallel: Used this same pattern for 
--   analyzing player retention in F2P games
-- ----------------------------------------
WITH cohorts AS (
    SELECT 
        student_id,
        DATE_TRUNC('week', MIN(created_at)) AS cohort_week
    FROM students
    GROUP BY student_id
),
activity AS (
    SELECT 
        student_id,
        DATE_TRUNC('week', session_date) AS activity_week
    FROM student_sessions
)
SELECT 
    c.cohort_week,
    COUNT(DISTINCT c.student_id) AS cohort_size,
    COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week THEN a.student_id END) AS week_0,
    COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week + INTERVAL '1 week' THEN a.student_id END) AS week_1,
    COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week + INTERVAL '2 weeks' THEN a.student_id END) AS week_2,
    COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week + INTERVAL '3 weeks' THEN a.student_id END) AS week_3,
    COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week + INTERVAL '4 weeks' THEN a.student_id END) AS week_4
FROM cohorts c
LEFT JOIN activity a ON c.student_id = a.student_id
GROUP BY c.cohort_week
ORDER BY c.cohort_week DESC;


-- ----------------------------------------
-- 4. Content Difficulty Analysis
-- BA Use Case: Flag content that may be too hard/easy
-- Product Action: Inform adaptive learning algorithm tuning
-- ----------------------------------------
SELECT 
    q.question_id,
    q.topic,
    q.difficulty_tag,
    COUNT(a.attempt_id) AS total_attempts,
    ROUND(AVG(CASE WHEN a.is_correct THEN 1.0 ELSE 0.0 END) * 100, 2) AS accuracy_rate,
    ROUND(AVG(a.time_spent_seconds), 1) AS avg_time_seconds,
    CASE 
        WHEN AVG(CASE WHEN a.is_correct THEN 1.0 ELSE 0.0 END) > 0.9 THEN '🟢 Too Easy - Consider Harder'
        WHEN AVG(CASE WHEN a.is_correct THEN 1.0 ELSE 0.0 END) < 0.3 THEN '🔴 Too Hard - Review Content'
        ELSE '🟡 Appropriate Difficulty'
    END AS difficulty_assessment
FROM questions q
JOIN attempts a ON q.question_id = a.question_id
GROUP BY q.question_id, q.topic, q.difficulty_tag
HAVING COUNT(a.attempt_id) >= 50  -- Minimum sample size
ORDER BY accuracy_rate ASC;
