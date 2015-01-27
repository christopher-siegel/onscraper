# Install
  1. install wkhtmltopdf -- http://stackoverflow.com/a/17610797
  2. npm install -g phantomjs
  3. npm install -g coffee-script
  4. npm install
  5. create "output" folder

# Start Watcher
  1. coffee components/watcher/app.coffee

# Start Scraper directly
  1. coffee components/scraper/app.coffee

# Reset Status
If you want to let the watcher forget:
  1. empty components/watcher/status.werk file. 

# Run Wizard
  1. ./run.sh