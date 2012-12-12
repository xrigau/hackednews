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
		user.link = {}
		user.link.rel = "viewUser"
		user.link.href = host+"/"+$("td a", data).attr("href")
		user

	parsePoints = (data) =>
		$("td span", data).text().split(' ')[0]

	parseNextPage = (data) ->
		myHost + $("a", data).attr("href")

	parseWhen = (data) ->
		timeRegex = /(?:)[0-9]* (day[s]*|minute[s]*|hour[s]*) ago/g
		match = timeRegex.exec($("td", data).text())
		match[0]

	parseItem = (data) ->
		obj = {}
		obj.domain = parseDomain $(data[1])
		obj.title = parseTitle $(data[1])
		obj.href = parseStoryHref $(data[1])
		obj.submittedBy = parseSubmittedBy $(data[2])
		obj.points = parsePoints $(data[2])
		obj.when = parseWhen $(data[2])
		obj

	parseNews = (data) ->

		dom = cheerio.load data
		rows = dom("table table tr").toArray()
		stories = rows.splice(0, rows.length-4)
		nextPage = rows.splice(rows.length-4, rows.length)
		
		groups = chunks(stories ,3)

		newsItems = _.map groups, (item, ndx) ->
			console.log $(item).html()
			parseItem item

		res = {}
		res.newsItems = newsItems
		res.links = []
		res.links.push {rel:"nextPage", href: parseNextPage $(nextPage)}

		headerLinks = $("a", dom("table tr").first())
		
		res.links.push {rel: "ycombinator", href: $(headerLinks[0]).attr("href")}
		res.links.push {rel: "ycombinator", href: "#{myHost}" + $(headerLinks[1]).attr("href")}
		res.links.push {rel: "news", href: "#{myHost}" + $(headerLinks[2]).attr("href")}
		res.links.push {rel: "newest", href: "#{myHost}" + $(headerLinks[3]).attr("href")}
		res.links.push {rel: "newcomments", href: "#{myHost}" + $(headerLinks[4]).attr("href")}
		res.links.push {rel: "jobs", href: "#{myHost}" + $(headerLinks[5]).attr("href")}
		res

	parseComments = (data) ->
		console.log data.toString()
		{}

	callHNews = (uri, fn) ->
		shred.get 
			url:"#{host}/#{uri}",
			on:
				200: (response) ->
					fn(response.body._body)
				response: (response) ->
					console.log("Oh no!")
	
	getNewest: ({fn}) ->
		callHNews "newest", (body) ->
			news = parseNews body
			fn(news)

	getNews: ({fn}) ->
		callHNews "news", (body) ->
			news = parseNews body
			fn(news)

	getPage: ({uri, fn})->
		callHNews uri, (body) ->
			news = parseNews body
			fn(news)

	getAsk: ({fn}) ->
		callHNews "ask", (body) ->
			news = parseNews body
			fn(news)

	getNewComments: ({fn}) ->
		callHNews "newcomments", (body) ->
			news = parseComments body
			fn(news)

	getItem: ({uri, fn}) ->
		callHNews uri, (body) ->
			console.log body.toString()
			fn({uri: uri})


	getHeaders: (domain) ->
		headers = null
		http.get "#{protocol}/#{domain}", (res) ->
			headers = res.headers
		headers

module.exports = Client