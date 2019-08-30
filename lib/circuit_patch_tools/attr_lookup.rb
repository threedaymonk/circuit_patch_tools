module CircuitPatchTools
  module AttrLookup
    def attr_lookup(ext, int, table)
      define_method ext do
        table.fetch(send(int))
      end

      define_method "#{ext}=" do |v|
        send "#{int}=", table.index(v)
      end
    end
  end
end
