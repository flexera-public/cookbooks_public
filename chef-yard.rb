
class Defenition < YARD::Handlers::Ruby::Base
  handles method_call(:define)
  namespace_only

  YARD::Parser::SourceParser.before_parse_file do |p|
    @@parsed_file =  p.file.to_s
  end

  def process
    path_arr = @@parsed_file.to_s.split('/')
    ext_obj = YARD::Registry.resolve(:root, "#{path_arr[0].to_s}::#{path_arr[1].to_s}::#{path_arr[2].to_s}::#{path_arr[3].to_s}", true)

    name = statement.parameters.first.jump(:tstring_content, :ident).source
    object = YARD::CodeObjects::MethodObject.new(ext_obj, name)
    register(object)
    object.object_id
    parse_block(statement.last.last)
    object.dynamic = false

  end
end



class Action < YARD::Handlers::Ruby::Base
  handles method_call(:action)
  namespace_only

  YARD::Parser::SourceParser.before_parse_file do |p|
    @@parsed_file =  p.file.to_s
  end

  def process
    path_arr = @@parsed_file.to_s.split('/')
    ext_obj = YARD::Registry.resolve(:root, "#{path_arr[0].to_s}::#{path_arr[1].to_s}::#{path_arr[2].to_s}::#{path_arr[3].to_s}", true)

    name = statement.parameters.first.jump(:tstring_content, :ident).source
    object = YARD::CodeObjects::MethodObject.new(ext_obj, name)
    register(object)
    object.object_id
    parse_block(statement.last.last)
    object.dynamic = false

  end
end

class ClassAttributeHandler < YARD::Handlers::Ruby::AttributeHandler
  handles method_call(:attribute)
  namespace_only

  YARD::Parser::SourceParser.before_parse_file do |p|
    @@parsed_file =  p.file.to_s
  end

  process do

    path_arr = @@parsed_file.to_s.split('/')
    ext_obj = YARD::Registry.resolve(:root, "#{path_arr[0].to_s}::#{path_arr[1].to_s}::#{path_arr[2].to_s}::#{path_arr[3].to_s}", true)
    read, write = true, false
    params = statement.parameters(false).dup
    params.pop

    name = statement.parameters.first.jump(:tstring_content, :ident).source
    attr_new = MethodObject.new(ext_obj, name, scope) do |o|
      src = "attribute :#{name},"
      full_src = statement.first_line
      o.source ||= full_src
      o.signature ||= src
      full_docs=nil
      param_line = nil
      cut_line = nil

      if (statement.comments.to_s.include? "param" || "attribute")
          o.docstring = statement.comments.to_s
      else
        st_comments = statement.comments.to_s

        if (statement.comments.to_s.empty?)
          full_docs = "Sets the attribute #{name}"
        else
          full_docs = "Sets the attribute #{name}"
          #full_docs = statement.comments.to_s
        end

        cut_line = statement.first_line.delete "\"" "=>"
        param_line = cut_line.split(', :')
        param_line.each do |e|

         if (!e.to_s.include? "attribute")
           if (e.to_s.include? "kind_of")
             e_splited = e.to_s.split(' ')
             full_docs << " \n@return [#{e_splited[1].to_s}] "
           else
             full_docs << " \n@param #{e.to_s} "
           end
         else
           c_temp=1
         end

        end
        o.docstring = full_docs
      end
      o.visibility = visibility
    end
    push_state(:scope => :class) {
      YARD::Registry.register (attr_new)
      attr_new.object_id
                                  }
  end

end

#must be in the end of the script
#########################################################

paths = ['cookbooks/*/providers/*.rb','cookbooks/*/resources/*.rb','cookbooks/*/definitions/*.rb']

YARD::Parser::SourceParser.before_parse_file do |parser|
  #puts "#{parser.file} is #{parser.contents.size} characters"
  path_var = parser.file.to_s.split('/')

  id0 = YARD::CodeObjects::ClassObject.new(:root, path_var[0].to_s) do |o|
    o.docstring = "#{path_var[0]}folder"
  end
  id0.add_file("#{parser.file.to_s}", nil, false)
  YARD::Registry.register(id0)
  id0.object_id

    id1 = YARD::CodeObjects::ClassObject.new(id0, path_var[1].to_s) do |o|
       if (File.exists?(File.dirname(__FILE__)+'/'+path_var[0].to_s+'/'+path_var[1].to_s+'/'+'README.rdoc'))
         o.docstring = IO.read(File.join(File.dirname(__FILE__)+'/'+path_var[0].to_s+'/'+path_var[1].to_s+'/', 'README.rdoc'))
       else
         o.docstring = "#{path_var[1]} folder"
       end
      #o.docstring = "#{path_var[1]} folder"
      #o.docstring = IO.read(File.join(File.dirname(__FILE__)+'/'+path_var[0].to_s+'/'+path_var[1].to_s+'/', 'README.rdoc'))
    end
    id1.add_file("#{parser.file.to_s}", nil, false)
    YARD::Registry.register(id1)
    id1.object_id

  id2 = YARD::CodeObjects::ClassObject.new(id1, path_var[2].to_s) do |o|
      o.docstring = "#{path_var[2]}folder"
    end
    id2.add_file("#{parser.file.to_s}", nil, false)
    YARD::Registry.register(id2)
    id2.object_id

  id3 = YARD::CodeObjects::ClassObject.new(id2, path_var[3].to_s) do |o|
    o.docstring = "Default #{path_var[3].to_s} file"
    o.group = "Default #{path_var[3].to_s} file"
  end
  id3.add_file("#{parser.file.to_s}", nil, false)
  YARD::Registry.register(id3)
  id3.object_id
end

YARD.parse(paths)












