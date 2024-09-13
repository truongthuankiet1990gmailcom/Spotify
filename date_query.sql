USE Top_Song_73_Countries;
GO

-- Create the dbo.date table
CREATE TABLE dbo.date (
	date INT,
	month INT,
	year INT
);

-- Insert values into dbo.date
INSERT INTO dbo.date (date, month, year)
SELECT DAY(album_release_date), MONTH(album_release_date), YEAR(album_release_date)
FROM dbo.universal_top_spotify_songs;

select * from dbo.date