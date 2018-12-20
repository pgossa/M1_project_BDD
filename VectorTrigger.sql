DROP TABLE vector;
CREATE TABLE vector
(
    id_film INT PRIMARY KEY,
    synopsis VARCHAR ARRAY,
    occ_array INT ARRAY,
    word_sch INT,
    word_weight REAL
);

CREATE OR REPLACE FUNCTION f_array_remove_elem(anyarray, int)
  RETURNS anyarray LANGUAGE sql IMMUTABLE AS
'SELECT $1[1:$2-1] || $1[$2+1:2147483647]';

CREATE OR REPLACE FUNCTION vectorize()
RETURNS trigger AS
$CONTENT$
DECLARE
    ref_word VARCHAR;
    temp_syn VARCHAR;
    temp_array VARCHAR ARRAY;
    occ_array INT ARRAY;
    weight_array REAL ARRAY;
    cnt1 INT = 1;
    cnt2 INT = 2;
    cnt_word REAL = 1;
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
    temp_syn := regexp_replace(temp_syn, ' this ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' in ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' have ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' i ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' it ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' for ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' not ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' on ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' has ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' you ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' she ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' he ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' he ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' you ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' do ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' at ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' by ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' are ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' with ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' who ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' her ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' his ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' him ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, ' when ', ' ' ,'g');
    temp_syn := regexp_replace(temp_syn, '  ', ' ' ,'g');

-- Array Cast
    temp_array := regexp_split_to_array(temp_syn, E' ');

-- Remove duplicate word
    WHILE cnt1 <= array_length(temp_array,1) LOOP
        cnt2 = cnt1+1;
        ref_word := temp_array[cnt1];
        WHILE cnt2 <= array_length(temp_array,1) LOOP
            temp_syn := temp_array[cnt2];
            IF temp_syn = ref_word THEN
                cnt_word = cnt_word+1;
                temp_array := f_array_remove_elem(temp_array::text[], cnt2);
            ELSE
                cnt2 = cnt2+1;
            END IF;
        END LOOP;
        weight_array := array_append(weight_array,cnt_word);
        cnt_word = 1;
        cnt1 = cnt1+1;
    END LOOP;

-- Divide per the total word number
    occ_array := weight_array;
-- Insertion 
    INSERT INTO vector VALUES (NEW.id_film,temp_array,occ_array,0,0);
    RETURN NEW;
END;
$CONTENT$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trig_vector ON film;
CREATE TRIGGER trig_vector
AFTER INSERT OR UPDATE ON film
FOR EACH ROW EXECUTE PROCEDURE vectorize();