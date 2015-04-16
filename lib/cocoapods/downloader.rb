require 'cocoapods-downloader'
require 'claide/informative_error'
require 'fileutils'
require 'tmpdir'

module Pod
  module Downloader
    require 'cocoapods/downloader/cache'
    require 'cocoapods/downloader/request'
    require 'cocoapods/downloader/response'

    def self.download(
      request,
      target,
      cache_path: !Config.instance.skip_download_cache && Config.instance.cache_root + 'Pods'
    )
      cache_path, tmp_cache = Pathname(Dir.mktmpdir), true unless cache_path
      cache = Cache.new(cache_path)
      result = cache.download_pod(request)
      if target
        FileUtils.rm_rf target
        FileUtils.cp_r(result.location, target)
      end
      result
    ensure
      FileUtils.rm_r cache_path if tmp_cache
    end

    class DownloaderError; include CLAide::InformativeError; end

    class Base
      override_api do
        def execute_command(executable, command, raise_on_failure = false)
          Executable.execute_command(executable, command, raise_on_failure)
        rescue CLAide::InformativeError => e
          raise DownloaderError, e.message
        end

        # Indicates that an action will be performed. The action is passed as a
        # block.
        #
        # @param  [String] message
        #         The message associated with the action.
        #
        # @yield  The action, this block is always executed.
        #
        # @return [void]
        #
        def ui_action(message)
          UI.section(" > #{message}", '', 1) do
            yield
          end
        end

        # Indicates that a minor action will be performed. The action is passed
        # as a block.
        #
        # @param  [String] message
        #         The message associated with the action.
        #
        # @yield  The action, this block is always executed.
        #
        # @return [void]
        #
        def ui_sub_action(message)
          UI.section(" > #{message}", '', 2) do
            yield
          end
        end

        # Prints an UI message.
        #
        # @param  [String] message
        #         The message associated with the action.
        #
        # @return [void]
        #
        def ui_message(message)
          UI.puts message
        end
      end
    end
  end
end
