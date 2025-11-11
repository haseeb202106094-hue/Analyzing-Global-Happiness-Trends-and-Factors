select * from happiness_data limit(25)

--Q1. What are the top 10 happiest countries based on the Happiness Score?
select country, year,  happiness_score
from happiness_data
where year = (select max(year) from happiness_data)
order by happiness_score desc
limit 10

--Q2. Which countries have the highest GDP per capita and how does it correlate with Happiness Score?

select country, year, gdp, happiness_score
from happiness_data
where year = (select max(year) from happiness_data)
order by gdp desc
limit 10

--finding correlation 

SELECT 
    ROUND(cast(CORR(gdp, happiness_score) as numeric), 3) AS gdp_happiness_corr
FROM happiness_data
WHERE year = (SELECT MAX(year) FROM happiness_data)
GROUP BY year

--Q3. Compare the average happiness score by region or continent.

select region, 
       round(cast(avg(happiness_score) as numeric), 3) as avg_happiness
from happiness_data
group by region
order by avg_happiness desc


--Q4. Is there a significant difference in average life expectancy between countries with above-average vs below-average happiness scores?

select
      case 
	      when happiness_score >= (select avg(happiness_score) from happiness_data)
		  then 'Above Average Happiness'
		  ELSE 'Below Average Happiness'
		  end as happiness_group,
	round(cast(avg(life_expectancy) as numeric), 3) as avg_life_expectancy
from happiness_data
group by happiness_group



--Q5. Which factors (GDP, social support, freedom, corruption, generosity) have the strongest correlation with happiness?


select 
     round(cast(corr(gdp, happiness_score) as numeric), 3) as gdp_happiness_corr,
	 round(cast(corr(social_support, happiness_score) as numeric), 3) as soical_happiness_corr,
     round(cast(corr(freedom, happiness_score) as numeric), 3) as freedom_happiness_corr,
	 round(cast(corr(corruption, happiness_score) as numeric), 3) as corruption_happiness_corr,
	 round(cast(corr(generosity, happiness_score) as numeric), 3) as generosity_happiness_corr
from happiness_data;


--Q6. Identify the top 5 countries that improved their happiness score the most compared to the previous year.

select 
      h1.country,
	  h1.year, 
	  h1.happiness_score - h2.happiness_score as score_increase
from happiness_data h1
join happiness_data h2
   on h1.country = h2.country
   and h1.year = h2.year + 1
order by score_increase desc
limit 5

--Q7. What is the average happiness score by income group (e.g., low, middle, high income nations)?

select  income_group,
       round(cast(avg(happiness_score) as numeric), 3) as avg_happiness_score
from happiness_data
group by income_group

--Q8. How does social support vary among the top 10 and bottom 10 happiest countries?
WITH latest_year AS (
    SELECT MAX(year) as current_year FROM happiness_data
),
ranked_countries AS (
    SELECT 
        country,
        year,
        happiness_score,
        social_support,
        ROW_NUMBER() OVER (ORDER BY happiness_score DESC) as rank_desc,
        ROW_NUMBER() OVER (ORDER BY happiness_score ASC) as rank_asc,
        (SELECT COUNT(*) FROM happiness_data WHERE year = (SELECT current_year FROM latest_year)) as total_countries
    FROM happiness_data
    WHERE year = (SELECT current_year FROM latest_year)
)
SELECT 
    country,
    year,
    happiness_score,
    social_support,
    CASE 
        WHEN rank_desc <= 10 THEN 'Top 10'
        WHEN rank_asc <= 10 THEN 'Bottom 10'
    END as category
FROM ranked_countries
WHERE rank_desc <= 10 OR rank_asc <= 10
ORDER BY 
    CASE WHEN rank_desc <= 10 THEN 1 ELSE 2 END,
    happiness_score DESC;


--Q9. Which region shows the widest gap between GDP per capita and Happiness Score rankings

with ranked as(
             select country,
			        region,
					rank() over (order by gdp desc) as gdp_rank,
					rank() over (order by happiness_score desc) as happy_rank
			from happiness_data
)
select  
      region,
	  avg(abs(gdp_rank-happy_rank)) as avg_gap
from ranked
group by region
order by avg_gap desc
limit 1

--Q10. Are freedom and perception of corruption inversely related across all countries?

select 
       case
            when round(cast(corr(freedom, corruption) as numeric), 3) <= 0
		    then 'Negative_relation'
		    else 'positive_relation'
		end as correlation_result
from happiness_data



		