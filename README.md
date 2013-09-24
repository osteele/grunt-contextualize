# grunt-contextualize

This plugin modifies properties, in order to re-use a single set of plugin targets
for use in multiple contexts.

This is particularly useful when a plugin is already configured with multiple targets -- for example, to
create one JavaScript library for the whole site, and one for each set of pages, on a complex site; and
similarly for creating several sets of CSS files, each from multiple source files.
In these cases, creating a distinct configuration for e.g. each combination of components (e.g. site-wide vs. home page)
with build configurations (development vs. distribution).

This plugin supports two modes:

1. With a "global configuration", contexts are specified inside the `contextualize` section of the grunt configuration,
and their values are copied into other tasks' configurations.
2. With "local configuration", contexts are specified inside each plugin's configuration, alongside the values that
are being modified.

See the bottom of this README for examples of using each mode to modify SASS and Jade configurations.

Alternatives:

* Grunt [templates](http://gruntjs.com/configuring-tasks#templates) can be used for this when the configuration property is a string. Unfortunately, templates can't
expand into non-string values such as boolean flags.
* Grunt [options](http://gruntjs.com/api/grunt.option) are available when `grunt.initConfig` is called, and can therefore be used *outside* of string interpolation. The uses of options requires that you specify them as command-line options, in conjunction with the task target(s), in the grunt command line. I wanted something that could be bundled into just a targets. (A target can *set* option values, but then it's too late for this to affect the initial call to `grunt.initConfig`)
* I wanted [grunt-context](https://github.com/indieisaconcept/grunt-context) to work, but [it's defunct](https://github.com/indieisaconcept/grunt-context/issues/12), and in time-honored weekend project manner I decided I'd rather add my own with a different features than understand how to fix it.
* [grunt-reconfigure](https://github.com/jlindsey/grunt-reconfigure) handles the "global configuration" case. I didn't discover that plugin until after I had written this one, and had already decided I liked the local configuration mode better anyway.

## Getting Started
This plugin requires Grunt `~0.4.1`

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

With any of these configurations,
the `contextualize:context1` task will replace the `context1.target1.property1` by `'replacement 1`',
and the `contextualize:context2` task will replace the `context1.target1.property1` by `'replacement 2`'.


1\. Add a section named `contextualize` to the data object passed into `grunt.initConfig()`.

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

2\. Add properties named e.g. `'_context1'` (`'_'` plus a context name) alongside the configuration options for *other* plugins.

2a\. This context property can be inside the object that contains the properties it replaces:

```js
grunt.initConfig({
    plugin: {
      options: {
        optionName: 'value'
        _context1: {
          optionName: 'replacement 1'
        },
        _context2: {
          optionName: 'replacement 2'
        }
      }
    }
})
```

2b\. Or it can be inside a parent of this object:

```js
grunt.initConfig({
    plugin: {
      options: {
        optionName: 'value'
      },
      _context1: {
        options: {
          optionName: 'replacement 1'
        }
      },
      _context2: {
        options: {
          optionName: 'replacement 2'
        }
      }
    }
})
```

### Options

#### options.prefix
Type: `String`
Default value: `'_'`

The values keyed by property names that begin with this prefix are merged into nearby data.
See the examples above.
Where contextualize looks for `'_context1'` in the examples, a value of `'$'` for `options.prefix` would
cause it to look for `'$context1'` instead, etc.

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
