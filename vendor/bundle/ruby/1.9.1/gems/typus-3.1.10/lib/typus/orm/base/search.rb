module Typus
  module Orm
    module Base
      module Search

        def build_search_conditions(key, value)
          raise "Not implemented!"
        end

        def build_boolean_conditions(key, value)
          { key => (value == 'true') ? true : false }
        end

        def build_datetime_conditions(key, value)
          tomorrow = Time.zone.now.beginning_of_day.tomorrow

          interval = case value
                     when 'today'         then 0.days.ago.beginning_of_day..tomorrow
                     when 'last_few_days' then 3.days.ago.beginning_of_day..tomorrow
                     when 'last_7_days'   then 6.days.ago.beginning_of_day..tomorrow
                     when 'last_30_days'  then 30.days.ago.beginning_of_day..tomorrow
                     end

          build_filter_interval(interval, key)
        end

        alias_method :build_time_conditions, :build_datetime_conditions

        def build_date_conditions(key, value)
          tomorrow = 0.days.ago.tomorrow.to_date

          interval = case value
                     when 'today'         then 0.days.ago.to_date..tomorrow
                     when 'last_few_days' then 3.days.ago.to_date..tomorrow
                     when 'last_7_days'   then 6.days.ago.to_date..tomorrow
                     when 'last_30_days'  then 30.days.ago.to_date..tomorrow
                     end

          build_filter_interval(interval, key)
        end

        def build_filter_interval(interval, key)
          raise "Not implemented!"
        end

        def build_string_conditions(key, value)
          { key => value }
        end

        alias_method :build_integer_conditions, :build_string_conditions
        alias_method :build_belongs_to_conditions, :build_string_conditions

        # TODO: Detect the primary_key for this object.
        def build_has_many_conditions(key, value)
          ["#{key}.id = ?", value]
        end

        # To build conditions we accept only model fields and the search
        # param.
        def build_conditions(params)
          Array.new.tap do |conditions|
            query_params = params.dup

            query_params.reject! do |k, v|
              !model_fields.keys.include?(k.to_sym) &&
              !model_relationships.keys.include?(k.to_sym) &&
              !(k.to_sym == :search)
            end

            query_params.compact.each do |key, value|
              filter_type = model_fields[key.to_sym] || model_relationships[key.to_sym] || key
              conditions << send("build_#{filter_type}_conditions", key, value)
            end
          end
        end

        def build_my_joins(params)
          query_params = params.dup
          query_params.reject! { |k, v| !model_relationships.keys.include?(k.to_sym) }
          query_params.compact.map { |k, v| k.to_sym }
        end

      end
    end
  end
end
