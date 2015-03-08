ffmpeg = require 'ffmpeg'
RSVP = require 'rsvp'

module.exports = (grunt) ->

	extractFrames = (filename, dest) ->

	grunt.registerMultiTask 'extractVideoFrames', 'Extract video frames with ffmpeg.', ->

		done = @async()
		dest = @data.dest
		extractors = []

		grunt.file.expand(@data.src).forEach (video) ->

			process = new ffmpeg video
			process.then (video) ->

				splitVideo = video.file_path.split '/'
				filename = splitVideo[splitVideo.length - 1].split('.')[0]

				extractors.push new RSVP.Promise (resolve, reject) ->
					video.fnExtractFrameToJPG dest + '/' + filename, {}
					, (error, files) ->
						grunt.log.ok 'frames extracted: ' + filename
						return reject(error) if error
						resolve()

				RSVP.all(extractors).then ->
					grunt.log.ok 'complete!'
					done()
				.catch (reason) ->
					grunt.log.error reason

				grunt.log.ok 'video file read: ' + filename

			, (err) ->
				grunt.log.error err