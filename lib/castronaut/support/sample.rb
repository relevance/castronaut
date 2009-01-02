module Castronaut
  module Support
    
    class Sample
    
      def self.create_sample_database
        connection = ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => "development.db", "timeout" => 5000)
        connection.connection.create_table "users", :force => true do |t|
          t.column :login,                     :string, :limit => 40
          t.column :name,                      :string, :limit => 100, :default => '', :null => true
          t.column :password,                  :string
        end
        connection.connection.add_index :users, :login, :unique => true
        connection.connection.execute("INSERT INTO users (login,name,password) values ('admin', 'admin', 'admin')")
        connection.connection.execute("INSERT INTO users (login,name,password) values ('user', 'user', 'user')")
      end
      
    end
    
  end
end
