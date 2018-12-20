#!/bin/bash
#if you are using mac OS X uncomment line 33 (psql ...) and comment line 32.
echo $1
	bddid=$(echo $1 | cut -d ',' -f1)
	imdbid=$(echo $1 | cut -d',' -f2)
	tmdbid=$(echo $1 | cut -d',' -f3)
	if [[ $tmdbid = *[^[:space:]]* ]]
	then
		currentURL="https://www.themoviedb.org/movie/$tmdbid"
		content=$(wget -q -O - $currentURL | xmllint --html --xpath '//div[@class = "overview"]' - 2>/dev/null | tail -n +2 | head -n +2 | cut  -c19- | sed 's#<p>##g' | sed 's#</p>##g' | sed "s#'#''#g" | tr -d '\n')
		content2=$(echo $content | sed "s#[[:punct:]]# #g")
        if [[ -z "$content" ]]
        then
            currentURL="https://www.imdb.com/title/tt$imdbid/"
		content=$(wget -q -O - $currentURL | xmllint --html --xpath '//div[@class = "inline canwrap"]' - 2>/dev/null | xmllint --html --xpath '//span' - 2>/dev/null | cut  -c11- | sed 's#</span>##g' | sed "s#'#''#g")
		content2=$(echo $content | sed "s#[[:punct:]]# #g")
				if [[ -z "$content" ]]
				then
						content=null
						content2=null
					fi
        fi

	else
		currentURL="https://www.imdb.com/title/tt$imdbid/"
		content=$(wget -q -O - $currentURL | xmllint --html --xpath '//div[@class = "inline canwrap"]' - 2>/dev/null | xmllint --html --xpath '//span' - 2>/dev/null | cut  -c11- | sed 's#</span>##g' | sed "s#'#''#g")
		content2=$(echo $content | sed "s#[[:punct:]]# #g")
	fi
	echo $content
	#echo $bddid
	export LD_LIBRARY_PATH=./lib/
	#./bin/psql -h 127.0.0.1 -p 5454 -U cinephile -d cinema -c "BEGIN;UPDATE film SET synopsis = '$content' WHERE id_film=$bddid;COMMIT;"
	psql -h 127.0.0.1 -p 5454 -U cinephile -d cinema -c "BEGIN;UPDATE film SET synopsis = '$content' WHERE id_film=$bddid;COMMIT;"
