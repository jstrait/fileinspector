What Is It?
===========

FileInspector allows you to view the contents of a file in different data formats side-by-side. It is similar to a hex viewer, but supports additional formats such as numbers of varying sizes and endianess. It is useful for helping to reverse-engineer file formats that contain multiple data types. It was originally written to help reverse engineer the *.HUB file format used by the Hammerhead drum machine (see clawhammer.rb, http://github.com/jstrait/clawhammer/tree/master), and then cleaned up for general use.


How to Install
==============

Two files are required for FileInspector:
    * FileInspector.rb - Contains the FileInspector class, which implements the core functionality.
    * fin.rb - A wrapper for FileInspector.rb which allows it to be used from the command line.


Usage
=====

ruby fin.rb [-bytes start:end] filename formats

    Example:
        ruby fin.rb example.txt abhsf

    This will produce the following output:

                     a          b    h        s                        f
    ====================================================================
          0:         T   00101010   45    26708     1.84924498566139e+31
          1:         h   00010110   86                                  
          2:         i   10010110   96    29545                         
          3:         s   11001110   37                                  
          4:   [SPACE]   00000100   02    26912     2.06176835630374e-19
          5:         i   10010110   96                                  
          6:         s   11001110   37     8307                         
          7:   [SPACE]   00000100   02                                  
          8:         a   10000110   16     8289     7.20534192010734e+22
          9:   [SPACE]   00000100   02                                  
         10:         t   00101110   47    25972                         
         11:         e   10100110   56                                  
         12:         s   11001110   37    29811     5.37580603001101e-31
         13:         t   00101110   47                                  
         14:         .   01110100   e2     3374                         
         15:      [CR]   10110000   d0                                  
         16:      [LF]   01010000   a0    21514     1.81692580458497e+31
         17:         T   00101010   45                                  
         18:         e   10100110   56    29541                         
         19:         s   11001110   37                                  
         20:         t   00101110   47    26996     1.12586848973162e+24
         21:         i   10010110   96                                  
         22:         n   01110110   e6    26478                         
         23:         g   11100110   76                                  
         24:   [SPACE]   00000100   02    12576     4.14885334976134e-08
         25:         1   10001100   13                                  
         26:         2   01001100   23    13106                         
         27:         3   11001100   33                                  
         28:         .   01110100   e2     3374                       ..
         29:      [CR]   10110000   d0                                  
         30:      [LF]   01010000   a0       ..                         


Parameters
==========

Bytes (Optional)

    Allows displaying only the part of the file between the start byte and end byte. If left out, the contents of the entire file will be displayed. Starting and ending byte indexes are zero-indexed.

    Examples:
        ruby fin.rb -bytes 0:9 example.txt abhs
           Display first 10 bytes of the file
        ruby fin.rb -bytes :9 example.txt abhs
           Same as above
        ruby fin.rb -bytes 10: example.txt abhs
           Display from 11th byte to end of file
        ruby fin.rb -bytes 10:20
           Display from 11th byte to 21st byte
  
File

    The name of the file to inspect.

Formats

	The data formats to display are specified using the same formats accepted by Ruby's String.pack and String.unpack methods. Certain format directives are not valid, because they don't make sense in the context of FileInspector.

        Supported: a, B, b, C, c, D, d, E, e, F, f, G, g, H, h, I, i, L, l, N, n, Q, q, S, S, V, v
        Unsupported: @, A, M, m, P, p, U, u, w, X, x, Z
