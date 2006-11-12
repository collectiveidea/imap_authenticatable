require File.join(File.dirname(__FILE__), 'test_helper')

class User < ActiveRecord::Base
  imap_authenticatable :host => 'mail.example.com', :default_domain => 'example.com'
end

class Admin < ActiveRecord::Base
  imap_authenticatable :host => 'example.com', :allow_new_users => false
  
  # override authentication method to add new criteria
  self.class_eval do
    alias_method_chain :authorize, :extra_authorization
    def authorize_with_extra_authorization(username, password)
      user = authorize(username, password)
      
      # only authorized if user has 'active' flag set
      if user
        user.active?
      end
    end
  end
end

class IMAPAuthenticatableTest < Test::Unit::TestCase
  fixtures :users, :admins
  
  def test_successful_user_authentication
    users(:bob)
  end
end
