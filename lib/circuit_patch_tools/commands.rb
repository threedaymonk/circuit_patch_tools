require 'circuit_patch_tools/commands/info'
require 'circuit_patch_tools/commands/portable'
require 'circuit_patch_tools/commands/split'

module CircuitPatchTools
  module Commands
    def self.handlers
      @handlers ||= [Info, Portable, Split].map(&:new)
    end
  end
end
