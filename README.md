# grunt-contextualize

This plugin overrides configuration properties based on the current context,
 in order to re-use a single set of plugin targets for multiple contexts.

This is particularly useful when a plugin is already configured with multiple targets -- for example, to
create one JavaScript or CSS file for the whole site, and one for each set of pages on a complex site.
In these cases, creating and maintaining a distinct configuration for each combination of components
(e.g. site-wide vs. home page) with build configurations (development vs. distribution) is burdensome.

This plugin supports three modes (which can be mixed and matched):

1. **Contextual properties** override the values of properties they're next to.
For example, `options: {pretty: true; pretty$release: false}` in a plugin configuration
lets the corresponding plugin task see `pretty` as `true` when the `contextualize` task isn't run,
but as `false` when the task follows the `contextualize:release` task.
2. With **local configuration**, contexts are specified inside each plugin's configuration, alongside the values that
are being modified. For example, `options: {pretty: true; _release: {pretty: false}}`.
3. With a **global configuration**, contexts are specified inside the `contextualize` section of the grunt configuration,
and their values are copied into other tasks' configurations.

See the bottom of this README for examples of using each mode to modify SASS and Jade configurations.

Alternatives:

* Grunt [templates](http://gruntjs.com/configuring-tasks#templates) work great when the configuration property is a string.
Unfortunately, templates can't expand into non-string values, such as boolean flags.
* Grunt [options](http://gruntjs.com/api/grunt.option) are available when `grunt.initConfig` is called, and can therefore be used *outside* of string interpolation.
However, the use of options requires that you specify them as command-line options, in conjunction with the task target(s), in the grunt command line.
Unfortunately, command-line options can't be encapsulated in the target definitions.
(A target can set option values, but then it's too late for this to affect configuration defined in the initial call to `grunt.initConfig`.)
* I wanted [grunt-context](https://github.com/indieisaconcept/grunt-context) to work, but [its author says it's defunct](https://github.com/indieisaconcept/grunt-context/issues/12).
In time-honored weekend project manner, I decided I'd rather write my own with a different features than understand how to fix it.
* [grunt-reconfigure](https://github.com/jlindsey/grunt-reconfigure) handles the "global configuration" case. I didn't discover that plugin until after I had written this one, and had decided I liked the *contextual properties*
and *local configuration* by then.

## Getting Started
This plugin requires Grunt `~0.4.x`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install grunt-contextualize --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-contextualize');
```

## The "contextualize" task

### Overview
In your project's Gruntfile, do one or more of the following.

With any of these configurations:

* The `contextualize:context1` task will replace the value of `somePlugin.options.anOption` by `1`; and
* the `contextualize:context2` task will replace the value of `somePlugin.options.anOption` by `2`.

#### Contextual Properties
Sprinkle properties named `"#{propertyName}$#{context}"` into your grunt configuration.

```js
grunt.initConfig({
  somePlugin: {
    options: {
      anOption: 0
      anOption$context1: 1
      anOption$context2: 2
    },
})
```

#### Local configuration
Add properties named e.g. `'_context1'` (`'_'` plus a context name) alongside the configuration options for *other* plugins.

This context property can be inside the object that contains the properties it replaces:

```js
grunt.initConfig({
  somePlugin: {
    options: {
      anOption: 0
      _context1: {
        anOption: 1
      },
      _context2: {
        anOption: 2
      }
    }
  }
})
```

Or it can be inside a parent of this object:

```js
grunt.initConfig({
  somePlugin: {
    options: {
      anOption: 0
    },
    _context1: {
      options: {
        anOption: 1
      }
    },
    _context2: {
      options: {
        anOption: 2
      }
    }
  }
})
```

#### Global Configuration
Add a section named `contextualize` to the data object passed into `grunt.initConfig()`.

```js
grunt.initConfig({
  contextualize: {
    options: {
      // Task-specific options go here.
    },
    context1: {
      target1: {
        property1: 'replacement 1'
      }
    },
    context2: {
      target1: {
        property1: 'replacement 2'
      }
    }
  }
})
```

### Options

#### options.infix
Type: `String`
Default value: `'$'`

The separator between a contextualized property and its context.
Where contextualize looks for `'name$context1'` in the examples, a value of `'_'` for `options.prefix` would
cause it to look for `'name_context1'` instead.

`'.'` or `':'` would be nice infix values, but using them would require you to quote your property names;
e.g. `{'name.context1': ...}` instead of `{name.context1: ...}`.

#### options.prefix
Type: `String`
Default value: `'_'`

The values keyed by property names that begin with this prefix are merged into nearby data.
Where contextualize looks for `'_context1'` in the examples, a value of `'$'` for `options.prefix` would
cause it to look for `'$context1'` instead.

`'.'` or `':'` would be nice prefix values, but using them would require you to quote your property names;
e.g. `{':context1': ...}` instead of `{_context1: ...}`.
Also, '`_`' has the feature that grunt ignores it when used at the top level of a multitask configuration,
where it could otherwise be mistaken for the name of a multitask target.

#### options.verbose
Type: `boolean`
Default value: `false`

Display information about which properties are replaced.
This has the same effect on this plugin as the `--verbose` option to `grunt` does, but
unlike that option it only affects this plugin.

### Usage Examples

#### Local Configurations
In this example, `grunt build` will build jade files *with* the `pretty` option, and *uncompressed*
sass files *with* `sourcemap`. into the *`build`* directory.
`grunt build:release` will build jade files *without* `pretty`, and *compressed* sass files *without*
`sourcemap`, into the *`release`* directory.

```js
grunt.initConfig({
  directories: {
    build: '<%= directories.dev %>',
    dev: 'build',
    release: 'release',
    _release: {
      build: '<%= directories.release %>'
    }
  },

  jade: {
    app: {
      expand: true,
      cwd: 'app',
      src: '**/*.jade',
      dest: '<%= directories.build %>',
      ext: '.html'
    }
    options: {
      pretty: true,
      _release: {
        pretty: false
      }
    }
  },

  sass: {
    app: {
      expand: true,
      cwd: 'app',
      dest: '<%= directories.build %>',
      src: ['css/**.scss', '!css/_*'],
      ext: '.css',
      filter: 'isFile'
    }
    options: {
      sourcemap: true,
      _release: {
        sourcemap: false
        style: 'compressed'
      }
    }
  }
})

grunt.registerTask 'build', ['jade', 'sass']
grunt.registerTask 'build:release', ['context:release', 'build']
```

#### Global Configuration
This configuration has the same effect as the preceding example.

```js
grunt.initConfig({
  contextualize: {
    release: {
      directories: {
        build: '<%= directories.release %>'
      },
      jade: {
        app: {
          options: {
            pretty: false
          }
        }
      },
      sass: {
        app: {
          options: {
            sourcemap: false
            style: 'compressed'
          }
        }
      }
    }
  }
  directories: {
    build: '<%= directories.dev %>',
    dev: 'build',
    release: 'release'
  },

  jade: {
    app: {
      expand: true,
      cwd: 'app',
      src: '**/*.jade',
      dest: '<%= directories.build %>',
      ext: '.html'
    }
    options: {
      pretty: true
    }
  },

  sass: {
    app: {
      expand: true,
      cwd: 'app',
      dest: '<%= directories.build %>',
      src: ['css/**.scss', '!css/_*'],
      ext: '.css',
      filter: 'isFile'
    }
    options: {
      sourcemap: true
    }
  }
})

grunt.registerTask 'build', ['jade', 'sass']
grunt.registerTask 'build:release', ['context:release', 'build']
```

See this project's Gruntfile for additional (CoffeeScript) examples.

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History

* September 24, 20012 -- initial release
