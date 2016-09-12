#adds route_params accessor; shall be user for copying #params from Radix::Result when route is found
#currently route_params are assigned in RouteHandler
module Shepherd::CoreExtensions::Modules::RadixResultParamsAccessor

  macro included

    #accessing params of Radix::Result#params
    property :route_params

    @route_params = {} of String => String

  end

end
