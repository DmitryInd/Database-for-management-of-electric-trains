CREATE VIEW route_v AS
SELECT track_length_cnt, max_train_cnt
FROM route;

SELECT *
FROM route_v;

CREATE VIEW electric_train_v AS
SELECT standard_plus_flg, avg_speed_cnt
FROM electric_train;

SELECT *
FROM electric_train_v;

CREATE VIEW railcar_v AS
SELECT heating_flg, free_square_cnt, seat_cnt, seat_square_cnt
FROM railcar;

SELECT *
FROM railcar_v;

CREATE VIEW station_v AS
SELECT station_nm, way_cnt, traffic_flow_cnt, address_txt, repair_dt
FROM station;

SELECT *
FROM station_v;

CREATE VIEW trip_v AS
SELECT departure_type_cd, trip_price_amt, sale_flg
FROM trip;

SELECT *
FROM trip_v;

CREATE VIEW ticket_v AS
SELECT buyer_first_nm, buyer_second_nm, purchase_dttm
FROM ticket;

SELECT *
FROM ticket_v;

CREATE VIEW trip_x_station_v AS
SELECT departure_flg
FROM trip_x_station;

SELECT *
FROM trip_x_station_v;

CREATE VIEW train_timetable_v AS
SELECT arrival_dttm, departure_dttm, way_num
FROM train_timetable;

SELECT *
FROM train_timetable_v;