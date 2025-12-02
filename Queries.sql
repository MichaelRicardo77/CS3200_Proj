USE mario_kart_8_world_records;

-- QUERY 1
-- My favorite kart is the Teddy Buggy (Kart id 38). 
-- I want to see what country has the most world records with this Kart.
SELECT c.country_name, COUNT(*) AS teddy_buggy_wrs
FROM wr_150cc wr
JOIN country AS c ON wr.country_id = c.country_id
WHERE wr.kart_id = 38
GROUP BY c.country_name
ORDER BY teddy_buggy_wrs DESC;
/*
Findings: 
- I'm not surprised that Japan is by far the most common as they have the most World Records overall.
- I am surprised that the US is only 6th with Teddy Buggy, behind unexpected countries like Netherlands and Aus.
*/


-- QUERY 2
-- I want to optimize my mushroom (shroom) usage.
-- I most commonly play players from the United States (id 185) and Canada (id 31)
-- I want to know what shroom pattern is most common in world records from those countries.
SELECT 
    shrooms AS shroom_pattern,
    COUNT(*) AS num_world_records
FROM wr_150cc AS wr
WHERE wr.shrooms IS NOT NULL 
AND wr.shrooms != ''
AND wr.country_id IN (185, 31)
GROUP BY shrooms
ORDER BY num_world_records DESC;
/*
Findings: 
- By far the most common patter is 1.1.1 (1 shroom on each lap). 
- This is not surprising as most tracks have 1 optimal spot to use a mushroom to take a shortcut.
- I am surprised that 0.1.2 is more common than 2.1.0. 
- I am also very surprised that there are world records with 1.0.2 and 2.0.1 as they seem like awkward usages of shrooms.
- I also would have expected some WR's to be set wit 3 shrooms on one lap, but the US has none.
*/


-- QUERY 3
-- I wonder if any players have carried their country's world record contributions.
-- I want to find which players contribute the largest percentage of their country’s WR's
SELECT DISTINCT
    c.country_name,
    p.player_name,
    pr.unique_tracks_wrs AS world_record_held,
    cr.tracks_with_wrs AS country_world_records,
    ROUND((pr.unique_tracks_wrs / cr.tracks_with_wrs) * 100, 2) AS percent_of_country
FROM player_ranking AS pr
JOIN player AS p ON pr.player_id = p.player_id
JOIN country_ranking AS cr ON pr.country_id = cr.country_id
JOIN country AS c ON cr.country_id = c.country_id
ORDER BY percent_of_country DESC
LIMIT 50;
/*
Findings: 
- There are 10 countries where only one player has set world records, leading to a 100% "percent_of_country" score.
- Impressively Norway (Pii) and Belgium (ths) have 21 and 14 WR's while the rest of these countries achieved 100% but only have 3 or less WR's.
- Alberto holds 67 of Spain's 72 world records. I actually have heard of Alberto before. It is cool to see that our data backs up his reputation.
- For countries with >10 WR's, Japan has the greatest duo with K4I (46.24%) and しらぬい (36.56%) contributing over 82% of Japan's WR's.
- Also interestingly, the UK has a trio of similar contributions with Xander (36.11%), vxlocity (30.56%), and Shaun (25%) making up over 91% of the UK's WR's.
*/


-- Query 4
-- When I see skilled players play online, I notice that some characters like Yoshi
-- and Waluigi dominate the meta because of their stats. I’d like to see which characters 
-- concretely have the most world records.
SELECT 
	CASE 
        WHEN character_name LIKE '%Yoshi%' THEN 'Yoshi (All Variants)'
        WHEN character_name LIKE '%Birdo%' THEN 'Birdo (All Variants)'
        WHEN character_name LIKE '%Shy Guy%' THEN 'Shy Guy (All Variants)'
        ELSE character_name
    END AS character_group,
    MAX(weight_class) AS weight_class,
	SUM(CASE WHEN w.track_id IS NOT NULL THEN 1 ELSE 0 END) AS total_wrs,
	COUNT(DISTINCT track_id) AS unique_tracks
FROM `character` AS c
LEFT JOIN wr_150cc AS w ON w.character_id = c.character_id
GROUP BY character_group
ORDER BY total_wrs DESC
LIMIT 100;
/*
Findings:
- When accounting for all of the Yoshi Variants, Yoshi has set almost double the world records as
  any other character.
- The top 10 record setting characters are all heavy except Yoshi (Medium), Baby Daisy (Light), 
  and Baby Peach (Light). With how dominant Yoshi is in the meta, I'm surprised he's the only
  Medium weight character and by far the most meta.
- Several characters have never set a world record including Toad, Ludwig, and Toadette.
- Mario only has one world record in his own game no less.
*/


