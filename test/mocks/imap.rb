module Net
  class IMAP
  
    def initialize(*options)
      true
    end
    
    def authenticate(method, username, password)
      # password should be the reverse of username... tricky.
      authenticated = password == username.reverse
      throw Exception unless authenticated
    end
  
    def disconnect
      true
    end
  end
end