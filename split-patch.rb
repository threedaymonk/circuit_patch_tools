require_relative './patch'

all = ARGF.read
all.force_encoding(Encoding::ASCII_8BIT)

all.scan(/\xF0\x00\x20\x29\x01\x60[\x00-\xFF]{343}\xF7/n).each do |raw|
  patch = Patch.unpack(raw)
  filename = format(
    '%02d - %s.sysx',
    patch.location,
    patch.name
  )
  $stderr.puts filename
  File.open(filename, 'wb', encoding: Encoding::ASCII_8BIT) do |f|
    f << raw
  end
end
