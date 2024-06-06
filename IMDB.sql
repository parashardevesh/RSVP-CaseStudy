USE imdb;

/* 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
*/

-- Finding total number of rows in each table of the schema

WITH row_count AS
(
	SELECT 
		'director_mapping' AS table_name, 
		COUNT(*) AS total_rows 
	FROM 
		director_mapping
	UNION
	SELECT 
		'genre' AS table_name, 
		COUNT(*) AS total_rows 
	FROM 
		genre
	UNION
	SELECT 
		'movie' AS table_name, 
		COUNT(*) AS total_rows 
	FROM 
		movie
	UNION
	SELECT 
		'names' AS table_name, 
		COUNT(*) AS total_rows 
	FROM 
		names
	UNION
	SELECT 
		'ratings' AS table_name, 
		COUNT(*) AS total_rows 
	FROM 
		ratings
	UNION
	SELECT 
		'role_mapping' AS table_name,
		COUNT(*) AS total_rows 
	FROM 
		role_mapping
)
SELECT * 
FROM 
	row_count 
ORDER BY 
	total_rows DESC;
-- We have a total of 7997 unique movies in our dataset.


-- Let's also check how many columns have null values in movie table.

With null_counts AS
(
	SELECT
		'id' AS column_name, COUNT(*) AS null_count
	FROM 
		movie
	WHERE id IS NULL
	UNION
	SELECT
		'title' AS column_name, COUNT(*) AS null_count
	FROM 
		movie
	WHERE title IS NULL
	UNION
	SELECT
		'year' AS column_name, COUNT(*) AS null_count
	FROM 
		movie
	WHERE year IS NULL
	UNION
	SELECT
		'date_published' AS column_name, COUNT(*) AS null_count
	FROM 
		movie
	WHERE date_published IS NULL
	UNION
	SELECT
		'duration' AS column_name, COUNT(*) AS null_count
	FROM 
		movie
	WHERE duration IS NULL
	UNION
	SELECT
		'country' AS column_name, COUNT(*) AS null_count
	FROM 
		movie
	WHERE country IS NULL
	UNION 
	SELECT 
		'worlwide_gross_income' AS column_name, COUNT(*) AS null_count
	FROM
		movie
	WHERE 
		worlwide_gross_income IS NULL
	UNION 
	SELECT 
		'languages' AS column_name, COUNT(*) AS null_count
	FROM 
		movie
	WHERE 
		languages IS NULL
	UNION
	SELECT 'production_company' AS column_name, COUNT(*) AS null_count
	FROM 
		movie
	WHERE 
		production_company IS NULL
)
SELECT 
	column_name AS columns_having_nulls, null_count
FROM 
	null_counts
WHERE 
	null_count > 0
ORDER BY 
	null_count;
/*
There are four columnms with null values in movie table.
1. Country 
2. Languages
3. Prodeuction_company
4. worlwide_gross_income
*/


-- Now, let's check total number of movies released each year.
-- And how does the trend look month wise?

-- 1st part

SELECT Year, COUNT(id) AS number_of_movies
FROM movie
GROUP BY year; 

-- 2nd part

SELECT 
	MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM 
	movie
GROUP BY month_num
ORDER BY month_num;

-- The highest number of movies is produced in the month of March. 


/*
We know USA and India produces huge number of movies each year. 
Lets find the number of movies produced by USA or India for the last year.
*/

-- Finding number of movies that were produced in the USA or India in the year 2019.

SELECT 
    COUNT(id) AS Total_movies_released_in_India_USA_2019
FROM 
    movie
WHERE
	country REGEXP 'India|USA'
    AND year = 2019; 
/* 
USA and India produced more than a thousand movies in the year 2019.
Exploring table Genre would be fun!!

Let’s find out the different genres in the dataset.
*/


-- Let's see how many unique genres are present in our dataset

SELECT 
	DISTINCT genre AS Types_of_genres 
FROM 
	genre; 

/* 
So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. 
*/

-- Let's check which genre had the highest number of movies produced overall.

SELECT 
	genre AS genre_with_highest_movies_produced, 
    COUNT(m.id) AS number_of_movies_produced
FROM 
	genre AS g
INNER JOIN 
	movie AS m
	ON g.movie_id = m.id
GROUP BY 
	genre
