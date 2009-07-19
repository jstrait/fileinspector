#!/usr/bin/env ruby
# Copyright (c) 2009 Joel Strait
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

class FileInspector
  BLOCK_SIZE = 512
  LOWERCASE_A = 97
  COLUMN_PADDING = 3
  NOT_ENOUGH_BYTES_MSG = ".."
  PRETTY_CHARS = ["[NUL]", "[SOH]", "[STX]", "[ETX]", "[EOT]", "[ENQ]", "[ACK]", "[BEL]",
                   "[BS]",  "[TAB]", "[LF]",  "[VT]",  "[FF]",  "[CR]",  "[SO]",  "[SI]",
                   "[DLE]", "[DC1]", "[DC2]", "[DC3]", "[DC4]", "[NAK]", "[SYN]", "[ETB]",
                   "[CAN]", "[EM]",  "[SUB]", "[ESC]", "[FS]",  "[GS]",  "[RS]",  "[US]",
                   "[SPACE]", "!",   "\"",    "#",     "$",     "%",     "&",     "'",
                   "(",     ")",     "*",     "+",     ",",     "-",     ".",     "/",
                   "0",     "1",     "2",     "3",     "4",     "5",     "6",     "7",
                   "8",     "9",     ":",     ";",     "<",     "=",     ">",     "?",
                   "@",     "A",     "B",     "C",     "D",     "E",     "F",     "G",
                   "H",     "I",     "J",     "K",     "L",     "M",     "N",     "O",
                   "P",     "Q",     "R",     "S",     "T",     "U",     "V",     "W",
                   "X",     "Y",     "Z",     "[",     "\\",    "]",     "^",     "_",
                   "`",     "a",     "b",     "c",     "d",     "e",     "f",     "g",
                   "h",     "i",     "j",     "k",     "l",     "m",     "n",     "o",
                   "p",     "q",     "r",     "s",     "t",     "u",     "v",     "w",
                   "x",     "y",     "z",     "{",     "|",     "}",     "~",     "[DEL]"]

  def initialize(format_str)
    if format_str == "" || format_str.class != String
      raise StandardError, "Must provide a list of display formats"
    end

    @column_descriptors = []
    @bytes_per_row = 10000   # Larger than any format byte length

    format_str.each_byte{|format|
      new_column_descriptor = build_column_descriptor(format.chr)
      @column_descriptors.push(new_column_descriptor)

      if new_column_descriptor[:byteLength] < @bytes_per_row
        @bytes_per_row = new_column_descriptor[:byteLength]
      end
    }

    # Must occur after each column format is built, because until then
    # the number of bytes per display row isn't known.
    @column_descriptors.each {|column_descriptor|
      unpack_str = column_descriptor[:unpackStr]
      column_descriptor[:unpackStr] += items_to_unpack_per_byte(unpack_str, column_descriptor[:byteLength]).to_s
    }
  end

  def display_header(byte_column_width)
    puts ""
    row = " " * byte_column_width
    @column_descriptors.each {|column_descriptor|
      row += column_descriptor[:unpackStr][0].chr.rjust(column_descriptor[:displayWidth] + COLUMN_PADDING, " ")
    }
    puts row
    puts "=" * row.length
  end

  def display(start_byte, end_byte, data)
    if start_byte > end_byte
      raise StandardError, "Starting byte is after than ending byte"
    end

    byte_column_width = end_byte.to_s.length + 1  # Add extra pad for : character

    display_header(byte_column_width)

    end_byte += 1
    display_byte_index = start_byte
    seek_byte_index = start_byte

    while seek_byte_index < end_byte
      bytes_in_current_block = end_byte - seek_byte_index

      if bytes_in_current_block < BLOCK_SIZE
        block = data[seek_byte_index, bytes_in_current_block]
      else
        bytes_in_current_block = BLOCK_SIZE
        block = data[seek_byte_index, BLOCK_SIZE]
      end

      cols = []
      @column_descriptors.each {|column_descriptor|
        col_data = consume(block, column_descriptor[:unpackStr], column_descriptor[:byteLength])
        cols.push(col_data)
      }

      (0...cols[0].length).each { |row_index|
        # Output current row
        row = "#{display_byte_index}:".rjust(byte_column_width, " ")
        i = 0
        cols.each{|col|
          row += (" " * COLUMN_PADDING) + col[row_index].to_s.rjust(@column_descriptors[i][:displayWidth], " ")
          i += 1
        }
        puts row

        display_byte_index += @bytes_per_row
        seek_byte_index += @bytes_per_row
      }
    end
  end

  def consume(block, unpack_format, format_length)
    arr = []
    i = 0
    while i < block.length
      rows = block[i, format_length].unpack(unpack_format)
      if rows[0] == nil
        rows[0] = NOT_ENOUGH_BYTES_MSG
      end
      arr += rows
      i += format_length
    end

    if unpack_format[0] == LOWERCASE_A  # 'a'
      arr = arr.map {|char|
        pretty_char = PRETTY_CHARS[char[0]]
        (pretty_char != nil) ? pretty_char : char
      }
    end

    return arr
  end

  def build_column_descriptor(format)
    # Unsupported: M, m, P, p, U, u, w, X, x, Z, @, A
    column_descriptor = case format
      when "a" then                     { :byteLength => 1, :displayWidth => 7,  :caption => "Alpha" }
      when "B", "b" then                { :byteLength => 1, :displayWidth => 8,  :caption => "Binary" }
      when "C", "c" then                { :byteLength => 1, :displayWidth => 3,  :caption => "Int8" }
      when "D", "d", "E", "e", "G" then { :byteLength => 8, :displayWidth => 22, :caption => "" }
      when "F", "f", "g" then           { :byteLength => 4, :displayWidth => 22, :caption => "" }
      when "H", "h" then                { :byteLength => 1, :displayWidth => 2,  :caption => "Hex" }
      when "I", "i" then                { :byteLength => 4, :displayWidth => 10, :caption => "Int32" }
      when "L", "l" then                { :byteLength => 4, :displayWidth => 10, :caption => "Int32" }
      when "N", "Q", "q", "V" then      { :byteLength => 8, :displayWidth => 16, :caption => "int16" }
      when "n", "S", "s", "v" then      { :byteLength => 2, :displayWidth => 6,  :caption => "" }
      else raise StandardError, "Unsupported format: #{format}"
    end

    column_descriptor[:unpackStr] = format
    return column_descriptor
  end

  # The number to append after the unpack format.
  # For example, 8.
  def items_to_unpack_per_byte(format, format_length)
    if format == "B" || format == "b"
      byte_length = 8
    elsif format == "H" || format == "h"
      # Each hex character is 4 bits
      byte_length = 2
    else
      byte_length = (format_length / @bytes_per_row).to_i
    end

    return byte_length
  end
end