# -----------------------------------------------------------------------------
#
# Various Geos-related internal utilities
#
# -----------------------------------------------------------------------------

module RGeo
  module Geos
    module Utils # :nodoc:
      class << self
        def ffi_coord_seqs_equal?(cs1, cs2, check_z)
          len1 = cs1.length
          len2 = cs2.length
          if len1 == len2
            (0...len1).each do |i|
              return false unless cs1.get_x(i) == cs2.get_x(i) &&
                cs1.get_y(i) == cs2.get_y(i) &&
                (!check_z || cs1.get_z(i) == cs2.get_z(i))
            end
            true
          else
            false
          end
        end

        def ffi_compute_dimension(geom)
          result = -1
          case geom.type_id
          when ::Geos::GeomTypes::GEOS_POINT
            result = 0
          when ::Geos::GeomTypes::GEOS_MULTIPOINT
            result = 0 unless geom.empty?
          when ::Geos::GeomTypes::GEOS_LINESTRING, ::Geos::GeomTypes::GEOS_LINEARRING
            result = 1
          when ::Geos::GeomTypes::GEOS_MULTILINESTRING
            result = 1 unless geom.empty?
          when ::Geos::GeomTypes::GEOS_POLYGON
            result = 2
          when ::Geos::GeomTypes::GEOS_MULTIPOLYGON
            result = 2 unless geom.empty?
          when ::Geos::GeomTypes::GEOS_GEOMETRYCOLLECTION
            geom.each do |g|
              dim = ffi_compute_dimension(g)
              result = dim if result < dim
            end
          end
          result
        end

        def ffi_coord_seq_hash(cs, hash = 0)
          (0...cs.length).inject(hash) do |h, i|
            [hash, cs.get_x(i), cs.get_y(i), cs.get_z(i)].hash
          end
        end

        def _init
          if FFI_SUPPORTED
            @ffi_supports_prepared_level_1 = ::Geos::FFIGeos.respond_to?(:GEOSPreparedContains_r)
            @ffi_supports_prepared_level_2 = ::Geos::FFIGeos.respond_to?(:GEOSPreparedDisjoint_r)
            @ffi_supports_set_output_dimension = ::Geos::FFIGeos.respond_to?(:GEOSWKTWriter_setOutputDimension_r)
            @ffi_supports_unary_union = ::Geos::FFIGeos.respond_to?(:GEOSUnaryUnion_r)
          end
          @psych_wkt_generator = WKRep::WKTGenerator.new(convert_case: :upper)
          @marshal_wkb_generator = WKRep::WKBGenerator.new
        end

        attr_reader :ffi_supports_prepared_level_1
        attr_reader :ffi_supports_prepared_level_2
        attr_reader :ffi_supports_set_output_dimension
        attr_reader :ffi_supports_unary_union
        attr_reader :psych_wkt_generator
        attr_reader :marshal_wkb_generator
      end
    end
  end
end
