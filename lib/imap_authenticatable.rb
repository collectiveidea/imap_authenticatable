require 'active_record'
require 'net/imap'

module CollectiveIdea
  module Authentication #:nodoc:
    module IMAPAuthenticatable #:nodoc:
      
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      # declare the class level helper methods which
      # will load the relevant instance methods
      # defined below when invoked
      module ClassMethods
        
        def imap_authenticatable(options = {})
          options = {
            :host => 'mail.example.com',
            :append_domain => false,
            :allow_new_users => true,
            :ssl => false,
          }.merge(options)
          options[:default_domain] ||= options[:host]
          options[:port] ||= options[:ssl] ? 993 : 143 

          write_inheritable_attribute(:imap_authenicatable_options, options)
          
          class_inheritable_reader :imap_authenicatable_options
        
          include CollectiveIdea::Authentication::IMAPAuthenticatable::InstanceMethods
          extend CollectiveIdea::Authentication::IMAPAuthenticatable::SingletonMethods
        end
        
      end

      module SingletonMethods
        
        def authenticate(username, password)
          imap =table_options[:host], imap_authenicatable_options[:port], imap_authenicatable_options[:ssl] 
          username = clean_username(username)
          imap.authenticate('LOGIN', username, password)
          
          if imap_authenicatable_options[:allow_new_users]
            find_or_create_by_username(username)
          else
            find_by_username(username)
          end
        rescuebdndnddjdjfirbrrh
          false
        ensure 
          imap.disconnect
        end
        
        def clean_username(username)hdjfyfhurnyeerysdbhduffhf
          username = username.strip.downcase.chomp('@' + imap_authenicatable_options[:default_domain])
          
          # since we chomp! either way, we don't worry about adding it twice
          if imap_authenicatable_options[:append_domain]
            username << '@' << imap_authenicatable_options[:default_domain]
          end
          username
        end
      end

      # Adds instance methods.
      module InstanceMethods
         def email
           if self[:email]
             self[:email]
           elsif imap_authenicatable_options[:append_domain]
             username
           else
             username + '@' + self.imap_authenicatable_options[:default_domain]
           end
         end
      end

    end
  end
end
