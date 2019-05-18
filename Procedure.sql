CREATE FUNCTION sale_trigger ()
RETURNS TRIGGER AS $$
BEGIN
    IF tg_op = 'INSERT' THEN
        UPDATE trip SET sale_flg = true
        WHERE trip_id = new.trip_id;
        RETURN NEW;
    ELSEIF tg_op = 'UPDATE' THEN
        IF (SELECT count(train_id) FROM electric_train_x_trip WHERE trip_id = old.trip_id) = 0
            THEN UPDATE trip SET sale_flg = false
                 WHERE trip_id = old.trip_id;
        END IF;
        UPDATE trip SET sale_flg = true
        WHERE trip_id = new.trip_id;
        RETURN NEW;
    ELSEIF tg_op = 'DELETE' THEN
        IF (SELECT count(train_id) FROM electric_train_x_trip WHERE trip_id = old.trip_id) = 0
            THEN UPDATE trip SET sale_flg = false
                 WHERE trip_id = old.trip_id;
        END IF;
        RETURN NEW;
    END IF;
END
$$ language plpgsql;

CREATE TRIGGER sale_condition
    AFTER INSERT OR DELETE OR UPDATE
    ON electric_train_x_trip
    FOR EACH ROW
    EXECUTE PROCEDURE sale_trigger();

CREATE FUNCTION ticket_trigger ()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS(SELECT sale_flg FROM trip WHERE trip.trip_id = new.trip_id)
           or (SELECT sale_flg FROM trip WHERE trip.trip_id = new.trip_id) = false
        THEN RAISE EXCEPTION 'Этот билет не продаётся';
        ELSE RETURN new;
    END IF;
END
$$ language plpgsql;

CREATE TRIGGER ticket_condition
    BEFORE INSERT OR UPDATE
    ON ticket
    FOR EACH ROW
    EXECUTE PROCEDURE ticket_trigger();