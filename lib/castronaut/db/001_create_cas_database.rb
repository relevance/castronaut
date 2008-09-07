class CreateCasDatabase < ActiveRecord::Migration
  def self.up
    create_table :login_tickets,   :force => true do |t|
      t.column :ticket,           :string,   :null => false
      t.column :created_on,       :timestamp, :null => false
      t.column :consumed,         :datetime, :null => true
      t.column :client_hostname,  :string, :null => false
    end

    create_table :service_tickets,   :force => true do |t|
      t.column :ticket,           :string,    :null => false
      t.column :service,          :text,    :null => false
      t.column :created_on,       :timestamp, :null => false
      t.column :consumed,         :datetime, :null => true
      t.column :client_hostname,  :string, :null => false
      t.column :username,         :string,  :null => false
      t.column :type,             :string,   :null => false
      t.column :pgt_id,           :integer, :null => true
      t.column :tgt_id,           :integer, :null => true
    end

    create_table :ticket_granting_tickets,  :force => true do |t|
      t.column :ticket,           :string,    :null => false
      t.column :created_on,       :timestamp, :null => false
      t.column :client_hostname,  :string, :null => false
      t.column :username,         :string,    :null => false
      t.column :extra_attributes, :text
    end

    create_table :proxy_granting_tickets,  :force => true do |t|
      t.column :ticket,           :string,    :null => false
      t.column :created_on,       :timestamp, :null => false
      t.column :client_hostname,  :string, :null => false
      t.column :iou,              :string,    :null => false
      t.column :st_id,            :integer, :null => false
    end
  end

  def self.down
    drop_table :proxy_granting_tickets
    drop_table :ticket_granting_tickets
    drop_table :service_tickets
    drop_table :login_tickets
  end
end
