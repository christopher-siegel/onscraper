express = require("express")
app = express()
exec = require('child_process').exec
fs= require "fs"
cors = require('cors')

scraper_dir = "/Users/nikolas/www/onscraper"
app.use(cors())
app.get "/scrape", (req, res) ->
  exec "coffee #{scraper_dir}/components/scraper/app.coffee", (err, stdout, stderr) ->
    console.log stdout
    console.log stderr
    console.log err
    res.end "OK"

app.get "/info", (req, res) ->
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "X-Requested-With");
  res.setHeader('Content-Type', 'application/json')
  fs.readFile "#{scraper_dir}/output/data.json", (err, data) ->
    if err
      res.end "500"
    else
      article_info = JSON.parse(data)
      fs.stat "#{scraper_dir}/output/data.json", (err, status_info) ->
        if err
          res.end "500"
        else
          json_response = {
            last_article: article_info["articles"][0]["title"]
            last_time: status_info.mtime
            whole_data: article_info
          }
          res.end(JSON.stringify(json_response))

app.all "/", (req, res, next) ->
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "X-Requested-With");
  next();

server = app.listen(1337, ->
  host = server.address().address
  port = server.address().port
  console.log "Launched Web-API, http://%s:%s", host, port
)