require 'circuit_patch_tools/patch'
require 'optparse'

module CircuitPatchTools
  module Commands
    class Join
      DEFAULT_OPTIONS = {
        output: 'patches.sysx'
      }

      def name
        'join'
      end

      def description
        'join up to 64 patches into a single sysex file'
      end

      def run(args)
        options = DEFAULT_OPTIONS.dup

        OptionParser.new do |opts|
          opts.banner = <<~END
            #{name}: #{description}

            Usage: circuit-patch #{name} [options] patch1.sysx [patch2.sysx ...]

            Options:
          END
          opts.on('-oFILENAME', '--output=FILENAME',
                  'Output filename',
                  "Default: #{DEFAULT_OPTIONS[:output]}",
                  String) do |v|
            options[:output] = v
          end
          opts.on('-h', '--help', 'Print this help') do
            puts opts
            return
          end
        end.parse!(args)

        join options, args
      end

    private
      def join(options, paths)
        output = options.fetch(:output)
        File.open(output, 'wb', encoding: Encoding::ASCII_8BIT) do |f|
          paths.each.with_index do |path, index|
            raw = File.open(path, 'rb', encoding: Encoding::ASCII_8BIT).read
            patch = Patch.unpack(raw)
            patch.command = :replace_patch
            patch.location = index
            f << patch.pack
          end
        end
      end
    end
  end
end
