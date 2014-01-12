_ = require "underscore"

NewsRoutes = (app, api) ->
	
	callback = (fnName, {uri, req, res}) ->
		console.log fnName.toString()
		api[fnName](
			uri: if uri then uri()
			fn: (data) ->
					data.currentPage || data.currentPage = req.url.replace("/", "")
					res.set('Content-Type', 'application/json')
					res.send(data)
		)

	_.each [
		{path:"/"},
		{path:"/news"},
		{path:"/news2"},
		{path:"/newest"},
		{path:"/newcomments"},
		{path:"/ask"},
		{path:"/x", uri: (req) -> "/x?fnid=#{req.query.fnid}" },
		{path:"/user", uri: (req) -> "/user?id=#{req.query.id}" },
		{path:"/item", uri: (req) -> "/item?id=#{req.query.id}"},
		{path:"/submitted", uri: (req) -> "/submitted?id=#{req.query.id}"},
		{path:"/threads", uri: (req) -> "/threads?id=#{req.query.id}"}],
		(item, ndx) ->
			app.get item.path, (req, res) ->
				params = 
					req: req
					res: res
					uri:  if item.uri
							-> 
								item.uri(req)
				res.format
					json: ->
						callback item.path, params
					default: ->
						json()


module.exports = NewsRoutes
