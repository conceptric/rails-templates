# create rvmrc file
create_file ".rvmrc", "rvm use ruby-1.9.2-p180"

# gemfile   
gem 'haml-rails'
gem 'sass', '3.1.1'
gem 'simple_form'
gem 'jquery-rails'

# hpricot and ruby_parser required by haml
gem 'hpricot', :group => :development
gem 'ruby_parser', :group => :development
gem 'hirb', :group => :development

# development and testing environments
gem 'rake', '0.8.7', :group => [ :development ]
gem 'nifty-generators', :group => [ :development ]
gem 'rails3-generators', :group => [ :development ]
gem 'rspec-rails', :group => [ :development, :test ]
gem 'factory_girl_rails', :group => [ :development, :test ]
gem 'capybara', :group => [ :development, :test ]
gem 'mocha', :group => [ :development, :test ]
gem 'launchy', :group => :test

# Replace the mysql2 gem because the latest doesn't work with 3.0.x
gsub_file 'Gemfile', "gem 'mysql2'", "gem 'mysql2', '0.2.6'"

# install gems to a local vendor directory
run 'bundle install --path vendor'
run "echo 'vendor/ruby' >> .gitignore"

generate 'nifty:config'

# views
generate 'simple_form:install'
generate 'nifty:layout --haml'
remove_file 'app/views/layouts/application.html.erb' # use nifty layout instead

# use SCSS rather than SASS    
run 'bundle exec sass-convert public/stylesheets/sass/application.sass public/stylesheets/sass/application.scss'
append_to_file 'public/stylesheets/sass/application.scss' do
  <<-eos 
  
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
end
remove_file "public/stylesheets/sass/application.sass"

# scripts
remove_file 'public/javascripts/rails.js' # jquery-rails replaces this
generate 'jquery:install --ui'

# tests
generate 'rspec:install'                
inject_into_file 'spec/spec_helper.rb', "\nrequire 'factory_girl'\nrequire 'mocha'", :after => "require 'rspec/rails'"
gsub_file 'spec/spec_helper.rb', '# config.mock_with :mocha', 'config.mock_with :mocha'
gsub_file 'spec/spec_helper.rb', 'config.mock_with :rspec', '# config.mock_with :rspec'
gsub_file 'spec/spec_helper.rb', 'config.fixture_path', '# config.fixture_path'
                      
                      
# application defaults  
inject_into_file 'config/application.rb', 'jquery rails', :after => 'config.action_view.javascript_expansions[:defaults] = %w('
inject_into_file 'config/application.rb', :after => "config.filter_parameters += [:password]" do
  <<-eos
    
    # Customize generators
    config.generators do |g|
      g.stylesheets false
      g.template_engine :haml
      g.form_builder :simple_form
      g.test_framework :rspec  
      g.fallbacks[:rspec] = :test_unit
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