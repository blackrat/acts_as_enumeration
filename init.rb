require File.dirname(__FILE__) + '/lib/active_record/acts/enumeration.rb'
ActiveRecord::Base.send :include, ActiveRecord::Acts::Enumeration