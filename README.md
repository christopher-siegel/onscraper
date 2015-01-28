# Install
  1. install wkhtmltopdf -- Careful: http://stackoverflow.com/a/17610797
  2. npm install -g phantomjs
  3. npm install -g coffee-script
  4. npm install

# Start Watcher
  1. change directory to watcher folder.
  2. coffee app.coffee

# Start Scraper directly
  1. change directory to scraper folder.
  2. coffee app.coffee

# Start API (to use Web Interface)
  1. change directory to web folder.
  2. coffee app.coffee

# Reset Status
If you want to let the watcher forget:
  1. empty components/watcher/status.werk file. 

# Run Wizard
  1. go to root folder of Application /onscraper/.
  2. ./run.sh