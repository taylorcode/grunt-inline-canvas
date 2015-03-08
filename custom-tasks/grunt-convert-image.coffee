gm = require 'gm'
RSVP = require 'rsvp'
_ = require 'underscore'

# This converts in batches, because it fails if you load more than a certain number of images into memory.

module.exports = (grunt) ->

	grunt.registerMultiTask 'convertImage', 'Convert images to another filetype.', ->

		done = @async()
		dest = @data.dest
		ext = @data.ext
		groupSize = @data.groupSize or 50

		return grunt.log.error 'ext must be defined' if not ext

		converters = []
		convertGroups = []

		grunt.file.recurse @data.src, (abspath, rootdir, subdir, filename) ->
			
			return if filename.charAt(0) is '.'

			newFilename = filename.replace filename.split('.').pop(), ext
			newDir = dest + '/' + subdir

			grunt.file.mkdir newDir

			converters.push ((src, dest) ->
				->
					new RSVP.Promise (resolve, reject) ->
						gm(src).write dest, (err) ->
							return reject err if err
							resolve()
			) abspath, newDir + '/' + newFilename

		# group the converters in arrays of 
		convertGroups = ( (group, max, n, convertGroups) ->
			convertGroups.push []
			converters.forEach (converter) ->
				n++
				if n > max
					convertGroups.push []
					group++
					n = 0
				convertGroups[group].push converter
			convertGroups
		) 0, groupSize, 0, []

		processGroups = (index, convertGroups) ->

			convertPromises = []

			# console.log 'convert group at index ' + index + ' with length' + convertGroups[index].length

			convertGroups[index].forEach (converter) ->
				convertPromises.push converter()

			RSVP.all(convertPromises).then ->
				grunt.log.ok 'converted group ' + (index + 1) + ' of ' + convertGroups.length
				newIndex = index + 1
				return done() if not convertGroups[newIndex]
				processGroups newIndex, convertGroups

		processGroups 0, convertGroups # start recursive processing
