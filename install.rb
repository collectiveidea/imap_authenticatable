# Copy the mock imap.rb to the project's test directory
File.copy(File.join(File.dirname(__FILE__), 'test/mocks/imap.rb'), File.join(File.dirname(__FILE__), '../../../test/mocks/test/'))