require File.join(File.dirname(__FILE__), 'active_record', 'acts', 'enumeration.rb')
ActiveRecord::Base.include ActiveRecord::Acts::Enumeration
