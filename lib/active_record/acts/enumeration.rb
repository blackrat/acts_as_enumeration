module ActiveRecord
  module Acts
    module Enumeration

      VERSION="0.1.9a"
      class << self

        def included(base)
          base.instance_eval do
            extend ClassMethods
          end
        end
      end

      module ClassMethods
        private
        def portable_select(*args)
          respond_to?(:scoped) ? scoped(:select => "#{args.join(',')}") : select(*args)
        end

        def normalize(string)
          string.to_s.gsub(/[\W]+/, ' ').strip.gsub(/\s+/, '_').underscore
        end

        public
        def normalize_intern(string)
          normalize(string).intern
        end

        def acts_as_enumeration(*args)
          class << self;
            attr_accessor :enumeration;
          end
          self.enumeration||=HashWithIndifferentAccess.new
          args.each do |field|
            self.enumeration[field]=HashWithIndifferentAccess[
              *portable_select(field, primary_key).map do |x|
                [normalize_intern(x.send(field)), x.send(x.class.primary_key)]
              end.flatten
            ]
            (
            class << self;
              self;
            end).class_eval do
              define_method(:enumerations) { |name| self.enumeration[name] }
              define_method("#{field}_valid?") { |value| !!send("id_for_#{field}", value) }
              alias_method "valid_#{field}?", "#{field}_valid?"
              define_method("id_for_#{field}") { |value| enumerations(field)[value] }
              define_method("for_#{field}") { |value| find(send("id_for_#{field}", value)) }
              define_method("enum_#{field}") { enumerations(field) }
              define_method("as_key") { |value| find(value).as_key rescue nil }
            end

            define_method(:is?) { |*types| types.any? { |x| self==(self.class.send(x) rescue nil) } }
            define_method(:is_not?) { |*types| !is?(*types) }
            define_method(:method_missing) do |method_id, *args, &block|
              method_name=method_id.to_s
              if match_data=method_name.match(/^(is[_not]*)(\?|_(\w*)\?)/)
                method  =match_data[1] << "?"
                new_args= (match_data[2]=='?') ? args : match_data[3].split(/_or_/)
                respond_to?(method) ? send(method, *new_args, &block) : false
              else
                super method_id, *args, &block
              end
            end

            portable_select(field).map { |x| normalize_intern(x.send(field)) }.each do |y|
              key = y.to_s=~/^[a-z_]/ ? y.to_s : "_#{y.to_s}"
              define_method(:as_key) { self.class.normalize_intern(send(field)) }
              define_method("is_#{y}?") { is?(y) }
              alias_method "#{key}?", "is_#{y}?"
              class << self;
                self;
              end.instance_eval do
                define_method(key) { self.send("for_#{field}", y) }
                define_method(key.camelize) { self.send("id_for_#{field}", y)}
                define_method(key.camelize.upcase) { self.send(key.camelize)}
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
