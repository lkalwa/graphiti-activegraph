module Graphiti::ActiveGraph
  module Runner
    def initialize(resource_class, params, query = nil, action = nil)
      @resource_class = resource_class
      @params = params
      @query = query
      @action = action

      validator = ::Graphiti::RequestValidator.new(jsonapi_resource, params, action)

      validator.validate! unless params[:skip_render_val]

      @deserialized_payload = validator.deserialized_payload
    end

    def proxy(base = nil, opts = {})
      base ||= jsonapi_resource.base_scope
      preloaded = opts[:preloaded] || (opts[:self_as_preloaded] ? instance_variable_get(:@jsonapi_resource) : nil)
      scope_opts = opts.slice(:sideload_parent_length,
                              :default_paginate,
                              :after_resolve,
                              :sideload,
                              :parent,
                              :params).merge(unpaginated_query: params[:unpaginated_query], preloaded: preloaded)
      scope = jsonapi_scope(base, scope_opts)
      options = { payload: deserialized_payload,
        single: opts[:single],
        raise_on_missing: opts[:raise_on_missing],
        preloaded: preloaded
      }
      ::Graphiti::ResourceProxy.new jsonapi_resource,
        scope,
        query,
        options
    end
  end
end

