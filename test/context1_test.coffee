grunt = require 'grunt'

exports.contextualize =
  sibling_properties_override: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.sibling'), 'context1 sibling'
    test.done()

  niece_properties_override: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.niece'), 'context1 niece'
    test.equal grunt.config.get('contextTestConfig2.target1.options.niece'), 'context1 niece'
    test.done()

  contextualize_properties_override: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.replaceByContextualizeConfig1'),
      'context1 contextualize config'
    test.done()

  untargeted_properties_arent_touched: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.untargeted'), 'original value', 'should not change'
    test.done()

  other_contexts_are_ignored: (test) ->
    test.equal grunt.config.get('contextTestConfig1.options.unusedContextTriesToChangeThis'), 'original value'
    test.done()
