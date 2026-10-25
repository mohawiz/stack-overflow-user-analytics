-- ==========================================
-- ASSIGNMENT: SQL EXERCISES & SOLUTIONS
-- ==========================================


-- ==========================================
-- PART 1: BASICS
-- ==========================================

-- 1. Explore the structure and first 5 rows of each table
SELECT * 
FROM posts 
LIMIT 5;


-- 2. Identify the total number of records in each table
SELECT 'posts' AS table_name, COUNT(*) AS total_records FROM posts
UNION ALL
SELECT 'comments', COUNT(*) FROM comments
UNION ALL
SELECT 'badges', COUNT(*) FROM badges
UNION ALL
SELECT 'post_history', COUNT(*) FROM post_history
UNION ALL
SELECT 'votes', COUNT(*) FROM votes
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'tags', COUNT(*) FROM tags
UNION ALL
SELECT 'post_links', COUNT(*) FROM post_links;


-- 3. Find all posts with a view_count greater than 100
SELECT * 
FROM posts 
WHERE view_count > 100;


-- 4. Display comments made in 2005, sorted by date of creation
SELECT * 
FROM comments 
WHERE creation_date >= '2005-01-01' 
  AND creation_date < '2006-01-01'
ORDER BY creation_date ASC;


-- 5. Count the total number of votes for each post_id
SELECT post_id, COUNT(*) AS total_votes
FROM votes
GROUP BY post_id;


-- 6. Calculate the count and average score of posts per post_tag_id
SELECT post_tag_id, COUNT(*), AVG(score)
FROM posts
GROUP BY post_tag_id;



-- ==========================================
-- PART 2: ADVANCED
-- ==========================================

-- 7. Combine the post_history and posts tables to display the title of posts and the corresponding changes made in the post history
SELECT po.title, p.text AS post_history_changes
FROM post_history p
JOIN posts po ON p.post_id = po.id;


-- 8. Show user details and the total badges earned by each user
WITH user_badge_counts AS (
    SELECT user_id, COUNT(user_id) AS total_badges
    FROM badges
    GROUP BY user_id
)
SELECT u.*, COALESCE(ub.total_badges, 0) AS total_badges
FROM users u
LEFT JOIN user_badge_counts ub ON u.id = ub.user_id;


-- 9. Fetch the titles of posts, their comments, and the users who made those comments
SELECT 
    p.title, 
    c.text AS comment_text, 
    u.display_name AS commenter_name
FROM posts p
LEFT JOIN comments c ON p.id = c.post_id
LEFT JOIN users u ON c.user_id = u.id;

-- Combine post_links with posts to list related questions.

select
p1.title as original_post,
p1.title as related_post
from post p1
join post_link pl on p1.id = pl.post_id
join posts p2 on ph.related_post_id = p2.id;

-- Find the users who have earned badges and also made comments.

WITH users_with_badges AS (
    SELECT DISTINCT user_id 
    FROM badges
),
users_with_comments AS (
    SELECT DISTINCT user_id 
    FROM comments
)
SELECT u.id, u.display_name
FROM users_with_badges b
INNER JOIN users_with_comments c ON b.user_id = c.user_id
JOIN users u ON b.user_id = u.id;

-- Find all users with the highest reputation.

select *
from users 
where reputation = (select max(reputation) from users);

-- Retrieve posts with the highest score in each post_tag_id

WITH ranked_posts AS (
    SELECT 
        post_tag_id,
        title,
        score,
        ROW_NUMBER() OVER (PARTITION BY post_tag_id ORDER BY score DESC) AS rn
    FROM posts
)
SELECT post_tag_id, title, score
FROM ranked_posts
WHERE rn = 1;

-- For each post, fetch the number of related posts from post_links.

select p.title as post, pl.post_id, count(pl.related_post_id) as related_count
from posts p
join post_links pl on p.id = pl.post_id
group by p.id, p.title, pl.post_id ;

-- Rank posts based on their score within each post_tag_id.

select *,
  dense_rank() over (partition by(post_tag_id) order by score)
from posts;

-- Calculate the running total of badges earned by users in chronological order.

select  user_id, date, name,
count(*) over(partition by user_id order by date) as running_total_badges
from badges;

-- Find out the date for each user on which their total badges went over 1.

with badge_rank as (

select user_id, date, 
row_number() over (partition by user_id order by date) as badge_num
from badges

)

select user_id, date
from badge_rank
where badge_num = 2;

-- Create a CTE to calculate the average score of posts by each user and use it to:
-- Show user_ids, display_name, reputation and avg_score for users with an average score above 40.
-- Rank users based on their average post score. Show user_ids, display_name, reputation, avg_score and rank.

with avg_post_score as (

select user_id,avg(score) as avg_score
from posts
group by user_id

)
select u.id as user_id, u.display_name, u.reputation, a.avg_score,
rank() over (order by avg_score desc) as user_rank
from users u
join avg_post_score a on u.id = a.user_id
where a.avg_score > 40 ;