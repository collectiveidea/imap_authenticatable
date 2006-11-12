require 'imap_authenticatable'
ActiveRecord::Base.send(:include, CollectiveIdea::Authentication::IMAPAuthenticatable)