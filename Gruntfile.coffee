module.exports = (grunt) ->

  grunt.loadTasks('./custom-tasks');

  grunt.initConfig
  
    pkg: grunt.file.readJSON 'package.json'

    extractVideoFrames:
      default:
        src: ['src/assets/video/*.mp4']
        dest: 'src/assets/video-frames/original'

    copy:
      rename:
        expand: true
        cwd: 'src/assets/video-frames/original'
        src: ['**']
        dest: 'src/assets/video-frames/renamed'
        filter: 'isFile'
        rename: (dest, src) ->
          pad = (num, size) ->
            s = num + ''
            s = '0' + s  while s.length < size
            s
          parts = src.split '/'
          split = parts[1].split('_')[1].split '.'
          dest + '/' + parts[0] + '/' + (pad split[0], 4) + '.' + split[1]

    convertImage:
      default:
        ext: 'jpg'
        groupSize: 50 # process no more than x images at once, or will cause overload!
        src: 'src/assets/video-frames/renamed'
        dest: 'src/assets/video-frames/converted'

    responsive_images:
      mobile:
        options:
          sizes: [
            width: 568
            name: 'mobile'
            quality: 70
          ]
        files: [
          expand: true
          cwd: 'src/assets/video-frames/converted'
          src: '**/*.{jpg,gif,png}'
          custom_dest: 'src/assets/video-frames/resized/uncompressed/{%= name %}/{%= path %}'
        ]

    smushit:
      default:
        src: ['src/assets/video-frames/resized/uncompressed/**/*.{jpg,gif,png}']
        dest: 'src/assets/video-frames/resized/compressed/'

    framesToUri:
      mobile:
        src: ['src/assets/video-frames/resized/compressed/mobile/*']
        dest: 'target/assets/data-uris/mobile'
      # desktop:
      #   src: ['src/assets/video-frames/renamed/*']
      #   dest: 'target/assets/data-uris/desktop'

    clean: ['target']

  # load all tasks declared in devDependencies
  Object.keys(require('./package.json').devDependencies).forEach (dep) ->
    grunt.loadNpmTasks dep if dep.substring(0, 6) is 'grunt-'
  
  grunt.registerTask 'extractVideo', [
    'extractVideoFrames'
  ]

  # grunt copy must be run next
  grunt.registerTask 'convertFrames', [
    'convertImage'
    'responsive_images'
    'smushit'
    'framesToUri'
  ]


