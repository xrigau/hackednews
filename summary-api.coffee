pm = require 'pagemunch'

SummaryApi = (apiKey) ->
	pm.set {key: apiKey}

	getSummary = (url, callback) ->
		pm.summary url, (err, data) -> 
			if err
				console.log err
			else
				callback(data)

	# public API
	"/summary" : ({url, fn}) -> getSummary(url, fn)

module.exports = SummaryApi
