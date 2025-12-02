use mario_kart_8_world_records;
SHOW tables;
SELECT * FROM wr_150cc;

-- QUERY 7
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


-- Query 8

SELECT
	AVG(entry_count) AS system_based_entries
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
	AVG(entry_count) AS switch_specific_based_entries
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

