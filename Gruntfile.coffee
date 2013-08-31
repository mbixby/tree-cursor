"use strict"

module.exports = (grunt) ->
  grunt = (require 'grunt-utilities') grunt

  grunt.initConfig
    name: 'tree_search'

    bower:
      options:
        install: no
        targetDir: '.tmp'
        cleanup: no
        layout: (type, component) ->
          (require 'path').join 'components', component
      install: {}

    clean:
      dist:
        files: [
          dot: yes
          src: [".tmp"]
        ]
      server: ".tmp"

    coffee:
      options:
        bare: yes
      dist:
        expand: yes
        cwd: "lib"
        src: "**/*.coffee"
        dest: ".tmp/lib"
        ext: ".js"
      test:
        expand: yes
        cwd: "test"
        src: "**/*.coffee"
        dest: ".tmp/test"
        ext: ".js"

    jshint:
      all: [".tmp/lib/**/*.js", ".tmp/test/**/*.js"]

    neuter:
      options:
        template: "{%= src %}"
        loadPaths: ['.tmp', '.tmp/lib', '.tmp/components', '.tmp/test']
        filepathTransform: require 'neuter-grunt-resolve-path'
      dist:
        src: [".tmp/lib/<%= name %>.js"]
        dest: "dist/<%= name %>.js"
      testComponents:
        src: [".tmp/test/components.js"]
        dest: ".tmp/test/combined-components.js"
      test:
        src: [".tmp/test/spec.js"]
        dest: ".tmp/test/combined-spec.js"

    copy:
      test:
        files: [
          expand: yes
          cwd: "."
          dest: ".tmp"
          src: ["components/mocha/mocha.css", "test/*.html" ]
        ]

    watch:
      options:
        livereload: "<%= connect.options.port %>"
        # Because we're changing config in grunt.event.on('watch') below,
        # we can't spawn processes
        spawn: no

      test:
        files: ["{lib,test}/**/*.coffee"]
        tasks: ["coffee", "neuter:test"]

    connect:
      options:
        port: 35729
        hostname: "localhost"
      test:
        options:
          middleware: grunt.middleware -> [".tmp", ".tmp/test"]

    open:
      server:
        path: "http://localhost:<%= connect.options.port %>"

    mocha:
      all:
        run: yes
        src: [ '.tmp/test/index.html' ]

  # Compile only changed files
  grunt.event.on 'watch', (action, filepath) ->
    for target in ["dist", "test"] when filepath.match /.coffee/
      cwd = grunt.config "coffee.#{target}.cwd"
      filepath = filepath.replace "#{cwd}/", ""
      console.log "-- #{filepath} -- #{target}"
      grunt.config "coffee.#{target}.src", filepath

  # Tasks 
  grunt.registerTask "default", ["clean", "bower", "coffee:dist", "neuter:dist"]
  grunt.registerTask "prepareForTesting", ["clean:server", "bower", "coffee", "neuter:testComponents", "neuter:test", "copy:test", "connect:test"]
  grunt.registerTask "test", ["prepareForTesting", "watch:test"]
  grunt.registerTask "test:shell", ["prepareForTesting", "mocha"]
