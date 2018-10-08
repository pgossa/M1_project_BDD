#!/bin/bash
listid=$(tail -n +2 idmovie.csv)
for i in $listid
do
	imdbid=$(echo $i | cut -d',' -f2)
	tmdbid=$(echo $i | cut -d',' -f3)
	if [[ $tmdbid = *[^[:space:]]* ]] 
	then 
		currentURL="https://www.themoviedb.org/movie/$tmdbid"
		content=$(wget -q -O - $currentURL | xmllint --html --xpath '//div[@class = "overview"]' - 2>/dev/null | tail -n +2 | head -n +2 | sed 's#<p>##g' | sed 's#</p>##g')
	else 
		currentURL="https://www.imdb.com/title/tt$imdbid/"
	content=$(wget -q -O - $currentURL | xmllint --html --xpath '//div[@class = "inline canwrap"]' - 2>/dev/null | xmllint --html --xpath '//span' - 2>/dev/null | cut  -c11- | sed 's#</span>##g')
	fi
	echo $content
	./bin/psql -h 127.0.0.1 -p 5454 -U francois -d projet_test -c "INSERT INTO cinema (synopsis) VALUES ($content);"
done
