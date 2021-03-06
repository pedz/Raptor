# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class String
  ASCIITABLE = [
  0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20, # 00h
  0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20, # 10h
  0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20, # 20h
  0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20, # 30h
#                                                      ^    .    <    (    +    | 
  0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x5e,0x2e,0x3c,0x28,0x2b,0x7c, # 40h
#    &                                                 !    $    *    )    ;    [ 
  0x26,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x21,0x24,0x2a,0x29,0x3b,0x5b, # 50h
#    -    /                                            ]    ,    %    _    >    ? 
  0x2d,0x2f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x5d,0x2c,0x25,0x5f,0x3e,0x3f, # 60h
#                                                 `    :    #    @    '    =    " 
  0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x60,0x3a,0x23,0x40,0x27,0x3d,0x22, # 70h
#         a    b    c    d    e    f    g    h    i                               
  0x20,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x20,0x20,0x20,0x20,0x20,0x20, # 80h
#         j    k    l    m    n    o    p    q    r                               
  0x20,0x6a,0x6b,0x6c,0x6d,0x6e,0x6f,0x70,0x71,0x72,0x20,0x20,0x20,0x20,0x20,0x20, # 90h
#         ~    s    t    u    v    w    x    y    z                               
  0x20,0x7e,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,0x20,0x20,0x20,0x20,0x20,0x20, # a0h
  0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20, # b0h
#    {    A    B    C    D    E    F    G    H    I                               
  0x7b,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x20,0x20,0x20,0x20,0x20,0x20, # c0h
#    }    J    K    L    M    N    O    P    Q    R                               
  0x7d,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,0x50,0x51,0x52,0x20,0x20,0x20,0x20,0x20,0x20, # d0h
#    \         S    T    U    V    W    X    Y    Z                               
  0x5c,0x20,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5a,0x20,0x20,0x20,0x20,0x20,0x20, # e0h
#    0    1    2    3    4    5    6    7    8    9                               
  0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x20,0x20,0x20,0x20,0x20,0x20  # f0h
                 ]

  EBCDICTABLE = [
  0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40, # 00h
  0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40, # 10h
  0x40,0x5a,0x7f,0x7b,0x5b,0x6c,0x50,0x7d,0x4d,0x5d,0x5c,0x4e,0x6b,0x60,0x4b,0x61, # 20h
  0xf0,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf7,0xf8,0xf9,0x7a,0x5e,0x4c,0x7e,0x6e,0x6f, # 30h
  0x7c,0xc1,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xc8,0xc9,0xd1,0xd2,0xd3,0xd4,0xd5,0xd6, # 40h
  0xd7,0xd8,0xd9,0xe2,0xe3,0xe4,0xe5,0xe6,0xe7,0xe8,0xe9,0x5f,0xe0,0x5a,0x4a,0x6d, # 50h
  0x40,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x91,0x92,0x93,0x94,0x95,0x96, # 60h
  0x97,0x98,0x99,0xa2,0xa3,0xa4,0xa5,0xa6,0xa7,0xa8,0xa9,0xc0,0x4f,0xd0,0xa1,0x40, # 70h
  0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40, # 80h
  0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x4a,0x40,0x40,0x40,0x40, # 90h
  0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40, # a0h
  0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40, # b0h
  0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40, # c0h
  0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40, # d0h
  0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40, # e0h
  0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40  # f0h
                  ]

  RETAIN_CS = "IBM-037"
  USER_CS = "utf8"

  # Retain fields can have nulls in them.  We do a gsub while in
  # UTF-16.  I am guessing it is safer to do the substitution while in
  # UTF-16 than as a string since the Strings.gsub does not know about
  # double byte codes (and may replayce the space that shows up as the
  # second byte in a double byte sequence).
  #
  # The icu4r had some problems here.  /\0/.U seems to cause a core
  # dump.  The "\0".to_u has the proper effect and avoids the core
  # dump.  (Its probably cheaper to create too).
  if "a".respond_to? :force_encoding
    def retain_to_user(encoding = RETAIN_CS)
      self.to_u(encoding).
        gsub("\0".to_u, ' '.to_u).
        to_s(USER_CS).
        force_encoding('utf-8')
    end
  else
    def retain_to_user(encoding = RETAIN_CS)
      self.to_u(encoding).gsub("\0".to_u, ' '.to_u).to_s(USER_CS)
    end
  end

  def user_to_retain(encoding = RETAIN_CS)
    self.to_u(USER_CS).to_s(encoding)
  end

  # Makes string len length, truncating it if necessary, padding it
  # with padstr otherwise.
  def trim(len, padstr=" ")
    self.ljust(len, padstr)[0...len]
  end

  # There is no unpack for signed that is network order.  The only
  # signed unpack has is native order.  So, the test below determines
  # if the bytes need to be reversed before being passed to unpack.
  # We then define the functions we want.  The same trick is done
  # below for the reverse case.
  if [ 256 ].pack("s")[0].ord == 0
    def ret2short
      self.reverse.unpack("s")[0]
    end

    def ret2int
      self.reverse.unpack("l")[0]
    end
  else
    def ret2short
      self.unpack("s")[0]
    end

    def ret2int
      self.unpack("l")[0]
    end
  end
    
  def ret2uint
    self.unpack("N")[0]
  end
    
  def ret2ushort
    self.unpack("n")[0]
  end

  def singular?
    singularize == self
  end

  def plural?
    pluralize == self
  end
end

class Symbol
  def singularize
    self.to_s.singularize.to_sym
  end

  def pluralize
    self.to_s.pluralize.to_sym
  end

  def singular?
    ! plural?
  end

  def plural?
    pluralize == self
  end

  # Returns an tuple [ singular of sym, boolean if sym is plural ]
  def to_singular_tuple
    ssym = singularize
    [ ssym, (self != ssym) ]
  end
end

class Integer
  def uint2ret
    [ self ].pack("N")
  end
  
  def ushort2ret
    [ self ].pack("n")
  end

  if [ 256 ].pack("s")[0].ord == 0
    def short2ret
      [ self ].pack("s").reverse
    end

    def int2ret
      [ self ].pack("l").reverse
    end
  else
    def short2ret
      [ self ].pack("s")
    end

    def int2ret
      [ self ].pack("l")
    end
  end

end
