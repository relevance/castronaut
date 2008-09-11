class CreateCasDatabase < ActiveRecord::Migration
  def self.up
    create_table :login_tickets,   :force => true do |t|
      t.column :ticket,           :string,    :null => false
      t.column :client_hostname,  :string,    :null => false
      t.column :consumed_at,      :datetime,  :null => true
      t.column :created_at,       :datetime,  :null => false
    end

    create_table :service_tickets,   :force => true do |t|
      t.column :proxy_granting_ticket_id,     :integer, :null => true
      t.column :ticket_granting_ticket_id,    :integer, :null => true

      t.column :ticket,           :string,    :null => false
      t.column :client_hostname,  :string,    :null => false
      t.column :service,          :text,      :null => false
      t.column :username,         :string,    :null => false
      t.column :type,             :string,    :null => true
      t.column :consumed_at,      :datetime,  :null => true
      t.column :created_at,       :datetime,  :null => false
    end

    create_table :ticket_granting_tickets,  :force => true do |t|
      t.column :ticket,           :string,    :null => false
      t.column :client_hostname,  :string,    :null => false
      t.column :username,         :string,    :null => false

      t.column :created_at,       :datetime,  :null => false
    end

    create_table :proxy_granting_tickets,  :force => true do |t|
      t.column :service_ticket_id,  :integer,   :null => false

      t.column :ticket,             :string,    :null => false
      t.column :client_hostname,    :string,    :null => false
      t.column :iou,                :string,    :null => false
      t.column :created_at,         :datetime,  :null => false
    end
  end

  def self.down
    drop_table :proxy_granting_tickets
    drop_table :ticket_granting_tickets
    drop_table :service_tickets
    drop_table :login_tickets
  end
end
