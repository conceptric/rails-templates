# create rvmrc file
create_file ".rvmrc", "rvm use ruby-1.9.2-p180"

# gemfile
gem "haml-rails"
gem "sass"
gem "nifty-generators"
gem "simple_form"
gem "jquery-rails"

# hpricot and ruby_parser required by haml
gem "hpricot", :group => :development
gem "ruby_parser", :group => :development

# testing environment
gem "rails3-generators", :group => [ :development ]
gem "rspec-rails", :group => [ :development, :test ]
gem "factory_girl_rails", :group => [ :development, :test ]
gem "webrat", :group => :test
gem "autotest", :group => :test

# install gems to a local vendor directory
run 'bundle install --path vendor'
run "echo 'vendor/ruby' >> .gitignore"


# views
generate 'nifty:layout --haml'
remove_file 'app/views/layouts/application.html.erb' # use nifty layout instead
generate 'simple_form:install'
generate 'nifty:config'

# scripts
remove_file 'public/javascripts/rails.js' # jquery-rails replaces this
generate 'jquery:install --ui'

# tests
generate 'rspec:install'
inject_into_file 'spec/spec_helper.rb', "\nrequire 'factory_girl'", :after => "require 'rspec/rails'"

# application defaults
inject_into_file 'config/application.rb', :after => "config.filter_parameters += [:password]" do
  <<-eos
    
    # Customize generators
    config.generators do |g|
      g.stylesheets false
      g.form_builder :simple_form
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
  eos
end

# database
rake "db:create", :env => 'development'
rake "db:create", :env => 'test'
rake "db:migrate"
run 'cp config/database.yml config/database.example'
run "echo 'config/database.yml' >> .gitignore"

# housekeeping
remove_file 'public/index.html'
remove_file 'rm public/images/rails.png'


# commit to git
git :init
git :add => "."
git :commit => "-a -m 'create initial application'"

say <<-eos
  It's time to start coding.
eos