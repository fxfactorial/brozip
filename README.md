`brozip` is a **fast** command line tool to concurrently compress,
decompress files using the Brotli compression algorithm. If can handle
arbitrary number of files given and if none are given it will perform
an operation on `stdin` and push the results to `stdout`

# Installation

(I assume you have [opam](https://opam.ocaml.org) installed, it is OCaml's package manager)
Until I get this up on `opam` you will have to locally pin the
package, do that with:

```shell
$ opam pin add brozip . -y
```

and you'll have the `brozip` executable installed.

# brozip usage

Look at the man page, always accessible with `brozip --help`
![img](./man_page_brozip.gif)

# Issues

As always, please report bugs and PRs are always welcome.

1.  Even though this is only 200 lines of Code, there are still places
    that can be refactored and made more `DRY`
2.  I'm leaving this for someone eager to get into open-source or
    `OCaml`
