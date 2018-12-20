-- This function write the weight the word researched on the column word_weight
CREATE OR REPLACE FUNCTION weight(rch varchar,syn varchar ARRAY, occ_array INT ARRAY ,N int, df INT)
RETURNS INT AS
$CONTENT$
DECLARE 
cnt INT =1;
cnt_occ INT =0;
tot REAL;
BEGIN
-- Loop that check ih the word is in the synopsis array
WHILE cnt <= array_length(syn,1) LOOP
    IF syn[cnt] = rch THEN
        cnt_occ = cnt_occ + occ_array[cnt];
    END IF;
    cnt=cnt+1;
END LOOP;
cnt=1;
-- tot is the weight of the word using
-- N : the total number of document
-- df: the number of document un which the word researched appear
tot = cnt_occ * log(N/df);
-- Update the table to set the weigth of the word researched
UPDATE vector SET word_weight = tot WHERE vector.synopsis = syn;
RETURN 1;
END;
$CONTENT$
LANGUAGE plpgsql;