ORDER BY 
	COUNT(m.id) DESC
LIMIT 1;

/* 
So, based on the insight from above query, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres.

So, let’s find out the count of movies that belong to only one genre.
*/


-- Now, let's see how many movies belong to only one genre?

WITH movies_with_1_genre AS
(
	SELECT id
	FROM movie AS m
	INNER JOIN genre AS g 
	ON m.id = g.movie_id
	GROUP BY id
    HAVING COUNT(genre) = 1
)
SELECT 
	COUNT(*) AS number_of_movies_with_only_1genre
FROM 
	movies_with_1_genre; 

/* 
There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant.

Now, let's find out the possible duration of RSVP Movies’ next project.
*/


-- Finding Average duration of movies in each genre 
-- (Note: The same movie can belong to multiple genres.)

SELECT 
	genre,
    ROUND(AVG(duration), 2) AS avg_duration
FROM 
	movie AS m
INNER JOIN 
	genre AS g 
	ON m.id = g.movie_id
GROUP BY 
	genre
ORDER BY 
	avg_duration DESC;  


/* 
Now we know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.

Lets find at what rank the genre 'thriller' is on the basis of number of movies.
*/

-- Let's find the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced.

WIth top_genres AS
(
	SELECT 
		genre,
		COUNT(m.id) AS movie_count,
		RANK() OVER (ORDER BY COUNT(m.id) DESC) AS genre_rank
	FROM 
		genre AS g
	INNER JOIN 
		movie AS m
	ON g.movie_id = m.id
	GROUP BY genre
)
SELECT *
FROM top_genres 
WHERE genre = 'Thriller'; 


/*
Thriller movies is in top 3 among all genres in terms of number of movies
Till now we have analysed the movies and genres tables. 

Now let's analyse the ratings table as well.
To start with, lets get the min and max values of different columns in the ratings table
*/

-- Checking minimum and maximum values for each column of the ratings table except the movie_id column

SELECT 
	MIN(avg_rating) AS min_avg_rating, 
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
	MIN(median_rating) AS min_median_rating, 
    MAX(median_rating) AS max_median_rating
FROM ratings;

/* 
So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 

Now, let’s find out the top 10 movies based on average rating.
*/

-- Top 10 movies based on average rating.

With movies_rank AS
(
	SELECT 
		title,
		avg_rating,
		ROW_NUMBER() OVER(ORDER BY avg_rating DESC) AS movie_rank
	FROM 
		movie AS m
	INNER JOIN 
		ratings AS r 
	ON m.id = r.movie_id
)
SELECT *
FROM 
	movies_rank
WHERE movie_rank <= 10;


/* 
So, now that we know the top 10 movies, let's see if character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.
*/ 

-- The ratings table based on the movie counts by median ratings.

SELECT 	
	median_rating,
	COUNT(movie_id) AS movie_count
FROM 
	ratings
GROUP BY 
	median_rating
ORDER BY 
	movie_count DESC;


/*
Movies with a median rating of 7 are highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.
*/

-- Let's find the production house that has produced the most number of hit movies. 
-- Keeping Average rating > 8 to filter for hit movies

WITH hit_movies_rating AS
(
	SELECT 
		production_company,
		COUNT(id) AS movie_count,
		RANK() OVER (ORDER BY COUNT(id) DESC) AS prod_company_rank 
	FROM 
		movie AS m
	INNER JOIN 
		ratings AS r
		ON m.id = r.movie_id 
	WHERE 
		avg_rating > 8 AND production_company IS NOT NULL
	GROUP BY 
		production_company
)
SELECT *  
FROM hit_movies_rating
WHERE prod_company_rank = 1; 

-- Dream Warrior Pictures and National Theatre Live are the two production house with most number of hits.


-- Now, let's check how many movies were released in each genre during March 2017 in the USA had more than 1,000 votes?

SELECT 
	genre, 
	COUNT(id) AS movie_count
FROM 
	movie AS m
INNER JOIN 
	genre AS g
	ON m.id = g.movie_id
INNER JOIN 
	ratings AS r
    ON m.id = r.movie_id
WHERE 
	MONTH(date_published) = 3 
	AND YEAR(date_published) = 2017 
	AND country LIKE '%USA%'
    AND total_votes > 1000 
GROUP BY 
	genre
