# frozen_string_literal: true

module Gitlab
  module Graphql
    module Representation
      class AiFeatureSetting < SimpleDelegator
        include GlobalID::Identification

        class << self
          def decorate_with_valid_models(feature_settings)
            return if feature_settings.nil?

            indexed_self_hosted_models = ::Ai::SelfHostedModel.all.group_by(&:model)

            feature_settings.map do |feature_setting|
              valid_models = []

              feature_setting.compatible_llms.each do |model|
                models = indexed_self_hosted_models[model]
                next if models.nil?

                valid_models.append(*models)
              end

              new(feature_setting, valid_models)
            end
          end
        end

        attr_accessor :valid_models

        def initialize(feature_setting, valid_models)
          @feature_setting = feature_setting
          @valid_models = valid_models

          super(feature_setting)
        end
      end
    end
  end
end
