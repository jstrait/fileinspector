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

require 'optparse'
require 'FileInspector'

def read_file(file_name)
  #blockSize = 1_048_576
  #blockSize = 4_294_967_296
  block_size = 16_777_216
  file_contents = ""
  file = File.open(file_name, "rb")
  
  begin
    while true
      file_contents += file.sysread(block_size)
    end
  rescue EOFError
    file.close()
  end

  return file_contents
end

def parse_arguments()
  params = {}
  
  if ARGV[0] == "-bytes"
    params[:byteRange] = ARGV[1].split(":")
    params[:fileName] = ARGV[2]
    params[:columnFormats] = ARGV[3]
  else
    params[:byteRange] = "0:".split(":")
    params[:fileName] = ARGV[0]
    params[:columnFormats] = ARGV[1]
  end

  return params;
end

def main()
  params = parse_arguments()
  file_contents = read_file(params[:fileName])
  
  start_byte = params[:byteRange][0].to_i
  end_byte = params[:byteRange][1]
  if(end_byte == nil)
    end_byte = file_contents.length - 1
  else
    end_byte = endByte.to_i
  end
  if end_byte > file_contents.length
    puts "Warning: ending byte is greater than length of file"
    end_byte = file_contents.length - 1
  end
  
  puts "Start Byte: #{start_byte}, End Byte: #{end_byte}"
  
  inspector = FileInspector.new(params[:columnFormats])
  inspector.display(start_byte, end_byte, file_contents)
end

main()