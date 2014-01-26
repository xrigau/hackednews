request = require 'request'
cheerio = require 'cheerio'
sanitizeHtml = require 'sanitize-html'
Boilerpipe = require 'boilerpipe'

SummaryApi = ->
    boilerpipe = new Boilerpipe

    getSummary = (url, callback) ->
        boilerpipe.setUrl url
        boilerpipe.getText (err, text) ->
            if err
                console.log err
                callback ''
            else
                boilerpipe.getImages (err, images) ->
                    image = ''
                    if err
                        console.log err
                    else
                        console.log images
                        image = images[0]

                    result = {
                        image: image,
                        text: text
                    }
                    callback result

    # public API
    "/summary" : ({url, fn}) -> getSummary(url, fn)

module.exports = SummaryApi
