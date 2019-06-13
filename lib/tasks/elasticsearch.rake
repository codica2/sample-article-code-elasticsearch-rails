namespace :elasticsearch do
  desc 'Rebuild ES index'
  task reindex: :environment do
    Locationt.__elasticsearch__.delete_index! if Locationt.__elasticsearch__.index_exists?

    Locationt.__elasticsearch__.import(force: true)
  end
end
