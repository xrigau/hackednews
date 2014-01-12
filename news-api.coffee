cheerio = require('cheerio')
Shred = require("shred")
shred = new Shred()
_ = require "underscore"
$ = require('cheerio')
protocol = "http://"
host = "#{protocol}news.ycombinator.com"

NewsApi = (myHost) ->

	userFields = ["user", "created", "karma", "avg", "about"]
	userLinks = ["submissions", "comments"]

	chunks = (array, size) ->
		results = []
		while array.length
			results.push(array.splice(0, size))
		results

	getUrl = (data) ->
		url = $(data).attr("href")
		if url then url.trim()

	isUrl = (data) ->
		if data is undefined
			return false

		data.indexOf("http") is 0

	getFullUrl = (data) ->
		href = getUrl data
		if isUrl href
			href
		else
			"#{myHost}" + href

	parseDomain = (data) ->
		domainArray = ($(".comhead", data).map (ndx, item) ->
			$(item).text().replace("(", "").replace(")", ""))
		if domainArray[0]
			domainArray[0].trim()

	parseTitle = (data) ->
		titles = $("td a", data).map (ndx, item) ->
			$(item).text().replace("(", "").replace(")", "")
		_.filter(titles, (title) -> title != '').pop()

	parseUsername = (data) ->
		$("td a", data).html() or undefined

	parseCommentCount = (data) ->
		comments = $("td a", data).last().html()
		commentsRegex = /([0-9]+) comment(s)?/
		match = commentsRegex.exec comments
		if match
			parseInt match[1]

	parsePoints = (data) =>
		points = $("td span", data).text().split(' ')[0]
		if (points)
			parseInt points

	parseNextPage = (data) ->
		nextPage = $("a", data).attr("href")
		if ////.*///.test nextPage
			nextPage = nextPage.replace("/", "")
		nextPage

	parseWhen = (data) ->
		timeRegex = /(?:)[0-9]* (day[s]*|minute[s]*|hour[s]*) ago/g
		match = timeRegex.exec(data)
		if match
			match[0]

	parseItemWrapper = (data) ->
		$local = cheerio.load data
		rows = $local("table table tr").toArray()

		item = parseItem rows
		item.comments = parseComments data
		item

	parseItem = (data) ->
		obj = {}
		obj.domain = parseDomain $(data[1])
		obj.title = parseTitle $(data[1])
		obj.url = getFullUrl $("td a", $(data[1])).last()
		obj.user = parseUsername $(data[2])
		obj.userUrl = getUrl $("td a", $(data[2]))
		obj.comments = parseCommentCount $(data[2])
		obj.commentsUrl = getUrl $("td a", $(data[2])).last()
		obj.points = parsePoints $(data[2])
		obj.timestamp = parseWhen $("td", $(data[2])).text()
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
		res.items = newsItems
		res.nextPage = parseNextPage $(nextPage)

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

			parent = $(".comhead a", $(item))[2]

			if parent
				comment.parent = getUrl $(parent)
			head = $(".comhead a", $(item))[3]

			if head
				comment.head = getUrl $(head)
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
	"/item" : ({uri, fn}) -> callHNews uri, fn, parseItemWrapper
	"/comments/item" : ({uri, fn}) -> callHNews uri, fn, parseNews
	"/submitted" : ({uri, fn}) -> callHNews uri, fn, parseComments
	"/threads" : ({uri, fn}) -> callHNews uri, fn, parseComments


module.exports = NewsApi
