insert into ticket(trip_id, buyer_first_nm, buyer_second_nm, purchase_dttm) values (3, 'Dmitry', 'Liverpool', now()::timestamp);
SELECT ticket_id, trip_id, buyer_first_nm, buyer_second_nm, purchase_dttm
FROM ticket
WHERE ticket_id = 93;
UPDATE ticket SET (trip_id, buyer_second_nm) = (5, 'Indenbom') WHERE ticket_id = 93;
DELETE FROM ticket WHERE ticket_id = 93;

insert into station(station_nm, way_cnt, traffic_flow_cnt, address_txt, repair_dt) values ('Socialism', 4, 400, 'Comunism', now()::timestamp);
SELECT station_id, station_nm, way_cnt, traffic_flow_cnt, address_txt, repair_dt
FROM station
WHERE station_id = 13;
UPDATE station SET (station_nm, address_txt, repair_dt) = ('Romashkovo', 'Capitalism', DATE(now()::timestamp + INTERVAL '10' YEAR)) WHERE station_id = 13;
DELETE FROM station WHERE station_id = 13;