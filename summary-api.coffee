request = require 'request'
cheerio = require 'cheerio'
sanitizeHtml = require 'sanitize-html'

# md = require 'html-md'

SummaryApi = ->
    getSummary = (url, callback) ->
        request url, (error, response, body) ->
            if error
                console.log error
                callback('')
            else
                $ = cheerio.load(sanitizeHtml(body))
                result = {
                    text: $.html(),
                    image: ''
                }
                callback(result)

    # public API
    "/summary" : ({url, fn}) -> getSummary(url, fn)

module.exports = SummaryApi
