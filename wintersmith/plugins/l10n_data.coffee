fs = require 'fs'
additional_languages = ['en']

module.exports = (env, callback) ->
  ### JSON_data plugin:
      Allows easy access to language specific content file
  ###

  getLocalizedContent = (contents, page, filename) ->
    # helper that returns a json that spawned template
    languageFolder = []
    langPath = page.getLocation()
    # language specific folder
    if langPath.length > 1
      # get language folder
       contentFolders = langPath.split('/')
       if contentFolders[1] and contentFolders[1] in additional_languages
        languageFolder.push(contentFolders[1])
    # path to file
    filePath = filename.split('/') || [filename]
    folders = languageFolder.concat(filePath)
    location
    # traverse to required file
    for dir in folders
      location = if location then location[dir.toString()] else contents[dir.toString()]
    return location.metadata


  getPathToRoot = (page) ->
    rootPath = ''
    langPath = page.getLocation()
    # helper returns nesting level for additional languages
    if langPath.length > 1
       contentFolders = langPath.split('/')
       if contentFolders[1] and contentFolders[1] in additional_languages
        rootPath = '../' + rootPath
    return rootPath


  # add helpers to the environment so we can use them later
  env.helpers.getLocalizedContent = getLocalizedContent
  env.helpers.getPathToRoot = getPathToRoot

  # tell the plugin manager we are done
  callback()
