# Grunt Inline Canvas and CanvasVideo

### Purpose
The purpose of these utilities is to play video in-line on mobile devices.

### How does it work?

The grunt task `extractVideoFrames` uses ffmpeg to convert your videos to frames. Each frame is then read and converted to a base64 representation using the task `framesToUri`, and all of the base64 frames are added a json file.

The JavaScript service `CanvasVideo` processes the json file with base64 and paints the frames onto a canvas.

## Running the Task

Place the videos you want to convert in: `src/assets/video`.

Next, execute:

	$ grunt extractVideo

To convert your images to frames and then:

	$ grunt convertFrames

To convert your frames to dataURI in a json file. The resulting json files will appear in `target/assets/data-uris/mobile`, this is configurable in the `framesToUri` task in your `Gruntfile`.

## Playing the Video

After you've converted your videos to json files with dataURI frames, you can use the `CanvasVideo` service to play your videos.

#### Example:

	var myCanvasVideo = new CanvasVideo(canvasElem, target/assets/data-uris/mobile/sample-video.json', options)

	myCanvasVideo.play()

	myCanvasVideo.pause()


### Options

Options can be passed into the third parameter of the `CanvasVideo` constructor. The options passed in will override the defaults:

	{
	    frameRate: 30,
	    width: 400,
	    height: 300,
	    imageEncoding: 'png'
	}

## Set Up Video to DataURI Conversion

### Install Node Dependencies
`
npm install
`

### Install Video to dataURI Utilities

#### FFMPEG

`
brew install ffmpeg
`

Converts video frames to PNG image sequences (THIS IS NOT DEFAULT BEHAVIOR, SEE BELOW "FFMPEG Minor Hack")

#### GraphicsMagick
`
brew install graphicsmagick
`
Converts PNG image sequences to JPEG

### FFMPEG Minor Hack

By default, the node ffmpeg module issues the command to ffmpeg to convert the image sequences to JPEG's. This produces terribly quality, especially with high frame rates and resolution. Luckily this is easy to fix. This change must be implemented before use:

##### node_modules/ffmpeg/lib/video.js line 765

```javascript
settings.file_name = path.basename(settings.file_name, path.extname(settings.file_name)) + '_%d.jpg';
```

Please change `.jpg` to `.png`

## Build Process

To convert the Videos to dataURI, execute these commands (in order, whenever needed):

Compile all coffeescript and sass files, sync project files with target.

```
grunt
```
Extract video frames to PNG
```
grunt extractVideo
```
Create a copy of the frames, renaming them to retain order
```
grunt copy
```
Convert the frames to JPEG, compress to target resolutions (see responsive_images task), remove redundant data with smushit, convert to dataURI files.
```
grunt convertFrames
```