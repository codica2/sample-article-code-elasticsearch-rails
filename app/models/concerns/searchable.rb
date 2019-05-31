module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    def as_indexed_json(_options = {})
      as_json(only: %i[name level])
    end

    settings settings_attributes do
      mappings dynamic: false do
        # we use our autocomplete custom analyzer that we defined below
        indexes :name,  type: :text, analyzer: :autocomplete
        indexes :level, type: :keyword
      end
    end

    def self.search(query, filters)
      # A lambda function that adds conditions to a search definition.
      set_filters = lambda do |context_type, filter|
        @search_definition[:query][:bool][context_type] |= [filter]
      end

      @search_definition = {
        # we indicate that there should be no more than 5 documents to return
        size: 5,
        # we define an empty query with the ability to
        # dynamically change the definition
        # Query DSL https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
        query: {
          bool: {
            must: [],
            should: [],
            filter: []
          }
        }
      }

      # match all documents
      if query.blank?
        set_filters.call(:must, match_all: {})
      else
        set_filters.call(
          :must,
          match: {
            name: {
              query: query,
              # fuzziness means you can make one typo and still match document
              fuzziness: 1
            }
          }
        )
      end

      # will return only those documents that pass this filter
      if filters[:level].present?
        set_filters.call(:filter, term: { level: filters[:level] })
      end

      __elasticsearch__.search(@search_definition)
    end
  end

  class_methods do
    def settings_attributes
      {
        index: {
          analysis: {
            analyzer: {
              # we define custom analyzer with name autocomplete
              autocomplete: {
                # type should be custom for custom analyzers
                type: :custom,
                # we use standard tokenizer
                tokenizer: :standard,
                # we use two token filters.
                # autocomplete filter is a custom filter that we defined right below
                filter: %i[lowercase autocomplete]
              }
            },
            filter: {
              # we define custom token filter with name autocomplete
              autocomplete: {
                type: :edge_ngram,
                min_gram: 2,
                max_gram: 25
              }
            }
          }
        }
      }
    end
  end
end
