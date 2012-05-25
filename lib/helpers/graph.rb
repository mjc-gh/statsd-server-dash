# helpers for parsing and validating input
module StatsdServer
  module GraphHelpers
    def zero_fill!(results, range, step)
      results.tap do |data|
        # start from the first timestamp
        time = results.first.first + step
        index = 0

        while obj = data[index += 1]
          if obj.first == time
            time += step
            next
          end

          data.insert(index, [time, 0])

          time += step
        end
      end
    end
  end
end
