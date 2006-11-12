ActiveRecord::Schema.define(:version => 1) do
  
  create_table "users", :force => true do |t|
    t.column "username",                :string
    t.column "favorite_rails_feature",  :string
  end
  
  create_table "admins", :force => true do |t|
    t.column "username",      :string
    t.column "active",        :boolean
  end
  
end