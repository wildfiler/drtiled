module Tiled
  module Utils
    module_function def relative_to_absolute(path)
      absolute_path = path.split(File::SEPARATOR).inject([]) do |memo, element|
        if element == ".."
          memo.shift
        else
          memo.push(element)
        end
        memo
      end

      File.join(*absolute_path)
    end
  end
end
