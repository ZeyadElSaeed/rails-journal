namespace :db do
  desc "Drop and recreate the database"
  task reset: :environment do
    puts "Dropping the database..."
    Rake::Task["db:drop"].invoke

    puts "Creating the database..."
    Rake::Task["db:create"].invoke

    puts "Running migrations..."
    Rake::Task["db:migrate"].invoke

    # puts "Seeding the database..."
    # Rake::Task["db:seed"].invoke
  end
end
