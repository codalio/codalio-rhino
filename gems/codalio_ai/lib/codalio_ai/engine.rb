require "rhino/engine"
require "codalio_ai/version"
module CodalioAi
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path("../../lib", __dir__)

    initializer "codalio_ai.register_module" do
      config.after_initialize do
        Rhino.registered_modules[:codalio_ai] = {
          version: CodalioAi::VERSION::STRING
        }

        Rhino.resources += ["CodalioAi::DevAi"] if Rails.env.development?
      end
    end
  end
end
