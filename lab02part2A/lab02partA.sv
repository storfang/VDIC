virtual class shape;
   protected real width;
   protected real height;
   
   function new(real w, real h);
      width = w;
      height = h;
   endfunction
   
   pure virtual function real get_area();
   pure virtual function void print();
   
endclass : shape

class rectangle extends shape;
   
   function new(real w, real h);
      super.new(w, h);
   endfunction : new
   
   function real get_area();
      return (width*height);
   endfunction
   
   function void print();
      $display("Rectangle w=%g h=%g area=%g", width,height,get_area());
   endfunction 
endclass 

class square extends shape;
   
   function new(real w, real h);
      super.new(w, h);
   endfunction : new
   
   function real get_area();
      return (width*width);
   endfunction
   
   function void print();
      $display("Square w=%g h=%g area=%g", width,height,get_area());
   endfunction 
endclass 

class triangle extends shape;
   
   function new(real w, real h);
      super.new(w, h);
   endfunction : new
   
   function real get_area();
      return (0.5*width*height);
   endfunction
   
   function void print();
      $display("Triangle w=%g h=%g area=%g", width,height,get_area());
   endfunction 
endclass : triangle


class shape_factory;
   
   static function shape make_shape(string shape_type, real w, real h);
      rectangle rectangle_h;
      square square_h;
      triangle triangle_h;
      
      case (shape_type)
         "rectangle" : begin
            rectangle_h = new(w,h);
            return rectangle_h;
         end 
         "square" : begin
            square_h = new(w,h);
            return square_h;
         end 
         "triangle" : begin
            triangle_h = new(w, h);
            return triangle_h;
         end 
        default : 
          $fatal (1, {"No such shape: ", shape_type});
      endcase 
   endfunction
   
endclass : shape_factory

class shape_reporter #(type T = shape);
   protected static T shape_storage[$];
   
   static function void queue_shape(T s);
      shape_storage.push_back(s);
   endfunction
   
   static function void report_shapes();
      real sum_area;
      foreach(shape_storage[i]) begin
         shape_storage[i].print();
         sum_area += shape_storage[i].get_area();
      end 
      $display("Total area: %g\n", sum_area);
   endfunction 
   
endclass : shape_reporter

module top;
   
   initial begin
      rectangle rectangle_h;
      square square_h;
      triangle triangle_h;
      bit cast_ok;
      
      int fsh;
      real width;
      real heigth;
      string shape_name;
      int read_num;
      
      fsh = $fopen("lab02part2A_shapes.txt", "r");
      
      while($fscanf(fsh, "%s %g %g", shape_name, width, heigth) == 3) begin
         
         case (shape_name)
            "rectangle" : begin
               if (!$cast(rectangle_h, shape_factory::make_shape(shape_name, width, heigth)))
                  $fatal(1, "Failed to cast shape from factory to rectangle_h");
               
               shape_reporter#(rectangle)::queue_shape(rectangle_h);
            end 
            "square" : begin
               if (!$cast(square_h, shape_factory::make_shape(shape_name, width, heigth)))
                  $fatal(1, "Failed to cast shape from factory to square_h");
               
               shape_reporter#(square)::queue_shape(square_h);
            end 
            "triangle" : begin
               if (!$cast(triangle_h, shape_factory::make_shape(shape_name, width, heigth)))
                  $fatal(1, "Failed to cast shape from factory to triangle_h");
               
               shape_reporter#(triangle)::queue_shape(triangle_h);
            end 
           default : 
             $fatal (1, {"No such shape: ", shape_name});
         endcase 
      end 
      
      shape_reporter #(rectangle)::report_shapes();
      shape_reporter #(square)::report_shapes();
      shape_reporter #(triangle)::report_shapes();
   
   end    
endmodule 

