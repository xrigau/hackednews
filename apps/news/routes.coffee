_ = require "underscore"

routes = (app, api) ->
	
	createUrl = (req) ->
		"http://" + req.headers.host + req.url
	
	callback = (fnName, {uri, req, res}) ->
		api[fnName](
			uri: uri
			fn: (data) ->
					data.links || data.links = []
					data.links.push {rel:"self", href: createUrl req}
					res.set('Content-Type', 'application/json')
					res.send(data)
		)

	_.each [
		{path:"/"},
		{path:"/news"},
		{path:"/newest"},
		{path:"/newcomments"},
		{path:"/ask"},
		{path:"/x", uri: (req) -> "x?fnid=#{req.query.fnid}"}, 
		{path:"/item", uri: (req) -> "item?id=#{req.query.id}"}], (item, ndx) ->
			
			app.get item.path, (req, res) ->
				params = 
					req: req
					res: res
					uri: item.uri.call req if item.uri?
				res.format
					json: ->
						callback item.path, params
					default: ->
						callback item.path, params


module.exports = routes
