defmodule PasswordGenerator do
  @moduledoc """
  Documentation for `PasswordGenerator`.
  Generates random password depends on arguments , Module main function is generate(options).
  Function takes argument as map
  Example for options :
         options = %{
          "length" => "7",
          "numbers" => "false",
          "uppercase" => "false",
          "symbols" => "false"
         }
  """
  @allowed_options [:length, :numbers, :uppercase, :symbools]

  @symbols  "!@#$%^&*()_-+=[]{}"

  @doc """
  generates password for given option

  ## Examples
       options = %{
          "length" => "7",
          "numbers" => "false",
          "uppercase" => "false",
          "symbols" => "false"
         }

      iex> PasswordGenerator.generate(options)
      "abcdefg"

      options = %{
          "length" => "7",
          "numbers" => "true",
          "uppercase" => "false",
          "symbols" => "false"
         }

      iex> PasswordGenerator.generate(options)
      "abcde43"

  """
  @spec generate(options :: map()) :: {:ok , bitstring()} | {:error , bitstring()}
  def generate(options) do
    length = Map.has_key?(options, "length")  #checks length is present or not
    validate_length(length , options)
  end

  defp validate_length(false , _options) do
    {:error, "Please provide a length"}
  end

  defp validate_length(true , options) do
    numbers = Enum.map(0..9 , &(Integer.to_string(&1)))  # generates list contains number from 0 to 9
    length = options["length"]                           # taking the value of length
    length = String.contains?(length, numbers)           # checking whether is integer or not
    validate_length_is_integer(length, options)
  end

  defp validate_length_is_integer(false , _options) do
    {:error, "Only integers allowed for length"}
  end

  defp validate_length_is_integer(true , options) do
    length = options["length"] |> String.trim() |> String.to_integer()       # Converting length value to int
    options_without_length = Map.delete(options, "length")                   # removing length key from options
    options_values = Map.values(options_without_length)                      # taking the rest values of options
    value = options_values |> Enum.all?(fn x -> String.to_atom(x) |> is_boolean() end) # checking all values are boolean
    validate_options_values_are_boolean(value , length , options_without_length)
  end

  defp validate_options_values_are_boolean(false , _length , _options_without_length) do
    {:error, "Only booleans allowed for options values"}
  end

  defp validate_options_values_are_boolean(true , length , options_without_length) do
    options = included_options(options_without_length)             # taking list of options that to be included in password
    invalid_options? = options |> Enum.any?(&(&1 not in @allowed_options)) # checking the option keys
    validate_options(invalid_options? , length, options)
  end

  defp validate_options(true , _length , _options) do
    {:error, "Only options allowed number, uppercase, symbols."}
  end

  defp validate_options(false , length , options) do
    generate_strings(length,options)
  end

  defp generate_strings(length,options) do
    options = [:lowercase_letter | options]
    included = include(options)
    length = length - length(included)
    random_strings = generate_random_strings(length,options)
    strings = included ++ random_strings
    get_result(strings)
  end

  defp get_result(strings) do
    string = strings |> Enum.shuffle() |> to_string()

    {:ok, string}
  end

  defp include(options) do
    options |> Enum.map(&get(&1))
  end

  defp get(:lowercase_letter) do
    <<Enum.random(?a..?z)>>
  end

  defp get(:uppercase_letter) do
    <<Enum.random(?A..?Z)>>
  end

  defp get(:numbers) do
    Enum.random(0..9) |> Integer.to_string()
  end

  defp get(:symbols) do
     symbols = @symbols |>String.split("", trim: true)
     Enum.random(symbols)
  end

  defp generate_random_strings(length,options) do
    Enum.map(1.. length, fn _->
      Enum.random(options) |> get()
    end)
  end

  defp included_options(options) do
    Enum.filter(options ,fn {_key, value}->
        value |> String.trim() |> String.to_existing_atom()
    end) |> Enum.map(fn {key , _value}-> String.to_atom(key) end)
  end
end
