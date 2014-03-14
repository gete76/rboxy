module Rboxy
  module Binders
    class Knockout
      
      attr_reader :html, :js
     #ini
=begin
      def initialize command, obj
        @js = ''
        @html_attr = ''
        @command = command
        @obj = obj
      end
=end
      def run command, obj
        @js = ''
        @html = ''
        @command = command
        @obj = obj
        interpret_string
        return self
      end
      
      def interpret_string 
        #matching strings starting with a ko binder
        t = @command.match(/(\A[a-zA-Z]{2,12}):\s([a-zA-Z]+)/)
        @html = "data-bind=\"#{@command}\""
        if t == nil
          return @command
          #just give back string
        else
          case t[1].to_s
          when 'foreach'
            observable_array t[2].to_s       
          when 'if'

          when 'text'
          when 'html'
          end
        end
      end

      private

      def observable value
        @js << "var #{value} = ko.observable();"
      end

      def observable_array model       
        @js << "var #{model} = ko.observableArray([]);" 
        @js << "ko.applyBindings(#{model},document.getElementById('#{@obj[:id]}'));"
        @js <<  %Q<
          $.getJSON("/#{model.downcase}", function(response){
              $.each(response, function(ind,obj){
                  #{model}.push(obj)
              })             
          })
        >   
      end

      def binders
        %w{ foreach if ifnot with text attr visible html }
      end

      
    end
  end
end
