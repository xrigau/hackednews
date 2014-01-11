_ = require "underscore"

SummaryRoutes = (app, api) ->
	callback = (fnName, {url, req, res}) ->
		console.log fnName.toString()
		api[fnName] (
			url: url()
			fn: (data) ->
				res.set('Content-Type', 'application/json')
				res.send(data)
		)

	_.each [
		{ path:"/summary", url: (req) -> "#{req.query.url}" }
	], (item, ndx) ->
		app.get item.path, (req, res) ->
			params = 
				req: req
				res: res
				url: -> item.url(req)
			res.format
				json: -> 
					callback item.path, params
				default: ->
					json()


module.exports = SummaryRoutes
