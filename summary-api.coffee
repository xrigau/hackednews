request = require 'request'

SummaryApi = (readabilityToken) ->
    getSummary = (url, callback) ->
        options = {
            url: 'http://readability.com/api/content/v1/parser',
            qs: {
                url: url,
                token: readabilityToken
            }
        }
        request.get options, (error, response, body) ->
            if error
                console.log error
                callback ''
            else
                callback body

    # public API
    "/summary" : ({url, fn}) -> getSummary(url, fn)

module.exports = SummaryApi
