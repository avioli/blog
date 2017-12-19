# FFmpeg for web videos

Today I found an amazing book/article by Addy Osmani - [Essential Image Optimizations](https://images.guide)

It talks image optimisation on the web.

TIL about: [Guetzli](https://github.com/google/guetzli) - a slow perceptual JPEG encoder from Google.

It made me consider again WebP as an alternative for supported browsers, which I should add to may workflow.

Also made me think and experiment with html5 videos:

### First install ffmpeg

On Mac OS with [homebrew](https://brew.sh) it is as easy as:

```
brew install ffmpeg --with-tools --with-libvpx

# or with more stuff:
brew install ffmpeg --with-ffplay --with-tools --with-x265 --with-faac --with-fdk-aac --with-libvpx --with-libvorbis
```

On any other platform (that I do not use) try to follow the [official compilation guide](https://trac.ffmpeg.org/wiki/CompilationGuide). I would probably first try with [docker](https://www.docker.com): [jrottenberg/ffmpeg](https://hub.docker.com/r/jrottenberg/ffmpeg/), but it could be tricky to run.

### MP4 - Scale down video to 720 height and 24 fps

In my case the input file had only video stream, so I didn't care about any audio.

```
ffmpeg -y -i FILENAME.mov -c:v libx264 -minrate 1M -b:v 1828K -vf 'scale=-1:720' -r 24 -preset fast -threads 0 FILENAME-720-24fps-1828k.mp4
```

### MP4 - Same as previous but add fade-in/out for 10 frames

Fading out involves the exact frame from which to begin:

```
ffprobe -i FILENAME.mov -count_frames -show_entries stream=nb_frames
# nb_frames=1728 (in my case)
```

```
ffmpeg -y -i FILENAME.mov -c:v libx264 -minrate 1M -b:v 1828K -vf 'scale=-1:720,fade=in:0:10,fade=out:1718:10' -r 24 -preset fast -threads 0 FILENAME-720-24fps-1828k-fadeinout.mp4
```

### WebM with similar settings as MP4, but using two passes

I followed the details from the page about [VP8 encoding](https://trac.ffmpeg.org/wiki/Encode/VP8).

```
ffmpeg -y -i FILENAME.mov -c:v libvpx -minrate 1M -b:v 1828K -vf 'scale=-1:720' -r 24 -preset fast -threads 0 -pass 1 FILENAME-720-24fps-1828k.webm
ffmpeg -y -i FILENAME.mov -c:v libvpx -minrate 1M -b:v 1828K -vf 'scale=-1:720' -r 24 -preset fast -threads 0 -pass 2 FILENAME-720-24fps-1828k.webm
```

During the first pass the output WebM file is useless. Some people use `-f mp4 /dev/null` or `-f webm /dev/null` which, of course, doesn't produce that file. I'm not really sure if it is necessary, but with no tests I can't say much.

### Making GIF from the video

I followed the details from the page [High Quality GIF with FFmpeg](http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html).

To keep the output small I decided to go with 320px in width and 10 fps.

```
ffmpeg -i FILENAME.mov -vf 'scale=320:-1:sws_dither=ed' -gifflags -transdiff -r 10 -y FILENAME-320-10fps-dither.gif
```

An alternative suggestion was to create a palette first from all frames and use that when encoding the GIF. Apparently you can add the fps setting into the `-vf` flag.

```
ffmpeg -i FILENAME.mov -vf 'fps=10,scale=320:-1:flags=lanczos,palettegen' -y palette.png
ffmpeg -i FILENAME.mov -i palette.png -lavfi 'fps=10,scale=320:-1:flags=lanczos [x]; [x][1:v] paletteuse' -y FILENAME-320-10fps-long-palette.gif
```
