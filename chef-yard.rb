

class YARD::Handlers::Ruby::ModuleHandler < YARD::Handlers::Ruby::Base
  handles :module
  namespace_only

  YARD::Parser::SourceParser.before_parse_file do |p|
    @@parsed_file =  p.file.to_s
  end

  process do
    path_arr = @@parsed_file.to_s.split('/')
    ext_obj = YARD::Registry.resolve(:root, "#{path_arr[0].to_s}::#{path_arr[1].to_s}::#{path_arr[2].to_s}::#{path_arr[3].to_s}", true)

    modname = statement[0].source
    if (modname == 'DnsTools' || modname == 'Helper')
      puts modname
      mod = register ModuleObject.new(ext_obj, modname)
    end
    #mod = register ModuleObject.new(ext_obj, modname)
    parse_block(statement[1], :namespace => mod)
  end
end
#YARD.parse('cookbooks/*/libraries/*.rb')

#handler for chef "define" keywords
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
    object.dynamic = true

  end
end


#handler for chef "action" keywords
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

#handler for chef "attribute" keywords
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
          #full_docs = "Sets the attribute #{name}"
          full_docs = statement.comments.to_s
        end

        cut_line = statement.first_line.delete "\"" "=>"
        param_line = cut_line.split(', :')
        param_line.each do |e|

         if (!e.to_s.include? "attribute")
         #  if (e.to_s.include? "kind_of")
          #   e_splited = e.to_s.split(' ')
          #   full_docs << " \n@return [#{e_splited[1].to_s}] "
          # else
             full_docs << " \n@param #{e.to_s} "
         #  end
         else
           c_temp=1
         end

        end
        o.docstring = full_docs
      end
      o.visibility = visibility
    end
    attr_new.add_file("#{parser.file.to_s}", nil, false)
    push_state(:scope => :class) {
      YARD::Registry.register(attr_new)
      #attr_new.object_id
     # puts attr_new.path
                                  }
  end

end

#must be in the end of the script
#########################################################

#file paths which will be scanned
paths = ['cookbooks/*/providers/*.rb','cookbooks/*/resources/*.rb','cookbooks/*/definitions/*.rb','cookbooks/*/libraries/*.rb']

#preparing yarddoc dir/object structure
YARD::Parser::SourceParser.before_parse_file do |parser|

#new_root_nsp = YARD::Registry.resolve(:root, 'RightScale', false)
#puts new_root_nsp.path

  path_var = parser.file.to_s.split('/')
 # id0 = YARD::CodeObjects::ClassObject.new(new_root_nsp, path_var[0].to_s) do |o|
  #Root cookbook object
  id0 = YARD::CodeObjects::ClassObject.new(:root, path_var[0].to_s) do |o|
    #Description for coobooks
    if (File.exists?(File.join(File.dirname(__FILE__)+'/', 'LICENSE.rdoc')))
      o.docstring = IO.read(File.join(File.dirname(__FILE__)+'/', 'LICENSE.rdoc'))
    else
      o.docstring = "#{path_var[0]} folder"
    end

  end
  id0.add_file('/'+path_var[0].to_s, nil, false)
  YARD::Registry.register(id0)

  #Cookooks registration
  id1 = YARD::CodeObjects::ClassObject.new(id0, path_var[1].to_s) do |o|
    if (File.exists?(File.dirname(__FILE__)+'/'+path_var[0].to_s+'/'+path_var[1].to_s+'/'+'README.rdoc'))
      o.docstring = IO.read(File.join(File.dirname(__FILE__)+'/'+path_var[0].to_s+'/'+path_var[1].to_s+'/', 'README.rdoc'))
    else
      o.docstring = "#{path_var[1]} folder"
    end
  end
  id1.add_file('/'+path_var[0].to_s+'/'+path_var[1].to_s, nil, false)
  id1.superclass = id0
  YARD::Registry.register(id1)

  #Cookbooks elements registration
  id2 = YARD::CodeObjects::ClassObject.new(id1, path_var[2].to_s) do |o|
      o.docstring = "#{path_var[2]} folder"
  end
  id2.add_file('/'+path_var[0].to_s+'/'+path_var[1].to_s+'/'+path_var[2].to_s, nil, false)
  id2.superclass = id1
  YARD::Registry.register(id2)

  #Get description and license info for cookbooks elements (first 6 lines)
  desc =  IO.readlines(parser.file)
  str=""
  for i in 0..6
    str_t = desc[i].delete  '#'
      if i == 1
        str_t.insert(0, ' =')
      end
    str << str_t
  end

  id3 = YARD::CodeObjects::ClassObject.new(id2, path_var[3].to_s) do |o|
    o.docstring = str
  end

  id3.add_file("#{parser.file.to_s}", nil, false)
  id3.superclass = id2
  YARD::Registry.register(id3)

end

YARD.parse(paths)

#Remove duplicates in Top Level Namespace
a = YARD::Registry.paths
a.each do |e|
  #puts e
  if e[0].chr == '#'
    duplicate = YARD::Registry.resolve(:root, e, true)
    YARD::Registry.delete(duplicate)
    YARD::Registry.save
  end
end
