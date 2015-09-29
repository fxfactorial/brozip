`brozip` is a command line tool to concurrently compress, decompress
files using the Brotli compression algorithm.

# brozip usage

Right now its quite simple, since its built with `cmdliner`, there's a
nice man page available when you do `brozip --help` Basically if you
do

```shell
$ brozip fileone.compressed filetwo.compressed
```

then you'll get uncompressed files named `fileone`, `filetwo`
