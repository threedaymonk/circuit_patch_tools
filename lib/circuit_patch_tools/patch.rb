require 'circuit_patch_tools/attr_lookup'
require 'circuit_patch_tools/any'

module CircuitPatchTools
  class Patch
    extend AttrLookup

    SYSEX = [
      ['C',    :sysex,                0xF0],
      ['C',    :manufacturer_1,       0x00],
      ['C',    :manufacturer_2,       0x20],
      ['C',    :manufacturer_3,       0x29],
      ['C',    :product_type,         0x01],
      ['C',    :product_number,       0x60],
      ['C',    :command,              0..1],
      ['C',    :location,             0..63],
      ['C',    :reserved,             Any],
      ['A16',  :patch_name,           Any],
      ['C',    :patch_category,       0..14],
      ['C',    :patch_genre,          0..9],
      ['a14',  :patch_reserved,       Any],
      ['C',    :voice_polyphony_mode, 0..2],
      ['a307', :patch_settings,       Any],
      ['C',    :eox,                  0xF7]
    ]

    PATTERN = SYSEX.map { |a, _, _| a }.join('')
    FIELDS  = SYSEX.map { |_, a, _| a }

    POLYPHONY = %i[ mono mono_ag poly ]
    GENRES = %i[
      none classic drumbass house industrial jazz randb rock techno dubstep
    ]
    CATEGORIES = %i[
      none arp bass bell classic drum keyboard lead movement pad poly sfx
      string user voc
    ]
    COMMANDS = %i[ replace_current_patch replace_patch ]

    def self.unpack(raw)
      values = raw.unpack(PATTERN)

      values.zip(SYSEX).each do |v, (_, name, validator)|
        unless validator === v
          raise "#{name}: #{v.inspect} does not satisfy #{validator.inspect}"
        end
      end

      new(FIELDS.zip(values).to_h)
    end

    def initialize(parameter_hash)
      @parameters = parameter_hash
    end

    def pack
      FIELDS.map { |f| @parameters[f] }.pack(PATTERN)
    end

    FIELDS.each do |f|
      define_method "_#{f}" do
        @parameters.fetch(f)
      end

      define_method "_#{f}=" do |v|
        @parameters[f] = v
      end

      private "_#{f}", "_#{f}="
    end

    alias_method :name, :_patch_name
    alias_method :name=, :_patch_name=
    alias_method :location, :_location
    alias_method :location=, :_location=

    attr_lookup :polyphony, :_voice_polyphony_mode, POLYPHONY
    attr_lookup :genre, :_patch_genre, GENRES
    attr_lookup :category, :_patch_category, CATEGORIES
    attr_lookup :command, :_command, COMMANDS
  end
end
