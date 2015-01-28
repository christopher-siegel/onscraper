request = require 'request'
cheerio = require 'cheerio'
exec = require('child_process').exec
fs = require "fs"

# Config
seconds = 1*60
interval = seconds * 1000

# Functions
checkForUpdates = (url) ->
  console.log "--------"
  console.log "Trying ..."
  request {uri: url, encoding: "utf8"}, (error, response, body) ->
      if error or response.statusCode isnt 200
        console.log "Woops, Error requesting website #{response.statusCode}"
      else
	      $ = cheerio.load body
	      title = $('.article > h2 > a').attr('title')
	      status = fs.readFileSync(__dirname+'/status.werk')
	      console.log "Last Checked: #{status}"
	      console.log "Current: #{title}"
	      
	      if "#{status}" isnt "#{title}"
	      	fs.unlinkSync(__dirname+'/status.werk')
	      	fs.writeFileSync(__dirname+'/status.werk', title)
	      	console.log "[+] New Content! >> #{title} << . Scrape it!"
	      	exec "coffee ../scraper/app.coffee", (err, stdout, stderr) ->
	      	  if err or stderr
	      	  	console.log err
	      	  	console.log stderr
	      	  	console.log "[NO] Failed.\n--------"
	      	  else
	      	  	console.log "[YES] Successful.\n--------"
	      else
	      	console.log "[-] Nothing new\n--------"


checkForUpdates "http://onlinewerk.info"
# Check in Interval
setInterval (->
  checkForUpdates "http://onlinewerk.info"
), interval