GEMSPEC_PATH = File.join '..', 'gitter-api.gemspec'
GEMSPEC_FILE = File.expand_path GEMSPEC_PATH, __FILE__
GEMSPEC      = eval File.read(GEMSPEC_FILE)

require 'rake/clean'

RI_GEN_PATH = File.join '.rdoc', 'gitter-api-ruby', 'ri'
DOC_FILES   = %w[README.md]
CLEAN.include   'pkg'
CLOBBER.include '.rdoc'

# -----------------------------------------------
#                     Build
# -----------------------------------------------

require 'rubygems/package_task'

namespace :rubygems do
  Gem::PackageTask.new(GEMSPEC).define
end

# -----------------------------------------------
#                     Docs
# -----------------------------------------------

require 'rdoc/ri/task'

namespace :rdoc do
  RDoc::RI::Task.new do |ri|
    ri.name = 'generate'
    ri.main = 'README.md'
    ri.rdoc_dir = RI_GEN_PATH
    ri.generator = 'ri'
    ri.rdoc_files.include 'lib/**/*.rb', *DOC_FILES
  end

  def ri_driver
    opts   = RDoc::RI::Driver.process_args []
    driver = RDoc::RI::Driver.new opts
    store  = RDoc::RI::Store.new RI_GEN_PATH, :gem
    driver.stores = [store]
    store.load_cache

    driver
  end


  desc "view RI doc for specific :name"
  task :view, [:name] => "rdoc:generate" do |t, args|
    ri = ri_driver
    ri.show_all = true

    begin
      ri.display_name args[:name]
    rescue RDoc::RI::Driver::NotFoundError => e
      puts e.message
    end
  end

  namespace :view do
    DOC_FILES.each do |file|
      desc "Display the rdoc generated output for #{file}"
      task file => "rdoc:generate" do |t, _|
        ri_driver.display_page "gitter-api-ruby:#{t.name.split(':').last}"
      end
    end
  end
end


# -----------------------------------------------
#                    Console
# -----------------------------------------------

desc "Open an irb console"
task :console do
  require 'irb'
  require 'gitter/api'

  contrib = File.expand_path(File.join("..", "contrib", "scripts"), __FILE__)
  $LOAD_PATH.unshift(contrib) unless $LOAD_PATH.include?(contrib)
  require 'load_client_from_token_file'

  TOPLEVEL_BINDING.irb
end
