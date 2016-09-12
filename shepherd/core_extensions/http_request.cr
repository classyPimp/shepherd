require "../core_extensions/**"
#Monkey pathces HTTP::Request
class HTTP::Request

  #adds route_params accessor; shall be user for copying #params from Radix::Result when route is found
  #currently route_params are assigned in RouteHandler
  include Shepherd::CoreExtensions::Modules::RadixResultParamsAccessor

end
