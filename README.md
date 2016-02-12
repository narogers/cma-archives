# cma-archives
Hydra pilot for archiving institutional content

## Installation
Follow the normal [installation instructions](https://github.com/projecthydra/sufia/) for Sufia. Once Fedora, Solr, etc are configured and you have a clean installation

#### Import Default Collections
[config/default_collections.rb] (https://github.com/ClevelandArtGIT/cma-archives/blob/master/config/default_collections.yml) contains a list of featured collections that will appear on the homepage. Examples are included for reference.

When you are done editing the file import the collections into the repository using the Rake command

_%&gt; rake cma:collection:install_featured_

#### Batch Ingesting Content
Content is designed to be loaded using batch files. For more information see
the list of [related utilities](https://github.com/ClevelandArtGIT/cma-archives-utils). Batch files can also be created manually if the structure is followed in your workflow.

Multiple CSV files can be processed at the same time. Simply point the command
at the root directory for your dropbox.

_%&gt; rake cma:batch:ingest["path to dropbox"]_
