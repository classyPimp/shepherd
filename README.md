# Shepherd

Crystal web framework with these goals:
1. Api centric
2. Offer familiar concepts like controllers, routing, and TODO: models
3. Offer easy websockets integration.
4. Easy to reason source code.
5. Simplicity, easy to extend with custom code (giving you the minimum unopinionated base), so you can roll your own code.

TODO: more goals will be added. It's just 0.1 yet :)

# Controllers

We all know what they are. It's just a POCR (plain old Crystal) :) classes which will be instantiated, and whose method will be called when router mathces appropriate request path.

One thing though, they are supposed not to be the god objects like they often are, but rather "main" functions for each request, dispatching to other reponsible classes.

Your controllers reside in app/controllers/, and to add one just add a class
following this name convention: 
`
App::Controllers::YOURCONTROLLERNAME  < Shepherd::Controller::Base ; end
`

Conttrollers do have methods that:
1. have access to request and it's data
2. rendering methods.

##### Request object
you can access the `request : HTTP::Server::Request` of current request through getter `request`

##### Params
the methods to access the info including body, JSON payload, ecoded form data and etc. Controller has the property `params`, that is actually a lazily instantiated `Shepherd::Server::Request::Params`

so in controller you access as:

`params.json : JSON::Any` which will parse the body to JSON::Any

`params.route : Hash(String, String)` will return the hash, having the route params that where set in router, e.g.:

```
get "/foo/:id", to: "posts#bar"

posts#bar
  render plain: params.route["id"] #=> "some id"
end
```

`body : String?` returns the body of request

`encoded_form : HTTP::Params` if you had encoded form (anyway returns empty if cannot parse or wrong content type)

`url_query : HTTP::Params` obvious

TODO: `params[](val) : HTTP::Params | JSON::Any | Nil | String` generic accessor (will evaluate everything till it finds , or returns nil), not encouraged.

TODO: more functionality will be added . It's just 0.1 yet :)

##### Q: you may ask why seaccess params separately, why no just params[:val]?
##### A: 
that is for performance reasons, to not eavaluate and parse what you don't need.
e.g. you have class with schema JSON, so you want to be able to parse it with it like `json = SomeClass.parse(params.body)`.
keep in my mind that all params are lazily evaluated so not accessing them, gives no performance penalty. E.g. `paramas.route["id"]` will not parse `json` nor `url_query` and vice versa.

## rendering methods
`render(plain value : String) : Nil` will set content type to text/plain and print value to response

`render(json value ) : Nil` will set content type to application/json and render value.to_json

`head(status_code : Int32)` will set status_code on response

TODO: more will be added including views and etc. It's just 0.1 yet :)

### when rendering is happening
App prints to response only if you call the appropriate method, if you do not call any render method, or not change the status code. App will just head 200. 
Controllers do not keep track if you render twice, so keep it in mind.

