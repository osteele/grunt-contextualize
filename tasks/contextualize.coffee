# grunt-contextualize
# https://github.com/osteele/grunt-contextualize
#
# Copyright (c) 2013 Oliver Steele
# Licensed under the MIT license.

path = require 'path'

module.exports = (grunt) ->
  description = grunt.file.readJSON(path.join(path.dirname(module.filename), '../package.json')).description

  grunt.registerTask 'contextualize', description, (contextName) ->
    options = this.options
      prefix: '_'
      separator: '$'
      verbose: false

    #
    # Logging and Reporting
    #
    taskName = this.name
    verbose = if options.verbose
        (msg) -> grunt.log.writeln msg
      else
        (msg) -> grunt.verbose.writeln msg

    #
    # Recognizing context keys (also inlined in following section methods)
    #
    currentContextKey = "#{options.prefix}#{contextName}"

    isContextKey = (propertyName) ->
      return propertyName.indexOf(options.prefix) == 0

    isReplacementKey = (propertyName) ->
      return propertyName.indexOf(options.separator) > 0

    #
    # Replace property values
    #

    replacePropertyValue = (target, propertyName, value, propertyPath) ->
      verbose "#{taskName}: replacing #{propertyPath.join('.')}=#{value} (was #{target[propertyName]})"
      target[propertyName] = value

    recursiveMerge = (target, source, targetPath) ->
      for propertyName, value of source
        propertyPath = targetPath.concat(propertyName)
        if propertyName of target and grunt.util.kindOf(value) == 'object'
          recursiveMerge target[propertyName], value, propertyPath
        else
          replacePropertyValue target, propertyName, value, propertyPath

    # Recurse through `obj`, looking for properties that name the current context
    # according to the scheme in contextKey and applying `recursiveMerge` to them.
    installContexts = (target, targetPath) ->
      recursiveMerge target, target[currentContextKey], targetPath if currentContextKey of target
      for propertyName, value of target
        propertyPath = targetPath.concat(propertyName)
        if isReplacementKey(propertyName)
          components = propertyName.split(options.separator)
          if components.length == 2 and components[1] == contextName
            propertyName = components[0]
            replacePropertyValue target, components[0], value, propertyPath
        else if grunt.util.kindOf(value) == 'object' and not isContextKey(propertyName)
          installContexts value, propertyPath

    #
    # Main body
    #

    contextData = grunt.config.getRaw([this.name, contextName])
    installContexts grunt.config.data, []
    recursiveMerge grunt.config.data, contextData, [] if contextData

    return true
