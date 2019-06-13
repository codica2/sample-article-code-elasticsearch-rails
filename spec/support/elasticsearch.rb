# frozen_string_literal: true

RSpec.configure do |config|
  es_port = '9250'
  es_bin = '~/Downloads/elasticsearch-6.4.0/bin/elasticsearch'
  config.before :suite do
    unless Elasticsearch::Extensions::Test::Cluster.running?(command: es_bin, port: es_port, nodes: 1)
      Elasticsearch::Extensions::Test::Cluster.start(command: es_bin, port: es_port, nodes: 1, timeout: 300)
    end
  end

  # Stop elasticsearch cluster after test run
  config.after :suite do
    if Elasticsearch::Extensions::Test::Cluster.running?(command: es_bin, port: es_port, nodes: 1)
      Elasticsearch::Extensions::Test::Cluster.stop(command: es_bin, port: es_port, nodes: 1)
    end
  end

  # Create indexes for all elastic searchable models
  config.before :each do
    ActiveRecord::Base.descendants.each do |model|
      next unless model.respond_to?(:__elasticsearch__)

      begin
        model.__elasticsearch__.create_index!
        model.__elasticsearch__.refresh_index!
      rescue StandardError => e
        STDERR.puts "There was an error creating the elasticsearch index for #{model.name}: #{e.inspect}"
      end
    end
  end

  # Delete indexes for all elastic searchable models to ensure clean state between tests
  config.after :each do
    ActiveRecord::Base.descendants.each do |model|
      next unless model.respond_to?(:__elasticsearch__)

      begin
        model.__elasticsearch__.delete_index!
      rescue StandardError => e
        STDERR.puts "There was an error removing the elasticsearch index for #{model.name}: #{e.inspect}"
      end
    end
  end
end
