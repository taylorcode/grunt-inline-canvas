Datauri = require 'datauri'
ffmpeg = require 'ffmpeg'

module.exports = (grunt) ->
	
	grunt.registerMultiTask 'framesToUri', 'Convert image sequence to a file with dataUri', ->

		dest = @data.dest

		grunt.file.expand(@data.src).forEach (framesDir) ->

			s = framesDir.split '/'
			destFilename = s[s.length - 1]

			dataUris = frames: []

			grunt.file.expand(framesDir + '/**').forEach (frame) ->
				dataUris.frames.push (new Datauri frame).base64 if grunt.file.isFile frame

			grunt.file.write  dest + '/' + destFilename + '.json', JSON.stringify dataUris # write the dataUri content to the file
