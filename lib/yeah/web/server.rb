require 'pathname'
require 'erb'
require 'rack'
require 'opal'
require 'yeah/web/builder'

module Yeah
module Web

# The `Web::Server` serves a game over the web. To start a game web server,
# enter `yeah serve` in a command-line within a game project.
class Server
  # @param [Integer] port
  # @return [nil]
  # Start web server for game in working directory.
  def start(port = 1234, opts={})
    Opal::Processor.inline_operators_enabled = true

    runner = Runner.new

    assets = Opal::Environment.new

    # Append standard library code paths.
    $LOAD_PATH.each { |p| assets.append_path(p) }

    # Append gem code paths.
    assets.append_path gem_path.join('lib')
    assets.append_path gem_path.join('opal')

    # Append game code and asset paths.
    assets.append_path 'assets'
    assets.append_path 'code'

    source_maps = Opal::SourceMapServer.new(assets, '/assets')

    application = Rack::Builder.new do
      use Rack::Deflater

      map '/' do
        run runner
      end

      map '/assets' do
        run Rack::Cascade.new([assets, source_maps])
      end
    end

    Rack::Server.start(app: application, Port: port)
  end

  private

  def gem_path
    @gem_path ||= Pathname.new(__FILE__).join('..', '..', '..', '..')
  end

  # `Web::Runner` is a Rack app that provides the runner webpage for
  # `Web::Server`.
  # @see Yeah::Web::Server
  class Runner
    include Yeah::Web::BuildTools

    def call(environment)
      runner_path = Pathname.new(__FILE__).join('..', 'runner.html.erb')
      html = ERB.new(File.read(runner_path)).result(binding)

      # rebuild the game on every page reload 
      if ENV['YEAH_ENV']=='development'
        require 'yeah/web/builder'
        Yeah::Web::Builder.new.build
      end 
      [200, {'Content-Type' => 'text/html'}, [html]]
    end

    private
    # asset_include_tags and script_include_tag(path) are now included with Yeah::Web::BuildTools

  end
end

end
end
