# bio-sra

A Sequence Read Archive (SRA) download script and Ruby interface to the [SRAdb](ncbi.nlm.nih.gov/pmc/articles/PMC3560148/) (SRA metadata) SQLite database.

## Installation

```sh
gem install bio-sra
```

## Download script usage

Download a single run file to the current directory:
```sh
sra_download ERR229501
```

Download a list of runs
```sh
$ cat srr_list.txt
ERR229501
ERR229498
$ sra_download -f srr_list.txt
```

Download all runs that are a part of the experiment ERP001779 "Microbial biogeography of public restroom surfaces". This requires an [SRAdb](http://www.bioconductor.org/packages/release/bioc/html/SRAdb.html) database (i.e. a database of the SRA metadata), which can be downloaded from 
```sh
$ sra_download -d '/path/to/SRAmetadb.sqlite' ERP001779
```
The SRAdb SQLite file can be downloaded from these mirrors:
* http://gbnci.abcc.ncifcrf.gov/backup/SRAmetadb.sqlite.gz
* http://watson.nci.nih.gov/~zhujack/SRAmetadb.sqlite.gz
* http://dl.dropbox.com/u/51653511/SRAmetadb.sqlite.gz

## Ruby interface script

```ruby
require 'bio-sra'

# Connect to the database
Bio::SRA::Connection.connect '/path/to/SRAmetadb.sqlite'
```
Once connected, the each row of the Bio::SRA::Tables::SRA table represents an SRA run:
```
Bio::SRA::Tables::SRA.first.run_accession
# => "DRR000001"

Bio::SRA::Tables::SRA.first.submission_accession
# => "DRA000001"

Bio::SRA::Tables::SRA.first.submission_date
# => "2009-06-20"

Bio::SRA::Tables::SRA.first.submission_comment
# => "Bacillus subtilis subsp. natto BEST195 draft sequence, the chromosome and plasmid pBEST195S"
```

There are also methods for working with accession numbers, e.g.
```ruby
 Bio::SRA::Accession.classify_accession_type('ERP001779') #=> :study_accession
```

The API doc is online. For more code examples see the test files in
the source tree.

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/wwood/bioruby-sra

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

This Ruby code is unpublished, but citing the SRAdb paper is probably good practice:

* [SRAdb: query and use public next-generation sequencing data from within R](dx.doi.org/10.1186/1471-2105-14-19)

## Biogems.info

This Biogem is published at [#bio-sra](http://biogems.info/index.html)

## Copyright

Copyright (c) 2012-2014 Ben J. Woodcroft. See LICENSE.txt for further details.

