module ActiveRecord
  module Acts
    module Enumeration
      VERSION="0.1.6"
      class << self
        def included(base)
          base.instance_eval do
            extend ClassMethods
          end
        end
      end

      module ClassMethods
        private
        def normalize(string)
          string.to_s.gsub(/[\\W]+/, ' ').strip.gsub(/\s+/, '_').underscore
        end

        def normalize_intern(string)
          normalize(string).intern
        end

        def portable_select(*args)
          respond_to?(:scoped) ? scoped(:select => ["#{args.join(',')}"]) : select(*args)
        end

        public
        def acts_as_enumeration(*args)
          args.each do |column_name|
            instance_variable_set(
              "@enum_#{column_name}".intern,
              Hash[*portable_select(column_name, primary_key).map { |x| [normalize_intern(x.send(column_name)), x.send(x.class.primary_key)] }.flatten]
            ) unless instance_variable_defined?("@enum_#{column_name}".intern)
            (
            class << self;
              self;
            end).class_eval do
              define_method(:enumerations) { |name| instance_variable_get("@enum_#{name}") }
              define_method("#{column_name}_valid?") { |value| !!send("id_for_#{column_name}", value) }
              define_method("id_for_#{column_name}") { |value| enumerations(column_name)[value] }
              define_method("for_#{column_name}") { |value| find(send("id_for_#{column_name}", value)) }
              define_method("enum_#{column_name}") { enumerations(column_name) }
              define_method("as_key") { |value|
                send(value).as_key rescue nil
              }
            end

            define_method(:is?) { |*types| types.any? { |x| self==(self.class.send(x) rescue nil) } }
            define_method(:is_not?) { |*types| !is?(*types) }
            define_method(:method_missing) do |method_id, *args, &block|
              method_name=method_id.to_s
              if match_data=method_name.match(/^(is[_not]*)(\?|_(\w*)\?)/)
                method  =match_data[1] << "?"
                new_args= ((match_data[2]=='?') ? args : match_data[3].split(/_or_/).map { |x| x.intern })
                respond_to?(method) ? send(method, *new_args, &block) : false
              else
                super method_id, *args, &block
              end
            end

            portable_select(column_name).map { |x| normalize_intern(x.send(column_name)) }.each do |y|
              key = y.to_s=~/^[a-z_]/ ? y.to_s : "_#{y.to_s}"
              define_method(:as_key) { self.class.normalize_intern(send(column_name)) }
              define_method("is_#{y}?") { is?(y) }
              alias_method "#{key}?", "is_#{y}?"
              (
              class << self;
                self;
              end).class_eval { define_method(key) { send("for_#{column_name}", y) } }
            end
          end
        end

        alias_method :acts_as_enumerable, :acts_as_enumeration
        alias_method :acts_as_enum, :acts_as_enumeration
        alias_method :enumerable_column, :acts_as_enumeration
        alias_method :enum_column, :acts_as_enumeration
      end
    end
  end
end
