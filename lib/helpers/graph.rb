# helpers for parsing and validating input
module StatsdServer
  module GraphHelpers
    def zero_fill!(results, range, step)
			step *= 1000 # convert to milisec

      results.tap do |data|
        # start from the first timestamp
        time = results.first.first + step
        break_ts = results.last.first
        index = 0

        while obj = data[index += 1]
          ts = obj.first

          # explicit break to handle uneven intervals
          break if time > break_ts

          if ts == time
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