ORDER BY 
	movie_count DESC;  


/*
Lets try to analyse with a unique problem statement.
Problem Statement:
	Let's find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
*/

-- Making sure movies having more than one genre do not come more than once in our output by assigning only one genre to it in the following cte
-- Using MIN(genre) to select a single genre for movies with multiple genre

WITH primary_genre AS 
(
	SELECT 
		movie_id,
		MIN( genre ) AS primary_genre 
	FROM 
		genre AS g 
	INNER JOIN
		movie AS m
		ON g.movie_id = m.id 
	GROUP BY 	
		movie_id
)
SELECT 
	title,
    avg_rating,
    primary_genre AS genre
FROM 
	movie AS m
INNER JOIN 
	primary_genre AS pg
	ON m.id = pg.movie_id
INNER JOIN 
	ratings AS r
	ON m.id = r.movie_id
WHERE 
	avg_rating > 8 
    AND title LIKE 'The%'
ORDER BY 
	avg_rating; 

/*
We should also try our hand at median rating and check whether the ‘median rating’ column gives any significant insights.
Problem Statement:
	Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
*/

SELECT 
	COUNT(id) AS count_of_movies_with_8_median_rating_2018_2019,
	ROUND((100*COUNT(id) /
    (
		SELECT COUNT(*) AS total_movie_released
		FROM movie 
		WHERE date_published BETWEEN '2018-04-01' AND '2019-04-01')
	),2) AS percentage_of_movies_with_8_median_rating_2018_2019
FROM 
	movie AS m
INNER JOIN 
	ratings AS r
	ON m.id = r.movie_id
WHERE 
	median_rating = 8 
    AND date_published BETWEEN '2018-04-01' AND '2019-04-01';

/*
Checking whether German movies get more votes than Italian movies or not.
We'll do this by finding the total number of votes for both German and Italian movies.
*/

with german_italy_votes AS
(
SELECT 
	SUM(total_votes) AS germanMovies_total_votes,
	( 
		SELECT SUM(total_votes)
        FROM movie as m
        INNER JOIN ratings AS r
        ON m.id = r.movie_id
        WHERE id NOT IN 
						(
						SELECT id 
						FROM movie 
						WHERE country LIKE '%Germany%' AND country LIKE '%Italy%' 
						)
			AND country LIKE '%Italy%' 
        
	) AS italianMovies_total_votes
FROM 
	movie AS m
INNER JOIN 
	ratings AS r
	ON m.id = r.movie_id
WHERE id NOT IN 
	(
    SELECT id 
	FROM movie 
	WHERE country LIKE '%Germany%' AND country LIKE '%Italy%'
    )
    AND country LIKE '%Germany%'
)
SELECT 
	CASE 
		WHEN germanMovies_total_votes > italianMovies_total_votes
			THEN CONCAT('Yes, German movies total votes = ', germanMovies_total_votes, ' > Italian movie total votes = ', italianMovies_total_votes)
		ELSE CONCAT('No, German movies total votes = ', germanMovies_total_votes, ' < Italian movie total votes = ', italianMovies_total_votes)
	END AS germanMovies_have_more_votes_than_italianMovies
FROM german_italy_votes;

-- Answer is Yes


/* 
Now that we have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the names table.
*/
-- Finding number of nulls for each column in names table

SELECT 
	SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls, 
	SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
	SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
	SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM NAMES; 

/*
There are no Null value in the column 'name' which is a good thing.

Now, we know that the director is the most important person in a movie crew. 

Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.
*/

-- Finding top three directors in the top three genres whose movies have an average rating > 8.
-- (The top three genres would have the most number of movies with an average rating > 8.)

-- let's make a cte with top 3 genres first
WITH top_3genres AS 
(
	SELECT 
		genre
	FROM 
		genre AS g
	INNER JOIN 
		movie AS m
		ON g.movie_id = m.id
	INNER JOIN 
		ratings AS r
		ON g.movie_id = r.movie_id
	WHERE avg_rating > 8
	GROUP BY genre 
	ORDER BY COUNT(m.id) DESC
	LIMIT 3
)
SELECT 
	name AS director_name, 
	COUNT(d.movie_id) AS movie_count
FROM 
	director_mapping AS d
INNER JOIN 
	names AS n 
	ON d.name_id = n.id
