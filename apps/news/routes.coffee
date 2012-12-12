routes = (app) ->
	Client = require("../../headers")(app.clientsettings.host)
	
	createUrl = (req) ->
		"http://" + req.headers.host + req.url
	
	callback = (fnName, {uri, req, res}) ->
		Client[fnName](
			uri: uri
			fn: (data) ->
					data.links || data.links = []
					data.links.push {rel:"self", href: createUrl req}
					res.set('Content-Type', 'application/json')
					res.send(data)
		)

	app.get "/", (req, res) ->
		res.format
			json: ->
				callback "getNews", req: req, res: res
			default: ->
				callback "getNews", req: req, res: res

	app.get "/news", (req, res) ->
		res.format
			json: ->
				callback "getNews", req: req, res: res
			default: ->
				callback "getNews", req: req, res: res

	app.get "/newest", (req, res) ->
		res.format
			json: ->
				callback "getNewest", req: req, res: res
			default: ->
				callback "getNewest", req: req, res: res

	app.get "/newcomments", (req, res) ->
		res.format
			json: ->
				callback "getNewComments", req: req, res: res
			default: ->
				callback "getNewComments", req: req, res: res

	app.get "/ask", (req, res) ->
		res.format
			json: ->
				callback "getAsk", req: req, res: res
			default: ->
				callback "getAsk", req: req, res: res

	app.get "/x", (req, res) ->
		res.format
			json: ->
				callback "getPage", uri: "x?fnid=#{req.query.fnid}", req: req, res: res
			default: ->
				callback "getPage", uri: "x?fnid=#{req.query.fnid}", req: req, res: res

	app.get "/item", (req, res) ->
		res.format
			json: ->
				callback "getItem", uri: "item?id=#{req.query.id}", req: req, res: res
			default: ->
				callback "getItem", uri: "item?id=#{req.query.id}", req: req, res: res


module.exports = routes