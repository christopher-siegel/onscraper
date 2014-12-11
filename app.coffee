request = require 'request'
cheerio = require 'cheerio'
phantom = require 'phantom'
Q = require 'q'
fs = require 'fs'
wkhtmltopdf = require("wkhtmltopdf")
moment = require "moment"

# @ToDo:
# - Mit Cronjob/o.Ä. diesen Code alle 3 Tage automatisch ausführen lassen
#   - Dabei nur eine neue Datei speichern, wenn sich die Seite verändert hat (z. B. neuer Artikel online)

current_time = moment().format("YYYY-MM-DD")

# -- Config --
config = {
  target: 'http://www.onlinewerk.info'
  output: {
    pdf: "output/Onlinewerk-Pdf_#{current_time}.pdf"
    jpg: "output/Onlinewerk-Screenshot_#{current_time}.jpg"
    json: "output/Onlinewerk-Artikel_#{current_time}.json"
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
      $('.article > p').each (x, elem) ->
        content_scraped += $(this).text()

      article = {
        title: title_scraped
        cat: cat_scraped
        date: date_scraped
        author: author_scraped
        content: content_scraped
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