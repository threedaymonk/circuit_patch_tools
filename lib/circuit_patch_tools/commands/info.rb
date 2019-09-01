require 'circuit_patch_tools/patch'
require 'optparse'

module CircuitPatchTools
  module Commands
    class Info
      FIELDS = %i[ path name command location genre category polyphony ]

      DEFAULT_OPTIONS = {
        fields: %w[ name genre category command location polyphony ]
      }

      def name
        'info'
      end

      def description
        'show patch information'
      end

      def run(args)
        options = DEFAULT_OPTIONS.dup

        OptionParser.new do |opts|
          opts.banner = <<~END
            #{name}: #{description}

            Usage: circuit-patch #{name} [options] patch1.sysex [patch2.sysex ...]

            Options:
          END
          opts.on('-fFIELDS', '--fields=FIELDS',
                  'Comma-separated list of fields to show',
                  "Default: #{DEFAULT_OPTIONS.fetch(:fields).join(',')}",
                  Array) do |v|
            options[:fields] = v
          end
          opts.on('-l', '--list', 'List available fields') do
            puts *FIELDS
          end
          opts.on('-h', '--help', 'Print this help') do
            puts opts
            return
          end
        end.parse!(args)

        args.each do |path|
          show_info options, path
        end
      end

    private
      def show_info(options, path)
        patch = Patch.open(path)
        metadata = FIELDS.map { |f| [f.to_s, patch.send(f)] }.to_h
        options.fetch(:fields).each do |k|
          puts "#{k}: #{metadata.fetch(k)}"
        end
      end

      class Patch < CircuitPatchTools::Patch
        attr_accessor :path

        def self.open(path)
          raw = File.open(path, 'rb', encoding: Encoding::ASCII_8BIT).read
          unpack(raw).tap { |p| p.path = path }
        end
      end
    end
  end
end
