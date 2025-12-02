use mario_kart_8_world_records;

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

-- Rainbow_Entries_AVG = 95.4000
-- Non_Rainbow_Entries_AVG = 69.9778
-- Findings: I am not suprised by my findings of which support my hypothosis. Because of the complication of these tracks there is more world record changes
-- Perhaps in practice simply the fact that these tracks are long mean that they have more distance to find shortcuts

-- Query 8
-- Many tracks have been ported over for foreing systems for example the WII. These tracks were made when the systems were simpler with easier-to-understand mechanics
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

-- system_based_entries = 67.000
-- switch_specific_based_entries = 71.3158
-- Findings: Overall these entries are less striking than the previous query though still support my hypothosis somewhat.
-- About 4 more changes on average for native tracks.
-- This could point to foriegn tracks being slighly more simple (as they are older tracks) and/or because they are older some of the secrets have already been found out.

-- Query 9 
-- Tour track are super intersting as they are long and complicated tacks meant to take place in a cities
-- A key feature that is essential is understanding which characters are used on these types of maps. 
-- The most important classification for characters is the weight catagory split between light, medium, and heavy
-- For this I will joing the world record table, track able, and character table to find the most frequently used weight class based on all of the Tour maps
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

-- Light = 107, heavy = 134, Medium = 349  
-- Findings: Ok not what I expected. The dependence on mediums could indicate that the tour maps are more balanced that initially thought. 
-- Perhaps the tracks are long but not simply straight line type tracks. Insetead, they are dynamic with a mix between speed and turning ability. 
-- These conditins would favor mediums as they are seen as the more balanced class. 