
routes = (app) ->
	Client = require("../../headers")(app.clientsettings.host)
	
	app.get "/", (req, res) ->
		res.format
			json: ->
				res.set('Content-Type', 'application/json');
				Client.getNewest (data) ->
					res.send(data)
			default: ->
				res.set('Content-Type', 'application/json');
				Client.getPage "x?fnid=#{req.query.fnid}", (data) ->
					res.send(data)

	app.get "/x", (req, res) ->
		res.format
			json: ->
				res.set('Content-Type', 'application/json');
				Client.getPage "x?fnid=#{req.query.fnid}", (data) ->
					res.send(data)
			default: ->
				res.set('Content-Type', 'application/json');
				Client.getPage "x?fnid=#{req.query.fnid}", (data) ->
					res.send(data)

	app.get "/item", (req, res) ->
		res.format
			json: ->
				res.set('Content-Type', 'application/json');
				Client.getItem "item?id=#{req.query.id}", (data) ->
					res.send(data)
			default: ->
				res.set('Content-Type', 'application/json');
				Client.getItem "item?id=#{req.query.id}", (data) ->
					res.send(data)

module.exports = routes