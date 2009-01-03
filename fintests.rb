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

require "fin"
require "test/unit"

class FileInspectorMock < FileInspector  
  attr_reader :bytes_per_row, :column_descriptors
end

class TestFileInspector < Test::Unit::TestCase
  def test_initialize
    fin = FileInspectorMock.new('a')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 1)
    assert_equal(fin.column_descriptors.first[:unpackStr], "a1")
    assert_equal(fin.column_descriptors.first[:byteLength], 1)
    assert_equal(fin.column_descriptors.first[:displayWidth], 7)
    
    fin = FileInspectorMock.new('b')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 1)
    fin = FileInspectorMock.new('B')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 1)
    
    fin = FileInspectorMock.new('h')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 1)
    fin = FileInspectorMock.new('H')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 1)
    
    fin = FileInspectorMock.new('c')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 1)
    fin = FileInspectorMock.new('C')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 1)
    
    fin = FileInspectorMock.new('s')
    assert_equal(fin.bytes_per_row, 2)
    assert_equal(fin.column_descriptors.length, 1)
    fin = FileInspectorMock.new('S')
    assert_equal(fin.bytes_per_row, 2)
    assert_equal(fin.column_descriptors.length, 1)
    
    fin = FileInspectorMock.new('f')
    assert_equal(fin.bytes_per_row, 4)
    assert_equal(fin.column_descriptors.length, 1)
    fin = FileInspectorMock.new('f')
    assert_equal(fin.bytes_per_row, 4)
    assert_equal(fin.column_descriptors.length, 1)
    
    fin = FileInspectorMock.new('d')
    assert_equal(fin.bytes_per_row, 8)
    assert_equal(fin.column_descriptors.length, 1)
    fin = FileInspectorMock.new('D')
    assert_equal(fin.bytes_per_row, 8)
    assert_equal(fin.column_descriptors.length, 1)
    
    fin = FileInspectorMock.new('abh')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 3)
    
    fin = FileInspectorMock.new('ad')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 2)
    
    fin = FileInspectorMock.new('af')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 2)
    
    fin = FileInspectorMock.new('df')
    assert_equal(fin.bytes_per_row, 4)
    assert_equal(fin.column_descriptors.length, 2)
    
    fin = FileInspectorMock.new('sd')
    assert_equal(fin.bytes_per_row, 2)
    assert_equal(fin.column_descriptors.length, 2)
    
    fin = FileInspectorMock.new('aaaaaaa')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 7)
    
    fin = FileInspectorMock.new('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
    assert_equal(fin.bytes_per_row, 1)
    assert_equal(fin.column_descriptors.length, 40)
    
    assert_raise(StandardError) { fin = FileInspectorMock.new('') }
    assert_raise(StandardError) { fin = FileInspectorMock.new('%') }
    assert_raise(StandardError) { fin = FileInspectorMock.new('A') }
    assert_raise(StandardError) { fin = FileInspectorMock.new(12) }
    assert_raise(StandardError) { fin = FileInspectorMock.new([1,2,3,4]) }
    assert_raise(StandardError) { fin = FileInspectorMock.new('arc') }
  end

  def test_consume
    fin = FileInspector.new('a')
    assert_equal(fin.consume("Test", "a1", 1), ['T', 'e', 's', 't'])
    assert_equal(fin.consume("Te t", "a1", 1), ['T', 'e', '[SPACE]', 't'])
    
    fin = FileInspector.new('c')
    assert_equal(fin.consume("a", "c1", 1), [97])
    
    fin = FileInspector.new('s')
    assert_equal(fin.consume("aa", "s1", 2), [24929])
    
    fin = FileInspector.new('as')
    assert_equal(fin.consume("aa", "a1", 1), ['a', 'a'])
    assert_equal(fin.consume("aa", "s1", 2), [24929])
    assert_equal(fin.consume("aaa", "s1", 2), [24929, '..'])
    assert_equal(fin.consume("aaa", "d1", 8), ['..'])
    assert_equal(fin.consume("a" * 600, "s1", 2), [24929] * 300)
    assert_equal(fin.consume("a" * 601, "s1", 2), ([24929] * 300) + ['..'])
  end
  
  def test_unpack_items_per_byte
    fin = FileInspector.new('abcd')
    
     assert_equal(fin.unpack_items_per_byte('b', 1), 8)
     assert_equal(fin.unpack_items_per_byte('b', 10), 8)
     assert_equal(fin.unpack_items_per_byte('b', 12.3), 8)
     
     assert_equal(fin.unpack_items_per_byte('B', 1), 8)
     assert_equal(fin.unpack_items_per_byte('B', 10), 8)
     assert_equal(fin.unpack_items_per_byte('B', 12.3), 8)
     
     assert_equal(fin.unpack_items_per_byte('h', 1), 2)
     assert_equal(fin.unpack_items_per_byte('h', 10), 2)
     assert_equal(fin.unpack_items_per_byte('h', 12.3), 2)
     
     assert_equal(fin.unpack_items_per_byte('H', 1), 2)
     assert_equal(fin.unpack_items_per_byte('H', 10), 2)
     assert_equal(fin.unpack_items_per_byte('H', 12.3), 2)
   end
 
end