grunt = require 'grunt'

exports.contextualize =
  adjacent_properties_override: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.niece'), 'replaced by niece from context1'
    test.equal grunt.config.get('contextTestConfig2.target1.options.niece'), 'replaced by niece from context1'
    test.done()

  contextualize_properties_override: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.replaceByContextualizeConfig1'),
      'replaced by contextualize config from context1'
    test.done()

  untargeted_properties_arent_touched: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.untargeted'), 'original value', 'should not change'
    test.done()

  other_contexts_are_ignored: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.unusedContextTriesToChangeThis'), 'original value'
    test.done()
