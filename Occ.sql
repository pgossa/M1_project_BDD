-- This function write the number of time that the word researched appear on the column word_sch
CREATE OR REPLACE FUNCTION occ(rch varchar,syn VARCHAR ARRAY,occ_array INT ARRAY)
RETURNS INT AS
$CONTENT$
DECLARE
cnt INT =1;
cnt_occ INT =0;
BEGIN
-- Loop that check ih the word is in the synopsis array
WHILE cnt <= array_length(syn,1) LOOP
    IF syn[cnt] = rch THEN
        cnt_occ = cnt_occ + occ_array[cnt];
    END IF;
    cnt=cnt+1;
END LOOP;
cnt=1;
-- Update the table to set the number of time that the word appear
UPDATE vector SET word_sch = cnt_occ WHERE vector.synopsis = syn;
RETURN cnt_occ;
END;
$CONTENT$
LANGUAGE plpgsql;