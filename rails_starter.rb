# Manage the Ruby version
create_file ".rvmrc", "rvm use ruby-1.9.3-p125"

# Application gems   
gem 'simple_form'

# Development and testing environments
gem 'rake', :group => [ :development ]
gem 'rails3-generators', :group => [ :development ]
gem 'rspec-rails', :group => [ :development, :test ]
gem 'factory_girl_rails', :group => [ :development, :test ]
gem 'capybara', :group => [ :development, :test ]
gem 'mocha', :group => [ :development, :test ]
gem 'launchy', :group => :test

# Deployment
gem 'rvm', :group => [ :deployment ]
gem 'rvm-capistrano', :group => [ :deployment ]
gem 'capistrano', :group => [ :deployment ]
gem 'capistrano-ext', :group => [ :deployment ]

# Bundle gems to a local vendor directory
run 'bundle install --path vendor'
run "echo 'vendor/ruby' >> .gitignore"

# RSpec
generate 'rspec:install'                
inject_into_file 'spec/spec_helper.rb', "\nrequire 'factory_girl'\nrequire 'mocha'", :after => "require 'rspec/rails'"
gsub_file 'spec/spec_helper.rb', '# config.mock_with :mocha', 'config.mock_with :mocha'
gsub_file 'spec/spec_helper.rb', 'config.mock_with :rspec', '# config.mock_with :rspec'
gsub_file 'spec/spec_helper.rb', 'config.fixture_path', '# config.fixture_path'

# Capybara
create_file "spec/support/capybara.rb", <<-eos
require 'capybara/rails'
require 'capybara/rspec'
eos

# Views and forms
generate 'simple_form:install'

# Add SCSS styling for simple_form    
create_file "app/assets/stylesheets/simpleform.scss", <<-eos   
.simple_form {
  label {  
  float: left;  
  width: 100px;  
  text-align: right;  
  margin: 2px 10px; }
  div.input {  
    margin-bottom: 10px; }
  div.boolean, input[type='submit'] {  
    margin-left: 120px; } 
  div.boolean label {  
    float: none;  
    margin: 0; }
  div.boolean label {  
    float: none;  
    margin: 0; } }    
  eos
                      
# Set the application defaults  
inject_into_file 'config/application.rb', :after => "config.filter_parameters += [:password]" do
  <<-eos    
    # Customize generators
    config.generators do |g|
      g.stylesheets false
      g.form_builder :simple_form
      g.test_framework :rspec  
      g.fallbacks[:rspec] = :test_unit
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
  eos
end

# Database
rake "db:create", :env => 'development'
rake "db:create", :env => 'test'
rake "db:migrate"
run 'cp config/database.yml config/database.example'
run "echo 'config/database.yml' >> .gitignore"

# Commit to git
git :init
git :add => "."
git :commit => "-a -m 'create initial application'"

say <<-eos
  It's time to start coding.
eos