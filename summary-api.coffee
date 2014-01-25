pm = require 'pagemunch'

request = require 'request'
cheerio = require 'cheerio'
# md = require 'html-md'

SummaryApi = (apiKey) ->
    pm.set {key: apiKey}

    getSummary = (url, callback) ->
        pm.summary url, (err, data) ->
            if err
                console.log err
            else
                callback(data)

    getSummaryMarkdown = (url, callback) ->
        request url, (error, response, body) ->
            if error
                console.log error
                callback('')
            else
                $ = cheerio.load(body)
                result = {
                    text: $('body').html(),
                    image: ''
                }
                callback(result)

    # public API
    "/summary" : ({url, fn}) -> getSummary(url, fn)
    "/summary-md" : ({url, fn}) -> getSummaryMarkdown(url, fn)

module.exports = SummaryApi
