# grunt-contextualize
# https://github.com/osteele/grunt-contextualize
#
# Copyright (c) 2013 Oliver Steele
# Licensed under the MIT license.

module.exports = (grunt) ->
  grunt.initConfig
    coffeelint:
      app: ['lib/*.coffee']
      gruntfile: 'Gruntfile.coffee'
      options:
        max_line_length: { value: 120 }

    contextualize:
      options:
        verbose: true
      context1:
        contextTestConfig1:
          options:
            replaceByContextualizeConfig1: 'replaced by contextualize config from context1'
      unusedContext:
        contextTestConfig1:
          options:
            unusedContextTriesToChangeThis: 'changed'

    nodeunit:
      _context1:
        tests: 'test/context1_test.coffee'
      _context2:
        tests: 'test/context2_test.coffee'
      _context3:
        tests: 'test/context3_test.coffee'

    contextTestConfig1:
      options:
        untargeted: 'original value'
        niece: 'replace by niece'
        cousin: 'replace by cousin'
        replaceByContextualizeConfig1: 'replace by contextualize config'
        unusedContextTriesToChangeThis: 'original value'
        _context1:
          niece: 'replaced by niece from context1'
        _unusedContext:
          unusedContextTriesToChangeThis: 'changed'
      _context2:
        options:
          cousin: 'replaced by cousin from context2'

    contextTestConfig2:
      target1:
        options:
          niece: 'replace by niece'
          cousin: 'replace by cousin'
          _context1:
            niece: 'replaced by niece from context1'
        _context2:
          options:
            cousin: 'replaced by cousin from context2'
      _context3:
        target1:
          options:
            cousin: 'replaced by cousin from context3'

  grunt.loadTasks 'tasks'

  require('load-grunt-tasks')(grunt)

  grunt.registerTask 'test', [
    'contextualize:context2', 'nodeunit',
    'contextualize:context2', 'nodeunit',
    'contextualize:context3', 'nodeunit',
  ]
  grunt.registerTask 'default', ['coffeelint', 'test']
