# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update scopes.
    class ScopeForm < Form
      include TranslatableAttributes
      include JsonbAttributes

      translatable_attribute :name, String
      attribute :organization, Decidim::Organization
      attribute :code, String
      attribute :parent_id, Integer
      attribute :scope_type_id, Integer
      attribute :geolocalized, Boolean
      jsonb_attribute :geojson, [
        [:geometry, String],
        [:parsed_geometry, Hash],
        [:color, String]
      ]

      mimic :scope

      validates :name, translatable_presence: true
      validates :organization, :code, presence: true
      validate :code, :code_uniqueness
      validate :geojson, :parsable_json

      alias organization current_organization

      def scope_type
        Decidim::ScopeType.find_by(id: scope_type_id) if scope_type_id
      end

      def map_model(model)
        self.geolocalized = model.geojson.present?
      end

      private

      def code_uniqueness
        return unless organization
        return unless organization.scopes.where(code: code).where.not(id: id).any?

        errors.add(:code, :taken)
      end

      def parsable_json
        return true if geolocalized.blank?

        begin
          self.parsed_geometry = JSON.parse(geometry).deep_symbolize_keys
          if self.parsed_geometry[:type] = "FeatureCollection"
            if self.parsed_geometry[:features]&.size > 1
              errors.add(:geometry, "GeoJSON error : FeatureCollection with more than one feature are not valid")
            else
              self.parsed_geometry = self.parsed_geometry[:features]&.first
            end
          end
        rescue StandardError
          errors.add(:geometry, I18n.t("decidim.scope.errors.geojson_error"))
        end
      end
    end
  end
end
