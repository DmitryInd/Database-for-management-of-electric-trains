/*Количество денег, полученных с поездки и количество поездов обслуживающих её*/
with t as (
    SELECT t2.trip_id, SUM(t2.trip_price_amt) as gain
    FROM ticket t1
             INNER JOIN trip t2
                        on t1.trip_id = t2.trip_id
    GROUP BY t2.trip_id
)
SELECT t.trip_id, round(cast(max(t.gain) as numeric), 2) as gain, count(distinct t3.train_id) as Number_of_trains
FROM t
INNER JOIN electric_train_x_trip t3
ON t3.trip_id = t.trip_id
GROUP BY t.trip_id;
/*Загруженность поездки*/
with t as(
    SELECT t1.trip_id, count(t1.ticket_id) as number_of_purchase
    FROM ticket t1
    INNER JOIN trip t2
    ON t1.trip_id = t2.trip_id
    GROUP BY t1.trip_id
)
SELECT t3.trip_id, cast(max(t.number_of_purchase) as float)/count(distinct t3.train_id) as number_of_people_on_train,
       max(t.number_of_purchase) as number_of_people, count(distinct t3.train_id) as number_of_train
FROM t
INNER JOIN electric_train_x_trip t3
ON t.trip_id = t3.trip_id
GROUP BY t3.trip_id;
/*Процент заполнения путей(маршрутов)*/
SELECT t2.route_id,
       CASE
           WHEN max(t1.route_id) is NULL
               THEN 0.00
               ELSE cast(100 * cast(count(t1.train_id) as real)/max(t2.max_train_cnt) as numeric(4, 2))
           END as percent
FROM electric_train t1
RIGHT JOIN route t2
ON t1.route_id = t2.route_id
GROUP BY t2.route_id
ORDER BY t2.route_id DESC;
/*Оборот денег в неделю*/
with RECURSIVE t1 as (
    SELECT 1 as num, (SELECT CAST(DATE(min(purchase_dttm)) as timestamp) FROM ticket) as week_start,
           (SELECT CAST(DATE(min(purchase_dttm)) as timestamp) + INTERVAL '7' DAY  FROM ticket) as week_end
    UNION ALL
    SELECT num + 1, week_start + INTERVAL '7' DAY, week_end + INTERVAL '7' DAY FROM t1
    WHERE week_end < (SELECT max(purchase_dttm) + INTERVAL '7' DAY FROM ticket)
),
t2 as (
    SELECT t1.num, t1.week_start, t1.week_end, x.ticket_id, y.trip_price_amt
    FROM ticket x
    INNER JOIN trip y
    ON y.trip_id = x.trip_id
    RIGHT JOIN t1
    ON x.purchase_dttm >= t1.week_start and x.purchase_dttm < t1.week_end
)
SELECT num, max(week_start) as week_start, max(week_end) as week_end,
       CASE
           WHEN SUM(trip_price_amt) is NULL
                THEN 0
                ELSE SUM(trip_price_amt)
           END as fortune
FROM t2
GROUP BY num
ORDER BY num;
/*Площадь в электричке на человека в промежуток времени*/
with square as (
    SELECT x.train_id,
           CASE
               WHEN sum(r.seat_square_cnt) is NULL
                   THEN 0
                   ELSE sum(r.seat_square_cnt)*sum(r.seat_cnt)/3 + sum(free_square_cnt)
               END as sq
    FROM electric_train x
    LEFT JOIN railcar r
        ON x.train_id = r.train_id
    GROUP BY x.train_id
), t as(
    SELECT t1.trip_id, count(t1.ticket_id) as number_of_purchase
    FROM ticket t1
    INNER JOIN trip t2
    ON t1.trip_id = t2.trip_id
    WHERE DATE(t1.purchase_dttm) > '2018-05-11' and DATE(t1.purchase_dttm) < '2018-08-11' --Тут вводится промежуток вермени
    GROUP BY t1.trip_id
), num as (
    SELECT t3.train_id,
           cast(max(t.number_of_purchase) over(PARTITION BY t3.trip_id) as float)
               / count(t3.train_id) over(PARTITION BY t3.trip_id) as number_of_people_on_train
    FROM t
    INNER JOIN electric_train_x_trip t3
    ON t.trip_id = t3.trip_id
)
SELECT x.train_id,
    CASE
        WHEN SUM(y.number_of_people_on_train) is NULL
            THEN 0 --Выводится ноль, если на электричку никто не покупал билет
            ELSE max(x.sq)/SUM(y.number_of_people_on_train)
        END as square_on_person
FROM square x
LEFT JOIN num y
ON x.train_id = y.train_id
GROUP BY x.train_id
ORDER BY x.train_id DESC;