-- Query 5
-- I wanted to see which tracks had highest amounts of world record turn over. I'd love to see
-- the tracks that have the most records set as well as the average amount of time that each record
-- remains at the top of the leaderboard. 
SELECT 
    track_name,
    COUNT(*) AS total_records_set,
    AVG(duration_days) AS avg_days_at_top,
    MIN(date_set) AS first_record_date,
    DATEDIFF('2025-11-23', MIN(date_set)) AS total_days_competed
FROM wr_150cc AS w
JOIN track AS t ON w.track_id = t.track_id
GROUP BY track_name
ORDER BY total_records_set DESC
LIMIT 100;
/*
Findings:
- The amount of records set on a course tends to correlate with the amount of time that the course
  has been in the game.
- The courses with more records have fewer average days where the records last even though most
  have been around since the game came out.
*/


-- Query 6
-- I want to see the overall percentage of the time that certain characters, karts, wheels, and gliders
-- are used to set world records.
SELECT 
    char_stats.ranking,
    char_stats.character_group,
    char_stats.char_usage_pct,
    kart_stats.kart_name,
    kart_stats.kart_usage_pct,
    wheel_stats.wheel_name,
    wheel_stats.wheel_usage_pct,
    glider_stats.glider_name,
    glider_stats.glider_usage_pct
FROM (
    -- Character rankings
    SELECT 
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS ranking,
        CASE 
            WHEN c.character_name LIKE '%Yoshi%' THEN 'Yoshi (All Variants)'
            WHEN c.character_name LIKE '%Birdo%' THEN 'Birdo (All Variants)'
            WHEN c.character_name LIKE '%Shy Guy%' THEN 'Shy Guy (All Variants)'
            ELSE c.character_name
        END AS character_group,
        COUNT(*) AS times_used,
        ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM wr_150cc)), 2) AS char_usage_pct
    FROM wr_150cc AS wr
    JOIN `character` AS c ON wr.character_id = c.character_id
    GROUP BY character_group
) AS char_stats
LEFT JOIN (
    -- Vehicle rankings
    SELECT 
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS ranking,
        k.kart_name,
        COUNT(*) AS times_used,
        ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM wr_150cc)), 2) AS kart_usage_pct
    FROM wr_150cc AS wr
    JOIN kart AS k ON wr.kart_id = k.kart_id
    GROUP BY k.kart_name
) AS kart_stats ON char_stats.ranking = kart_stats.ranking
LEFT JOIN (
    -- Wheel rankings
    SELECT 
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS ranking,
        w.wheel_name,
        COUNT(*) AS times_used,
        ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM wr_150cc)), 2) AS wheel_usage_pct
    FROM wr_150cc AS wr
    JOIN wheel AS w ON wr.wheel_id = w.wheel_id
    GROUP BY w.wheel_name
) AS wheel_stats ON char_stats.ranking = wheel_stats.ranking
LEFT JOIN (
    -- Glider rankings
    SELECT 
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS ranking,
        g.glider_name,
        COUNT(*) AS times_used,
        ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM wr_150cc)), 2) AS glider_usage_pct
    FROM wr_150cc AS wr
    JOIN glider AS g ON wr.glider_id = g.glider_id
    GROUP BY g.glider_name
) AS glider_stats ON char_stats.ranking = glider_stats.ranking
ORDER BY char_stats.ranking;
/*
Findings:
- As expected, there's disproportionate representations within the all categories, with a couple
  selections making up the majority of overall usage in the competitive scene.
- The Paper Glider, Azure Roller, and Biddybuggy are all used in over 45 percent of all records.
*/


-- QUERY 7
-- Rainbow road tracks are super advanced and long, i am wondering if this complication leads to more world record changes 
-- Since Rainbow road tracks are so complicated ther is more room to find changes and new wolrd records
-- I want to find the mean of the num of world record entries (indicating world record changes) for all of the maps and then compare it with mean world record entries for rainbow road
-- Below is an analsyis into this hypothosis by joining the world record table with the track table and doing a keryword search
SELECT
	AVG(entry_count) AS Rainbow_Entries_AVG