INNER JOIN 
	movie as m
	ON d.movie_id = m.id
INNER JOIN 
	ratings AS r
	ON m.id = r.movie_id
INNER JOIN 
	genre AS g
	ON g.movie_id = m.id
WHERE 
	avg_rating > 8 
	AND genre IN 
				(
					SELECT genre 
					FROM top_3genres -- making sure only top 3 genres are being considered
                ) 
GROUP BY name
ORDER BY movie_count DESC
LIMIT 3; 

/* 
From above query's output, it's clear that James Mangold can be hired as the director for RSVP's next project.

Now, let’s find out the top two actors.
*/

-- Top two actors whose movies have a median rating >= 8.

WITH top_2actors AS
(
	SELECT 
		name AS actor_name, 
		COUNT(ro.movie_id) AS movie_count,
		ROW_NUMBER() OVER (ORDER BY COUNT(ro.movie_id) DESC) AS rn
	FROM 
		names AS n
	INNER JOIN 
		role_mapping AS ro
		ON n.id = ro.name_id
	INNER JOIN
		movie AS m
		ON m.id = ro.movie_id
	INNER JOIN 
		ratings AS r
		ON ro.movie_id = r.movie_id
	WHERE 
		median_rating >= 8
	GROUP BY 
		actor_name
	ORDER BY 
		movie_count DESC
)
SELECT 
	actor_name, 
	movie_count
FROM top_2actors 
WHERE rn <= 2; 


/* 
So based on median rating >= 8, top 2 acotrs that we found are;
	1. Mammoothy with 8 hits
	2. Mohanlal with 5 hits

Since, RSVP Movies plans to partner with other global production houses. 
Let’s also find out the top three production houses in the world.
*/

-- Top three production houses based on the number of votes received by their movies

WITH top_3prod_company AS
(
	SELECT 
		production_company,
		SUM(total_votes) AS vote_count,
		ROW_NUMBER() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
	FROM 	
		movie AS m
	INNER JOIN 
		ratings AS r
		ON m.id = r.movie_id
	WHERE 
		production_company IS NOT NULL
	GROUP BY 
		production_company
)
SELECT * 
FROM 
	top_3prod_company
WHERE 
	prod_comp_rank <= 3; 

/*
Yes, Marvel Studios rules the movie world.
So, now we know the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 

Let’s find who these actors could be.
*/

-- Let's rank actors with movies released in India based on their average ratings and find the actor who is at the top of the list.
-- Note: The actor should have acted in at least five Indian movies.
-- (We will use the weighted average based on votes. If the ratings clash, then the total number of votes will act as the tie breaker.)

SELECT 
	name AS actor_name,
    SUM(total_votes) AS total_votes,
    COUNT(r.movie_id) AS movie_count,
	ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2)AS actor_avg_rating,
    RANK() OVER(ORDER BY SUM(avg_rating * total_votes) / SUM(total_votes) DESC, SUM(total_votes) DESC) AS actor_rank
FROM 
	names AS n 
INNER JOIN 
	role_mapping AS r
	ON n.id = r.name_id
INNER JOIN 
	movie AS m
    ON r.movie_id = m.id
INNER JOIN 
	ratings AS ra
    ON r.movie_id = ra.movie_id 
WHERE 
	country like '%India%' AND category = 'actor' 
GROUP BY 
	actor_name
HAVING 
	movie_count >= 5; 

-- Top actor is Vijay Sethupathi


/*
Let's also find out the top five actresses in Hindi movies released in India based on their average ratings.
Note: The actresses should have acted in at least three Indian movies. 
( We'll again use the weighted average based on votes. If the ratings clash, then the total number of votes will act as the tie breaker. )
*/

SELECT 
	name AS actress_name,
	SUM(total_votes) AS total_votes, 
    COUNT(r.movie_id) AS movie_count,
    ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actress_avg_rating,
    RANK() OVER(ORDER BY SUM(avg_rating * total_votes) / SUM(total_votes) DESC, SUM(total_votes) DESC) AS actress_rank
FROM 
	names AS n
INNER JOIN
	role_mapping AS r
    ON n.id = r.name_id
INNER JOIN 
	movie AS m
    ON r.movie_id = m.id
INNER JOIN 
	ratings AS ra
    ON r.movie_id = ra.movie_id
