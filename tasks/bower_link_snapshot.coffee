###
 * grunt-bower-link-snapshot
 * https://github.com/daemonl/grunt-bower-link-snapshot
 *
 * Copyright (c) 2015 Damien Whitten
 * Licensed under the MIT license.
###

path = require("path")
bower = require("bower")
spawn = require("child_process").spawn

startsWith = (s, w)->
	if s.substr(0, w.length) == w
		return true
	return false

class CLITool
	constructor: (dir, @binary)->
		@dir = path.resolve(dir)

	run: (cmd, args, callback)=>
		a = [cmd]
		for arg in args
			a.push(arg)
		options = 
			cwd: @dir
		child = spawn @binary, a, options
		err = ""
		data = ""
		child.stderr.on "data", (d)->
			err += d
		child.stdout.on "data", (d)->
			data += d

		child.on "close", ()->
			if err.length < 1
				err = null
			callback(err, data)


class Git extends CLITool
	constructor: (dir)->
		super(dir, "git")

	status: (callback)=>
		@run "status", ["--porcelain"], (err, res)->
			return callback(err, null) if err?
			parts = res.split("\n").filter((l)-> l.length).map (p)->
				return {status: p.substr(0, 1), path: p.substr(2)}
			callback(null, parts)

	currentTag: (callback)=>
		@run "describe", ["--exact-match", "HEAD"], (err, res)->
			if err?
				if startsWith(err, "fatal: no tag exactly matches")
					return callback(null, "")
				return callback(err, null)
			return callback(null, res.trim())

class Bower extends CLITool
	constructor: (dir)->
		super(dir, "bower")
	
	version: (str, callback)=>
		@run "version", [str], (err, res)->
			return callback(err, null) if err?
			return callback(null, res.trim())
	

module.exports = (grunt)->

	grunt.registerMultiTask 'bower_link_snapshot', 'Grunt task for snapshotting bower linked components', ()->
		done = this.async()
		# Merge task-specific and/or target-specific options with these defaults.
		options = this.options
			"packages": []
		
		setDependsVersion = (bowerPackage, version, done)->
			grunt.log.writeln "Set bower version for #{bowerPackage} to #{version}"
			bowerConfig = grunt.file.readJSON("bower.json")
			if !bowerConfig.dependencies.hasOwnProperty(bowerPackage)
				grunt.log.error "Bower package #{bowerPackage} not found in bower.json"
				return done(false)
			packagePath = bowerConfig.dependencies[bowerPackage]
			packagePath = packagePath.split("#")[0]
			packagePath = packagePath + "#" + version.substr(1)
			bowerConfig.dependencies[bowerPackage] = packagePath
			grunt.file.write("bower.json", JSON.stringify(bowerConfig, null, 2))
			done()


		pending = options.packages
		doNext = (success)->
			if success is false
				return done(success)
			if pending.length < 1
				return done()
			p = pending.pop()
			dir = "bower_components/#{p}"

			repo = new Git(dir)
			repo.status (err, res)->
				return done(err) if err?
				if res.length > 0
					grunt.log.writeln("Package #{p} had un-committed changes")
					return done(false)

				repo.currentTag (err, res)->
					if err?
						grunt.log.writeln(err)
						return done(false)
					if res != ""
						return setDependsVersion(p, res, doNext)
				
					bower = new Bower(dir)
					bower.version "minor", (err, res)->
						if err?
							grunt.log.error(err)
							return done(false)
						grunt.log.writeln "Bump bower version to", res
						setDependsVersion(p, res, doNext)
		doNext()
