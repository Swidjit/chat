namespace :experiments do
  task :substitutions => :environment do
    files = ['contractions.csv']
    subs = {}
    files.each do |f|
      file = File.open(f)
      file.each do |line|
        parts = line.split(',')
        puts parts[0]
        puts parts[1].split('/')[0].strip
        subs[parts[0]] = parts[1].split('/')[0].strip
      end
    end
    puts subs
  end
end