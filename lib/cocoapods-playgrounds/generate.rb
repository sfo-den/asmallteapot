require 'fileutils'
require 'pathname'

module Pod
  class PlaygroundGenerator
    TEMPLATE_DIR = Pathname.new('Library/Xcode/Templates/File Templates/Source/Playground with Platform Choice.xctemplate')
    TEMPLATE_NAME = Pathname.new('___FILEBASENAME___.playground')

    def initialize(platform)
      @template = self.class.dir_for_platform(platform)
      raise "Could not find template for #{platform}" if @template.nil?
      @template += TEMPLATE_NAME
    end

    def generate(name)
      FileUtils.cp_r(@template, "#{name}.playground")
      Pathname.new("#{name}.playground")
    end

    def self.platforms
      Dir.entries(template_dir).map do |file|
        next if file.start_with?('.')
        next unless (template_dir + file).directory?
        platform_name(file)
      end.compact
    end

    def self.template_dir
      xcode = Pathname.new(`xcode-select -p`.strip)
      xcode + TEMPLATE_DIR
    end

    def self.platform_name(file)
      file.downcase.sub(' ', '').to_sym
    end

    def self.dir_for_platform(platform)
      Dir.foreach(template_dir) do |file|
        return (template_dir + file) if platform_name(file) == platform
      end
    end
  end
end
