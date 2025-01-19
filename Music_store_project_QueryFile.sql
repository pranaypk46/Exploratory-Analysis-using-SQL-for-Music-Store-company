--1) who is the senior most employee based on job title ?
--1st approach 
select * from employee order by levels desc limit 1

-- 2nd approach (for Query optimization)
select employee_id,first_name,last_name,title,levels from employee 
order by levels
desc limit 1

--2) --2) which countries have the most invoices ?

--approch 1
select * from invoice
select count (*) from invoice
select * from invoice_line
select count (*) from invoice_line

select billing_country as Country,count(invoice_id) as Total_Invoice from invoice 
group by Country 
order by Total_Invoice desc
limit 5

--3) what are the top 3 values of total invoice

-- 1st Approach 
select  total as Invoice_Total_Values from invoice 
order by total desc
limit 3 


/* 4) which city has the best customers ? we would like to throw a promotional 
Music Festival in the city we made the most money. write a query that returns
one city that has the highest sum of invoice totals Return both the city names 
& sum of all invoice totals */


-- 1st Approach 

select * from invoice 

select billing_city as City,sum(total) as Total_Invoice
from invoice
group by City 
order by Total_Invoice desc
limit 1
/* 5) who is the best customer ? the customer who spents the most money
will be declared the best customer . write a query that returns the person 
who has spent the most money
*/
--Approach 1

select * from customer 
select * from invoice

select c.customer_id,c.first_name,c.last_name,sum(i.total) as Total_invoices
from invoice i join customer c
on c.customer_id= i.customer_id
group by c.customer_id
order by Total_invoices desc
limit 1; 

/*6)
Write a query to return the email, first name , last name, and genre of 
all rock music listeners. Return your list ordered alphatically 
by email starting with A
*/

select * from track
select * from genre

--Approach 1 

select Distinct customer.email,customer.first_name , customer.last_name 
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id In 
                (
				select track_id from track
				join genre on track.genre_id= genre.genre_id
				where genre.name='Rock'
				 ) 
order by customer.email


--Approach 2 (for query optimization)
select Distinct customer.email,customer.first_name , customer.last_name,
genre.name as Genre_Category
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id =  track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name='Rock'
order by customer.email


/*7)
Let's invite the artists who have written the most rock music 
in our dataset . Write a Query that returns the Artist Name and
total track count of the top 10 rock brands*/

select * from artist
select * from album
select * from track
select * from genre

Approach 1


select artist.name,
count(artist.artist_id) as Number_of_songs from track
join album
on album.album_id=track.album_id
join artist
on artist.artist_id = album.artist_id
join genre 
on track.genre_id= genre.genre_id
where genre.name='Rock'
group by artist.name
order by Number_of_songs desc 
limit 10

 

 

/*8)
Return all the track names that have a song length longer than the
average song length . Return the Name and Milliseconds for each track 
Order by the song length with the longest songs listed first 
*/

--Approach 1
select name as Track_name,milliseconds from track
where milliseconds>(select avg(milliseconds) from track)
order by milliseconds desc


--Approach 2

					   
/*9)
Find how much amount spent by each customer on artists?
write a query to return customer name, artist name and total spent  
*/
--approach 1
with best_selling_artist As (
 select artist.artist_id as artist_id,artist.name as artist_name,
 sum( invoice_line.unit_price * invoice_line.quantity ) as total_sales
 from invoice_line
 join track on track.track_id = invoice_line.track_id
 join album on album.album_id = track.album_id
 join artist on artist.artist_id =album.artist_id
 group by 1
 order by 3 desc
 Limit 1
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price * il.quantity) as Amount_Spent
from customer c
join invoice i 
on i.customer_id= c.customer_id
join invoice_line il 
on il.invoice_id= i.invoice_id
join track t
on t.track_id=il.track_id
join album al
on al.album_id = t.album_id
join best_selling_artist bsa
on bsa.artist_id=al.artist_id
group by 1,2,3,4
order by 5 desc;




/*10)
We Want to find out the most popular music genre for each country .
We Determine the most popular  genre as the genre with the highest 
amount of purchases 
writa a query that returns each country along with the top genre 
for countries where the maximum number of purchases
is shared return all Genres
*/
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1




/*11)
Write a Query that determines the customer that has spent the most 
on music for each country 
write a query that returns the country along with the top customer 
and how much they spent . For countries where the top amount 
spent is shared, provide all customers who spent this amount
*/

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
	




