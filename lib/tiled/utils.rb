module Tiled
  module Utils
    module_function def relative_to_absolute(path)
      absolute_path = path.split(File::SEPARATOR).inject([]) do |memo, element|
        if element == ".."
          memo.pop
        else
          memo.push(element)
        end
        memo
      end

      File.join(*absolute_path)
    end

    module_function def convert_relative_path(path, relative_file)
      Utils.relative_to_absolute(File.join(File.dirname(path), relative_file))
    end

    module_function def gcd(a, b)
      if a % b == 0
        b
      else
        gcd(b, a % b)
      end
    end
  end
end
