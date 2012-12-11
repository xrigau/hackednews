
routes = (app) ->
	Client = require("../../headers")(app.clientsettings.host)
	
	app.get "/", (req, res) ->
		res.format
#			html: ->
#				res.set('Content-Type', 'text/html');
#				Client.getNewestHtml (data) ->
#					res.send(data.toString())
			json: ->
				res.set('Content-Type', 'application/json');
				Client.getNewest (data) ->
					res.send(data)

	app.get "/(:page)", (req, res) ->
#		res.format
#			html: ->
#				res.set('Content-Type', 'text/html');
#				Client.getPageHtml "#{req.params.page}?fnid=#{req.query.fnid}", (data) ->
#					res.send(data.toString())
			json: ->
				res.set('Content-Type', 'application/json');
				Client.getPage "#{req.params.page}?fnid=#{req.query.fnid}", (data) ->
					res.send(data)

module.exports = routes