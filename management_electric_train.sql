create database management_electric_trains;

set search_path to public;

create table ROUTE(
    route_id SERIAL PRIMARY KEY,
    track_length_cnt REAL CHECK (track_length_cnt > 0),
    max_train_cnt INTEGER CHECK (max_train_cnt >= 0)
);

create table ELECTRIC_TRAIN(
  train_id SERIAL PRIMARY KEY,
  route_id SERIAL REFERENCES route(route_id),
  standard_plus_flg BOOLEAN NOT NULL,
  avg_speed_cnt REAL CHECK (avg_speed_cnt > 0)
);

create table RAILCAR(
  railcar_id SERIAL PRIMARY KEY,
  train_id SERIAL REFERENCES ELECTRIC_TRAIN(train_id),
  heating_flg BOOLEAN NOT NULL,
  free_square_cnt REAL CHECK (free_square_cnt > 0),
  seat_cnt INTEGER CHECK (seat_cnt > 0),
  seat_square_cnt REAL CHECK (seat_square_cnt > 0)
);

create table STATION(
  station_id SERIAL PRIMARY KEY,
  station_nm VARCHAR(63) NOT NULL,
  way_cnt INTEGER DEFAULT 0, CHECK (way_cnt >= 0),
  traffic_flow_cnt INTEGER DEFAULT 0, CHECK (traffic_flow_cnt >= 0),
  address_txt VARCHAR(511) NOT NULL,
  repair_dt DATE NOT NULL
);

create table TRAIN_TIMETABLE(
  train_timetable_id SERIAL PRIMARY KEY,
  station_id SERIAL REFERENCES STATION(station_id),
  train_id SERIAl REFERENCES ELECTRIC_TRAIN(train_id),
  arrival_dttm TIMESTAMP(0) NOT NULL,
  departure_dttm TIMESTAMP(0) NOT NULL,
  way_num INTEGER CHECK (way_num >= 0)
);

create table TRIP(
  trip_id SERIAL PRIMARY KEY,
  departure_type_cd VARCHAR(3) CHECK (departure_type_cd IN ('USU', 'EXP', 'AIR')),
  trip_price_amt REAL CHECK (trip_id >= 0),
  sale_flg BOOLEAN NOT NULL
);

create table TICKET(
  ticket_id SERIAL PRIMARY KEY,
  trip_id SERIAL REFERENCES TRIP(trip_id),
  buyer_first_nm VARCHAR(31) NOT NULL,
  buyer_second_nm VARCHAR(31) NOT NULL,
  purchase_dttm TIMESTAMP(0) DEFAULT now()::timestamp, CHECK (purchase_dttm is NOT NULL)
);

create table ELECTRIC_TRAIN_X_TRIP(
  train_id SERIAL REFERENCES ELECTRIC_TRAIN(train_id),
  trip_id SERIAL REFERENCES TRIP(trip_id),
  PRIMARY KEY(train_id, trip_id)
);

create table TRIP_X_STATION(
  trip_id SERIAL REFERENCES TRIP(trip_id),
  station_id SERIAL REFERENCES STATION(station_id),
  departure_flg BOOLEAN NOT NULL,
  PRIMARY KEY(trip_id, station_id)
);