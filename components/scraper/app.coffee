request = require 'request'
cheerio = require 'cheerio'
phantom = require 'phantom'
Q = require 'q'
fs = require 'fs'
wkhtmltopdf = require("wkhtmltopdf")
moment = require "moment"
exec = require('child_process').exec
path = require('path')

# html oberfläche schreiben
# watcher dienst?
# pm2


current_time = moment().format("YYYY-MM-DD")

# -- Config --
config = {
  target: 'http://www.onlinewerk.info'
  output: {
    pdf: "output/onlinewerk.pdf"
    jpg: "output/oninewerk.jpg"
    json: "output/data.json"
  }
}

temp = {
  content: ""
  articleURLList: []
}

json = {
  articles: []
}

_pre = ->
  deferred = Q.defer()

  deferred.resolve true
  return deferred.promise

# -- Functions --
getBody = ->
  deferred = Q.defer()
  request {uri: config.target, encoding: "utf8"}, (error, response, body) ->
    temp.content = body
    return deferred.resolve body  if not error and response.statusCode is 200
    if error or response.statusCode isnt 200 then return deferred.reject error
  return deferred.promise

getArticles = ->
  deferred = Q.defer()
  $ = cheerio.load(temp.content)
  $('div.article > h2 > a').each (i, elem) ->
    link = $(this).attr('href')
    temp.articleURLList.push link
  deferred.resolve true
  return deferred.promise

parseArticles = ->
  deferred = Q.defer()
  i = 1
  for articleURL in temp.articleURLList
    request {uri: articleURL, encoding: "utf8"}, (error, response, body) ->
      if error or response.statusCode isnt 200
        return deferred.reject
      $ = cheerio.load body

      title_scraped = $('div.article > h2 > a').attr("title")
      cat_scraped = $('div.article > small a[rel="category tag"]').text()
      date_scraped = $('div.article > small').text()
      date_pos1 = ((date_scraped.indexOf("am ")) + 3)
      date_pos2 = ((date_scraped.indexOf(" in") - 3))
      date_scraped = date_scraped.substr(date_pos1, date_pos2)
      author_scraped = $('div.article > small a[rel="author"]').text()
      content_scraped = ""
      quotes_scraped = []
      $('.article > p').each (x, elem) ->
        content_scraped += $(this).text()

      $('.article > blockquote').each (x, elem) ->
        quotes_scraped.push $(this).text()

      article = {
        title: title_scraped
        cat: cat_scraped
        date: date_scraped
        author: author_scraped
        content: content_scraped
        quotes: quotes_scraped
        }
      json.articles.push article
      if i is temp.articleURLList.length
        console.log "(x) Saved JSON"
        return deferred.resolve true
      else
        i++
  return deferred.promise

saveMedia = ->
  deferred = Q.defer()
  fs.writeFileSync config.output.json, JSON.stringify(json)
  wkhtmltopdf(config.target)
    .pipe(fs.createWriteStream(config.output.pdf));
  console.log "(x) Saved PDF"
  exec "gs -dPDFA -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=#{config.output.pdf} #{config.output.pdf}", (err, stdout, stderr) ->
    console.log stdout
    phantom.create (ph) ->
      ph.createPage (page) ->
        page.viewportSize = { width: 1920, height: 1080}
        page.open config.target, (status) ->
            page.render config.output.jpg, ->
              console.log "(x) Saved JPG"
              ph.exit()
              return deferred.resolve true
   return deferred.promise



# -- Procedure --
Q.fcall(_pre)
.then(getBody)
.then(getArticles)
.then(parseArticles)
.then(saveMedia)
.catch (err) ->
  console.log "Error:", err
.done()