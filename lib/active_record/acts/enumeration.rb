module ActiveRecord
  module Acts
    module Enumeration
      VERSION='0.1.0'
      class << self
        def included(base)
          base.class_eval do
            extend ClassMethods
          end
        end
      end

      def method_missing(method_id, *args, &block)
        method_name=method_id.to_s
        if match_data=method_name.match(/^(is(?:_not)*)(\?|_(\w*)\?)/)
          method=match_data[1] << "?"
          new_args= ((match_data[2]=='?') ? args : match_data[3].split(/_or_/).map { |x| x.intern })
          respond_to?(method) ? send(method, *new_args, &block) : false
        else
          super
        end
      end


      module ClassMethods
        def normalize(field)
          field.to_s.gsub(/[\\W]+/, ' ').strip.gsub(/\s+/, '_').underscore
        end

        def acts_as_enumeration(*opts)
          opts.each do |field|
            klass=self
            (
            class<<self;
              self;
            end).class_eval do
              define_method "enum_#{field}" do
                instance_variable_get("@enum_#{field}") || instance_variable_set("@enum_#{field}", HashWithIndifferentAccess[*klass.all.map { |x| [x.send(field).gsub(/[\\W]+/, ' ').strip.gsub(/\s+/, '_').underscore, x.send(x.class.primary_key)] }.flatten])
              end

              define_method :as_key do |value|
                return '' unless exists?(value)
                klass.find(value).as_key
              end

              alias_method :as_symbol, :as_key

              define_method "valid_#{field}?" do |value|
                send("enum_#{field}").has_key?(value)
              end

              define_method "id_for_#{field}" do |value|
                send("enum_#{field}")[value]
              end

              define_method "for_#{field}" do |value|
                klass.find(send("id_for_#{field}", value))
              end
            end

            define_method 'is?' do |*types|
              types.any? { |x| send(self.class.primary_key)==self.class.send("enum_#{field}")[x] }
            end

            define_method 'is_not?' do |*types|
              !is?(*types)
            end

            define_method :as_key do
              self.class.normalize(send(field)).intern
            end

            alias_method :as_symbol, :as_key

            all.map { |x| normalize(x.send(field)) }.each do |y|

              define_method "is_#{y}?" do
                is?("#{y}")
              end

              identifier = y.to_s=~/^[a-z_]/ ? y.to_s : "_#{y.to_s}"

              define_method "#{identifier}?" do
                is?("#{y}")
              end

              (
              class << self;
                self;
              end).class_eval do
                define_method identifier do
                  self.send("for_#{field}", y)
                end
              end
            end
          end
        end

        [:acts_as_enum, :enum_column, :enumerable_column, :acts_as_enumerable].each do |aliased|
          unless defined?(aliased)
            alias_method :aliased, :acts_as_enumeration
          end
        end
      end
    end
  end
end
