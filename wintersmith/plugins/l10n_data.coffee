fs = require 'fs'

module.exports = (env, callback) ->
  ### JSON_data plugin:
      Allows easy access to language specific content file
  ###

  getLocalizedContent = (contents, page, filename) ->
    # helper that returns a json that spawned template
    folders = []
    langPath = page.getLocation()
    # language specific folder
    if langPath.length > 1
      # trim last slash
      langPath = langPath.substr(0, langPath.length-1)
      # get language folder
      folders = langPath.split('/')
    # path to file
    filePath = filename.split('/') || [filename]
    folders = folders.concat(filePath)
    location
    # traverse to required file
    for dir in folders
      location = if location then location[dir.toString()] else contents[dir.toString()]
    return location.metadata

  # add the article helper to the environment so we can use it later
  env.helpers.getLocalizedContent = getLocalizedContent

  # tell the plugin manager we are done
  callback()
