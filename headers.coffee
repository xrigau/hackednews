cheerio = require('cheerio')
http = require('http')
Shred = require("shred")
shred = new Shred()
_ = require "underscore"
$ = require('cheerio')
protocol = "http://"
host = "#{protocol}news.ycombinator.com"

Client = (myHost) ->

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
		user.href = host+"/"+$("td a", data).attr("href")
		user

	parsePoints = (data) =>
		$("td span", data).text().split(' ')[0]

	parseNextPage = (data) ->
		myHost + $("a", data).attr("href")

	parseWhen = (data) ->
		timeRegex = /(?:)[0-9]* (day[s]*|minute[s]*|hour[s]*) ago/g
		match = timeRegex.exec($("td", data).text())
		match[0]

	parseNews = (data) ->
		dom = cheerio.load data
		rows = dom("table table tr").toArray()
		stories = rows.splice(0, rows.length-4)
		nextPage = rows.splice(rows.length-4, rows.length)
		
		groups = chunks(stories ,3)

		newsItems = _.map groups, (item, ndx) ->
			obj = {}
			obj.domain = parseDomain $(item[1])
			obj.title = parseTitle $(item[1])
			obj.href = parseStoryHref $(item[1])
			obj.submittedBy = parseSubmittedBy $(item[2])
			obj.points = parsePoints $(item[2])
			obj.when = parseWhen $(item[2])
			obj

		news = {}
		news.newsItems = newsItems
		news.more = parseNextPage $(nextPage)
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

	getPage: (page, fn)->
		callHNews page, (body) ->
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