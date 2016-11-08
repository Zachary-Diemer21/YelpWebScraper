# YelpWebScraper

* :rocket Here is what you need to do to utilize this particular webscraper!
	1. Firstly, download the YelpWebScraper.py script, and the txt file with all of the zipcodes within the US. These two scripts will allow you to start collecting data. The python script is the main script. 
	2. Edit it accordingly (ie by providing it with a designated search term, path to the zipcode txt file, etc.), and then send it into action by copy and pasting it into a python command prompt. 
	3. Edit the location that you wish to save such files. 

Some notes: 

	* I split up the US zipcodes as follows: 10000, 20000, 30000, etc. and then ran the code accordingly. 
	* There is a tremendous amount of duplicate data due to the overlapping zipcodes. Therefore, I utilized an R script to clean the data which can be found in this repository. 
	* There are additional files, including a particular batch script, within this repository that I utilized to configure PostGIS, PostGreSQL, and the Tiger Geocoder (this in particular was an absolute NIGHTMARE to configure and lacks appropriate documentation). 