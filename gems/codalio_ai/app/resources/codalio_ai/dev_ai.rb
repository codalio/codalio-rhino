# frozen_string_literal: true

module CodalioAi
  class DevAi
    include Rhino::Resource

    rhino_owner_global

    rhino_routing only: %i[show create], singular: true, path: "dev/ai"
    rhino_controller :simple
    rhino_policy :dev_ai

    def self.describe
      nil
    end

    def self.model_list
      Rhino.resource_classes.index_with(&:describe).compact.transform_keys do |r|
        r.model_name.singular
      end
    end

    def self.client_path
      Rails.root.join("../client")
    end

    def self.rhino_config_path
      File.join(client_path, "src/rhino.config.js")
    end

    def self.openapi_schema_get
      puts "Getting openapi schema"

      JSON.pretty_generate({ response: model_list, response2: File.read(rhino_config_path) })
    end

    def self.rhino_config
      File.read(rhino_config_path)
    end

    def self.rhino_config_get
      rhino_config
    end

    def self.rhino_config_set(content:)
      puts content
      File.write(rhino_config_path, content)

      { response: "Updated rhino.config.js to #{content}" }
    end

    def self.dev_ai_endpoint
      ENV["CODALIO_ENDPOINT"] || "https://api.codalio.com"
    end

    def self.client
      Faraday.new do |f|
        f.response :logger
        f.request :json # encode req bodies as JSON
        f.response :json # decode response bodies as JSON
        f.adapter :httpclient
        f.headers["Authorization"] = ENV["CODALIO_API_KEY"]
      end
    end

    def self.show
      { enabled: ENV["CODALIO_API_KEY"].present? }
    end

    # def self.create(params)
    #   tool_data = params.permit(:content, contexts: {}).to_h.merge({ model_list:, rhino_config: })
    #   response = client.post("#{dev_ai_endpoint}/api/tool/ai", tool_data)

    #   response.body.each do |k, v|
    #     send(k, **JSON.parse(v).symbolize_keys) if respond_to?(k)
    #   end
    #   # rhino_config_set(content: response.body["rhino_config_set"]) if response.success? && response.body["rhino_config_set"].present?

    #   response.body
    # end

    def self.create(params)
      ai_info = params.require(:simple).permit!.to_h
      tool_calls = ai_info[:tool_calls]
      # response = client.post("#{dev_ai_endpoint}/api/tool/ai", tool_data)

      ai_info[:tool_calls] = tool_calls.map do |tool|
        name = tool.dig(:function, :name)
        next unless respond_to?(name)

        {
          tool_call_id: tool[:id],
          role: "tool",
          name:,
          content: send(name, **JSON.parse(tool[:function][:arguments]).symbolize_keys)
        }
      end.compact
      # # rhino_config_set(content: response.body["rhino_config_set"]) if response.success? && response.body["rhino_config_set"].present?

      # response.body
      ai_info
    end

    def self.model_name
      ActiveModel::Name.new(self)
    end
  end
end
