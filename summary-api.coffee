request = require 'request'
md = require 'html-md'

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
                res = JSON.parse body
                res.content = md res.content
                res.content = res.content.replace /!\[(.*)?\]\((.*)?\)/g, ""
                callback res

    # public API
    "/summary" : ({url, fn}) -> getSummary(url, fn)

module.exports = SummaryApi
