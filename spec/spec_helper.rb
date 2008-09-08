require 'rubygems'

gem :rspec, '>= 1.1.4'
gem :mocha, '>= 0.9.0'
gem :activerecord, '>= 2.1.0'

require File.join(File.dirname(__FILE__), '..', 'castronaut')

Castronaut.config = Castronaut::Configuration.new(File.join(File.dirname(__FILE__), '..', 'castronaut.example.yml'))

class CreateUsers < ActiveRecord::Migration
  old_connection = ActiveRecord::Base.connection
  ActiveRecord::Base.connection = Castronaut::Adapters::RestfulAuthentication::User.connection

  create_table "users", :force => true do |t|
    t.column :login,                     :string, :limit => 40
    t.column :name,                      :string, :limit => 100, :default => '', :null => true
    t.column :email,                     :string, :limit => 100
    t.column :crypted_password,          :string, :limit => 40
    t.column :salt,                      :string, :limit => 40
    t.column :created_at,                :datetime
    t.column :updated_at,                :datetime
    t.column :remember_token,            :string, :limit => 40
    t.column :remember_token_expires_at, :datetime
    t.string :first_name, :last_name
  end
  add_index :users, :login, :unique => true

  ActiveRecord::Base.connection = old_connection
end

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
