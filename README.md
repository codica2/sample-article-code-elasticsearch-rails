# Sample code from an article "Rails Elasticsearch"

## Requirements

- `ruby 2.6.1`
- `rails 5.2.3`
- `elasticsearch 6.4.0`
- `kibana 6.4.2`

## Getting started

```shell
 git clone git@github.com:codica2/sample-article-code-elasticsearch-rails.git
 cd sample-article-code-elasticsearch-rails
```

## Install the app's dependencies:

```shell
 bundle install && bundle exec rake db:create db:migrate db:seed
```

## Create/Recreate ES index

```bash
rake elasticsearch:reindex
```

## Testing

Before testing make sure `elasticsearch` is up and running

```bash
rspec
```