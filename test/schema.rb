ActiveRecord::Schema.define(:version => 1) do
  
  create_table "normals", :force => true do |t|
    t.column "username",                :string
    t.column "favorite_rails_feature",  :string
  end
  
  create_table "admins", :force => true do |t|
    t.column "username",      :string
    t.column "active",        :boolean
  end
  
  create_table "haxors", :force => true do |t|
    t.column "username",      :string
    t.column "email",         :string
  end
  
end