WHERE 
	country like '%India%' 
    AND category = 'actress' 
    AND languages LIKE '%Hindi%' 
GROUP BY 
	actress_name
HAVING 
	movie_count >= 3
LIMIT 5;


/* 
Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.

Selecting thriller movies as per avg rating and classifying them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------
*/

SELECT 
    CASE
		WHEN avg_rating > 8 
			THEN 'Superhit movies'
		WHEN avg_rating BETWEEN 7 AND 8
			THEN 'Hit movies'
		WHEN avg_rating BETWEEN 5 AND 7
			THEN 'One-time-watch movies'
		ELSE 
			'Flop movies'
	END AS thrillerCategory,
    COUNT(g.movie_id) AS thrillerCount
FROM 
	genre AS g
INNER JOIN 
	ratings AS r
    ON g.movie_id = r.movie_id
WHERE genre = 'Thriller'
GROUP BY thrillerCategory
ORDER BY thrillerCount; 


/* 
Until now, we have analysed various tables of the data set. 
Now, we will perform some tasks that will give us a broader understanding of the data.
*/

-- Let's find genre-wise running total and moving average of the average movie duration. 

WITH average_duration as 
(
	SELECT 
		genre, 
		ROUND(AVG(duration), 2) AS avg_duration
	FROM 
		movie m
	INNER JOIN 
		genre g 
		ON m.id = g.movie_id
	GROUP BY 
		genre
)
SELECT 
	genre, 
	avg_duration,
	SUM(avg_duration) OVER(ORDER BY avg_duration DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_duration,
    ROUND(AVG(avg_duration) OVER(ORDER BY avg_duration DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS moving_avg_duration
FROM 
	average_duration; 


/*
Now, let us find top 5 movies of each year with top 3 genres.

Finding five highest-grossing movies of each year that belong to the top three genres.
(Note: The top 3 genres would have the most number of movies.)
*/

-- Below cte finds top 3 Genres based on most number of movies
WITH top_3genre AS
(
	SELECT 
		genre
	FROM 
		movie AS m
	INNER JOIN 
		genre AS g
		ON m.id = g.movie_id
	GROUP BY genre
	ORDER BY COUNT(m.id) DESC
	LIMIT 3
), 
-- In the below CTE, making sure movies having more than one genre do not repeat in our output, hence, assigning only one genre to such movies in the following CTE 
-- Using MIN( genre ) to select a single genre for movies with multiple genre
primary_genre AS 
(
	SELECT 
		movie_id, 
        MIN(genre) AS primary_genre
	FROM genre AS g
    INNER JOIN 
		movie AS m 
        ON g.movie_id = m.id
	WHERE genre IN 
				(
                SELECT genre 
				FROM top_3genre -- making sure only top 3 genres are included
                ) 
    GROUP BY 
		movie_id
),
converted_incomes AS 
(
    SELECT *,
        CASE 
            WHEN worlwide_gross_income LIKE '%INR%' 
                THEN CAST(REPLACE(worlwide_gross_income, 'INR', '') AS FLOAT) / 83 -- Converting INR to dollar, assuming Dollar to be at Rs 83.
            ELSE 
                CAST(REPLACE(worlwide_gross_income, '$', '') AS FLOAT) 
        END AS dollar_income
    FROM 
        movie
),
top_5grossing_movies AS
(
	SELECT
		primary_genre AS genre,
		year,
		title AS movie_name,
		worlwide_gross_income,
		ROW_NUMBER() OVER(PARTITION BY year ORDER BY dollar_income DESC) AS movie_rank
	FROM 
		converted_incomes AS c
	INNER JOIN 
		primary_genre AS pg
		ON c.id = pg.movie_id
	WHERE 
		worlwide_gross_income IS NOT NULL
		AND primary_genre IN 
					(
						SELECT genre  -- making sure only top 3 genre are included
						FROM top_3genre
					) 
) 
SELECT 
	genre,
	year,
	movie_name,
    worlwide_gross_income AS worldwide_gross_income,
    movie_rank
FROM 
	top_5grossing_movies
WHERE 
	movie_rank <= 5;  


/*
Finally, let’s find out the top two production houses that have produced the highest number of hits among multilingual movies.
Note: We will calculate hits based on median rating >= 8.
*/

WITH ranked_prod_comp AS
(
	SELECT 
		production_company,
		COUNT(r.movie_id) AS movie_count,
		RANK() OVER(ORDER BY COUNT(r.movie_id) DESC ) AS prod_comp_rank
	FROM 
		movie AS m
	INNER JOIN 
		ratings AS r
		ON m.id = r.movie_id
	WHERE 
		production_company IS NOT NULL 
		AND median_rating>=8 
		AND languages LIKE '%,%'
	GROUP BY 
		production_company
)
SELECT * 
FROM ranked_prod_comp
WHERE prod_comp_rank <=2; 

-- Multilingual is the important piece in the above problem statement. It was created using " languages like '%,%' " logic
-- If there is a comma, that means the movie is of more than one language
-- We have got 'Star Cinema' and 'Twentieth Century Fox' from above query as the top 2 production houses based on above criteria.


-- Let's find the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?

WITH ranked_actress AS
( 
	SELECT 
		name AS actress_name,
		SUM(total_votes) AS total_votes,
		COUNT(ro.movie_id) AS movie_count,
		ROUND(AVG(avg_rating), 2) AS actress_avg_rating,
		ROW_NUMBER() OVER(ORDER BY COUNT(ro.movie_id) DESC, SUM(total_votes) DESC, AVG(avg_rating) DESC) AS actress_rank
	FROM 
		role_mapping AS ro
	INNER JOIN 
		names AS n
		ON ro.name_id = n.id
	INNER JOIN 
		ratings AS r
		ON ro.movie_id = r.movie_id
	INNER JOIN 
		genre AS g
		ON ro.movie_id = g.movie_id
	WHERE 
		category = 'actress' 
		AND avg_rating > 8 
		AND genre = 'Drama'
	GROUP BY 
		actress_name
) 
SELECT * 
FROM ranked_actress 
WHERE actress_rank <=3; 



/* Finding the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations
*/

WITH top_9directors AS
(
	SELECT 
		name, 
		d.name_id AS director_id, 
		COUNT(d.movie_id) AS movie_count
	FROM 
		names AS n
	INNER JOIN 
		director_mapping AS d
		ON n.id = d.name_id
	GROUP BY 
		d.name_id
	ORDER BY 
		movie_count desc
	LIMIT 9
),
director_movies AS
(
	SELECT 
		d.name_id AS director_id,
		name AS director_name,
		COUNT(d.movie_id) AS number_of_movies,
		ROUND(SUM(r.avg_rating * total_votes) / SUM(total_votes), 2) AS avg_rating,
		SUM(total_votes) AS total_votes,
		MIN(r.avg_rating) AS min_rating,
		MAX(r.avg_rating) AS max_rating,
		SUM(duration) AS total_duration
	FROM 
		names AS n
	INNER JOIN 
		director_mapping AS d 
		ON n.id = d.name_id
	INNER JOIN 
		movie AS m
		ON d.movie_id = m.id
	INNER JOIN 
		ratings AS r
		ON d.movie_id = r.movie_id
	WHERE 
		d.name_id IN (SELECT director_id FROM top_9directors) 
	GROUP BY 
		director_id, director_name 
), 
publishDates AS
(
	SELECT 
		d.name_id as director_id, 
		date_published,
		LEAD(date_published) OVER(PARTITION BY d.name_id ORDER BY date_published) AS next_date_publish  
	FROM 
		movie AS m
	INNER JOIN 
		director_mapping AS d
		ON m.id = d.movie_id
	WHERE 
		d.name_id IN (SELECT director_id FROM top_9directors) 
), 
avg_movie_days AS
(
	SELECT 
		director_id,
		ROUND(AVG(DATEDIFF(next_date_publish, date_published))) AS avg_inter_movie_days 
	FROM 
		publishDates
	WHERE 
		next_date_publish IS NOT NULL
	GROUP BY 
		director_id
) 
SELECT 
	director_id,
    director_name,
    number_of_movies,
    avg_inter_movie_days,
    avg_rating,
    total_votes,
    min_rating,
    max_rating,
    total_duration
FROM 
	director_movies AS dm
LEFT JOIN 
	avg_movie_days AS amd
    USING(director_id)
ORDER BY 
	number_of_movies DESC, director_name;  