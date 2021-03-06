# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec'
require 'spec/rails'
require 'ruby-debug'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

# require the entire app if we're running under coverage testing,
# so we measure 0% covered files in the report
#
# http://www.pervasivecode.com/blog/2008/05/16/making-rcov-measure-your-whole-rails-app-even-if-tests-miss-entire-source-files/
if defined?(Rcov)
  all_app_files = Dir.glob('{app,lib}/**/*.rb')
  all_app_files.each{|rb| require rb}
end

module SystemReportsSpecHelper
  def logged_in_as_admin
    @current_user = mock_model(User,
                               :admin? => true,
                               :logged? => true,
                               :anonymous? => false,
                               :active? => true,
                               :name => "Administrator",
                               :projects => Project,
                               :time_zone => ActiveSupport::TimeZone.all.first,
                               :language => 'en')
    @current_user.stub!(:allowed_to?).and_return(true)

    User.stub!(:current).and_return(@current_user)
    return @current_user
  end

  def logged_in_as_user
    @current_user = mock_model(User,
                               :admin? => false,
                               :logged? => true,
                               :anonymous? => false,
                               :active? => true,
                               :name => "User",
                               :projects => Project,
                               :time_zone => ActiveSupport::TimeZone.all.first,
                               :language => 'en')
    User.stub!(:current).and_return(@current_user)
    return @current_user
  end
end

include SystemReportsSpecHelper


describe "login_required", :shared => true do
  it 'should redirect' do
    do_request
    response.should be_redirect
  end
  
  it 'should redirect to the login page' do
    do_request
    response.should redirect_to(:controller => 'account', :action => 'login', :back_url => controller.url_for(params))
  end
  
end

describe "denied_access", :shared => true do
  it 'should not be successful' do
    do_request
    response.should_not be_success
  end
  
  it 'should return a 403 status code' do
    do_request
    response.code.should eql("403")
  end
  
  it 'should display the standard unauthorized page' do
    do_request
    response.should render_template('common/403')
  end

end
