cheerio = require('cheerio')
http = require('http')
Shred = require("shred")
shred = new Shred()
_ = require "underscore"
$ = require('cheerio')
protocol = "http://"
host = "#{protocol}news.ycombinator.com"

HNApi = (myHost) ->
	
	userFields = ["user", "created", "karma", "avg", "about"]
	userLinks = ["submissions", "comments"]
	sections = ["ycombinator", "news", "newest", "newcomments", "ask", "jobs"]

	chunks = (array, size) ->
		results = []
		while array.length
			results.push(array.splice(0, size))
		results

	isUrl = (data) ->
		data.indexOf("http") is 0

	getUrl = (data) ->
		href = $(data).attr("href")
		if isUrl href
			href
		else
			"#{myHost}" + href

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
		match = timeRegex.exec(data)
		match[0]

	parseItem = (data) ->
		obj = {}
		obj.domain = parseDomain $(data[1])
		obj.title = parseTitle $(data[1])
		obj.href = parseStoryHref $(data[1])
		obj.submittedBy = parseSubmittedBy $(data[2])
		obj.points = parsePoints $(data[2])
		obj.when = parseWhen $("td", $(data[2])).text()
		obj

	parseNews = (data) ->

		dom = cheerio.load data
		rows = dom("table table tr").toArray()
		stories = rows.splice(0, rows.length-4)
		nextPage = rows.splice(rows.length-4, rows.length)
		
		groups = chunks(stories ,3)

		newsItems = _.map groups, (item, ndx) ->
			parseItem item

		res = {}
		res.newsItems = newsItems
		res.links = []
		res.links.push {rel:"nextPage", href: parseNextPage $(nextPage)}

		headerLinks = $("a", dom("table tr").first())
		
		_.each sections, (item, ndx) ->
			res.links.push {rel: item, href: getUrl headerLinks[ndx]}

		res

	parseComments = (data) ->
		dom = cheerio.load data
		rows = dom(".default")
		comments = []

		_.each rows, (item, ndx) ->
			comment = {}
			comment.text = $(".comment", $(item)).text()
			comment.user = 
				name: $(".comhead a", $(item)).first().text()
				href: getUrl $(".comhead a", $(item)).first()
			comment.link = getUrl $($(".comhead a", $(item))[1])
			comment.parent = getUrl $($(".comhead a", $(item))[2])
			comment.head = getUrl $($(".comhead a", $(item))[3])
			comment.when = parseWhen $(".comhead", $(item)).text()
			comments.push comment

		comments

	parseUser = (data) ->
		dom = cheerio.load data
		rows = dom("table form table td")
		user = {}
		_.each userFields, (item, ndx) ->
			user["#{item}"] = $(rows[(ndx*2)+1]).html()
		
		user.links = []
		_.each userLinks, (item, ndx) ->
			user.links.push 
				rel: item
				href: getUrl $("a", $(rows[((ndx+userFields.length)*2)+1]))
		user

	callHNews = (uri, continuation, parser) ->
		console.log "#{host}#{uri}"
		shred.get 
			url:"#{host}#{uri}",
			on:
				200: (response) ->
					continuation(parser(response.body._body))
				response: (response) ->
					console.log("Oh no!")


	# public API

	"/" : ({fn}) -> callHNews "/news", fn, parseNews
	"/news" : ({fn}) -> callHNews "/news", fn, parseNews
	"/news2" : ({fn}) -> callHNews "/news2", fn, parseNews
	"/user" : ({uri, fn}) -> callHNews uri, fn, parseUser
	"/newest" : ({fn}) -> callHNews "/newest", fn, parseNews
	"/x" : ({uri, fn}) -> callHNews uri, fn, parseNews
	"/ask" : ({fn}) -> callHNews "/ask", fn, parseNews 
	"/newcomments" : ({fn}) -> callHNews "/newcomments", fn, parseComments
	"/item" : ({uri, fn}) -> callHNews uri, fn, parseNews
	"/submitted" : ({uri, fn}) -> callHNews uri, fn, parseComments
	


module.exports = HNApi


###

getHeaders = (domain) ->
	headers = null
	http.get "#{protocol}/#{domain}", (res) ->
		headers = res.headers
	headers