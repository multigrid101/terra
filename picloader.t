local SHAREDIR = '/home/sebastian/Desktop/masterarbeit/code/share/'

local includestring =           '#include <stdio.h>\n'
includestring = includestring .. '#include <stdlib.h>\n'
includestring = includestring .. '#include "' .. SHAREDIR .. 'lodepng/lodepng.h"\n'

local C = terralib.includecstring(includestring)
terralib.linklibrary(SHAREDIR .. "lodepng/liblodepng.so")


local M = {} -- the module table


local struct PNGpic {
_width : uint 
_height : uint
_data : &float
}                                                                               

-- create a white picture with a box in the middle, this is sufficient to see
-- if blur-kernels etc. are working correctly
-- TODO finish implementation
terra PNGpic_getTestPictureBW(width : int, height : int) : &float
  var picdata : &float
  picdata = [&float](C.malloc( width * height * sizeof(float) ))

  var numpixels = width*height
  for k = 0,width*height do
    picdata[k] = [float](k)/3.0
  end

end


terra PNGpic:writeToFile(filename : &int8)                                                                                                                                                              
  var w = self._width
  var h = self._height

  var picnewint : &uint8 = [&uint8](C.malloc(w*h*sizeof(uint8)))             

  for k = 0, w*h do                                                          
    picnewint[k] = self._data[k]                                              
  end                                                                        

  C.lodepng_encode_file(filename, picnewint, w,h,0,8)                         
end                                                                            


-- static class method (constructor)
terra PNGpic_fromFile(filename : &int8) -- get image as float

  var int_data : &uint8                                                            
  var w : uint                                                                
  var h : uint                                                                

  var thepic : PNGpic                                                         

  C.lodepng_decode_file(&int_data, &w, &h, filename, 0, 8)                         

  -- copy to float array                                                    
  var float_data : &float = [&float](C.malloc(w*h*sizeof(float)))               
  for k = 0, w*h do                                                           
    float_data[k] = int_data[k]                                                    
    -- C.printf("%f\n", picfloat[k])                                        
  end                                                                         

  C.free(int_data)                                                                 

  thepic._width = w                                                            
  thepic._height = h                                                           
  thepic._data = float_data                                                      

  return thepic                                                               
end                                                                             

-------------------------------------------------------------------------------
-- Setters / Getters
-------------------------------------------------------------------------------
terra PNGpic:getData()
  return self._data
end

terra PNGpic:getHeight()
  return self._height
end

terra PNGpic:getWidth()
  return self._width
end


-------------------------------------------------------------------------------
-- Build module table
-------------------------------------------------------------------------------
M.PNGpic = PNGpic
M.PNGpic_fromFile = PNGpic_fromFile


return M
