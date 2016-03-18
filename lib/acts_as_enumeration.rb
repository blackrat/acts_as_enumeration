require_relative File.join('active_record', 'acts', 'enumeration.rb')
ActiveRecord::Base.send :include, ActiveRecord::Acts::Enumeration