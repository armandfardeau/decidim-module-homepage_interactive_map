# frozen_string_literal: true

require "decidim/homepage_interactive_map/coordinates_swapper"

module Decidim
  module Admin
    # A command with all the business logic when updating a scope.
    class UpdateScope < Decidim::Command
      # Public: Initializes the command.
      #
      # scope - The Scope to update
      # form - A form object with the params.
      def initialize(scope, form)
        @scope = scope
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_scope
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_scope
        Decidim.traceability.update!(
          @scope,
          form.current_user,
          attributes,
          extra: {
            parent_name: @scope.parent.try(:name),
            scope_type_name: form.scope_type.try(:name)
          }
        )
      end

      def attributes
        {
          name: form.name,
          code: form.code,
          geojson: Decidim::HomepageInteractiveMap::CoordinatesSwapper.convert_geojson(geojson),
          scope_type: form.scope_type
        }
      end

      def geojson
        return nil if form.geolocalized.blank?

        geojson = form.geojson.deep_dup.deep_symbolize_keys
        {
          color: geojson[:color] || form.color,
          geometry: geojson[:geometry],
          parsed_geometry: parsed_geometry(geojson)
        }
      end

      def parsed_geometry(geojson)
        return if geojson.nil? || geojson[:geometry].nil?
        return geojson[:parsed_geometry].deep_symbolize_keys if geojson[:parsed_geometry].is_a? Hash

        JSON.parse(geojson[:parsed_geometry].gsub("=>", ":")).deep_symbolize_keys
      end
    end
  end
end
