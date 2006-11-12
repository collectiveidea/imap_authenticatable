module Net
  class IMAP
  
    def initialize(options*)
      true
    end
    
    def authenticate(method, username, password)
      # password should be the reverse of username... tricky.
      password == username.reverse
    end
  
    def disconnect
      true
    end
  end
end