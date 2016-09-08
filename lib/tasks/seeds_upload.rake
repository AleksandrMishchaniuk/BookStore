namespace :seeds_upload do
  task :apply do
    seeds_dir = './public/seeds/uploads/'
    target_dir = './public/'
    FileUtils.cp_r seeds_dir, target_dir
  end
end
