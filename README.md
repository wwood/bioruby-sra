# bio-sra

[![Build Status](https://secure.travis-ci.org/wwood/bioruby-sra.png)](http://travis-ci.org/wwood/bioruby-sra)

A Sequence Read Archive (SRA) download script and Ruby interface to the [SRAdb](ncbi.nlm.nih.gov/pmc/articles/PMC3560148/) (SRA metadata) SQLite database.

## Installation

```sh
gem install bio-sra
```

## Download script usage

Download a single run file to the current directory:
```sh
sra_download --runs ERR229501.sra
```

Download a list of runs
```sh
$ cat srr_list.txt
ERR229501
ERR229498
$ sra_download --runs -f srr_list.txt
```

Download all runs that are a part of the experiment ERP001779 (Microbial biogeography of public restroom surfaces)
```sh
$ sra_download ERP001779
```
This finds ERP001779 and links it to runs through the SRAdb

## Ruby interface script

```ruby
require 'bio-sra'
```

The API doc is online. For more code examples see the test files in
the source tree.

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/wwood/bioruby-sra

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

This Ruby code is unpublished, but there's a problem with

* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at [#bio-sra](http://biogems.info/index.html)

## Copyright

Copyright (c) 2012 Ben J. Woodcroft. See LICENSE.txt for further details.

