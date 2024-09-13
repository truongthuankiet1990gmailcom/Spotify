use Top_Song_73_Countries
go


CREATE FUNCTION dbo.SplitString (
    @string NVARCHAR(MAX),
    @delimiter CHAR(1)
)
RETURNS @output TABLE (
    ID INT IDENTITY(1,1),
    splitdata NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @start INT, @end INT;
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string);
    WHILE @start < LEN(@string) + 1
    BEGIN
        IF @end = 0 
            SET @end = LEN(@string) + 1;

        INSERT INTO @output (splitdata)
        VALUES(SUBSTRING(@string, @start, @end - @start));

        SET @start = @end + 1;
        SET @end = CHARINDEX(@delimiter, @string, @start);
    END
    RETURN;
END;
GO

CREATE TABLE spotify_artist(
    spotify_id NVARCHAR(MAX),
    artist_1 NVARCHAR(MAX),
    artist_2 NVARCHAR(MAX),
    artist_3 NVARCHAR(MAX),
    artist_4 NVARCHAR(MAX),
    artist_5 NVARCHAR(MAX),
    artist_6 NVARCHAR(MAX),
    artist_7 NVARCHAR(MAX),
    artist_8 NVARCHAR(MAX)
);

-- Insert into spotify_artist table, including rows with NULL artist values
INSERT INTO spotify_artist (
    spotify_id, artist_1, artist_2, artist_3, artist_4, artist_5, artist_6, artist_7, artist_8
)
SELECT 
    spotify_id,
    MAX(CASE WHEN ID = 1 THEN splitdata END) AS artist_1,
    MAX(CASE WHEN ID = 2 THEN splitdata END) AS artist_2,
    MAX(CASE WHEN ID = 3 THEN splitdata END) AS artist_3,
    MAX(CASE WHEN ID = 4 THEN splitdata END) AS artist_4,
    MAX(CASE WHEN ID = 5 THEN splitdata END) AS artist_5,
    MAX(CASE WHEN ID = 6 THEN splitdata END) AS artist_6,
    MAX(CASE WHEN ID = 7 THEN splitdata END) AS artist_7,
    MAX(CASE WHEN ID = 8 THEN splitdata END) AS artist_8

FROM 
(
    SELECT spotify_id, splitdata, ROW_NUMBER() OVER(PARTITION BY spotify_id ORDER BY ID) AS ID
    FROM 
        dbo.universal_top_spotify_songs
    CROSS APPLY dbo.SplitString(artists, ', ')
    WHERE artists IS NOT NULL
) AS Splitted
GROUP BY spotify_id;

-- Insert rows with NULL artist values directly
INSERT INTO spotify_artist (spotify_id, artist_1)
SELECT spotify_id, NULL
FROM dbo.universal_top_spotify_songs
WHERE artists IS NULL;

-- Select from spotify_artist table
SELECT * FROM spotify_artist ORDER BY spotify_id asc;

CREATE TABLE spotify_artist_new (
    spotify_id NVARCHAR(MAX),
    artist NVARCHAR(MAX)
);
GO

-- Insert data into the new table
INSERT INTO spotify_artist_new (spotify_id, artist)
SELECT spotify_id, artist_1 AS artist FROM spotify_artist WHERE artist_1 IS NOT NULL
UNION
SELECT spotify_id, artist_2 AS artist FROM spotify_artist WHERE artist_2 IS NOT NULL
UNION
SELECT spotify_id, artist_3 AS artist FROM spotify_artist WHERE artist_3 IS NOT NULL
UNION
SELECT spotify_id, artist_4 AS artist FROM spotify_artist WHERE artist_4 IS NOT NULL
UNION
SELECT spotify_id, artist_5 AS artist FROM spotify_artist WHERE artist_5 IS NOT NULL
UNION
SELECT spotify_id, artist_6 AS artist FROM spotify_artist WHERE artist_6 IS NOT NULL
UNION
SELECT spotify_id, artist_7 AS artist FROM spotify_artist WHERE artist_7 IS NOT NULL
UNION
SELECT spotify_id, artist_8 AS artist FROM spotify_artist WHERE artist_8 IS NOT NULL
;

-- Select from the new table to verify the results
SELECT * FROM spotify_artist_new;


-- 
ALTER TABLE dbo.universal_top_spotify_songs
ADD album_release_day INT,
    album_release_month INT,
    album_release_year INT;
GO

UPDATE dbo.universal_top_spotify_songs
SET album_release_day = DAY(album_release_date),
    album_release_month = MONTH(album_release_date),
    album_release_year = YEAR(album_release_date);
GO

select * from dbo.universal_top_spotify_songs
where name = 'Beautiful Things'

SELECT distinct album_release_day, album_release_month, album_release_year
FROM dbo.universal_top_spotify_songs;
GO

