CREATE OR REPLACE FUNCTION search(rch varchar)
RETURNS REAL ARRAY AS
$CONTENT$
DECLARE 
res_temp REAL ARRAY;
res REAL ARRAY;
res1 REAL ARRAY;
res2 REAL ARRAY;
res3 REAL ARRAY;
cnt_word INT=0;
cnt2 INT =1;
temp INT =0;
srch VARCHAR ARRAY;
N INT;
df INT;
BEGIN
-- Set the variable to 0
res[1]=0;res[2]=0;res[3]=0;res[4]=0;res[5]=0;res[6]=0;
srch := regexp_split_to_array(rch, E' ');
-- This loop launch the function for each different word is the research field
WHILE cnt_word < array_length(srch,1) LOOP
-- This function check for the number of time that the word appear
PERFORM occ(srch[cnt_word+1],synopsis,occ_array) from vector;
-- Compute the value
N = (SELECT count(*) FROM vector);
df = (SELECT count(*) FROM vector WHERE word_sch > 0);
IF df =0 THEN
RETURN res;
END IF;
-- This function set the weight of the word researched in each story line
PERFORM weight(srch[cnt_word+1],synopsis,occ_array,N,df) from vector;
-- This loop get the 3 higher weight story line and their id
WHILE cnt2 <=6 LOOP

res_temp[(cnt_word*6)+cnt2] := (SELECT id_film from vector ORDER BY word_weight DESC LIMIT 1);
res_temp[(cnt_word*6)+cnt2+1] := (SELECT word_weight from vector ORDER BY word_weight DESC LIMIT 1);
-- Set the column to 0 for the next research
UPDATE vector SET word_weight = 0 WHERE vector.id_film = res_temp[(cnt_word*6)+cnt2];
cnt2 = cnt2+2;
END LOOP;

cnt2=1;
cnt_word = cnt_word + 1;
END LOOP;

cnt_word =1;
-- This loop addition the height of film is they appear multiple time
WHILE cnt_word <= array_length(res_temp,1) LOOP

temp = cnt_word +2;
WHILE temp <= array_length (res_temp,1) LOOP

IF res_temp[cnt_word] = res_temp[temp] THEN
res_temp[cnt_word+1] = res_temp[cnt_word+1] + res_temp[temp+1];
END IF;

temp = temp+2;
END LOOP;

cnt_word = cnt_word +2;
END LOOP;

-- This loop set an int array which will have the highter weight and the id , and will be returned
cnt_word = 2;
res1[1]=0;res1[2]=0;res2[1]=0;res2[2]=0;res3[1]=0;res3[2]=0;
WHILE cnt_word <= array_length(res_temp,1) LOOP
IF res_temp[cnt_word] > res1[2] THEN
IF res1[2] > res2[2] THEN

res2 = res1;
ELSIF res1[2] > res3[2] THEN

res3 = res1;
END IF;

res1[1]=res_temp[cnt_word-1];
res1[2]=res_temp[cnt_word];

ELSIF res_temp[cnt_word] > res2[2] THEN

IF res2[2] > res3[2] THEN

res3 = res2;
END IF;

res2[1]=res_temp[cnt_word-1];
res2[2]=res_temp[cnt_word];

ELSIF res_temp[cnt_word] > res3[2] THEN

res3[1]=res_temp[cnt_word-1];
res3[2]=res_temp[cnt_word];

END IF;

cnt_word = cnt_word+2;
END LOOP;
res[1]=res1[1];res[2]=res1[2];res[3]=res2[1];res[4]=res2[2];res[5]=res3[1];res[6]=res3[2];

RETURN res;
END;
$CONTENT$
LANGUAGE plpgsql;