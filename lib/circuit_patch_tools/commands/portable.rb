require 'circuit_patch_tools/patch'
require 'optparse'

module CircuitPatchTools
  module Commands
    class Portable
      DEFAULT_OPTIONS = {
        synth: 1
      }

      def name
        'portable'
      end

      def description
        'make patches portable'
      end

      def run(args)
        options = DEFAULT_OPTIONS.dup

        OptionParser.new do |opts|
          opts.banner = <<~END
            #{name}: #{description}

            Usage: circuit-patch #{name} [options] patch1.sysex [patch2.sysex ...]

            Options:
          END
          opts.on('-sSYNTH', '--synth=SYNTH',
                  'Synth for the patch',
                  "Default: #{DEFAULT_OPTIONS[:synth]}",
                  Integer) do |v|
            options[:synth] = v
          end
          opts.on('-h', '--help', 'Print this help') do
            puts opts
            return
          end
        end.parse!(args)

        args.each do |path|
          make_portable options, path
        end
      end

    private
      def make_portable(options, path)
        raw = File.open(path, 'rb', encoding: Encoding::ASCII_8BIT).read
        patch = Patch.unpack(raw)
        patch.command = :replace_current_patch
        patch.location = options.fetch(:synth) - 1
        File.open(path, 'wb', encoding: Encoding::ASCII_8BIT) do |f|
          f << patch.pack
        end
      end
    end
  end
end
