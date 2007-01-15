require File.join(File.dirname(__FILE__), 'test_helper')

class Normal < ActiveRecord::Base
  imap_authenticatable :host => 'mail.example.com', :default_domain => 'example.com'
end

class Admin < ActiveRecord::Base
  imap_authenticatable :host => 'collectiveidea.com', :allow_new_users => false
  
  # override authentication method to add new criteria
  def self.included(mod)
    mod.class_eval do
      alias_method_chain :authenticate, :extra_authorization
      def authenticate_with_extra_authorization(username, password)
        user = authenticate(username, password)
      
        # only authorized if user has 'active' flag set
        if user
          throw Exception unless user.active?
        end
      end
    end
  end
end

class Haxor < ActiveRecord::Base
  imap_authenticatable :host => 'mail.haxor.xxx', :default_domain => 'haxor.xxx'
end

class SomethingElse < ActiveRecord::Base
  imap_authenticatable :host => 'mail.example.com', 
    :default_domain => 'example.com',
    :append_domain => true
end

class IMAPAuthenticatableTest < Test::Unit::TestCase
  fixtures :normals, :admins
  
  # valid passwords are equal to username.reverse
  
  def test_successful_normal_authentication
    assert_equal normals(:bob), Normal.authenticate('bob', 'bob')
    assert_equal normals(:bob), Normal.authenticate('BOB', 'bob')
    assert_equal normals(:sue), Normal.authenticate('sue', 'eus')
    assert_equal normals(:sue), Normal.authenticate('sue@example.com', 'eus')
    assert_equal normals(:sue), Normal.authenticate('sue@EXAMPLE.com', 'eus')
    
    assert_difference(Normal, :count) do
      assert_kind_of Normal, Normal.authenticate('newperson@example.com', 'nosrepwen')
    end
  end
  
  def test_successful_admin_authentication
    assert_equal admins(:daniel), Admin.authenticate('daniel', 'leinad')
    assert_equal admins(:daniel), Admin.authenticate('Daniel', 'leinad')
    assert_equal admins(:daniel), Admin.authenticate('daniel@collectiveidea.com', 'leinad')
  end
  
  def test_unsuccessful_normal_authentication
    assert !Normal.authenticate('bob', 'bobbob')
    assert !Normal.authenticate('BOB', 'b')
    assert !Normal.authenticate('BOB', '')
    assert !Normal.authenticate('sue', 'UES')
    assert !Normal.authenticate('sue@hacker.com', 'eus')
    assert !Normal.authenticate('sue@HACKER.com', 'eus')
    
    assert_no_difference(Normal, :count) do
      assert_equal false, Normal.authenticate('newperson@example.com', 'invalid')
    end
  end
  
  def test_unsuccessful_admin_authentication
    assert !Admin.authenticate('brandon', 'nodnard')
    assert !Admin.authenticate('brandon', '')
    assert !Admin.authenticate('daniel', 'incorrect')
    assert !Admin.authenticate('daniel@collectiveidea.com', '')
    
    assert_no_difference(Admin, :count) do
      assert !Admin.authenticate('newperson', 'nosrepwen')
    end
  end
  
  def test_successful_haxor_authentication
    assert_equal admins(:matt), Haxor.authenticate('matt', 'ttam')
    assert_equal admins(:john), Haxor.authenticate('john', 'nhoj')
    assert_equal admins(:matt), Haxor.authenticate('matt@haxor.xxx', 'ttam')
    assert_equal admins(:john), Haxor.authenticate('john@haxor.xxx', 'nhoj')
    assert_difference(Haxor, :count) do
      assert_kind_of Haxor, Haxor.authenticate('newperson', 'nosrepwen')
    end
  end
  
  def test_unsuccessful_haxor_authentication
    assert !Haxor.authenticate('matt', 'mat')
    assert !Haxor.authenticate('hack', 'hack')
    assert !Haxor.authenticate('not_matt@somewhere.else.org', 'ttam')
    assert !Haxor.authenticate('', 'nhoj')
    
    assert_no_difference(Haxor, :count) do
      assert_equal false, Haxor.authenticate('newperson@haxor.com', 'invalid')
    end
  end
  
  
  def test_clean_username
    assert_equal 'sam', Normal.clean_username('sam')
    assert_equal 'sam', Normal.clean_username('SAM')
    assert_equal 'sam', Normal.clean_username('Sam')
    assert_equal 'sam', Normal.clean_username('Sam   ')
    assert_equal 'sam', Normal.clean_username('  Sam   ')
    assert_equal 'sam', Normal.clean_username('  Sam')
    assert_equal 'sam', Normal.clean_username('sam@example.com')
    assert_equal 'sam', Normal.clean_username('sam@EXAMPLE.com')
    
    assert_equal 'sam@example.com', SomethingElse.clean_username('sam')
    assert_equal 'sam@example.com', SomethingElse.clean_username('SAM')
    assert_equal 'sam@example.com', SomethingElse.clean_username('Sam')
    assert_equal 'sam@example.com', SomethingElse.clean_username('Sam   ')
    assert_equal 'sam@example.com', SomethingElse.clean_username('  Sam   ')
    assert_equal 'sam@example.com', SomethingElse.clean_username('  Sam')
    assert_equal 'sam@example.com', SomethingElse.clean_username('sam@example.com')
    assert_equal 'sam@example.com', SomethingElse.clean_username('sam@EXAMPLE.com')
  end
  
  def test_email
    assert_equal 'bob@example.com', normals(:bob).email
    assert_equal 'sue@example.com', normals(:sue).email
    
    assert_equal 'daniel@collectiveidea.com', admins(:daniel).email
    assert_equal 'brandon@collectiveidea.com',admins(:brandon).email
    
    assert_equal 'not_matt@somewhere.else.org', haxors(:matt).email
    assert_nil, haxors(:john).email
  end
end
