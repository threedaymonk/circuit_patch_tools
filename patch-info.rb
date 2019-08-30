require_relative './patch'

raw = ARGF.read
raw.force_encoding(Encoding::ASCII_8BIT)

patch = Patch.unpack(raw)
%i[ name command location genre category ].each do |f|
  puts "#{f}: #{patch.send(f)}"
end
