class Shepherd::Router::Drawer

  INSTANCE = new



  macro inherited
    INSTANCE = new

    def  self.instance
      INSTANCE
    end
  end



  def  self.instance
    INSTANCE
  end



  @path = [""]
  @ws_name = ""
  @in_ws_block = false
  @current_ws_con : Shepherd::WebSockets::ConnectionEntry::Base?



  macro get(path, to controller)
    attach_http_route_to_map("get", @path.join("") + {{path}}, figure_out_controller({{controller}}))
  end



  macro post(path, to controller)
    attach_http_route_to_map("post", @path.join("") + {{path}}, figure_out_controller({{controller}}))
  end



  macro put(path, to controller)
    attach_http_route_to_map("put", @path.join("") + {{path}}, figure_out_controller({{controller}}))
  end



  macro patch(path, to controller)
    attach_http_route_to_map("patch", @path.join("") + {{path}}, figure_out_controller({{controller}}))
  end



  macro delete(path, to controller)
    attach_http_route_to_map("delete", @path.join("") + {{path}}, figure_out_controller({{controller}}))
  end


  macro attach_http_route_to_map(method, path, controller)

    Shepherd::Router::Http::Map.instance.add_route( {{ method }}, {{ path }}) do |context|
      {{ controller.id }}
    end

  end


  macro figure_out_controller(name)

    {% if (res = name.split("#")).size == 2 %}
      App::Controllers::{{res[0].camelcase.id}}.new(context).{{res[1].id}}
    {% elsif (res = name.split(".")).size == 2 %}
      App::Controllers::{{res[0].camelcase.id}}.{{res[1].id}}(context)
    {% else %}
      {{name.id}}
    {% end %}

  end


  macro scope(path, &block)
    @path << {{path}}
    {{ block.body }}
    @path.pop
  end


  macro ws_connection(path, to connection_entry_class, &block)
    @current_ws_con = constantize_connection_entry_class({{connection_entry_class}})
    add_ws_con_on_http({{path}}, {{connection_entry_class}})
    @in_ws_block = true
    {{block.body}}
    @ws_name = ""
    @in_ws_block = false
  end


  macro add_ws_con_on_http(path, class_name)
    Shepherd::Router::Http::Map.instance.add_route( "get", {{ path }}) do |context|
      constantize_connection_entry_class({{class_name}}).on_connection_request(context)
    end
  end



  macro constantize_connection_entry_class(name)
    App::WS::ConnectionEntries::{{ name.camelcase.id }}::INSTANCE
  end



  macro msg(path, to controller)

    @current_ws_con.as(Shepherd::WebSockets::ConnectionEntry::Base).route_map.add_route( @path.join("") + {{path}} ) do |connection, context, payload|
      figure_out_ws_controller({{ controller }})
    end

  end


  macro figure_out_ws_controller(name)

    {% if (res = name.split("#")).size == 2 %}
      App::WS::MessageControllers::{{res[0].camelcase.id}}.new(connection, context, payload).{{res[1].id}}
    {% elsif (res = name.split(".")).size == 2 %}
      App::WS::MessageControllers::{{res[0].camelcase.id}}.{{res[1].id}}(connection, context, payload)
    {%else%}
      raise "wrong to: argument"
    {% end %}

  end


  macro resources(resource_name, with only = nil)
    {%if only%}
      {% for action in only %}
        add_action({{action}}, {{resource_name}})
      {% end %}
    {%else%}
      resources({{resource_name}}, with: ["#index", "#new", "#show", "#edit", "#update", "#delete", "#create"])
    {%end%}
  end


  macro add_action(action, resource_name)
    {%if action.ends_with?("index") %}
      get("/#{{{resource_name}}}", to: "#{ {{resource_name}} }#{ {{action}} }")
    {%elsif action.ends_with?("new")%}
      get("/#{{{resource_name}}}/new", to: "#{ {{resource_name}} }#{ {{action}} }")
    {%elsif action.ends_with?("create")%}
      post("/#{{{resource_name}}}", to: "#{ {{resource_name}} }#{ {{action}} }")
    {%elsif action.ends_with?("show")%}
      get("/#{{{resource_name}}}/:id", to: "#{ {{resource_name}} }#{ {{action}} }")
    {%elsif action.ends_with?("edit")%}
      get("/#{{{resource_name}}}/:id/edit", to: "#{ {{resource_name}} }#{ {{action}} }")
    {%elsif action.ends_with?("update")%}
      patch("/#{{{resource_name}}}/:id", to: "#{ {{resource_name}} }#{ {{action}} }")
      put("/#{{{resource_name}}}/:id", to: "#{ {{resource_name}} }#{ {{action}} }")
    {%elsif action.ends_with?("delete")%}
      delete("/#{{{resource_name}}}/:id", to: "#{ {{resource_name}} }#{ {{action}} }")
    {%end%}
  end

end
