# rubocop:disable Style/AsciiComments
# LATIN SCRIPT UNICODE RANGES
#########################################################
# Basic Latin, 0000–007F. This block corresponds to ASCII.
# Latin-1 Supplement, 0080–00FF
# Latin Extended-A, 0100–017F
# Latin Extended-B, 0180–024F
# IPA Extensions, 0250–02AF
# Spacing Modifier Letters, 02B0–02FF
# Phonetic Extensions, 1D00–1D7F
# Phonetic Extensions Supplement, 1D80–1DBF
# Latin Extended Additional, 1E00–1EFF
# Superscripts and Subscripts, 2070-209F
# Letterlike Symbols, 2100–214F
# Number Forms, 2150–218F
# Latin Extended-C, 2C60–2C7F
# Latin Extended-D, A720–A7FF
# Latin Extended-E, AB30–AB6F
# Alphabetic Presentation Forms (Latin ligatures) FB00–FB4F
# Halfwidth and Fullwidth Forms (fullwidth Latin letters) FF00–FFEF
class String
  CHECK_INDEXES = [0, 5, 11]
  RTL_RANGE = [0x590..0x8FF, 0xFB1D..0xFB44, 0xFB50..0xFDFF, 0xFE70..0xFEFF, 0x10800..0x10F00]

  def dir(opts = {})
    opts.fetch(:check_indexes, CHECK_INDEXES).each do |i|
      RTL_RANGE.each do |subrange|
        return "rtl" if subrange.cover?(self[i].unpack('U*0')[0]) if self[i]
      end
    end
    "ltr"
  end
end
