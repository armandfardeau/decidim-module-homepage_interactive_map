# frozen_string_literal: true

require "rgeo"
require "rgeo/proj4"

module Decidim
  module HomepageInteractiveMap
    # This class swaps the coordinates of a feature
    module CoordinatesSwapper
      def self.convert_geojson(geojson, opts = {})
        return if geojson.nil?
        return if geojson.try(:values)&.compact.blank?

        from = opts[:from] || detect_crs(geojson) || "EPSG:4326"
        to = opts[:to] || "EPSG:4326"

        geojson_clone = geojson.dup.deep_symbolize_keys
        new_coordinates = transform(geojson_clone[:parsed_geometry][:geometry][:coordinates], from, to)
        new_geometry = geojson_clone[:parsed_geometry][:geometry].merge(
          {
            coordinates: new_coordinates,
            crs: to
          }
        )
        new_parsed_geometry = geojson_clone[:parsed_geometry].merge(geometry: new_geometry)

        geojson_clone.merge(parsed_geometry: new_parsed_geometry)
      end

      def self.transform(coordinates, from, to)
        return coordinates if from == to

        coord_sys_from = coord_sys(from)
        coord_sys_to = coord_sys(to)

        return transform_coords(coord_sys_from, coord_sys_to, coordinates.first, coordinates.last, nil) if coordinates.length == 2

        coordinates.map do |coord|
          if coord.first.is_a?(Array)
            transform(coord, from, to)
          else
            lat, lon = coord
            transform_coords(coord_sys_from, coord_sys_to, lat, lon, nil)
          end
        end
      end

      def self.transform_coords(projection, geography, lat, lon, alt)
        RGeo::CoordSys::Proj4.transform_coords(projection, geography, lat, lon, alt)
      end

      def self.coord_sys(coord_sys)
        RGeo::CoordSys::Proj4.create(coord_sys)
      end

      def self.detect_crs(geojson)
        geojson.dup.deep_symbolize_keys.dig(:parsed_geometry, :geometry, :crs)
      end
    end
  end
end
