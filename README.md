`brozip` is a **fast** command line tool to concurrently compress,
decompress files using the Brotli compression algorithm. If can handle
arbitrary number of files given and if none are given it will perform
an operation on `stdin` and push the results to `stdout`

# Why use this over any other zipping tool/algorithm?

Well, Google calls Brotli the [&#x2026;new compression algorithm for the
internet](http://google-opensource.blogspot.se/2015/09/introducing-brotli-new-compression.html) with improvements up to 25% over other zipping algorithms,
see the comparison shootout [here.](http://www.gstatic.com/b/brotlidocs/brotli-2015-09-22.pdf)

# Installation

I assume you have [opam](https://opam.ocaml.org) installed, it is OCaml's package manager.

```shell
$ opam install brozip
```

and you'll have the `brozip` executable installed.

I tested this on `OS X` and `Debian Jessie`, both worked. It should
work on Windows as well but you will have to put in more effort
although it should be fine if run under `cygwin` (I think)

# brozip usage

`brozip` keeps some common interfaces like other zipping utilities,
like if no files are given, then it will just take `stdin` and process
to `stdout` so you should be able to drop it in some shell scripts
now.

```shell
$ brozip < asyoulik.txt.compressed | wc -l
4122
```

The default action is decompression, tell `brozip` to compress input
with the `--compress`, `-c` flag. 

If multiple files are given then `brozip` will act on them
concurrently, you can control this with the flag `--serial`, `-s`
which when given will make `brozip` process files one by one.

Some compression tuning options are specific to the `Brotli` algorithm
but all default to the settings used by Google, Look at the man page
for all details, always accessible with `brozip --help`
![img](./man_page_brozip.gif)

# Issues

As always, please report bugs and PRs are always welcome.

1.  Even though this is only 250 lines of Code, there are still places
    that can be refactored and made more `DRY` or just generally
    improved.
