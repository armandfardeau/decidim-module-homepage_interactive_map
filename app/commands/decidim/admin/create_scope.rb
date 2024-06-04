# frozen_string_literal: true

require "decidim/homepage_interactive_map/coordinates_swapper"

module Decidim
  module Admin
    # A command with all the business logic when creating a static scope.
    class CreateScope < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # parent_scope - A parent scope for the scope to be created
      def initialize(form, parent_scope = nil)
        @form = form
        @parent_scope = parent_scope
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_scope
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_scope
        Decidim.traceability.create!(
          Scope,
          form.current_user,
          {
            name: form.name,
            organization: form.organization,
            code: form.code,
            geojson: Decidim::HomepageInteractiveMap::CoordinatesSwapper.convert_geojson(geojson),
            scope_type: form.scope_type,
            parent: @parent_scope
          },
          extra: {
            parent_name: @parent_scope.try(:name),
            scope_type_name: form.scope_type.try(:name)
          }
        )
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

        JSON.parse(geojson[:parsed_geometry].gsub('=>', ':')).deep_symbolize_keys
      end
    end
  end
end
