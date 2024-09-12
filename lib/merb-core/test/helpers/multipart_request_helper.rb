# encoding: UTF-8

module Merb::Test::MultipartRequestHelper
  require 'rubygems'
  require 'mime/types'

  class Param
    attr_accessor :key, :value

    # @param  [#to_s] key   The parameter key.
    # @param  [#to_s] value The parameter value.
    def initialize(key, value)
      @key   = key
      @value = value
    end

    # @return [String]
    #   The parameter in a form suitable for a multipart request.
    def to_multipart
      return %(Content-Disposition: form-data; name="#{key}"\r\n\r\n#{value}\r\n)
    end
  end

  class FileParam
    attr_accessor :key, :filename, :content

    # @param  [#to_s] key       The parameter key.
    # @param  [#to_s] filename  Name of the file for this parameter.
    # @param  [#to_s] content   Content of the file for this parameter.
    def initialize(key, filename, content)
      @key      = key
      @filename = filename
      @content  = content
    end

    # @return [String]
    #   The file parameter in a form suitable for a multipart request.
    def to_multipart
      return %(Content-Disposition: form-data; name="#{key}"; filename="#{filename}"\r\n) + "Content-Type: #{MIME::Types.type_for(@filename).first}\r\n\r\n" + content + "\r\n"
    end
  end

  class Post
    BOUNDARY = '----------0xKhTmLbOuNdArY'
    CONTENT_TYPE = "multipart/form-data, boundary=" + BOUNDARY

    # @param [Hash] params Optional params for the controller.
    def initialize(params = {})
      @multipart_params = []
      push_params(params)
    end

    # Saves the params in an array of multipart params as Param and
    # FileParam objects.
    #
    # @param  [Hash]  params  The params to add to the multipart params.
    # @param  [#to_s] prefix  An optional prefix for the request string keys.
    def push_params(params, prefix = nil)
      params.sort_by {|k| k.to_s}.each do |key, value|
        param_key = prefix.nil? ? key : "#{prefix}[#{key}]"
        if value.respond_to?(:read)
          @multipart_params << FileParam.new(param_key, value.path, value.read)
        else
          if value.is_a?(Hash) || value.is_a?(Mash)
            push_params(value, param_key)
          elsif value.is_a?(Array)
            value.each { |v| push_params(v, "#{param_key}[]") }
          else
            @multipart_params << Param.new(param_key, value)
          end
        end
      end
    end

    # @return [Array<String,String>] The query and the content type.
    def to_multipart
      query = @multipart_params.collect { |param| "--" + BOUNDARY + "\r\n" + param.to_multipart }.join("") + "--" + BOUNDARY + "--"
      return query, CONTENT_TYPE
    end
  end

  # Similar to {Merb::Test::RequestHelper#dispatch_to dispatch_to} but allows
  # for sending files inside params.
  #
  # @note Set your option to contain a file object to simulate file uploads.
  #
  # @note Does not use routes.
  #
  # @param [Controller] controller_klass
  #   The controller class object that the action should be dispatched to.
  # @param [Symbol] action
  #   The action name, as a symbol.
  # @param [Hash] params
  #   An optional hash that will end up as params in the controller instance.
  # @param [Hash] env
  #   An optional hash that is passed to the fake request. Any request options
  #   should go here (see {RequestHelper#fake_request fake_request}).
  # @param &blk
  #   The block is executed in the context of the controller.
  #
  # @example
  #   dispatch_multipart_to(MyController, :create, :my_file => @a_file ) do |controller|
  #     controller.stub!(:current_user).and_return(@user)
  #   end
  #
  # @see Merb::Test::RequestHelper#dispatch_to
  #
  # @api public
  def dispatch_multipart_to(controller_klass, action, params = {}, env = {}, &blk)
    request = multipart_fake_request(env, params)
    dispatch_request(request, controller_klass, action, &blk)
  end

  # An HTTP POST request that operates through the router and uses multipart
  # parameters.
  #
  # @note To include an uploaded file, put a file object as a value in params.
  #
  # @param [String] path
  #   The path that should go to the router as the request uri.
  # @param [Hash] params
  #   An optional hash that will end up as params in the controller instance.
  # @param [Hash] env
  #   An optional hash that is passed to the fake request. Any request options
  #   should go here (see {RequestHelper#fake_request fake_request}).
  # @param &block
  #   The block is executed in the context of the controller.
  def multipart_post(path, params = {}, env = {}, &block)
    env[:test_with_multipart] = true
    mock_request(path, :post, params, env, &block)
  end

  # An HTTP PUT request that operates through the router and uses multipart
  # parameters.
  #
  # @note To include an uploaded file, put a file object as a value in params.
  #
  # @param [String] path
  #   The path that should go to the router as the request uri.
  # @param [Hash] params
  #   An optional hash that will end up as params in the controller instance.
  # @param [Hash] env
  #   An optional hash that is passed to the fake request. Any request options
  #   should go here (see {RequestHelper#fake_request fake_request}).
  # @param &block
  #   The block is executed in the context of the controller.
  def multipart_put(path, params = {}, env = {}, &block)
    env[:test_with_multipart] = true
    mock_request(path, :put, params, env, &block)
  end

  # @param [Hash] env
  #   An optional hash that is passed to the fake request. Any request options
  #   should go here (see {RequestHelper#fake_request fake_request}).
  # @param [Hash] params
  #   An optional hash that will end up as params in the controller instance.
  #
  # @return [RequestHelper::FakeRequest]
  #   A multipart `Request` object that is built based on the parameters.
  def multipart_fake_request(env = {}, params = {})
    if params.empty?
      fake_request(env)
    else
      m = Post.new(params)
      body, head = m.to_multipart
      fake_request(env.merge( :content_type => head,
                              :content_length => body.length), :post_body => body)
    end
  end
end
