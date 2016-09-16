class Storage

  def initialize(controller, key)
    unless controller.kind_of? ApplicationController
      raise 'argument sould be instance of ApplicationController'
    end
    @storage = controller.session[key] ||= {}
    @storage.symbolize_keys!
  end

  def method_missing(name, *args, &block)
    if @storage.respond_to? name
      @storage.send(name, *args, &block)
    else
      super
    end
  end

end
