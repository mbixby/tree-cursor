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
        files: [
          expand: yes
          cwd: "lib"
          src: "**/*.coffee"
          dest: ".tmp/lib"
          ext: ".js"
        ]
      test:
        files: [
          expand: yes
          cwd: "test"
          src: "**/*.coffee"
          dest: ".tmp/test"
          ext: ".js"
        ]

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
        dest: ".tmp/test_components.js"
      test:
        src: [".tmp/test/spec.js"]
        dest: ".tmp/test_spec.js"

    copy:
      test:
        files: [
          expand: yes
          cwd: "."
          dest: ".tmp"
          src: ["components/mocha/mocha.css"]
        ]

    watch:
      options:
        livereload: yes

      coffee:
        files: ["lib/**/*.coffee"]
        tasks: ["coffee:dist"]

      coffeeTest:
        files: ["test/**/*.coffee"]
        tasks: ["coffee:test"]

      neuterTest:
        files: [".tmp/lib/**/*.js", ".tmp/test/**/*.js"]
        tasks: ["neuter:test"]

    connect:
      options:
        port: 35729
        hostname: "localhost"
      test:
        options:
          middleware: grunt.middleware (connect) ->
            [connect.livereloadFolders(), ".tmp", "test"]

    open:
      server:
        path: "http://localhost:<%= connect.options.port %>"

    mocha:
      all:
        run: yes
        urls: ["http://localhost:<%= connect.options.port %>/index.html"]


  # Tasks
        
  grunt.registerTask "default", ["clean", "bower", "coffee:dist", "neuter:dist"]
  grunt.registerTask "test", ["clean:server", "bower", "coffee", "neuter:testComponents", "neuter:test", "copy:test",  "connect:test", "watch"]
