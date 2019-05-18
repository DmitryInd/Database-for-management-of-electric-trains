CREATE VIEW full_ticket as (
    SELECT y.buyer_first_nm, y.buyer_second_nm, y.purchase_dttm,
           x.trip_price_amt, x.departure_type_cd, x.sale_flg as sale_yet_flg,
           z1.station_nm as station_from_nm, z2.station_nm as station_to_nm
    FROM (
         SELECT t1.trip_id, t1.trip_price_amt, t1.departure_type_cd, t1.sale_flg,
                t2.station_id as station_from_id, t3.station_id as station_to_id
         FROM trip t1
         INNER JOIN trip_x_station t2
         ON t1.trip_id = t2.trip_id and t2.departure_flg = true
         INNER JOIN trip_x_station t3
         ON t3.trip_id = t1.trip_id and t3.departure_flg = false
    ) as x
    INNER JOIN ticket y
    ON x.trip_id = y.trip_id
    INNER JOIN station z1
    ON x.station_from_id = z1.station_id
    INNER JOIN station z2
    ON x.station_to_id = z2.station_id
);

SELECT *
FROM full_ticket;

CREATE VIEW stations_of_route as (
    with main as (
        SELECT dense_rank() over (partition by t1.route_id order by t2.station_id) as route_number_in_view, --Нужно для понимания, какие станции в одном маршруте (можно и без этого)
               t1.route_id,
               max(track_length_cnt)                    as track_length_cnt,
               max(max_train_cnt)                       as max_train_cnt,
               max(station_nm)                          as station_nm,
               max(address_txt)                         as address_txt,
               max(way_cnt)                             as max_on_station_train_cnt
        FROM route t1
                 INNER JOIN (
            SELECT s.station_id, station_nm, address_txt, way_cnt, x.train_id, route_id
            FROM train_timetable x
                     INNER JOIN electric_train y
                                ON x.train_id = y.train_id
                     INNER JOIN station s
                                ON x.station_id = s.station_id
        ) as t2
                            ON t1.route_id = t2.route_id
        GROUP BY t1.route_id, t2.station_id
        ORDER BY t1.route_id
    )
    SELECT     dense_rank() over (order by route_id) as route_number_in_view,
               CASE
                   WHEN route_number_in_view = 1
                       THEN CAST(track_length_cnt as VARCHAR(10))
                       ELSE ''
                   END as track_length_cnt,
               CASE
                   WHEN route_number_in_view = 1
                       THEN CAST(max_train_cnt as VARCHAR(10))
                       ELSE ''
                   END as max_train_cnt,
               station_nm,
               address_txt,
               max_on_station_train_cnt
    FROM main
);

SELECT *
FROM stations_of_route;