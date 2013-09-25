# grunt-contextualize
# https://github.com/osteele/grunt-contextualize
#
# Copyright (c) 2013 Oliver Steele
# Licensed under the MIT license.

module.exports = (grunt) ->
  grunt.initConfig
    coffeelint:
      all: ['**/*.coffee', '!node_modules/**/*']
      options:
        max_line_length: { value: 120 }

    contextualize:
      options:
        verbose: true
      context1:
        contextTestConfig1:
          options:
            replaceByContextualizeConfig1: 'context1 contextualize config'
      unusedContext:
        contextTestConfig1:
          options:
            unusedContextTriesToChangeThis: 'changed'

    nodeunit:
      context1: 'test/context1_test.coffee'
      context2: 'test/context2_test.coffee'
      context3: 'test/context3_test.coffee'

    contextTestConfig1:
      options:
        untargeted: 'original value'
        sibling: 'replace by sibling'
        sibling$context1: 'context1 sibling'
        sibling$context2: 'context1 sibling'
        niece: 'replace by niece'
        cousin: 'replace by cousin'
        replaceByContextualizeConfig1: 'replace by contextualize config'
        unusedContextTriesToChangeThis: 'original value'
        _context1:
          niece: 'context1 niece'
        _unusedContext:
          unusedContextTriesToChangeThis: 'changed'
      _context2:
        options:
          cousin: 'context2 cousin'

    contextTestConfig2:
      target1:
        options:
          niece: 'replace by niece'
          cousin: 'replace by cousin'
          _context1:
            niece: 'context1 niece'
        _context2:
          options:
            cousin: 'context2 cousin'
      _context3:
        target1:
          options:
            cousin: 'context3 cousin'

  grunt.loadTasks 'tasks'

  require('load-grunt-tasks')(grunt)

  grunt.registerTask 'test', [
    'contextualize:context1', 'nodeunit:context1',
    'contextualize:context2', 'nodeunit:context2',
    'contextualize:context3', 'nodeunit:context3',
  ]
  grunt.registerTask 'default', ['coffeelint', 'test']