FROM (
    SELECT
        t.track_id,
        t.track_name,
        COUNT(w.wr150_id) AS entry_count
    FROM track AS t
    JOIN wr_150cc AS w ON t.track_id = w.track_id
    WHERE t.track_name LIKE '%Rainbow%'
    GROUP BY t.track_id, t.track_name
) AS rainbow_counts;
SELECT
	AVG(entry_count) AS Non_Rainbow_Entries_AVG
FROM (
    SELECT
        t.track_id,
        t.track_name,
        COUNT(w.wr150_id) AS entry_count
    FROM track AS t
    JOIN wr_150cc AS w ON t.track_id = w.track_id
    WHERE t.track_name NOT LIKE '%Rainbow%'
    GROUP BY t.track_id, t.track_name
) AS non_rainbow_counts;
/*
 Rainbow_Entries_AVG = 95.4000
 Non_Rainbow_Entries_AVG = 69.9778
 Findings: I am not suprised by my findings of which support my hypothosis. Because of the complication of these tracks there is more world record changes
 Perhaps in practice simply the fact that these tracks are long mean that they have more distance to find shortcuts
*/ 

-- Query 8
-- Many tracks have been ported over for foreign systems for example the WII. These tracks were made when the systems were simpler with easier-to-understand mechanics
-- With these facts in mind I hypothosize that there would be less entries for world records as simpler courses who are already known will have less to uncover 
-- Below is an analsyis into this hypothosis by joining the world record table with the track table and doing a keryword search
-- After this I will find the mean average of native and foreign tracks
SELECT
	AVG(entry_count) AS foreign_entries
FROM (
    SELECT
        t.track_id,
        t.track_name,
        COUNT(w.wr150_id) AS entry_count
    FROM track AS t
    JOIN wr_150cc AS w ON t.track_id = w.track_id
    WHERE t.track_name LIKE 'Wii %' OR t.track_name LIKE 'SNES %' OR t.track_name LIKE 'N64 %' OR t.track_name LIKE 'GBA %' 
    OR t.track_name LIKE '3DS %' OR t.track_name LIKE 'GCN %' OR t.track_name LIKE 'DS %'
	GROUP BY t.track_id, t.track_name
) AS system_based_entries;
SELECT
	AVG(entry_count) AS native_entries
FROM (
    SELECT
        t.track_id,
        t.track_name,
        COUNT(w.wr150_id) AS entry_count
    FROM track AS t
    JOIN wr_150cc AS w ON t.track_id = w.track_id
    WHERE t.track_name NOT LIKE 'Wii %' OR t.track_name NOT LIKE 'SNES %' OR t.track_name NOT LIKE 'N64 %' OR t.track_name NOT LIKE 'GBA %' 
    OR t.track_name NOT LIKE '3DS %' OR t.track_name NOT LIKE 'GCN %' OR t.track_name NOT LIKE 'DS %'
	GROUP BY t.track_id, t.track_name
) AS switch_specific_based_entries;
/*
system_based_entries = 67.000
switch_specific_based_entries = 71.3158
Findings: Overall these entries are less striking than the previous query though still support my hypothosis somewhat.
About 4 more changes on average for native tracks.
This could point to foriegn tracks being slighly more simple (as they are older tracks) and/or because they are older some of the secrets have already been found out.
*/ 
-- Query 9 
-- Tour tracks are super intersting as they are long and complicated tracks meant to take place in cities.
-- A key feature that is essential is understanding which characters are used on these types of maps. 
-- The most important classification for characters is the weight catagory split between light, medium, and heavy
-- For this I will joining the world record table, track table, and character table to find the most frequently used weight class based on all of the tour maps.
-- So in practice picking the maps that start with Tour, indicating they are part of the tour series.
-- I hypothosize that heavy will be the most popular as these are long courses and speed is the best trait of heavies 
SELECT
    c.weight_class,
    COUNT(*) AS weight_class_entries
FROM wr_150cc AS w
JOIN track AS t ON w.track_id = t.track_id
JOIN `character` AS c ON w.character_id = c.character_id
WHERE t.track_name LIKE 'Tour%'
GROUP BY c.weight_class;
/*
Light = 107, heavy = 134, Medium = 349  
Findings: Ok not what I expected. The dependence on mediums could indicate that the tour maps are more balanced than initially thought. 
Perhaps the tracks are long but not simply straight line type tracks. Insetead, they are dynamic with a mix between speed and turning ability. 
These conditins would favor mediums as they are seen as the more balanced class.
*/