### functional controllers:
same as controllers but supposed to not instantiate selfs for each request using static methods only and having no state (for performance reasons), or if you think functional style is cool (it's not).

to define one in controller run `has_functional_actions` macro
functional controllers can access the params via `params(context : HTTP::Context) : Shepherd::Server::Request::Params`, and rendering via: `render(context, args) : Nil` (with overloads)
example usage:

```
App::Routes::Map
    def draw
        namespace "/api" do
          get "/foo", to: "users.index" #delimit method with dot so it won't be instantiated
        end
    end
end

class App::Controller::Users < Shepherd::Controller::Base
  
  acts_as_functional #macro that gives some special methods
  
  def self.index(context)
    value_to_render = params(context.request).url_query["foo"]
    render context.response, plain: value_to_render 
  end
end
```
# what to do if no functionality is given for your needs
Just add your own. For example even your controllers don't need to inherit from controller::Base
it can be struct or even module with stuff you think you need, all you need is to accept `context` on initialize or in method (if you define root to "your_class.yourmethod" with dot).

Anyone could write what's in this repository. Idea is to give you basic minimum comfortable "boilerplate" to build your own stuff.

# HTTP routing
You routes are defined in app/routes/map, in App::Routes::Map #draw method's body. 
All possibilites are in this snippet.
on incoming request, if request.path matches the registered route, appropriate controller with appropriate method will be called.
```
class App::Routes::Map
        #define routes here
    def draw
        #on request GET req with "/" will instantiate App::Controller::Home with context
        #and call its #index method
        #behind the scenes will just App::Controller::Home.new(context).index
        get "/" to: "home#index" 
        
        #on PUT request to "/aaa" will call App::Controller::Home without instantiating 
        #calling .show on it with passing it context
        #behind the scenes App::Controller::Home.show(context)
        put "/aaa/:id" to: "home.show" 
        
        #ads wildcards route like Rails
        get "/*", to: "home#index" 
        
        #adds parametrized routes like Rails
        get "/users/:id", to: "users#show" # later access in controller params.route["id"]
        
        #adds namespaced routes like Rails
        namespace "/api" do 
        
            # path is /api/bar
            post "/bar", to: "posts.joe" 
            
            #namespaces can be nested
            namespace "/foo/v1" do 
                #path is /api/foo/v1/baz
                delete "/baz", to: "posts#delete" 
                #resource routes will respect namespaced paths
                resources "posts", with: ["#index", ".show", ".delete"]
            end
            
        end
        
        # will create REST methods to appropriate actions (all instance) the same as Rails
        resources "users" 
        
        #will only create routes to those actions,
        #as well this way you can specify wheter instance or functional controller 
        #action shall be called by adding (dot .) or (#) between name and method
        resources "posts", with: ["#index", ".show"]
        
    end

end
```

# Websockets

well socket handling is a bit tricky, and while I was writing it mindfucked me as the "inception" movie 

##### Concept is:
app can have separate distinct websocket connection entries, e.g. one is general - which is responsible for json exchange, and others for any other staff (some protected connection, or even maybe you will write some voice transmition protocol and etc). 

Most apps will need only one connection entry.

Each connection has it's own message processors for the incoming messages it recieves after the connection established.

So in broad sense, the connection entry point sits as hhtp route payload (the request to connect comes with get header) and when you add it to routes map, it starts it's own parralel listening to the messages it recieves (so called ws route map), and has the specialized for that connection type message controllers. So it's like server in server `exibit.jpg` ( they are not handlers in sense of Crystal's HTTP::Handler) .

To get it easier, just imagine that you would have some controller that is responsible for first user entry, later on as soon as user hits that controller - you will have the special routing and controllers specific to that users.
same here for ConnectionEntry (you can think of it as connection type), has it's own routing which will call own controllers when something is passed as message through that connections

Thanks to crystal you can literraly have tens of thousands connections on one machine (don't forget to set `ulimit -n overninethousand` on ubuntu)

##### That sounds a bit complicated but just look at this snippet and you'll get how easy it is
you just reason about it the same as you would do with standart Http routing
```
# in router
ws_connection "/general", to: "general" do
  msg "/index", to: "test#index"
  namespace "/test" do
    msg "/show", to: "test#show"
  end
  msg "/delete", to "test#delete"
end

in app/ws/connection_entries
class App::WS::ConnectionEntries::General < Shepherd::WebSockets::ConnectionEntry::Base
  def self.on_connection_request
    if current_user.ok? #fantasy method
       #since this point server will try establish connection, 
       #if socket connected #on_connection_established with fresh connection will be called
      connect 
    else
     reject
    end
  end
  
  def on_connection_established
    socket.send "established #{socket}"
    #register connection in redis for example
    RedisBaz.register[current_user.id] = connection #fantasy
  end
  
  def before_disconnect(connection)
    connection.send "disconnecting #{connection}"
    RedisBaz.cleanup current_user.id #fantasy
  end
  
end

in app/ws
class App::WS::MessageControllers::Test

  def index
    add connection, to: "test_channel" #fantasy
    send "message path was sent to /index, hello from test#index to #{connection}"
  end
  
  def show
    if connection, in: "test_channel" #fantasy
        user =  User.find(json_any_payload["user_id"]).to_s #this is fantasy method
        send "#{user}#{connection}"
    else
      send "sorry #{connection} you should've sent message to /bar/baz before to be able to see user "
    end
  end
  
  def delete
    send "bye #{connection}"
    purge connection, from: "test_channel" if in: "test_channel"
    to users, in : "test_channel", send: "#{connection} has left test_channel" #fantasy
    disconnect
  end
end

in js.
on client 1 (ok user)
var socket = new WebSocket("ws://localhost/general")
#=> established #<WebSocket:0x0000001>
socket.send("/index|") 
#=> "message path was sent to /index, hello from test#index #<WebSocket:0x0000001>"
socket.send("/test/show|{user_id: 4}") 
#=> {id: 4, name: "Joe"}#<WebSocket:0x0000001>
socket.close() 
#=> disconnecting #<WebSocket:0x0000001>

on client 2 (ok user)
var socket = new WebSocket("ws://localhost/general")
#frame=> established #<WebSocket:0x0000002>
socket.send("/index|") 
#frame=> "message path was sent to /index, hello from test#index #<WebSocket:0x0000002>"
socket.send("/test/show|{"user_id": 3}") 
#frame=> {id: 3, name: "Schmoe"}#<WebSocket:0x0000002>
socket.send("/disc") 
#frame=> bye #<WebSocket:0x0000002>
#frame=> disconnecting #<WebSocket:0x0000002>
socket.send("/index|")
#=> error socket is already in CLOSING or CLOSED state.

on client 3 (not ok user)
var socket = new WebSocket("ws://localhost/general")
#=> Error during WebSocket handshake: Unexpected response code: 401

on client 4 (ok user)
var socket = new WebSocket("ws://localhost/general")
#frame=> established #<WebSocket:0x0000003>
socket.send("/test/show|{user_id: 7}") 
#frame=> "sorry #<WebSocket:0x0000003> you should've sent message to /index before to be able to see user "
socket.send("/index|")
#frame=> "message path was sent to /index, hello from test#index #<WebSocket:0x0000002>"
after client 2 and 1 sent message to  /disc
#=>"#<WebSocket:0x0000002> has left test_channel"
#=>"#<WebSocket:0x0000001> has left test_channel"

```
TODO: describe WS routing; ws connection entries; ws message controllers

#### conventions
I don't know why but I did that each class resides in it's own file, and it's name repeats the file
structure just like in one language I forgot the name of
TODO:

# credits and thanks
Super thanks to crystal core team and @asterite specifically for giving us Crystal

Router uses luislavena/radix, thanks that shard is awesome!

Learned from manastech/frank, sdogruyol/kemal you're awesome!

Rails and Ruby no comments

# and thanks to all Crystal community.


## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/[your-github-name]/shepherd/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[your-github-name]](https://github.com/[your-github-name]) classyPimp - creator, maintainer
