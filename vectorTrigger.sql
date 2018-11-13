DROP TABLE vector;
CREATE TABLE vector
(
    id_film integer PRIMARY KEY,
    synopsis VARCHAR ARRAY,
    size int
);

CREATE OR REPLACE FUNCTION vectorize()
RETURNS trigger AS
$CONTENT$
DECLARE
    size integer;
    temp_syn varchar;
    temp_array VARCHAR ARRAY;
BEGIN
-- Symbols suppression
    temp_syn := regexp_replace(NEW.synopsis, '"', '' ,'g');
    temp_syn := regexp_replace(temp_syn, '''s', '' ,'g');
    temp_syn := regexp_replace(temp_syn, '[0-9]s', '0' ,'g');
    temp_syn := regexp_replace(temp_syn,'[.,/#!$%^&*;:{}=_`~()-]','','g');
-- Lower all characters
    temp_syn := LOWER(temp_syn);
-- Most usual word suppression
    temp_syn := regexp_replace(temp_syn, ' the ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' to ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' be ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' and ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' a ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' of ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' that ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' in ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' have ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' i ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' it ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' for ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' not ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' on ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' has ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' you ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' he ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' you ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' do ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' at ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, '  ', ' ' ,'g');
-- Array Cast
    temp_array := regexp_split_to_array(temp_syn, E' ');
-- Save total word number
    size := array_length(temp_array,1);


    INSERT INTO vector VALUES (NEW.id_film,temp_array,size);
    RETURN NEW;
END
$CONTENT$
LANGUAGE plpgsql; 

DROP TRIGGER IF EXISTS trig_vector ON film;
CREATE TRIGGER trig_vector
AFTER INSERT OR UPDATE ON film
FOR EACH ROW EXECUTE PROCEDURE vectorize();