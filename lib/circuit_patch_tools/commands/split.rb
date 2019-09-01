require 'circuit_patch_tools/patch'
require 'optparse'

module CircuitPatchTools
  module Commands
    class Split
      FIELDS = %i[ name command location genre category polyphony ]

      DEFAULT_OPTIONS = {
        filename: '%<location>02d - %<name>s.sysex'
      }

      PATCH_REGEXP = /\xF0\x00\x20\x29\x01\x60[\x00-\xFF]{343}\xF7/n

      def name
        'split'
      end

      def description
        'extract patches from a single sysex file into one file per patch'
      end

      def run(args)
        options = DEFAULT_OPTIONS.dup

        OptionParser.new do |opts|
          opts.banner = <<~END
            #{name}: #{description}

            Usage: circuit-patch #{name} [options] patch1.sysex [patch2.sysex ...]

            Options:
          END
          opts.on('-fPATTERN', '--filename=PATTERN',
                  'Pattern for filenames',
                  "Default: #{DEFAULT_OPTIONS[:filename].inspect}",
                  String) do |v|
            options[:filename] = v
          end
          opts.on('-h', '--help', 'Print this help') do
            puts opts
            return
          end
        end.parse!(args)

        extract_all options, args
      end

    private
      def extract_all(options, paths)
        paths.each do |path|
          File.open(path, 'rb', encoding: Encoding::ASCII_8BIT)
            .read
            .scan(PATCH_REGEXP).each do |raw|
              extract_one options, raw
            end
        end
      end

      def extract_one(options, raw)
        patch = Patch.unpack(raw)

        metadata = FIELDS.map { |f| [f, patch.send(f)] }.to_h
        filename = format(options.fetch(:filename), metadata)

        $stderr.puts filename
        File.open(filename, 'wb', encoding: Encoding::ASCII_8BIT) do |f|
          f << raw
        end
      end
    end
  end
end
