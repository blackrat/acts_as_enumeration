module ActsAsEnum
  def acts_as_enumerable(*args)
    args.each do |column_name|

      class_eval(%Q(
        unless defined? @@enum_#{column_name}
          @@enum_#{column_name}=Hash[*all.map{|x| [x.send(column_name).gsub(/[\\W]+/,' ').strip.gsub(/\s+/,'_').underscore.intern,x.send(x.class.primary_key)]}.flatten]
        end
      ), __FILE__, __LINE__+1)

      all.map { |x| x.send(column_name).gsub(/[\W]+/, ' ').strip.gsub(/\s+/, '_').underscore.intern }.each do |y|
        class_eval(%Q(
          def is_#{y}?
            is?("#{y}".intern)
          end
                   ), __FILE__, __LINE__+1)

        identifier = y.to_s=~/^[a-z_]/ ? y.to_s : "_#{y.to_s}"
        class_eval(%Q(
          def #{identifier}?
            is_#{y}?
          end
                   ), __FILE__, __LINE__+1)

        class_eval(%Q(
          def self.#{identifier}
            for_#{column_name}("#{y}".intern)
          end
                   ), __FILE__, __LINE__+1)
      end

      class_eval(%Q(
        def self.enum_#{column_name}
          @@enum_#{column_name}
        end
      ), __FILE__, __LINE__+1)

      class_eval(%Q(
        def self.as_key(value)
          return nil unless exists?(value)
          find(value).as_key
        end
      ), __FILE__, __LINE__+1)

      class_eval(%Q(
        def self.valid_#{column_name}?(value)
          @@enum_#{column_name}.keys.include?(value)
        end
      ), __FILE__, __LINE__+1)

      class_eval(%Q(
        def self.id_for_#{column_name}(value)
          @@enum_#{column_name}[value]
        end
      ), __FILE__, __LINE__+1)

      class_eval(%Q(
        def self.for_#{column_name}(value)
          find(id_for_#{column_name}(value))
        end
      ), __FILE__, __LINE__+1)

      class_eval(%Q(
        def is?(*types)
          types.any?{|x| send(self.class.primary_key)==self.class.enum_#{column_name}[x]}
        end
      ), __FILE__, __LINE__+1)

      class_eval(%Q(
        def is_not?(*types)
          !is?(*types)
        end
      ), __FILE__, __LINE__+1)

      class_eval(%Q(
        def as_key
          #{column_name}.gsub(/[\\W]+/,' ').strip.gsub(/\s+/,'_').underscore.intern
        end
        alias_method :as_symbol, :as_key
                 ))

      class_eval(%Q(
        def method_missing(method_id, *args, &block)
          method_name=method_id.to_s
          if match_data=method_name.match(/^(is[_not]*)(\\?|_(\\w*)\\?)/)
            method=match_data[1] << "?"
            new_args= ((match_data[2]=='?') ? args : match_data[3].split(/_or_/).map{|x| x.intern})
            respond_to?(method) ? send(method,*new_args,&block) : false
          else
            super
          end
        end
       ), __FILE__, __LINE__+1)
    end
  end

  alias_method :acts_as_enum, :acts_as_enumerable
  alias_method :enumerable_column, :acts_as_enumerable
  alias_method :enum_column, :acts_as_enumerable
end
