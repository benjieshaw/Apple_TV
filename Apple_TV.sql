--Retrieve all movie titles--
SELECT title FROM apple_tv_data
WHERE type = 'movie';

--Find movies released after 2000--
SELECT title, releaseyear FROM apple_tv_data
WHERE type = 'movie' AND releaseyear > 2000
ORDER BY releaseyear, title;

--List unique genres--
SELECT DISTINCT TRIM(unnest(string_to_array(genres, ','))) AS genre FROM apple_tv_data
WHERE genres IS NOT NULL;

--Count how many items are classified as 'movie' and 'series'.
SELECT type, COUNT(*) FROM apple_tv_data
	WHERE type IN('movie', 'series')
	GROUP BY type;

--What movie has the highest average IMDB rating?
SELECT title, imdbaveragerating FROM apple_tv_data
	WHERE imdbaveragerating = (SELECT MAX(imdbaveragerating) FROM apple_tv_data);

--Select movies and their genres that have an average IMDB rating above 8
SELECT title, genres, imdbaveragerating FROM apple_tv_data
	WHERE imdbaveragerating > 8;

--Write a query to count the number of movies released in each decade
SELECT FLOOR(releaseyear / 10) * 10 AS decade,
	COUNT(*) AS movie_count FROM apple_tv_data
	WHERE type = 'movie' AND releaseyear IS NOT NULL
	GROUP BY decade
	ORDER BY decade;

--Write a query to select the title, releaseYear, and imdbNumVotes of the movie with the highest imdbNumVotes.
SELECT title, releaseyear, imdbnumvotes FROM apple_tv_data
	WHERE imdbnumvotes = (SELECT MAX(imdbnumvotes) FROM apple_tv_data);

--Write a query to select titles of movies available in more than one country.
SELECT title FROM apple_tv_data
	WHERE LENGTH(availablecountries) > 2;

--Write a query to find the average IMDb rating of movies for each genre.
WITH SplitGenres AS (SELECT unnest(string_to_array(genres, ',')) AS genre, imdbaveragerating
	FROM apple_tv_data
	WHERE imdbaveragerating IS NOT NULL)
SELECT genre, ROUND(AVG(imdbaveragerating), 2) AS avg_rating
	FROM SplitGenres
	GROUP BY genre
	ORDER BY avg_rating DESC;

--Write a query to list the top 5 countries with the most available movies, 
--along with the number of movies available in each.
WITH unnest_countries AS (SELECT TRIM(unnest(string_to_array(availablecountries, ','))) AS country
	FROM apple_tv_data)
SELECT country, COUNT(country) AS total_movies FROM unnest_countries
	GROUP BY country
	ORDER BY total_movies DESC
	LIMIT 5;

--Write a query to select the highest-rated movie title and rating for each genre.
WITH split_genres AS (
	SELECT UNNEST(string_to_array(genres, ',')) AS genre, title, imdbaveragerating FROM apple_tv_data)

SELECT title, genre, imdbaveragerating FROM split_genres
	WHERE imdbaveragerating = (SELECT MAX(imdbaveragerating) FROM split_genres AS sg
		WHERE sg.genre = split_genres.genre)
	ORDER BY imdbaveragerating DESC;

--Write a query to find titles of movies with an IMDb rating above 8 but with fewer than 10,000 votes.
SELECT title FROM apple_tv_data
	WHERE imdbaveragerating > 8 AND imdbnumvotes < 10000
	ORDER BY title;

--Write a query to determine which genre had the most movie releases in each decade.
WITH decades AS(SELECT FLOOR(releaseyear / 10) * 10 AS decade, genres FROM apple_tv_data),
	split_genre AS (SELECT TRIM(UNNEST(string_to_array(genres, ','))) AS genre, 
	FLOOR(releaseyear / 10) * 10 AS decade FROM apple_tv_data)

SELECT decade, genre, COUNT(*) AS movie_count
	FROM split_genre
	GROUP BY decade, genre
	ORDER BY decade, movie_count DESC;

--Write a query to find titles of movies that are available in both the US and the UK.
SELECT title
FROM apple_tv_data
WHERE 
    type = 'movie' 
    AND TRIM(availableCountries) LIKE '%US%'
    AND TRIM(availableCountries) LIKE '%UK%';
