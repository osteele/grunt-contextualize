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
      verbose: false

    taskName = this.name
    verbose = if options.verbose
        (msg) -> grunt.log.writeln msg
      else
        (msg) -> grunt.verbose.writeln msg

    currentContextKey = "#{options.prefix}#{contextName}"

    isContextKey = (propertyName) ->
      return propertyName.substring(0, options.prefix.length) == options.prefix

    # Recurse through `obj`, looking for properties that name the current context
    # according to the scheme in contextKey and applying `recursiveMerge` to them.
    installContexts = (obj, propertyPath) ->
      recursiveMerge obj, obj[currentContextKey], propertyPath if currentContextKey of obj
      for propertyName, value of obj
        if grunt.util.kindOf(value) == 'object' and not isContextKey(propertyName)
          installContexts value, propertyPath.concat(propertyName)

    recursiveMerge = (target, source, propertyPath) ->
      for propertyName, value of source
        currentPath = propertyPath.concat(propertyName)
        if propertyName of target and grunt.util.kindOf(value) == 'object'
          recursiveMerge target[propertyName], value, currentPath
        else
          verbose "#{taskName}: replacing #{currentPath.join('.')}=#{value} (was #{target[propertyName]})"
          target[propertyName] = value

    contextData = grunt.config.getRaw([this.name, contextName])
    installContexts grunt.config.data, []
    recursiveMerge grunt.config.data, contextData, [] if contextData

    return true
