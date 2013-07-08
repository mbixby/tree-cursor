"use strict"

pathUtils = require("path")
glob = require("glob")
fs = require("fs")

module.exports = (grunt) ->
  grunt = (require 'grunt-utilities') grunt

  grunt.initConfig
    name: 'tree_search'

    bower:
      install:
        options:
          install: yes
          targetDir: '.tmp'
          cleanup: no
          layout: (type, component) ->
            (require 'path').join 'components', component

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp"]
        ]

    coffee:
      dist:
        files: [
          expand: true
          cwd: "lib"
          src: "**/*.coffee"
          dest: ".tmp/lib"
          ext: ".js"
        ]

    neuter:
      dist:
        options:
          template: "{%= src %}"
          loadPaths: ['.tmp', '.tmp/lib', '.tmp/components']
          filepathTransform: require 'neuter-grunt-resolve-path'
        src: [".tmp/lib/<%= name %>.js"]
        dest: "dist/<%= name %>.js"

  grunt.registerTask "default", ["clean", "coffee", "neuter"]

  # TOOD Test
  # grunt.registerTask "default", ["clean", "bower", "coffee", "neuter"]  
