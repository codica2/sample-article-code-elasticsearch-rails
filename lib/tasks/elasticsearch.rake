namespace :elasticsearch do
  desc 'Rebuild ES index'
  task reindex: :environment do
    Location.__elasticsearch__.delete_index! if Location.__elasticsearch__.index_exists?

    Location.__elasticsearch__.import(force: true)
  end
end
