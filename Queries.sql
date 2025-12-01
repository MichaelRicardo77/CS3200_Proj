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

