cheerio = require('cheerio')
http = require('http')
Shred = require("shred")
shred = new Shred()
_ = require "underscore"
$ = require('cheerio')
protocol = "http://"
host = "#{protocol}news.ycombinator.com"

Client = ->

	chunks = (array, size) ->
		results = []
		while array.length
			results.push(array.splice(0, size))
		results

	parseDomain = (data) ->
		($(".comhead", data).map (ndx, item) ->
			$(item).text().replace("(", "").replace(")", "")).pop()

	parseTitle = (data) ->
		titles = $("td a", data).map (ndx, item) ->
			$(item).text().replace("(", "").replace(")", "")
		_.filter(titles, (title) -> title != '').pop()

	parseStoryHref = (data) ->
		$("td a", data).last().attr("href")

	parseSubmittedBy = (data) ->
		user = {}
		user.name = $("td a", data).html()
		user.href = $("td a", data).attr("href")
		user

	parseNews = (data) ->
		dom = cheerio.load data
		rows = dom("table table tr").toArray()
		groups = chunks(rows,3)
		news = _.map groups, (item, ndx) ->
			obj = {}
			obj.domain = parseDomain $(item[1])
			obj.title = parseTitle $(item[1])
			obj.href = parseStoryHref $(item[1])
			obj.submittedBy = parseSubmittedBy $(item[2])
			obj
		console.log news
		news

	callHNews = (page, fn) ->
		shred.get 
			url:"#{host}/#{page}",
			on:
				200: (response) ->
					fn(response.body._body)
				response: (response) ->
					console.log("Oh no!")

	getNewestHtml: (fn) ->
		callHNews "newest", fn
	
	getNewest: (fn) ->
		callHNews "newest", (body) ->
			news = parseNews body
			fn(news)

	getPageHtml: (page, fn)->
		callHNews page, fn

	getHeaders: (domain) ->
		headers = null
		http.get "#{protocol}/#{domain}", (res) ->
			headers = res.headers
		headers

module.exports = Client